import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/draw_controller.dart';
import 'studio_widgets.dart';
class StudioStatusBar extends StatelessWidget {
  final DrawController controller;
  const StudioStatusBar({super.key, required this.controller});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 26,
      decoration: BoxDecoration(
        color: DS.bg,
        border: Border(top: BorderSide(color: DS.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          PulsingDot(color: DS.mint, size: 6),
          const SizedBox(width: 6),
          Text('STUDIO',
              style: TextStyle(
                  color: DS.mint,
                  fontSize: 8,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  fontFamily: 'monospace')),
          _div(),
          Obx(() {
            final x = controller.cursorPosition.value?.dx.toInt() ?? 0;
            final y = controller.cursorPosition.value?.dy.toInt() ?? 0;
            return _mono('X:${x.toString().padLeft(4)} Y:${y.toString().padLeft(4)}');
          }),
          _div(),
          Obx(() => _badge(
              controller.currentToolTooltip.toUpperCase(), DS.violet)),
          _div(),
          Obx(() => _mono('⌀${controller.selectedWidth.value.toInt()}px')),
          _div(),
          Obx(() => _mono(
              'α${(controller.selectedOpacity.value * 100).toInt()}%')),
          _div(),
          Obx(() => _badge(
              'L${controller.currentLayerIndex.value + 1}', DS.gold)),
          const SizedBox(width: 4),
          Obx(() =>
              _badge('F${controller.currentFrameIndex.value + 1}', DS.cyan)),
          const Spacer(),
          _zoomControls(),
          _div(),
          _mono('1920×1080'),
        ],
      ),
    );
  }
  Widget _zoomControls() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _zBtn(Icons.remove_rounded, controller.zoomOut),
        const SizedBox(width: 2),
        ValueListenableBuilder<Matrix4>(
          valueListenable: controller.transformationController,
          builder: (context, matrix, _) {
            final scale = (matrix.getMaxScaleOnAxis() * 100).toInt();
            return GestureDetector(
              onTap: controller.resetZoom,
              child: Container(
                width: 44,
                alignment: Alignment.center,
                child: Text('$scale%',
                    style: TextStyle(
                        color: DS.text,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'monospace')),
              ),
            );
          },
        ),
        const SizedBox(width: 2),
        _zBtn(Icons.add_rounded, controller.zoomIn),
        const SizedBox(width: 4),
        _zBtn(Icons.fit_screen_rounded, controller.resetZoom),
      ],
    );
  }
  Widget _zBtn(IconData icon, VoidCallback onTap) => InkWell(
        onTap: onTap,
        borderRadius: DS.r4,
        child: Container(
          width: 18,
          height: 18,
          alignment: Alignment.center,
          child: Icon(icon, size: 12, color: DS.textDim),
        ),
      );
  Widget _div() => Container(
        width: 1,
        height: 14,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        color: DS.border,
      );
  Widget _mono(String text) => Text(text,
      style: TextStyle(
          color: DS.textDim,
          fontSize: 9.5,
          fontFamily: 'monospace',
          fontWeight: FontWeight.w500));
  Widget _badge(String text, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: DS.r4,
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Text(text,
            style: TextStyle(
                color: color,
                fontSize: 8,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8)),
      );
}