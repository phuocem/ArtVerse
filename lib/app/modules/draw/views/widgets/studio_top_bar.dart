import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
class _StudioTopBarState extends State<StudioTopBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  bool _editingTitle = false;
  late TextEditingController _titleCtrl;
  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _titleCtrl = TextEditingController(
      text: widget.controller.currentProjectName ?? 'Untitled',
    );
  }
  @override
  void dispose() {
    _pulse.dispose();
    _titleCtrl.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final c = widget.controller;
    return Container(
      height: 48,
      decoration: const BoxDecoration(
        color: DS.surface,
        border: Border(bottom: BorderSide(color: DS.border, width: 1)),
      ),
      child: Row(
        children: [
          _backBtn(c),
          _vDiv(),
          _titleArea(),
          _vDiv(),
          _topBtn('Mới', Icons.add_rounded, c.clearCanvas, accent: DS.textDim),
          _topBtn('Lưu', Icons.save_rounded, c.save, accent: DS.mint),
          _topBtn('Xuất', Icons.upload_rounded, () => _showExportMenu(context, c), accent: DS.gold),
          _vDiv(),
          _miniSlider(Icons.line_weight_rounded, c.selectedWidth, 1, 100, DS.violet, (v) => c.changeWidth(v)),
          const SizedBox(width: 12),
          _miniSlider(Icons.opacity_rounded, c.selectedOpacity, 0, 1, DS.cyan, (v) => c.changeOpacity(v)),
          _vDiv(),
          Obx(() => _toolBadge(c.currentToolTooltip, c.currentToolIcon)),
          _vDiv(),
          Obx(() => _iconBtn(
                Icons.vertical_align_center_rounded,
                c.symmetryType.value != SymmetryType.none,
                () {
                  c.symmetryType.value = c.symmetryType.value == SymmetryType.none
                      ? SymmetryType.horizontal
                      : SymmetryType.none;
                },
                tip: 'Đối xứng',
                accent: DS.violet,
              )),
          Obx(() => _iconBtn(
                Icons.grid_on_rounded,
                c.showGrid.value,
                c.toggleGrid,
                tip: 'Lưới',
                accent: DS.cyan,
              )),
          Obx(() => _iconBtn(
                Icons.self_improvement_rounded,
                c.isZenMode.value,
                c.toggleZenMode,
                tip: 'Zen mode',
                accent: DS.gold,
              )),
          _vDiv(),
          Obx(() => _undoRedoBtn(
                Icons.undo_rounded,
                c.undoStack.isNotEmpty,
                c.undo,
                tip: 'Hoàn tác',
              )),
          Obx(() => _undoRedoBtn(
                Icons.redo_rounded,
                c.redoStack.isNotEmpty,
                c.redo,
                tip: 'Làm lại',
              )),
          _vDiv(),
          _iconBtn(Icons.delete_sweep_rounded, false, c.clearCanvas,
              tip: 'Xoá canvas', danger: true),
          const SizedBox(width: 8),
          Obx(() => _autoSaveDot(c.isChanged.value)),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
  Widget _backBtn(DrawController c) {
    return Tooltip(
      message: 'Thoát Studio',
      child: InkWell(
        onTap: c.leaveSaving,
        borderRadius: DS.r8,
        child: Container(
          width: 52,
          height: 48,
          alignment: Alignment.center,
          child: AnimatedBuilder(
            animation: _pulse,
            builder: (_, __) => ShaderMask(
              shaderCallback: (r) => DS.crimsonGrad.createShader(r),
              child: const Icon(Icons.brush_rounded, color: Colors.white, size: 20),
            ),
          ),
        ),
      ),
    );
  }
  Widget _titleArea() {
    if (_editingTitle) {
      return SizedBox(
        width: 160,
        height: 32,
        child: TextField(
          controller: _titleCtrl,
          autofocus: true,
          style: const TextStyle(
              color: DS.text, fontSize: 13, fontWeight: FontWeight.w700),
          decoration: InputDecoration(
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            filled: true,
            fillColor: DS.card,
            border: OutlineInputBorder(
                borderRadius: DS.r8,
                borderSide: BorderSide(color: DS.violet.withValues(alpha: 0.5))),
            focusedBorder: OutlineInputBorder(
                borderRadius: DS.r8,
                borderSide: BorderSide(color: DS.violet, width: 1.5)),
          ),
          onSubmitted: (v) {
            widget.controller.currentProjectName = v.trim().isEmpty ? 'Untitled' : v.trim();
            setState(() => _editingTitle = false);
          },
          onEditingComplete: () => setState(() => _editingTitle = false),
        ),
      );
    }
    return GestureDetector(
      onTap: () => setState(() {
        _titleCtrl.text = widget.controller.currentProjectName ?? 'Untitled';
        _editingTitle = true;
      }),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: DS.card,
          borderRadius: DS.r8,
          border: Border.all(color: DS.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                widget.controller.currentProjectName ?? 'Untitled',
                style: const TextStyle(
                    color: DS.text,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    overflow: TextOverflow.ellipsis),
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.edit_rounded, size: 10, color: DS.textDim),
          ],
        ),
      ),
    );
  }
  Widget _topBtn(String label, IconData icon, VoidCallback onTap,
      {Color? accent}) {
    final col = accent ?? DS.textDim;
    return Tooltip(
      message: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: DS.r8,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: accent != null
                ? accent.withValues(alpha: 0.06)
                : DS.card,
            borderRadius: DS.r8,
            border: Border.all(
                color: accent != null
                    ? accent.withValues(alpha: 0.2)
                    : DS.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 13, color: col),
              const SizedBox(width: 5),
              Text(label,
                  style: TextStyle(
                      color: col,
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
  Widget _miniSlider(IconData icon, RxDouble val, double mn, double mx,
      Color accent, ValueChanged<double> onChange) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: accent.withValues(alpha: 0.8)),
        const SizedBox(width: 4),
        Obx(() => Text(
              mx <= 1.0
                  ? '${(val.value * 100).toInt()}%'
                  : '${val.value.toInt()}',
              style: const TextStyle(
                  color: DS.text,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'monospace'),
            )),
        SizedBox(
          width: 64,
          child: Obx(() => SliderTheme(
                data: SliderThemeData(
                  trackHeight: 2,
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
                  activeTrackColor: accent,
                  inactiveTrackColor: DS.border,
                  thumbColor: Colors.white,
                  overlayColor: accent.withValues(alpha: 0.12),
                ),
                child: Slider(
                  value: val.value.clamp(mn, mx),
                  min: mn,
                  max: mx,
                  onChanged: onChange,
                ),
              )),
        ),
      ],
    );
  }
  Widget _toolBadge(String tool, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: DS.violet.withValues(alpha: 0.1),
        borderRadius: DS.r8,
        border: Border.all(color: DS.violet.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: DS.violet),
          const SizedBox(width: 5),
          Text(tool.toUpperCase(),
              style: const TextStyle(
                  color: DS.violet,
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2)),
        ],
      ),
    );
  }
  Widget _iconBtn(IconData icon, bool active, VoidCallback onTap,
      {String? tip, bool danger = false, Color accent = DS.violet}) {
    final col = danger
        ? DS.crimson.withValues(alpha: 0.7)
        : active
            ? accent
            : DS.textDim;
    final btn = InkWell(
      onTap: onTap,
      borderRadius: DS.r8,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: active && !danger ? accent.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: DS.r8,
          border: Border.all(
              color: active && !danger
                  ? accent.withValues(alpha: 0.3)
                  : Colors.transparent),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 16, color: col),
      ),
    );
    if (tip != null) return Tooltip(message: tip, child: btn);
    return btn;
  }
  Widget _undoRedoBtn(IconData icon, bool enabled, VoidCallback onTap,
      {String? tip}) {
    final btn = InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: DS.r8,
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        child: Icon(icon,
            size: 16, color: enabled ? DS.textDim : DS.textDim.withValues(alpha: 0.3)),
      ),
    );
    if (tip != null) return Tooltip(message: tip, child: btn);
    return btn;
  }
  Widget _autoSaveDot(bool isChanged) {
    return Tooltip(
      message: isChanged ? 'Có thay đổi chưa lưu' : 'Đã lưu',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isChanged ? DS.gold : DS.mint,
          boxShadow: [
            BoxShadow(
              color: (isChanged ? DS.gold : DS.mint).withValues(alpha: 0.5),
              blurRadius: 6,
            )
          ],
        ),
      ),
    );
  }
  Widget _vDiv() => Container(
        width: 1, height: 24,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        color: DS.border,
      );
  void _showExportMenu(BuildContext context, DrawController c) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final pos = box.localToGlobal(Offset.zero);
    showMenu(
      context: context,
      color: DS.card,
      shape: RoundedRectangleBorder(
        borderRadius: DS.r12,
        side: BorderSide(color: DS.border),
      ),
      position: RelativeRect.fromLTRB(pos.dx + 300, pos.dy + 48, 0, 0),
      items: [
        _menuItem(context, Icons.image_rounded, 'Xuất PNG', DS.cyan, () {
          c.exportFrameAsImage(c.currentFrameIndex.value);
        }),
        _menuItem(context, Icons.save_rounded, 'Lưu dự án', DS.violet, c.save),
        _menuItem(context, Icons.share_rounded, 'Chia sẻ', DS.gold, () {
          Get.snackbar('Thông báo', 'Tính năng chia sẻ đang phát triển',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: DS.card,
              colorText: DS.text);
        }),
      ],
    );
  }
  PopupMenuItem<String> _menuItem(BuildContext context, IconData icon,
      String label, Color accent, VoidCallback onTap) {
    return PopupMenuItem(
      onTap: onTap,
      child: Row(children: [
        Icon(icon, size: 16, color: accent),
        const SizedBox(width: 10),
        Text(label,
            style: TextStyle(
                color: DS.text, fontSize: 13, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}
