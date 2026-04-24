import 'package:flutter/material.dart';
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
import 'widgets/studio_rulers.dart';

class DrawView extends StatelessWidget {
  const DrawView({super.key});

  @override
  Widget build(BuildContext context) {
    final DrawController controller = Get.find();
    final dynamic args = Get.arguments;
    final String projectId = (args is Map) ? args['projectId'] : (args as String);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadProject(projectId);
    });

    return Scaffold(
      backgroundColor: DS.bg,
      body: Column(
        children: [
          StudioTopBar(controller: controller),
          Expanded(
            child: Row(
              children: [
                StudioLeftSidebar(controller: controller),
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(child: CustomPaint(painter: StudioDotGridPainter())),
                      const StudioRulers(),
                      const Positioned.fill(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(22, 22, 22, 22),
                          child: StudioCanvasContainer(),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        bottom: 0,
                        child: StudioVerticalSliders(controller: controller),
                      ),
                    ],
                  ),
                ),
                StudioRightSidebar(controller: controller),
              ],
            ),
          ),
          StudioStatusBar(controller: controller),
        ],
      ),
    );
  }

  Widget const StudioRulers() {
    return Stack(
      children: [
        Positioned(
          top: 0, left: 20, right: 0,
          child: Container(
            height: 20,
            color: DS.surface,
            child: Row(
              children: List.generate(28, (i) => Expanded(
                child: Container(
                  decoration: const BoxDecoration(border: Border(right: BorderSide(color: DS.border, width: 0.5))),
                  alignment: Alignment.bottomLeft,
                  padding: const EdgeInsets.only(left: 3, bottom: 2),
                  child: Text('${i * 64}', style: const TextStyle(color: DS.textFaint, fontSize: 7, fontFamily: 'monospace')),
                ),
              )),
            ),
          ),
        ),
        Positioned(
          top: 20, left: 0, bottom: 0,
          child: Container(
            width: 20,
            color: DS.surface,
            child: Column(
              children: List.generate(18, (i) => Expanded(
                child: Container(
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: DS.border, width: 0.5))),
                  alignment: Alignment.topRight,
                  padding: const EdgeInsets.only(top: 2, right: 2),
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: Text('${i * 54}', style: const TextStyle(color: DS.textFaint, fontSize: 7, fontFamily: 'monospace')),
                  ),
                ),
              )),
            ),
          ),
        ),
        Positioned(
          top: 0, left: 0,
          child: Container(
            width: 20, height: 20,
            color: DS.surface,
            child: const Icon(Icons.crop_free_rounded, size: 10, color: DS.textFaint),
          ),
        ),
      ],
    );
  }
}
