import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/draw_controller.dart';
import '../../../../data/models/draw/drawn_line_model.dart';
import 'studio_widgets.dart';
import '../dialogs/show_color_picker.dart';
import '../dialogs/studio_perspective_sheet.dart';
import '../dialogs/studio_ai_dialog.dart';
class StudioLeftSidebar extends StatefulWidget {
  final DrawController controller;
  const StudioLeftSidebar({super.key, required this.controller});
  @override
  State<StudioLeftSidebar> createState() => _StudioLeftSidebarState();
}
class _StudioLeftSidebarState extends State<StudioLeftSidebar>
    with SingleTickerProviderStateMixin {
  bool _collapsed = false;
  late final AnimationController _anim;
  late final Animation<double> _widthAnim;
  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250));
    _widthAnim =
        CurvedAnimation(parent: _anim, curve: Curves.easeInOutCubic);
  }
  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }
  void _toggle() {
    setState(() => _collapsed = !_collapsed);
    _collapsed ? _anim.forward() : _anim.reverse();
  }
  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    return AnimatedBuilder(
      animation: _widthAnim,
      builder: (_, __) {
        final w = 64.0 * (1 - _widthAnim.value);
        return SizedBox(
          width: w.clamp(0, 64),
          child: OverflowBox(
            alignment: Alignment.centerLeft,
            maxWidth: 64,
            child: Container(
              width: 64,
              decoration: const BoxDecoration(
                color: DS.surface,
                border: Border(right: BorderSide(color: DS.border)),
              ),
              child: Column(
                children: [
                  _CollapseBtn(collapsed: _collapsed, onTap: _toggle),
                  const Divider(color: DS.border, height: 1, thickness: 1),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(vertical: 6),
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
                  const Divider(color: DS.border, height: 1, thickness: 1),
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
          ),
        );
      },
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
    return Tooltip(
      message: label,
      preferBelow: false,
      decoration: BoxDecoration(
          color: DS.card,
          borderRadius: DS.r8,
          border: Border.all(color: DS.border)),
      textStyle: const TextStyle(color: DS.text, fontSize: 11),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          width: 50,
          height: 50,
          margin: const EdgeInsets.symmetric(vertical: 1),
          decoration: BoxDecoration(
            color: isSel ? accent.withValues(alpha: 0.14) : Colors.transparent,
            borderRadius: DS.r12,
            border: Border.all(
                color: isSel
                    ? accent.withValues(alpha: 0.45)
                    : Colors.transparent),
            boxShadow: isSel ? DS.glowShadow(accent, radius: 10) : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 18, color: isSel ? accent : DS.textDim),
              const SizedBox(height: 3),
              Text(label.toUpperCase(),
                  style: TextStyle(
                      color: isSel ? accent : DS.textDim,
                      fontSize: 7,
                      fontWeight:
                          isSel ? FontWeight.w900 : FontWeight.w500,
                      letterSpacing: 0.3)),
            ],
          ),
        ),
      ),
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
class _CollapseBtn extends StatelessWidget {
  final bool collapsed;
  final VoidCallback onTap;
  const _CollapseBtn({required this.collapsed, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: collapsed ? 'Mở thanh công cụ' : 'Ẩn thanh công cụ',
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 32,
          width: double.infinity,
          alignment: Alignment.center,
          child: Icon(
            collapsed
                ? Icons.chevron_right_rounded
                : Icons.chevron_left_rounded,
            size: 16,
            color: DS.textDim,
          ),
        ),
      ),
    );
  }
}
class _ColorSwatch extends StatelessWidget {
  final DrawController controller;
  const _ColorSwatch({required this.controller});
  @override
  Widget build(BuildContext context) {
    return Obx(() => GestureDetector(
          onTap: () => showColorPicker(context, controller),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: controller.selectedColor.value,
              borderRadius: DS.r12,
              border: Border.all(color: DS.border, width: 2),
              boxShadow: DS.glowShadow(controller.selectedColor.value, radius: 14),
            ),
            child: const Icon(Icons.colorize_rounded, color: Colors.white70, size: 16),
          ),
        ));
  }
}
