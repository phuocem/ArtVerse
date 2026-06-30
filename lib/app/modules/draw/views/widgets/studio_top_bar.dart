import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/draw_controller.dart';
import '../../../../data/models/draw/drawn_line_model.dart';
import 'studio_widgets.dart';
import '../dialogs/studio_perspective_sheet.dart';
import '../dialogs/studio_ai_dialog.dart';
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
    return GlassContainer(
      borderRadius: 16,
      opacity: 0.05,
      blur: 15,
      border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 0.8),
      child: SizedBox(
        height: 48,
        child: Row(
          children: [
            _backBtn(c),
            _vDiv(),
            _titleArea(),
            _vDiv(),
            Obx(() => _toolSelector(c)),
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
                  Icons.grid_3x3_rounded,
                  c.isIsometricSnapEnabled.value,
                  () => c.isIsometricSnapEnabled.toggle(),
                  tip: 'Hút Isometric',
                  accent: DS.mint,
                )),
            _iconBtn(
              Icons.grid_4x4,
              false,
              () {
                Get.bottomSheet(
                    StudioPerspectiveSheet(controller: c),
                    isScrollControlled: true);
              },
              tip: 'Phối cảnh',
              accent: DS.gold,
            ),
            _iconBtn(
              Icons.auto_awesome_rounded,
              false,
              () => Get.dialog(const StudioAiDialog()),
              tip: 'Trợ lý AI',
              accent: DS.rose,
            ),
            Obx(() => _iconBtn(
                  Icons.self_improvement_rounded,
                  c.isZenMode.value,
                  c.toggleZenMode,
                  tip: 'Zen mode',
                  accent: DS.gold,
                )),
            _vDiv(),
            _iconBtn(Icons.delete_sweep_rounded, false, c.clearCanvas,
                tip: 'Xoá canvas', danger: true),
            _vDiv(),
            const Spacer(),
            _topBtn('Mới', Icons.add_rounded, c.clearCanvas, accent: DS.textDim),
            _topBtn('Lưu', Icons.save_rounded, c.save, accent: DS.mint),
            _topBtn('Xuất', Icons.upload_rounded, () => _showExportMenu(context, c), accent: DS.gold),
            _vDiv(),
            Obx(() => _autoSaveDot(c.isChanged.value)),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }


  Widget _backBtn(DrawController c) {
    return _HoverScaleBtn(
      onTap: c.leaveSaving,
      tooltip: 'Quay lại',
      child: Container(
        width: 48,
        height: 48,
        alignment: Alignment.center,
        child: Icon(Icons.arrow_back_ios_new_rounded, color: DS.textDim, size: 18),
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
          style: TextStyle(
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
                style: TextStyle(
                    color: DS.text,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    overflow: TextOverflow.ellipsis),
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.edit_rounded, size: 10, color: DS.textDim),
          ],
        ),
      ),
    );
  }
  Widget _topBtn(String label, IconData icon, VoidCallback onTap,
      {Color? accent}) {
    final col = accent ?? DS.textDim;
    return _HoverScaleBtn(
      onTap: onTap,
      tooltip: label,
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
                  ? accent.withValues(alpha: 0.25)
                  : DS.border,
              width: 0.8),
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
    );
  }

  Widget _toolSelector(DrawController c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: DS.r12,
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _topToolBtn(c, Icons.edit_rounded, 'Chì', () {
            c.setBrushPreset(type: BrushType.pencil);
          }, isActive: c.selectedTool.value == ToolType.brush && c.selectedBrushType.value == BrushType.pencil),
          _topToolBtn(c, Icons.brush_rounded, 'Cọ', () {
            c.setBrushPreset(type: BrushType.brush);
          }, isActive: c.selectedTool.value == ToolType.brush && c.selectedBrushType.value == BrushType.brush),
          _topToolBtn(c, Icons.blur_on_rounded, 'Phun', () {
            c.setBrushPreset(type: BrushType.airbrush);
          }, isActive: c.selectedTool.value == ToolType.brush && c.selectedBrushType.value == BrushType.airbrush),
          _topToolBtn(c, Icons.history_edu_rounded, 'Mực', () {
            c.setBrushPreset(type: BrushType.pen);
          }, isActive: c.selectedTool.value == ToolType.brush && c.selectedBrushType.value == BrushType.pen),
          
          _vDivMini(),
          
          _topToolBtn(c, Icons.rectangle_outlined, 'Hình', () {
            if (c.selectedTool.value == ToolType.rectangle) {
              c.selectTool(ToolType.circle);
            } else if (c.selectedTool.value == ToolType.circle) {
              c.selectTool(ToolType.line);
            } else {
              c.selectTool(ToolType.rectangle);
            }
          }, isActive: c.selectedTool.value == ToolType.rectangle || c.selectedTool.value == ToolType.circle || c.selectedTool.value == ToolType.line,
             iconOverride: c.selectedTool.value == ToolType.rectangle 
                 ? Icons.rectangle_outlined 
                 : c.selectedTool.value == ToolType.circle 
                     ? Icons.circle_outlined 
                     : c.selectedTool.value == ToolType.line 
                         ? Icons.show_chart_rounded 
                         : Icons.category_outlined),
          
          _topToolBtn(c, Icons.format_color_fill_rounded, 'Sơn', () {
            c.selectTool(ToolType.bucket);
          }, isActive: c.selectedTool.value == ToolType.bucket),
          _topToolBtn(c, Icons.text_fields_rounded, 'Chữ', () {
            c.selectTool(ToolType.text);
          }, isActive: c.selectedTool.value == ToolType.text),
          
          _vDivMini(),
          
          _topToolBtn(c, Icons.auto_fix_normal_rounded, 'Tẩy', () {
            c.selectEraser();
          }, isActive: c.selectedTool.value == ToolType.eraser, danger: true),
        ],
      ),
    );
  }

  Widget _vDivMini() => Container(
        width: 1,
        height: 16,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        color: Colors.white.withValues(alpha: 0.08),
      );

  Widget _topToolBtn(
    DrawController c,
    IconData icon,
    String tooltip,
    VoidCallback onTap, {
    required bool isActive,
    IconData? iconOverride,
    bool danger = false,
  }) {
    final effectiveIcon = iconOverride ?? icon;
    final color = danger
        ? DS.crimson
        : isActive
            ? DS.violet
            : DS.textDim;
    return _HoverScaleBtn(
      onTap: onTap,
      tooltip: tooltip,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: DS.r6,
        ),
        alignment: Alignment.center,
        child: Icon(effectiveIcon, size: 14, color: color),
      ),
    );
  }
  Widget _iconBtn(IconData icon, bool active, VoidCallback onTap,
      {String? tip, bool danger = false, Color? accent}) {
    final effectiveAccent = accent ?? DS.violet;
    final col = danger
        ? DS.crimson.withValues(alpha: 0.7)
        : active
            ? effectiveAccent
            : DS.textDim;
    return _HoverScaleBtn(
      onTap: onTap,
      tooltip: tip,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: active && !danger ? effectiveAccent.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: DS.r8,
          border: Border.all(
              color: active && !danger
                  ? effectiveAccent.withValues(alpha: 0.3)
                  : Colors.transparent,
              width: 0.8),
        ),
        alignment: Alignment.center,
        child: Icon(icon, size: 16, color: col),
      ),
    );
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

class _HoverScaleBtn extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final String? tooltip;
  const _HoverScaleBtn({required this.child, this.onTap, this.tooltip});

  @override
  State<_HoverScaleBtn> createState() => _HoverScaleBtnState();
}

class _HoverScaleBtnState extends State<_HoverScaleBtn> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final hasTap = widget.onTap != null;
    Widget current = MouseRegion(
      cursor: hasTap ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) {
        if (hasTap) setState(() => _isHovered = true);
      },
      onExit: (_) {
        if (hasTap) setState(() => _isHovered = false);
      },
      child: AnimatedScale(
        scale: _isHovered ? 1.08 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: GestureDetector(
          onTap: widget.onTap,
          child: widget.child,
        ),
      ),
    );

    if (widget.tooltip != null) {
      current = Tooltip(
        message: widget.tooltip!,
        decoration: BoxDecoration(
          color: DS.card,
          borderRadius: DS.r8,
          border: Border.all(color: DS.border),
        ),
        textStyle: TextStyle(color: DS.text, fontSize: 11),
        child: current,
      );
    }
    return current;
  }
}