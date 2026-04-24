import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../layout/controllers/layout_controller.dart';
import '../controllers/profile_controller.dart';
import '../../../data/models/user_model.dart';
import '../../../widgets/global/global_artwork_card.dart';
import 'widgets/profile_header.dart';

class ProfileViewTablet extends GetView<ProfileController> {
  const ProfileViewTablet({super.key});

  @override
  Widget build(BuildContext context) {
    final lc = Get.find<LayoutController>();

    return Scaffold(
      backgroundColor: lc.backgroundColor,
      body: Obx(() {
        if (!controller.isLogined.value) {
          return _GuestPrompt(controller: controller, lc: lc);
        }

        if (controller.isLoading.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 48, height: 48,
                  child: CircularProgressIndicator(
                    color: lc.primaryColor, strokeWidth: 2,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'SYNCING NEURAL NETWORK',
                  style: GoogleFonts.plusJakartaSans(
                    color: lc.primaryColor,
                    fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 4,
                  ),
                ).animate().fade(duration: 800.ms).shimmer(duration: const Duration(seconds: 2)),
              ],
            ),
          );
        }

        final user = controller.viewedUser.value;
        if (user == null) {
          return Center(
            child: Text(
              'Identity Void',
              style: GoogleFonts.cinzel(color: lc.textColor.withValues(alpha: 0.3), fontSize: 24),
            ),
          );
        }

        return CustomScrollView(
          controller: controller.scrollController,
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            
            SliverToBoxAdapter(
              child: ProfileHeader(user: user, controller: controller, lc: lc)
                  .animate().fadeIn(duration: 800.ms).slideY(begin: 0.05, end: 0, curve: Curves.easeOutQuint),
            ),

            
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyFilterDelegate(
                child: _buildCategoryFilters(lc),
                minHeight: 100,
                maxHeight: 100,
                lc: lc,
              ),
            ),

            
            _buildSliverArtGrid(lc),

            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        );
      }),
    );
  
  Widget _buildCategoryFilters(LayoutController lc) {
    final filters = [
      {'label': 'All Works', 'count': controller.post.length, 'id': 'All', 'icon': Icons.grid_view_rounded},
    ];

    return Obx(() {
      return Container(
        color: lc.backgroundColor.withValues(alpha: 0.85),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: lc.textColor.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(color: lc.textColor.withValues(alpha: 0.08)),
              ),
              child: Row(
                children: filters.map((f) {
                  final isSelected = controller.selectedTab.value == f['id'];
                  return GestureDetector(
                    onTap: () => controller.selectedTab.value = f['id'] as String,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected ? lc.primaryColor : Colors.transparent,
                        borderRadius: BorderRadius.circular(100),
                        boxShadow: isSelected ? [BoxShadow(color: lc.primaryColor.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 4))] : [],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(f['icon'] as IconData, size: 16, color: isSelected ? Colors.white : lc.textColor.withValues(alpha: 0.4)),
                          const SizedBox(width: 8),
                          Text(
                            (f['label'] as String).toUpperCase(),
                            style: GoogleFonts.plusJakartaSans(
                              color: isSelected ? Colors.white : lc.textColor.withValues(alpha: 0.5),
                              fontSize: 12, fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600, letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white.withValues(alpha: 0.2) : lc.textColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${f['count']}',
                              style: GoogleFonts.plusJakartaSans(
                                color: isSelected ? Colors.white : lc.textColor.withValues(alpha: 0.5),
                                fontSize: 10, fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const Spacer(),
            
            _ViewToggle(
              value: controller.crossAxisCount.value,
              onChanged: (v) => controller.crossAxisCount.value = v,
              lc: lc,
            ),
          ],
        ),
      );
    });
  }

  
  Widget _buildSliverArtGrid(LayoutController lc) {
    return Obx(() {
      final posts = controller.filteredPosts;
      if (posts.isEmpty) {
        return SliverToBoxAdapter(child: _buildEmptyState(lc));
      }

      return SliverPadding(
        padding: const EdgeInsets.fromLTRB(48, 24, 48, 48),
        sliver: SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: controller.crossAxisCount.value,
            mainAxisSpacing: 32,
            crossAxisSpacing: 24,
            childAspectRatio: controller.crossAxisCount.value == 3 ? 0.82 : 1.15,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              return GlobalArtworkCard(
                post: posts[index],
                onTap: () => Get.toNamed('/artwork-detail', arguments: {'post': posts[index]}),
              )
                  .animate(delay: Duration(milliseconds: 50 * (index % 10)))
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuart);
            },
            childCount: posts.length,
          ),
        ),
      );
    });
  }

  Widget _buildEmptyState(LayoutController lc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 100),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 120, height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [lc.primaryColor.withValues(alpha: 0.1), Colors.transparent],
                  radius: 0.8,
                ),
                border: Border.all(color: lc.primaryColor.withValues(alpha: 0.2), width: 1),
                boxShadow: [BoxShadow(color: lc.primaryColor.withValues(alpha: 0.05), blurRadius: 40)],
              ),
              child: Icon(Icons.auto_awesome_outlined, size: 48, color: lc.primaryColor.withValues(alpha: 0.8)),
            ),
            const SizedBox(height: 32),
            Text('VOID CANVAS', style: GoogleFonts.cinzel(
              color: lc.textColor.withValues(alpha: 0.8), fontSize: 24, fontWeight: FontWeight.w400)),
            const SizedBox(height: 12),
            Text('Sync your first masterpiece to the network.', style: GoogleFonts.plusJakartaSans(
              color: lc.textColor.withValues(alpha: 0.4), fontSize: 14, fontWeight: FontWeight.w400)),
          ],
        ).animate().fadeIn(duration: const Duration(seconds: 1)).slideY(begin: 0.1, end: 0),
      ),
    );
  }
}




class _ProfileImmersiveHeader extends StatelessWidget {
  final UserModel user;
  final ProfileController controller;
  final LayoutController lc;

  const _ProfileImmersiveHeader({required this.user, required this.controller, required this.lc});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(48, 48, 48, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(48),
        color: lc.glassColor,
        border: Border.all(color: lc.glassBorderColor, width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 40, offset: const Offset(0, 20)),
        ],
      ),
      child: Stack(
        children: [
          
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(46),
              child: Opacity(
                opacity: 0.03,
                child: CustomPaint(painter: _SubtleGridPainter(lc.textColor)),
              ),
            ),
          ),
          
          Positioned(
            right: -100, top: -100,
            child: Container(
              width: 300, height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [lc.primaryColor.withValues(alpha: 0.3), Colors.transparent],
                ),
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(48),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildSquircleAvatar(),
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
                            child: Text(user.name.toUpperCase(), 
                              style: GoogleFonts.cinzel(color: lc.textColor, fontSize: 48, fontWeight: FontWeight.w900, letterSpacing: -1.5),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (user.isStudio) ...[
                            const SizedBox(width: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [Colors.amber, Colors.orangeAccent]),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [BoxShadow(color: Colors.amber.withValues(alpha: 0.4), blurRadius: 12)],
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.stars_rounded, color: Colors.white, size: 12),
                                  const SizedBox(width: 4),
                                  Text('STUDIO VERIFIED', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text('@${user.handle ?? user.name.toLowerCase().replaceAll(' ', '')}',
                        style: GoogleFonts.plusJakartaSans(color: lc.primaryColor, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1)),
                      const SizedBox(height: 24),
                      Text(
                        user.bio.isNotEmpty ? user.bio : "Silent Architect of the ArtVerse Neural Network.",
                        style: GoogleFonts.plusJakartaSans(color: lc.textColor.withValues(alpha: 0.6), fontSize: 15, height: 1.6, fontWeight: FontWeight.w400),
                      ),
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          _GlassCapsuleStat(label: 'COMS', value: '${user.followersCount}', icon: Icons.wifi_tethering_rounded, lc: lc),
                          const SizedBox(width: 16),
                          _GlassCapsuleStat(label: 'LINKS', value: '${user.followingCount}', icon: Icons.link_rounded, lc: lc),
                          const SizedBox(width: 16),
                          _GlassCapsuleStat(label: 'ARCHIVES', value: '${controller.post.length}', icon: Icons.inventory_2_rounded, lc: lc),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 32),
                Column(
                  children: [
                    _buildFollowActions(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSquircleAvatar() {
    return Container(
      width: 200, height: 200,
      decoration: BoxDecoration(
        color: lc.backgroundColor,
        borderRadius: BorderRadius.circular(56),
        border: Border.all(color: lc.glassBorderColor, width: 2),
        boxShadow: [BoxShadow(color: lc.primaryColor.withValues(alpha: 0.4), blurRadius: 60, offset: const Offset(0, 20))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(54),
        child: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
            ? CachedNetworkImage(imageUrl: user.avatarUrl!, fit: BoxFit.cover)
            : Container(color: lc.primaryColor.withValues(alpha: 0.1), child: Icon(Icons.person_rounded, size: 80, color: lc.primaryColor)),
      ),
    ).animate().scale(delay: 100.ms, duration: 600.ms, curve: Curves.easeOutBack);
  }

  Widget _buildFollowActions() {
    return Obx(() {
      final isOwner = controller.currentUser.value?.id == user.id;
      final isFollowing = controller.followingMap[user.id] ?? false;

      if (isOwner) {
        return Column(
          children: [
            GestureDetector(
              onTap: () => controller.showEditProfileDialog(
                id: user.id!, name: user.name, bio: user.bio, avatarUrl: user.avatarUrl, onUpdated: () => controller.reload(),
              ),
              child: Container(
                width: 200,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [lc.textColor.withValues(alpha: 0.1), lc.textColor.withValues(alpha: 0.05)]),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: lc.textColor.withValues(alpha: 0.2), width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.edit_rounded, size: 16, color: lc.textColor),
                    const SizedBox(width: 8),
                    Text('EDIT IDENTITY', style: GoogleFonts.plusJakartaSans(color: lc.textColor, fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildIconButton(Icons.account_balance_wallet_rounded, () => Get.toNamed('/wallet')),
                const SizedBox(width: 16),
                _buildIconButton(Icons.settings_rounded, () => controller.showSettingsOptions()),
              ],
            ),
          ],
        );
      }

      return GestureDetector(
        onTap: () => controller.toggleFollow(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 200,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            gradient: isFollowing ? null : LinearGradient(colors: [lc.primaryColor, lc.primaryColor.withValues(alpha: 0.8)]),
            color: isFollowing ? lc.textColor.withValues(alpha: 0.05) : null,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isFollowing ? lc.textColor.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.3), width: 1.5),
            boxShadow: isFollowing ? null : [BoxShadow(color: lc.primaryColor.withValues(alpha: 0.4), blurRadius: 24, offset: const Offset(0, 8))],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(isFollowing ? Icons.check_rounded : Icons.link_rounded, size: 18, color: isFollowing ? lc.textColor : Colors.white),
              const SizedBox(width: 8),
              Text(isFollowing ? 'ESTABLISHED' : 'ESTABLISH LINK',
                style: GoogleFonts.plusJakartaSans(color: isFollowing ? lc.textColor : Colors.white, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 92, height: 56,
        decoration: BoxDecoration(
          color: lc.textColor.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: lc.textColor.withValues(alpha: 0.1), width: 1.5),
        ),
        child: Icon(icon, size: 20, color: lc.textColor.withValues(alpha: 0.8)),
      ),
    );
  }
}

class _GlassCapsuleStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final LayoutController lc;

  const _GlassCapsuleStat({required this.label, required this.value, required this.icon, required this.lc});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: lc.textColor.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: lc.textColor.withValues(alpha: 0.05)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: lc.primaryColor, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: GoogleFonts.plusJakartaSans(color: lc.textColor, fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 2),
              Text(label, style: GoogleFonts.plusJakartaSans(color: lc.textColor.withValues(alpha: 0.4), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 2)),
            ],
          ),
        ],
      ),
    );
  }
}




class _StickyFilterDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double minHeight;
  final double maxHeight;
  final LayoutController lc;

  _StickyFilterDelegate({required this.child, required this.minHeight, required this.maxHeight, required this.lc});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 32, sigmaY: 32),
        child: Container(
          decoration: BoxDecoration(
            color: lc.backgroundColor.withValues(alpha: 0.8),
            border: Border(bottom: BorderSide(color: lc.glassBorderColor, width: 1)),
          ),
          child: child,
        ),
      ).animate().fadeIn(delay: 150.ms, duration: 600.ms).slideX(begin: 0.05, end: 0),
    );
  }

  @override
  double get maxExtent => maxHeight;
  @override
  double get minExtent => minHeight;
  @override
  bool shouldRebuild(covariant _StickyFilterDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight || minHeight != oldDelegate.minHeight || child != oldDelegate.child;
  }
}




class _ViewToggle extends StatelessWidget {
  final int value;
  final Function(int) onChanged;
  final LayoutController lc;

  const _ViewToggle({required this.value, required this.onChanged, required this.lc});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: lc.textColor.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: lc.textColor.withValues(alpha: 0.08)),
      ),
      padding: const EdgeInsets.all(6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildBtn(3, Icons.grid_view_rounded),
          _buildBtn(4, Icons.apps_rounded),
        ],
      ),
    );
  }

  Widget _buildBtn(int val, IconData icon) {
    final sel = value == val;
    return GestureDetector(
      onTap: () => onChanged(val),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: sel ? lc.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
          boxShadow: sel ? [BoxShadow(color: lc.primaryColor.withValues(alpha: 0.4), blurRadius: 12)] : [],
        ),
        child: Icon(icon, size: 16, color: sel ? Colors.white : lc.textColor.withValues(alpha: 0.3)),
      ),
    );
  }
}




class _SubtleGridPainter extends CustomPainter {
  final Color color;
  const _SubtleGridPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = 1.0;
    const step = 48.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _GuestPrompt extends StatelessWidget {
  final ProfileController controller;
  final LayoutController lc;

  const _GuestPrompt({required this.controller, required this.lc});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(top: -100, right: -80, child: Container(width: 400, height: 400, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [lc.primaryColor.withValues(alpha: 0.1), Colors.transparent])))),
        Center(
          child: Container(
            width: 500,
            padding: const EdgeInsets.all(56),
            decoration: BoxDecoration(
              color: lc.glassColor,
              borderRadius: BorderRadius.circular(48),
              border: Border.all(color: lc.glassBorderColor, width: 1.5),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 40, offset: const Offset(0, 20))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: lc.primaryColor.withValues(alpha: 0.1),
                    border: Border.all(color: lc.primaryColor.withValues(alpha: 0.3), width: 2),
                  ),
                  child: Icon(Icons.fingerprint_rounded, size: 48, color: lc.primaryColor),
                ),
                const SizedBox(height: 32),
                Text('IDENTITY REQUIRED', style: GoogleFonts.cinzel(color: lc.textColor, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1)),
                const SizedBox(height: 16),
                Text('Establish a neural link to track artists, archive creations, and expand your network protocol.', textAlign: TextAlign.center, style: GoogleFonts.plusJakartaSans(color: lc.textColor.withValues(alpha: 0.6), fontSize: 14, height: 1.7, fontWeight: FontWeight.w400)),
                const SizedBox(height: 48),
                Obx(() {
                  final loading = controller.isLoading.value;
                  return GestureDetector(
                    onTap: loading ? null : controller.signInWithGoogle,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: loading ? null : LinearGradient(colors: [lc.primaryColor, lc.primaryColor.withValues(alpha: 0.7)]),
                        color: loading ? lc.textColor.withValues(alpha: 0.04) : null,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: loading ? lc.textColor.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.3), width: 1.5),
                        boxShadow: loading ? null : [BoxShadow(color: lc.primaryColor.withValues(alpha: 0.4), blurRadius: 24, offset: const Offset(0, 8))],
                      ),
                      child: loading
                          ? const Center(child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white)))
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(width: 28, height: 28, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)), child: const Center(child: Text('G', style: TextStyle(color: Color(0xFF4285F4), fontSize: 16, fontWeight: FontWeight.w900)))),
                                const SizedBox(width: 16),
                                Text('ESTABLISH LINK', style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                              ],
                            ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ).animate().fadeIn(duration: 800.ms).scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1), curve: Curves.easeOutCubic),
      ],
    );
  }
}
