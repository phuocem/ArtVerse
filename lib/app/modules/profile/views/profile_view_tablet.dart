import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/global/global_artwork_card.dart';
import '../controllers/profile_controller.dart';
import '../../layout/controllers/layout_controller.dart';

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
    final lc = Get.find<LayoutController>();
    return Column(
      children: [
        _ProfileTopBar(controller: controller),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 290, 
                decoration: BoxDecoration(
                  border: Border(right: BorderSide(color: AppColors.border, width: 0.8)),
                ),
                child: _ProfileSidebar(controller: controller),
              ),
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
    final lc = Get.find<LayoutController>();
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.9),
        border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 6, height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: lc.primaryColor,
              boxShadow: [
                BoxShadow(
                  color: lc.primaryColor.withValues(alpha: 0.6),
                  blurRadius: 4,
                  spreadRadius: 1,
                )
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text('Profile', style: GoogleFonts.lexend(
            color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w800, letterSpacing: -0.2)),
          const SizedBox(width: 8),
          Obx(() => Text('${controller.filteredPosts.length} works',
            style: GoogleFonts.ibmPlexMono(color: AppColors.textTertiary, fontSize: 10, fontWeight: FontWeight.w700))),
          const Spacer(),
          Obx(() => Row(
            children: controller.tabArt.map((tab) {
              final active = controller.selectedTab.value == tab;
              return GestureDetector(
                onTap: () => controller.selectedTab.value = tab,
                child: _SegmentTab(label: tab, active: active),
              );
            }).toList(),
          )),
          const SizedBox(width: 12),
          _EditProfileBtn(controller: controller),
        ],
      ),
    );
  }
}

class _SegmentTab extends StatefulWidget {
  final String label;
  final bool active;
  const _SegmentTab({required this.label, required this.active});

  @override
  State<_SegmentTab> createState() => _SegmentTabState();
}

class _SegmentTabState extends State<_SegmentTab> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final lc = Get.find<LayoutController>();
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(left: 6),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            gradient: widget.active
                ? AppColors.violetPink
                : (_isHovered
                    ? LinearGradient(colors: [
                        lc.primaryColor.withValues(alpha: 0.1),
                        AppColors.pink.withValues(alpha: 0.05)
                      ])
                    : null),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.active
                  ? Colors.transparent
                  : (_isHovered
                      ? lc.primaryColor.withValues(alpha: 0.4)
                      : AppColors.border),
              width: 0.8,
            ),
            boxShadow: widget.active
                ? [
                    BoxShadow(
                      color: lc.primaryColor.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    )
                  ]
                : [],
          ),
          child: Text(
            widget.label,
            style: GoogleFonts.plusJakartaSans(
              color: widget.active
                  ? Colors.white
                  : (_isHovered ? lc.primaryColor : AppColors.textTertiary),
              fontSize: 11,
              fontWeight: widget.active || _isHovered ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _EditProfileBtn extends StatefulWidget {
  final ProfileController controller;
  const _EditProfileBtn({required this.controller});

  @override
  State<_EditProfileBtn> createState() => _EditProfileBtnState();
}

class _EditProfileBtnState extends State<_EditProfileBtn> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final lc = Get.find<LayoutController>();
    return GestureDetector(
      onTap: () {
        final user = widget.controller.currentUser.value;
        if (user != null) {
          widget.controller.showEditProfileDialog(
            id: user.id ?? '',
            name: user.name,
            bio: user.bio,
            avatarUrl: user.avatarUrl,
            onUpdated: () {},
          );
        }
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedScale(
          scale: _isHovered ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: _isHovered ? lc.primaryColor.withValues(alpha: 0.1) : AppColors.surface2,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _isHovered ? lc.primaryColor.withValues(alpha: 0.4) : AppColors.border,
                width: 0.8,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.edit_outlined, size: 14, color: _isHovered ? lc.primaryColor : AppColors.textSecondary),
                const SizedBox(width: 6),
                Text('Edit', style: GoogleFonts.plusJakartaSans(
                  color: _isHovered ? lc.primaryColor : AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileSidebar extends StatelessWidget {
  final ProfileController controller;
  const _ProfileSidebar({required this.controller});

  @override
  Widget build(BuildContext context) {
    final lc = Get.find<LayoutController>();
    return Container(
      color: lc.backgroundColor,
      child: Obx(() {
        final user = controller.currentUser.value!;
        return ListView(
          padding: EdgeInsets.zero,
          physics: const BouncingScrollPhysics(),
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  height: 110,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (user.coverUrl?.isNotEmpty == true)
                        Image.network(user.coverUrl!, fit: BoxFit.cover)
                      else
                        Image.asset('assets/images/branding/background_studio.png', fit: BoxFit.cover),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.1),
                              Colors.black.withValues(alpha: 0.5),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: -36,
                  child: Stack(
                    children: [
                      Container(
                        width: 76, height: 76,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: lc.backgroundColor, width: 3),
                          gradient: AppColors.violetPink,
                          boxShadow: [
                            BoxShadow(
                              color: lc.primaryColor.withValues(alpha: 0.25),
                              blurRadius: 12,
                            )
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(2.0),
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
                        Positioned(bottom: 2, right: 2,
                          child: Container(
                            width: 22, height: 22,
                            decoration: BoxDecoration(
                              color: AppColors.teal,
                              shape: BoxShape.circle,
                              border: Border.all(color: lc.backgroundColor, width: 2.5),
                            ),
                            child: const Icon(Icons.verified_rounded, size: 10, color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),
            
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
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                                blurRadius: 4,
                              )
                            ],
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
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFF8800).withValues(alpha: 0.3),
                                blurRadius: 4,
                              )
                            ],
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
                        color: AppColors.textTertiary, fontSize: 10, fontWeight: FontWeight.w600)),
                    ),
                  
                  const SizedBox(height: 16),
                  _LevelCard(user: user),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (user.bio.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: lc.textColor.withValues(alpha: 0.02),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border, width: 0.5),
                      ),
                      child: Text(user.bio, style: GoogleFonts.plusJakartaSans(
                        color: AppColors.textSecondary, fontSize: 12, height: 1.5)),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  _StatsCard(user: user, postCount: controller.post.length),
                  const SizedBox(height: 16),
                  
                  if (user.specialties?.isNotEmpty == true) ...[
                    _SpecialtiesCard(specialties: user.specialties!),
                    const SizedBox(height: 16),
                  ],
                  
                  _SocialLinksCard(user: user),
                  const SizedBox(height: 16),
                  
                  _WalletCard(balance: user.balance),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _LevelCard extends StatefulWidget {
  final dynamic user;
  const _LevelCard({required this.user});

  @override
  State<_LevelCard> createState() => _LevelCardState();
}

class _LevelCardState extends State<_LevelCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final lc = Get.find<LayoutController>();
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _isHovered ? lc.primaryColor.withValues(alpha: 0.08) : lc.textColor.withValues(alpha: 0.03),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _isHovered ? lc.primaryColor.withValues(alpha: 0.3) : AppColors.border, 
              width: 0.8,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      gradient: AppColors.violetPink,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text('LVL ${widget.user.level}', style: GoogleFonts.ibmPlexMono(
                      color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900)),
                  ),
                  const Spacer(),
                  Text('${widget.user.xp} XP', style: GoogleFonts.ibmPlexMono(
                    color: lc.textColor.withValues(alpha: 0.7), fontSize: 10, fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 8),
              Stack(
                children: [
                  Container(
                    height: 6,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: ((widget.user.xp % 1000) / 1000).clamp(0.02, 1.0),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 6,
                      decoration: BoxDecoration(
                        gradient: AppColors.violetPink,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.violet.withValues(alpha: 0.3),
                            blurRadius: 4,
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsCard extends StatefulWidget {
  final dynamic user;
  final int postCount;
  const _StatsCard({required this.user, required this.postCount});

  @override
  State<_StatsCard> createState() => _StatsCardState();
}

class _StatsCardState extends State<_StatsCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final lc = Get.find<LayoutController>();
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: lc.textColor.withValues(alpha: 0.02),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _isHovered ? lc.primaryColor.withValues(alpha: 0.25) : AppColors.border, 
              width: 0.8,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: lc.primaryColor.withValues(alpha: 0.04),
                      blurRadius: 10,
                    )
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatColumn('${widget.user.followersCount}', 'FOLLOWERS', AppColors.teal),
              Container(width: 0.8, height: 24, color: AppColors.border),
              _StatColumn('${widget.user.followingCount}', 'FOLLOWING', AppColors.pink),
              Container(width: 0.8, height: 24, color: AppColors.border),
              _StatColumn('${widget.postCount}', 'WORKS', lc.primaryColor),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String value;
  final String label;
  final Color glowColor;
  const _StatColumn(this.value, this.label, this.glowColor);

  @override
  Widget build(BuildContext context) {
    final lc = Get.find<LayoutController>();
    return Column(
      children: [
        Text(value, style: GoogleFonts.lexend(
          color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w900)),
        const SizedBox(height: 2),
        Text(label, style: GoogleFonts.ibmPlexMono(
          color: lc.textColor.withValues(alpha: 0.5), fontSize: 8, fontWeight: FontWeight.w800, letterSpacing: 1.0)),
      ],
    );
  }
}

class _SpecialtiesCard extends StatelessWidget {
  final List<String> specialties;
  const _SpecialtiesCard({required this.specialties});

  @override
  Widget build(BuildContext context) {
    final lc = Get.find<LayoutController>();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: lc.textColor.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4, height: 4,
                decoration: BoxDecoration(shape: BoxShape.circle, color: lc.primaryColor),
              ),
              const SizedBox(width: 6),
              Text('SPECIALTIES', style: GoogleFonts.ibmPlexMono(
                color: AppColors.textTertiary, fontSize: 8, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6, runSpacing: 6,
            children: specialties.map((s) => _SpecialtyTag(tag: s)).toList(),
          ),
        ],
      ),
    );
  }
}

class _SpecialtyTag extends StatefulWidget {
  final String tag;
  const _SpecialtyTag({required this.tag});

  @override
  State<_SpecialtyTag> createState() => _SpecialtyTagState();
}

class _SpecialtyTagState extends State<_SpecialtyTag> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final lc = Get.find<LayoutController>();
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.06 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: _isHovered ? lc.primaryColor : lc.primaryColor.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isHovered ? Colors.transparent : lc.primaryColor.withValues(alpha: 0.2),
              width: 0.8,
            ),
          ),
          child: Text(
            widget.tag,
            style: GoogleFonts.plusJakartaSans(
              color: _isHovered ? Colors.white : lc.primaryColor,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialLinksCard extends StatelessWidget {
  final dynamic user;
  const _SocialLinksCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final lc = Get.find<LayoutController>();
    final hasLinks = user.location?.isNotEmpty == true ||
        user.website?.isNotEmpty == true ||
        user.instagramUrl?.isNotEmpty == true ||
        user.twitterUrl?.isNotEmpty == true;

    if (!hasLinks) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: lc.textColor.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: Column(
        children: [
          if (user.location?.isNotEmpty == true)
            _InfoRow(icon: Icons.location_on_outlined, text: user.location!, color: AppColors.amber),
          if (user.website?.isNotEmpty == true)
            _InfoRow(icon: Icons.link_rounded, text: user.website!, url: user.website!, color: AppColors.teal),
          if (user.instagramUrl?.isNotEmpty == true)
            _InfoRow(icon: Icons.camera_alt_outlined, text: user.instagramUrl!, url: user.instagramUrl!, baseUrl: 'https://instagram.com/', color: AppColors.pink),
          if (user.twitterUrl?.isNotEmpty == true)
            _InfoRow(icon: Icons.alternate_email_rounded, text: user.twitterUrl!, url: user.twitterUrl!, baseUrl: 'https://x.com/', color: lc.primaryColor),
        ],
      ),
    );
  }
}

class _InfoRow extends StatefulWidget {
  final IconData icon;
  final String text;
  final String? url;
  final String? baseUrl;
  final Color color;

  const _InfoRow({
    required this.icon,
    required this.text,
    this.url,
    this.baseUrl,
    required this.color,
  });

  @override
  State<_InfoRow> createState() => _InfoRowState();
}

class _InfoRowState extends State<_InfoRow> {
  bool _isHovered = false;

  Future<void> _handleTap() async {
    if (widget.url == null || widget.url!.isEmpty) return;
    String finalUrl = widget.url!;
    if (!finalUrl.startsWith('http')) {
      if (widget.baseUrl != null) {
        finalUrl = '${widget.baseUrl}${finalUrl.replaceAll('@', '')}';
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
    final lc = Get.find<LayoutController>();
    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(widget.icon, size: 13, color: widget.color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              widget.text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                color: widget.url != null ? lc.textColor : lc.textColor.withValues(alpha: 0.8),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                decoration: widget.url != null && _isHovered ? TextDecoration.underline : TextDecoration.none,
                decorationColor: widget.color,
              ),
            ),
          ),
          if (widget.url != null)
            Icon(Icons.arrow_outward_rounded, size: 10, color: lc.textColor.withValues(alpha: 0.3)),
        ],
      ),
    );

    if (widget.url != null) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: _handleTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: _isHovered ? widget.color.withValues(alpha: 0.05) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: row,
          ),
        ),
      );
    }
    return row;
  }
}

class _WalletCard extends StatefulWidget {
  final double balance;
  const _WalletCard({required this.balance});

  @override
  State<_WalletCard> createState() => _WalletCardState();
}

class _WalletCardState extends State<_WalletCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final lc = Get.find<LayoutController>();
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: () => Get.toNamed<void>('/wallet'),
        child: AnimatedScale(
          scale: _isHovered ? 1.03 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: _isHovered 
                  ? AppColors.goldGrad 
                  : LinearGradient(
                      colors: [
                        AppColors.amber.withValues(alpha: 0.95),
                        const Color(0xFFFF8800).withValues(alpha: 0.95),
                      ],
                    ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.amber.withValues(alpha: _isHovered ? 0.35 : 0.15),
                  blurRadius: _isHovered ? 16 : 8,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('BALANCE', style: GoogleFonts.ibmPlexMono(
                      color: Colors.white.withValues(alpha: 0.8), fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1.5)),
                    Icon(Icons.account_balance_wallet_outlined, size: 16, color: Colors.white.withValues(alpha: 0.9)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text('\$${widget.balance.toStringAsFixed(2)}',
                      style: GoogleFonts.lexend(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                    const Spacer(),
                    Text('WALLET', style: GoogleFonts.ibmPlexMono(
                      color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 1)),
                    const SizedBox(width: 4),
                    Icon(Icons.chevron_right_rounded, size: 12, color: Colors.white.withValues(alpha: 0.7)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ArtworkGrid extends StatelessWidget {
  final ProfileController controller;
  const _ArtworkGrid({required this.controller});

  @override
  Widget build(BuildContext context) {
    final lc = Get.find<LayoutController>();
    return Obx(() {
      final posts = controller.filteredPosts;
      if (controller.isLoading.value) {
        return Center(child: CircularProgressIndicator(color: lc.primaryColor, strokeWidth: 2));
      }
      if (posts.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  color: lc.primaryColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(Icons.palette_outlined, size: 28, color: lc.textColor.withValues(alpha: 0.4)),
              ),
              const SizedBox(height: 14),
              Text('No artworks yet', style: GoogleFonts.plusJakartaSans(
                color: lc.textColor.withValues(alpha: 0.7), fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Text('Share your creations with the world', style: GoogleFonts.plusJakartaSans(
                color: lc.textColor.withValues(alpha: 0.4), fontSize: 12)),
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
              padding: const EdgeInsets.all(20),
              child: CircularProgressIndicator(color: lc.primaryColor, strokeWidth: 2),
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