import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/leaderboard_controller.dart';
import '../../../data/models/user_model.dart';
class LeaderboardView extends GetView<LeaderboardController> {
  const LeaderboardView({super.key});
  static const _categories = [
    ('Likes', 'likes'),
    ('Views', 'views'),
    ('Followers', 'followers'),
    ('Artworks', 'artworks'),
  ];
  static const _timeframes = [
    ('All Time', 'all_time'),
    ('Monthly', 'monthly'),
    ('Weekly', 'weekly'),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.9),
              border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
            ),
            child: Row(
              children: [
                Text('Leaderboard', style: GoogleFonts.lexend(
                  color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
                const Spacer(),
                Obx(() => Row(
                  children: _categories.map((cat) {
                    final active = controller.selectedCategory.value == cat.$2;
                    return GestureDetector(
                      onTap: () {
                        controller.selectedCategory.value = cat.$2;
                        controller.fetchLeaderboards(force: true);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(left: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: active ? AppColors.violet.withValues(alpha: 0.12) : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: active ? AppColors.violet.withValues(alpha: 0.3) : AppColors.border,
                            width: 0.5,
                          ),
                        ),
                        child: Text(cat.$1, style: GoogleFonts.plusJakartaSans(
                          color: active ? AppColors.violet : AppColors.textTertiary,
                          fontSize: 11, fontWeight: active ? FontWeight.w700 : FontWeight.w500)),
                      ),
                    );
                  }).toList(),
                )),
                const SizedBox(width: 16),
                Obx(() => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surface2,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.border, width: 0.5),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: controller.selectedTimeframe.value,
                      dropdownColor: AppColors.surface2,
                      icon: Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: AppColors.textTertiary),
                      style: GoogleFonts.plusJakartaSans(color: AppColors.textPrimary, fontSize: 11),
                      onChanged: (v) {
                        if (v != null) {
                          controller.selectedTimeframe.value = v;
                          controller.fetchLeaderboards(force: true);
                        }
                      },
                      items: _timeframes.map((t) => DropdownMenuItem(
                        value: t.$2,
                        child: Text(t.$1),
                      )).toList(),
                    ),
                  ),
                )),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator(color: AppColors.violet, strokeWidth: 2));
              }
              final users = controller.activeList;
              if (users.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.leaderboard_outlined, size: 48, color: AppColors.textTertiary),
                      const SizedBox(height: 12),
                      Text('No data yet', style: GoogleFonts.plusJakartaSans(
                        color: AppColors.textTertiary, fontSize: 14)),
                    ],
                  ),
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 300, child: _Podium(users: users.take(3).toList())),
                  Expanded(child: _RankList(users: users.skip(3).toList())),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
class _Podium extends StatelessWidget {
  final List<UserModel> users;
  const _Podium({required this.users});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 16),
          if (users.isNotEmpty) _PodiumEntry(user: users[0], rank: 1, height: 120),
          const SizedBox(height: 16),
          Row(
            children: [
              if (users.length > 1) Expanded(child: _PodiumEntry(user: users[1], rank: 2, height: 80)),
              const SizedBox(width: 12),
              if (users.length > 2) Expanded(child: _PodiumEntry(user: users[2], rank: 3, height: 60)),
            ],
          ),
        ],
      ),
    );
  }
}
class _PodiumEntry extends StatelessWidget {
  final UserModel user;
  final int rank;
  final double height;
  const _PodiumEntry({required this.user, required this.rank, required this.height});
  @override
  Widget build(BuildContext context) {
    final colors = [AppColors.amber, AppColors.textSecondary, const Color(0xFFCD7F32)];
    final c = colors[rank - 1];
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: rank == 1 ? 32 : 24,
              backgroundColor: c.withValues(alpha: 0.2),
              backgroundImage: user.avatarUrl?.isNotEmpty == true ? NetworkImage(user.avatarUrl!) : null,
              child: user.avatarUrl?.isEmpty != false
                  ? Text(user.name.isNotEmpty ? user.name[0] : '?',
                      style: GoogleFonts.lexend(color: c, fontSize: rank == 1 ? 20 : 14, fontWeight: FontWeight.w900))
                  : null,
            ),
            if (rank == 1)
              const Positioned(top: -10, child: Text('👑', style: TextStyle(fontSize: 16))),
          ],
        ),
        const SizedBox(height: 8),
        Text(user.name, maxLines: 1, overflow: TextOverflow.ellipsis,
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.textPrimary, fontSize: 11, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          height: height,
          decoration: BoxDecoration(
            color: c.withValues(alpha: 0.1),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            border: Border.all(color: c.withValues(alpha: 0.3), width: 0.5),
          ),
          child: Center(
            child: Text('#$rank', style: GoogleFonts.lexend(
              color: c, fontSize: 18, fontWeight: FontWeight.w900)),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2, end: 0);
  }
}
class _RankList extends StatelessWidget {
  final List<UserModel> users;
  const _RankList({required this.users});
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: users.length,
      itemBuilder: (ctx, i) {
        final user = users[i];
        final rank = i + 4;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 32,
                child: Text('#$rank', style: GoogleFonts.ibmPlexMono(
                  color: AppColors.textTertiary, fontSize: 12, fontWeight: FontWeight.w700)),
              ),
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.violet.withValues(alpha: 0.15),
                backgroundImage: user.avatarUrl?.isNotEmpty == true ? NetworkImage(user.avatarUrl!) : null,
                child: user.avatarUrl?.isEmpty != false
                    ? Text(user.name.isNotEmpty ? user.name[0] : '?',
                        style: GoogleFonts.lexend(color: AppColors.violet, fontSize: 13, fontWeight: FontWeight.w900))
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.name, style: GoogleFonts.plusJakartaSans(
                      color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                    if (user.handle != null)
                      Text('@${user.handle}', style: GoogleFonts.ibmPlexMono(
                        color: AppColors.textTertiary, fontSize: 10)),
                  ],
                ),
              ),
              Text('${user.likesCount} ♥', style: GoogleFonts.ibmPlexMono(
                color: AppColors.pink, fontSize: 11, fontWeight: FontWeight.w700)),
            ],
          ),
        ).animate(delay: Duration(milliseconds: 40 * i)).fadeIn(duration: 300.ms);
      },
    );
  }
}