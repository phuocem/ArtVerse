import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/draw_controller.dart';
import '../../../../data/models/draw/drawn_line_model.dart';
import 'studio_widgets.dart';
import '../dialogs/show_color_picker.dart';
import '../dialogs/studio_perspective_sheet.dart';
import '../dialogs/studio_ai_dialog.dart';
class StudioLeftSidebar extends StatelessWidget {
  final DrawController controller;
  const StudioLeftSidebar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final c = controller;
    return GlassContainer(
      borderRadius: 20,
      opacity: 0.05,
      blur: 15,
      border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 0.8),
      child: SizedBox(
        width: 64,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  children: [
                    _grp('VẼ', DS.violet),
                    _brushTool(c, 'Chì', Icons.edit_rounded, BrushType.pencil, DS.violet),
                    _brushTool(c, 'Cọ', Icons.brush_rounded, BrushType.brush, DS.violet),
                    _brushTool(c, 'Phun', Icons.blur_on_rounded, BrushType.airbrush, DS.violet),
                    _brushTool(c, 'Mực', Icons.history_edu_rounded, BrushType.pen, DS.violet),
                    const SizedBox(height: 4),
                    _sep(),
                    _grp('HÌNH', DS.gold),
                    _shapeTool(c, 'Rect', Icons.rectangle_outlined, ToolType.rectangle, DS.gold),
                    _shapeTool(c, 'Elip', Icons.circle_outlined, ToolType.circle, DS.gold),
                    _shapeTool(c, 'Line', Icons.show_chart_rounded, ToolType.line, DS.gold),
                    _sep(),
                    _grp('KHÁC', DS.cyan),
                    _shapeTool(c, 'Fill', Icons.format_color_fill_rounded, ToolType.bucket, DS.cyan),
                    _shapeTool(c, 'Text', Icons.text_fields_rounded, ToolType.text, DS.cyan),
                    _eraserTool(c),
                    _sep(),
                    _grp('EXTRA', DS.rose),
                    _toggleTool(c, 'Lazy', Icons.gesture_rounded, DS.rose,
                        c.isStabilizerEnabled,
                        () => c.isStabilizerEnabled.toggle()),
                    _toggleTool(c, 'ISO', Icons.grid_3x3_rounded, DS.mint,
                        c.isIsometricSnapEnabled,
                        () => c.isIsometricSnapEnabled.toggle()),
                    _actionTool(c, 'Persp', Icons.grid_4x4, DS.gold, () {
                      Get.bottomSheet(
                          StudioPerspectiveSheet(controller: c),
                          isScrollControlled: true);
                    }),
                    _actionTool(c, 'AI', Icons.auto_awesome_rounded, DS.rose,
                        () => Get.dialog(const StudioAiDialog())),
                    const SizedBox(height: 8),
                    _sep(),
                    _grp('SYM', DS.violet),
                    _symTool(c, 'H-Sym', Icons.swap_horiz_rounded, SymmetryType.horizontal, DS.violet),
                    _symTool(c, 'V-Sym', Icons.swap_vert_rounded, SymmetryType.vertical, DS.violet),
                    _symTool(c, 'R4', Icons.rotate_90_degrees_ccw_rounded, SymmetryType.radial4, DS.cyan),
                    _symTool(c, 'R8', Icons.filter_8_rounded, SymmetryType.radial8, DS.cyan),
                  ],
                ),
              ),
            ),
            Divider(color: DS.border, height: 1, thickness: 1),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                children: [
                  _ColorSwatch(controller: c),
                  const SizedBox(height: 6),
                  _recentColors(context, c),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _grp(String label, Color accent) => Padding(
        padding: const EdgeInsets.only(top: 6, bottom: 2),
        child: Text(label,
            style: TextStyle(
                color: accent.withValues(alpha: 0.45),
                fontSize: 7.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.2)),
      );
  Widget _sep() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
        child: Container(height: 1, color: DS.border),
      );
  Widget _brushTool(DrawController c, String label, IconData icon,
      BrushType type, Color accent) {
    return Obx(() {
      final isSel = c.selectedTool.value == ToolType.brush &&
          c.selectedBrushType.value == type;
      return _tile(label, icon, accent, isSel,
          () => c.setBrushPreset(type: type));
    });
  }
  Widget _shapeTool(DrawController c, String label, IconData icon,
      ToolType type, Color accent) {
    return Obx(() {
      final isSel = c.selectedTool.value == type;
      return _tile(label, icon, accent, isSel, () => c.selectTool(type));
    });
  }
  Widget _eraserTool(DrawController c) {
    return Obx(() {
      final isSel = c.selectedTool.value == ToolType.eraser;
      return _tile('Tẩy', Icons.auto_fix_normal_rounded, DS.rose, isSel,
          c.selectEraser);
    });
  }
  Widget _toggleTool(DrawController c, String label, IconData icon,
      Color accent, RxBool state, VoidCallback onTap) {
    return Obx(() => _tile(label, icon, accent, state.value, onTap));
  }
  Widget _actionTool(DrawController c, String label, IconData icon,
      Color accent, VoidCallback onTap) {
    return _tile(label, icon, accent, false, onTap);
  }
  Widget _symTool(DrawController c, String label, IconData icon,
      SymmetryType type, Color accent) {
    return Obx(() {
      final isSel = c.symmetryType.value == type;
      return _tile(label, icon, accent, isSel,
          () => c.symmetryType.value = isSel ? SymmetryType.none : type);
    });
  }
  Widget _tile(String label, IconData icon, Color accent, bool isSel,
      VoidCallback onTap) {
    return _StudioToolTile(
      label: label,
      icon: icon,
      accent: accent,
      isSel: isSel,
      onTap: onTap,
    );
  }

  Widget _recentColors(BuildContext context, DrawController c) {
    return Obx(() {
      final recent = c.recentColors.take(4).toList();
      if (recent.isEmpty) return const SizedBox.shrink();
      return Wrap(
        spacing: 4,
        runSpacing: 4,
        alignment: WrapAlignment.center,
        children: recent.map((color) {
          return GestureDetector(
            onTap: () => c.changeColor(color),
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: color,
                borderRadius: DS.r4,
                border: Border.all(color: DS.border, width: 1),
              ),
            ),
          );
        }).toList(),
      );
    });
  }
}

class _StudioToolTile extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color accent;
  final bool isSel;
  final VoidCallback onTap;

  const _StudioToolTile({
    required this.label,
    required this.icon,
    required this.accent,
    required this.isSel,
    required this.onTap,
  });

  @override
  State<_StudioToolTile> createState() => _StudioToolTileState();
}

class _StudioToolTileState extends State<_StudioToolTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final accent = widget.accent;
    final isSel = widget.isSel;
    return Tooltip(
      message: widget.label,
      preferBelow: false,
      decoration: BoxDecoration(
        color: DS.card,
        borderRadius: DS.r8,
        border: Border.all(color: DS.border),
      ),
      textStyle: TextStyle(color: DS.text, fontSize: 11),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedScale(
            scale: isSel ? 1.05 : (_isHovered ? 1.05 : 1.0),
            duration: const Duration(milliseconds: 150),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              width: 48,
              height: 48,
              margin: const EdgeInsets.symmetric(vertical: 2),
              decoration: BoxDecoration(
                color: isSel 
                    ? accent.withValues(alpha: 0.15) 
                    : (_isHovered ? accent.withValues(alpha: 0.05) : Colors.transparent),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSel
                      ? accent
                      : (_isHovered ? accent.withValues(alpha: 0.4) : Colors.transparent),
                  width: isSel ? 1.5 : 1.0,
                ),
                boxShadow: isSel 
                    ? DS.glowShadow(accent, radius: 10) 
                    : (_isHovered ? [BoxShadow(color: accent.withValues(alpha: 0.05), blurRadius: 4)] : []),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.icon,
                    size: 18, 
                    color: isSel ? accent : (_isHovered ? accent.withValues(alpha: 0.8) : DS.textDim),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    widget.label.toUpperCase(),
                    style: TextStyle(
                      color: isSel ? accent : (_isHovered ? accent.withValues(alpha: 0.8) : DS.textDim),
                      fontSize: 7,
                      fontWeight: isSel || _isHovered ? FontWeight.w900 : FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


class _ColorSwatch extends StatefulWidget {
  final DrawController controller;
  const _ColorSwatch({required this.controller});

  @override
  State<_ColorSwatch> createState() => _ColorSwatchState();
}

class _ColorSwatchState extends State<_ColorSwatch> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Obx(() {
        final color = widget.controller.selectedColor.value;
        return GestureDetector(
          onTap: () => showColorPicker(context, widget.controller),
          child: AnimatedScale(
            scale: _isHovered ? 1.08 : 1.0,
            duration: const Duration(milliseconds: 150),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color,
                borderRadius: DS.r12,
                border: Border.all(
                  color: _isHovered ? Colors.white : DS.border, 
                  width: 2,
                ),
                boxShadow: DS.glowShadow(color, radius: _isHovered ? 18 : 14),
              ),
              child: const Icon(Icons.colorize_rounded, color: Colors.white70, size: 16),
            ),
          ),
        );
      }),
    );
  }
}