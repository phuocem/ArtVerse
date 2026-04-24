import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/layout_controller.dart';
import '../../../core/theme/app_colors.dart';

class ProTopBar extends GetView<LayoutController> {
  const ProTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 48),
      decoration: BoxDecoration(
        color: AppColors.bg.withOpacity(0.4), 
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Row(
            children: [
              
              _buildBranding(),
              const Spacer(),

              
              _buildHorizontalNav(),

              const Spacer(),

              
              _buildGlobalActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBranding() {
    return Row(
      children: [
        Icon(Icons.bubble_chart_rounded, color: AppColors.violet2.withOpacity(0.8), size: 32),
        const SizedBox(width: 16),
        const Text(
          "ArtVerse",
          style: TextStyle(
            color: AppColors.textPrimary, 
            fontSize: 20, 
            fontWeight: FontWeight.w600, 
            letterSpacing: -0.5,
            fontFamily: 'Lexend',
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalNav() {
    final navItems = [
      {"label": "Home", "index": 0},
      {"label": "Feed", "index": 1},
      {"label": "Vault", "index": 4},
      {"label": "You", "index": 5},
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: navItems.map((item) {
          return Obx(() {
            final isSelected = controller.currentIndex.value == item['index'];
            return GestureDetector(
              onTap: () => controller.currentIndex.value = item['index'] as int,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.violet.withOpacity(0.2) : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  item['label'] as String,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.textSecondary.withOpacity(0.7),
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            );
          });
        }).toList(),
      ),
    );
  }

  Widget _buildGlobalActions() {
    return Row(
      children: [
        _buildActionRound(Icons.search_rounded),
        const SizedBox(width: 16),
        _buildActionRound(Icons.notifications_rounded, hasBadge: true),
      ],
    );
  }

  Widget _buildActionRound(IconData icon, {bool hasBadge = false}) {
    return Container(
      width: 44, height: 44,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 20),
          if (hasBadge)
            Positioned(
              top: 12, right: 12,
              child: Container(
                width: 6, height: 6,
                decoration: const BoxDecoration(color: AppColors.pink, shape: BoxShape.circle),
              ),
            ),
        ],
      ),
    );
  }
}
