import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../layout/controllers/layout_controller.dart';
import '../controllers/challenge_controller.dart';
import '../../../data/models/challenge_model.dart';

class ChallengeViewTablet extends GetView<ChallengeController> {
  const ChallengeViewTablet({super.key});

  @override
  Widget build(BuildContext context) {
    final lc = Get.find<LayoutController>();
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(children: [
        _buildAmbient(lc),
        RefreshIndicator(
          onRefresh: controller.refreshData,
          color: lc.primaryColor,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 72)),
              _buildHeader(lc),
              _buildDailyChallenge(lc),
              _buildActiveEvents(lc),
              _buildLeaderboard(lc),
              const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _buildAmbient(LayoutController lc) {
    return Obx(() => Stack(children: [
      Positioned(top: -120, left: -80, child: Container(width: 450, height: 450,
        decoration: BoxDecoration(shape: BoxShape.circle,
          gradient: RadialGradient(colors: [lc.primaryColor.withValues(alpha: 0.06), Colors.transparent])))),
      Positioned(bottom: -80, right: -40, child: Container(width: 350, height: 350,
        decoration: BoxDecoration(shape: BoxShape.circle,
          gradient: RadialGradient(colors: [lc.accentColor.withValues(alpha: 0.04), Colors.transparent])))),
    ]));
  }

  Widget _buildHeader(LayoutController lc) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(56, 16, 56, 40),
        child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Obx(() => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: lc.primaryColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: lc.primaryColor.withValues(alpha: 0.3))),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(width: 6, height: 6, decoration: BoxDecoration(shape: BoxShape.circle, color: lc.primaryColor,
                  boxShadow: [BoxShadow(color: lc.primaryColor.withValues(alpha: 0.5), blurRadius: 6)])),
                const SizedBox(width: 8),
                Text('LIVE EVENTS', style: GoogleFonts.plusJakartaSans(color: lc.primaryColor, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 2)),
              ]),
            )),
            const SizedBox(height: 16),
            Obx(() => Text('challenge_lab'.tr.toUpperCase(),
              style: GoogleFonts.cinzel(color: lc.textColor, fontSize: 40, fontWeight: FontWeight.w400, letterSpacing: -1))),
            const SizedBox(height: 6),
            Obx(() => Text('challenge_desc'.tr, style: TextStyle(color: lc.subtextColor, fontSize: 14, height: 1.5))),
          ]),
          const Spacer(),
          Obx(() => Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(color: lc.cardColor, borderRadius: BorderRadius.circular(16),
              border: Border.all(color: lc.textColor.withValues(alpha: 0.06))),
            child: Column(children: [
              Row(children: [
                const Icon(Icons.stars_rounded, color: Color(0xFFFBBF24), size: 16),
                const SizedBox(width: 8),
                Text('2,480 XP', style: GoogleFonts.lexend(color: lc.textColor, fontSize: 18, fontWeight: FontWeight.w900)),
              ]),
              const SizedBox(height: 8),
              ClipRRect(borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(value: 0.62,
                  backgroundColor: lc.textColor.withValues(alpha: 0.06),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFBBF24)), minHeight: 4)),
              const SizedBox(height: 6),
              Text('LVL 12  -  520 to next', style: TextStyle(color: lc.textColor.withValues(alpha: 0.3), fontSize: 10)),
            ]),
          )),
        ]),
      ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.08, end: 0),
    );
  }

  Widget _buildDailyChallenge(LayoutController lc) {
    return SliverToBoxAdapter(
      child: Obx(() {
        final prompt = controller.dailyPrompt.value;
        if (prompt == null) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 56),
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(36),
              gradient: lc.accentGradient,
              boxShadow: [BoxShadow(color: lc.primaryColor.withValues(alpha: 0.3), blurRadius: 40, offset: const Offset(0, 16))]),
            child: Stack(children: [
              Positioned.fill(child: Opacity(opacity: 0.04, child: CustomPaint(painter: _GridPainter()))),
              Positioned(top: -60, right: -60, child: Container(width: 250, height: 250,
                decoration: BoxDecoration(shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [Colors.white.withValues(alpha: 0.15), Colors.transparent])))),
              Padding(
                padding: const EdgeInsets.all(44),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                      child: Text("TODAY'S PROMPT  ⚡",
                        style: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 2))),
                    const SizedBox(height: 20),
                    Text('"${prompt.prompt}"',
                      style: GoogleFonts.cinzel(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w600, height: 1.3)),
                    const SizedBox(height: 24),
                    Row(children: [
                      _chip(Icons.stars_rounded, '${prompt.rewardXp} XP', const Color(0xFFFBBF24)),
                      const SizedBox(width: 12),
                      _chip(Icons.stars_rounded, 'RARE BADGE', Colors.white),
                    ]),
                    const SizedBox(height: 32),
                    GestureDetector(
                      onTap: () => controller.acceptChallenge(prompt),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.3))),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              Text('accept_challenge'.tr.toUpperCase(),
                                style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1)),
                              const SizedBox(width: 10),
                              const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
                            ]))))),
                  ])),
                  const SizedBox(width: 48),
                  Container(width: 220, height: 220,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(28),
                      color: Colors.white.withValues(alpha: 0.12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                      image: prompt.imageUrl != null
                          ? DecorationImage(image: NetworkImage(prompt.imageUrl!), fit: BoxFit.cover) : null),
                    child: prompt.imageUrl == null ? const Center(child: Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 64)) : null),
                ]),
              ),
            ]),
          ),
        ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideY(begin: 0.1, end: 0);
      }),
    );
  }

  Widget _chip(IconData icon, String label, Color iconColor) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
    decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, color: iconColor, size: 13), const SizedBox(width: 7),
      Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)),
    ]),
  );

  Widget _buildActiveEvents(LayoutController lc) {
    return SliverToBoxAdapter(child: Obx(() {
      final others = controller.activeChallenges.where((c) => c.id != controller.dailyPrompt.value?.id).toList();
      if (others.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.fromLTRB(56, 56, 56, 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _sectionTitle('weekly_masterpieces'.tr.toUpperCase(), lc),
          const SizedBox(height: 28),
          GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 20, crossAxisSpacing: 20, childAspectRatio: 2.5),
            itemCount: others.length,
            itemBuilder: (ctx, i) => _eventCard(others[i], lc, i)),
        ]),
      );
    }));
  }

  Widget _eventCard(ChallengeModel c, LayoutController lc, int i) {
    return GestureDetector(
      onTap: () => controller.acceptChallenge(c),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(color: lc.cardColor, borderRadius: BorderRadius.circular(22),
          border: Border.all(color: lc.textColor.withValues(alpha: 0.06))),
        child: Row(children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(shape: BoxShape.circle,
            color: lc.primaryColor.withValues(alpha: 0.08), border: Border.all(color: lc.primaryColor.withValues(alpha: 0.2))),
            child: Icon(Icons.auto_awesome_rounded, color: lc.primaryColor, size: 18)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(c.title, style: GoogleFonts.lexend(color: lc.textColor, fontSize: 13, fontWeight: FontWeight.w800), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 3),
            Text('${c.participantsCount} artists', style: TextStyle(color: lc.subtextColor, fontSize: 11)),
          ])),
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: lc.primaryColor.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
            child: Text('TIME LEFT', style: GoogleFonts.plusJakartaSans(color: lc.primaryColor, fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1.5))),
        ]),
      ).animate(delay: Duration(milliseconds: 60 * i)).fadeIn(duration: 400.ms).slideX(begin: 0.05, end: 0),
    );
  }

  Widget _buildLeaderboard(LayoutController lc) {
    return SliverToBoxAdapter(child: Padding(
      padding: const EdgeInsets.fromLTRB(56, 56, 56, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _sectionTitle('TOP VISIONARIES', lc),
        const SizedBox(height: 28),
        Obx(() {
          final users = controller.leaderboardUsers;
          if (users.isEmpty) return Center(child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: Text('No data yet', style: TextStyle(color: lc.subtextColor))));
          return Container(
            decoration: BoxDecoration(color: lc.cardColor.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(28), border: Border.all(color: lc.textColor.withValues(alpha: 0.05))),
            child: Column(children: users.take(8).toList().asMap().entries
              .map((e) => _leaderRow(e.key + 1, e.value, lc, e.key < 7)
                  .animate(delay: Duration(milliseconds: 50 * e.key)).fadeIn(duration: 400.ms).slideX(begin: 0.05, end: 0))
              .toList()));
        }),
      ]),
    ).animate().fadeIn(delay: 400.ms, duration: 600.ms).slideY(begin: 0.1, end: 0),
    );
  }

  Widget _leaderRow(int rank, dynamic user, LayoutController lc, bool showDivider) {
    const medalColors = {1: Color(0xFFFFD700), 2: Color(0xFFC0C0C0), 3: Color(0xFFCD7F32)};
    final isTop3 = rank <= 3;
    final medalColor = medalColors[rank];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: showDivider ? BoxDecoration(border: Border(bottom: BorderSide(color: lc.textColor.withValues(alpha: 0.04)))) : null,
      child: Row(children: [
        SizedBox(width: 40, child: isTop3
          ? Container(width: 28, height: 28,
              decoration: BoxDecoration(shape: BoxShape.circle,
                color: medalColor!.withValues(alpha: 0.12), border: Border.all(color: medalColor.withValues(alpha: 0.4))),
              child: Center(child: Text('$rank', style: GoogleFonts.lexend(color: medalColor, fontSize: 12, fontWeight: FontWeight.w900))))
          : Text('$rank', style: TextStyle(color: lc.textColor.withValues(alpha: 0.25), fontSize: 14, fontWeight: FontWeight.w700))),
        const SizedBox(width: 14),
        Container(
          decoration: isTop3 ? BoxDecoration(shape: BoxShape.circle,
            border: Border.all(color: medalColor!.withValues(alpha: 0.5), width: 2),
            boxShadow: [BoxShadow(color: medalColor.withValues(alpha: 0.2), blurRadius: 10)]) : null,
          child: CircleAvatar(radius: 17, backgroundColor: lc.primaryColor.withValues(alpha: 0.08),
            backgroundImage: (user.avatarUrl != null && (user.avatarUrl as String).isNotEmpty)
                ? NetworkImage(user.avatarUrl as String) : null,
            child: (user.avatarUrl == null || (user.avatarUrl as String).isEmpty)
                ? Icon(Icons.person_rounded, color: lc.primaryColor.withValues(alpha: 0.4), size: 14) : null)),
        const SizedBox(width: 14),
        Expanded(child: Text((user.name as String?) ?? 'Unknown Artist',
          style: TextStyle(color: lc.textColor, fontWeight: isTop3 ? FontWeight.w800 : FontWeight.w500, fontSize: 13))),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: lc.textColor.withValues(alpha: 0.04), borderRadius: BorderRadius.circular(8)),
          child: Text('${_fmtNum(user.followersCount as int)} followers',
            style: TextStyle(color: lc.textColor.withValues(alpha: 0.35), fontSize: 11, fontWeight: FontWeight.w600))),
      ]),
    );
  }

  Widget _sectionTitle(String text, LayoutController lc) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Obx(() => Text(text, style: GoogleFonts.cinzel(color: lc.textColor, fontSize: 22, fontWeight: FontWeight.w400))),
    const SizedBox(height: 8),
    Obx(() => Container(width: 36, height: 1.5, color: lc.primaryColor.withValues(alpha: 0.5))),
  ]);

  String _fmtNum(int n) => n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}K' : n.toString();
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white..strokeWidth = 0.5;
    const step = 28.0;
    for (double x = 0; x < size.width; x += step) canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    for (double y = 0; y < size.height; y += step) canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
