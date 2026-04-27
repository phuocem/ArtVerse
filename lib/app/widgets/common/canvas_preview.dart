import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class CanvasPreviewWidget extends StatelessWidget {
  const CanvasPreviewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.border2, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(
          children: [
            
            Positioned.fill(child: CustomPaint(painter: GridPainter())),
            
            Center(
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.violetPinkColor.withValues(alpha: 0.15),
                ),
              ),
            ),
            Center(
              child: Icon(
                Icons.brush_rounded,
                size: 80,
                color: AppColors.violet2,
              ),
            ),
            
            Positioned(
              top: 20,
              left: 20,
              child: _buildMiniTool(Icons.undo_rounded),
            ),
            Positioned(
              top: 20,
              left: 60,
              child: _buildMiniTool(Icons.redo_rounded),
            ),
            Positioned(
              top: 20,
              right: 20,
              child: _buildMiniTool(Icons.layers_rounded),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniTool(IconData icon) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.bg.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border2, width: 0.5),
      ),
      child: Icon(icon, size: 16, color: AppColors.textSecondary),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = AppColors.border.withValues(alpha: 0.2)
          ..strokeWidth = 0.5;

    const step = 20.0;
    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}