import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/dashboard_controller.dart';
import '../../../data/models/post_model.dart';
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
                return const Center(
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
        border: const Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Row(
        children: [
          Text('Pulse', style: GoogleFonts.lexend(
            color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(width: 8),
          Text('Analytics', style: GoogleFonts.plusJakartaSans(
            color: AppColors.textTertiary, fontSize: 12)),
          const Spacer(),
          Obx(() => Row(
            children: ['Week', 'Month', 'Year'].map((p) {
              final active = controller.selectedPeriod.value == p;
              return GestureDetector(
                onTap: () => controller.selectPeriod(p),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(left: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: active ? AppColors.violet.withValues(alpha: 0.12) : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: active ? AppColors.violet.withValues(alpha: 0.3) : AppColors.border,
                      width: 0.5,
                    ),
                  ),
                  child: Text(p, style: GoogleFonts.plusJakartaSans(
                    color: active ? AppColors.violet : AppColors.textTertiary,
                    fontSize: 11,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  )),
                ),
              );
            }).toList(),
          )),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () => controller.fetchDashboardData(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surface2,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border, width: 0.5),
              ),
              child: const Icon(Icons.refresh_rounded, size: 16, color: AppColors.textTertiary),
            ),
          ),
        ],
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
class _KpiCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final IconData icon;
  const _KpiCard({required this.value, required this.label, required this.color, required this.icon});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.15), width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: GoogleFonts.lexend(
                  color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w900)),
                Text(label, style: GoogleFonts.ibmPlexMono(
                  color: color.withValues(alpha: 0.7), fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0),
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
          return const SizedBox(height: 140, child: Center(
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
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AnimatedContainer(
                        duration: Duration(milliseconds: 300 + e.key * 50),
                        height: h.clamp(4.0, 120.0),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [AppColors.violet, AppColors.violetPinkColor],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }),
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
          return const Padding(
            padding: EdgeInsets.all(16),
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
class _PostRow extends StatelessWidget {
  final PostModel post;
  final int index;
  const _PostRow({required this.post, required this.index});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: AppColors.violet.withValues(alpha: 0.1),
              image: post.url.isNotEmpty
                  ? DecorationImage(image: NetworkImage(post.url), fit: BoxFit.cover)
                  : null,
            ),
            child: post.url.isEmpty ? const Icon(Icons.image_outlined, size: 16, color: AppColors.textTertiary) : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.name.isNotEmpty ? post.name : 'Untitled',
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
                Text('${post.views} views · ${post.likesCount} likes',
                  style: GoogleFonts.ibmPlexMono(color: AppColors.textTertiary, fontSize: 9)),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded, size: 10, color: AppColors.textTertiary.withValues(alpha: 0.5)),
        ],
      ),
    ).animate(delay: Duration(milliseconds: 60 * index)).fadeIn(duration: 400.ms);
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
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.key, style: GoogleFonts.plusJakartaSans(
                      color: AppColors.textSecondary, fontSize: 11)),
                    Text('${(entry.value * 100).toStringAsFixed(0)}%',
                      style: GoogleFonts.ibmPlexMono(color: AppColors.violet, fontSize: 10, fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: entry.value,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.violet.withValues(alpha: 0.7)),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
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
          return const Padding(
            padding: EdgeInsets.all(16),
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
class _AchBadge extends StatelessWidget {
  final String title;
  final bool unlocked;
  const _AchBadge({required this.title, required this.unlocked});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: unlocked ? AppColors.amber.withValues(alpha: 0.1) : AppColors.surface2,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: unlocked ? AppColors.amber.withValues(alpha: 0.4) : AppColors.border,
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(unlocked ? Icons.emoji_events_rounded : Icons.lock_outline_rounded,
            size: 12,
            color: unlocked ? AppColors.amber : AppColors.textTertiary),
          const SizedBox(width: 4),
          Text(title, style: GoogleFonts.plusJakartaSans(
            color: unlocked ? AppColors.amber : AppColors.textTertiary,
            fontSize: 10, fontWeight: FontWeight.w600)),
        ],
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: GoogleFonts.ibmPlexMono(
                      color: AppColors.textTertiary, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 2)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: GoogleFonts.plusJakartaSans(
                      color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
          Container(height: 0.5, color: AppColors.border),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }
}
