import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/draw_controller.dart';
import 'widgets/studio_widgets.dart';
import 'widgets/studio_top_bar.dart';
import 'widgets/studio_left_sidebar.dart';
import 'widgets/studio_right_sidebar.dart';
import 'widgets/studio_status_bar.dart';
import 'widgets/studio_canvas_container.dart';
import 'widgets/studio_vertical_sliders.dart';
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
      return Scaffold(
        backgroundColor: DS.bg,
        body: KeyboardListener(
          focusNode: FocusNode(),
          autofocus: false,
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: isZen ? 0 : 48,
                child: isZen
                    ? const SizedBox.shrink()
                    : StudioTopBar(controller: controller),
              ),
              Expanded(
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: isZen ? 0 : null,
                      child: isZen
                          ? const SizedBox.shrink()
                          : StudioLeftSidebar(controller: controller),
                    ),
                    Expanded(
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: CustomPaint(
                              painter: StudioDotGridPainter(),
                            ),
                          ),
                          if (!isZen) _buildRulers(),
                          Positioned.fill(
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(
                                isZen ? 0 : 18,
                                isZen ? 0 : 18,
                                isZen ? 0 : 18,
                                isZen ? 0 : 18,
                              ),
                              child: const StudioCanvasContainer(),
                            ),
                          ),
                          if (!isZen)
                            Positioned(
                              right: 0,
                              top: 0,
                              bottom: 0,
                              child: StudioVerticalSliders(
                                  controller: controller),
                            ),
                          if (isZen) _zenExitButton(),
                          if (isZen) _zenQuickActions(),
                        ],
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: isZen ? 0 : null,
                      child: isZen
                          ? const SizedBox.shrink()
                          : StudioRightSidebar(controller: controller),
                    ),
                  ],
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: isZen ? 0 : 26,
                child: isZen
                    ? const SizedBox.shrink()
                    : StudioStatusBar(controller: controller),
              ),
            ],
          ),
        ),
      );
    });
  }
  Widget _buildRulers() {
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 18,
          right: 52,
          child: Container(
            height: 18,
            color: DS.surface,
            child: Row(
              children: List.generate(
                28,
                (i) => Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                          right:
                              BorderSide(color: DS.border, width: 0.5)),
                    ),
                    alignment: Alignment.bottomLeft,
                    padding: const EdgeInsets.only(left: 3, bottom: 2),
                    child: Text(
                      '${i * 64}',
                      style: const TextStyle(
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
          top: 18,
          left: 0,
          bottom: 0,
          child: Container(
            width: 18,
            color: DS.surface,
            child: Column(
              children: List.generate(
                18,
                (i) => Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                          bottom: BorderSide(color: DS.border, width: 0.5)),
                    ),
                    alignment: Alignment.topRight,
                    padding: const EdgeInsets.only(top: 2, right: 2),
                    child: RotatedBox(
                      quarterTurns: 3,
                      child: Text(
                        '${i * 54}',
                        style: const TextStyle(
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
          top: 0,
          left: 0,
          child: Container(
            width: 18,
            height: 18,
            color: DS.surface,
            child: const Icon(Icons.crop_free_rounded,
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
            child: const Row(
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
    return Tooltip(
      message: tip,
      child: InkWell(
        onTap: onTap,
        borderRadius: DS.r50,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Icon(icon, size: 18, color: DS.textDim),
        ),
      ),
    );
  }
  Widget _zenSep() => Container(
      width: 1, height: 20, color: DS.border,
      margin: const EdgeInsets.symmetric(horizontal: 4));
  Widget _zenColorDot() {
    return GestureDetector(
      onTap: () {
        controller.toggleZenMode();
      },
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: controller.selectedColor.value,
          shape: BoxShape.circle,
          border: Border.all(color: DS.border, width: 2),
          boxShadow: DS.glowShadow(controller.selectedColor.value, radius: 8),
        ),
      ),
    );
  }
}
