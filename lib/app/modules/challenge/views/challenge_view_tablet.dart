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
                return const Center(child: CircularProgressIndicator(color: AppColors.violet, strokeWidth: 2));
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
        border: const Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
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
                  const Icon(Icons.refresh_rounded, size: 14, color: AppColors.textTertiary),
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
    return CustomScrollView(
      slivers: [
        Obx(() {
          final dp = controller.dailyPrompt.value;
          if (dp == null) return const SliverToBoxAdapter(child: SizedBox.shrink());
          return SliverToBoxAdapter(
            child: _DailyPromptCard(challenge: dp, controller: controller),
          );
        }),
        Obx(() {
          final challenges = controller.activeChallenges;
          return SliverPadding(
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
          );
        }),
      ],
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.violet.withValues(alpha: 0.2), AppColors.pink.withValues(alpha: 0.1)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.violet.withValues(alpha: 0.3), width: 0.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.amber.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.amber.withValues(alpha: 0.4)),
                  ),
                  child: Text('DAILY PROMPT', style: GoogleFonts.ibmPlexMono(
                    color: AppColors.amber, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 2)),
                ),
                const SizedBox(height: 12),
                Text(challenge.title, style: GoogleFonts.lexend(
                  color: AppColors.textPrimary, fontSize: 22, fontWeight: FontWeight.w900)),
                const SizedBox(height: 6),
                Text(challenge.prompt, style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => controller.acceptChallenge(challenge),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: AppColors.violetPink,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('ACCEPT CHALLENGE', style: GoogleFonts.plusJakartaSans(
                      color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: AppColors.violet.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.emoji_events_rounded, size: 40, color: AppColors.amber),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms);
  }
}
class _ChallengeCard extends StatelessWidget {
  final ChallengeModel challenge;
  final ChallengeController controller;
  final int index;
  const _ChallengeCard({required this.challenge, required this.controller, required this.index});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => controller.acceptChallenge(challenge),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.violet.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('MEDIUM', style: GoogleFonts.ibmPlexMono(
                    color: AppColors.violet, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1)),
                ),
                const Spacer(),
                const Icon(Icons.arrow_outward_rounded, size: 14, color: AppColors.textTertiary),
              ],
            ),
            const SizedBox(height: 12),
            Text(challenge.title, maxLines: 2, overflow: TextOverflow.ellipsis,
              style: GoogleFonts.lexend(
                color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w700, height: 1.3)),
            const SizedBox(height: 6),
            Text(challenge.prompt, maxLines: 2, overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(color: AppColors.textTertiary, fontSize: 11)),
            const Spacer(),
            Row(
              children: [
                const Icon(Icons.people_outline_rounded, size: 12, color: AppColors.textTertiary),
                const SizedBox(width: 4),
                Text('${challenge.participantsCount} joined', style: GoogleFonts.ibmPlexMono(
                  color: AppColors.textTertiary, fontSize: 9)),
                const Spacer(),
                Text('+${challenge.rewardXp} XP', style: GoogleFonts.lexend(
                  color: AppColors.amber, fontSize: 12, fontWeight: FontWeight.w900)),
              ],
            ),
          ],
        ),
      ).animate(delay: Duration(milliseconds: 60 * index)).fadeIn(duration: 400.ms),
    );
  }
}
class _LeaderSidebar extends StatelessWidget {
  final ChallengeController controller;
  const _LeaderSidebar({required this.controller});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(left: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('TOP ARTISTS', style: GoogleFonts.ibmPlexMono(
            color: AppColors.textTertiary, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 2)),
          const SizedBox(height: 16),
          Obx(() => Column(
            children: controller.leaderboardUsers.take(10).toList().asMap().entries.map((e) {
              final user = e.value;
              final rank = e.key + 1;
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: rank <= 3 ? AppColors.amber.withValues(alpha: 0.06) : AppColors.surface2,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: rank <= 3 ? AppColors.amber.withValues(alpha: 0.2) : AppColors.border,
                    width: 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 24,
                      child: Text('#$rank', style: GoogleFonts.ibmPlexMono(
                        color: rank <= 3 ? AppColors.amber : AppColors.textTertiary,
                        fontSize: 11, fontWeight: FontWeight.w900)),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: AppColors.violet.withValues(alpha: 0.2),
                      backgroundImage: (user.avatarUrl?.isNotEmpty == true)
                          ? NetworkImage(user.avatarUrl!) : null,
                      child: (user.avatarUrl?.isEmpty != false)
                          ? Text(user.name.isNotEmpty ? user.name[0] : '?',
                              style: GoogleFonts.lexend(color: AppColors.violet, fontSize: 11, fontWeight: FontWeight.w900))
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(user.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.textPrimary, fontSize: 11, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              );
            }).toList(),
          )),
        ],
      ),
    );
  }
}
