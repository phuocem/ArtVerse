import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/responsive_utils.dart';
import '../../../data/models/post_model.dart';
import '../../layout/controllers/layout_controller.dart';
import '../controllers/portfolio_controller.dart';

class PortfolioViewTablet extends GetView<PortfolioController> {
  const PortfolioViewTablet({super.key});

  @override
  Widget build(BuildContext context) {
    final layoutController = Get.find<LayoutController>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xFFFF69B4),
              strokeWidth: 3,
            ),
          );
        }

        return Stack(
          children: [
            _buildBackgroundGlows(context),
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildAppBar(context, layoutController),
                _buildArtistHeader(context, layoutController),
                _buildStatsGrid(context, layoutController),
                _buildFilterChips(context, layoutController),
                _buildPortfolioGrid(context, layoutController),
                const SliverToBoxAdapter(child: SizedBox(height: 150)),
              ],
            ),
            _buildShareFAB(context),
          ],
        );
      }),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return SliverToBoxAdapter(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.art_track_rounded, color: Colors.white24, size: 80),
            ),
            const SizedBox(height: 24),
            Text(
              'no_works_found'.tr.toUpperCase(),
              style: const TextStyle(color: Colors.white38, fontSize: 18, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundGlows(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Positioned(
          top: -150,
          right: -150,
          child: Container(
            width: size.width * 0.6,
            height: size.width * 0.6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  controller.primaryColor.withValues(alpha: 0.12),
                  Colors.transparent,
                ],
              ),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
              child: Container(color: Colors.transparent),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(BuildContext context, LayoutController layoutController) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leadingWidth: 80,
      leading: Padding(
        padding: const EdgeInsets.all(12),
        child: GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.08),
                  Colors.white.withValues(alpha: 0.02),
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1.5),
            ),
            child: Icon(Icons.arrow_back_ios_new_rounded, color: layoutController.textColor, size: 18),
          ),
        ),
      ),
      title: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              controller.primaryColor.withValues(alpha: 0.2),
              controller.primaryColor.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: controller.primaryColor.withValues(alpha: 0.4)),
        ),
        child: Text(
          'your_portfolio'.tr.toUpperCase(),
          style: TextStyle(
            fontSize: context.responsiveFontSize(14),
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
            color: layoutController.textColor,
          ),
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildArtistHeader(BuildContext context, LayoutController layoutController) {
    final user = controller.profileController.currentUser.value;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 32, 32, 24),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [controller.primaryColor, controller.primaryColor.withValues(alpha: 0.4), Colors.transparent],
                ),
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                radius: 48,
                backgroundImage: user?.avatarUrl != null ? NetworkImage(user!.avatarUrl!) : null,
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                child: user?.avatarUrl == null ? Icon(Icons.person_rounded, color: layoutController.textColor, size: 48) : null,
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    user?.name.toUpperCase() ?? 'elite_artist'.tr.toUpperCase(),
                    style: TextStyle(
                      fontSize: context.responsiveFontSize(28),
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      color: const Color(0xFFFF1493),
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [controller.primaryColor.withValues(alpha: 0.25), controller.primaryColor.withValues(alpha: 0.1)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: controller.primaryColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      "studio_master".tr.toUpperCase(),
                      style: TextStyle(
                        fontSize: context.responsiveFontSize(11),
                        fontWeight: FontWeight.w800,
                        color: controller.primaryColor,
                        letterSpacing: 1.5,
                      ),
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

  Widget _buildStatsGrid(BuildContext context, LayoutController lc) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Row(
          children: [
            _buildStatCard(context, "works".tr.toUpperCase(), controller.projects.length.toString(), Icons.photo_library_rounded),
            const SizedBox(width: 16),
            _buildStatCard(context, "collections".tr.toUpperCase(), controller.collections.length.toString(), Icons.collections_bookmark_rounded),
            const SizedBox(width: 16),
            _buildStatCard(context, "views".tr.toUpperCase(), controller.portfolioStats['total_views']?.toString() ?? "0", Icons.visibility_rounded),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: controller.primaryColor, size: 24),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
            Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context, LayoutController lc) {
    final filters = [
      {'id': -1, 'label': 'all'.tr.toUpperCase()},
      {'id': 1, 'label': 'public'.tr.toUpperCase()},
      {'id': 0, 'label': 'private'.tr.toUpperCase()},
    ];

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 8, 32, 32),
        child: Row(
          children: filters.map((f) {
            return Obx(() {
              final isSelected = controller.filterStatus.value == f['id'];
              return GestureDetector(
                onTap: () => controller.setFilter(f['id'] as int),
                child: Container(
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? controller.primaryColor : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isSelected ? Colors.transparent : Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Text(
                    f['label'] as String,
                    style: TextStyle(color: isSelected ? Colors.white : Colors.white60, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              );
            });
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPortfolioGrid(BuildContext context, LayoutController layoutController) {
    if (controller.projects.isEmpty) return _buildEmptyState(context);

    final gridColumns = context.gridCrossAxisCount;
    final spacing = context.gridSpacing;

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: gridColumns,
          mainAxisSpacing: spacing,
          crossAxisSpacing: spacing,
          childAspectRatio: 1.4,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          return _buildPortfolioCard(context, controller.projects[index], index, layoutController);
        }, childCount: controller.projects.length),
      ),
    );
  }

  Widget _buildPortfolioCard(BuildContext context, PostModel post, int index, LayoutController layoutController) {
    return GestureDetector(
      onTap: () => controller.openProject(post),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 25, offset: const Offset(0, 12)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(post.isVideo ? 'assets/video.png' : 'assets/anh.png', fit: BoxFit.cover),
              _buildGradientOverlay(),
              if (post.isVideo) _buildVideoIndicator(),
              _buildCardContent(context, post, index, layoutController),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.transparent, Colors.black.withValues(alpha: 0.7), Colors.black.withValues(alpha: 0.95)],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoIndicator() {
    return Positioned(
      top: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2),
        ),
        child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildCardContent(BuildContext context, PostModel post, int index, LayoutController layoutController) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              post.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: context.responsiveFontSize(16),
                fontWeight: FontWeight.w800,
                height: 1.2,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildMetric(context, Icons.favorite_rounded, post.likesCount.toString()),
                const SizedBox(width: 12),
                _buildMetric(context, Icons.remove_red_eye_rounded, post.views.toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetric(BuildContext context, IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white60, size: 14),
        const SizedBox(width: 4),
        Text(value, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildShareFAB(BuildContext context) {
    return Positioned(
      bottom: 40,
      right: 40,
      child: FloatingActionButton.extended(
        elevation: 10,
        onPressed: () => controller.refreshPortfolio(),
        backgroundColor: controller.primaryColor,
        label: Row(
          children: [
            const Icon(Icons.share_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text('share_studio'.tr.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
          ],
        ),
      ),
    );
  }
}
