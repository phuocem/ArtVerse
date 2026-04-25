import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/global/global_artwork_card.dart';
import '../controllers/profile_controller.dart';

class ProfileViewTablet extends GetView<ProfileController> {
  const ProfileViewTablet({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Obx(() {
        final user = controller.currentUser.value;
        if (user == null) {
          return _GuestView();
        }
        return _LoggedInView(controller: controller);
      }),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// GUEST VIEW
// ════════════════════════════════════════════════════════════════════════

// ignore: must_be_immutable
class _GuestView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: AppColors.violet.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.violet.withValues(alpha: 0.2)),
            ),
            child: const Icon(Icons.person_outline_rounded, size: 36, color: AppColors.textTertiary),
          ),
          const SizedBox(height: 20),
          Text('Sign in to view your profile', style: GoogleFonts.lexend(
            color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('Connect your account to see your artworks and stats',
            style: GoogleFonts.plusJakartaSans(color: AppColors.textTertiary, fontSize: 13)),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: () => Get.toNamed<void>('/login'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              decoration: BoxDecoration(
                gradient: AppColors.violetPink,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('SIGN IN', style: GoogleFonts.ibmPlexMono(
                color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2)),
            ),
          ),
        ],
      ).animate().fadeIn(duration: 600.ms),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════
// LOGGED IN VIEW
// ════════════════════════════════════════════════════════════════════════

class _LoggedInView extends StatelessWidget {
  final ProfileController controller;
  const _LoggedInView({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top bar
        _ProfileTopBar(controller: controller),

        // Content
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: profile card + stats
              SizedBox(width: 280, child: _ProfileSidebar(controller: controller)),

              // Right: artwork grid
              Expanded(child: _ArtworkGrid(controller: controller)),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Top Bar ──────────────────────────────────────────────────────────────

class _ProfileTopBar extends StatelessWidget {
  final ProfileController controller;
  const _ProfileTopBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.9),
        border: const Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Row(
        children: [
          Text('Profile', style: GoogleFonts.lexend(
            color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(width: 8),
          Obx(() => Text('${controller.post.length} works',
            style: GoogleFonts.ibmPlexMono(color: AppColors.textTertiary, fontSize: 10))),
          const Spacer(),

          // Tab filter
          Obx(() => Row(
            children: controller.tabArt.map((tab) {
              final active = controller.selectedTab.value == tab;
              return GestureDetector(
                onTap: () => controller.selectedTab.value = tab,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(left: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: active ? AppColors.violet.withValues(alpha: 0.12) : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: active ? AppColors.violet.withValues(alpha: 0.3) : AppColors.border,
                      width: 0.5,
                    ),
                  ),
                  child: Text(tab, style: GoogleFonts.plusJakartaSans(
                    color: active ? AppColors.violet : AppColors.textTertiary,
                    fontSize: 11, fontWeight: active ? FontWeight.w700 : FontWeight.w500)),
                ),
              );
            }).toList(),
          )),

          const SizedBox(width: 12),

          // Edit profile
          GestureDetector(
            onTap: () => Get.toNamed<void>('/profile/edit'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surface2,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border, width: 0.5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.edit_outlined, size: 13, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text('Edit', style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sidebar ───────────────────────────────────────────────────────────

class _ProfileSidebar extends StatelessWidget {
  final ProfileController controller;
  const _ProfileSidebar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Avatar + name
          Obx(() {
            final user = controller.currentUser.value!;
            return Column(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 80, height: 80,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppColors.violetPink,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: ClipOval(
                          child: Container(
                            color: AppColors.surface2,
                            child: user.avatarUrl?.isNotEmpty == true
                                ? Image.network(user.avatarUrl!, fit: BoxFit.cover)
                                : Center(child: Text(
                                    user.name.isNotEmpty ? user.name[0] : '?',
                                    style: GoogleFonts.lexend(color: AppColors.violet, fontSize: 28, fontWeight: FontWeight.w900))),
                          ),
                        ),
                      ),
                    ),
                    if (user.isVerified)
                      Positioned(bottom: 0, right: 0,
                        child: Container(
                          width: 22, height: 22,
                          decoration: BoxDecoration(
                            color: AppColors.teal,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.surface, width: 2),
                          ),
                          child: const Icon(Icons.verified_rounded, size: 12, color: Colors.white),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(user.name, style: GoogleFonts.lexend(
                  color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w900)),
                if (user.handle != null)
                  Text('@${user.handle}', style: GoogleFonts.ibmPlexMono(
                    color: AppColors.textTertiary, fontSize: 11)),
                if (user.isStudio)
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: AppColors.goldGrad,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('STUDIO', style: GoogleFonts.ibmPlexMono(
                      color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 2)),
                  ),
              ],
            );
          }),

          const SizedBox(height: 20),
          Container(height: 0.5, color: AppColors.border),
          const SizedBox(height: 16),

          // Bio
          Obx(() {
            final bio = controller.currentUser.value?.bio ?? '';
            if (bio.isNotEmpty) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(bio, style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textSecondary, fontSize: 12, height: 1.5)),
              );
            }
            return const SizedBox.shrink();
          }),

          // Stats
          Obx(() {
            final user = controller.currentUser.value!;
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatColumn('${user.followersCount}', 'FOLLOWERS'),
                _StatColumn('${user.followingCount}', 'FOLLOWING'),
                _StatColumn('${controller.post.length}', 'WORKS'),
              ],
            );
          }),

          const SizedBox(height: 16),
          Container(height: 0.5, color: AppColors.border),
          const SizedBox(height: 16),

          // Location + website
          Obx(() {
            final user = controller.currentUser.value!;
            return Column(
              children: [
                if (user.location?.isNotEmpty == true)
                  _InfoRow(icon: Icons.location_on_outlined, text: user.location!),
                if (user.website?.isNotEmpty == true)
                  _InfoRow(icon: Icons.link_rounded, text: user.website!),
                if (user.instagramUrl?.isNotEmpty == true)
                  const _InfoRow(icon: Icons.camera_alt_outlined, text: 'Instagram'),
                if (user.twitterUrl?.isNotEmpty == true)
                  const _InfoRow(icon: Icons.alternate_email_rounded, text: 'Twitter / X'),
              ],
            );
          }),

          const SizedBox(height: 20),

          // Wallet shortcut
          GestureDetector(
            onTap: () => Get.toNamed<void>('/wallet'),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface2,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border, width: 0.5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.account_balance_wallet_outlined, size: 16, color: AppColors.amber),
                  const SizedBox(width: 10),
                  Obx(() => Text('\$${controller.currentUser.value?.balance.toStringAsFixed(2) ?? '0.00'}',
                    style: GoogleFonts.lexend(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w900))),
                  const Spacer(),
                  Text('WALLET', style: GoogleFonts.ibmPlexMono(
                    color: AppColors.textTertiary, fontSize: 8, fontWeight: FontWeight.w700, letterSpacing: 1)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String value;
  final String label;
  const _StatColumn(this.value, this.label);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.lexend(
          color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w900)),
        Text(label, style: GoogleFonts.ibmPlexMono(
          color: AppColors.textTertiary, fontSize: 8, fontWeight: FontWeight.w700, letterSpacing: 1)),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.textTertiary),
          const SizedBox(width: 8),
          Expanded(child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 11))),
        ],
      ),
    );
  }
}

// ── Artwork Grid ──────────────────────────────────────────────────────

class _ArtworkGrid extends StatelessWidget {
  final ProfileController controller;
  const _ArtworkGrid({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final posts = controller.post;
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator(color: AppColors.violet, strokeWidth: 2));
      }
      if (posts.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  color: AppColors.violet.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.palette_outlined, size: 28, color: AppColors.textTertiary),
              ),
              const SizedBox(height: 14),
              Text('No artworks yet', style: GoogleFonts.plusJakartaSans(
                color: AppColors.textTertiary, fontSize: 14)),
              const SizedBox(height: 6),
              Text('Share your creations with the world', style: GoogleFonts.plusJakartaSans(
                color: AppColors.textTertiary.withValues(alpha: 0.6), fontSize: 12)),
            ],
          ).animate().fadeIn(duration: 600.ms),
        );
      }

      return GridView.builder(
        controller: controller.scrollController,
        padding: const EdgeInsets.all(24),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        itemCount: posts.length + (controller.isLoadingMore.value ? 1 : 0),
        itemBuilder: (ctx, i) {
          if (i == posts.length) {
            return const Center(child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(color: AppColors.violet, strokeWidth: 2),
            ));
          }
          return GlobalArtworkCard(
            post: posts[i],
            onTap: () => Get.toNamed<void>('/view/${posts[i].id}'),
          ).animate(delay: Duration(milliseconds: 50 * (i % 9)))
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.08, end: 0, curve: Curves.easeOutQuad);
        },
      );
    });
  }
}