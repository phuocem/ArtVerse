import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:blur/blur.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:shimmer/shimmer.dart';
import '../../layout/controllers/layout_controller.dart';
import '../controllers/leaderboard_controller.dart';

class LeaderboardView extends GetView<LeaderboardController> {
  const LeaderboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final lc = Get.find<LayoutController>();

    return Scaffold(
      backgroundColor: lc.backgroundColor,
      body: Stack(
        children: [

          _buildDivineBackground(lc),

          RefreshIndicator(
            onRefresh: () => controller.fetchLeaderboards(force: true),
            color: lc.primaryColor,
            backgroundColor: Colors.white,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              slivers: [
                _buildSleekAppBar(lc),
                _buildCelestialTabs(lc),
                _buildMonumentalPodium(lc),
                _buildRankingSection(lc),
                const SliverPadding(padding: EdgeInsets.only(bottom: 150)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivineBackground(LayoutController lc) {
    return Stack(
      children: [

        Container(
          color: lc.backgroundColor,
        ),

        Positioned(
          top: -100,
          left: -100,
          child: Container(
            width: 500,
            height: 500,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFFFD700).withValues(alpha: 0.15),
                  Colors.transparent,
                ],
              ),
            ),
          ).blurred(blur: 60, colorOpacity: 0),
        ),

        Positioned(
          bottom: -150,
          right: -100,
          child: Container(
            width: 600,
            height: 600,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                  Colors.transparent,
                ],
              ),
            ),
          ).blurred(blur: 70, colorOpacity: 0),
        ),

        Center(
          child: Container(
            width: 800,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  lc.primaryColor.withValues(alpha: 0.08),
                  Colors.transparent,
                ],
              ),
            ),
          ).blurred(blur: 80, colorOpacity: 0),
        ),
      ],
    );
  }

  Widget _buildSleekAppBar(LayoutController lc) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      sliver: SliverToBoxAdapter(
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                ),
                child: Icon(MdiIcons.chevronLeft, color: Colors.white, size: 24),
              ),
            ),
            const Spacer(),
            Column(
              children: [
                Text(
                  'visionary_hall'.tr.toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFFFFD700),
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Lexend',
                    letterSpacing: 6,
                  ),
                ),
                const SizedBox(height: 8),
                Obx(() => Text(
                  controller.categoryLabel.replaceAll('🌸 ', '').replaceAll(' 💗', ''),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Lexend',
                    letterSpacing: -0.5,
                  ),
                )),
              ],
            ),
            const Spacer(),
            const SizedBox(width: 56),
          ],
        ),
      ),
    );
  }

  Widget _buildCelestialTabs(LayoutController lc) {
    return SliverToBoxAdapter(
      child: Column(
        children: [

          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 24),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  'likes',
                  'followers',
                  'wealth',
                  'views'
                ].map((catId) => _buildTabItem(catId, true, lc)).toList(),
              ),
            ),
          ),

          Center(
            child: Container(
              margin: const EdgeInsets.only(bottom: 40),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.02),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  'day',
                  'week',
                  'month',
                  'all_time'
                ].map((tfId) => _buildTabItem(tfId, false, lc)).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(String id, bool isCategory, LayoutController lc) {
    return Obx(() {
      final isSelected = isCategory 
          ? controller.selectedCategory.value == id 
          : controller.selectedTimeframe.value == id;

      final label = isCategory ? id.tr.toUpperCase() : id.tr.toUpperCase();

      return GestureDetector(
        onTap: () => isCategory ? controller.changeCategory(id) : controller.changeTimeframe(id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: EdgeInsets.symmetric(
            horizontal: isCategory ? 28 : 18, 
            vertical: isCategory ? 14 : 8
          ),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
            boxShadow: isSelected ? [
              BoxShadow(color: lc.primaryColor.withValues(alpha: 0.1), blurRadius: 10)
            ] : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.4),
              fontSize: isCategory ? 12 : 10,
              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
              letterSpacing: 1,
            ),
          ),
        ),
      );
    });
  }

  Widget _buildMonumentalPodium(LayoutController lc) {
    return SliverToBoxAdapter(
      child: Obx(() {
        if (controller.isLoading.value) {
          return SizedBox(
            height: 350,
            child: Center(
              child: CircularProgressIndicator(color: lc.primaryColor),
            ),
          );
        }

        final list = controller.activeList;
        if (list.isEmpty) return const SizedBox.shrink();

        final top1 = list.isNotEmpty ? list[0] : null;
        final top2 = list.length > 1 ? list[1] : null;
        final top3 = list.length > 2 ? list[2] : null;

        return Container(
          height: 550,
          padding: const EdgeInsets.symmetric(horizontal: 60),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [

              _buildPillar(top2, 2, 160, const Color(0xFFC0C0C0), lc),
              const SizedBox(width: 40),

              _buildPillar(top1, 1, 240, const Color(0xFFFFD700), lc),
              const SizedBox(width: 40),

              _buildPillar(top3, 3, 130, const Color(0xFFCD7F32), lc),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildPillar(dynamic artist, int rank, double height, Color accent, LayoutController lc) {
    if (artist == null) return const SizedBox.shrink();

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [

          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                width: rank == 1 ? 120 : 90,
                height: rank == 1 ? 120 : 90,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: accent.withValues(alpha: 0.5), width: 2),
                  boxShadow: [
                    BoxShadow(color: accent.withValues(alpha: 0.2), blurRadius: 30, spreadRadius: 5),
                  ],
                ),
                child: ClipOval(
                  child: artist.avatarUrl != null
                      ? CachedNetworkImage(
                          imageUrl: artist.avatarUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: Colors.white.withValues(alpha: 0.05),
                            highlightColor: Colors.white.withValues(alpha: 0.12),
                            child: Container(color: Colors.white10),
                          ),
                        )
                      : Container(
                          color: Colors.white10,
                          child: Icon(MdiIcons.accountOutline, color: Colors.white30),
                        ),
                ),
              ),

              Transform.translate(
                offset: const Offset(0, 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [BoxShadow(color: accent.withValues(alpha: 0.4), blurRadius: 10)],
                  ),
                  child: Text(
                    "#$rank",
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),

          Text(
            artist.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white,
              fontSize: rank == 1 ? 20 : 16,
              fontWeight: FontWeight.w900,
              fontFamily: 'Lexend',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _getMetricValue(artist),
            style: TextStyle(
              color: accent,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          Container(
            height: height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  accent.withValues(alpha: 0.15),
                  accent.withValues(alpha: 0.02),
                ],
              ),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              border: Border.all(color: accent.withValues(alpha: 0.1)),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: BackdropFilter(
                filter: ColorFilter.mode(accent.withValues(alpha: 0.05), BlendMode.srcOver),
                child: Container(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankingSection(LayoutController lc) {
    return Obx(() {
      final list = controller.activeList;
      if (list.length <= 3) {
        if (!controller.isLoading.value && list.isEmpty) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Text(
                "no_data_yet".tr,
                style: const TextStyle(color: Colors.white24, fontSize: 16, fontStyle: FontStyle.italic),
              ),
            ),
          );
        }
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      }

      final rest = list.sublist(3);

      return SliverPadding(
        padding: const EdgeInsets.fromLTRB(60, 40, 60, 0),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final artist = rest[index];
              final rank = index + 4;
              return _buildRankTile(artist, rank, lc)
                  .animate(delay: Duration(milliseconds: index * 60))
                  .fadeIn(duration: 400.ms, curve: Curves.easeOut)
                  .slideX(begin: 0.04, end: 0, duration: 400.ms, curve: Curves.easeOut);
            },
            childCount: rest.length,
          ),
        ),
      );
    });
  }

  Widget _buildRankTile(dynamic artist, int rank, LayoutController lc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: lc.cardColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: lc.textColor.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              "$rank",
              style: TextStyle(
                color: Colors.white.withValues(alpha: rank <= 10 ? 0.8 : 0.4),
                fontSize: 20,
                fontWeight: FontWeight.w900,
                fontFamily: 'Lexend',
              ),
            ),
          ),
          const SizedBox(width: 16),
          CircleAvatar(
            radius: 26,
            backgroundImage: artist.avatarUrl != null
                ? CachedNetworkImageProvider(artist.avatarUrl!)
                : null,
            backgroundColor: Colors.white.withValues(alpha: 0.05),
            child: artist.avatarUrl == null
                ? Icon(MdiIcons.accountOutline, color: Colors.white24)
                : null,
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  artist.name,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  "@${artist.id}",
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _getMetricValue(artist),
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, fontFamily: 'Lexend'),
              ),
              const SizedBox(height: 2),
              Text(
                controller.selectedCategory.value.tr.toUpperCase(),
                style: const TextStyle(color: Color(0xFFFFD700), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1),
              ),
            ],
          ),
          const SizedBox(width: 24),
          IconButton(
            onPressed: () => controller.nominateArtist(artist.id!, "Excellence in digital arts"),
            icon: Icon(MdiIcons.medalOutline, color: lc.primaryColor.withValues(alpha: 0.4), size: 28),
          ),
        ],
      ),
    );
  }

  String _getMetricValue(dynamic artist) {
    switch (controller.selectedCategory.value) {
      case 'likes': return "${artist.likesCount}";
      case 'followers': return "${artist.followersCount}";
      case 'wealth': return "${artist.balance.toInt()}";
      case 'views': return "${artist.viewsCount}";
      default: return "-";
    }
  }
}
