import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/draw_controller.dart';
import '../widgets/studio_widgets.dart';
void showColorPicker(BuildContext context, DrawController controller) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.55),
    builder: (_) => _ColorPickerDialog(controller: controller),
  );
}
class _ColorPickerDialog extends StatefulWidget {
  final DrawController controller;
  const _ColorPickerDialog({required this.controller});
  @override
  State<_ColorPickerDialog> createState() => _ColorPickerDialogState();
}
class _ColorPickerDialogState extends State<_ColorPickerDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  late TextEditingController _hexCtrl;
  double _hue = 0;
  double _sat = 1;
  double _val = 1;
  static const _basic = [
    Color(0xFF000000), Color(0xFFFFFFFF), Color(0xFFEF4444),
    Color(0xFFF97316), Color(0xFFEAB308), Color(0xFF22C55E),
    Color(0xFF06B6D4), Color(0xFF3B82F6), Color(0xFF8B5CF6),
    Color(0xFFEC4899), Color(0xFF92400E), Color(0xFF6B7280),
    Color(0xFF0F172A), Color(0xFFF59E0B), Color(0xFF10B981),
    Color(0xFF6366F1), Color(0xFFFF6B9D), Color(0xFF00E5FF),
    Color(0xFFF5A623), Color(0xFF00D49F), Color(0xFF7C5CFC),
    Color(0xFF2D2D46), Color(0xFFFF2D55), Color(0xFFB39DFB),
  ];
  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    final c = widget.controller.selectedColor.value;
    final hsv = HSVColor.fromColor(c);
    _hue = hsv.hue;
    _sat = hsv.saturation;
    _val = hsv.value;
    _hexCtrl = TextEditingController(text: _colorToHex(c));
  }
  @override
  void dispose() {
    _tab.dispose();
    _hexCtrl.dispose();
    super.dispose();
  }
  Color get _currentColor =>
      HSVColor.fromAHSV(1.0, _hue, _sat, _val).toColor();
  String _colorToHex(Color c) =>
      c.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase().substring(2);
  void _applyColor(Color c) {
    widget.controller.changeColor(c);
    if (!widget.controller.recentColors.contains(c)) {
      widget.controller.recentColors.insert(0, c);
      if (widget.controller.recentColors.length > 8) {
        widget.controller.recentColors.removeLast();
      }
    }
  }
  void _pickAndClose(Color c) {
    _applyColor(c);
    Navigator.of(context).pop();
  }
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 360,
        constraints: const BoxConstraints(maxHeight: 560),
        decoration: BoxDecoration(
          color: DS.card,
          borderRadius: DS.r24,
          border: Border.all(color: DS.border),
          boxShadow: DS.elevation,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            _buildPreview(),
            Container(
              margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              height: 34,
              decoration: BoxDecoration(
                  color: DS.surface,
                  borderRadius: DS.r12,
                  border: Border.all(color: DS.border)),
              child: TabBar(
                controller: _tab,
                indicator: BoxDecoration(
                    gradient: DS.violetGrad, borderRadius: DS.r10),
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: const EdgeInsets.all(3),
                dividerColor: Colors.transparent,
                labelStyle: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4),
                unselectedLabelStyle:
                    const TextStyle(fontSize: 10, fontWeight: FontWeight.w400),
                labelColor: Colors.white,
                unselectedLabelColor: DS.textDim,
                tabs: const [
                  Tab(text: 'Cơ bản'),
                  Tab(text: 'HSV'),
                  Tab(text: 'Palette'),
                ],
              ),
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                child: TabBarView(
                  controller: _tab,
                  children: [
                    _basicGrid(),
                    _hsvPicker(),
                    _paletteGrid(),
                  ],
                ),
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 14, 12),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: DS.border))),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
                gradient: DS.crimsonGrad, borderRadius: DS.r10),
            child: const Icon(Icons.palette_rounded,
                color: Colors.white, size: 16),
          ),
          const SizedBox(width: 12),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('CHỌN MÀU',
                  style: TextStyle(
                      color: DS.text,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      letterSpacing: 0.8)),
              Text('Chọn màu để vẽ',
                  style: TextStyle(color: DS.textDim, fontSize: 10)),
            ],
          ),
          const Spacer(),
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: DS.r50,
            child: const Padding(
              padding: EdgeInsets.all(6),
              child:
                  Icon(Icons.close_rounded, color: DS.textDim, size: 18),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildPreview() {
    return Obx(() {
      final c = widget.controller.selectedColor.value;
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: c.withValues(alpha: 0.08),
          borderRadius: DS.r12,
          border: Border.all(color: c.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                  color: c,
                  borderRadius: DS.r8,
                  boxShadow: DS.glowShadow(c, radius: 14)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('MÀU HIỆN TẠI',
                      style: TextStyle(
                          color: DS.textDim,
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5)),
                  Text(_colorToHex(c),
                      style: const TextStyle(
                          color: DS.text,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'monospace')),
                ],
              ),
            ),
            Obx(() => Row(
                  mainAxisSize: MainAxisSize.min,
                  children:
                      widget.controller.recentColors.take(4).map((rc) {
                    return GestureDetector(
                      onTap: () {
                        _pickAndClose(rc);
                      },
                      child: Container(
                        width: 18,
                        height: 18,
                        margin: const EdgeInsets.only(left: 4),
                        decoration: BoxDecoration(
                          color: rc,
                          borderRadius: DS.r4,
                          border: Border.all(color: DS.border),
                        ),
                      ),
                    );
                  }).toList(),
                )),
          ],
        ),
      );
    });
  }
  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: DS.border))),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: DS.textFaint.withValues(alpha: 0.2),
                borderRadius: DS.r8),
            child: const Text('#',
                style: TextStyle(
                    color: DS.textDim,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'monospace')),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Container(
              height: 34,
              decoration: BoxDecoration(
                  color: DS.surface,
                  borderRadius: DS.r8,
                  border: Border.all(color: DS.border)),
              child: TextField(
                controller: _hexCtrl,
                style: const TextStyle(
                    color: DS.text,
                    fontFamily: 'monospace',
                    fontSize: 13,
                    fontWeight: FontWeight.w700),
                decoration: const InputDecoration(
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    border: InputBorder.none),
                onSubmitted: (hex) {
                  try {
                    final clean = hex.replaceFirst('#', '').trim();
                    final full = clean.length == 6 ? 'ff$clean' : clean;
                    final color = Color(int.parse(full, radix: 16));
                    _pickAndClose(color);
                  } catch (_) {}
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          InkWell(
            onTap: () {
              final hsv = HSVColor.fromAHSV(1, _hue, _sat, _val);
              _pickAndClose(hsv.toColor());
            },
            borderRadius: DS.r10,
            child: Container(
              height: 34,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: const BoxDecoration(
                  gradient: DS.violetGrad, borderRadius: DS.r10),
              alignment: Alignment.center,
              child: const Text('Chọn',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }
  Widget _basicGrid() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _basic
          .map((c) => Obx(() {
                final isSel = widget.controller.selectedColor.value
                        .toARGB32() ==
                    c.toARGB32();
                return GestureDetector(
                  onTap: () => _pickAndClose(c),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: c,
                      borderRadius: DS.r10,
                      border: Border.all(
                          color: isSel ? Colors.white : DS.border,
                          width: isSel ? 2.5 : 1),
                      boxShadow:
                          isSel ? DS.glowShadow(c, radius: 12) : null,
                    ),
                    child: isSel
                        ? const Icon(Icons.check_rounded,
                            color: Colors.white, size: 16)
                        : null,
                  ),
                );
              }))
          .toList(),
    );
  }
  Widget _hsvPicker() {
    return StatefulBuilder(
      builder: (_, setLocal) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                  color: _currentColor, borderRadius: DS.r12),
            ),
            const SizedBox(height: 12),
            _hsvSlider('Hue', _hue, 0, 360, DS.rose, (v) {
              setLocal(() => _hue = v);
              _applyColor(_currentColor);
            }),
            _hsvSlider('Saturation', _sat, 0, 1, DS.cyan, (v) {
              setLocal(() => _sat = v);
              _applyColor(_currentColor);
            }, isPercent: true),
            _hsvSlider('Brightness', _val, 0, 1, DS.gold, (v) {
              setLocal(() => _val = v);
              _applyColor(_currentColor);
            }, isPercent: true),
          ],
        );
      },
    );
  }
  Widget _hsvSlider(String label, double value, double min, double max,
      Color accent, ValueChanged<double> onChanged,
      {bool isPercent = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    color: DS.textDim,
                    fontSize: 10,
                    fontWeight: FontWeight.w700)),
            Text(
              isPercent
                  ? '${(value * 100).toInt()}%'
                  : value.toInt().toString(),
              style: const TextStyle(
                  color: DS.text,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'monospace'),
            ),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 6,
            thumbShape:
                const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape:
                const RoundSliderOverlayShape(overlayRadius: 14),
            activeTrackColor: accent,
            inactiveTrackColor: DS.border,
            thumbColor: Colors.white,
            overlayColor: accent.withValues(alpha: 0.12),
          ),
          child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              onChanged: onChanged),
        ),
        const SizedBox(height: 4),
      ],
    );
  }
  Widget _paletteGrid() {
    return Obx(() {
      if (widget.controller.importedPalettes.isEmpty) {
        return const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.palette_outlined, size: 36, color: DS.textFaint),
            SizedBox(height: 8),
            Text('Chưa có palette nào',
                style: TextStyle(color: DS.textDim, fontSize: 12)),
            Text('Nhập palette .ase hoặc .aco',
                style: TextStyle(color: DS.textFaint, fontSize: 10)),
          ],
        );
      }
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: widget.controller.importedPalettes.map((pl) {
            final colors = (pl['colors'] as List).cast<String>();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pl['name'] ?? 'Palette',
                    style: const TextStyle(
                        color: DS.textDim,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: colors
                      .map((hex) => GestureDetector(
                            onTap: () =>
                                _pickAndClose(_fromHex(hex)),
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: _fromHex(hex),
                                borderRadius: DS.r8,
                                border:
                                    Border.all(color: DS.border),
                              ),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 16),
              ],
            );
          }).toList(),
        ),
      );
    });
  }
}
Color _fromHex(String hex) {
  final buf = StringBuffer();
  if (hex.length == 6 || hex.length == 7) buf.write('ff');
  buf.write(hex.replaceFirst('#', ''));
  return Color(int.parse(buf.toString(), radix: 16));
}
