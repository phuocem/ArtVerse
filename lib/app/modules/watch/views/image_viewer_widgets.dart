import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../data/models/user_model.dart';
import '../../../data/models/comment_model.dart';
import '../../layout/controllers/layout_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../controllers/watch_controller.dart';

// Helper widgets for Image Viewer

Widget buildStatChip(IconData icon, String value, Color color) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          color.withValues(alpha: 0.2),
          color.withValues(alpha: 0.1),
        ],
      ),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: color.withValues(alpha: 0.4),
        width: 1,
      ),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
        Text(
          value,
          style: GoogleFonts.ibmPlexMono(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

Widget buildArtistRow(
  BuildContext context,
  UserModel? user,
  LayoutController lc,
  WatchController controller,
) {
  final pc = Get.find<ProfileController>();
  
  return Row(
    children: [
      // Avatar
      GestureDetector(
        onTap: () => Get.toNamed('/profile/${user?.id}'),
        child: Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                lc.primaryColor,
                lc.primaryColor.withValues(alpha: 0.5),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: lc.primaryColor.withValues(alpha: 0.4),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Container(
            margin: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF0A0A0F),
              image: user?.avatarUrl != null
                  ? DecorationImage(
                      image: NetworkImage(user!.avatarUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: user?.avatarUrl == null
                ? Icon(
                    Icons.person,
                    color: lc.primaryColor,
                    size: 28,
                  )
                : null,
          ),
        ),
      ),
      
      const SizedBox(width: 16),
      
      // Name and info
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  user?.name ?? 'unknown_artist'.tr,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                if (controller.post.value?.coAuthorIds?.isNotEmpty ?? false) ...[
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          lc.primaryColor.withValues(alpha: 0.3),
                          lc.primaryColor.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      "+ ${controller.post.value!.coAuthorIds!.length}",
                      style: GoogleFonts.orbitron(
                        color: lc.primaryColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'VERIFIED CREATOR',
              style: GoogleFonts.orbitron(
                color: lc.primaryColor,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
      
      // Follow button
      Obx(() {
        final isLogined = pc.isLogined.value;
        final currentUser = pc.currentUser.value;

        if (!isLogined || currentUser?.id == user?.id) {
          return const SizedBox.shrink();
        }

        final isFollowing = pc.followingMap[user?.id] ?? false;

        return GestureDetector(
          onTap: () => pc.toggleFollowUser(user),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: isFollowing
                  ? null
                  : LinearGradient(
                      colors: [lc.primaryColor, lc.primaryColor.withValues(alpha: 0.7)],
                    ),
              color: isFollowing ? Colors.white.withValues(alpha: 0.1) : null,
              border: Border.all(
                color: isFollowing
                    ? Colors.white.withValues(alpha: 0.2)
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Text(
              isFollowing ? 'FOLLOWING' : 'FOLLOW',
              style: GoogleFonts.orbitron(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ),
        );
      }),
    ],
  );
}

String formatNumber(int num) {
  if (num >= 1000000) return '${(num / 1000000).toStringAsFixed(1)}M';
  if (num >= 1000) return '${(num / 1000).toStringAsFixed(1)}K';
  return num.toString();
}
