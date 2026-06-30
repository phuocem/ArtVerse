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
      width: 52,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
      child: Column(
        children: [
          _VertSlider(
            icon: Icons.line_weight_rounded,
            label: 'SIZE',
            value: controller.selectedWidth,
            min: 1.0,
            max: 100.0,
            accent: DS.violet,
            displayFn: (v) => '${v.toInt()}',
            onChanged: controller.changeWidth,
          ),
          const SizedBox(height: 8),
          _OrbBtn(Icons.undo_rounded, controller.undo, tip: 'Undo'),
          const SizedBox(height: 6),
          _OrbBtn(Icons.redo_rounded, controller.redo, tip: 'Redo'),
          const SizedBox(height: 8),
          _VertSlider(
            icon: Icons.opacity_rounded,
            label: 'OPAC',
            value: controller.selectedOpacity,
            min: 0.0,
            max: 1.0,
            accent: DS.cyan,
            displayFn: (v) => '${(v * 100).toInt()}',
            onChanged: controller.changeOpacity,
          ),
          const SizedBox(height: 8),
          _VertSlider(
            icon: Icons.lens_blur_rounded,
            label: 'HARD',
            value: controller.selectedHardness,
            min: 0.0,
            max: 1.0,
            accent: DS.gold,
            displayFn: (v) => '${(v * 100).toInt()}',
            onChanged: (v) => controller.selectedHardness.value = v,
          ),
        ],
      ),
    );
  }
}
class _VertSlider extends StatelessWidget {
  final IconData icon;
  final String label;
  final RxDouble value;
  final double min;
  final double max;
  final Color accent;
  final String Function(double) displayFn;
  final ValueChanged<double> onChanged;
  const _VertSlider({
    required this.icon,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.accent,
    required this.displayFn,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 13, color: accent.withValues(alpha: 0.7)),
          const SizedBox(height: 4),
          Expanded(
            child: RotatedBox(
              quarterTurns: 3,
              child: Obx(() => SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 12,
                      activeTrackColor: accent.withValues(alpha: 0.85),
                      inactiveTrackColor: DS.card,
                      thumbColor: Colors.white,
                      thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 8, elevation: 4),
                      overlayColor: accent.withValues(alpha: 0.1),
                      overlayShape:
                          const RoundSliderOverlayShape(overlayRadius: 16),
                      trackShape: const RoundedRectSliderTrackShape(),
                    ),
                    child: Slider(
                      value: value.value.clamp(min, max),
                      min: min,
                      max: max,
                      onChanged: onChanged,
                    ),
                  )),
            ),
          ),
          const SizedBox(height: 4),
          Obx(() => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.1),
                    borderRadius: DS.r6),
                child: Text(displayFn(value.value),
                    style: TextStyle(
                        color: accent,
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'monospace')),
              )),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                  color: DS.textDim,
                  fontSize: 7,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5)),
        ],
      ),
    );
  }
}
class _OrbBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tip;
  const _OrbBtn(this.icon, this.onTap, {required this.tip});
  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tip,
      child: InkWell(
        onTap: onTap,
        borderRadius: DS.r50,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: DS.card,
            shape: BoxShape.circle,
            border: Border.all(color: DS.border),
          ),
          child: Icon(icon, size: 15, color: DS.textDim),
        ),
      ),
    );
  }
}