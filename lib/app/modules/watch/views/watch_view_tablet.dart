import 'dart:ui';
import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../data/models/comment_model.dart';
import '../../../data/models/post_model.dart';
import '../../../data/models/user_model.dart';
import '../controllers/watch_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../layout/controllers/layout_controller.dart';

/// PROFESSIONAL VIDEO PLAYER LAYOUT
/// - Large video player (70-80% screen) with full controls
/// - Related videos sidebar on right
/// - Info panel below video
/// - Comments section at bottom
class WatchViewTablet extends GetView<WatchController> {
  const WatchViewTablet({super.key});
  
  @override
  Widget build(BuildContext context) {
    final lc = Get.find<LayoutController>();
    
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 80, height: 80,
                  child: CircularProgressIndicator(
                    color: lc.primaryColor, strokeWidth: 4,
                  ),
                ),
                const SizedBox(height: 24),
                Text('LOADING VIDEO', style: GoogleFonts.orbitron(
                  color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 3)),
              ],
            ),
          );
        }
        
        final post = controller.post.value;
        if (post == null) return const Center(child: Text('Video not found', style: TextStyle(color: Colors.white38)));
        
        return _VideoPlayerLayout(controller: controller, post: post, lc: lc);
      }),
    );
  }
}


/// MAIN LAYOUT: Video player + Related videos sidebar
class _VideoPlayerLayout extends StatefulWidget {
  final WatchController controller;
  final PostModel post;
  final LayoutController lc;
  
  const _VideoPlayerLayout({required this.controller, required this.post, required this.lc});
  
  @override
  State<_VideoPlayerLayout> createState() => _VideoPlayerLayoutState();
}

class _VideoPlayerLayoutState extends State<_VideoPlayerLayout> {
  final _showSidebar = true.obs;
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // LEFT: Main content (Video + Info + Comments)
        Expanded(
          child: Column(
            children: [
              // Video player section
              Expanded(
                child: Container(
                  color: Colors.black,
                  child: Stack(
                    children: [
                      // Video player - scales to fit available space
                      Positioned.fill(
                        child: Center(
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: widget.controller.playerController != null
                                ? BetterPlayer(controller: widget.controller.playerController!)
                                : Container(
                                    color: Colors.black,
                                    child: Center(
                                      child: Icon(Icons.play_circle_outline, 
                                        size: 100, color: widget.lc.primaryColor.withOpacity(0.3)),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      
                      // Back button
                      Positioned(
                        top: 16, left: 16,
                        child: SafeArea(
                          child: Material(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              onTap: () => Get.back(),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                child: Icon(Icons.arrow_back_rounded, color: Colors.white, size: 24),
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      // Toggle sidebar button
                      Positioned(
                        top: 16, right: 16,
                        child: SafeArea(
                          child: Obx(() => Material(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(12),
                            child: InkWell(
                              onTap: () => _showSidebar.value = !_showSidebar.value,
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _showSidebar.value ? Icons.chevron_right_rounded : Icons.chevron_left_rounded,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                    if (!_showSidebar.value) ...[
                                      const SizedBox(width: 8),
                                      Icon(Icons.playlist_play_rounded, color: widget.lc.primaryColor, size: 20),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          )),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Info and comments section
              Expanded(
                child: Container(
                  color: const Color(0xFF0A0A0F),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _VideoInfoPanel(controller: widget.controller, post: widget.post, lc: widget.lc),
                        const SizedBox(height: 16),
                        _CommentsSection(controller: widget.controller, lc: widget.lc),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // RIGHT: Related videos sidebar (collapsible)
        Obx(() => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: _showSidebar.value ? 380 : 0,
          decoration: BoxDecoration(
            color: const Color(0xFF12121A),
            border: _showSidebar.value
                ? Border(left: BorderSide(color: Colors.white.withOpacity(0.05)))
                : null,
          ),
          child: _showSidebar.value
              ? _RelatedVideosSidebar(controller: widget.controller, lc: widget.lc)
              : const SizedBox.shrink(),
        )),
      ],
    );
  }
}


/// VIDEO INFO PANEL - Title, description, artist, stats, actions
class _VideoInfoPanel extends StatelessWidget {
  final WatchController controller;
  final PostModel post;
  final LayoutController lc;
  
  const _VideoInfoPanel({required this.controller, required this.post, required this.lc});
  
  @override
  Widget build(BuildContext context) {
    final pc = Get.find<ProfileController>();
    
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            post.name,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              height: 1.3,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Stats row
          Row(
            children: [
              _StatChip(
                icon: Icons.remove_red_eye_rounded,
                label: '${_formatNumber(post.views)} views',
                color: Colors.cyan,
              ),
              const SizedBox(width: 12),
              _StatChip(
                icon: Icons.calendar_today_rounded,
                label: _formatDate(post.createdAt),
                color: Colors.orange,
              ),
              const SizedBox(width: 12),
              if (post.fileType != null)
                _StatChip(
                  icon: Icons.video_library_rounded,
                  label: post.fileType!.toUpperCase(),
                  color: lc.primaryColor,
                ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Action buttons row
          Row(
            children: [
              Obx(() => _ActionButton(
                icon: controller.isLiked.value ? Icons.favorite : Icons.favorite_border,
                label: '${_formatNumber(controller.likeCount.value)} Likes',
                onTap: controller.toggleLike,
                color: Colors.pink,
                isActive: controller.isLiked.value,
              )),
              const SizedBox(width: 12),
              _ActionButton(
                icon: Icons.share_rounded,
                label: 'Share',
                onTap: () {},
                color: Colors.blue,
              ),
              const SizedBox(width: 12),
              _ActionButton(
                icon: Icons.download_rounded,
                label: 'Download',
                onTap: () {},
                color: Colors.green,
              ),
              const SizedBox(width: 12),
              _ActionButton(
                icon: Icons.bookmark_border_rounded,
                label: 'Save',
                onTap: () {},
                color: Colors.amber,
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Divider
          Container(height: 1, color: Colors.white.withOpacity(0.1)),
          
          const SizedBox(height: 24),
          
          // Artist info
          Obx(() {
            final user = controller.user.value;
            if (user == null) return const SizedBox.shrink();
            
            return Row(
              children: [
                // Avatar
                GestureDetector(
                  onTap: () => Get.toNamed('/profile/${user.id}'),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: lc.primaryColor.withOpacity(0.5), width: 2),
                    ),
                    child: ClipOval(
                      child: user.avatarUrl?.isNotEmpty == true
                          ? Image.network(user.avatarUrl!, fit: BoxFit.cover)
                          : Container(
                              color: lc.primaryColor.withOpacity(0.2),
                              child: Icon(Icons.person, color: lc.primaryColor, size: 28),
                            ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Name and handle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (user.handle != null)
                        Text(
                          '@${user.handle}',
                          style: GoogleFonts.ibmPlexMono(
                            color: lc.primaryColor,
                            fontSize: 13,
                          ),
                        ),
                    ],
                  ),
                ),
                
                // Follow button
                if (user.id != pc.currentUser.value?.id)
                  Obx(() {
                    final isFollowing = pc.followingMap[user.id] ?? false;
                    
                    return Material(
                      color: isFollowing ? Colors.white.withOpacity(0.1) : lc.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: () => pc.toggleFollowUser(user),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: isFollowing
                                ? Border.all(color: lc.primaryColor.withOpacity(0.5), width: 2)
                                : null,
                          ),
                          child: Text(
                            isFollowing ? 'FOLLOWING' : 'FOLLOW',
                            style: GoogleFonts.orbitron(
                              color: isFollowing ? lc.primaryColor : Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
              ],
            );
          }),
          
          // Description
          if (post.description?.isNotEmpty == true) ...[
            const SizedBox(height: 20),
            Text(
              post.description!,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white70,
                fontSize: 14,
                height: 1.6,
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  String _formatNumber(int num) {
    if (num >= 1000000) return '${(num / 1000000).toStringAsFixed(1)}M';
    if (num >= 1000) return '${(num / 1000).toStringAsFixed(1)}K';
    return num.toString();
  }
  
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays > 365) return '${(diff.inDays / 365).floor()} years ago';
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()} months ago';
    if (diff.inDays > 0) return '${diff.inDays} days ago';
    if (diff.inHours > 0) return '${diff.inHours} hours ago';
    return 'Just now';
  }
}


class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  
  const _StatChip({required this.icon, required this.label, required this.color});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.ibmPlexMono(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}


class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  final bool isActive;
  
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
    this.isActive = false,
  });
  
  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive ? color.withOpacity(0.2) : Colors.white.withOpacity(0.05),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? color : Colors.white.withOpacity(0.1),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: isActive ? color : Colors.white70, size: 20),
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  color: isActive ? color : Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


/// COMMENTS SECTION
class _CommentsSection extends StatelessWidget {
  final WatchController controller;
  final LayoutController lc;
  
  const _CommentsSection({required this.controller, required this.lc});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.comment_rounded, color: lc.primaryColor, size: 24),
              const SizedBox(width: 12),
              Obx(() => Text(
                '${controller.comments.length} Comments',
                style: GoogleFonts.orbitron(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              )),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Input box
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.commentController,
                  style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Add a comment...',
                    hintStyle: GoogleFonts.plusJakartaSans(color: Colors.white38),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: lc.primaryColor, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  maxLines: null,
                ),
              ),
              const SizedBox(width: 12),
              Obx(() => Material(
                color: controller.isPostingComment.value ? Colors.white12 : lc.primaryColor,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: controller.isPostingComment.value ? null : controller.postComment,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    child: controller.isPostingComment.value
                      ? SizedBox(
                          width: 20, height: 20,
                          child: CircularProgressIndicator(
                            color: lc.primaryColor, strokeWidth: 2))
                      : Icon(Icons.send_rounded, color: Colors.black, size: 20),
                  ),
                ),
              )),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Comments list
          Obx(() {
            if (controller.comments.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 60, color: Colors.white.withOpacity(0.1)),
                      const SizedBox(height: 16),
                      Text('No comments yet', style: GoogleFonts.plusJakartaSans(
                        color: Colors.white38, fontSize: 14)),
                    ],
                  ),
                ),
              );
            }
            
            return Column(
              children: controller.comments.map((comment) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _CommentCard(comment: comment, lc: lc),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }
}


class _CommentCard extends StatelessWidget {
  final CommentModel comment;
  final LayoutController lc;
  
  const _CommentCard({required this.comment, required this.lc});
  
  @override
  Widget build(BuildContext context) {
    final user = comment.user;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: user?.avatarUrl?.isNotEmpty == true
                ? NetworkImage(user!.avatarUrl!)
                : null,
            backgroundColor: lc.primaryColor.withOpacity(0.2),
            child: user?.avatarUrl?.isEmpty != false
                ? Text(user?.name[0] ?? '?', style: GoogleFonts.orbitron(
                    color: lc.primaryColor, fontSize: 14, fontWeight: FontWeight.w900))
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(user?.name ?? 'Unknown', style: GoogleFonts.plusJakartaSans(
                      color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                    const SizedBox(width: 8),
                    Text(
                      _formatTime(comment.createdAt),
                      style: GoogleFonts.ibmPlexMono(color: Colors.white38, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  comment.data,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);
    
    if (diff.inDays > 0) return '${diff.inDays}d';
    if (diff.inHours > 0) return '${diff.inHours}h';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m';
    return 'now';
  }
}


/// RELATED VIDEOS SIDEBAR
class _RelatedVideosSidebar extends StatelessWidget {
  final WatchController controller;
  final LayoutController lc;
  
  const _RelatedVideosSidebar({required this.controller, required this.lc});
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05))),
          ),
          child: Row(
            children: [
              Icon(Icons.playlist_play_rounded, color: lc.primaryColor, size: 24),
              const SizedBox(width: 12),
              Text(
                'RELATED VIDEOS',
                style: GoogleFonts.orbitron(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
        
        // Related videos list
        Expanded(
          child: Obx(() {
            if (controller.relatedVideos.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.video_library_outlined, size: 60, color: Colors.white.withOpacity(0.1)),
                      const SizedBox(height: 16),
                      Text('No related videos', style: GoogleFonts.plusJakartaSans(
                        color: Colors.white38, fontSize: 13)),
                    ],
                  ),
                ),
              );
            }
            
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: controller.relatedVideos.length,
              itemBuilder: (context, index) {
                final video = controller.relatedVideos[index];
                return _RelatedVideoCard(video: video, lc: lc);
              },
            );
          }),
        ),
      ],
    );
  }
}


class _RelatedVideoCard extends StatelessWidget {
  final PostModel video;
  final LayoutController lc;
  
  const _RelatedVideoCard({required this.video, required this.lc});
  
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => Get.toNamed('/watch/${video.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              Container(
                width: 120,
                height: 68,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.black,
                  image: video.thumbnail.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(video.thumbnail),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: video.thumbnail.isEmpty
                    ? Icon(Icons.play_circle_outline, color: lc.primaryColor.withOpacity(0.5), size: 32)
                    : Stack(
                        children: [
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                gradient: LinearGradient(
                                  colors: [Colors.transparent, Colors.black.withOpacity(0.5)],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ),
                          Center(
                            child: Icon(Icons.play_circle_filled, color: Colors.white, size: 32),
                          ),
                        ],
                      ),
              ),
              
              const SizedBox(width: 12),
              
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.name,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${_formatNumber(video.views)} views',
                      style: GoogleFonts.ibmPlexMono(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  String _formatNumber(int num) {
    if (num >= 1000000) return '${(num / 1000000).toStringAsFixed(1)}M';
    if (num >= 1000) return '${(num / 1000).toStringAsFixed(1)}K';
    return num.toString();
  }
}
