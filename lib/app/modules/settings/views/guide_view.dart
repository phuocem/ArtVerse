import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';

class GuideView extends StatelessWidget {
  const GuideView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          _buildHero(),
          _buildSections(),
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      backgroundColor: AppColors.surface.withValues(alpha: 0.9),
      floating: true,
      pinned: true,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
        onPressed: () => Get.back(),
      ),
      title: Text('User Guide', style: GoogleFonts.lexend(
        color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
      centerTitle: true,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
        ),
      ),
    );
  }

  Widget _buildHero() {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.fromLTRB(40, 60, 40, 40),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.violetPink,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: AppColors.violet.withValues(alpha: 0.3), blurRadius: 40, spreadRadius: 10),
                ],
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 48),
            ).animate().scale(duration: 800.ms, curve: Curves.easeOutBack).fadeIn(),
            const SizedBox(height: 32),
            Text(
              "Welcome to ArtVerse",
              style: GoogleFonts.lexend(
                color: AppColors.textPrimary,
                fontSize: 32,
                fontWeight: FontWeight.w900,
              ),
            ).animate().slideY(begin: 0.3, end: 0, duration: 600.ms).fadeIn(),
            const SizedBox(height: 16),
            Text(
              "Your journey to artistic excellence starts here.\nExplore the features and master the tools of ArtVerse.",
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textTertiary,
                fontSize: 16,
                height: 1.6,
              ),
            ).animate().slideY(begin: 0.3, end: 0, duration: 600.ms, delay: 100.ms).fadeIn(),
          ],
        ),
      ),
    );
  }

  Widget _buildSections() {
    final sections = [
      (
        'Draw Studio', 
        'Professional canvas for your creativity', 
        Icons.palette_rounded, 
        AppColors.violet,
        [
          'Access layers and frames from the right sidebar.',
          'Use the tool palette to select brushes, erasers, and shapes.',
          'Export your work as high-quality PNG, GIF, or HLS video.',
          'Auto-save ensures you never lose your progress.'
        ]
      ),
      (
        'Art Arena', 
        'Compete and grow with challenges', 
        Icons.auto_fix_high_rounded, 
        AppColors.pink,
        [
          'Join daily prompts to earn XP and increase your rank.',
          'Submit your entries directly from the Studio.',
          'Check the leaderboard to see top artists in real-time.',
          'Win challenges to unlock exclusive badges.'
        ]
      ),
      (
        'Community', 
        'Connect with fellow artists', 
        Icons.group_rounded, 
        AppColors.teal,
        [
          'Browse artworks from around the globe.',
          'Like, comment, and follow your favorite creators.',
          'Share your own masterpieces to build a following.',
          'Discover trending styles and inspirations.'
        ]
      ),
      (
        'Asset Market', 
        'Premium resources for your workflow', 
        Icons.shopping_bag_rounded, 
        AppColors.amber,
        [
          'Find color palettes, lineart, and remix templates.',
          'Purchase or download free assets to use in your projects.',
          'Upload your own assets to earn revenue.',
          'Manage your downloads in the Studio sidebar.'
        ]
      ),
    ];

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final section = sections[index];
            return _GuideSection(
              title: section.$1,
              desc: section.$2,
              icon: section.$3,
              color: section.$4,
              steps: section.$5,
              index: index,
            );
          },
          childCount: sections.length,
        ),
      ),
    );
  }
}

class _GuideSection extends StatelessWidget {
  final String title;
  final String desc;
  final IconData icon;
  final Color color;
  final List<String> steps;
  final int index;

  const _GuideSection({
    required this.title,
    required this.desc,
    required this.icon,
    required this.color,
    required this.steps,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 0.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 4)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.05),
              border: Border(bottom: BorderSide(color: color.withValues(alpha: 0.1))),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: GoogleFonts.lexend(
                        color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w800)),
                      Text(desc, style: GoogleFonts.plusJakartaSans(
                        color: AppColors.textTertiary, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: steps.asMap().entries.map((e) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        width: 16, height: 16,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text('${e.key + 1}', style: GoogleFonts.ibmPlexMono(
                            color: color, fontSize: 9, fontWeight: FontWeight.w900)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(e.value, style: GoogleFonts.plusJakartaSans(
                          color: AppColors.textSecondary, fontSize: 14, height: 1.5)),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: 100 * index)).fadeIn(duration: 600.ms).slideX(begin: 0.1, end: 0);
  }
}
