import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/layout_controller.dart';
import '../../settings/views/settings_view.dart';
import '../../settings/controllers/settings_controller.dart';
import '../../settings/repositories/settings_repository.dart';
import '../../settings/providers/settings_provider.dart';

class ProSideRail extends GetView<LayoutController> {
  const ProSideRail({super.key});

  static const _nav = [
    (idx: 0, icon: Icons.auto_awesome_mosaic_rounded, label: 'Home'),
    (idx: 1, icon: Icons.explore_rounded,               label: 'Discover'),
    (idx: 2, icon: Icons.storefront_rounded,            label: 'Market'),
    (idx: 4, icon: Icons.bar_chart_rounded,             label: 'Stats'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: true,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: RepaintBoundary(
          child: Container(
            height: 62,
            alignment: Alignment.center,
            child: Stack(
              alignment: Alignment.center,
              children: [
                
                Obx(() => Container(
                  width: 500, height: 58,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: [
                      BoxShadow(
                        color: controller.primaryColor.withValues(alpha: 0.10),
                        blurRadius: 24,
                        spreadRadius: -8,
                      ),
                    ],
                  ),
                )),

                
                ClipRRect(
                  borderRadius: BorderRadius.circular(26),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: Obx(() => Container(
                      height: 54,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: controller.cardColor.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(
                          color: controller.textColor.withValues(alpha: 0.08),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          
                          Obx(() => Container(
                            width: 34, height: 34,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [controller.primaryColor, controller.primaryColor.withValues(alpha: 0.5)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [BoxShadow(color: controller.primaryColor.withValues(alpha: 0.3), blurRadius: 10)],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: Image.asset(
                                'assets/images/branding/app_icon.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          )),

                          Obx(() => Container(
                            width: 0.5, height: 24,
                            color: controller.textColor.withValues(alpha: 0.1),
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                          )),

                          
                          ..._nav.map((n) => _NavItem(
                            index: n.idx,
                            icon: n.icon,
                            label: n.label,
                          )),

                          Obx(() => Container(
                            width: 0.5, height: 24,
                            color: controller.textColor.withValues(alpha: 0.1),
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                          )),

                          
                          const _AvatarDot(),

                          const SizedBox(width: 6),

                          
                          GestureDetector(
                            onTap: _openSettings,
                            child: Obx(() => Container(
                              width: 34, height: 34,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: controller.textColor.withValues(alpha: 0.04),
                              ),
                              child: Icon(
                                Icons.tune_rounded,
                                color: controller.textColor.withValues(alpha: 0.35),
                                size: 16,
                              ),
                            )),
                          ),
                        ],
                      ),
                    )),
                  ),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.5, end: 0, curve: Curves.easeOutBack),
      ),
    );
  }

  void _openSettings() {
    if (!Get.isRegistered<SettingsController>()) {
      Get.lazyPut<SettingsController>(() => SettingsController(
        repository: SettingsRepository(provider: SettingsProvider()),
      ));
    }
    Get.to<void>(
      () => const SettingsView(),
      transition: Transition.downToUp,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }
}


class _NavItem extends StatelessWidget {
  final int index;
  final IconData icon;
  final String label;

  const _NavItem({required this.index, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final lc = Get.find<LayoutController>();
    
    return Obx(() {
      final active = lc.currentIndex.value == index;
      return GestureDetector(
        onTap: () => lc.currentIndex.value = index,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: EdgeInsets.symmetric(horizontal: active ? 14 : 9, vertical: 7),
          decoration: BoxDecoration(
            color: active ? lc.primaryColor.withValues(alpha: 0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: active ? lc.primaryColor.withValues(alpha: 0.3) : Colors.transparent,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                color: active ? lc.primaryColor : lc.textColor.withValues(alpha: 0.3),
                size: 19),
              if (active) ...[
                const SizedBox(width: 7),
                Text(label.toUpperCase(), style: GoogleFonts.plusJakartaSans(
                  color: lc.primaryColor, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
              ],
            ],
          ),
        ),
      );
    });
  }
}


class _AvatarDot extends StatelessWidget {
  const _AvatarDot();

  @override
  Widget build(BuildContext context) {
    final lc = Get.find<LayoutController>();
    
    return Obx(() {
      final user = lc.profileController.currentUser.value;
      final active = lc.currentIndex.value == 5;
      return GestureDetector(
        onTap: () => lc.currentIndex.value = 5,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          width: 34, height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: active ? lc.primaryColor : lc.primaryColor.withValues(alpha: 0.25),
              width: active ? 2 : 1.5,
            ),
            boxShadow: active
                ? [BoxShadow(color: lc.primaryColor.withValues(alpha: 0.35), blurRadius: 10)]
                : null,
            image: user?.avatarUrl != null
                ? DecorationImage(image: NetworkImage(user!.avatarUrl!), fit: BoxFit.cover)
                : null,
            color: user?.avatarUrl == null ? lc.primaryColor.withValues(alpha: 0.1) : null,
          ),
          child: user?.avatarUrl == null
              ? Icon(Icons.person_rounded, size: 16, color: lc.primaryColor.withValues(alpha: 0.5))
              : null,
        ),
      );
    });
  }
}
