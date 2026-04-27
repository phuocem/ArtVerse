import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';
import '../../../layout/controllers/layout_controller.dart';

class ProjectCard extends StatefulWidget {
  final String id;
  final String? imageUrl;
  final Uint8List? thumbnail;
  final String title;
  final String createdAt;
  final int frameCount;
  final bool isAnimation;
  final bool isFavorite;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onSync;
  final Function(bool)? onFavoriteChanged;

  const ProjectCard({
    super.key,
    required this.id,
    this.imageUrl,
    this.thumbnail,
    required this.title,
    required this.createdAt,
    required this.frameCount,
    this.isAnimation = false,
    this.isFavorite = false,
    this.onTap,
    this.onDelete,
    this.onSync,
    this.onFavoriteChanged,
  });

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard> {
  @override
  Widget build(BuildContext context) {
    final lc = Get.find<LayoutController>();
    
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        onSecondaryTap: () => _showContextMenu(context, lc),
        onLongPress: () => _showContextMenu(context, lc),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: lc.surfaceColor,
                  borderRadius: BorderRadius.circular(2), 
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05), width: 0.5),
                ),
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildThumbnail(lc),

                    if (widget.isAnimation)
                      Positioned.fill(
                        child: _VideoBackgroundPlayer(
                          key: ValueKey(widget.id),
                          assetPath: 'assets/video/complex_anim.mp4',
                          startAtSeconds: 1, 
                        ),
                      ),

                    _buildDarkGradientOverlay(),
  
                    Positioned(top: 12, left: 12, child: _buildTypeBadge()),
                    Positioned(bottom: 12, right: 12, child: _buildActionButtons(lc)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildProjectInfo(lc),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectInfo(LayoutController lc) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                _formatTimeAgo(),
                style: GoogleFonts.ibmPlexMono(
                  fontSize: 8,
                  fontWeight: FontWeight.w500,
                  color: Colors.white24,
                  letterSpacing: 1,
                ),
              ),
              const Spacer(),
              if (widget.isAnimation)
                Text(
                  'SEQUENCE',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 8,
                    fontWeight: FontWeight.w900,
                    color: lc.primaryColor.withValues(alpha: 0.4),
                    letterSpacing: 1,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnail(LayoutController lc) {
    if (widget.thumbnail != null) {
      return Hero(
        tag: 'project_${widget.id}',
        child: Image.memory(widget.thumbnail!, fit: BoxFit.cover, gaplessPlayback: true),
      );
    }
    return Container(
      color: Colors.white.withValues(alpha: 0.01),
      child: Center(
        child: widget.isAnimation 
          ? const SizedBox.shrink()
          : const Icon(
              Icons.edit_note_rounded,
              color: Colors.white10,
              size: 24,
            ),
      ),
    );
  }

  Widget _buildDarkGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.4),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.8),
        border: Border.all(color: Colors.white12),
      ),
      child: Text(
        (widget.isAnimation ? "ANIM" : "ART").toUpperCase(),
        style: GoogleFonts.ibmPlexMono(
          color: Colors.white,
          fontSize: 7,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildActionButtons(LayoutController lc) {
    return GestureDetector(
      onTap: () => widget.onFavoriteChanged?.call(!widget.isFavorite),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: widget.isFavorite ? Colors.white : Colors.black.withValues(alpha: 0.4),
          border: Border.all(color: Colors.white12),
          shape: BoxShape.circle,
        ),
        child: Icon(
          widget.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
          color: widget.isFavorite ? Colors.black : Colors.white24,
          size: 16,
        ),
      ),
    );
  }


  String _formatTimeAgo() {
    try {
      final date = DateTime.parse(widget.createdAt);
      final diff = DateTime.now().difference(date);
      if (diff.inDays > 30) return '${(diff.inDays / 30).floor()} MO AGO';
      if (diff.inDays > 7) return '${(diff.inDays / 7).floor()} W AGO';
      if (diff.inDays > 0) return '${diff.inDays} D AGO';
      if (diff.inHours > 0) return '${diff.inHours} H AGO';
      return 'JUST NOW';
    } catch (e) { return 'RECENTLY'; }
  }

  void _showContextMenu(BuildContext context, LayoutController lc) {
    showModalBottomSheet<void>(
      context: context, backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(24), padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: lc.isDark.value ? const Color(0xFF16161D) : Colors.white, borderRadius: BorderRadius.circular(32), border: Border.all(color: lc.textColor.withValues(alpha: 0.1))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.sync_rounded, color: lc.primaryColor),
              title: Text('CLOUD SYNC', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: lc.textColor, letterSpacing: 1)),
              onTap: () { widget.onSync?.call(); Get.back<void>(); },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
              title: const Text('DELETE PROJECT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.redAccent, letterSpacing: 1)),
              onTap: () { widget.onDelete?.call(); Get.back<void>(); },
            ),
          ],
        ),
      ),
    );
  }
}


class _VideoBackgroundPlayer extends StatefulWidget {
  final String assetPath;
  final int startAtSeconds;

  const _VideoBackgroundPlayer({
    super.key,
    required this.assetPath,
    this.startAtSeconds = 0,
  });

  
  static VideoPlayerController? _sharedController;
  static bool _isInitializing = false;

  static Future<void> _ensureInitialized(String path, int startAt) async {
    if (_sharedController != null || _isInitializing) return;
    _isInitializing = true;

    final controller = VideoPlayerController.asset(path);
    _sharedController = controller;

    await controller.initialize();
    await controller.setLooping(false);
    await controller.setVolume(0);
    await controller.seekTo(Duration(seconds: startAt));
    await controller.play();

    
    controller.addListener(() {
      final pos = controller.value.position;
      if (pos >= const Duration(seconds: 8)) {
        controller.seekTo(Duration(seconds: startAt));
        controller.play();
      }
    });

    _isInitializing = false;
  }

  @override
  State<_VideoBackgroundPlayer> createState() => _VideoBackgroundPlayerState();
}

class _VideoBackgroundPlayerState extends State<_VideoBackgroundPlayer> {
  bool _showVideo = false;

  @override
  void initState() {
    super.initState();
    _setupController();
  }

  Future<void> _setupController() async {
    
    await _VideoBackgroundPlayer._ensureInitialized(widget.assetPath, widget.startAtSeconds);
    
    
    if (mounted) {
      setState(() {
        _showVideo = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = _VideoBackgroundPlayer._sharedController;
    if (controller == null || !controller.value.isInitialized || !_showVideo) {
      return const SizedBox.shrink();
    }

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: _showVideo ? 1.0 : 0.0,
      child: FittedBox(
        fit: BoxFit.contain,
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          width: controller.value.size.width,
          height: controller.value.size.height,
          child: VideoPlayer(controller),
        ),
      ),
    );
  }
}

