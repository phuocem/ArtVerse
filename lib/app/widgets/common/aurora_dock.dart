import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../modules/layout/controllers/layout_controller.dart';

class AuroraFloatingDock extends StatelessWidget {
  final LayoutController controller;
  const AuroraFloatingDock({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = controller.isDark.value;
      
      return Container(
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: controller.surfaceColor.withValues(alpha: isDark ? 0.3 : 0.8),
          borderRadius: BorderRadius.circular(40),
          border: Border.all(
            color: Colors.white.withValues(alpha: isDark ? 0.08 : 0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: controller.primaryColor.withValues(alpha: 0.2),
              blurRadius: 30,
              spreadRadius: -5,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDockItem(MdiIcons.leaf, 0, 'garden'.tr),
                _buildDockItem(MdiIcons.brushVariant, 1, 'studio'.tr),
                _buildDockItem(MdiIcons.storeOutline, 2, 'market'.tr),
                _buildSeparator(),
                _buildDockItem(MdiIcons.trophyOutline, 3, 'challenges'.tr),
                _buildDockItem(MdiIcons.chartDonut, 4, 'stats'.tr),
                _buildDockItem(MdiIcons.accountOutline, 5, 'profile'.tr),
                _buildSeparator(),
                _buildGardenItem(),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildGardenItem() {
    return Tooltip(
      message: 'Vườn Thú Cưng',
      child: GestureDetector(
        onTap: () => Get.toNamed('/garden'),
        child: Container(
          width: 48,
          height: 48,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            MdiIcons.leaf,
            color: Colors.white70,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildSeparator() {
    return Container(
      width: 1.2,
      height: 20,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.white.withValues(alpha: 0.1),
    );
  }

  Widget _buildDockItem(IconData icon, int index, String label) {
    final isSelected = controller.currentIndex.value == index;
    
    return Tooltip(
      message: label,
      child: GestureDetector(
        onTap: () => controller.onTabChange(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          width: isSelected ? 56 : 48,
          height: isSelected ? 56 : 48,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: isSelected ? controller.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(getSelectedRadius(isSelected)),
            boxShadow: isSelected ? [
              BoxShadow(
                color: controller.primaryColor.withValues(alpha: 0.4),
                blurRadius: 15,
                spreadRadius: 2,
              )
            ] : [],
          ),
          child: Icon(
            icon,
            color: isSelected ? Colors.black : controller.onLayoutColor.withValues(alpha: 0.6),
            size: 24,
          ),
        ),
      ),
    );
  }


  double getSelectedRadius(bool selected) => selected ? 18 : 12;
}
