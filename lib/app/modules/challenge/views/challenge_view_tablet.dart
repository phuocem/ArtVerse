import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/challenge_controller.dart';
import '../../../data/models/challenge_model.dart';
class ChallengeViewTablet extends GetView<ChallengeController> {
  const ChallengeViewTablet({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          _ChallengeTopBar(controller: controller),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator(color: AppColors.violet, strokeWidth: 2));
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 6, child: _ChallengeGrid(controller: controller)),
                  SizedBox(width: 280, child: _LeaderSidebar(controller: controller)),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
class _ChallengeTopBar extends StatelessWidget {
  final ChallengeController controller;
  const _ChallengeTopBar({required this.controller});
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
          Text('Arena', style: GoogleFonts.lexend(
            color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(width: 8),
          Obx(() => Text('${controller.activeChallenges.length} active',
            style: GoogleFonts.ibmPlexMono(color: AppColors.textTertiary, fontSize: 10))),
          const Spacer(),
          GestureDetector(
            onTap: () => controller.refreshData(),
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
                  Icon(Icons.refresh_rounded, size: 14, color: AppColors.textTertiary),
                  const SizedBox(width: 6),
                  Text('Refresh', style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textTertiary, fontSize: 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class _ChallengeGrid extends StatelessWidget {
  final ChallengeController controller;
  const _ChallengeGrid({required this.controller});
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dp = controller.dailyPrompt.value;
      final challenges = controller.activeChallenges;

      if (dp == null && challenges.isEmpty) {
        return _buildEmptyState();
      }

      return CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          if (dp != null)
            SliverToBoxAdapter(
              child: _DailyPromptCard(challenge: dp, controller: controller),
            ),
          if (challenges.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (ctx, i) => _ChallengeCard(
                    challenge: challenges[i],
                    controller: controller,
                    index: i,
                  ),
                  childCount: challenges.length,
                ),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 320,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.2,
                ),
              ),
            ),
        ],
      );
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.violet.withValues(alpha: 0.05),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: AppColors.violet.withValues(alpha: 0.2), blurRadius: 40, spreadRadius: 10),
              ],
            ),
            child: Icon(Icons.auto_awesome_rounded, size: 64, color: AppColors.violet),
          ).animate().scale(duration: 800.ms, curve: Curves.easeOutBack).fadeIn(),
          const SizedBox(height: 32),
          Text(
            "ARENA IS QUIET",
            style: GoogleFonts.lexend(
              color: AppColors.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ).animate().slideY(begin: 0.5, end: 0, duration: 600.ms).fadeIn(),
          const SizedBox(height: 16),
          Text(
            "Artists are resting. Prepare your brushes\nfor the next epic battle.",
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              color: AppColors.textTertiary,
              fontSize: 15,
              height: 1.5,
            ),
          ).animate().slideY(begin: 0.5, end: 0, duration: 600.ms, delay: 100.ms).fadeIn(),
        ],
      ),
    );
  }
}
class _DailyPromptCard extends StatelessWidget {
  final ChallengeModel challenge;
  final ChallengeController controller;
  const _DailyPromptCard({required this.challenge, required this.controller});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        image: challenge.imageUrl != null ? DecorationImage(
          image: NetworkImage(challenge.imageUrl!),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(Colors.black.withValues(alpha: 0.6), BlendMode.darken),
        ) : null,
        gradient: challenge.imageUrl == null ? LinearGradient(
          colors: [AppColors.violet.withValues(alpha: 0.3), AppColors.pink.withValues(alpha: 0.15)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ) : null,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.violet.withValues(alpha: 0.5), width: 1),
        boxShadow: [
          BoxShadow(color: AppColors.violet.withValues(alpha: 0.2), blurRadius: 24, offset: const Offset(0, 8)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.amber.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.amber.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.local_fire_department_rounded, size: 12, color: AppColors.amber),
                          const SizedBox(width: 4),
                          Text('FEATURED BATTLE', style: GoogleFonts.ibmPlexMono(
                            color: AppColors.amber, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 2)),
                        ],
                      ),
                    ).animate(onPlay: (c) => c.repeat(reverse: true)).shimmer(duration: const Duration(seconds: 2), color: AppColors.amber.withValues(alpha: 0.5)),
                    const SizedBox(width: 12),
                    Text('+${challenge.rewardXp} XP', style: GoogleFonts.lexend(
                      color: AppColors.amber, fontSize: 14, fontWeight: FontWeight.w900)),
                  ],
                ),
                const SizedBox(height: 16),
                Text(challenge.title, style: GoogleFonts.lexend(
                  color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, shadows: [
                    Shadow(color: AppColors.violet, blurRadius: 16),
                  ])),
                const SizedBox(height: 8),
                Text(challenge.prompt, style: GoogleFonts.plusJakartaSans(
                  color: Colors.white.withValues(alpha: 0.8), fontSize: 14, height: 1.5)),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () => controller.acceptChallenge(challenge),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: AppColors.violetPink,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(color: AppColors.pink.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.brush_rounded, size: 16, color: Colors.white),
                        const SizedBox(width: 8),
                        Text('ENTER ARENA', style: GoogleFonts.plusJakartaSans(
                          color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 32),
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface.withValues(alpha: 0.5),
              border: Border.all(color: AppColors.amber.withValues(alpha: 0.5), width: 2),
              boxShadow: [
                BoxShadow(color: AppColors.amber.withValues(alpha: 0.2), blurRadius: 30),
              ],
            ),
            child: Icon(Icons.emoji_events_rounded, size: 50, color: AppColors.amber),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(begin: const Offset(0.95, 0.95), end: const Offset(1.05, 1.05), duration: const Duration(seconds: 2)),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0);
  }
}
class _ChallengeCard extends StatelessWidget {
  final ChallengeModel challenge;
  final ChallengeController controller;
  final int index;
  const _ChallengeCard({required this.challenge, required this.controller, required this.index});
  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => controller.acceptChallenge(challenge),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface2,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 1),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.circle, size: 6, color: AppColors.teal),
                        const SizedBox(width: 6),
                        Text('LOBBY OPEN', style: GoogleFonts.ibmPlexMono(
                          color: AppColors.teal, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1)),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.amber.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text('+${challenge.rewardXp} XP', style: GoogleFonts.lexend(
                      color: AppColors.amber, fontSize: 10, fontWeight: FontWeight.w900)),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(challenge.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                style: GoogleFonts.lexend(
                  color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w800, height: 1.3)),
              const SizedBox(height: 8),
              Text(challenge.prompt, maxLines: 2, overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(color: AppColors.textSecondary, fontSize: 12, height: 1.4)),
              const Spacer(),
              Container(height: 1, color: AppColors.border),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.people_alt_rounded, size: 14, color: AppColors.textTertiary),
                  const SizedBox(width: 6),
                  Text('${challenge.participantsCount} ARTISTS', style: GoogleFonts.ibmPlexMono(
                    color: AppColors.textTertiary, fontSize: 9, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.violet),
                ],
              ),
            ],
          ),
        ).animate(delay: Duration(milliseconds: 50 * index)).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
      ),
    );
  }
}
class _LeaderSidebar extends StatelessWidget {
  final ChallengeController controller;
  const _LeaderSidebar({required this.controller});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(left: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('HALL OF FAME', style: GoogleFonts.ibmPlexMono(
            color: AppColors.textTertiary, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 2)),
          const SizedBox(height: 16),
          Obx(() => Column(
            children: controller.leaderboardUsers.take(10).toList().asMap().entries.map((e) {
              final user = e.value;
              final rank = e.key + 1;
              final isTop3 = rank <= 3;
              
              Color rankColor = AppColors.textTertiary;
              if (rank == 1) rankColor = const Color(0xFFFFD700); 
              else if (rank == 2) rankColor = const Color(0xFFC0C0C0); 
              else if (rank == 3) rankColor = const Color(0xFFCD7F32); 

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: isTop3 ? rankColor.withValues(alpha: 0.08) : AppColors.surface2,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isTop3 ? rankColor.withValues(alpha: 0.3) : AppColors.border,
                    width: isTop3 ? 1 : 0.5,
                  ),
                  boxShadow: isTop3 ? [
                    BoxShadow(color: rankColor.withValues(alpha: 0.1), blurRadius: 10)
                  ] : [],
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 28,
                      child: isTop3
                        ? Icon(Icons.workspace_premium_rounded, size: 20, color: rankColor)
                        : Text('#$rank', style: GoogleFonts.ibmPlexMono(
                            color: AppColors.textTertiary, fontSize: 11, fontWeight: FontWeight.w900)),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: isTop3 ? Border.all(color: rankColor, width: 1.5) : null,
                      ),
                      child: CircleAvatar(
                        radius: 14,
                        backgroundColor: AppColors.violet.withValues(alpha: 0.2),
                        backgroundImage: (user.avatarUrl?.isNotEmpty == true)
                            ? NetworkImage(user.avatarUrl!) : null,
                        child: (user.avatarUrl?.isEmpty != false)
                            ? Text(user.name.isNotEmpty ? user.name[0] : '?',
                                style: GoogleFonts.lexend(color: AppColors.violet, fontSize: 11, fontWeight: FontWeight.w900))
                            : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              color: isTop3 ? AppColors.textPrimary : AppColors.textSecondary, 
                              fontSize: 12, fontWeight: isTop3 ? FontWeight.w800 : FontWeight.w600)),
                          const SizedBox(height: 2),
                          Text('${user.viewsCount} views', style: GoogleFonts.ibmPlexMono(
                            color: AppColors.textTertiary, fontSize: 9)),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate(delay: Duration(milliseconds: 50 * rank)).fadeIn().slideX(begin: 0.1, end: 0);
            }).toList(),
          )),
        ],
      ),
    );
  }
}