import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/draw_controller.dart';
import '../../../../data/models/draw/drawn_line_model.dart';
import 'studio_widgets.dart';

class StudioTopBar extends StatefulWidget {
  final DrawController controller;
  const StudioTopBar({super.key, required this.controller});
  @override
  State<StudioTopBar> createState() => _StudioTopBarState();
}

class _StudioTopBarState extends State<StudioTopBar> with TickerProviderStateMixin {
  late final AnimationController _shimmer;
  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
  }
  @override
  void dispose() { _shimmer.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: const BoxDecoration(color: DS.surface, border: Border(bottom: BorderSide(color: DS.border, width: 1))),
      child: Row(
        children: [
          _buildLogoArea(),
          _vLine(),
          const SizedBox(width: 12),
          _topAction('Tệp', Icons.folder_open_rounded, () {
            Get.snackbar('Thông báo', 'Tính năng quản lý tệp đang được phát triển', snackPosition: SnackPosition.BOTTOM, backgroundColor: DS.card, colorText: DS.text);
          }, accent: DS.gold),
          _topAction('Mới', Icons.add_rounded, widget.controller.clearCanvas),
          _topAction('Xuất', Icons.upload_rounded, widget.controller.save, accent: DS.mint),
          _vLine(),
          const SizedBox(width: 8),
          _miniSlider('Cỡ', widget.controller.selectedWidth, 1, 100),
          const SizedBox(width: 16),
          _miniSlider('Mờ', widget.controller.selectedOpacity, 0, 1, isPercent: true),
          const Spacer(),
          Obx(() => _toolBadge(widget.controller.currentToolTooltip)),
          _vLine(),
          _iconAction(Icons.vertical_align_center_rounded, () {
            widget.controller.symmetryType.value = widget.controller.symmetryType.value == SymmetryType.none ? SymmetryType.horizontal : SymmetryType.none;
          }, tip: 'Bật/Tắt đối xứng nhanh'),
          _iconAction(Icons.grid_on_rounded, widget.controller.showGrid.toggle, tip: 'Bật/Tắt lưới'),
          _vLine(),
          _iconAction(Icons.undo_rounded, widget.controller.undo, tip: 'Hoàn tác (Ctrl+Z)'),
          _iconAction(Icons.redo_rounded, widget.controller.redo, tip: 'Làm lại (Ctrl+Y)'),
          _vLine(),
          _iconAction(Icons.delete_sweep_rounded, widget.controller.clearCanvas, danger: true, tip: 'Xoá canvas'),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
  Widget _buildLogoArea() {
    return GestureDetector(
      onTap: () => Get.back<void>(),
      child: Container(
        width: 64, height: 56, alignment: Alignment.center,
        decoration: const BoxDecoration(border: Border(right: BorderSide(color: DS.border))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(animation: _shimmer, builder: (_, __) => ShaderMask(shaderCallback: (rect) => DS.crimsonGrad.createShader(rect), child: const Icon(Icons.brush_rounded, color: Colors.white, size: 20))),
            const SizedBox(height: 2),
            const Text('ART', style: TextStyle(color: DS.textDim, fontSize: 7, fontWeight: FontWeight.w900, letterSpacing: 2)),
          ],
        ),
      ),
    );
  }
  Widget _topAction(String label, IconData icon, VoidCallback onTap, {Color? accent}) {
    final c = accent ?? DS.textDim;
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Tooltip(
        message: label,
        child: InkWell(
          onTap: onTap, borderRadius: DS.r8,
          child: AnimatedContainer(duration: const Duration(milliseconds: 150), padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: accent != null ? accent.withValues(alpha: 0.08) : DS.card, borderRadius: DS.r8, border: Border.all(color: accent != null ? accent.withValues(alpha: 0.25) : DS.border)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 13, color: c), const SizedBox(width: 5), Text(label, style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.w600))])),
        ),
      ),
    );
  }
  Widget _miniSlider(String label, RxDouble value, double min, double max, {bool isPercent = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(color: DS.textDim, fontSize: 10, fontWeight: FontWeight.w500)),
        const SizedBox(width: 6),
        Obx(() => Text(isPercent ? '${(value.value * 100).toInt()}%' : value.value.toInt().toString(), style: const TextStyle(color: DS.text, fontSize: 11, fontWeight: FontWeight.w900, fontFamily: 'monospace'))),
        const SizedBox(width: 6),
        SizedBox(width: 72, child: Obx(() => SliderTheme(data: const SliderThemeData(trackHeight: 2, thumbShape: RoundSliderThumbShape(enabledThumbRadius: 5), overlayShape: RoundSliderOverlayShape(overlayRadius: 10), activeTrackColor: DS.violet, inactiveTrackColor: DS.border, thumbColor: Colors.white), child: Slider(value: value.value.clamp(min, max), min: min, max: max, onChanged: (v) => value.value = v)))),
      ],
    );
  }
  Widget _toolBadge(String tool) {
    return Container(margin: const EdgeInsets.symmetric(horizontal: 12), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: DS.violet.withValues(alpha: 0.1), borderRadius: DS.r8, border: Border.all(color: DS.violet.withValues(alpha: 0.3))), child: Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.circle, size: 6, color: DS.violet), const SizedBox(width: 6), Text(tool.toUpperCase(), style: const TextStyle(color: DS.violet, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.5))]));
  }
  Widget _iconAction(IconData icon, VoidCallback onTap, {bool danger = false, String? tip}) {
    final color = danger ? DS.crimson.withValues(alpha: 0.7) : DS.textDim;
    final btn = InkWell(onTap: onTap, borderRadius: DS.r8, child: Container(width: 34, height: 34, alignment: Alignment.center, child: Icon(icon, color: color, size: 17)));
    if (tip != null) return Tooltip(message: tip, child: btn);
    return btn;
  }
  Widget _vLine() => Container(width: 1, height: 28, margin: const EdgeInsets.symmetric(horizontal: 10), color: DS.border);
}
