import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/draw_controller.dart';
import 'studio_widgets.dart';

class StudioStatusBar extends StatelessWidget {
  final DrawController controller;
  const StudioStatusBar({super.key, required this.controller});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 28,
      decoration: const BoxDecoration(color: DS.bg, border: Border(top: BorderSide(color: DS.border))),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const PulsingDot(color: DS.mint, size: 6),
          const SizedBox(width: 8),
          const Text('LIVE', style: TextStyle(color: DS.mint, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 2, fontFamily: 'monospace')),
          _divider(),
          Obx(() {
            final x = controller.cursorPosition.value?.dx.toInt() ?? 0;
            final y = controller.cursorPosition.value?.dy.toInt() ?? 0;
            return _monoText('X: ${x.toString().padLeft(4)} Y: ${y.toString().padLeft(4)}');
          }),
          _divider(),
          Obx(() => _badge(controller.currentToolTooltip.toUpperCase(), DS.violet)),
          _divider(),
          Obx(() => _monoText('⌀ ${controller.selectedWidth.value.toInt()}px')),
          _divider(),
          Obx(() => _monoText('α ${(controller.selectedOpacity.value * 100).toInt()}%')),
          const Spacer(),
          _zoomControls(),
          _divider(),
          _monoText('1920 × 1080'),
          _divider(),
          Obx(() => _badge('${controller.currentLayerIndex.value + 1} LỚP', DS.gold)),
          _divider(),
          Obx(() => _badge('${controller.frames.length} FRAME', DS.cyan)),
        ],
      ),
    );
  }
  Widget _divider() => Container(width: 1, height: 14, margin: const EdgeInsets.symmetric(horizontal: 10), color: DS.border);
  Widget _monoText(String text) => Text(text, style: const TextStyle(color: DS.textDim, fontSize: 10, fontFamily: 'monospace', fontWeight: FontWeight.w500));
  Widget _badge(String text, Color color) => Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: DS.r4, border: Border.all(color: color.withValues(alpha: 0.25))), child: Text(text, style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1)));
  Widget _zoomControls() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _zoomBtn(Icons.remove_rounded, controller.zoomOut),
        const SizedBox(width: 4),
        Obx(() {
          final scale = (controller.transformationController.value.getMaxScaleOnAxis() * 100).toInt();
          return SizedBox(width: 40, child: Text('$scale%', textAlign: TextAlign.center, style: const TextStyle(color: DS.text, fontSize: 10, fontWeight: FontWeight.w700, fontFamily: 'monospace')));
        }),
        const SizedBox(width: 4),
        _zoomBtn(Icons.add_rounded, controller.zoomIn),
        const SizedBox(width: 6),
        _zoomBtn(Icons.fit_screen_rounded, controller.resetZoom),
      ],
    );
  }
  Widget _zoomBtn(IconData icon, VoidCallback onTap) {
    return InkWell(onTap: onTap, borderRadius: DS.r4, child: Container(width: 20, height: 20, alignment: Alignment.center, child: Icon(icon, color: DS.textDim, size: 13)));
  }
}
