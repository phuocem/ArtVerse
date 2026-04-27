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
          Text(
            'Studio',
            style: GoogleFonts.lexend(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.violet.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(4),
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
          GestureDetector(
            onTap: () => Get.dialog<void>(CreateProjectDialog(controller: controller, initialType: 0)),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: AppColors.violetPink,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(color: AppColors.violet.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4)),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add_rounded, color: Colors.white, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    'New Project',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
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
        return GestureDetector(
          onTap: () => controller.filterType.value = f.$2,
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
            child: Text(
              f.$1,
              style: GoogleFonts.plusJakartaSans(
                color: active ? AppColors.violet : AppColors.textTertiary,
                fontSize: 11,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
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
              color: Colors.black.withValues(alpha: 0.4),
              colorBlendMode: BlendMode.darken,
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Colors.black87, Colors.transparent],
                stops: [0.0, 0.7],
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
                GestureDetector(
                  onTap: () => Get.dialog<void>(CreateProjectDialog(controller: controller, initialType: 0)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: AppColors.violetPink,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'START CREATING →',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
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
class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _StatCard({required this.value, required this.label, required this.color});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.15), width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: GoogleFonts.lexend(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.ibmPlexMono(
                color: color.withValues(alpha: 0.6),
                fontSize: 8,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
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
class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.sub, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.15), width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                )),
                Text(sub, style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textTertiary,
                  fontSize: 10,
                )),
              ],
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textTertiary, size: 10),
          ],
        ),
      ),
    );
  }
}
class _RecentItem extends StatelessWidget {
  final String name;
  final bool isAnim;
  final DateTime date;
  final VoidCallback onTap;
  const _RecentItem({required this.name, required this.isAnim, required this.date, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final diff = DateTime.now().difference(date);
    final timeStr = diff.inDays > 0 ? '${diff.inDays}d ago' : diff.inHours > 0 ? '${diff.inHours}h ago' : 'Just now';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Get.find<LayoutController>().cardColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isAnim ? AppColors.teal.withValues(alpha: 0.1) : AppColors.violet.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                isAnim ? Icons.animation_rounded : Icons.brush_rounded,
                size: 14,
                color: isAnim ? AppColors.teal : AppColors.violet,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.textPrimary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
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
class _Orb extends StatelessWidget {
  final double radius;
  final Color color;
  const _Orb({required this.radius, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, Colors.transparent]),
      ),
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