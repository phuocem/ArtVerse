import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:artverse/app/data/models/post_model.dart';
import '../../modules/layout/controllers/layout_controller.dart';
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
  double get _aspectRatio {
    if (widget.post.id == null) return 1.0;
    final hash = widget.post.id.hashCode;
    return 0.75 + (hash % 100) / 180.0;
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          transform: Matrix4.translationValues(0.0, _isHovered ? -4.0 : 0.0, 0.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: _isHovered ? lc.primaryColor.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.1),
                      blurRadius: _isHovered ? 24 : 10,
                      offset: Offset(0, _isHovered ? 12 : 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
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
                                    Colors.black.withValues(alpha: 0.6),
                                    Colors.transparent,
                                  ],
                                  stops: const [0.0, 0.4],
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (_isHovered) ...[
                          Positioned(
                            bottom: 12, right: 12,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: lc.primaryColor,
                                shape: BoxShape.circle,
                              ),
                              child: Center(child: Icon(Icons.arrow_outward_rounded, size: 14, color: lc.onPrimaryColor)),
                            ).animate().scale(duration: 200.ms, curve: Curves.easeOutBack),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16, left: 4, right: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: lc.textColor.withValues(alpha: 0.05),
                        border: Border.all(color: lc.textColor.withValues(alpha: 0.1), width: 1),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: widget.post.user?.avatarUrl != null && widget.post.user!.avatarUrl!.isNotEmpty
                            ? CachedNetworkImage(imageUrl: widget.post.user!.avatarUrl!, fit: BoxFit.cover)
                            : Icon(Icons.person_outline_rounded, size: 16, color: lc.textColor.withValues(alpha: 0.3)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.post.name.isNotEmpty ? widget.post.name : "Untitled",
                            style: GoogleFonts.plusJakartaSans(color: lc.textColor, fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: -0.2),
                            maxLines: 1, 
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.post.user?.name ?? 'Unknown Artist',
                            style: GoogleFonts.plusJakartaSans(color: lc.textColor.withValues(alpha: 0.4), fontSize: 11, fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.favorite_rounded, size: 12, color: lc.textColor.withValues(alpha: 0.25)),
                        const SizedBox(width: 4),
                        Text(_formatCount(widget.post.likesCount), 
                          style: GoogleFonts.plusJakartaSans(color: lc.textColor.withValues(alpha: 0.4), fontSize: 11, fontWeight: FontWeight.w800)),
                        const SizedBox(width: 10),
                        Icon(Icons.visibility_rounded, size: 12, color: lc.textColor.withValues(alpha: 0.25)),
                        const SizedBox(width: 4),
                        Text(_formatCount(widget.post.views), 
                          style: GoogleFonts.plusJakartaSans(color: lc.textColor.withValues(alpha: 0.4), fontSize: 11, fontWeight: FontWeight.w800)),
                      ],
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
  Widget _typeBadge(String label, LayoutController lc) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1), width: 0.5),
      ),
      child: Text(label, style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
    );
  }
  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}m';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}k';
    return count.toString();
  }
}
