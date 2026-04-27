import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
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
            child: Icon(Icons.person_outline_rounded, size: 36, color: AppColors.textTertiary),
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
class _LoggedInView extends StatelessWidget {
  final ProfileController controller;
  const _LoggedInView({required this.controller});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ProfileTopBar(controller: controller),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(width: 280, child: _ProfileSidebar(controller: controller)),
              Expanded(child: _ArtworkGrid(controller: controller)),
            ],
          ),
        ),
      ],
    );
  }
}
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
        border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Row(
        children: [
          Text('Profile', style: GoogleFonts.lexend(
            color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(width: 8),
          Obx(() => Text('${controller.post.length} works',
            style: GoogleFonts.ibmPlexMono(color: AppColors.textTertiary, fontSize: 10))),
          const Spacer(),
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
          GestureDetector(
            onTap: () {
              final user = controller.currentUser.value;
              if (user != null) {
                controller.showEditProfileDialog(
                  id: user.id ?? '',
                  name: user.name,
                  bio: user.bio,
                  avatarUrl: user.avatarUrl,
                  onUpdated: () {},
                );
              }
            },
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
                  Icon(Icons.edit_outlined, size: 13, color: AppColors.textSecondary),
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
class _ProfileSidebar extends StatelessWidget {
  final ProfileController controller;
  const _ProfileSidebar({required this.controller});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Obx(() {
        final user = controller.currentUser.value!;
        return ListView(
          padding: EdgeInsets.zero,
          children: [
            
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  height: 90,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      
                      if (user.coverUrl?.isNotEmpty == true)
                        Image.network(user.coverUrl!, fit: BoxFit.cover)
                      else
                        Image.asset('assets/images/branding/background_studio.png', fit: BoxFit.cover),
                      
                      Container(color: Colors.black.withValues(alpha: 0.25)),
                    ],
                  ),
                ),
                Positioned(
                  bottom: -36,
                  child: Stack(
                    children: [
                      Container(
                        width: 72, height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.surface, width: 3),
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
                                      style: GoogleFonts.lexend(color: AppColors.violet, fontSize: 26, fontWeight: FontWeight.w900))),
                            ),
                          ),
                        ),
                      ),
                      if (user.isVerified)
                        Positioned(bottom: 2, right: 2,
                          child: Container(
                            width: 20, height: 20,
                            decoration: BoxDecoration(
                              color: AppColors.teal,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.surface, width: 2),
                            ),
                            child: const Icon(Icons.verified_rounded, size: 10, color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 44),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(user.name, style: GoogleFonts.lexend(
                        color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w900)),
                      if (user.isPro) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            gradient: AppColors.goldGrad,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('PRO', style: GoogleFonts.ibmPlexMono(
                            color: Colors.white, fontSize: 7, fontWeight: FontWeight.w900, letterSpacing: 1)),
                        ),
                      ],
                      if (user.isStudio) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [const Color(0xFFFFAA00), const Color(0xFFFF6600)]),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text('STUDIO', style: GoogleFonts.ibmPlexMono(
                            color: Colors.white, fontSize: 7, fontWeight: FontWeight.w900, letterSpacing: 1)),
                        ),
                      ],
                    ],
                  ),
                  if (user.handle != null && user.handle!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text('@${user.handle}', style: GoogleFonts.ibmPlexMono(
                        color: AppColors.textTertiary, fontSize: 10)),
                    ),
                  
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surface2,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border, width: 0.5),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.violet.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text('LVL ${user.level}', style: GoogleFonts.ibmPlexMono(
                                color: AppColors.violet, fontSize: 9, fontWeight: FontWeight.w900)),
                            ),
                            const Spacer(),
                            Text('${user.xp} XP', style: GoogleFonts.ibmPlexMono(
                              color: AppColors.textTertiary, fontSize: 9)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: ((user.xp % 1000) / 1000).clamp(0.0, 1.0),
                            backgroundColor: AppColors.border,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.violet),
                            minHeight: 4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(height: 0.5, color: AppColors.border, margin: const EdgeInsets.symmetric(horizontal: 16)),
            const SizedBox(height: 12),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (user.bio.isNotEmpty) ...[
                    Text(user.bio, style: GoogleFonts.plusJakartaSans(
                      color: AppColors.textSecondary, fontSize: 12, height: 1.5)),
                    const SizedBox(height: 12),
                  ],
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _StatColumn('${user.followersCount}', 'FOLLOWERS'),
                      _StatColumn('${user.followingCount}', 'FOLLOWING'),
                      _StatColumn('${controller.post.length}', 'WORKS'),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(height: 0.5, color: AppColors.border),
                  const SizedBox(height: 12),
                  
                  if (user.specialties?.isNotEmpty == true) ...[
                    Text('SPECIALTIES', style: GoogleFonts.ibmPlexMono(
                      color: AppColors.textTertiary, fontSize: 8, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6, runSpacing: 6,
                      children: user.specialties!.map((s) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.violet.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.violet.withValues(alpha: 0.2)),
                        ),
                        child: Text(s, style: GoogleFonts.plusJakartaSans(
                          color: AppColors.violet, fontSize: 10, fontWeight: FontWeight.w600)),
                      )).toList(),
                    ),
                    const SizedBox(height: 12),
                    Container(height: 0.5, color: AppColors.border),
                    const SizedBox(height: 12),
                  ],
                  
                  if (user.location?.isNotEmpty == true)
                    _InfoRow(icon: Icons.location_on_outlined, text: user.location!),
                  if (user.website?.isNotEmpty == true)
                    _InfoRow(icon: Icons.link_rounded, text: user.website!, url: user.website!),
                  if (user.instagramUrl?.isNotEmpty == true)
                    _InfoRow(icon: Icons.camera_alt_outlined, text: user.instagramUrl!, url: user.instagramUrl!, baseUrl: 'https://instagram.com/'),
                  if (user.twitterUrl?.isNotEmpty == true)
                    _InfoRow(icon: Icons.alternate_email_rounded, text: user.twitterUrl!, url: user.twitterUrl!, baseUrl: 'https://x.com/'),
                  const SizedBox(height: 12),
                  
                  GestureDetector(
                    onTap: () => Get.toNamed<void>('/wallet'),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface2,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border, width: 0.5),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.account_balance_wallet_outlined, size: 16, color: AppColors.amber),
                          const SizedBox(width: 10),
                          Text('\$${user.balance.toStringAsFixed(2)}',
                            style: GoogleFonts.lexend(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w900)),
                          const Spacer(),
                          Text('WALLET', style: GoogleFonts.ibmPlexMono(
                            color: AppColors.textTertiary, fontSize: 8, fontWeight: FontWeight.w700, letterSpacing: 1)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        );
      }),
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
  final String? url;
  final String? baseUrl;

  const _InfoRow({required this.icon, required this.text, this.url, this.baseUrl});

  Future<void> _handleTap() async {
    if (url == null || url!.isEmpty) return;
    String finalUrl = url!;
    if (!finalUrl.startsWith('http')) {
      if (baseUrl != null) {
        finalUrl = '$baseUrl${finalUrl.replaceAll('@', '')}';
      } else {
        finalUrl = 'https://$finalUrl';
      }
    }
    final uri = Uri.parse(finalUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final row = Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 14, color: url != null ? AppColors.violet : AppColors.textTertiary),
          const SizedBox(width: 8),
          Expanded(child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(color: url != null ? AppColors.violet : AppColors.textSecondary, fontSize: 11, decoration: url != null ? TextDecoration.underline : TextDecoration.none, decorationColor: AppColors.violet))),
        ],
      ),
    );

    if (url != null) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: _handleTap,
          child: row,
        ),
      );
    }
    return row;
  }
}
class _ArtworkGrid extends StatelessWidget {
  final ProfileController controller;
  const _ArtworkGrid({required this.controller});
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final posts = controller.post;
      if (controller.isLoading.value) {
        return Center(child: CircularProgressIndicator(color: AppColors.violet, strokeWidth: 2));
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
                child: Icon(Icons.palette_outlined, size: 28, color: AppColors.textTertiary),
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
      return MasonryGridView.count(
        controller: controller.scrollController,
        padding: const EdgeInsets.all(24),
        crossAxisCount: 3,
        mainAxisSpacing: 20,
        crossAxisSpacing: 16,
        itemCount: posts.length + (controller.isLoadingMore.value ? 1 : 0),
        itemBuilder: (ctx, i) {
          if (i == posts.length) {
            return Center(child: Padding(
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