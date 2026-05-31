import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:photo_view/photo_view.dart';

import '../../../data/models/comment_model.dart';
import '../../../data/models/post_model.dart';
import '../../../data/models/user_model.dart';
import '../controllers/watch_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../layout/controllers/layout_controller.dart';

/// PROFESSIONAL IMAGE VIEWER LAYOUT
/// - Large image viewer (70-80% screen) with zoom/pan/rotate
/// - Thumbnail sidebar on right for quick navigation
/// - Metadata panel below image
/// - Action buttons (download, share, favorite, edit)
class ImageViewerTablet extends GetView<WatchController> {
  const ImageViewerTablet({super.key});
  
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
                Text('LOADING IMAGE', style: GoogleFonts.orbitron(
                  color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 3)),
              ],
            ),
          );
        }
        
        final post = controller.post.value;
        if (post == null) return const Center(child: Text('Image not found', style: TextStyle(color: Colors.white38)));
        
        return _ImageViewerLayout(controller: controller, post: post, lc: lc);
      }),
    );
  }
}


/// MAIN LAYOUT: Image viewer + Thumbnail sidebar
class _ImageViewerLayout extends StatefulWidget {
  final WatchController controller;
  final PostModel post;
  final LayoutController lc;
  
  const _ImageViewerLayout({required this.controller, required this.post, required this.lc});
  
  @override
  State<_ImageViewerLayout> createState() => _ImageViewerLayoutState();
}

class _ImageViewerLayoutState extends State<_ImageViewerLayout> {
  final _rotationAngle = 0.0.obs;
  final _showMetadata = true.obs;
  final _showSidebar = true.obs;
  
  void _rotate() {
    _rotationAngle.value = (_rotationAngle.value + 90) % 360;
  }
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // LEFT: Main content (Image + Metadata + Comments)
        Expanded(
          child: Column(
            children: [
              // Image viewer section
              Expanded(
                child: Container(
                  color: Colors.black,
                  child: Stack(
                    children: [
                      // Image viewer with zoom/pan/rotate - fills available space
                      Positioned.fill(
                        child: Center(
                          child: Obx(() => Transform.rotate(
                            angle: _rotationAngle.value * 3.14159 / 180,
                            child: PhotoView(
                              imageProvider: NetworkImage(widget.post.url),
                              backgroundDecoration: const BoxDecoration(color: Colors.black),
                              minScale: PhotoViewComputedScale.contained * 0.5,
                              maxScale: PhotoViewComputedScale.covered * 4,
                              initialScale: PhotoViewComputedScale.contained,
                              heroAttributes: PhotoViewHeroAttributes(tag: widget.post.id ?? ''),
                            ),
                          )),
                        ),
                      ),
                      
                      // Top controls
                      Positioned(
                        top: 16, left: 16, right: 16,
                        child: SafeArea(
                          child: Row(
                            children: [
                              // Back button
                              _ControlButton(
                                icon: Icons.arrow_back_rounded,
                                onTap: () => Get.back(),
                                tooltip: 'Back',
                              ),
                              
                              const Spacer(),
                              
                              // Rotate button
                              _ControlButton(
                                icon: Icons.rotate_right_rounded,
                                onTap: _rotate,
                                tooltip: 'Rotate',
                              ),
                              
                              const SizedBox(width: 8),
                              
                              // Fullscreen button
                              _ControlButton(
                                icon: Icons.fullscreen_rounded,
                                onTap: () {},
                                tooltip: 'Fullscreen',
                              ),
                              
                              const SizedBox(width: 8),
                              
                              // Toggle metadata
                              Obx(() => _ControlButton(
                                icon: _showMetadata.value ? Icons.info : Icons.info_outline,
                                onTap: () => _showMetadata.value = !_showMetadata.value,
                                tooltip: 'Info',
                                isActive: _showMetadata.value,
                              )),
                              
                              const SizedBox(width: 8),
                              
                              // Toggle sidebar
                              Obx(() => _ControlButton(
                                icon: _showSidebar.value ? Icons.chevron_right_rounded : Icons.chevron_left_rounded,
                                onTap: () => _showSidebar.value = !_showSidebar.value,
                                tooltip: _showSidebar.value ? 'Hide Gallery' : 'Show Gallery',
                                isActive: !_showSidebar.value,
                              )),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Metadata and comments section
              Obx(() => _showMetadata.value
                ? Expanded(
                    child: Container(
                      color: const Color(0xFF0A0A0F),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _ImageMetadataPanel(controller: widget.controller, post: widget.post, lc: widget.lc),
                            const SizedBox(height: 16),
                            _CommentsSection(controller: widget.controller, lc: widget.lc),
                          ],
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink()),
            ],
          ),
        ),
        
        // RIGHT: Thumbnail sidebar (collapsible)
        Obx(() => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          width: _showSidebar.value ? 280 : 0,
          decoration: BoxDecoration(
            color: const Color(0xFF12121A),
            border: _showSidebar.value
                ? Border(left: BorderSide(color: Colors.white.withOpacity(0.05)))
                : null,
          ),
          child: _showSidebar.value
              ? _ThumbnailSidebar(controller: widget.controller, lc: widget.lc)
              : const SizedBox.shrink(),
        )),
      ],
    );
  }
}


class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  final bool isActive;
  
  const _ControlButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
    this.isActive = false,
  });
  
  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: isActive ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
        ),
      ),
    );
  }
}


/// IMAGE METADATA PANEL - Title, description, artist, stats, actions
class _ImageMetadataPanel extends StatelessWidget {
  final WatchController controller;
  final PostModel post;
  final LayoutController lc;
  
  const _ImageMetadataPanel({required this.controller, required this.post, required this.lc});
  
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
          
          // Metadata grid
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _MetadataChip(
                icon: Icons.calendar_today_rounded,
                label: 'Created',
                value: _formatDate(post.createdAt),
                color: Colors.orange,
              ),
              _MetadataChip(
                icon: Icons.remove_red_eye_rounded,
                label: 'Views',
                value: _formatNumber(post.views),
                color: Colors.cyan,
              ),
              if (post.fileType != null)
                _MetadataChip(
                  icon: Icons.image_rounded,
                  label: 'Format',
                  value: post.fileType!.toUpperCase(),
                  color: lc.primaryColor,
                ),
              _MetadataChip(
                icon: Icons.storage_rounded,
                label: 'Size',
                value: 'N/A',
                color: Colors.purple,
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Action buttons row
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              Obx(() => _ActionButton(
                icon: controller.isLiked.value ? Icons.favorite : Icons.favorite_border,
                label: '${_formatNumber(controller.likeCount.value)} Likes',
                onTap: controller.toggleLike,
                color: Colors.pink,
                isActive: controller.isLiked.value,
              )),
              _ActionButton(
                icon: Icons.download_rounded,
                label: 'Download',
                onTap: () {},
                color: Colors.green,
              ),
              _ActionButton(
                icon: Icons.share_rounded,
                label: 'Share',
                onTap: () {},
                color: Colors.blue,
              ),
              _ActionButton(
                icon: Icons.bookmark_border_rounded,
                label: 'Favorite',
                onTap: () {},
                color: Colors.amber,
              ),
              _ActionButton(
                icon: Icons.edit_rounded,
                label: 'Edit',
                onTap: () {},
                color: Colors.deepPurple,
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
    return '${date.day}/${date.month}/${date.year}';
  }
}


class _MetadataChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  
  const _MetadataChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label.toUpperCase(),
                style: GoogleFonts.ibmPlexMono(
                  color: color,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
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


/// THUMBNAIL SIDEBAR - For gallery navigation
class _ThumbnailSidebar extends StatelessWidget {
  final WatchController controller;
  final LayoutController lc;
  
  const _ThumbnailSidebar({required this.controller, required this.lc});
  
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
              Icon(Icons.collections_rounded, color: lc.primaryColor, size: 24),
              const SizedBox(width: 12),
              Text(
                'GALLERY',
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
        
        // Thumbnails grid
        Expanded(
          child: Obx(() {
            if (controller.relatedVideos.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image_outlined, size: 60, color: Colors.white.withOpacity(0.1)),
                      const SizedBox(height: 16),
                      Text('No other images', style: GoogleFonts.plusJakartaSans(
                        color: Colors.white38, fontSize: 13)),
                    ],
                  ),
                ),
              );
            }
            
            return GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: controller.relatedVideos.length,
              itemBuilder: (context, index) {
                final image = controller.relatedVideos[index];
                final isCurrent = image.id == controller.post.value?.id;
                return _ThumbnailCard(image: image, lc: lc, isCurrent: isCurrent);
              },
            );
          }),
        ),
      ],
    );
  }
}


class _ThumbnailCard extends StatelessWidget {
  final PostModel image;
  final LayoutController lc;
  final bool isCurrent;
  
  const _ThumbnailCard({
    required this.image,
    required this.lc,
    required this.isCurrent,
  });
  
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isCurrent ? null : () => Get.toNamed('/view/${image.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isCurrent ? lc.primaryColor : Colors.white.withOpacity(0.1),
              width: isCurrent ? 3 : 1,
            ),
            image: image.thumbnail.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(image.thumbnail),
                    fit: BoxFit.cover,
                  )
                : null,
            color: image.thumbnail.isEmpty ? Colors.black : null,
          ),
          child: image.thumbnail.isEmpty
              ? Icon(Icons.image_outlined, color: lc.primaryColor.withOpacity(0.5), size: 40)
              : isCurrent
                  ? Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: lc.primaryColor.withOpacity(0.3),
                      ),
                      child: Center(
                        child: Icon(Icons.check_circle, color: lc.primaryColor, size: 32),
                      ),
                    )
                  : null,
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
