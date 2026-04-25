import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/draw_controller.dart';
import '../widgets/studio_widgets.dart';

void showColorPicker(BuildContext context, DrawController controller) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.6),
    builder: (_) => _ColorPickerDialog(controller: controller),
  );
}

class _ColorPickerDialog extends StatefulWidget {
  final DrawController controller;
  const _ColorPickerDialog({required this.controller});
  @override
  State<_ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<_ColorPickerDialog> with SingleTickerProviderStateMixin {
  late TabController _tab;
  static const _basic = [Color(0xFF000000), Color(0xFFFFFFFF), Color(0xFFEF4444), Color(0xFFF97316), Color(0xFFEAB308), Color(0xFF22C55E), Color(0xFF06B6D4), Color(0xFF3B82F6), Color(0xFF8B5CF6), Color(0xFFEC4899), Color(0xFF92400E), Color(0xFF6B7280), Color(0xFF0F172A), Color(0xFFF59E0B), Color(0xFF10B981), Color(0xFF6366F1), Color(0xFFFF6B9D), Color(0xFF00E5FF), Color(0xFFF5A623), Color(0xFF00D49F), Color(0xFF7C5CFC), Color(0xFF2D2D46), Color(0xFFFF2D55), Color(0xFFB39DFB)];
  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }
  @override
  void dispose() { _tab.dispose(); super.dispose(); }
  void _pick(Color c) {
    widget.controller.changeColor(c);
    Navigator.of(context).pop();
  }
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 360, constraints: const BoxConstraints(maxHeight: 520), decoration: BoxDecoration(color: DS.card, borderRadius: DS.r24, border: Border.all(color: DS.border), boxShadow: DS.elevation),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 18, 16, 14), decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: DS.border))),
              child: Row(
                children: [
                  Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(gradient: DS.crimsonGrad, borderRadius: DS.r10), child: const Icon(Icons.palette_rounded, color: Colors.white, size: 16)),
                  const SizedBox(width: 12),
                  const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('THƯ VIỆN MÀU', style: TextStyle(color: DS.text, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1)), Text('Chọn màu để vẽ', style: TextStyle(color: DS.textDim, fontSize: 11))]),
                  const Spacer(),
                  InkWell(onTap: () => Navigator.of(context).pop(), borderRadius: DS.r50, child: Container(padding: const EdgeInsets.all(6), child: const Icon(Icons.close_rounded, color: DS.textDim, size: 18))),
                ],
              ),
            ),
            Obx(() {
              final c = widget.controller.selectedColor.value;
              return Container(
                margin: const EdgeInsets.fromLTRB(16, 14, 16, 0), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), decoration: BoxDecoration(color: c.withValues(alpha: 0.08), borderRadius: DS.r12, border: Border.all(color: c.withValues(alpha: 0.3))),
                child: Row(
                  children: [
                    Container(width: 32, height: 32, decoration: BoxDecoration(color: c, borderRadius: DS.r8, boxShadow: DS.glowShadow(c, radius: 16))),
                    const SizedBox(width: 12),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('MÀU HIỆN TẠI', style: TextStyle(color: DS.textDim, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1.5)), Text('#${c.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase().substring(2)}', style: const TextStyle(color: DS.text, fontSize: 14, fontWeight: FontWeight.w900, fontFamily: 'monospace'))]),
                  ],
                ),
              );
            }),
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 0), height: 34, decoration: BoxDecoration(color: DS.surface, borderRadius: DS.r12, border: Border.all(color: DS.border)),
              child: TabBar(controller: _tab, indicator: const BoxDecoration(gradient: DS.violetGrad, borderRadius: DS.r10), indicatorSize: TabBarIndicatorSize.tab, indicatorPadding: const EdgeInsets.all(3), dividerColor: Colors.transparent, labelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5), unselectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w400), labelColor: Colors.white, unselectedLabelColor: DS.textDim, tabs: const [Tab(text: 'Cơ bản'), Tab(text: 'Palette nhập')]),
            ),
            Flexible(child: Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 16), child: TabBarView(controller: _tab, children: [_basicGrid(), _paletteGrid()]))),
          ],
        ),
      ),
    );
  }
  Widget _basicGrid() => Wrap(spacing: 8, runSpacing: 8, children: _basic.map((c) => _colorBubble(c)).toList());
  Widget _paletteGrid() {
    return Obx(() {
      if (widget.controller.importedPalettes.isEmpty) {
        return const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.palette_outlined, size: 36, color: DS.textFaint), SizedBox(height: 8), Text('Chưa có palette nào', style: TextStyle(color: DS.textDim, fontSize: 12)), Text('Nhập palette .ase hoặc .aco', style: TextStyle(color: DS.textFaint, fontSize: 10))]);
      }
      return SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: widget.controller.importedPalettes.map((pl) {
        final colors = (pl['colors'] as List).cast<String>();
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(pl['name'] ?? 'Palette', style: const TextStyle(color: DS.textDim, fontSize: 11, fontWeight: FontWeight.w600)), const SizedBox(height: 8), Wrap(spacing: 8, runSpacing: 8, children: colors.map((hex) => _colorBubble(_fromHex(hex))).toList()), const SizedBox(height: 16)]);
      }).toList()));
    });
  }
  Widget _colorBubble(Color c) {
    return GestureDetector(
      onTap: () => _pick(c),
      child: Obx(() {
        final isSel = widget.controller.selectedColor.value.toARGB32() == c.toARGB32();
        return AnimatedContainer(duration: const Duration(milliseconds: 150), width: 36, height: 36, decoration: BoxDecoration(color: c, borderRadius: DS.r10, border: Border.all(color: isSel ? Colors.white : DS.border, width: isSel ? 2.5 : 1), boxShadow: isSel ? DS.glowShadow(c, radius: 14) : null), child: isSel ? const Icon(Icons.check_rounded, color: Colors.white, size: 16) : null);
      }),
    );
  }
}
Color _fromHex(String hex) {
  final buf = StringBuffer();
  if (hex.length == 6 || hex.length == 7) buf.write('ff');
  buf.write(hex.replaceFirst('#', ''));
  return Color(int.parse(buf.toString(), radix: 16));
}
