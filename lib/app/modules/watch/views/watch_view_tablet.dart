import 'dart:ui';
import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/utils/responsive_utils.dart';
import '../../../data/models/post_model.dart';
import '../../../data/models/user_model.dart';
import '../../layout/controllers/layout_controller.dart';
import '../controllers/watch_controller.dart';

class WatchViewTablet extends GetView<WatchController> {
  const WatchViewTablet({super.key});

  @override
  Widget build(BuildContext context) {
    final layoutController = Get.find<LayoutController>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: _buildBody(context, layoutController),
    );
  }

  Widget _buildBody(BuildContext context, LayoutController layoutController) {
    return Obx(() {
      if (controller.isLoading.value) {
        return Center(
          child: CircularProgressIndicator(color: layoutController.primaryColor),
        );
      }

      final post = controller.post.value;
      if (post == null) {
        return _buildEmptyState();
      }

      if (!post.isVideo) {
        Future.delayed(Duration.zero, () {
          Get.offNamed('/view/${post.id}');
        });
        return const SizedBox.shrink();
      }

      final user = controller.user.value;

      return Stack(
        children: [
          
          Positioned.fill(
            child: _buildImmersiveVideoPlayer(layoutController),
          ),

          
          Positioned(
            top: 24,
            left: 24,
            child: SafeArea(child: _buildFloatingBackButton(context)),
          ),

          
          Positioned(
            top: 24,
            right: 24,
            child: SafeArea(child: Obx(() => 
              AnimatedOpacity(
                duration: 200.ms,
                opacity: controller.isPanelVisible.value ? 0 : 1,
                child: IgnorePointer(
                  ignoring: controller.isPanelVisible.value,
                  child: _buildToggleButton(context),
                )
              )
            )),
          ),

          
          Positioned(
            top: 24,
            bottom: 24,
            right: 24,
            width: 420,
            child: SafeArea(child: Obx(() => AnimatedSlide(
              offset: controller.isPanelVisible.value ? Offset.zero : const Offset(1.2, 0),
              duration: 500.ms,
              curve: Curves.easeOutQuint,
              child: _buildFloatingPanel(context, post, user, layoutController),
            ))),
          ),
        ],
      );
    });
  }

  Widget _buildToggleButton(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: GestureDetector(
          onTap: controller.togglePanel,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha: 0.3),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: const Center(
              child: Icon(Icons.info_outline_rounded, color: Colors.white, size: 24),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingBackButton(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withValues(alpha: 0.3),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: const Center(
              child: Padding(
                padding: EdgeInsets.only(left: 8.0),
                child: Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.videocam_off_outlined, size: 80, color: Colors.white30),
          const SizedBox(height: 24),
          Text(
            'video_not_found'.tr,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white54,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImmersiveVideoPlayer(LayoutController layoutController) {
    return Container(
      color: Colors.black, 
      child: Center(
        child: controller.playerController == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: layoutController.primaryColor),
                  const SizedBox(height: 24),
                  Text(
                    'initializing_theater'.tr.toUpperCase(),
                    style: GoogleFonts.plusJakartaSans(color: Colors.white30, fontSize: 13, letterSpacing: 1),
                  ),
                ],
              )
            : BetterPlayer(controller: controller.playerController!),
      ),
    ).animate().fade(duration: 800.ms);
  }

  Widget _buildFloatingPanel(BuildContext context, PostModel post, UserModel? user, LayoutController layoutController) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 48, sigmaY: 48), 
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.4), 
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 1.5),
          ),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(32),
                sliver: SliverList.list(
                  children: [
                    
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            post.name.toUpperCase(),
                            style: GoogleFonts.cinzel(
                              color: Colors.white,
                              fontSize: context.responsiveFontSize(32),
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: controller.togglePanel,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close_rounded, color: Colors.white54, size: 20),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    
                    Row(
                      children: [
                        _buildSmallMetric(Icons.remove_red_eye_rounded, _fmt(post.views), layoutController),
                        const SizedBox(width: 24),
                        _buildSmallMetric(Icons.calendar_today_rounded, DateFormat('MMM d, yyyy').format(post.createdAt).toUpperCase(), layoutController),
                      ],
                    ),
                    const SizedBox(height: 32),

                    
                    _buildArtistRow(context, user, layoutController),
                    const SizedBox(height: 32),

                    
                    if (post.description != null && post.description!.isNotEmpty) ...[
                      Text(
                        post.description!,
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: context.responsiveFontSize(14),
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],

                    
                    Row(
                      children: [
                        Expanded(child: _buildLikeButton(context, layoutController)),
                        const SizedBox(width: 12),
                        if (post.projectFileUrl?.isNotEmpty ?? false)
                          Expanded(child: _buildActionCapsule(context, 'remix_btn'.tr.toUpperCase(), Icons.brush_rounded, () => controller.remixProject(post.projectFileUrl!), layoutController, isGradient: true)),
                      ],
                    ),
                    const SizedBox(height: 32),
                    
                    
                    Container(height: 1, color: Colors.white.withValues(alpha: 0.1)),
                    const SizedBox(height: 32),

                    
                    Text(
                      'reactions'.tr.toUpperCase(),
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: context.responsiveFontSize(14),
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildCommentInput(context, layoutController),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
              _buildCommentsList(context, layoutController),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    ).animate().fade(duration: 600.ms, curve: Curves.easeOut).slideX(begin: 0.1, end: 0, duration: 600.ms, curve: Curves.easeOutCirc);
  }

  Widget _buildSmallMetric(IconData icon, String value, LayoutController lc) {
    return Row(
      children: [
        Icon(icon, color: Colors.white54, size: 16),
        const SizedBox(width: 8),
        Text(value, style: GoogleFonts.plusJakartaSans(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildArtistRow(BuildContext context, UserModel? user, LayoutController layoutController) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Get.toNamed('/profile/${user?.id}'),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.1),
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              image: user?.avatarUrl != null
                  ? DecorationImage(image: NetworkImage(user!.avatarUrl!), fit: BoxFit.cover)
                  : null,
            ),
            child: user?.avatarUrl == null
                ? const Icon(Icons.person, color: Colors.white54, size: 24)
                : null,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user?.name ?? 'unknown_artist'.tr,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: context.responsiveFontSize(16),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'verified_creator'.tr.toUpperCase(),
                style: GoogleFonts.plusJakartaSans(
                  color: layoutController.primaryColor,
                  fontSize: context.responsiveFontSize(10),
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
        _buildFollowButton(context, user, layoutController),
      ],
    );
  }

  Widget _buildFollowButton(BuildContext context, UserModel? user, LayoutController layoutController) {
    return Obx(() {
      final isLogined = controller.profileController.isLogined.value;
      final currentUser = controller.profileController.currentUser.value;

      if (!isLogined || currentUser?.id == user?.id) {
        return const SizedBox.shrink();
      }

      final isFollowing = controller.profileController.followingMap[user?.id] ?? false;

      return GestureDetector(
        onTap: () => controller.profileController.toggleFollowUser(user),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            gradient: isFollowing ? null : layoutController.accentGradient,
            color: isFollowing ? Colors.white.withValues(alpha: 0.1) : null,
            border: Border.all(
              color: isFollowing ? Colors.white.withValues(alpha: 0.2) : Colors.transparent,
              width: 1,
            ),
          ),
          child: Text(
            isFollowing ? 'following_btn'.tr.toUpperCase() : 'follow_btn'.tr.toUpperCase(),
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: context.responsiveFontSize(11),
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildLikeButton(BuildContext context, LayoutController layoutController) {
    return Obx(() {
      final isLiked = controller.isLiked.value;
      final likeCount = controller.likeCount.value;

      return GestureDetector(
        onTap: controller.toggleLike,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(100),
            color: isLiked ? layoutController.primaryColor.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.1),
            border: Border.all(
              color: isLiked ? layoutController.primaryColor : Colors.white.withValues(alpha: 0.15),
              width: 1,
            ),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isLiked ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                  color: isLiked ? layoutController.primaryColor : Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _fmt(likeCount),
                  style: GoogleFonts.plusJakartaSans(
                    color: isLiked ? layoutController.primaryColor : Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: context.responsiveFontSize(13),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildActionCapsule(BuildContext context, String label, IconData icon, VoidCallback action, LayoutController layoutController, {bool isGradient = false}) {
    return GestureDetector(
      onTap: action,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          gradient: isGradient ? layoutController.accentGradient : null,
          color: isGradient ? null : Colors.white.withValues(alpha: 0.1),
          border: isGradient ? null : Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: context.responsiveFontSize(13),
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommentInput(BuildContext context, LayoutController layoutController) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: TextField(
              controller: controller.commentController,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: context.responsiveFontSize(14),
              ),
              decoration: InputDecoration(
                hintText: 'add_comment'.tr,
                hintStyle: GoogleFonts.plusJakartaSans(
                  color: Colors.white54,
                  fontSize: context.responsiveFontSize(14),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
              onSubmitted: (_) => controller.postComment(),
            ),
          ),
        ),
        const SizedBox(width: 12),
        _buildSendButton(context, layoutController),
      ],
    );
  }

  Widget _buildSendButton(BuildContext context, LayoutController layoutController) {
    return Obx(() {
      final isPosting = controller.isPostingComment.value;
      return GestureDetector(
        onTap: isPosting ? null : controller.postComment,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isPosting ? null : layoutController.accentGradient,
            color: isPosting ? Colors.white.withValues(alpha: 0.1) : null,
          ),
          child: isPosting
              ? const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  ),
                )
              : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
        ),
      );
    });
  }

  Widget _buildCommentsList(BuildContext context, LayoutController layoutController) {
    return SliverToBoxAdapter(
      child: Obx(() {
        final comments = controller.comments.toList();

        if (comments.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: Center(
              child: Text(
                'be_first_comment'.tr.toUpperCase(),
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white24,
                  fontSize: context.responsiveFontSize(11),
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: comments.map((comment) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white10,
                      backgroundImage: comment.user?.avatarUrl != null ? NetworkImage(comment.user!.avatarUrl!) : null,
                      child: comment.user?.avatarUrl == null ? const Icon(Icons.person, color: Colors.white38, size: 20) : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.2), 
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(24),
                            bottomLeft: Radius.circular(24),
                            bottomRight: Radius.circular(24),
                          ),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  comment.user?.name ?? 'Unknown',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: layoutController.primaryColor,
                                    fontWeight: FontWeight.w900,
                                    fontSize: context.responsiveFontSize(13),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  DateFormat('MMM d, yyyy').format(comment.createdAt),
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white54,
                                    fontSize: context.responsiveFontSize(10),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              comment.data,
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontSize: context.responsiveFontSize(14),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      }),
    );
  }

  String _fmt(int num) {
    if (num >= 1000000) return '${(num / 1000000).toStringAsFixed(1)}M';
    if (num >= 1000) return '${(num / 1000).toStringAsFixed(1)}K';
    return num.toString();
  }
}
