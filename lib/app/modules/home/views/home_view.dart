import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/home_controller.dart';
import 'widgets/project_card.dart' as app_widgets;
import '../../layout/controllers/layout_controller.dart';
import '../../../core/theme/app_colors.dart';
import 'dialogs/create_project_dialog.dart';
class HomeView extends GetView<HomeController> {
  const HomeView({super.key});
  @override
  Widget build(BuildContext context) {
    final lc = Get.find<LayoutController>();
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          _AmbientOrbs(lc: lc),
          Column(
            children: [
              _TopBar(controller: controller, lc: lc),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 7,
                      child: _ProjectArea(controller: controller, lc: lc),
                    ),
                    Obx(() => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOutCubic,
                      width: controller.isSidebarOpen.value ? 280 : 0,
                      child: ClipRect(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const NeverScrollableScrollPhysics(),
                          child: SizedBox(
                            width: 280,
                            child: _ActivityPanel(controller: controller, lc: lc),
                          ),
                        ),
                      ),
                    )),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
class _TopBar extends StatelessWidget {
  final HomeController controller;
  final LayoutController lc;
  const _TopBar({required this.controller, required this.lc});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: lc.surfaceColor.withValues(alpha: 0.8),
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
          Text(
            'Studio',
            style: GoogleFonts.lexend(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.violet.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.violet.withValues(alpha: 0.25),
                width: 0.8,
              ),
            ),
            child: Obx(() => Text(
              '${controller.filteredProjects.length}',
              style: GoogleFonts.ibmPlexMono(
                color: AppColors.violet,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            )),
          ),
          const Spacer(),
          _FilterRow(controller: controller, lc: lc),
          const SizedBox(width: 16),
          _NewProjectBtn(controller: controller),
          const SizedBox(width: 16),
          Obx(() {
            final isDark = lc.isDark.value;
            return _imageBtn(
              isDark 
                  ? 'assets/images/branding/theme_light_btn.png' 
                  : 'assets/images/branding/theme_dark_btn.png',
              isDark ? 'Light Mode' : 'Dark Mode',
              () {
                lc.isDark.toggle();
                Get.changeThemeMode(lc.isDark.value ? ThemeMode.dark : ThemeMode.light);
              },
            );
          }),
          const SizedBox(width: 8),
          _imageBtn(
            'assets/images/branding/guide_btn.png',
            'Guide',
            () => Get.toNamed<void>('/guide'),
          ),
          const SizedBox(width: 8),
          _imageBtn(
            'assets/images/branding/settings_btn.png',
            'Settings',
            () => Get.toNamed<void>('/settings'),
          ),
          const SizedBox(width: 16),
          Container(width: 1, height: 24, color: AppColors.border),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: controller.toggleSidebar,
            child: Obx(() => Icon(
              controller.isSidebarOpen.value ? Icons.last_page_rounded : Icons.first_page_rounded,
              color: AppColors.textSecondary,
              size: 24,
            )),
          ),
        ],
      ),
    );
  }

  Widget _imageBtn(String imagePath, String tip, VoidCallback onTap) {
    return Tooltip(
      message: tip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 32,
          height: 32,
          padding: const EdgeInsets.all(4),
          child: Image.asset(
            imagePath,
            width: 24,
            height: 24,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.medium,
          ),
        ),
      ),
    );
  }
}
class _FilterRow extends StatelessWidget {
  final HomeController controller;
  final LayoutController lc;
  const _FilterRow({required this.controller, required this.lc});
  static const _filters = [
    ('All', 'all'),
    ('Animation', 'anim'),
    ('Artwork', 'art'),
    ('Starred', 'starred'),
  ];
  @override
  Widget build(BuildContext context) {
    return Obx(() => Row(
      children: _filters.map((f) {
        final active = controller.filterType.value == f.$2;
        return _FilterChip(
          label: f.$1,
          active: active,
          onTap: () => controller.filterType.value = f.$2,
        );
      }).toList(),
    ));
  }
}
class _ProjectArea extends StatelessWidget {
  final HomeController controller;
  final LayoutController lc;
  const _ProjectArea({required this.controller, required this.lc});
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(child: _HeroBanner(controller: controller, lc: lc)),
        SliverToBoxAdapter(child: _StatsRow(controller: controller, lc: lc)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Row(
              children: [
                Text(
                  'YOUR WORKS',
                  style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textTertiary,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(child: Container(height: 0.5, color: AppColors.border)),
              ],
            ),
          ),
        ),
        Obx(() {
          final projects = controller.filteredProjects;
          if (projects.isEmpty) {
            return SliverToBoxAdapter(child: _EmptyState(lc: lc));
          }
          return SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final p = projects[i];
                  return app_widgets.ProjectCard(
                    id: p.id,
                    title: p.name,
                    createdAt: p.updatedAt.toIso8601String(),
                    frameCount: p.frames.length,
                    isAnimation: p.isAnimation,
                    isFavorite: p.isFavorite,
                    onTap: () => Get.toNamed<void>('/draw', arguments: {'projectId': p.id}),
                    onDelete: () => controller.deleteProject(p.id),
                    onFavoriteChanged: (_) => controller.toggleFavorite(p.id),
                  ).animate(delay: Duration(milliseconds: 50 * i))
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic);
                },
                childCount: projects.length,
              ),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                mainAxisSpacing: 20,
                crossAxisSpacing: 16,
                childAspectRatio: 0.82,
              ),
            ),
          );
        }),
      ],
    );
  }
}
class _HeroBanner extends StatelessWidget {
  final HomeController controller;
  final LayoutController lc;
  const _HeroBanner({required this.controller, required this.lc});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.violet.withValues(alpha: 0.05),
            blurRadius: 24,
            spreadRadius: 1,
          )
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: controller.bannerPageController,
            onPageChanged: (i) => controller.bannerIndex.value = i,
            itemCount: controller.bannerImages.length,
            itemBuilder: (ctx, i) => Image.asset(
              controller.bannerImages[i],
              fit: BoxFit.cover,
              color: Colors.black.withValues(alpha: 0.3),
              colorBlendMode: BlendMode.darken,
              filterQuality: FilterQuality.medium,
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 320,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.black.withValues(alpha: 0.5),
                        Colors.black.withValues(alpha: 0.1),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.violet.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.violet.withValues(alpha: 0.4), width: 0.5),
                  ),
                  child: Text(
                    'SEASON 2026',
                    style: GoogleFonts.ibmPlexMono(
                      color: AppColors.violet,
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'The Creative\nFrontier.',
                  style: GoogleFonts.lexend(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 14),
                _StartCreatingBtn(controller: controller),
              ],
            ),
          ),
          Positioned(
            bottom: 12,
            right: 16,
            child: Obx(() => Row(
              children: List.generate(controller.bannerImages.length, (i) {
                final active = controller.bannerIndex.value == i;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(left: 4),
                  width: active ? 16 : 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: active ? Colors.white : Colors.white30,
                    borderRadius: BorderRadius.circular(2),
                  ),
                );
              }),
            )),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms);
  }
}

class _StartCreatingBtn extends StatefulWidget {
  final HomeController controller;
  const _StartCreatingBtn({required this.controller});

  @override
  State<_StartCreatingBtn> createState() => _StartCreatingBtnState();
}

class _StartCreatingBtnState extends State<_StartCreatingBtn> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.dialog<void>(CreateProjectDialog(controller: widget.controller, initialType: 0)),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedScale(
          scale: _isHovered ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: AppColors.violetPink,
              borderRadius: BorderRadius.circular(8),
              boxShadow: _isHovered 
                  ? [
                      BoxShadow(
                        color: AppColors.violet.withValues(alpha: 0.5),
                        blurRadius: 12,
                        spreadRadius: 1,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : [
                      BoxShadow(
                        color: AppColors.violet.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      )
                    ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'START CREATING',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(width: 6),
                AnimatedSlide(
                  offset: _isHovered ? const Offset(0.3, 0) : Offset.zero,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  child: const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 10),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final HomeController controller;
  final LayoutController lc;
  const _StatsRow({required this.controller, required this.lc});
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final total = controller.filteredProjects.length;
      final anims = controller.filteredProjects.where((p) => p.isAnimation).length;
      final starred = controller.filteredProjects.where((p) => p.isFavorite).length;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          children: [
            _StatCard(value: '$total', label: 'TOTAL', color: AppColors.violet),
            const SizedBox(width: 12),
            _StatCard(value: '$anims', label: 'ANIM', color: AppColors.teal),
            const SizedBox(width: 12),
            _StatCard(value: '${total - anims}', label: 'ART', color: AppColors.pink),
            const SizedBox(width: 12),
            _StatCard(value: '$starred', label: 'STAR', color: AppColors.amber),
          ],
        ),
      );
    });
  }
}

class _StatCard extends StatefulWidget {
  final String value;
  final String label;
  final Color color;
  const _StatCard({required this.value, required this.label, required this.color});

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> {
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
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
            decoration: BoxDecoration(
              color: _isHovered 
                  ? widget.color.withValues(alpha: 0.1) 
                  : widget.color.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.value,
                      style: GoogleFonts.lexend(
                        color: widget.color,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Icon(
                      _getIconForLabel(widget.label),
                      color: widget.color.withValues(alpha: _isHovered ? 0.8 : 0.4),
                      size: 16,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  widget.label,
                  style: GoogleFonts.ibmPlexMono(
                    color: widget.color.withValues(alpha: 0.7),
                    fontSize: 8,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconForLabel(String label) {
    switch (label) {
      case 'TOTAL':
        return Icons.folder_open_rounded;
      case 'ANIM':
        return Icons.movie_creation_outlined;
      case 'ART':
        return Icons.image_outlined;
      case 'STAR':
        return Icons.star_border_rounded;
      default:
        return Icons.folder_open_rounded;
    }
  }
}
class _ActivityPanel extends StatelessWidget {
  final HomeController controller;
  final LayoutController lc;
  const _ActivityPanel({required this.controller, required this.lc});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: lc.surfaceColor,
        border: Border(left: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const _SectionLabel('QUICK ACTIONS'),
          const SizedBox(height: 12),
          _QuickAction(
            icon: Icons.draw_rounded,
            label: 'New Canvas',
            sub: 'Start from blank',
            color: AppColors.violet,
            onTap: () => Get.dialog<void>(CreateProjectDialog(controller: controller, initialType: 0)),
          ),
          const SizedBox(height: 8),
          _QuickAction(
            icon: Icons.animation_rounded,
            label: 'New Animation',
            sub: 'Frame-by-frame',
            color: AppColors.teal,
            onTap: () => Get.dialog<void>(CreateProjectDialog(controller: controller, initialType: 1)),
          ),
          const SizedBox(height: 8),
          _QuickAction(
            icon: Icons.cloud_sync_rounded,
            label: 'Sync All',
            sub: 'Upload to cloud',
            color: AppColors.amber,
            onTap: () => Get.snackbar('Cloud Sync', 'Open a project and tap Sync to upload to cloud.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppColors.surface2,
                  colorText: AppColors.textPrimary,
                  duration: const Duration(seconds: 3)),
          ),
          const SizedBox(height: 28),
          const _SectionLabel('RECENT ACTIVITY'),
          const SizedBox(height: 12),
          Obx(() {
            final recent = controller.filteredProjects.take(5).toList();
            if (recent.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'No projects yet',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.textTertiary,
                      fontSize: 12,
                    ),
                  ),
                ),
              );
            }
            return Column(
              children: recent.asMap().entries.map((e) {
                final p = e.value;
                return _RecentItem(
                  name: p.name,
                  isAnim: p.isAnimation,
                  date: p.updatedAt,
                  onTap: () => Get.toNamed<void>('/draw', arguments: {'projectId': p.id}),
                ).animate(delay: Duration(milliseconds: 60 * e.key))
                    .fadeIn(duration: 400.ms)
                    .slideX(begin: 0.05, end: 0);
              }).toList(),
            );
          }),
        ],
      ),
    );
  }
}
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.ibmPlexMono(
        color: AppColors.textTertiary,
        fontSize: 9,
        fontWeight: FontWeight.w700,
        letterSpacing: 2,
      ),
    );
  }
}
class _QuickAction extends StatefulWidget {
  final IconData icon;
  final String label;
  final String sub;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.sub, required this.color, required this.onTap});

  @override
  State<_QuickAction> createState() => _QuickActionState();
}

class _QuickActionState extends State<_QuickAction> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedScale(
          scale: _isHovered ? 1.03 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: _isHovered 
                  ? widget.color.withValues(alpha: 0.1) 
                  : widget.color.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isHovered 
                    ? widget.color.withValues(alpha: 0.4) 
                    : widget.color.withValues(alpha: 0.15),
                width: 0.8,
              ),
              boxShadow: _isHovered 
                  ? [
                      BoxShadow(
                        color: widget.color.withValues(alpha: 0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      )
                    ]
                  : [],
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: widget.color.withValues(alpha: 0.25),
                      width: 0.8,
                    ),
                  ),
                  child: Icon(widget.icon, color: widget.color, size: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.label,
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        widget.sub,
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.textTertiary,
                          fontSize: 10,
                        ),
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
                    color: _isHovered ? widget.color : AppColors.textTertiary,
                    size: 10,
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

class _RecentItem extends StatefulWidget {
  final String name;
  final bool isAnim;
  final DateTime date;
  final VoidCallback onTap;
  const _RecentItem({required this.name, required this.isAnim, required this.date, required this.onTap});

  @override
  State<_RecentItem> createState() => _RecentItemState();
}

class _RecentItemState extends State<_RecentItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final diff = DateTime.now().difference(widget.date);
    final timeStr = diff.inDays > 0 ? '${diff.inDays}d ago' : diff.inHours > 0 ? '${diff.inHours}h ago' : 'Just now';
    final typeColor = widget.isAnim ? AppColors.teal : AppColors.violet;

    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedScale(
          scale: _isHovered ? 1.03 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: _isHovered
                  ? typeColor.withValues(alpha: 0.08)
                  : Get.find<LayoutController>().cardColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _isHovered
                    ? typeColor.withValues(alpha: 0.35)
                    : AppColors.border,
                width: 0.8,
              ),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: typeColor.withValues(alpha: 0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      )
                    ]
                  : [],
            ),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: widget.isAnim
                        ? AppColors.teal.withValues(alpha: 0.12)
                        : AppColors.violet.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: widget.isAnim
                          ? AppColors.teal.withValues(alpha: 0.2)
                          : AppColors.violet.withValues(alpha: 0.2),
                      width: 0.8,
                    ),
                  ),
                  child: Icon(
                    widget.isAnim ? Icons.animation_rounded : Icons.brush_rounded,
                    size: 14,
                    color: widget.isAnim ? AppColors.teal : AppColors.violet,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        timeStr,
                        style: GoogleFonts.ibmPlexMono(
                          color: AppColors.textTertiary,
                          fontSize: 9,
                        ),
                      ),
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
class _AmbientOrbs extends StatelessWidget {
  final LayoutController lc;
  const _AmbientOrbs({required this.lc});
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned(top: -100, left: -80,
        child: _Orb(radius: 350, color: AppColors.violet.withValues(alpha: 0.04))),
      Positioned(bottom: 100, right: -100,
        child: _Orb(radius: 280, color: AppColors.teal.withValues(alpha: 0.03))),
    ]);
  }
}

class _Orb extends StatefulWidget {
  final double radius;
  final Color color;
  const _Orb({required this.radius, required this.color});

  @override
  State<_Orb> createState() => _OrbState();
}

class _OrbState extends State<_Orb> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );

    _opacityAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.radius * 2,
              height: widget.radius * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [widget.color, Colors.transparent]),
              ),
            ),
          ),
        );
      },
    );
  }
}
class _EmptyState extends StatelessWidget {
  final LayoutController lc;
  const _EmptyState({required this.lc});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.violet.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.violet.withValues(alpha: 0.15)),
              ),
              child: Icon(Icons.add_rounded, size: 32, color: AppColors.violet.withValues(alpha: 0.4)),
            ),
            const SizedBox(height: 20),
            Text('YOUR CANVAS AWAITS', style: GoogleFonts.ibmPlexMono(
              color: AppColors.textTertiary,
              fontSize: 9,
              letterSpacing: 3,
              fontWeight: FontWeight.w700,
            )),
            const SizedBox(height: 8),
            Text('Create your first masterpiece', style: GoogleFonts.plusJakartaSans(
              color: AppColors.textTertiary,
              fontSize: 13,
              fontWeight: FontWeight.w400,
            )),
          ],
        ).animate().fadeIn(duration: 600.ms),
      ),
    );
  }
}

class _FilterChip extends StatefulWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _FilterChip({required this.label, required this.active, required this.onTap});

  @override
  State<_FilterChip> createState() => _FilterChipState();
}

class _FilterChipState extends State<_FilterChip> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedScale(
          scale: _isHovered ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(left: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              gradient: widget.active
                  ? AppColors.violetPink
                  : (_isHovered
                      ? LinearGradient(colors: [
                          AppColors.violet.withValues(alpha: 0.1),
                          AppColors.pink.withValues(alpha: 0.05)
                        ])
                      : null),
              color: widget.active
                  ? null
                  : (_isHovered ? null : Colors.transparent),
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
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NewProjectBtn extends StatefulWidget {
  final HomeController controller;
  const _NewProjectBtn({required this.controller});

  @override
  State<_NewProjectBtn> createState() => _NewProjectBtnState();
}

class _NewProjectBtnState extends State<_NewProjectBtn> with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _spinController;
  late Animation<double> _spinAnimation;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _spinAnimation = Tween<double>(begin: 0.0, end: 0.25).animate(
      CurvedAnimation(parent: _spinController, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.dialog<void>(CreateProjectDialog(controller: widget.controller, initialType: 0)),
      child: MouseRegion(
        onEnter: (_) {
          setState(() => _isHovered = true);
          _spinController.forward(from: 0.0);
        },
        onExit: (_) {
          setState(() => _isHovered = false);
        },
        child: AnimatedScale(
          scale: _isHovered ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: AppColors.violetPink,
              borderRadius: BorderRadius.circular(10),
              boxShadow: _isHovered 
                  ? [
                      BoxShadow(
                        color: AppColors.violet.withValues(alpha: 0.4),
                        blurRadius: 12,
                        spreadRadius: 1,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : [
                      BoxShadow(
                        color: AppColors.violet.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      )
                    ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                RotationTransition(
                  turns: _spinAnimation,
                  child: const Icon(Icons.add_rounded, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 6),
                Text(
                  'New Project',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
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