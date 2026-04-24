import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/home_controller.dart';
import 'widgets/project_card.dart' as app_widgets;
import '../../layout/controllers/layout_controller.dart';
import 'widgets/create_project_dialog.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final lc = Get.find<LayoutController>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          _buildAmbientBackground(lc),
          CustomScrollView(
            physics: const ClampingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _buildCinematicHeader(lc)),
              SliverToBoxAdapter(child: _buildStatsBar(lc)),
              SliverToBoxAdapter(child: _buildProjectGridSection(lc)),
              
              const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
            ],
          ),
        ],
      ),
    );
  }

  
  
  
  Widget _buildAmbientBackground(LayoutController lc) {
    return Stack(
      children: [
        Positioned(
          top: -200, left: -150,
          child: Container(
            width: 700, height: 700,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                lc.primaryColor.withValues(alpha: 0.06),
                Colors.transparent,
              ]),
            ),
          ),
        ),
        Positioned(
          top: 300, right: -200,
          child: Container(
            width: 500, height: 500,
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
    );
  }

  
  Widget _buildCinematicHeader(LayoutController lc) {
    return SizedBox(
      height: 350,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        child: Stack(
        children: [
          
          Positioned.fill(
            child: PageView.builder(
              controller: controller.bannerPageController,
              onPageChanged: (i) => controller.bannerIndex.value = i,
              itemCount: controller.bannerImages.length,
              itemBuilder: (ctx, i) {
                return Image.asset(
                  controller.bannerImages[i],
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                  filterQuality: FilterQuality.high,
                  width: double.infinity,
                  color: Colors.black.withValues(alpha: 0.35),
                  colorBlendMode: BlendMode.darken,
                );
              },
            ),
          ),

          
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.5, 1.0],
                  colors: [
                    Colors.black.withValues(alpha: 0.3),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.6),
                  ],
                ),
              ),
            ),
          ),

          
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Colors.black.withValues(alpha: 0.4), Colors.transparent],
                  stops: const [0.0, 0.6],
                ),
              ),
            ),
          ),

          
          Positioned.fill(
            child: Opacity(
              opacity: 0.03,
              child: CustomPaint(painter: _GrainPainter()),
            ),
          ),

          
          Positioned(
            bottom: 24, left: 64, right: 64,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: lc.primaryColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: lc.primaryColor.withValues(alpha: 0.4), width: 0.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 4, height: 4,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: lc.primaryColor)),
                      const SizedBox(width: 6),
                      Text(
                        'SEASON 2026 · PRESTIGE COLLECTION',
                        style: GoogleFonts.plusJakartaSans(
                          color: lc.primaryColor, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideY(begin: 0.3, end: 0),

                const SizedBox(height: 10),

                Text(
                  'The\nCreative\nFrontier.',
                  style: GoogleFonts.cinzel(
                    color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, height: 1.0, letterSpacing: -1.5,
                  ),
                ).animate().fadeIn(delay: 350.ms, duration: 700.ms).slideY(begin: 0.2, end: 0),

                const SizedBox(height: 10),

                Text(
                  'Where imagination becomes legacy.',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white.withValues(alpha: 0.55), fontSize: 11, fontWeight: FontWeight.w300, letterSpacing: 0.5,
                  ),
                ).animate().fadeIn(delay: 450.ms, duration: 600.ms),

                const SizedBox(height: 16),

                Row(
                  children: [
                    _buildHeroCTA(lc, Icons.add_rounded, 'NEW PROJECT', true, () => _showCreateDialog(0)),
                    const SizedBox(width: 12),
                    _buildHeroCTA(lc, Icons.explore_rounded, 'EXPLORE', false, () => _showCreateDialog(0)),
                  ],
                ).animate().fadeIn(delay: 550.ms, duration: 600.ms).slideY(begin: 0.2, end: 0),
              ],
            ),
          ),

          
          Positioned(
            bottom: 12, left: 64,
            child: Obx(() => Row(
              children: List.generate(controller.bannerImages.length, (i) =>
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  margin: const EdgeInsets.only(right: 4),
                  width: controller.bannerIndex.value == i ? 16 : 4,
                  height: 3,
                  decoration: BoxDecoration(
                    color: controller.bannerIndex.value == i
                        ? lc.primaryColor
                        : Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            )),
          ),

          
          Positioned(
            right: 32, top: 80,
            child: RotatedBox(
              quarterTurns: 1,
              child: Text(
                'ARTVERSE STUDIO  ◆  PRESTIGE EDITION  ◆  2026',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white.withValues(alpha: 0.06), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 4,
                ),
              ),
            ),
          ),

          
          Positioned(
            left: 12, top: 0, bottom: 0,
            child: Center(
              child: _buildBannerNavButton(
                icon: Icons.chevron_left_rounded,
                onTap: () {
                  final prev = (controller.bannerIndex.value - 1 + controller.bannerImages.length) % controller.bannerImages.length;
                  controller.bannerPageController.animateToPage(prev, duration: 600.ms, curve: Curves.easeInOutCubic);
                },
              ),
            ),
          ),
          Positioned(
            right: 12, top: 0, bottom: 0,
            child: Center(
              child: _buildBannerNavButton(
                icon: Icons.chevron_right_rounded,
                onTap: () {
                  final next = (controller.bannerIndex.value + 1) % controller.bannerImages.length;
                  controller.bannerPageController.animateToPage(next, duration: 600.ms, curve: Curves.easeInOutCubic);
                },
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildBannerNavButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.15),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 0.5),
        ),
        child: Icon(icon, color: Colors.white.withValues(alpha: 0.5), size: 24),
      ),
    ).animate().fadeIn(delay: 800.ms).scale(begin: const Offset(0.8, 0.8));
  }

  Widget _buildHeroCTA(LayoutController lc, IconData icon, String label, bool isPrimary, VoidCallback onTap) {
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isPrimary ? lc.primaryColor : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isPrimary ? lc.primaryColor : Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: isPrimary
              ? [BoxShadow(color: lc.primaryColor.withValues(alpha: 0.35), blurRadius: 15, offset: const Offset(0, 6))]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isPrimary ? lc.onPrimaryColor : Colors.white.withValues(alpha: 0.8), size: 14),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                color: isPrimary ? lc.onPrimaryColor : Colors.white.withValues(alpha: 0.7),
                fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  
  Widget _buildStatsBar(LayoutController lc) {
    return Obx(() {
      final total = controller.filteredProjects.length;
      final anims = controller.filteredProjects.where((p) => p.isAnimation).length;
      final statics = total - anims;
      final starred = controller.filteredProjects.where((p) => p.isFavorite).length;

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: lc.cardColor.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: lc.textColor.withValues(alpha: 0.05), width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _statItem(lc, '$total', 'TOTAL WORKS', Icons.palette_rounded),
                _statDivider(lc),
                _statItem(lc, '$anims', 'ANIMATIONS', Icons.animation_rounded),
                _statDivider(lc),
                _statItem(lc, '$statics', 'STATIC ART', Icons.brush_rounded),
                _statDivider(lc),
                _statItem(lc, '$starred', 'STARRED', Icons.star_rounded),
              ],
            ),
          ),
        ),
      );
    }).animate().fadeIn(delay: 100.ms, duration: 600.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _statItem(LayoutController lc, String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: lc.primaryColor.withValues(alpha: 0.6), size: 16),
        const SizedBox(height: 6),
        Text(value, style: GoogleFonts.lexend(color: lc.textColor, fontSize: 18, fontWeight: FontWeight.w900)),
        const SizedBox(height: 2),
        Text(label, style: GoogleFonts.plusJakartaSans(
          color: lc.textColor.withValues(alpha: 0.3), fontSize: 8, fontWeight: FontWeight.w700, letterSpacing: 2)),
      ],
    );
  }

  Widget _statDivider(LayoutController lc) =>
      Container(width: 1, height: 32, color: lc.textColor.withValues(alpha: 0.06));

  
  Widget _buildProjectGridSection(LayoutController lc) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CREATIVE VAULT', style: GoogleFonts.plusJakartaSans(
                    color: lc.primaryColor, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 3)),
                  const SizedBox(height: 4),
                  Text('Project Ledger', style: GoogleFonts.cinzel(
                    color: lc.textColor, fontSize: 28, fontWeight: FontWeight.w400, letterSpacing: 1)),
                ],
              ),
              const Spacer(),
              _buildFilterChips(lc),
            ],
          ),

          const SizedBox(height: 12),
          Container(height: 0.5, color: lc.textColor.withValues(alpha: 0.07)),
          const SizedBox(height: 24),

          
          Obx(() {
            final projects = controller.filteredProjects;
            if (projects.isEmpty) return _buildEmptyState(lc);

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220, mainAxisSpacing: 24, crossAxisSpacing: 16, childAspectRatio: 0.85,
              ),
              itemCount: projects.length,
              itemBuilder: (ctx, i) {
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
                ).animate(delay: Duration(milliseconds: 60 * i))
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: 0.15, end: 0, curve: Curves.easeOutCubic);
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFilterChips(LayoutController lc) {
    final filters = [
      ('ALL', 'all', Icons.apps_rounded),
      ('ANIMATION', 'anim', Icons.animation_rounded),
      ('STATIC', 'art', Icons.brush_rounded),
      ('STARRED', 'starred', Icons.star_rounded),
    ];
    return Row(
      children: filters.map((f) =>
        
        Obx(() {
          final active = controller.filterType.value == f.$2;
          return GestureDetector(
            onTap: () => controller.filterType.value = f.$2,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: active ? lc.primaryColor.withValues(alpha: 0.12) : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: active ? lc.primaryColor.withValues(alpha: 0.4) : lc.textColor.withValues(alpha: 0.06),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(f.$3, size: 13, color: active ? lc.primaryColor : lc.textColor.withValues(alpha: 0.25)),
                  const SizedBox(width: 6),
                  Text(f.$1, style: GoogleFonts.plusJakartaSans(
                    color: active ? lc.primaryColor : lc.textColor.withValues(alpha: 0.3),
                    fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.5,
                  )),
                ],
              ),
            ),
          );
        }),
      ).toList(),
    );
  }

  Widget _buildEmptyState(LayoutController lc) {
    return SizedBox(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.8, end: 1.0),
              duration: const Duration(milliseconds: 2000),
              curve: Curves.easeInOut,
              builder: (ctx, scale, _) => Transform.scale(
                scale: scale,
                child: Container(
                  width: 96, height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      lc.primaryColor.withValues(alpha: 0.08), lc.primaryColor.withValues(alpha: 0.02),
                    ]),
                    boxShadow: [BoxShadow(
                      color: lc.primaryColor.withValues(alpha: 0.12 * scale),
                      blurRadius: 40 * scale, spreadRadius: 4,
                    )],
                  ),
                  child: Icon(Icons.add_rounded, size: 36, color: lc.primaryColor.withValues(alpha: 0.3)),
                ),
              ),
            ),
            const SizedBox(height: 28),
            Text('YOUR CANVAS AWAITS', style: GoogleFonts.plusJakartaSans(
              color: lc.textColor.withValues(alpha: 0.15), fontSize: 10, letterSpacing: 4, fontWeight: FontWeight.w900)),
            const SizedBox(height: 10),
            Text('Create your first masterpiece', style: GoogleFonts.plusJakartaSans(
              color: lc.textColor.withValues(alpha: 0.1), fontSize: 13, fontWeight: FontWeight.w400)),
          ],
        ),
      ),
    );
  }

  void _showCreateDialog(int type) {
    Get.dialog<void>(CreateProjectDialog(controller: controller, initialType: type));
  }
}


class _GrainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    final rng = math.Random(42);
    for (int i = 0; i < 3000; i++) {
      canvas.drawCircle(
        Offset(rng.nextDouble() * size.width, rng.nextDouble() * size.height),
        rng.nextDouble() * 0.8, paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
