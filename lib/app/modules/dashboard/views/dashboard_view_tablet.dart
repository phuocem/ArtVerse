import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../layout/controllers/layout_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import 'widgets/dashboard_studio_card.dart';
import 'widgets/dashboard_visionary_card.dart';
import 'widgets/dashboard_stats_row.dart';

class DashboardViewTablet extends GetView<DashboardController> {
  const DashboardViewTablet({super.key});

  @override
  Widget build(BuildContext context) {
    final lc = Get.find<LayoutController>();
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          
          _buildAmbient(lc),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 72)),
              _buildHeader(lc),
              _buildHeroMetrics(lc),
              _buildChartSection(lc),
              _buildActivityFeed(lc),
              const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
            ],
          ),
        ],
      ),
    );
  }

  
  Widget _buildAmbient(LayoutController lc) {
    return Obx(() => Stack(
      children: [
        Positioned(
          top: -150, right: -100,
          child: Container(
            width: 500, height: 500,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                lc.primaryColor.withValues(alpha: 0.07),
                Colors.transparent,
              ]),
            ),
          ),
        ),
        Positioned(
          bottom: -100, left: -50,
          child: Container(
            width: 400, height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                lc.accentColor.withValues(alpha: 0.04),
                Colors.transparent,
              ]),
            ),
          ),
        ),
      ],
    ));
  }

  
  Widget _buildHeader(LayoutController lc) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(56, 16, 56, 40),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => Row(
                  children: [
                    Container(
                      width: 6, height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: lc.primaryColor,
                        boxShadow: [BoxShadow(color: lc.primaryColor.withValues(alpha: 0.5), blurRadius: 8)],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'ANALYTICS  ◆  INSIGHTS',
                      style: GoogleFonts.plusJakartaSans(
                        color: lc.primaryColor,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3,
                      ),
                    ),
                  ],
                )),
                const SizedBox(height: 10),
                Obx(() => Text(
                  'Creative\nInfluence.',
                  style: GoogleFonts.cinzel(
                    color: lc.textColor,
                    fontSize: 44,
                    fontWeight: FontWeight.w400,
                    letterSpacing: -1,
                    height: 1.0,
                  ),
                )),
              ],
            ),
            const Spacer(),
            _buildPeriodToggle(lc),
          ],
        ),
      ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.1, end: 0),
    );
  }

  Widget _buildPeriodToggle(LayoutController lc) {
    return Obx(() => Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: lc.cardColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: lc.textColor.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ['Week', 'Month', 'Year'].map((p) {
          final active = p == controller.selectedPeriod.value;
          return GestureDetector(
            onTap: () => controller.selectPeriod(p),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 280),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
              decoration: BoxDecoration(
                color: active ? lc.primaryColor : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                boxShadow: active
                    ? [BoxShadow(color: lc.primaryColor.withValues(alpha: 0.25), blurRadius: 10)]
                    : null,
              ),
              child: Text(
                p.toUpperCase(),
                style: GoogleFonts.plusJakartaSans(
                  color: active ? lc.onPrimaryColor : lc.textColor.withValues(alpha: 0.3),
                  fontWeight: FontWeight.w900,
                  fontSize: 9,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    ));
  }

  
  Widget _buildHeroMetrics(LayoutController lc) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 56),
        child: Column(
          children: [
            
            Row(
              children: [
                Expanded(flex: 3, child: DashboardStudioCard(lc: lc)),
                const SizedBox(width: 20),
                Expanded(flex: 2, child: DashboardVisionaryCard(lc: lc)),
              ],
            ),
            const SizedBox(height: 20),
            
            DashboardStatsRow(lc: lc),
          ],
        ),
      ),
    );
  }

  Widget _buildProCard(LayoutController lc) {
    final profileController = Get.find<ProfileController>();
    return Obx(() {
      final user = profileController.currentUser.value;
      final isStudio = user?.isStudio ?? false;

      return GestureDetector(
        onTap: () => Get.toNamed<void>(isStudio ? '/home' : '/studio-upgrade'),
        child: Container(
          height: 200,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                lc.primaryColor.withValues(alpha: 0.8),
                lc.accentColor.withValues(alpha: 0.5),
                lc.primaryColor.withValues(alpha: 0.3),
              ],
            ),
            boxShadow: [
              BoxShadow(color: lc.primaryColor.withValues(alpha: 0.2), blurRadius: 30, offset: const Offset(0, 12)),
            ],
          ),
          child: Stack(
            children: [
              
              Positioned.fill(
                child: CustomPaint(painter: _DotPatternPainter(Colors.white.withValues(alpha: 0.04))),
              ),
              
              Positioned(
                top: -40, right: -40,
                child: Container(
                  width: 180, height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      Colors.white.withValues(alpha: 0.12),
                      Colors.transparent,
                    ]),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.stars_rounded, color: Colors.amber, size: 11),
                              const SizedBox(width: 6),
                              Text(
                                isStudio ? 'STUDIO ACTIVE' : 'STUDIO',
                                style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      isStudio ? 'Professional\nWorkspace' : 'Upgrade to Studio\nStudio',
                      style: GoogleFonts.lexend(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, height: 1.1),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isStudio ? 'Full access to all professional tools' : 'Upgrade to studio grade tools',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 12),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Text(
                          isStudio ? 'ENTER STUDIO →' : 'UPGRADE NOW →',
                          style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 100.ms, duration: 600.ms).slideX(begin: -0.05, end: 0),
      );
    });
  }

  Widget _buildVisionaryCard(LayoutController lc) {
    return GestureDetector(
      onTap: () => Get.toNamed<void>('/visionary-hall'),
      child: Container(
        height: 200,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: lc.cardColor,
          border: Border.all(color: lc.textColor.withValues(alpha: 0.06)),
        ),
        child: Stack(
          children: [
            
            Positioned(
              top: -30, right: -30,
              child: Container(
                width: 150, height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    const Color(0xFFFFD700).withValues(alpha: 0.08),
                    Colors.transparent,
                  ]),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [BoxShadow(color: const Color(0xFFFFD700).withValues(alpha: 0.3), blurRadius: 16)],
                    ),
                    child: const Icon(Icons.stars_rounded, color: Colors.white, size: 22),
                  ),
                  const Spacer(),
                  Obx(() => Text(
                    'VISIONARY\nHALL',
                    style: GoogleFonts.cinzel(
                      color: lc.textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                      height: 1.1,
                    ),
                  )),
                  const SizedBox(height: 8),
                  Obx(() => Text(
                    'Hall of Fame',
                    style: TextStyle(color: lc.textColor.withValues(alpha: 0.3), fontSize: 12),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsRow(LayoutController lc) {
    final profileController = Get.find<ProfileController>();
    return Obx(() {
      final user = profileController.currentUser.value;
      if (user == null) return const SizedBox.shrink();

      final stats = [
        _StatData('REACH', _fmt(user.viewsCount), Icons.visibility_rounded, const Color(0xFF60A5FA)),
        _StatData('FANS', _fmt(user.followersCount), Icons.people_rounded, const Color(0xFFA78BFA)),
        _StatData('SALES', '${user.balance.toInt()}', Icons.attach_money_rounded, const Color(0xFF34D399)),
        _StatData('SCORE', '${((user.likesCount * 2 + user.viewsCount) / 10).clamp(0, 99).toInt()}', Icons.star_rounded, const Color(0xFFFBBF24)),
      ];

      return Row(
        children: stats.asMap().entries.map((e) {
          final s = e.value;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(left: e.key == 0 ? 0 : 16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: lc.cardColor.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: lc.textColor.withValues(alpha: 0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: s.color.withValues(alpha: 0.1),
                        ),
                        child: Icon(s.icon, size: 16, color: s.color),
                      ),
                      const Spacer(),
                      Icon(Icons.trending_up_rounded, size: 12, color: s.color.withValues(alpha: 0.5)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    s.value,
                    style: GoogleFonts.lexend(
                      color: lc.textColor,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    s.label,
                    style: GoogleFonts.plusJakartaSans(
                      color: lc.textColor.withValues(alpha: 0.3),
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: math.Random(e.key).nextDouble() * 0.7 + 0.2,
                      backgroundColor: s.color.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(s.color.withValues(alpha: 0.5)),
                      minHeight: 3,
                    ),
                  ),
                ],
              ),
            ).animate(delay: Duration(milliseconds: 80 * e.key))
                .fadeIn(duration: 400.ms)
                .slideY(begin: 0.1, end: 0),
          );
        }).toList(),
      );
    });
  }

  
  Widget _buildChartSection(LayoutController lc) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(56, 32, 56, 0),
        child: Container(
          padding: const EdgeInsets.all(36),
          decoration: BoxDecoration(
            color: lc.cardColor.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: lc.textColor.withValues(alpha: 0.05)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(() => Text(
                        'DATA VISUALIZATION',
                        style: GoogleFonts.plusJakartaSans(
                          color: lc.primaryColor,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 3,
                        ),
                      )),
                      const SizedBox(height: 6),
                      Obx(() => Text(
                        'Performance Chart',
                        style: GoogleFonts.cinzel(color: lc.textColor, fontSize: 20, fontWeight: FontWeight.w400),
                      )),
                    ],
                  ),
                  const Spacer(),
                  Obx(() => Icon(Icons.auto_graph_rounded, color: lc.primaryColor.withValues(alpha: 0.5), size: 20)),
                ],
              ),
              const SizedBox(height: 36),
              _buildChart(lc),
              const SizedBox(height: 16),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN']
                    .map((d) => Obx(() => Text(d,
                        style: GoogleFonts.plusJakartaSans(color: lc.textColor.withValues(alpha: 0.2), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1))))
                    .toList(),
              ),
            ],
          ),
        ),
      ).animate().fadeIn(delay: 200.ms, duration: 700.ms).slideY(begin: 0.1, end: 0),
    );
  }

  Widget _buildChart(LayoutController lc) {
    return Obx(() {
      final values = controller.chartValues.isEmpty
          ? [0.45, 0.62, 0.38, 0.71, 0.55, 0.83, 0.66]
          : controller.chartValues;

      return SizedBox(
        height: 180,
        child: Stack(
          children: [
            
            ...List.generate(4, (i) {
              final y = 180 * (1 - (i + 1) / 4);
              return Positioned(
                top: y,
                left: 0, right: 0,
                child: Container(
                  height: 0.5,
                  color: lc.textColor.withValues(alpha: 0.05),
                ),
              );
            }),
            
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: values.asMap().entries.map((e) {
                final isMax = e.value == values.reduce(math.max);
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AnimatedContainer(
                          duration: Duration(milliseconds: 600 + e.key * 80),
                          curve: Curves.easeOutCubic,
                          height: 160 * e.value,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: isMax
                                  ? [lc.primaryColor, lc.primaryColor.withValues(alpha: 0.3)]
                                  : [lc.primaryColor.withValues(alpha: 0.4), lc.primaryColor.withValues(alpha: 0.05)],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      );
    });
  }

  
  Widget _buildActivityFeed(LayoutController lc) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(56, 32, 56, 0),
        child: Obx(() {
          final activities = controller.recentActivities;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'STUDIO LOG',
                        style: GoogleFonts.plusJakartaSans(
                          color: lc.primaryColor,
                          fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Recent Activity',
                        style: GoogleFonts.cinzel(color: lc.textColor, fontSize: 20, fontWeight: FontWeight.w400),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 28),

              if (activities.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    child: Text(
                      'NO RECENT ENTRIES',
                      style: GoogleFonts.plusJakartaSans(
                        color: lc.textColor.withValues(alpha: 0.1),
                        fontSize: 10, letterSpacing: 4, fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                )
              else
                Container(
                  decoration: BoxDecoration(
                    color: lc.cardColor.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: lc.textColor.withValues(alpha: 0.05)),
                  ),
                  child: Column(
                    children: activities.take(6).toList().asMap().entries.map((e) {
                      final act = e.value;
                      final isLast = e.key == activities.take(6).length - 1;
                      return _activityRow(act, lc, isLast)
                          .animate(delay: Duration(milliseconds: 100 * e.key))
                          .fadeIn(duration: 400.ms)
                          .slideX(begin: 0.03, end: 0);
                    }).toList(),
                  ),
                ),
            ],
          );
        }),
      ).animate().fadeIn(delay: 300.ms, duration: 600.ms).slideY(begin: 0.1, end: 0),
    );
  }

  Widget _activityRow(Map<String, String> act, LayoutController lc, bool isLast) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      decoration: BoxDecoration(
        border: isLast ? null : Border(
          bottom: BorderSide(color: lc.textColor.withValues(alpha: 0.04)),
        ),
      ),
      child: Row(
        children: [
          
          Column(
            children: [
              Container(
                width: 10, height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: lc.primaryColor.withValues(alpha: 0.3),
                  border: Border.all(color: lc.primaryColor, width: 1.5),
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (act['title'] ?? 'ACTION').toUpperCase(),
                  style: GoogleFonts.plusJakartaSans(
                    color: lc.textColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
                if ((act['subtitle'] ?? '').isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(act['subtitle'] ?? '', style: TextStyle(color: lc.textColor.withValues(alpha: 0.35), fontSize: 11)),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: lc.textColor.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              (act['time'] ?? '').toUpperCase(),
              style: GoogleFonts.plusJakartaSans(color: lc.textColor.withValues(alpha: 0.2), fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1),
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}


class _StatData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatData(this.label, this.value, this.icon, this.color);
}


class _DotPatternPainter extends CustomPainter {
  final Color color;
  const _DotPatternPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const step = 20.0;
    for (double x = 0; x < size.width; x += step) {
      for (double y = 0; y < size.height; y += step) {
        canvas.drawCircle(Offset(x, y), 1.2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
