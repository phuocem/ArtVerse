import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/global/global_artwork_card.dart';
import '../controllers/portfolio_controller.dart';
class PortfolioViewTablet extends GetView<PortfolioController> {
  const PortfolioViewTablet({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          _PortfolioTopBar(controller: controller),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return Center(child: CircularProgressIndicator(color: AppColors.violet, strokeWidth: 2));
              }
              return Row(
                children: [
                  SizedBox(width: 240, child: _PortfolioSidebar(controller: controller)),
                  Expanded(child: _PortfolioGrid(controller: controller)),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}
class _PortfolioTopBar extends StatelessWidget {
  final PortfolioController controller;
  const _PortfolioTopBar({required this.controller});
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
          GestureDetector(
            onTap: () => Get.back<void>(),
            child: Icon(Icons.arrow_back_rounded, color: AppColors.textSecondary, size: 20),
          ),
          const SizedBox(width: 12),
          Text('Portfolio', style: GoogleFonts.lexend(
            color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(width: 8),
          Obx(() => Text('${controller.projects.length} works',
            style: GoogleFonts.ibmPlexMono(color: AppColors.textTertiary, fontSize: 10))),
          const Spacer(),
          Obx(() => Row(
            children: [
              _StatusChip(label: 'All', value: -1, selected: controller.filterStatus.value,
                  onTap: () => controller.filterStatus.value = -1),
              const SizedBox(width: 6),
              _StatusChip(label: 'Published', value: 1, selected: controller.filterStatus.value,
                  onTap: () => controller.filterStatus.value = 1),
              const SizedBox(width: 6),
              _StatusChip(label: 'Drafts', value: 0, selected: controller.filterStatus.value,
                  onTap: () => controller.filterStatus.value = 0),
            ],
          )),
        ],
      ),
    );
  }
}
class _StatusChip extends StatelessWidget {
  final String label;
  final int value;
  final int selected;
  final VoidCallback onTap;
  const _StatusChip({required this.label, required this.value, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final active = selected == value;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppColors.violet.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: active ? AppColors.violet.withValues(alpha: 0.3) : AppColors.border,
            width: 0.5,
          ),
        ),
        child: Text(label, style: GoogleFonts.plusJakartaSans(
          color: active ? AppColors.violet : AppColors.textTertiary,
          fontSize: 11, fontWeight: active ? FontWeight.w700 : FontWeight.w500)),
      ),
    );
  }
}
class _PortfolioSidebar extends StatelessWidget {
  final PortfolioController controller;
  const _PortfolioSidebar({required this.controller});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Obx(() {
            final score = controller.completionScore.value;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('PORTFOLIO SCORE', style: GoogleFonts.ibmPlexMono(
                  color: AppColors.textTertiary, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 2)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text('${(score * 100).toInt()}%', style: GoogleFonts.lexend(
                      color: score >= 0.7 ? AppColors.teal : AppColors.amber,
                      fontSize: 28, fontWeight: FontWeight.w900)),
                    const Spacer(),
                    Text(score >= 0.7 ? 'GREAT' : 'GROWING',
                      style: GoogleFonts.ibmPlexMono(
                        color: score >= 0.7 ? AppColors.teal : AppColors.amber,
                        fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: score,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      score >= 0.7 ? AppColors.teal : AppColors.amber),
                    minHeight: 6,
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 24),
          Container(height: 0.5, color: AppColors.border),
          const SizedBox(height: 20),
          Text('STATS', style: GoogleFonts.ibmPlexMono(
            color: AppColors.textTertiary, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 2)),
          const SizedBox(height: 12),
          Obx(() {
            final stats = controller.portfolioStats;
            return Column(
              children: stats.entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(e.key, style: GoogleFonts.plusJakartaSans(
                      color: AppColors.textSecondary, fontSize: 11)),
                    Text('${e.value}', style: GoogleFonts.lexend(
                      color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w700)),
                  ],
                ),
              )).toList(),
            );
          }),
          const SizedBox(height: 24),
          Container(height: 0.5, color: AppColors.border),
          const SizedBox(height: 20),
          Text('COLLECTIONS', style: GoogleFonts.ibmPlexMono(
            color: AppColors.textTertiary, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 2)),
          const SizedBox(height: 12),
          Obx(() {
            final cols = controller.collections;
            if (cols.isEmpty) {
              return Text('No collections yet', style: GoogleFonts.plusJakartaSans(
                color: AppColors.textTertiary, fontSize: 12));
            }
            return Column(
              children: cols.take(5).map((c) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surface2,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border, width: 0.5),
                ),
                child: Row(
                  children: [
                    Icon(Icons.folder_outlined, size: 14, color: AppColors.textTertiary),
                    const SizedBox(width: 8),
                    Expanded(child: Text(c['name'] ?? 'Collection', style: GoogleFonts.plusJakartaSans(
                      color: AppColors.textPrimary, fontSize: 11, fontWeight: FontWeight.w600))),
                    Text('${c['count'] ?? 0}', style: GoogleFonts.ibmPlexMono(
                      color: AppColors.textTertiary, fontSize: 9)),
                  ],
                ),
              )).toList(),
            );
          }),
        ],
      ),
    );
  }
}
class _PortfolioGrid extends StatelessWidget {
  final PortfolioController controller;
  const _PortfolioGrid({required this.controller});
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final all = controller.projects;
      final filtered = controller.filterStatus.value == -1
          ? all
          : all.where((p) => p.status == controller.filterStatus.value).toList();
      if (filtered.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.collections_outlined, size: 48, color: AppColors.textTertiary),
              const SizedBox(height: 12),
              Text('No works here', style: GoogleFonts.plusJakartaSans(
                color: AppColors.textTertiary, fontSize: 14)),
            ],
          ).animate().fadeIn(duration: 500.ms),
        );
      }
      return MasonryGridView.extent(
        padding: const EdgeInsets.all(24),
        maxCrossAxisExtent: 260,
        mainAxisSpacing: 20,
        crossAxisSpacing: 16,
        itemCount: filtered.length,
        itemBuilder: (ctx, i) => GlobalArtworkCard(
          post: filtered[i],
          onTap: () => Get.toNamed<void>('/view/${filtered[i].id}'),
        ).animate(delay: Duration(milliseconds: 50 * (i % 12)))
            .fadeIn(duration: 400.ms)
            .slideY(begin: 0.08, end: 0, curve: Curves.easeOutQuad),
      );
    });
  }
}