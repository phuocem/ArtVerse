import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/marketplace_controller.dart';
import '../../../data/models/resource_model.dart';
class MarketplaceViewTablet extends GetView<MarketplaceController> {
  const MarketplaceViewTablet({super.key});
  static final _categories = [
    ('All', 'all', Icons.apps_rounded),
    ('Palettes', 'palette', Icons.palette_outlined),
    ('Lineart', 'lineart', Icons.gesture_rounded),
    ('Remix', 'remix', Icons.shuffle_rounded),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          _MarketTopBar(controller: controller, categories: _categories),
          Expanded(
            child: Row(
              children: [
                SizedBox(width: 260, child: _MarketLeftPanel(controller: controller)),
                Expanded(child: _MarketGrid(controller: controller)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
class _MarketTopBar extends StatelessWidget {
  final MarketplaceController controller;
  final List<(String, String, IconData)> categories;
  const _MarketTopBar({required this.controller, required this.categories});
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
          Text('Market', style: GoogleFonts.lexend(
            color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(width: 8),
          Obx(() => Text('${controller.filteredResources.length} assets',
            style: GoogleFonts.ibmPlexMono(color: AppColors.textTertiary, fontSize: 10))),
          const SizedBox(width: 24),
          Obx(() => Row(
            children: categories.map((cat) {
              final active = controller.selectedCategory.value == cat.$2;
              return GestureDetector(
                onTap: () => controller.filterResources(cat.$2),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: active ? AppColors.violet.withValues(alpha: 0.12) : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: active ? AppColors.violet.withValues(alpha: 0.3) : AppColors.border,
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(cat.$3, size: 13, color: active ? AppColors.violet : AppColors.textTertiary),
                      const SizedBox(width: 5),
                      Text(cat.$1, style: GoogleFonts.plusJakartaSans(
                        color: active ? AppColors.violet : AppColors.textTertiary,
                        fontSize: 11, fontWeight: active ? FontWeight.w700 : FontWeight.w500)),
                    ],
                  ),
                ),
              );
            }).toList(),
          )),
          const Spacer(),
          GestureDetector(
            onTap: () => Get.toNamed<void>('/marketplace/upload'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                gradient: AppColors.violetPink,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.upload_rounded, color: Colors.white, size: 14),
                  const SizedBox(width: 6),
                  Text('Upload', style: GoogleFonts.plusJakartaSans(
                    color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class _MarketLeftPanel extends StatelessWidget {
  final MarketplaceController controller;
  const _MarketLeftPanel({required this.controller});
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Obx(() => _RevenueCard(revenue: controller.totalRevenue.value)),
          const SizedBox(height: 16),
          Text('MY ASSETS', style: GoogleFonts.ibmPlexMono(
            color: AppColors.textTertiary, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 2)),
          const SizedBox(height: 10),
          Obx(() {
            final owned = controller.allResources
                .where((r) => controller.ownedAssetIds.contains(r.id)).toList();
            if (owned.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text('No owned assets yet', style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textTertiary, fontSize: 12)),
              );
            }
            return Column(
              children: owned.take(5).map((r) => _OwnedAssetRow(resource: r)).toList(),
            );
          }),
          const SizedBox(height: 16),
          Text('QUICK ACTIONS', style: GoogleFonts.ibmPlexMono(
            color: AppColors.textTertiary, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 2)),
          const SizedBox(height: 10),
          _ActionTile(icon: Icons.upload_file_rounded, label: 'Sell an Asset',
              sub: 'Share your work', onTap: () => Get.toNamed<void>('/marketplace/upload')),
          const SizedBox(height: 6),
          _ActionTile(icon: MdiIcons.wallet, label: 'Wallet',
              sub: 'Manage earnings', onTap: () => Get.toNamed<void>('/wallet')),
        ],
      ),
    );
  }
}
class _RevenueCard extends StatelessWidget {
  final double revenue;
  const _RevenueCard({required this.revenue});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.violetPink,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('TOTAL REVENUE', style: GoogleFonts.ibmPlexMono(
            color: Colors.white60, fontSize: 8, fontWeight: FontWeight.w700, letterSpacing: 2)),
          const SizedBox(height: 6),
          Text('\$${revenue.toStringAsFixed(2)}', style: GoogleFonts.lexend(
            color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
          const SizedBox(height: 4),
          Text('From sold assets', style: GoogleFonts.plusJakartaSans(
            color: Colors.white60, fontSize: 10)),
        ],
      ),
    );
  }
}
class _OwnedAssetRow extends StatelessWidget {
  final ResourceModel resource;
  const _OwnedAssetRow({required this.resource});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 30, height: 30,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: AppColors.amber.withValues(alpha: 0.1),
              image: resource.thumbnailUrl.isNotEmpty
                  ? DecorationImage(image: NetworkImage(resource.thumbnailUrl), fit: BoxFit.cover)
                  : null,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(resource.name, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textPrimary, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
          const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.teal),
        ],
      ),
    );
  }
}
class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  final VoidCallback onTap;
  const _ActionTile({required this.icon, required this.label, required this.sub, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface2,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.violet),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textPrimary, fontSize: 11, fontWeight: FontWeight.w700)),
                Text(sub, style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textTertiary, fontSize: 10)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
class _MarketGrid extends StatelessWidget {
  final MarketplaceController controller;
  const _MarketGrid({required this.controller});
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final resources = controller.filteredResources;
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator(color: AppColors.violet, strokeWidth: 2));
      }
      if (resources.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.shopping_bag_outlined, size: 48, color: AppColors.textTertiary),
              const SizedBox(height: 12),
              Text('No assets found', style: GoogleFonts.plusJakartaSans(
                color: AppColors.textTertiary, fontSize: 14)),
            ],
          ),
        );
      }
      return GridView.builder(
        padding: const EdgeInsets.all(24),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 240,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 0.78,
        ),
        itemCount: resources.length,
        itemBuilder: (ctx, i) => _AssetCard(
          resource: resources[i],
          isOwned: controller.ownedAssetIds.contains(resources[i].id),
          onTap: () => controller.downloadResource(resources[i]),
        ).animate(delay: Duration(milliseconds: 50 * (i % 12)))
            .fadeIn(duration: 400.ms)
            .slideY(begin: 0.08, end: 0, curve: Curves.easeOutCubic),
      );
    });
  }
}
class _AssetCard extends StatelessWidget {
  final ResourceModel resource;
  final bool isOwned;
  final VoidCallback onTap;
  const _AssetCard({required this.resource, required this.isOwned, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface2,
                      image: resource.thumbnailUrl.isNotEmpty
                          ? DecorationImage(
                              image: resource.thumbnailUrl.startsWith('assets/')
                                  ? AssetImage(resource.thumbnailUrl) as ImageProvider
                                  : NetworkImage(resource.thumbnailUrl),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                  ),
                  Positioned(
                    top: 10, right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(resource.type.toUpperCase(), style: GoogleFonts.ibmPlexMono(
                        color: Colors.white70, fontSize: 8, fontWeight: FontWeight.w700, letterSpacing: 1)),
                    ),
                  ),
                  if (isOwned)
                    Positioned(
                      top: 10, left: 10,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: AppColors.teal, shape: BoxShape.circle),
                        child: const Icon(Icons.check_rounded, size: 10, color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(resource.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text('By ${resource.authorName}', style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textTertiary, fontSize: 10)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.download_outlined, size: 12, color: AppColors.textTertiary),
                      const SizedBox(width: 3),
                      Text('${resource.downloadsCount}', style: GoogleFonts.ibmPlexMono(
                        color: AppColors.textTertiary, fontSize: 9)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isOwned
                              ? AppColors.teal.withValues(alpha: 0.1)
                              : AppColors.violet.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isOwned ? AppColors.teal : AppColors.violet,
                            width: 0.5,
                          ),
                        ),
                        child: Text(isOwned ? 'OWNED' : 'GET', style: GoogleFonts.ibmPlexMono(
                          color: isOwned ? AppColors.teal : AppColors.violet,
                          fontSize: 9, fontWeight: FontWeight.w900)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
