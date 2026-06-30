import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../layout/controllers/layout_controller.dart';
import '../controllers/draw_controller.dart';
import 'widgets/studio_widgets.dart';
import 'widgets/studio_top_bar.dart';
import 'widgets/studio_right_sidebar.dart';
import 'widgets/studio_status_bar.dart';
import 'widgets/studio_canvas_container.dart';
import 'widgets/studio_dot_grid_painter.dart';
class DrawView extends StatefulWidget {
  const DrawView({super.key});
  @override
  State<DrawView> createState() => _DrawViewState();
}
class _DrawViewState extends State<DrawView> {
  late DrawController controller;
  @override
  void initState() {
    super.initState();
    controller = Get.find<DrawController>();
    final dynamic args = Get.arguments;
    final String projectId =
        (args is Map) ? args['projectId'] : (args as String);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadProject(projectId);
    });
    ServicesBinding.instance.keyboard.addHandler(_onKey);
  }
  @override
  void dispose() {
    ServicesBinding.instance.keyboard.removeHandler(_onKey);
    super.dispose();
  }
  bool _onKey(KeyEvent event) {
    if (event is! KeyDownEvent) return false;
    final isCtrl = HardwareKeyboard.instance.isControlPressed;
    if (isCtrl && event.logicalKey == LogicalKeyboardKey.keyZ) {
      controller.undo();
      return true;
    }
    if (isCtrl && event.logicalKey == LogicalKeyboardKey.keyY) {
      controller.redo();
      return true;
    }
    if (isCtrl && event.logicalKey == LogicalKeyboardKey.keyS) {
      controller.save();
      return true;
    }
    if (event.logicalKey == LogicalKeyboardKey.keyB) {
      controller.selectBrush();
      return true;
    }
    if (event.logicalKey == LogicalKeyboardKey.keyE) {
      controller.selectEraser();
      return true;
    }
    return false;
  }
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isZen = controller.isZenMode.value;
      final rightCollapsed = controller.isSidebarCollapsed.value;

      final double dynamicLeftPadding = isZen ? 0 : 12.0;
      final double dynamicRightPadding = isZen ? 0 : (rightCollapsed ? 60.0 : 264.0);

      final isDark = Get.find<LayoutController>().isDark.value;

      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: isDark
                ? const LinearGradient(
                    colors: [Color(0xFF0A0A0F), Color(0xFF121218)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : const LinearGradient(
                    colors: [Color(0xFFFBFBFD), Color(0xFFF2EFEA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
          ),
          child: KeyboardListener(
            focusNode: FocusNode(),
            autofocus: false,
            child: Stack(
              children: [
                // Glowing background ambient spots (only in dark mode for maximum contrast)
                if (isDark) ...[
                  Positioned(
                    top: -120,
                    left: -120,
                    child: Container(
                      width: 320,
                      height: 320,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: DS.violet.withValues(alpha: 0.12),
                      ),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90),
                        child: const SizedBox.shrink(),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -150,
                    right: -150,
                    child: Container(
                      width: 400,
                      height: 400,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: DS.crimson.withValues(alpha: 0.08),
                      ),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                        child: const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ],

                // 1. BASE LAYER: Full-screen Dot Grid & Zoomable Drawing Canvas
                Positioned.fill(
                  child: CustomPaint(
                    painter: StudioDotGridPainter(),
                  ),
                ),

              if (!isZen) _buildRulers(rightCollapsed),

              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    dynamicLeftPadding,
                    isZen ? 0 : 72.0,  // Clear of Top Bar (12 margin + 48 height + 12 gap = 72)
                    dynamicRightPadding,
                    isZen ? 0 : 52.0,  // Clear of Status Bar (12 margin + 28 height + 12 gap = 52)
                  ),
                  child: const StudioCanvasContainer(),
                ),
              ),

              // 2. OVERLAY LAYER: Floating Glass Panels (Clean 12px Grid Spacing)
              if (!isZen) ...[
                // Top Bar
                Positioned(
                  top: 12, left: 12, right: 12,
                  child: StudioTopBar(controller: controller),
                ),

                // Right Sidebar
                Positioned(
                  right: 12, top: 72, bottom: 52,
                  child: StudioRightSidebar(controller: controller),
                ),

                // Status Bar
                Positioned(
                  bottom: 12, left: 12, right: 12,
                  child: StudioStatusBar(controller: controller),
                ),
              ],

              // 3. ZEN MODE OVERLAYS
              if (isZen) ...[
                _zenExitButton(),
                _zenQuickActions(),
              ],
            ],
          ),
        ),
      ),
    );
  });
}

  Widget _buildRulers(bool rightCollapsed) {
    final double leftOffset = 12.0;
    final double rightOffset = rightCollapsed ? 60.0 : 264.0;

    return Stack(
      children: [
        Positioned(
          top: 72,
          left: leftOffset,
          right: rightOffset,
          child: Container(
            height: 18,
            color: DS.surface.withValues(alpha: 0.7),
            child: Row(
              children: List.generate(
                28,
                (i) => Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                          right:
                              BorderSide(color: DS.border.withValues(alpha: 0.3), width: 0.5)),
                    ),
                    alignment: Alignment.bottomLeft,
                    padding: const EdgeInsets.only(left: 3, bottom: 2),
                    child: Text(
                      '${i * 64}',
                      style: TextStyle(
                          color: DS.textFaint,
                          fontSize: 6.5,
                          fontFamily: 'monospace'),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 90,
          left: leftOffset,
          bottom: 52,
          child: Container(
            width: 18,
            color: DS.surface.withValues(alpha: 0.7),
            child: Column(
              children: List.generate(
                18,
                (i) => Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(color: DS.border.withValues(alpha: 0.3), width: 0.5)),
                    ),
                    alignment: Alignment.topRight,
                    padding: const EdgeInsets.only(top: 2, right: 2),
                    child: RotatedBox(
                      quarterTurns: 3,
                      child: Text(
                        '${i * 54}',
                        style: TextStyle(
                            color: DS.textFaint,
                            fontSize: 6.5,
                            fontFamily: 'monospace'),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 72,
          left: leftOffset,
          child: Container(
            width: 18,
            height: 18,
            color: DS.surface.withValues(alpha: 0.7),
            child: Icon(Icons.crop_free_rounded,
                size: 9, color: DS.textFaint),
          ),
        ),
      ],
    );
  }
  Widget _zenExitButton() {
    return Positioned(
      top: 12,
      right: 12,
      child: Tooltip(
        message: 'Thoát Zen Mode (Z)',
        child: GestureDetector(
          onTap: controller.toggleZenMode,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: DS.surface.withValues(alpha: 0.85),
              borderRadius: DS.r50,
              border: Border.all(color: DS.border),
              boxShadow: DS.elevation,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.fullscreen_exit_rounded,
                    size: 14, color: DS.textDim),
                SizedBox(width: 6),
                Text('Thoát Zen',
                    style: TextStyle(
                        color: DS.textDim,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _zenQuickActions() {
    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: DS.surface.withValues(alpha: 0.9),
            borderRadius: DS.r50,
            border: Border.all(color: DS.border),
            boxShadow: DS.elevation,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _zenBtn(Icons.undo_rounded, controller.undo, 'Undo'),
              _zenSep(),
              _zenBtn(Icons.redo_rounded, controller.redo, 'Redo'),
              _zenSep(),
              Obx(() => _zenColorDot()),
              _zenSep(),
              _zenBtn(Icons.auto_fix_normal_rounded, controller.selectEraser,
                  'Tẩy'),
              _zenSep(),
              _zenBtn(Icons.brush_rounded, controller.selectBrush, 'Cọ vẽ'),
            ],
          ),
        ),
      ),
    );
  }
  Widget _zenBtn(IconData icon, VoidCallback onTap, String tip) {
    return _ZenHoverBtn(icon: icon, onTap: onTap, tip: tip);
  }
  Widget _zenSep() => Container(
      width: 1, height: 20, color: DS.border,
      margin: const EdgeInsets.symmetric(horizontal: 4));
  Widget _zenColorDot() {
    return _ZenColorDot(controller: controller);
  }
}

class _ZenHoverBtn extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tip;
  const _ZenHoverBtn({required this.icon, required this.onTap, required this.tip});

  @override
  State<_ZenHoverBtn> createState() => _ZenHoverBtnState();
}

class _ZenHoverBtnState extends State<_ZenHoverBtn> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tip,
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
        child: AnimatedScale(
          scale: _isHovered ? 1.15 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: GestureDetector(
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              child: Icon(
                widget.icon, 
                size: 18, 
                color: _isHovered ? DS.violet : DS.textDim,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ZenColorDot extends StatefulWidget {
  final DrawController controller;
  const _ZenColorDot({required this.controller});

  @override
  State<_ZenColorDot> createState() => _ZenColorDotState();
}

class _ZenColorDotState extends State<_ZenColorDot> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Màu hiện tại / Thoát Zen',
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
        child: AnimatedScale(
          scale: _isHovered ? 1.15 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: GestureDetector(
            onTap: widget.controller.toggleZenMode,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: widget.controller.selectedColor.value,
                shape: BoxShape.circle,
                border: Border.all(
                  color: _isHovered ? Colors.white : DS.border, 
                  width: 2,
                ),
                boxShadow: DS.glowShadow(widget.controller.selectedColor.value, radius: _isHovered ? 12 : 8),
              ),
            ),
          ),
        ),
      ),
    );
  }
}