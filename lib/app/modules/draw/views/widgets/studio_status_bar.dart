import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/draw_controller.dart';
import 'studio_widgets.dart';

class StudioStatusBar extends StatelessWidget {
  final DrawController controller;
  const StudioStatusBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: 12,
      opacity: 0.05,
      blur: 15,
      border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 0.8),
      child: SizedBox(
        height: 28,
        child: Row(
          children: [
            const SizedBox(width: 12),
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
            Obx(() => _badge(
                'L${controller.currentLayerIndex.value + 1}', DS.gold)),
            const SizedBox(width: 4),
            Obx(() =>
                _badge('F${controller.currentFrameIndex.value + 1}', DS.cyan)),

            // Horizontal Sliders and Undo/Redo integrated from Image 1!
            _div(),
            Obx(() => _miniActionBtn(
                  Icons.undo_rounded,
                  controller.undoStack.isNotEmpty,
                  controller.undo,
                  'Hoàn tác',
                )),
            const SizedBox(width: 4),
            Obx(() => _miniActionBtn(
                  Icons.redo_rounded,
                  controller.redoStack.isNotEmpty,
                  controller.redo,
                  'Làm lại',
                )),
            _div(),
            _horizontalSlider(
              icon: Icons.line_weight_rounded,
              value: controller.selectedWidth,
              min: 1.0,
              max: 100.0,
              color: DS.violet,
              displayFn: (v) => '${v.toInt()}',
              onChanged: controller.changeWidth,
            ),
            _div(),
            _horizontalSlider(
              icon: Icons.opacity_rounded,
              value: controller.selectedOpacity,
              min: 0.0,
              max: 1.0,
              color: DS.cyan,
              displayFn: (v) => '${(v * 100).toInt()}%',
              onChanged: controller.changeOpacity,
            ),
            _div(),
            _horizontalSlider(
              icon: Icons.lens_blur_rounded,
              value: controller.selectedHardness,
              min: 0.0,
              max: 1.0,
              color: DS.gold,
              displayFn: (v) => '${(v * 100).toInt()}%',
              onChanged: (v) => controller.selectedHardness.value = v,
            ),

            const Spacer(),
            _zoomControls(),
            _div(),
            _mono('1920×1080'),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }

  Widget _horizontalSlider({
    required IconData icon,
    required RxDouble value,
    required double min,
    required double max,
    required Color color,
    required String Function(double) displayFn,
    required ValueChanged<double> onChanged,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color.withValues(alpha: 0.8)),
        const SizedBox(width: 6),
        Obx(() => SizedBox(
              width: 28,
              child: Text(
                displayFn(value.value),
                style: TextStyle(
                  color: color,
                  fontSize: 9,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                ),
              ),
            )),
        SizedBox(
          width: 80,
          height: 14,
          child: Obx(() => SliderTheme(
                data: SliderThemeData(
                  trackHeight: 3,
                  activeTrackColor: color.withValues(alpha: 0.8),
                  inactiveTrackColor: DS.border.withValues(alpha: 0.3),
                  thumbColor: Colors.white,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                  overlayColor: color.withValues(alpha: 0.1),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
                ),
                child: Slider(
                  value: value.value.clamp(min, max),
                  min: min,
                  max: max,
                  onChanged: onChanged,
                ),
              )),
        ),
      ],
    );
  }

  Widget _miniActionBtn(
      IconData icon, bool enabled, VoidCallback onTap, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(4),
        child: Opacity(
          opacity: enabled ? 1.0 : 0.4,
          child: Container(
            padding: const EdgeInsets.all(4),
            child: Icon(icon, size: 14, color: DS.text),
          ),
        ),
      ),
    );
  }

  Widget _zoomControls() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _zBtn(Icons.remove_rounded, controller.zoomOut),
        const SizedBox(width: 4),
        Obx(() => _mono('${(controller.currentZoom.value * 100).toInt()}%')),
        const SizedBox(width: 4),
        _zBtn(Icons.add_rounded, controller.zoomIn),
        const SizedBox(width: 6),
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
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5)),
      );
}