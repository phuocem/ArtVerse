import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:artverse/app/data/models/post_model.dart';
import '../../modules/layout/controllers/layout_controller.dart';
import '../../core/theme/app_colors.dart';

class GlobalArtworkCard extends StatefulWidget {
  final PostModel post;
  final VoidCallback onTap;
  const GlobalArtworkCard({
    super.key,
    required this.post,
    required this.onTap,
  });

  @override
  State<GlobalArtworkCard> createState() => _GlobalArtworkCardState();
}

class _GlobalArtworkCardState extends State<GlobalArtworkCard> {
  bool _isHovered = false;
  double get _aspectRatio => 1.1;

  String _getTagText() {
    if (widget.post.isVideo) return 'Video';
    switch (widget.post.category) {
      case 'art_photos':
        return 'Photo';
      case 'illustrations':
        return 'Artwork';
      case 'animations':
        return 'Anim';
      default:
        return widget.post.fileType ?? 'Art';
    }
  }

  @override
  Widget build(BuildContext context) {
    final lc = Get.find<LayoutController>();
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isHovered ? 1.03 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: lc.cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isHovered
                    ? lc.primaryColor.withValues(alpha: 0.3)
                    : AppColors.border,
                width: 0.8,
              ),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: lc.primaryColor.withValues(alpha: 0.12),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      )
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      )
                    ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: AspectRatio(
                    aspectRatio: _aspectRatio,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: CachedNetworkImage(
                            imageUrl: widget.post.thumbnail,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: lc.textColor.withValues(alpha: 0.02),
                              child: Center(
                                child: Icon(Icons.image_rounded, size: 24, color: lc.textColor.withValues(alpha: 0.05)),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: lc.cardColor,
                              child: Icon(Icons.broken_image_rounded, size: 24, color: lc.textColor.withValues(alpha: 0.05)),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 300),
                            opacity: _isHovered ? 1.0 : 0.0,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.5),
                                    Colors.transparent,
                                  ],
                                  stops: const [0.0, 0.4],
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Floating Glassmorphic Tag
                        Positioned(
                          top: 8,
                          left: 8,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                color: Colors.black.withValues(alpha: 0.35),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      widget.post.isVideo ? Icons.play_arrow_rounded : Icons.image_rounded,
                                      size: 10,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _getTagText().toUpperCase(),
                                      style: GoogleFonts.ibmPlexMono(
                                        color: Colors.white,
                                        fontSize: 8,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (_isHovered) ...[
                          Positioned(
                            bottom: 10, right: 10,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: lc.primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: Center(child: Icon(Icons.arrow_outward_rounded, size: 12, color: lc.onPrimaryColor)),
                            ).animate().scale(duration: 200.ms, curve: Curves.easeOutBack),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, left: 2, right: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 28, height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: lc.textColor.withValues(alpha: 0.05),
                          border: Border.all(color: lc.primaryColor.withValues(alpha: 0.15), width: 1),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: widget.post.user?.avatarUrl != null && widget.post.user!.avatarUrl!.isNotEmpty
                              ? CachedNetworkImage(imageUrl: widget.post.user!.avatarUrl!, fit: BoxFit.cover)
                              : Icon(Icons.person_outline_rounded, size: 14, color: lc.textColor.withValues(alpha: 0.3)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.post.name.isNotEmpty ? widget.post.name : "Untitled",
                              style: GoogleFonts.plusJakartaSans(color: lc.textColor, fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: -0.2),
                              maxLines: 1, 
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 1),
                            Text(
                              widget.post.user?.name ?? 'Unknown Artist',
                              style: GoogleFonts.plusJakartaSans(color: lc.textColor.withValues(alpha: 0.4), fontSize: 10, fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.favorite_rounded, size: 10, color: AppColors.pink),
                          const SizedBox(width: 3),
                          Text(
                            _formatCount(widget.post.likesCount), 
                            style: GoogleFonts.ibmPlexMono(color: lc.textColor.withValues(alpha: 0.5), fontSize: 10, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.visibility_rounded, size: 10, color: lc.primaryColor),
                          const SizedBox(width: 3),
                          Text(
                            _formatCount(widget.post.views), 
                            style: GoogleFonts.ibmPlexMono(color: lc.textColor.withValues(alpha: 0.5), fontSize: 10, fontWeight: FontWeight.w700),
                          ),
                        ],
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

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}m';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}k';
    return count.toString();
  }
}
