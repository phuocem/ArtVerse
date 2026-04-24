import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'draw_controller.dart';
import '../../../data/models/draw/drawn_line_model.dart';

class AiDrawController extends GetxController {
  final drawController = Get.find<DrawController>();
  
  final isGenerating = false.obs;
  final lastPrompt = ''.obs;

  
  
  Future<void> generateSketchFromPrompt(String prompt) async {
    if (prompt.isEmpty) return;
    
    isGenerating.value = true;
    lastPrompt.value = prompt;

    try {
      
      await Future.delayed(const Duration(seconds: 2));
      
      final List<DrawnLine> generatedLines = _mockAIGeneratedOutline(prompt);
      
      for (final line in generatedLines) {
        drawController.currentLines.add(line);
      }
      
      drawController.isChanged.value = true;
      drawController.updateBackgroundPicture();
      
      Get.snackbar(
        'AI Success',
        'Outline generated for: $prompt',
        backgroundColor: Colors.indigo.withValues(alpha: 0.8),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('AI Error', 'Failed to generate sketch');
    } finally {
      isGenerating.value = false;
    }
  }

  
  
  void generatePoseSkeleton() {
    final center = const Offset(500, 300);
    final skeleton = [
      
      DrawnLine(
        points: [center, center + const Offset(0, 100)],
        colorValue: Colors.blueGrey.toARGB32(),
        width: 2.0,
      ),
      
      DrawnLine(
        points: [center + const Offset(0, 30), center + const Offset(-80, 80)],
        colorValue: Colors.blueGrey.toARGB32(),
        width: 2.0,
      ),
      DrawnLine(
        points: [center + const Offset(0, 30), center + const Offset(80, 80)],
        colorValue: Colors.blueGrey.toARGB32(),
        width: 2.0,
      ),
    ];
    
    drawController.currentLines.addAll(skeleton);
    drawController.updateBackgroundPicture();
  }

  List<DrawnLine> _mockAIGeneratedOutline(String prompt) {
    
    
    final List<DrawnLine> lines = [];
    final center = const Offset(600, 400);
    
    if (prompt.contains('cat')) {
      
      lines.add(DrawnLine(
        points: [center, center + const Offset(50, 50), center + const Offset(-50, 50), center],
        colorValue: Colors.white54.toARGB32(),
        width: 3,
      ));
    } else {
      
      final List<Offset> circlePoints = [];
      for (int i = 0; i <= 36; i++) {
        final angle = i * 10 * 3.14 / 180;
        circlePoints.add(center + Offset(100 * (1 + 0.2 * i % 2), 100 * (1 + 0.2 * i % 2)));
      }
      lines.add(DrawnLine(points: circlePoints, colorValue: Colors.white38.toARGB32(), width: 2));
    }
    
    return lines;
  }
}
