import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:artverse/app/modules/layout/controllers/layout_controller.dart';
import 'package:artverse/app/modules/profile/controllers/profile_controller.dart';

class DashboardStudioCard extends StatelessWidget {
  final LayoutController lc;

  const DashboardStudioCard({super.key, required this.lc});

  @override
  Widget build(BuildContext context) {
    final profileController = Get.find<ProfileController>();
    return Obx(() {
      final user = profileController.currentUser.value;
      final isStudio = user?.isStudio ?? false;

      return GestureDetector(
        onTap: () => Get.toNamed<void>(isStudio ? '/home' : '/studio-upgrade'),
        child: Container(
          height: 200,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                lc.primaryColor.withValues(alpha: 0.8),
                lc.accentColor.withValues(alpha: 0.5),
                lc.primaryColor.withValues(alpha: 0.3),
              ],
            ),
            boxShadow: [
              BoxShadow(color: lc.primaryColor.withValues(alpha: 0.2), blurRadius: 30, offset: const Offset(0, 12)),
            ],
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.stars_rounded, color: Colors.amber, size: 11),
                              const SizedBox(width: 6),
                              Text(
                                isStudio ? 'STUDIO ACTIVE' : 'STUDIO',
                                style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1.5),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      isStudio ? 'Professional\nWorkspace' : 'Upgrade to Studio\nStudio',
                      style: GoogleFonts.lexend(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, height: 1.1),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isStudio ? 'Full access to all professional tools' : 'Upgrade to studio grade tools',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 12),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Text(
                          isStudio ? 'ENTER STUDIO →' : 'UPGRADE NOW →',
                          style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
