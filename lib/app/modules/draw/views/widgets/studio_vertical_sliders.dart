import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/draw_controller.dart';
import 'studio_widgets.dart';

class StudioVerticalSliders extends StatelessWidget {
  final DrawController controller;
  const StudioVerticalSliders({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60,
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: DS.border)),
        color: DS.surface,
      ),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 0),
      child: Column(
        children: [
          Expanded(child: _vertControl(
            icon: Icons.line_weight_rounded,
            label: 'SIZE',
            value: controller.selectedWidth,
            min: 1.0, max: 200.0,
            accent: DS.violet,
            displayFn: (v) => '${v.toInt()}',
          )),
          const SizedBox(height: 12),
          _orbBtn(Icons.undo_rounded, controller.undo, tip: 'Undo', accent: DS.textDim),
          const SizedBox(height: 8),
          _orbBtn(Icons.redo_rounded, controller.redo, tip: 'Redo', accent: DS.textDim),
          const SizedBox(height: 12),
          Expanded(child: _vertControl(
            icon: Icons.opacity_rounded,
            label: 'OPAC',
            value: controller.selectedOpacity,
            min: 0.0, max: 1.0,
            accent: DS.cyan,
            displayFn: (v) => '${(v * 100).toInt()}',
          )),
        ],
      ),
    );
  }

  Widget _vertControl({
    required IconData icon,
    required String label,
    required RxDouble value,
    required double min,
    required double max,
    required Color accent,
    required String Function(double) displayFn,
  }) {
    return Column(
      children: [
        Icon(icon, size: 14, color: accent.withValues(alpha: 0.7)),
        const SizedBox(height: 4),
        Expanded(
          child: RotatedBox(
            quarterTurns: 3,
            child: Obx(() => SliderTheme(
              data: SliderThemeData(
                trackHeight: 14,
                activeTrackColor: accent.withValues(alpha: 0.9),
                inactiveTrackColor: DS.card,
                thumbColor: Colors.white,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9, elevation: 6),
                overlayColor: accent.withValues(alpha: 0.1),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
                trackShape: const RoundedRectSliderTrackShape(),
              ),
              child: Slider(
                value: value.value.clamp(min, max),
                min: min, max: max,
                onChanged: (v) => value.value = v,
              ),
            )),
          ),
        ),
        const SizedBox(height: 4),
        Obx(() => Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(color: accent.withValues(alpha: 0.1), borderRadius: DS.r8),
          child: Text(
            displayFn(value.value),
            style: TextStyle(color: accent, fontSize: 9, fontWeight: FontWeight.w900, fontFamily: 'monospace'),
          ),
        )),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: DS.textDim, fontSize: 7, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
      ],
    );
  }

  Widget _orbBtn(IconData icon, VoidCallback onTap, {required String tip, required Color accent}) {
    return Tooltip(
      message: tip,
      child: InkWell(
        onTap: onTap,
        borderRadius: DS.r50,
        child: Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: DS.card,
            shape: BoxShape.circle,
            border: Border.all(color: DS.border),
          ),
          child: Icon(icon, size: 16, color: DS.textDim),
        ),
      ),
    );
  }
}
