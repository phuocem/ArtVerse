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
import '../../../core/theme/app_colors.dart';

class WatchViewTablet extends GetView<WatchController> {
  const WatchViewTablet({super.key});
  
  @override
  Widget build(BuildContext context) {
    final lc = Get.find<LayoutController>();
    
    return Scaffold(
      backgroundColor: const Color(0xFF08080C),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 60, height: 60,
                  child: CircularProgressIndicator(
                    color: lc.primaryColor, strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 24),
                Text('LOADING VIDEO', style: GoogleFonts.ibmPlexMono(
                  color: lc.primaryColor, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 3)),
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
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: Container(
                  color: Colors.black,
                  child: Stack(
                    children: [
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
                                        size: 100, color: widget.lc.primaryColor.withValues(alpha: 0.3)),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      
                      // Back button
                      Positioned(
                        top: 16, left: 16,
                        child: SafeArea(
                          child: _ViewerControlBtn(
                            icon: Icons.arrow_back_rounded,
                            onTap: () => Get.back(),
                          ),
                        ),
                      ),
                      
                      // Toggle sidebar button
                      Positioned(
                        top: 16, right: 16,
                        child: SafeArea(
                          child: Obx(() => _ViewerControlBtn(
                            icon: _showSidebar.value ? Icons.chevron_right_rounded : Icons.chevron_left_rounded,
                            onTap: () => _showSidebar.value = !_showSidebar.value,
                            primaryIcon: !_showSidebar.value ? Icons.playlist_play_rounded : null,
                            primaryColor: widget.lc.primaryColor,
                          )),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              Expanded(
                child: Container(
                  color: const Color(0xFF08080C),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _VideoInfoPanel(controller: widget.controller, post: widget.post, lc: widget.lc),
                        _CommentsSection(controller: widget.controller, lc: widget.lc),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        Obx(() => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutQuint,
          width: _showSidebar.value ? 380 : 0,
          decoration: BoxDecoration(
            color: const Color(0xFF0F0F14),
            border: _showSidebar.value
                ? Border(left: BorderSide(color: Colors.white.withValues(alpha: 0.05), width: 0.8))
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

class _ViewerControlBtn extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final IconData? primaryIcon;
  final Color? primaryColor;
  const _ViewerControlBtn({required this.icon, required this.onTap, this.primaryIcon, this.primaryColor});

  @override
  State<_ViewerControlBtn> createState() => _ViewerControlBtnState();
}

class _ViewerControlBtnState extends State<_ViewerControlBtn> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.08 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Material(
          color: Colors.black.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _isHovered 
                      ? (widget.primaryColor ?? Colors.white).withValues(alpha: 0.4) 
                      : Colors.white.withValues(alpha: 0.1),
                  width: 0.8,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(widget.icon, color: Colors.white, size: 22),
                  if (widget.primaryIcon != null) ...[
                    const SizedBox(width: 8),
                    Icon(widget.primaryIcon, color: widget.primaryColor, size: 20),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _VideoInfoPanel extends StatelessWidget {
  final WatchController controller;
  final PostModel post;
  final LayoutController lc;
  
  const _VideoInfoPanel({required this.controller, required this.post, required this.lc});
  
  @override
  Widget build(BuildContext context) {
    final pc = Get.find<ProfileController>();
    
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _StatChip(
                icon: Icons.remove_red_eye_rounded,
                label: '${_formatNumber(post.views)} views',
                color: AppColors.teal,
              ),
              _StatChip(
                icon: Icons.calendar_today_rounded,
                label: _formatDate(post.createdAt),
                color: AppColors.amber,
              ),
              if (post.fileType != null)
                _StatChip(
                  icon: Icons.video_library_rounded,
                  label: post.fileType!.toUpperCase(),
                  color: lc.primaryColor,
                ),
            ],
          ),
          const SizedBox(height: 20),
          
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              Obx(() => _ActionButton(
                icon: controller.isLiked.value ? Icons.favorite : Icons.favorite_border,
                label: '${_formatNumber(controller.likeCount.value)} Likes',
                onTap: controller.toggleLike,
                color: AppColors.pink,
                isActive: controller.isLiked.value,
              )),
              _ActionButton(
                icon: Icons.share_rounded,
                label: 'Share',
                onTap: () {},
                color: AppColors.teal,
              ),
              _ActionButton(
                icon: Icons.download_rounded,
                label: 'Download',
                onTap: () {},
                color: Colors.green,
              ),
              _ActionButton(
                icon: Icons.bookmark_border_rounded,
                label: 'Save',
                onTap: () {},
                color: AppColors.amber,
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          Container(height: 0.8, color: Colors.white.withValues(alpha: 0.08)),
          const SizedBox(height: 24),
          
          Obx(() {
            final user = controller.user.value;
            if (user == null) return const SizedBox.shrink();
            
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.02),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05), width: 0.8),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.toNamed('/profile/${user.id}'),
                    child: Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: lc.primaryColor.withValues(alpha: 0.5), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: lc.primaryColor.withValues(alpha: 0.15),
                            blurRadius: 8,
                          )
                        ],
                      ),
                      child: ClipOval(
                        child: user.avatarUrl?.isNotEmpty == true
                            ? Image.network(user.avatarUrl!, fit: BoxFit.cover)
                            : Container(
                                color: lc.primaryColor.withValues(alpha: 0.2),
                                child: Icon(Icons.person, color: lc.primaryColor, size: 28),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (user.handle != null)
                          Text(
                            '@${user.handle}',
                            style: GoogleFonts.ibmPlexMono(
                              color: lc.primaryColor.withValues(alpha: 0.8),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (user.id != pc.currentUser.value?.id)
                    Obx(() {
                      final isFollowing = pc.followingMap[user.id] ?? false;
                      return _FollowBtn(
                        isFollowing: isFollowing,
                        onTap: () => pc.toggleFollowUser(user),
                        lc: lc,
                      );
                    }),
                ],
              ),
            );
          }),
          
          if (post.description?.isNotEmpty == true) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.015),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.03), width: 0.8),
              ),
              child: Text(
                post.description!,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 13,
                  height: 1.6,
                ),
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

class _FollowBtn extends StatefulWidget {
  final bool isFollowing;
  final VoidCallback onTap;
  final LayoutController lc;
  const _FollowBtn({required this.isFollowing, required this.onTap, required this.lc});

  @override
  State<_FollowBtn> createState() => _FollowBtnState();
}

class _FollowBtnState extends State<_FollowBtn> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.isFollowing
                    ? Colors.white.withValues(alpha: 0.25)
                    : Colors.transparent,
                width: 1.5,
              ),
              gradient: widget.isFollowing
                  ? null
                  : AppColors.violetPink,
              color: widget.isFollowing
                  ? Colors.white.withValues(alpha: 0.08)
                  : null,
              boxShadow: widget.isFollowing
                  ? []
                  : [
                      BoxShadow(
                        color: widget.lc.primaryColor.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      )
                    ],
            ),
            child: Text(
              widget.isFollowing ? 'FOLLOWING' : 'FOLLOW',
              style: GoogleFonts.ibmPlexMono(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
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
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.ibmPlexMono(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
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
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final borderCol = widget.isActive 
        ? widget.color 
        : (_isHovered ? widget.color.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.1));
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: widget.isActive 
                  ? widget.color.withValues(alpha: 0.15) 
                  : (_isHovered ? Colors.white.withValues(alpha: 0.06) : Colors.white.withValues(alpha: 0.02)),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: borderCol,
                width: 1.2,
              ),
              boxShadow: widget.isActive || _isHovered
                  ? [
                      BoxShadow(
                        color: widget.color.withValues(alpha: 0.12),
                        blurRadius: 10,
                      )
                    ]
                  : [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.icon, color: widget.isActive ? widget.color : Colors.white70, size: 18),
                const SizedBox(width: 8),
                Text(
                  widget.label,
                  style: GoogleFonts.plusJakartaSans(
                    color: widget.isActive ? widget.color : Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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
          Row(
            children: [
              Icon(Icons.comment_rounded, color: lc.primaryColor, size: 22),
              const SizedBox(width: 10),
              Obx(() => Text(
                '${controller.comments.length} Comments',
                style: GoogleFonts.orbitron(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              )),
            ],
          ),
          const SizedBox(height: 20),
          
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.commentController,
                  style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Add a comment...',
                    hintStyle: GoogleFonts.plusJakartaSans(color: Colors.white38),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.02),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: lc.primaryColor, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  maxLines: null,
                ),
              ),
              const SizedBox(width: 12),
              Obx(() => _SendCommentBtn(
                isPosting: controller.isPostingComment.value,
                onTap: controller.postComment,
                lc: lc,
              )),
            ],
          ),
          const SizedBox(height: 24),
          
          Obx(() {
            if (controller.comments.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 50, color: Colors.white.withValues(alpha: 0.08)),
                      const SizedBox(height: 16),
                      Text('No comments yet', style: GoogleFonts.plusJakartaSans(
                        color: Colors.white38, fontSize: 13)),
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

class _SendCommentBtn extends StatefulWidget {
  final bool isPosting;
  final VoidCallback onTap;
  final LayoutController lc;
  const _SendCommentBtn({required this.isPosting, required this.onTap, required this.lc});

  @override
  State<_SendCommentBtn> createState() => _SendCommentBtnState();
}

class _SendCommentBtnState extends State<_SendCommentBtn> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.08 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Material(
          color: widget.isPosting ? Colors.white12 : widget.lc.primaryColor,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: widget.isPosting ? null : widget.onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: widget.isPosting || !_isHovered
                    ? []
                    : [
                        BoxShadow(
                          color: widget.lc.primaryColor.withValues(alpha: 0.3),
                          blurRadius: 10,
                        )
                      ],
              ),
              child: widget.isPosting
                ? SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(
                      color: widget.lc.primaryColor, strokeWidth: 2))
                : const Icon(Icons.send_rounded, color: Colors.black, size: 20),
            ),
          ),
        ),
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
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.04), width: 0.8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: user?.avatarUrl?.isNotEmpty == true
                ? NetworkImage(user!.avatarUrl!)
                : null,
            backgroundColor: lc.primaryColor.withValues(alpha: 0.15),
            child: user?.avatarUrl?.isEmpty != false
                ? Text(user?.name[0] ?? '?', style: GoogleFonts.orbitron(
                    color: lc.primaryColor, fontSize: 13, fontWeight: FontWeight.w900))
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
                      color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                    const SizedBox(width: 8),
                    Text(
                      _formatTime(comment.createdAt),
                      style: GoogleFonts.ibmPlexMono(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  comment.data,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white.withValues(alpha: 0.85),
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

class _RelatedVideosSidebar extends StatelessWidget {
  final WatchController controller;
  final LayoutController lc;
  
  const _RelatedVideosSidebar({required this.controller, required this.lc});
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
          ),
          child: Row(
            children: [
              Icon(Icons.playlist_play_rounded, color: lc.primaryColor, size: 24),
              const SizedBox(width: 12),
              Text(
                'RELATED VIDEOS',
                style: GoogleFonts.orbitron(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
        
        Expanded(
          child: Obx(() {
            if (controller.relatedVideos.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.video_library_outlined, size: 50, color: Colors.white.withValues(alpha: 0.08)),
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
              physics: const BouncingScrollPhysics(),
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

class _RelatedVideoCard extends StatefulWidget {
  final PostModel video;
  final LayoutController lc;
  const _RelatedVideoCard({required this.video, required this.lc});

  @override
  State<_RelatedVideoCard> createState() => _RelatedVideoCardState();
}

class _RelatedVideoCardState extends State<_RelatedVideoCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.03 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: GestureDetector(
          onTap: () => Get.toNamed('/watch/${widget.video.id}'),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _isHovered ? Colors.white.withValues(alpha: 0.06) : Colors.white.withValues(alpha: 0.02),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _isHovered ? widget.lc.primaryColor.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.05),
                width: 0.8,
              ),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: widget.lc.primaryColor.withValues(alpha: 0.1),
                        blurRadius: 8,
                      )
                    ]
                  : [],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 110,
                  height: 62,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.black,
                    image: widget.video.thumbnail.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(widget.video.thumbnail),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: widget.video.thumbnail.isEmpty
                      ? Icon(Icons.play_circle_outline, color: widget.lc.primaryColor.withValues(alpha: 0.5), size: 28)
                      : Stack(
                          children: [
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  gradient: LinearGradient(
                                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.5)],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                            ),
                            Center(
                              child: Icon(Icons.play_circle_filled, color: Colors.white, size: 28),
                            ),
                          ],
                        ),
                ),
                
                const SizedBox(width: 12),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.video.name,
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${_formatNumber(widget.video.views)} views',
                        style: GoogleFonts.ibmPlexMono(
                          color: Colors.white.withValues(alpha: 0.55),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
