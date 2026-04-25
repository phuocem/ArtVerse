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
    return Container(
      width: 68,
      decoration: const BoxDecoration(color: DS.surface, border: Border(right: BorderSide(color: DS.border))),
      child: Column(
        children: [
          const SizedBox(height: 8),
          _groupLabel('VẼ', DS.violet),
          _brushTool('Chì',   Icons.edit_rounded,          BrushType.pencil,   DS.violet),
          _brushTool('Cọ',    Icons.brush_rounded,          BrushType.brush,    DS.violet),
          _brushTool('Phun',  Icons.blur_on_rounded,        BrushType.airbrush, DS.violet),
          _brushTool('Mực',   Icons.history_edu_rounded,    BrushType.pen,      DS.violet),
          _sep(),
          _groupLabel('HÌNH', DS.gold),
          _shapeTool('Rect',  Icons.rectangle_outlined,     ToolType.rectangle, DS.gold),
          _shapeTool('Elip',  Icons.circle_outlined,        ToolType.circle,    DS.gold),
          _shapeTool('Line',  Icons.maximize_rounded,       ToolType.line,      DS.gold),
          _sep(),
          _groupLabel('KHÁC', DS.cyan),
          _shapeTool('Fill',  Icons.format_color_fill_rounded, ToolType.bucket, DS.cyan),
          _shapeTool('Text',  Icons.text_fields_rounded,    ToolType.text,      DS.cyan),
          _eraserTool(),
          _sep(),
          _groupLabel('EXTRA', DS.crimson),
          _toggleTool('Lazy',  Icons.gesture_rounded,           'stabilizer', DS.crimson,   () => controller.isStabilizerEnabled.toggle()),
          _toggleTool('Persp', Icons.grid_4x4,                  'perspective', DS.gold,     () => Get.bottomSheet(StudioPerspectiveSheet(controller: controller), isScrollControlled: true)),
          _toggleTool('ISO',   Icons.grid_3x3_rounded,          'isosnap', DS.mint,         () => controller.isIsometricSnapEnabled.toggle()),
          _toggleTool('AI',    Icons.auto_awesome_rounded,      'ai', DS.rose,              () => Get.dialog(const StudioAiDialog())),
          const Spacer(),
          _colorSwatch(context),
          const SizedBox(height: 14),
        ],
      ),
    );
  }

  Widget _groupLabel(String text, Color accent) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(text, style: TextStyle(color: accent.withValues(alpha: 0.5), fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 2.5)),
    );
  }

  Widget _sep() => Padding(padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8), child: Container(height: 1, color: DS.border));

  Widget _brushTool(String label, IconData icon, BrushType type, Color accent) {
    return Obx(() {
      final isSel = (controller.selectedTool.value == ToolType.brush || controller.selectedTool.value == ToolType.eraser) && controller.selectedBrushType.value == type;
      return _toolTile(label, icon, accent, isSel, () => controller.setBrushPreset(type: type));
    });
  }

  Widget _shapeTool(String label, IconData icon, ToolType type, Color accent) {
    return Obx(() {
      final isSel = controller.selectedTool.value == type;
      return _toolTile(label, icon, accent, isSel, () => controller.selectTool(type));
    });
  }

  Widget _eraserTool() {
    return Obx(() {
      final isSel = controller.selectedTool.value == ToolType.eraser;
      return _toolTile('Tẩy', Icons.auto_fix_normal_rounded, DS.rose, isSel, () => controller.selectEraser());
    });
  }

  Widget _toggleTool(String label, IconData icon, String type, Color accent, VoidCallback onTap) {
    return Obx(() {
      bool isSel = false;
      switch (type) {
        case 'stabilizer':  isSel = controller.isStabilizerEnabled.value; break;
        case 'perspective': isSel = controller.perspectiveType.value != PerspectiveType.none; break;
        case 'isosnap':     isSel = controller.isIsometricSnapEnabled.value; break;
        default:            isSel = false;
      }
      return _toolTile(label, icon, accent, isSel, onTap);
    });
  }

  Widget _toolTile(String label, IconData icon, Color accent, bool isSel, VoidCallback onTap) {
    return Tooltip(
      message: label,
      preferBelow: false,
      decoration: BoxDecoration(color: DS.cardHi, borderRadius: DS.r8, border: Border.all(color: DS.border)),
      textStyle: const TextStyle(color: DS.text, fontSize: 11),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          width: 52,
          height: 52,
          margin: const EdgeInsets.symmetric(vertical: 2),
          decoration: BoxDecoration(color: isSel ? accent.withValues(alpha: 0.12) : Colors.transparent, borderRadius: DS.r12, border: Border.all(color: isSel ? accent.withValues(alpha: 0.4) : Colors.transparent), boxShadow: isSel ? DS.glowShadow(accent, radius: 12) : null),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: isSel ? accent : DS.textDim),
              const SizedBox(height: 3),
              Text(label.toUpperCase(), style: TextStyle(color: isSel ? accent : DS.textDim, fontSize: 7, fontWeight: isSel ? FontWeight.w900 : FontWeight.w500, letterSpacing: 0.5)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _colorSwatch(BuildContext context) {
    return Obx(() => GestureDetector(
      onTap: () => showColorPicker(context, controller),
      child: AnimatedContainer(duration: const Duration(milliseconds: 200), width: 38, height: 38, decoration: BoxDecoration(color: controller.selectedColor.value, borderRadius: DS.r12, border: Border.all(color: DS.borderHi, width: 2), boxShadow: DS.glowShadow(controller.selectedColor.value, radius: 16))),
    ));
  }
}
