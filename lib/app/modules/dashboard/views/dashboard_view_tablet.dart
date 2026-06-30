import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/dashboard_controller.dart';
import '../../../data/models/post_model.dart';
import '../../layout/controllers/layout_controller.dart';

class DashboardViewTablet extends GetView<DashboardController> {
  const DashboardViewTablet({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          _DashTopBar(controller: controller),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(
                  child: CircularProgressIndicator(color: AppColors.violet, strokeWidth: 2),
                );
              }
              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _StatsGrid(controller: controller),
                    const SizedBox(height: 28),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 6,
                          child: Column(
                            children: [
                              _ChartCard(controller: controller),
                              const SizedBox(height: 20),
                              _RecentProjectsCard(controller: controller),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          flex: 4,
                          child: Column(
                            children: [
                              _StyleDNACard(controller: controller),
                              const SizedBox(height: 20),
                              _AchievementsCard(controller: controller),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _DashTopBar extends StatelessWidget {
  final DashboardController controller;
  const _DashTopBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.9),
        border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.violet,
              boxShadow: [
                BoxShadow(
                  color: AppColors.violet.withValues(alpha: 0.8),
                  blurRadius: 4,
                  spreadRadius: 1,
                )
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text('Pulse', style: GoogleFonts.lexend(
            color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.2)),
          const SizedBox(width: 8),
          Text('Analytics', style: GoogleFonts.plusJakartaSans(
            color: AppColors.textTertiary, fontSize: 12)),
          const Spacer(),
          Obx(() => Row(
            children: ['Week', 'Month', 'Year'].map((p) {
              final active = controller.selectedPeriod.value == p;
              return GestureDetector(
                onTap: () => controller.selectPeriod(p),
                child: _SegmentTab(label: p, active: active),
              );
            }).toList(),
          )),
          const SizedBox(width: 16),
          _RefreshBtn(controller: controller),
        ],
      ),
    );
  }
}

class _SegmentTab extends StatefulWidget {
  final String label;
  final bool active;
  const _SegmentTab({required this.label, required this.active});

  @override
  State<_SegmentTab> createState() => _SegmentTabState();
}

class _SegmentTabState extends State<_SegmentTab> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(left: 6),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            gradient: widget.active
                ? AppColors.violetPink
                : (_isHovered
                    ? LinearGradient(colors: [
                        AppColors.violet.withValues(alpha: 0.1),
                        AppColors.pink.withValues(alpha: 0.05)
                      ])
                    : null),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.active
                  ? Colors.transparent
                  : (_isHovered
                      ? AppColors.violet.withValues(alpha: 0.4)
                      : AppColors.border),
              width: 0.8,
            ),
            boxShadow: widget.active
                ? [
                    BoxShadow(
                      color: AppColors.violet.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    )
                  ]
                : [],
          ),
          child: Text(
            widget.label,
            style: GoogleFonts.plusJakartaSans(
              color: widget.active
                  ? Colors.white
                  : (_isHovered ? AppColors.violet : AppColors.textTertiary),
              fontSize: 11,
              fontWeight: widget.active || _isHovered ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _RefreshBtn extends StatefulWidget {
  final DashboardController controller;
  const _RefreshBtn({required this.controller});

  @override
  State<_RefreshBtn> createState() => _RefreshBtnState();
}

class _RefreshBtnState extends State<_RefreshBtn> with SingleTickerProviderStateMixin {
  late AnimationController _spinController;
  late Animation<double> _spinAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _spinAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _spinController, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _spinController.forward(from: 0.0);
    widget.controller.fetchDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedScale(
          scale: _isHovered ? 1.08 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _isHovered ? AppColors.violet.withValues(alpha: 0.08) : AppColors.surface2,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _isHovered ? AppColors.violet.withValues(alpha: 0.35) : AppColors.border,
                width: 0.8,
              ),
            ),
            child: RotationTransition(
              turns: _spinAnimation,
              child: Icon(Icons.refresh_rounded, size: 16, color: _isHovered ? AppColors.violet : AppColors.textTertiary),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final DashboardController controller;
  const _StatsGrid({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() => Row(
      children: [
        _KpiCard(value: '${controller.totalViews.value}', label: 'VIEWS', color: AppColors.teal, icon: Icons.visibility_outlined),
        const SizedBox(width: 12),
        _KpiCard(value: '${controller.totalLikes.value}', label: 'LIKES', color: AppColors.pink, icon: Icons.favorite_outline_rounded),
        const SizedBox(width: 12),
        _KpiCard(value: '${controller.totalArtworks.value}', label: 'WORKS', color: AppColors.violet, icon: Icons.palette_outlined),
        const SizedBox(width: 12),
        _KpiCard(value: '${controller.followerCount.value}', label: 'FOLLOWERS', color: AppColors.amber, icon: Icons.people_outline_rounded),
      ],
    ));
  }
}

class _KpiCard extends StatefulWidget {
  final String value;
  final String label;
  final Color color;
  final IconData icon;
  const _KpiCard({required this.value, required this.label, required this.color, required this.icon});

  @override
  State<_KpiCard> createState() => _KpiCardState();
}

class _KpiCardState extends State<_KpiCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedScale(
          scale: _isHovered ? 1.04 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: _isHovered 
                  ? widget.color.withValues(alpha: 0.1) 
                  : widget.color.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isHovered 
                    ? widget.color.withValues(alpha: 0.4) 
                    : widget.color.withValues(alpha: 0.15),
                width: 0.8,
              ),
              boxShadow: _isHovered 
                  ? [
                      BoxShadow(
                        color: widget.color.withValues(alpha: 0.15),
                        blurRadius: 16,
                        spreadRadius: 1,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : [],
            ),
            child: Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: widget.color.withValues(alpha: 0.25),
                      width: 0.8,
                    ),
                  ),
                  child: Icon(widget.icon, color: widget.color, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.value, style: GoogleFonts.lexend(
                        color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w900)),
                      Text(widget.label, style: GoogleFonts.ibmPlexMono(
                        color: widget.color.withValues(alpha: 0.7), fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final DashboardController controller;
  const _ChartCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'ENGAGEMENT',
      subtitle: 'Views over time',
      child: Obx(() {
        final values = controller.chartValues;
        if (values.isEmpty) {
          return SizedBox(height: 140, child: Center(
            child: Text('No data', style: TextStyle(color: AppColors.textTertiary)),
          ));
        }
        final max = values.reduce((a, b) => a > b ? a : b).clamp(1.0, double.infinity);
        return SizedBox(
          height: 140,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: values.asMap().entries.map((e) {
              final h = (e.value / max) * 120;
              return _ChartBar(
                height: h.clamp(6.0, 120.0),
                value: e.value,
                index: e.key,
              );
            }).toList(),
          ),
        );
      }),
    );
  }
}

class _ChartBar extends StatefulWidget {
  final double height;
  final double value;
  final int index;
  const _ChartBar({required this.height, required this.value, required this.index});

  @override
  State<_ChartBar> createState() => _ChartBarState();
}

class _ChartBarState extends State<_ChartBar> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Tooltip(
          message: '${widget.value.toStringAsFixed(0)} views',
          child: MouseRegion(
            onEnter: (_) => setState(() => _isHovered = true),
            onExit: (_) => setState(() => _isHovered = false),
            child: AnimatedScale(
              scale: _isHovered ? 1.08 : 1.0,
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOutCubic,
              alignment: Alignment.bottomCenter,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300 + widget.index * 40),
                height: widget.height,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: _isHovered
                        ? [AppColors.pink, AppColors.violet]
                        : [AppColors.violet, AppColors.violetPinkColor],
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                  boxShadow: _isHovered
                      ? [
                          BoxShadow(
                            color: AppColors.violet.withValues(alpha: 0.4),
                            blurRadius: 10,
                            spreadRadius: 1,
                          )
                        ]
                      : [
                          BoxShadow(
                            color: AppColors.violet.withValues(alpha: 0.1),
                            blurRadius: 4,
                          )
                        ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RecentProjectsCard extends StatelessWidget {
  final DashboardController controller;
  const _RecentProjectsCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'RECENT WORKS',
      subtitle: 'Your latest posts',
      child: Obx(() {
        final posts = controller.recentProjects;
        if (posts.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text('No works yet', style: TextStyle(color: AppColors.textTertiary, fontSize: 12)),
          );
        }
        return Column(
          children: posts.take(5).toList().asMap().entries.map((e) {
            return _PostRow(post: e.value, index: e.key);
          }).toList(),
        );
      }),
    );
  }
}

class _PostRow extends StatefulWidget {
  final PostModel post;
  final int index;
  const _PostRow({required this.post, required this.index});

  @override
  State<_PostRow> createState() => _PostRowState();
}

class _PostRowState extends State<_PostRow> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: _isHovered
                ? AppColors.violet.withValues(alpha: 0.08)
                : AppColors.surface2,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _isHovered
                  ? AppColors.violet.withValues(alpha: 0.35)
                  : AppColors.border,
              width: 0.8,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: AppColors.violet.withValues(alpha: 0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    )
                  ]
                : [],
          ),
          child: Row(
            children: [
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.violet.withValues(alpha: 0.25),
                    width: 0.8,
                  ),
                  color: AppColors.violet.withValues(alpha: 0.1),
                  image: widget.post.url.isNotEmpty
                      ? DecorationImage(image: NetworkImage(widget.post.url), fit: BoxFit.cover)
                      : null,
                ),
                child: widget.post.url.isEmpty ? Icon(Icons.image_outlined, size: 16, color: AppColors.textTertiary) : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.post.name.isNotEmpty ? widget.post.name : 'Untitled',
                      maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Row(
                      children: [
                        Icon(Icons.favorite_rounded, size: 9, color: AppColors.pink),
                        const SizedBox(width: 3),
                        Text(
                          '${widget.post.likesCount}',
                          style: GoogleFonts.ibmPlexMono(color: AppColors.textTertiary, fontSize: 9),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.visibility_rounded, size: 9, color: AppColors.teal),
                        const SizedBox(width: 3),
                        Text(
                          '${widget.post.views}',
                          style: GoogleFonts.ibmPlexMono(color: AppColors.textTertiary, fontSize: 9),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              AnimatedSlide(
                offset: _isHovered ? const Offset(0.3, 0) : Offset.zero,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 10,
                  color: _isHovered ? AppColors.violet : AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate(delay: Duration(milliseconds: 60 * widget.index)).fadeIn(duration: 400.ms);
  }
}

class _StyleDNACard extends StatelessWidget {
  final DashboardController controller;
  const _StyleDNACard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'STYLE DNA',
      subtitle: 'Your creative fingerprint',
      child: Column(
        children: controller.styleDNA.entries.take(5).toList().asMap().entries.map((e) {
          final entry = e.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key,
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${(entry.value * 100).toStringAsFixed(0)}%',
                      style: GoogleFonts.ibmPlexMono(
                        color: AppColors.violet,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                _GlowProgressBar(value: entry.value),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _GlowProgressBar extends StatefulWidget {
  final double value;
  const _GlowProgressBar({required this.value});

  @override
  State<_GlowProgressBar> createState() => _GlowProgressBarState();
}

class _GlowProgressBarState extends State<_GlowProgressBar> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Stack(
        children: [
          Container(
            height: 6,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.border.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          FractionallySizedBox(
            widthFactor: widget.value.clamp(0.02, 1.0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 6,
              decoration: BoxDecoration(
                gradient: AppColors.violetPink,
                borderRadius: BorderRadius.circular(10),
                boxShadow: _isHovered
                    ? [
                        BoxShadow(
                          color: AppColors.pink.withValues(alpha: 0.5),
                          blurRadius: 8,
                          spreadRadius: 1,
                        )
                      ]
                    : [
                        BoxShadow(
                          color: AppColors.violet.withValues(alpha: 0.25),
                          blurRadius: 4,
                        )
                      ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementsCard extends StatelessWidget {
  final DashboardController controller;
  const _AchievementsCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: 'ACHIEVEMENTS',
      subtitle: 'Your milestones',
      child: Obx(() {
        final ach = controller.achievements;
        if (ach.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Keep creating to unlock achievements!',
              style: TextStyle(color: AppColors.textTertiary, fontSize: 12)),
          );
        }
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ach.take(6).map((a) => _AchBadge(title: a.title, unlocked: a.isUnlocked)).toList(),
        );
      }),
    );
  }
}

class _AchBadge extends StatefulWidget {
  final String title;
  final bool unlocked;
  const _AchBadge({required this.title, required this.unlocked});

  @override
  State<_AchBadge> createState() => _AchBadgeState();
}

class _AchBadgeState extends State<_AchBadge> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _wiggleController;
  late Animation<double> _wiggleAnimation;

  @override
  void initState() {
    super.initState();
    _wiggleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _wiggleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 0.0, end: 0.05), weight: 1),
      TweenSequenceItem(tween: Tween<double>(begin: 0.05, end: -0.05), weight: 2),
      TweenSequenceItem(tween: Tween<double>(begin: -0.05, end: 0.03), weight: 2),
      TweenSequenceItem(tween: Tween<double>(begin: 0.03, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _wiggleController, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _wiggleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final badgeColor = widget.unlocked ? AppColors.amber : AppColors.textTertiary;
    return GestureDetector(
      onTap: () {
        if (!widget.unlocked) {
          _wiggleController.forward(from: 0.0);
        }
      },
      child: MouseRegion(
        onEnter: (_) {
          setState(() => _isHovered = true);
          if (!widget.unlocked) {
            _wiggleController.forward(from: 0.0);
          }
        },
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedScale(
          scale: _isHovered ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          child: RotationTransition(
            turns: _wiggleAnimation,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: widget.unlocked 
                    ? AppColors.amber.withValues(alpha: 0.1) 
                    : AppColors.surface2,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: widget.unlocked 
                      ? (_isHovered ? AppColors.amber : AppColors.amber.withValues(alpha: 0.4)) 
                      : (_isHovered ? AppColors.textTertiary.withValues(alpha: 0.5) : AppColors.border),
                  width: 0.8,
                ),
                boxShadow: widget.unlocked && _isHovered
                    ? [
                        BoxShadow(
                          color: AppColors.amber.withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        )
                      ]
                    : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.unlocked ? Icons.emoji_events_rounded : Icons.lock_outline_rounded,
                    size: 12,
                    color: badgeColor,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    widget.title,
                    style: GoogleFonts.plusJakartaSans(
                      color: badgeColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  const _Card({required this.title, required this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.violet,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(title, style: GoogleFonts.ibmPlexMono(
                          color: AppColors.textTertiary, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 2)),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(subtitle, style: GoogleFonts.plusJakartaSans(
                      color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w700)),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: child,
          ),
        ],
      ),
    );
  }
}