import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../controllers/draw_controller.dart';
import '../../controllers/collab_controller.dart';
import 'studio_widgets.dart';
import 'sketcher.dart';

class StudioCanvas extends StatelessWidget {
  const StudioCanvas({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DrawController>();
    final Rx<Offset?> localCursor = Rx<Offset?>(null);
    return ExcludeSemantics(
      child: MouseRegion(
        onHover: (e) {
          final box = context.findRenderObject() as RenderBox;
          final pos = box.globalToLocal(e.position);
          localCursor.value = pos;
          controller.cursorPosition.value = pos;
        },
        onExit: (_) {
          localCursor.value = null;
          controller.cursorPosition.value = null;
        },
        child: InteractiveViewer(
          transformationController: controller.transformationController,
          minScale: 0.05,
          maxScale: 20.0,
          boundaryMargin: const EdgeInsets.all(800),
          panEnabled: true,
          scaleEnabled: true,
          child: GestureDetector(
            onPanStart: (d) {
              final box = context.findRenderObject() as RenderBox;
              final pt = box.globalToLocal(d.globalPosition);
              final vpIdx = controller.vpIndexAtPosition(pt);
              if (vpIdx != null && controller.perspectiveType.value != PerspectiveType.none) {
                controller.startVpDrag(vpIdx);
                return;
              }
              controller.startStroke(pt);
            },
            onPanUpdate: (d) {
              final box = context.findRenderObject() as RenderBox;
              final pt = box.globalToLocal(d.globalPosition);
              if (controller.draggingVpIndex.value >= 0) {
                controller.updateVpDrag(pt);
                return;
              }
              controller.addPoint(pt);
            },
            onPanEnd: (_) {
              if (controller.draggingVpIndex.value >= 0) {
                controller.endVpDrag();
                return;
              }
              controller.endStroke();
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(0),
              child: RepaintBoundary(
                key: controller.repaintKey,
                child: Obx(() => Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..scale(
                      controller.isMirroredHorizontal.value ? -1.0 : 1.0,
                      controller.isMirroredVertical.value   ? -1.0 : 1.0,
                      1.0,
                    ),
                  child: Container(
                    width:  DrawController.canvasSize.width,
                    height: DrawController.canvasSize.height,
                    color: controller.canvasBackgroundColor.value,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (controller.showGrid.value) _buildGrid(),
                        _buildReference(controller),
                        _buildMainStrokes(controller),
                        _buildActiveStroke(controller),
                        const _RemoteCursorsOverlay(),
                        _buildIsoGuide(controller, localCursor),
                        _buildBrushPreview(controller, localCursor),
                      ],
                    ),
                  ),
                )),
              ),
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildGrid() {
    return CustomPaint(painter: _GridPainter(), size: DrawController.canvasSize);
  }
  Widget _buildReference(DrawController ctrl) {
    return Obx(() {
      final path = ctrl.referenceImage.value;
      if (path == null) return const SizedBox.shrink();
      return Opacity(opacity: ctrl.referenceOpacity.value, child: Image.file(File(path), fit: BoxFit.contain, width: DrawController.canvasSize.width, height: DrawController.canvasSize.height));
    });
  }
  Widget _buildMainStrokes(DrawController ctrl) {
    return Obx(() => CustomPaint(painter: SketcherFull(mainLines: ctrl.currentBackgroundPicture.value != null ? [] : ctrl.currentLines, backgroundPicture: ctrl.currentBackgroundPicture.value, onionSkinLines: ctrl.getMultiOnionLines(), backgroundColor: Colors.transparent, opacity: 1.0, symmetryType: ctrl.symmetryType.value, perspectiveType: ctrl.perspectiveType.value, vanishingPoints: ctrl.vanishingPoints), size: DrawController.canvasSize));
  }
  Widget _buildActiveStroke(DrawController ctrl) {
    return Obx(() {
      final tempLine = ctrl.currentTempLine.value;
      if (tempLine == null) return const SizedBox.shrink();
      return CustomPaint(painter: SketcherFull(mainLines: const [], tempLine: tempLine, opacity: 1.0, symmetryType: ctrl.symmetryType.value, lazyPoint: ctrl.lazyPoint.value, actualPoint: ctrl.actualPoint.value, perspectiveType: ctrl.perspectiveType.value, vanishingPoints: ctrl.vanishingPoints), size: DrawController.canvasSize);
    });
  }
  Widget _buildIsoGuide(DrawController ctrl, Rx<Offset?> cursor) {
    return Obx(() {
      if (!ctrl.isIsometricSnapEnabled.value) return const SizedBox.shrink();
      final pos = cursor.value;
      if (pos == null) return const SizedBox.shrink();
      return CustomPaint(painter: _IsoCursorPainter(pos), size: DrawController.canvasSize);
    });
  }
  Widget _buildBrushPreview(DrawController ctrl, Rx<Offset?> cursor) {
    return Obx(() {
      final pos = cursor.value;
      if (pos == null) return const SizedBox.shrink();
      final size   = ctrl.selectedWidth.value;
      final opacity= ctrl.selectedOpacity.value;
      final color  = ctrl.selectedColor.value;
      final isErase= ctrl.selectedTool.value == ToolType.eraser;
      return Positioned(
        left: pos.dx - size / 2,
        top:  pos.dy - size / 2,
        child: IgnorePointer(
          child: Container(
            width: size, height: size,
            decoration: BoxDecoration(shape: BoxShape.circle, color: isErase ? Colors.white.withValues(alpha: 0.15) : color.withValues(alpha: opacity * 0.35), border: Border.all(color: isErase ? DS.textFaint : color.withValues(alpha: 0.8), width: 1.5), boxShadow: isErase ? null : DS.glowShadow(color, radius: size * 0.4)),
          ),
        ),
      );
    });
  }
}
class _RemoteCursorsOverlay extends StatelessWidget {
  const _RemoteCursorsOverlay();
  @override
  Widget build(BuildContext context) {
    try {
      final collab = Get.find<CollabController>();
      return Obx(() {
        if (!collab.isCollaborating.value) return const SizedBox.shrink();
        return Stack(
          children: collab.remoteCursors.entries.map((entry) {
            final userId = entry.key;
            final position = entry.value;
            final color = collab.memberColors[userId] ?? DS.violet;
            final member = collab.activeMembers.firstWhere((m) => m['id'] == userId, orElse: () => {'name': 'Artist'});
            return AnimatedPositioned(duration: const Duration(milliseconds: 150), curve: Curves.easeOut, left: position.dx - 8, top: position.dy - 8, child: _RemoteCursor(name: member['name'] as String, color: color));
          }).toList(),
        );
      });
    } catch (_) {
      return const SizedBox.shrink();
    }
  }
}
class _RemoteCursor extends StatefulWidget {
  final String name;
  final Color color;
  const _RemoteCursor({required this.name, required this.color});
  @override
  State<_RemoteCursor> createState() => _RemoteCursorState();
}
class _RemoteCursorState extends State<_RemoteCursor> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(width: 20, height: 20, decoration: BoxDecoration(shape: BoxShape.circle, color: widget.color.withValues(alpha: 0.15), boxShadow: DS.glowShadow(widget.color, radius: 10))),
              Icon(MdiIcons.brushVariant, size: 16, color: widget.color),
            ],
          ),
          const SizedBox(height: 4),
          Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3), decoration: BoxDecoration(color: widget.color, borderRadius: DS.r8, boxShadow: DS.glowShadow(widget.color, radius: 8)), child: Text(widget.name, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.3))),
        ],
      ),
    );
  }
}
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final major = Paint()..color = const Color(0xFF2A2A3A)..strokeWidth = 0.5;
    final minor = Paint()..color = const Color(0xFF1A1A26)..strokeWidth = 0.4;
    const step = 40.0;
    const bigStep = 200.0;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), x % bigStep == 0 ? major : minor);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), y % bigStep == 0 ? major : minor);
    }
  }
  @override
  bool shouldRepaint(_GridPainter _) => false;
}
class _IsoCursorPainter extends CustomPainter {
  final Offset center;
  const _IsoCursorPainter(this.center);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = DS.mint.withValues(alpha: 0.5)..strokeWidth = 1.0..style = PaintingStyle.stroke;
    const len = 40.0;
    final angles = [0.0, math.pi / 3, 2 * math.pi / 3, math.pi, 4 * math.pi / 3, 5 * math.pi / 3];
    for (final a in angles) {
      canvas.drawLine(center, center + Offset(math.cos(a) * len, math.sin(a) * len), paint);
    }
    canvas.drawCircle(center, 3, paint..style = PaintingStyle.fill..color = DS.mint.withValues(alpha: 0.7));
  }
  @override
  bool shouldRepaint(_IsoCursorPainter old) => old.center != center;
}
