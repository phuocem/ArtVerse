import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:artverse/app/data/models/user_model.dart';
import 'package:artverse/app/modules/layout/controllers/layout_controller.dart';
import 'package:artverse/app/modules/profile/controllers/profile_controller.dart';

class ProfileHeader extends StatelessWidget {
  final UserModel user;
  final ProfileController controller;
  final LayoutController lc;

  const ProfileHeader({super.key, required this.user, required this.controller, required this.lc});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(48, 48, 48, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(48),
        color: lc.cardColor.withValues(alpha: 0.1), 
        border: Border.all(color: lc.textColor.withValues(alpha: 0.1), width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 40, offset: const Offset(0, 20)),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(48),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildAvatar(),
                const SizedBox(width: 48),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              user.name.toUpperCase(),
                              style: GoogleFonts.lexend(
                                color: lc.textColor, fontSize: 42, fontWeight: FontWeight.w900, letterSpacing: -1,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (user.isVerified) ...[
                            const SizedBox(width: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00D1FF).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFF00D1FF).withValues(alpha: 0.2)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.verified_rounded, color: Color(0xFF00D1FF), size: 12),
                                  const SizedBox(width: 6),
                                  Text(
                                    "VERIFIED",
                                    style: GoogleFonts.plusJakartaSans(
                                      color: const Color(0xFF00D1FF),
                                      fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          if (user.isStudio) ...[
                            const SizedBox(width: 12),
                            _badge("STUDIO", const Color(0xFFD4AF37)),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user.handle ?? "@${user.name.toLowerCase().replaceAll(' ', '')}",
                        style: GoogleFonts.plusJakartaSans(
                          color: lc.primaryColor, fontSize: 16, fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        user.bio.isNotEmpty ? user.bio : "Nurturing the intersection of digital art and neural networks. No bio provided.",
                        style: GoogleFonts.plusJakartaSans(
                          color: lc.textColor.withValues(alpha: 0.5), fontSize: 15, height: 1.6, fontWeight: FontWeight.w400,
                        ),
                        maxLines: 2, overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 160, height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: lc.primaryColor.withValues(alpha: 0.3), width: 2),
        boxShadow: [
          BoxShadow(color: lc.primaryColor.withValues(alpha: 0.15), blurRadius: 40, offset: const Offset(0, 10)),
        ],
      ),
      padding: const EdgeInsets.all(6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34),
        child: user.avatarUrl != null
            ? CachedNetworkImage(imageUrl: user.avatarUrl!, fit: BoxFit.cover)
            : Container(color: lc.cardColor, child: Icon(Icons.person_rounded, color: lc.textColor.withValues(alpha: 0.1), size: 64)),
      ),
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: GoogleFonts.plusJakartaSans(
          color: color, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1,
        ),
      ),
    );
  }
}
