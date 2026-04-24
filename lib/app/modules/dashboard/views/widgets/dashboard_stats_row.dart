import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math' as math;
import 'package:artverse/app/modules/layout/controllers/layout_controller.dart';
import 'package:artverse/app/modules/profile/controllers/profile_controller.dart';

class DashboardStatsRow extends StatelessWidget {
  final LayoutController lc;

  const DashboardStatsRow({super.key, required this.lc});

  @override
  Widget build(BuildContext context) {
    final profileController = Get.find<ProfileController>();
    return Obx(() {
      final user = profileController.currentUser.value;
      if (user == null) return const SizedBox.shrink();

      final stats = [
        _StatData('REACH', _fmt(user.viewsCount), Icons.visibility_rounded, const Color(0xFF60A5FA)),
        _StatData('FANS', _fmt(user.followersCount), Icons.people_rounded, const Color(0xFFA78BFA)),
        _StatData('SALES', '${user.balance.toInt()}', Icons.attach_money_rounded, const Color(0xFF34D399)),
        _StatData('SCORE', '${((user.likesCount * 2 + user.viewsCount) / 10).clamp(0, 99).toInt()}', Icons.star_rounded, const Color(0xFFFBBF24)),
      ];

      return Row(
        children: stats.asMap().entries.map((e) {
          final s = e.value;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(left: e.key == 0 ? 0 : 16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: lc.cardColor.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: lc.textColor.withValues(alpha: 0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: s.color.withValues(alpha: 0.1),
                        ),
                        child: Icon(s.icon, size: 16, color: s.color),
                      ),
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    s.value,
                    style: GoogleFonts.lexend(
                      color: lc.textColor,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    s.label,
                    style: GoogleFonts.plusJakartaSans(
                      color: lc.textColor.withValues(alpha: 0.3),
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}

class _StatData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatData(this.label, this.value, this.icon, this.color);
}
