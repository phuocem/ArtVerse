import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:artverse/app/modules/layout/controllers/layout_controller.dart';

class DashboardVisionaryCard extends StatelessWidget {
  final LayoutController lc;

  const DashboardVisionaryCard({super.key, required this.lc});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.toNamed<void>('/visionary-hall'),
      child: Container(
        height: 200,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: lc.cardColor,
          border: Border.all(color: lc.textColor.withValues(alpha: 0.06)),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [BoxShadow(color: const Color(0xFFFFD700).withValues(alpha: 0.3), blurRadius: 16)],
                    ),
                    child: const Icon(Icons.stars_rounded, color: Colors.white, size: 22),
                  ),
                  const Spacer(),
                  Text(
                    'VISIONARY\nHALL',
                    style: GoogleFonts.cinzel(
                      color: lc.textColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hall of Fame',
                    style: TextStyle(color: lc.textColor.withValues(alpha: 0.3), fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
