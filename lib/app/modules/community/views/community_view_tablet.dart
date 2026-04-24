import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../layout/controllers/layout_controller.dart';
import '../controllers/community_controller.dart';
import '../../../widgets/global/global_artwork_card.dart';
import 'package:artverse/app/widgets/global/global_section_title.dart';
import 'widgets/community_hero.dart';

class CommunityViewTablet extends GetView<CommunityController> {
  const CommunityViewTablet({super.key});

  @override
  Widget build(BuildContext context) {
    final lc = Get.find<LayoutController>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommunityHero(lc: lc).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0),
                  const SizedBox(height: 80),

                  GlobalSectionTitle(title: 'CURATED DISCOVERY', subtitle: 'THE FRONTIER', lc: lc).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideY(begin: 0.1, end: 0),
                  const SizedBox(height: 40),
                  _buildDiscoveryFilter(lc).animate().fadeIn(delay: 300.ms, duration: 600.ms).slideY(begin: 0.1, end: 0),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),

          _buildMasonryDiscoveryGrid(lc),

          const SliverToBoxAdapter(child: SizedBox(height: 150)),
        ],
      ),
    );
  }


  Widget _buildCinematicHero(LayoutController lc) {
    return Container(
      height: 380,
      width: double.infinity,
      decoration: BoxDecoration(
        color: lc.cardColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        border: Border.all(color: lc.textColor.withValues(alpha: 1)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          
          Positioned.fill(
            child: PageView.builder(
              controller: controller.bannerPageController,
              onPageChanged: controller.onBannerChanged,
              itemCount: controller.communityBanners.length,
              itemBuilder: (context, index) {
                final banner = controller.communityBanners[index];
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      banner['image']!,
                      fit: BoxFit.cover,
                    ),
                    
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomLeft,
                          end: Alignment.topRight,
                          colors: [
                            lc.backgroundColor.withValues(alpha: 0.95),
                            lc.backgroundColor.withValues(alpha: 0.2),
                            Colors.transparent,
                          ],
                          stops: const [0, 0.4, 1],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          
          Positioned(
            left: 60,
            bottom: 60,
            child: Obx(() {
              final banner = controller.communityBanners[controller.bannerIndex.value];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    banner['title']!,
                    style: GoogleFonts.plusJakartaSans(
                      color: lc.primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                      shadows: [Shadow(color: Colors.black.withValues(alpha: 0.8), blurRadius: 8)],
                    ),
                  ).animate(key: ValueKey('title_${controller.bannerIndex.value}'))
                      .fadeIn(duration: 400.ms).slideX(begin: -0.1, end: 0),
                  const SizedBox(height: 20),
                  Text(
                    banner['subtitle']!,
                    style: GoogleFonts.cinzel(
                      color: lc.textColor,
                      fontSize: 56,
                      fontWeight: FontWeight.w400,
                      height: 0.95,
                      letterSpacing: -1,
                      shadows: [Shadow(color: Colors.black.withValues(alpha: 0.8), blurRadius: 12)],
                    ),
                  ).animate(key: ValueKey('subtitle_${controller.bannerIndex.value}'))
                      .fadeIn(delay: 100.ms, duration: 400.ms).slideX(begin: -0.1, end: 0),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      _buildHeroButton('DISCOVER NOW', lc),
                      const SizedBox(width: 20),
                      Text(
                        banner['label']!,
                        style: GoogleFonts.plusJakartaSans(
                          color: lc.textColor.withValues(alpha: 0.2),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ).animate(key: ValueKey('cta_${controller.bannerIndex.value}'))
                      .fadeIn(delay: 200.ms, duration: 400.ms),
                ],
              );
            }),
          ),

          
          Positioned(
            right: 60,
            bottom: 60,
            child: Row(
              children: List.generate(controller.communityBanners.length, (index) {
                return Obx(() {
                  final active = controller.bannerIndex.value == index;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    width: active ? 32 : 8,
                    height: 4,
                    margin: const EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      color: active ? lc.primaryColor : lc.textColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                });
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroButton(String text, LayoutController lc) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: lc.textColor.withValues(alpha: 0.2), width: 1),
      ),
      child: Text(
        text,
        style: GoogleFonts.plusJakartaSans(
          color: lc.textColor,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildEditorialTitle(String title, String subtitle, LayoutController lc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          subtitle,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: lc.textColor.withValues(alpha: 0.1),
            letterSpacing: 4,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          style: GoogleFonts.cinzel(
            fontSize: 32,
            fontWeight: FontWeight.w400,
            color: lc.textColor,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 16),
        Container(width: 40, height: 1, color: lc.primaryColor),
      ],
    );
  }

  Widget _buildDiscoveryFilter(LayoutController lc) {
    final filters = [
      {"label": "LIVE SESSIONS", "id": "live"},
      {"label": "MOTION PLOTS", "id": "2D Art"},
      {"label": "TRENDING", "id": "trending"},
    ];

    return Row(
      children: filters.map((f) => Obx(() {
        final active = controller.selectedCategory.value == f['id'];
        return GestureDetector(
          onTap: () => controller.filterByCategory(f['id'] as String),
          child: Padding(
            padding: const EdgeInsets.only(right: 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  f['label'] as String,
                  style: GoogleFonts.plusJakartaSans(
                    color: active ? lc.textColor : lc.textColor.withValues(alpha: 0.2),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 6),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: active ? 16 : 0,
                  height: 1.5,
                  color: lc.primaryColor,
                ),
              ],
            ),
          ),
        );
      })).toList(),
    );
  }

  Widget _buildMasonryDiscoveryGrid(LayoutController lc) {
    return Obx(() {
      final posts = controller.filteredPosts;
      if (posts.isEmpty) {
        
        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 60),
          sliver: SliverMasonryGrid.count(
            crossAxisCount: 3,
            mainAxisSpacing: 48,
            crossAxisSpacing: 40,
            itemBuilder: (context, index) => _buildSkeletonCard(lc),
            childCount: 6,
          ),
        );
      }

      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 60),
        sliver: SliverMasonryGrid.count(
          crossAxisCount: 3,
          mainAxisSpacing: 48,
          crossAxisSpacing: 40,
          itemBuilder: (context, index) {
            return GlobalArtworkCard(
              post: posts[index],
              onTap: () => controller.openPostDetail(posts[index]),
            ).animate(delay: Duration(milliseconds: 100 * (index % 10))).fadeIn(duration: 600.ms).slideY(begin: 0.15, end: 0, curve: Curves.easeOutQuad);
          },
          childCount: posts.length,
        ),
      );
    });
  }

  Widget _buildSkeletonCard(LayoutController lc) {
    final heights = [280.0, 320.0, 260.0, 300.0, 340.0, 270.0];
    final h = heights[DateTime.now().millisecond % heights.length];
    return Shimmer.fromColors(
      baseColor: lc.cardColor,
      highlightColor: lc.textColor.withValues(alpha: 0.06),
      child: Container(
        height: h,
        decoration: BoxDecoration(
          color: lc.cardColor,
          borderRadius: BorderRadius.circular(32),
        ),
      ),
    );
  }
}
