import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/draw_controller.dart';
import '../dialogs/show_color_picker.dart';
import 'studio_widgets.dart';
class StudioSidebarProperties extends StatelessWidget {
  final DrawController controller;
  const StudioSidebarProperties({super.key, required this.controller});
  static const _palette = [
    Color(0xFF000000),
    Color(0xFFFFFFFF),
    Color(0xFFEF4444),
    Color(0xFFF97316),
    Color(0xFFEAB308),
    Color(0xFF22C55E),
    Color(0xFF06B6D4),
    Color(0xFF3B82F6),
    Color(0xFF8B5CF6),
    Color(0xFFEC4899),
    Color(0xFF92400E),
    Color(0xFF6B7280),
    Color(0xFF0F172A),
    Color(0xFFF59E0B),
    Color(0xFF10B981),
    Color(0xFF6366F1),
    Color(0xFFFF6B9D),
    Color(0xFF00E5FF),
    Color(0xFFF5A623),
    Color(0xFF00D49F),
    Color(0xFF7C5CFC),
    Color(0xFF2D2D46),
    Color(0xFFFF2D55),
    Color(0xFFB39DFB),
  ];
  static const _blendModes = [
    'Normal',
    'Multiply',
    'Screen',
    'Overlay',
    'Darken',
    'Lighten',
    'Dodge',
    'Burn',
    'Hard Lt',
    'Soft Lt',
  ];
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sectionLabel('MÀU SẮC', accent: DS.crimson),
          _colorPreview(context),
          const SizedBox(height: 12),
          _quickPalette(),
          const SizedBox(height: 16),
          _recentColors(),
          const SizedBox(height: 20),
          sectionLabel('BÚT VẼ', accent: DS.violet),
          StudioSlider(
            'Cỡ nét',
            controller.selectedWidth,
            1,
            100,
            accent: DS.violet,
            onChanged: controller.changeWidth,
          ),
          StudioSlider(
            'Opacity',
            controller.selectedOpacity,
            0,
            1,
            isPercent: true,
            accent: DS.cyan,
            onChanged: controller.changeOpacity,
          ),
          StudioSlider(
            'Cứng',
            controller.selectedHardness,
            0,
            1,
            isPercent: true,
            accent: DS.gold,
            onChanged: (v) => controller.selectedHardness.value = v,
          ),
          StudioSlider(
            'Gian cách',
            controller.selectedSpacing,
            1,
            50,
            accent: DS.mint,
            onChanged: (v) => controller.selectedSpacing.value = v,
          ),
          StudioSlider(
            'Scatter',
            controller.selectedScatter,
            0,
            50,
            accent: DS.rose,
            onChanged: (v) => controller.selectedScatter.value = v,
          ),
          const SizedBox(height: 20),
          sectionLabel('TÙY CHỌN', accent: DS.cyan),
          _smoothingRow(),
          _stabilizerRow(),
          const SizedBox(height: 20),
          sectionLabel('CHẾ ĐỘ PHA', accent: DS.gold),
          _blendGrid(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
  Widget _colorPreview(BuildContext context) {
    return GestureDetector(
      onTap: () => showColorPicker(context, controller),
      child: Obx(() {
        final c = controller.selectedColor.value;
        final hex =
            '#${c.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase().substring(2)}';
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: c.withValues(alpha: 0.06),
            borderRadius: DS.r12,
            border: Border.all(color: c.withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: c,
                  borderRadius: DS.r10,
                  boxShadow: DS.glowShadow(c, radius: 14),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hex,
                      style: TextStyle(
                        color: DS.text,
                        fontSize: 13,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'Nhấn để chọn màu',
                      style: TextStyle(color: DS.textDim, fontSize: 10),
                    ),
                  ],
                ),
              ),
              Icon(Icons.colorize_rounded, color: DS.textDim, size: 16),
            ],
          ),
        );
      }),
    );
  }
  Widget _quickPalette() {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children:
          _palette.map((c) {
            return Obx(() {
              final isSel =
                  controller.selectedColor.value.toARGB32() == c.toARGB32();
              return GestureDetector(
                onTap: () {
                  controller.changeColor(c);
                  if (!controller.recentColors.contains(c)) {
                    controller.recentColors.insert(0, c);
                    if (controller.recentColors.length > 8) {
                      controller.recentColors.removeLast();
                    }
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: c,
                    borderRadius: DS.r6,
                    border: Border.all(
                      color: isSel ? Colors.white : DS.border,
                      width: isSel ? 2 : 1,
                    ),
                    boxShadow: isSel ? DS.glowShadow(c, radius: 10) : null,
                  ),
                  child:
                      isSel
                          ? const Icon(
                            Icons.check_rounded,
                            color: Colors.white,
                            size: 13,
                          )
                          : null,
                ),
              );
            });
          }).toList(),
    );
  }
  Widget _recentColors() {
    return Obx(() {
      if (controller.recentColors.isEmpty) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'GẦN ĐÂY',
            style: TextStyle(
              color: DS.textDim,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children:
                controller.recentColors.take(8).map((c) {
                  return GestureDetector(
                    onTap: () => controller.changeColor(c),
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: c,
                        borderRadius: DS.r6,
                        border: Border.all(color: DS.border),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      );
    });
  }
  Widget _smoothingRow() {
    return Obx(
      () => _toggleRow(
        'Làm mịn nét vẽ',
        Icons.auto_fix_high_rounded,
        controller.isSmoothingEnabled.value,
        DS.cyan,
        () => controller.isSmoothingEnabled.toggle(),
      ),
    );
  }
  Widget _stabilizerRow() {
    return Obx(
      () => _toggleRow(
        'Bộ ổn định nét',
        Icons.gesture_rounded,
        controller.isStabilizerEnabled.value,
        DS.rose,
        () => controller.isStabilizerEnabled.toggle(),
      ),
    );
  }
  Widget _toggleRow(
    String label,
    IconData icon,
    bool value,
    Color accent,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: value ? accent.withValues(alpha: 0.08) : DS.card,
          borderRadius: DS.r12,
          border: Border.all(
            color: value ? accent.withValues(alpha: 0.3) : DS.border,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 15, color: value ? accent : DS.textDim),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: value ? DS.text : DS.textDim,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            _miniSwitch(value, accent),
          ],
        ),
      ),
    );
  }
  Widget _miniSwitch(bool value, Color accent) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 32,
      height: 18,
      decoration: BoxDecoration(
        color: value ? accent : DS.border,
        borderRadius: DS.r50,
      ),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 200),
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 14,
          height: 14,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
  Widget _blendGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3.2,
        mainAxisSpacing: 5,
        crossAxisSpacing: 5,
      ),
      itemCount: _blendModes.length,
      itemBuilder: (_, i) {
        return Obx(() {
          final isSel = controller.selectedBlendModeIndex.value == (i + 3);
          return GestureDetector(
            onTap: () => controller.selectedBlendModeIndex.value = i + 3,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              decoration: BoxDecoration(
                color: isSel ? DS.violet.withValues(alpha: 0.14) : DS.card,
                borderRadius: DS.r8,
                border: Border.all(
                  color: isSel ? DS.violet.withValues(alpha: 0.5) : DS.border,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                _blendModes[i].toUpperCase(),
                style: TextStyle(
                  color: isSel ? DS.text : DS.textDim,
                  fontSize: 9,
                  fontWeight: isSel ? FontWeight.w900 : FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          );
        });
      },
    );
  }
}