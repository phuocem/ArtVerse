import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:artverse/app/modules/layout/controllers/layout_controller.dart';
import 'package:artverse/app/modules/community/controllers/community_controller.dart';

class CommunityHero extends GetView<CommunityController> {
  final LayoutController lc;

  const CommunityHero({super.key, required this.lc});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 380,
      width: double.infinity,
      decoration: BoxDecoration(
        color: lc.cardColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        border: Border.all(color: lc.textColor.withValues(alpha: 0.05)),
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
}
