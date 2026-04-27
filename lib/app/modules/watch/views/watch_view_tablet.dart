import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/comment_model.dart';
import '../../../data/models/post_model.dart';
import '../controllers/watch_controller.dart';
import '../../profile/controllers/profile_controller.dart';
class WatchViewTablet extends GetView<WatchController> {
  const WatchViewTablet({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.violet, strokeWidth: 2),
          );
        }
        final post = controller.post.value;
        if (post == null) {
          return _buildEmpty();
        }
        return _WatchBody(controller: controller, post: post);
      }),
    );
  }
  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.video_library_outlined, size: 56, color: AppColors.textTertiary),
          const SizedBox(height: 16),
          Text('Video not available', style: GoogleFonts.plusJakartaSans(
            color: AppColors.textTertiary, fontSize: 14)),
        ],
      ),
    );
  }
}
class _WatchBody extends StatelessWidget {
  final WatchController controller;
  final PostModel post;
  const _WatchBody({required this.controller, required this.post});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 7,
          child: Column(
            children: [
              _VideoPlayer(controller: controller),
              Expanded(child: _VideoInfo(controller: controller, post: post)),
            ],
          ),
        ),
        SizedBox(
          width: 340,
          child: _RightPanel(controller: controller, post: post),
        ),
      ],
    );
  }
}
class _VideoPlayer extends StatelessWidget {
  final WatchController controller;
  const _VideoPlayer({required this.controller});
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: controller.playerController != null
            ? BetterPlayer(controller: controller.playerController!)
            : Container(
                color: AppColors.surface2,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.play_circle_outline_rounded,
                          size: 64, color: AppColors.textTertiary.withValues(alpha: 0.5)),
                      const SizedBox(height: 12),
                      Text('Loading video…', style: GoogleFonts.plusJakartaSans(
                        color: AppColors.textTertiary, fontSize: 13)),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
class _VideoInfo extends StatelessWidget {
  final WatchController controller;
  final PostModel post;
  const _VideoInfo({required this.controller, required this.post});
  @override
  Widget build(BuildContext context) {
    final pc = Get.find<ProfileController>();
    return Container(
      color: AppColors.bg,
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(post.name.isNotEmpty ? post.name : 'Untitled',
              style: GoogleFonts.lexend(
                color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Row(
              children: [
                Obx(() => Text(
                  '${controller.likeCount.value} likes · ${post.views} views',
                  style: GoogleFonts.ibmPlexMono(color: AppColors.textTertiary, fontSize: 10),
                )),
                const Spacer(),
                Obx(() => GestureDetector(
                  onTap: () => controller.toggleLike(),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: controller.isLiked.value
                          ? AppColors.pink.withValues(alpha: 0.15)
                          : AppColors.surface2,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: controller.isLiked.value
                            ? AppColors.pink.withValues(alpha: 0.5)
                            : AppColors.border,
                        width: 0.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          controller.isLiked.value
                              ? Icons.favorite_rounded
                              : Icons.favorite_outline_rounded,
                          size: 14,
                          color: controller.isLiked.value ? AppColors.pink : AppColors.textTertiary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          controller.isLiked.value ? 'Liked' : 'Like',
                          style: GoogleFonts.plusJakartaSans(
                            color: controller.isLiked.value ? AppColors.pink : AppColors.textTertiary,
                            fontSize: 12, fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
              ],
            ),
            const SizedBox(height: 16),
            Container(height: 0.5, color: AppColors.border),
            const SizedBox(height: 14),
            Obx(() {
              final user = controller.user.value;
              if (user == null) return const SizedBox.shrink();
              return Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.violet.withValues(alpha: 0.2),
                    backgroundImage: user.avatarUrl?.isNotEmpty == true
                        ? NetworkImage(user.avatarUrl!) : null,
                    child: user.avatarUrl?.isEmpty != false
                        ? Text(user.name.isNotEmpty ? user.name[0] : '?',
                            style: GoogleFonts.lexend(color: AppColors.violet, fontSize: 14, fontWeight: FontWeight.w900))
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.name, style: GoogleFonts.plusJakartaSans(
                        color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w700)),
                      if (user.handle != null)
                        Text('@${user.handle}', style: GoogleFonts.ibmPlexMono(
                          color: AppColors.textTertiary, fontSize: 10)),
                    ],
                  ),
                  const Spacer(),
                  Obx(() {
                    final isCurrentUser = pc.currentUser.value?.id == user.id;
                    if (isCurrentUser) return const SizedBox.shrink();
                    return GestureDetector(
                      onTap: () => pc.toggleFollowUser(user),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          gradient: AppColors.violetPink,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('Follow', style: GoogleFonts.plusJakartaSans(
                          color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                      ),
                    );
                  }),
                ],
              );
            }),
            if (post.description?.isNotEmpty == true) ...[
              const SizedBox(height: 12),
              Text(post.description!, style: GoogleFonts.plusJakartaSans(
                color: AppColors.textSecondary, fontSize: 12, height: 1.6)),
            ],
          ],
        ),
      ),
    );
  }
}
class _RightPanel extends StatelessWidget {
  final WatchController controller;
  final PostModel post;
  const _RightPanel({required this.controller, required this.post});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(left: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
              ),
              child: TabBar(
                labelStyle: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700),
                unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontSize: 12),
                labelColor: AppColors.violet,
                unselectedLabelColor: AppColors.textTertiary,
                indicatorColor: AppColors.violet,
                indicatorSize: TabBarIndicatorSize.label,
                tabs: const [
                  Tab(text: 'Comments'),
                  Tab(text: 'Related'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _CommentsTab(controller: controller, postId: post.id ?? ''),
                  _RelatedTab(controller: controller),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class _CommentsTab extends StatelessWidget {
  final WatchController controller;
  final String postId;
  const _CommentsTab({required this.controller, required this.postId});
  @override
  Widget build(BuildContext context) {
    final textCtrl = TextEditingController();
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: textCtrl,
                  style: GoogleFonts.plusJakartaSans(color: AppColors.textPrimary, fontSize: 12),
                  decoration: InputDecoration(
                    hintText: 'Add a comment…',
                    hintStyle: GoogleFonts.plusJakartaSans(color: AppColors.textTertiary, fontSize: 12),
                    filled: true,
                    fillColor: AppColors.surface2,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  controller.postComment();
                  textCtrl.clear();
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: AppColors.violetPink,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.send_rounded, size: 16, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Obx(() {
            final comments = controller.comments;
            if (comments.isEmpty) {
              return Center(
                child: Text('No comments yet', style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textTertiary, fontSize: 12)),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: comments.length,
              itemBuilder: (ctx, i) => _CommentTile(comment: comments[i], index: i),
            );
          }),
        ),
      ],
    );
  }
}
class _CommentTile extends StatelessWidget {
  final CommentModel comment;
  final int index;
  const _CommentTile({required this.comment, required this.index});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.violet.withValues(alpha: 0.15),
            backgroundImage: comment.user?.avatarUrl?.isNotEmpty == true
                ? NetworkImage(comment.user!.avatarUrl!) : null,
            child: comment.user?.avatarUrl?.isEmpty != false
                ? Text(comment.user?.name.isNotEmpty == true ? comment.user!.name[0] : '?',
                    style: GoogleFonts.lexend(color: AppColors.violet, fontSize: 10, fontWeight: FontWeight.w900))
                : null,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(comment.user?.name ?? 'Unknown', style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textPrimary, fontSize: 11, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(comment.data, style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textSecondary, fontSize: 11, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: 40 * index)).fadeIn(duration: 300.ms);
  }
}
class _RelatedTab extends StatelessWidget {
  final WatchController controller;
  const _RelatedTab({required this.controller});
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final related = controller.relatedVideos;
      if (related.isEmpty) {
        return Center(
          child: Text('No related videos', style: GoogleFonts.plusJakartaSans(
            color: AppColors.textTertiary, fontSize: 12)),
        );
      }
      return ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: related.length,
        itemBuilder: (ctx, i) => _RelatedCard(post: related[i], index: i),
      );
    });
  }
}
class _RelatedCard extends StatelessWidget {
  final PostModel post;
  final int index;
  const _RelatedCard({required this.post, required this.index});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed<void>('/watch/${post.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.surface2,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: Row(
          children: [
            Container(
              width: 100, height: 64,
              color: AppColors.bg,
              child: post.url.isNotEmpty
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(post.url, fit: BoxFit.cover, errorBuilder: (_, __, ___) =>
                          Icon(Icons.play_circle_outline_rounded, color: AppColors.textTertiary)),
                        Center(
                          child: Container(
                            width: 28, height: 28,
                            decoration: const BoxDecoration(
                              color: Colors.black54, shape: BoxShape.circle),
                            child: const Icon(Icons.play_arrow_rounded, size: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    )
                  : Center(child: Icon(Icons.play_circle_outline_rounded, color: AppColors.textTertiary)),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(post.name.isNotEmpty ? post.name : 'Untitled',
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        color: AppColors.textPrimary, fontSize: 11, fontWeight: FontWeight.w600, height: 1.3)),
                    const SizedBox(height: 4),
                    Text('${post.views} views', style: GoogleFonts.ibmPlexMono(
                      color: AppColors.textTertiary, fontSize: 9)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ).animate(delay: Duration(milliseconds: 50 * index)).fadeIn(duration: 300.ms),
    );
  }
}