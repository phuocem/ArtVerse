import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/global/global_artwork_card.dart';
import '../../layout/controllers/layout_controller.dart';
import '../controllers/community_controller.dart';
class CommunityViewTablet extends GetView<CommunityController> {
  const CommunityViewTablet({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          _CommunityTopBar(controller: controller),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _FilterRail(),
                Expanded(
                  child: _PostGrid(controller: controller),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
class _CommunityTopBar extends StatelessWidget {
  final CommunityController controller;
  const _CommunityTopBar({required this.controller});
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
          Text('Discover', style: GoogleFonts.lexend(
            color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(width: 8),
          Obx(() => Text(
            '${controller.filteredPosts.length} works',
            style: GoogleFonts.ibmPlexMono(color: AppColors.textTertiary, fontSize: 10),
          )),
          const Spacer(),
          _SearchBar(controller: controller),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => Get.toNamed<void>('/community/upload'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: AppColors.violetPink,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add_rounded, color: Colors.white, size: 14),
                  const SizedBox(width: 6),
                  Text('Share', style: GoogleFonts.plusJakartaSans(
                    color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class _SearchBar extends StatelessWidget {
  final CommunityController controller;
  const _SearchBar({required this.controller});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 240,
      height: 36,
      child: TextField(
        controller: controller.searchController,
        onChanged: controller.updateSearch,
        style: GoogleFonts.plusJakartaSans(color: AppColors.textPrimary, fontSize: 13),
        decoration: InputDecoration(
          hintText: 'Search artworks…',
          hintStyle: GoogleFonts.plusJakartaSans(color: AppColors.textTertiary, fontSize: 12),
          prefixIcon: Icon(Icons.search_rounded, color: AppColors.textTertiary, size: 16),
          filled: true,
          fillColor: AppColors.surface2,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.border, width: 0.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.border, width: 0.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: AppColors.violet.withValues(alpha: 0.5), width: 1),
          ),
        ),
      ),
    );
  }
}
class _FilterRail extends GetView<CommunityController> {
  const _FilterRail();
  static const _cats = [
    ('All', 'all', Icons.apps_rounded),
    ('Photos', 'art_photos', Icons.photo_outlined),
    ('Video', 'video_film', Icons.play_circle_outline_rounded),
    ('Trending', 'trending', Icons.trending_up_rounded),
    ('Illustrations', 'illustrations', Icons.brush_outlined),
    ('Animations', 'animations', Icons.animation_rounded),
  ];
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
            child: Text('FILTER', style: GoogleFonts.ibmPlexMono(
              color: AppColors.textTertiary, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 2)),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: _cats.map((cat) => Obx(() {
                final active = controller.selectedCategory.value == cat.$2;
                return GestureDetector(
                  onTap: () => controller.filterByCategory(cat.$2),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: active ? AppColors.violet.withValues(alpha: 0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: active ? AppColors.violet.withValues(alpha: 0.25) : Colors.transparent,
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(cat.$3, size: 15, color: active ? AppColors.violet : AppColors.textTertiary),
                        const SizedBox(width: 8),
                        Text(cat.$1, style: GoogleFonts.plusJakartaSans(
                          color: active ? AppColors.violet : AppColors.textTertiary,
                          fontSize: 11,
                          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                        )),
                      ],
                    ),
                  ),
                );
              })).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Container(height: 0.5, color: AppColors.border),
                const SizedBox(height: 12),
                _SideLink(icon: Icons.chat_bubble_outline_rounded, label: 'Messages',
                    onTap: () => Get.toNamed<void>('/messaging')),
                const SizedBox(height: 4),
                _SideLink(icon: Icons.notifications_outlined, label: 'Notifications',
                    onTap: () => Get.toNamed<void>('/notifications')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
class _SideLink extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SideLink({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Row(
          children: [
            Icon(icon, size: 15, color: AppColors.textTertiary),
            const SizedBox(width: 8),
            Text(label, style: GoogleFonts.plusJakartaSans(
              color: AppColors.textTertiary, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
class _PostGrid extends StatelessWidget {
  final CommunityController controller;
  const _PostGrid({required this.controller});
  @override
  Widget build(BuildContext context) {
    final lc = Get.find<LayoutController>();
    return Obx(() {
      final posts = controller.filteredPosts;
      final loading = controller.isLoading.value;
      if (loading) {
        return _buildSkeleton(lc);
      }
      if (posts.isEmpty) {
        return _buildEmpty();
      }
      return CustomScrollView(
        controller: controller.scrollController,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverMasonryGrid.count(
              crossAxisCount: 3,
              mainAxisSpacing: 20,
              crossAxisSpacing: 16,
              itemBuilder: (context, index) => GlobalArtworkCard(
                post: posts[index],
                onTap: () => controller.openPostDetail(posts[index]),
              ).animate(delay: Duration(milliseconds: 60 * (index % 12)))
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad),
              childCount: posts.length,
            ),
          ),
          if (controller.isLoadingMore.value)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator(color: AppColors.violet, strokeWidth: 2)),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      );
    });
  }
  Widget _buildSkeleton(LayoutController lc) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: MasonryGridView.count(
        crossAxisCount: 3,
        mainAxisSpacing: 20,
        crossAxisSpacing: 16,
        itemCount: 9,
        itemBuilder: (_, i) {
          final heights = [240.0, 280.0, 220.0, 300.0, 260.0, 240.0, 280.0, 220.0, 260.0];
          return Shimmer.fromColors(
            baseColor: AppColors.surface2,
            highlightColor: AppColors.border2,
            child: Container(
              height: heights[i % heights.length],
              decoration: BoxDecoration(
                color: AppColors.surface2,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          );
        },
      ),
    );
  }
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72, height: 72,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.violet.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('🌸', style: TextStyle(fontSize: 32)),
          ),
          const SizedBox(height: 16),
          Text('No artworks yet', style: GoogleFonts.plusJakartaSans(
            color: AppColors.textTertiary, fontSize: 14)),
          const SizedBox(height: 8),
          Text('Be the first to share', style: GoogleFonts.plusJakartaSans(
            color: AppColors.textTertiary.withValues(alpha: 0.6), fontSize: 12)),
        ],
      ).animate().fadeIn(duration: 600.ms),
    );
  }
}