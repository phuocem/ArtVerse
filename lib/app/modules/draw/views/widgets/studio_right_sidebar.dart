import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/draw_controller.dart';
import 'studio_sidebar_layers.dart';
import 'studio_sidebar_frames.dart';
import 'studio_sidebar_properties.dart';
import 'studio_sidebar_export.dart';
import 'studio_widgets.dart';

class StudioRightSidebar extends StatefulWidget {
  final DrawController controller;
  const StudioRightSidebar({super.key, required this.controller});
  @override
  State<StudioRightSidebar> createState() => _StudioRightSidebarState();
}

class _StudioRightSidebarState extends State<StudioRightSidebar>
    with TickerProviderStateMixin {
  late TabController _tab;
  bool _collapsed = false;
  bool _lastIsAnimation = false;

  @override
  void initState() {
    super.initState();
    _lastIsAnimation = widget.controller.isAnimation.value;
    _tab = TabController(length: _lastIsAnimation ? 4 : 3, vsync: this);
  }

  void _rebuildTab(bool isAnimation) {
    if (_lastIsAnimation == isAnimation) return;
    _lastIsAnimation = isAnimation;
    final old = _tab;
    _tab = TabController(length: isAnimation ? 4 : 3, vsync: this);
    old.dispose();
    setState(() {});
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isAnim = widget.controller.isAnimation.value;
      WidgetsBinding.instance.addPostFrameCallback((_) => _rebuildTab(isAnim));
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        width: _collapsed ? 32 : 272,
        decoration: BoxDecoration(
          color: DS.surface,
          border: Border(left: BorderSide(color: DS.border)),
        ),
        child: _collapsed ? _collapsedBar(isAnim) : _expandedPanel(isAnim),
      );
    });
  }

  Widget _collapsedBar(bool isAnim) {
    return Column(
      children: [
        _collapseBtn(),
        const Spacer(),
        _colIcon(Icons.tune_rounded, 0, 'Thuộc tính'),
        _colIcon(Icons.layers_rounded, 1, 'Lớp'),
        if (isAnim) _colIcon(Icons.movie_rounded, 2, 'Frame'),
        _colIcon(isAnim ? Icons.upload_rounded : Icons.upload_rounded, isAnim ? 3 : 2, 'Xuất'),
        const Spacer(),
      ],
    );
  }

  Widget _collapseBtn() {
    return Tooltip(
      message: _collapsed ? 'Mở bảng điều khiển' : 'Thu gọn',
      child: InkWell(
        onTap: () => setState(() => _collapsed = !_collapsed),
        child: Container(
          height: 36,
          width: 32,
          alignment: Alignment.center,
          child: Icon(
            _collapsed ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
            size: 16,
            color: DS.textDim,
          ),
        ),
      ),
    );
  }

  Widget _colIcon(IconData icon, int tabIdx, String tip) {
    return Tooltip(
      message: tip,
      child: InkWell(
        onTap: () {
          setState(() => _collapsed = false);
          _tab.animateTo(tabIdx);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Icon(icon, size: 18, color: DS.textDim),
        ),
      ),
    );
  }

  Widget _expandedPanel(bool isAnim) {
    final tabs = [
      (Icons.tune_rounded, 'Thuộc tính'),
      (Icons.layers_rounded, 'Lớp'),
      if (isAnim) (Icons.movie_rounded, 'Frame'),
      (Icons.upload_rounded, 'Xuất'),
    ];

    final tabViews = [
      StudioSidebarProperties(controller: widget.controller),
      const StudioSidebarLayers(),
      if (isAnim) StudioSidebarFrames(controller: widget.controller),
      StudioSidebarExport(controller: widget.controller),
    ];

    return Column(
      children: [
        _buildTabBar(tabs),
        Expanded(
          child: TabBarView(
            controller: _tab,
            physics: const NeverScrollableScrollPhysics(),
            children: tabViews,
          ),
        ),
      ],
    );
  }

  Widget _buildTabBar(List<(IconData, String)> tabs) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: DS.border)),
      ),
      child: Row(
        children: [
          _collapseBtn(),
          Container(width: 1, height: 28, color: DS.border),
          Expanded(
            child: TabBar(
              controller: _tab,
              labelPadding: EdgeInsets.zero,
              indicatorWeight: 0,
              indicator: BoxDecoration(
                gradient: DS.violetGrad,
                borderRadius: DS.r6,
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              indicatorPadding: const EdgeInsets.all(4),
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: DS.textDim,
              tabs: tabs
                  .map((t) => Tooltip(
                        message: t.$2,
                        child: Tab(child: Icon(t.$1, size: 16)),
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}