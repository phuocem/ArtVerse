import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/draw_controller.dart';
import 'studio_sidebar_layers.dart';
import 'studio_sidebar_frames.dart';
import 'studio_widgets.dart';

class StudioRightSidebar extends StatefulWidget {
  final DrawController controller;
  const StudioRightSidebar({super.key, required this.controller});
  @override
  State<StudioRightSidebar> createState() => _StudioRightSidebarState();
}

class _StudioRightSidebarState extends State<StudioRightSidebar> with TickerProviderStateMixin {
  late TabController _tab;
  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 4, vsync: this);
  }
  @override
  void dispose() { _tab.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: const BoxDecoration(color: DS.surface, border: Border(left: BorderSide(color: DS.border))),
      child: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: [
                _PropertiesTab(controller: widget.controller),
                const StudioSidebarLayers(),
                StudioSidebarFrames(controller: widget.controller),
                _LayoutTab(controller: widget.controller),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildTabBar() {
    return Container(
      height: 46,
      decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: DS.border))),
      child: TabBar(
        controller: _tab,
        labelPadding: EdgeInsets.zero,
        indicatorWeight: 0,
        indicator: const BoxDecoration(gradient: DS.violetGrad, borderRadius: DS.r8),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        dividerColor: Colors.transparent,
        labelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.5),
        unselectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.w400),
        labelColor: Colors.white,
        unselectedLabelColor: DS.textDim,
        tabs: const [Tab(text: 'Thuộc tính'), Tab(text: 'Lớp'), Tab(text: 'Frame'), Tab(text: 'Layout')],
      ),
    );
  }
}

class _PropertiesTab extends StatelessWidget {
  final DrawController controller;
  const _PropertiesTab({required this.controller});
  static const _palette = [Color(0xFF000000), Color(0xFFFFFFFF), Color(0xFFEF4444), Color(0xFFF97316), Color(0xFFEAB308), Color(0xFF22C55E), Color(0xFF06B6D4), Color(0xFF3B82F6), Color(0xFF8B5CF6), Color(0xFFEC4899), Color(0xFF92400E), Color(0xFF6B7280), Color(0xFF0F172A), Color(0xFFF59E0B), Color(0xFF10B981), Color(0xFF6366F1), Color(0xFFFF6B9D), Color(0xFF00E5FF), Color(0xFFF5A623), Color(0xFF00D49F)];
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          sectionLabel('MÀU SẮC', accent: DS.crimson),
          _colorPalette(),
          const SizedBox(height: 10),
          _hexRow(),
          const SizedBox(height: 20),
          sectionLabel('BÚT VẼ', accent: DS.violet),
          StudioSlider('Cỡ nét',   controller.selectedWidth,    1,  100, accent: DS.violet),
          StudioSlider('Opacity',   controller.selectedOpacity,  0,  1,   isPercent: true, accent: DS.cyan),
          StudioSlider('Cứng',     controller.selectedHardness, 0,  1,   isPercent: true, accent: DS.gold),
          StudioSlider('Gian cách', controller.selectedSpacing,  1,  50, accent: DS.mint),
          StudioSlider('Góc',      controller.selectedAngle,    0,  360, suffix: '°', accent: DS.rose),
          const SizedBox(height: 20),
          sectionLabel('CHẾ ĐỘ PHA', accent: DS.gold),
          _blendGrid(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
  Widget _colorPalette() {
    return Wrap(
      spacing: 7,
      runSpacing: 7,
      children: _palette.map((c) => Obx(() {
        final isSel = controller.selectedColor.value.toARGB32() == c.toARGB32();
        return GestureDetector(
          onTap: () => controller.selectedColor.value = c,
          child: AnimatedContainer(duration: const Duration(milliseconds: 150), width: 28, height: 28, decoration: BoxDecoration(color: c, borderRadius: DS.r8, border: Border.all(color: isSel ? Colors.white : DS.borderHi, width: isSel ? 2 : 1), boxShadow: isSel ? DS.glowShadow(c, radius: 12) : null), child: isSel ? const Icon(Icons.check_rounded, color: Colors.white, size: 14) : null),
        );
      })).toList(),
    );
  }
  Widget _hexRow() {
    return Row(
      children: [
        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: const BoxDecoration(color: DS.textFaint, borderRadius: DS.r8), child: const Text('HEX', style: TextStyle(color: DS.textDim, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.5))),
        const SizedBox(width: 8),
        Expanded(child: Container(height: 36, padding: const EdgeInsets.symmetric(horizontal: 10), decoration: BoxDecoration(color: DS.card, borderRadius: DS.r12, border: Border.all(color: DS.border)), alignment: Alignment.centerLeft, child: Obx(() => Text('#${controller.selectedColor.value.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase().substring(2)}', style: const TextStyle(color: DS.text, fontSize: 12, fontFamily: 'monospace', fontWeight: FontWeight.w600))))),
        const SizedBox(width: 8),
        Obx(() => Container(width: 36, height: 36, decoration: BoxDecoration(color: controller.selectedColor.value, borderRadius: DS.r12, border: Border.all(color: DS.border), boxShadow: DS.glowShadow(controller.selectedColor.value, radius: 14)))),
      ],
    );
  }
  Widget _blendGrid() {
    const modes = ['Normal', 'Multiply', 'Screen', 'Overlay', 'Darken', 'Lighten', 'Dodge', 'Burn', 'Hard Lt', 'Soft Lt'];
    return GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 3.4, mainAxisSpacing: 6, crossAxisSpacing: 6), itemCount: modes.length, itemBuilder: (_, i) => Obx(() {
      final isSel = controller.selectedBlendModeIndex.value == (i + 3);
      return GestureDetector(
        onTap: () => controller.selectedBlendModeIndex.value = i + 3,
        child: AnimatedContainer(duration: const Duration(milliseconds: 150), decoration: BoxDecoration(color: isSel ? DS.violet.withValues(alpha: 0.14) : DS.card, borderRadius: DS.r10, border: Border.all(color: isSel ? DS.violet.withValues(alpha: 0.5) : DS.border)), alignment: Alignment.center, child: Text(modes[i].toUpperCase(), style: TextStyle(color: isSel ? DS.text : DS.textDim, fontSize: 9, fontWeight: isSel ? FontWeight.w900 : FontWeight.w500, letterSpacing: 0.5))),
      );
    }));
  }
}

class _LayoutTab extends StatelessWidget {
  final DrawController controller;
  const _LayoutTab({required this.controller});
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          sectionLabel('KHUNG VẼ', accent: DS.cyan),
          _infoRow('Chiều rộng', '1920 px', DS.cyan),
          _infoRow('Chiều cao',  '1080 px', DS.cyan),
          _infoRow('DPI',        '72',      DS.cyan),
          const SizedBox(height: 20),
          sectionLabel('NỀN', accent: DS.gold),
          _infoRow('Màu nền',    'Trắng', DS.gold),
          _infoRow('Trong suốt', 'Tắt',   DS.gold),
          const SizedBox(height: 20),
          sectionLabel('LƯỚI', accent: DS.mint),
          Obx(() => _toggleRow('Hiện lưới', controller.showGrid.value, DS.mint, () => controller.showGrid.toggle())),
        ],
      ),
    );
  }
  Widget _infoRow(String label, String value, Color accent) {
    return Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), decoration: BoxDecoration(color: DS.card, borderRadius: DS.r12, border: Border.all(color: DS.border)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(color: DS.textDim, fontSize: 12)), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3), decoration: BoxDecoration(color: accent.withValues(alpha: 0.1), borderRadius: DS.r8, border: Border.all(color: accent.withValues(alpha: 0.25))), child: Text(value, style: TextStyle(color: accent, fontSize: 12, fontWeight: FontWeight.w700)))]));
  }
  Widget _toggleRow(String label, bool value, Color accent, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(color: value ? accent.withValues(alpha: 0.08) : DS.card, borderRadius: DS.r12, border: Border.all(color: value ? accent.withValues(alpha: 0.3) : DS.border)),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: TextStyle(color: value ? DS.text : DS.textDim, fontSize: 12, fontWeight: FontWeight.w600)), Container(width: 36, height: 20, decoration: BoxDecoration(color: value ? accent : DS.border, borderRadius: DS.r50), child: AnimatedAlign(duration: const Duration(milliseconds: 200), alignment: value ? Alignment.centerRight : Alignment.centerLeft, child: Container(width: 16, height: 16, margin: const EdgeInsets.symmetric(horizontal: 2), decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle))))]),
      ),
    );
  }
}
