import 'dart:ui';

import 'package:blur/blur.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../data/models/resource_model.dart';
import '../../layout/controllers/layout_controller.dart';
import '../controllers/marketplace_controller.dart';
import '../../../widgets/common/studio_common_widgets.dart';

class MarketplaceViewTablet extends GetView<MarketplaceController> {
  const MarketplaceViewTablet({super.key});

  @override
  Widget build(BuildContext context) {
    final lc = Get.find<LayoutController>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          
          _buildAtmosphere(lc),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildHeader(lc),
              
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      MarketplaceHero(lc: lc).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0),
                      const SizedBox(height: 56),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          GlobalSectionTitle(title: 'WEEKLY TRENDING', subtitle: 'MASTERPIECE CURATIONS', lc: lc).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideY(begin: 0.1, end: 0),
                          const Spacer(),
                          _viewAllBtn(lc),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildTrendingLane(lc).animate().fadeIn(delay: 300.ms, duration: 600.ms).slideX(begin: 0.05, end: 0),
                      
                      const SizedBox(height: 72),
                      GlobalSectionTitle(title: 'DISCOVER ASSETS', subtitle: 'CREATIVE RESOURCES', lc: lc).animate().fadeIn(delay: 400.ms, duration: 600.ms).slideY(begin: 0.1, end: 0),
                      const SizedBox(height: 32),
                      
                      
                      if (controller.allResources.any((r) => r.authorId == 'mock_self')) 
                        _buildRevenueDashboard(lc),
                    ],
                  ),
                ),
              ),

              _buildMasonryDiscoveryGrid(lc),

              const SliverToBoxAdapter(child: SizedBox(height: 150)),
            ],
          ),

          
          _buildFloatingDock(lc),
        ],
      ),
    );
  }

  Widget _buildAtmosphere(LayoutController lc) {
    return Obx(() {
      final color = _getAccentColor(lc);
      return AnimatedContainer(
        duration: const Duration(seconds: 2),
        decoration: BoxDecoration(color: lc.backgroundColor),
        child: Stack(
          children: [
            Positioned(
              top: -200, right: -100,
              child: _auraPoint(color.withValues(alpha: 0.08), 700),
            ),
            Positioned(
              bottom: -150, left: -200,
              child: _auraPoint(lc.primaryColor.withValues(alpha: 0.05), 900),
            ),
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 130, sigmaY: 130),
              child: Container(color: Colors.transparent),
            ),
          ],
        ),
      );
    });
  }

  Widget _auraPoint(Color color, double size) => Container(
    width: size, height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)])),
  );

  Widget _buildHeader(LayoutController lc) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      toolbarHeight: 90,
      title: Container(
        height: 54,
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: lc.cardColor.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: lc.textColor10, width: 0.5),
        ),
        child: Row(
          children: [
            Icon(MdiIcons.magnify, color: lc.textColor30, size: 20),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                style: TextStyle(color: lc.textColor, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search creative assets, brushes, or models...',
                  hintStyle: TextStyle(color: lc.textColor30, fontSize: 13),
                  border: InputBorder.none,
                ),
              ),
            ),
            _badge('⌘ K', lc.textColor10, lc),
          ],
        ),
      ).blurred(blur: 15, colorOpacity: 0).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2, end: 0),
      actions: [
        CircleAvatar(
          radius: 20,
          backgroundColor: lc.cardColor,
          child: Icon(MdiIcons.bellOutline, color: lc.textColor, size: 20),
        ),
        const SizedBox(width: 48),
      ],
    );
  }

  Widget _buildImmersiveHero(LayoutController lc) {
    return Container(
      height: 380,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(color: lc.primaryColor.withValues(alpha: 0.15), blurRadius: 60, offset: const Offset(0, 30)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              'https:
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomLeft,
                  end: Alignment.topRight,
                  colors: [lc.backgroundColor, lc.backgroundColor.withValues(alpha: 0.4), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            left: 56, bottom: 56,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _glassBadge('SEASON PASS · 2026', lc.primaryColor, lc),
                const SizedBox(height: 24),
                Text(
                  'CYBERSPACE\nRIGGING STUDIO',
                  style: GoogleFonts.lexend(color: lc.textColor, fontSize: 64, fontWeight: FontWeight.w900, height: 0.9, letterSpacing: -2),
                ),
                const SizedBox(height: 16),
                Text('Studio-grade rigging templates and character bases.', style: TextStyle(color: lc.subtextColor, fontSize: 18, fontWeight: FontWeight.w400)),
                const SizedBox(height: 48),
                Row(
                  children: [
                    _gradientButton('EXPLORE VAULT', lc, () => controller.filterResources('All')),
                    const SizedBox(width: 20),
                    _outlineBtn('Watch Trailer', lc, onTap: () => Get.toNamed<void>('/community')),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, String subtitle, LayoutController lc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(subtitle.toUpperCase(), style: GoogleFonts.lexend(fontSize: 10, fontWeight: FontWeight.w900, color: lc.primaryColor, letterSpacing: 2.5)),
        const SizedBox(height: 8),
        Text(title, style: GoogleFonts.cinzel(fontSize: 28, fontWeight: FontWeight.w400, color: lc.textColor, letterSpacing: 1)),
      ],
    );
  }

  Widget _viewAllBtn(LayoutController lc) => TextButton(
    onPressed: () => controller.filterResources('All'),
    child: Row(
      children: [
        Text('View All', style: TextStyle(color: lc.primaryColor, fontWeight: FontWeight.w800, fontSize: 14)),
        const SizedBox(width: 8),
        Icon(MdiIcons.arrowRight, size: 16, color: lc.primaryColor),
      ],
    ),
  );

  Widget _buildTrendingLane(LayoutController lc) {
    return Obx(() {
      final trending = controller.allResources.take(6).toList();
      return SizedBox(
        height: 320,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(right: 48),
          physics: const BouncingScrollPhysics(),
          itemCount: trending.length,
          itemBuilder: (context, i) => Padding(
            padding: const EdgeInsets.only(right: 32),
            child: _buildCompactMarketCard(trending[i], lc, isWide: true),
          ),
        ),
      );
    });
  }

  Widget _buildMasonryDiscoveryGrid(LayoutController lc) {
    return Obx(() {
      if (controller.filteredResources.isEmpty) {
        return SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: lc.primaryColor)));
      }

      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        sliver: SliverMasonryGrid.count(
          crossAxisCount: 3,
          mainAxisSpacing: 32,
          crossAxisSpacing: 32,
          itemBuilder: (context, index) {
            final resource = controller.filteredResources[index];
            return MarketplaceCard(resource: resource, lc: lc).animate(delay: Duration(milliseconds: 100 * (index % 12))).fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad);
          },
          childCount: controller.filteredResources.length,
        ),
      );
    });
  }

  Widget _buildMarketplaceCard(ResourceModel resource, LayoutController lc) {
    final bool isOwned = controller.ownedAssetIds.contains(resource.id);
    
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => controller.downloadResource(resource),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: lc.textColor10, width: 1),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 30, offset: const Offset(0, 15)),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: GlassCard(
            borderRadius: 28,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 1.1,
                      child: Container(
                        decoration: BoxDecoration(
                          image: (resource.isLottie && resource.lottieUrl != null) ? null : DecorationImage(
                            image: resource.thumbnailUrl.startsWith('assets/') 
                              ? AssetImage(resource.thumbnailUrl) as ImageProvider
                              : NetworkImage(resource.thumbnailUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: (resource.isLottie && resource.lottieUrl != null)
                          ? Center(child: Lottie.network(resource.lottieUrl!, fit: BoxFit.contain, height: 140))
                          : null,
                      ),
                    ),
                    Positioned(
                      top: 16, right: 16,
                      child: _assetBadge(resource.type.toUpperCase(), isOwned ? Colors.amber : lc.textColor.withValues(alpha: 0.1), lc),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(resource.name, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: lc.textColor, letterSpacing: -0.5)),
                      const SizedBox(height: 6),
                      Text('By ${resource.authorName}', style: TextStyle(fontSize: 13, color: lc.subtextColor, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          _statLabel(MdiIcons.downloadOutline, '${resource.downloadsCount}', lc),
                          const SizedBox(width: 16),
                          _statLabel(MdiIcons.shimmer, 'STUDIO', lc),
                          const Spacer(),
                          _cardActionBtn(isOwned, lc),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statLabel(IconData icon, String val, LayoutController lc) => Row(
    children: [
      Icon(icon, size: 14, color: lc.textColor30),
      const SizedBox(width: 6),
      Text(val, style: TextStyle(fontSize: 12, color: lc.textColor30, fontWeight: FontWeight.w800)),
    ],
  );

  Widget _cardActionBtn(bool isOwned, LayoutController lc) => Container(
    width: 44, height: 44,
    decoration: BoxDecoration(
      color: isOwned ? lc.primaryColor15 : lc.textColor05,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: isOwned ? lc.primaryColor : lc.textColor10, width: 1),
    ),
    child: Icon(isOwned ? MdiIcons.sendVariant : MdiIcons.download, size: 20, color: isOwned ? lc.primaryColor : lc.textColor),
  );

  Widget _buildCompactMarketCard(ResourceModel resource, LayoutController lc, {bool isWide = false}) {
    return Container(
      width: isWide ? 420 : 220,
      decoration: BoxDecoration(
        color: lc.cardColor,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: lc.textColor10, width: 0.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 40, offset: const Offset(0, 20)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.network(resource.thumbnailUrl, fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withValues(alpha: 0.8), Colors.black.withValues(alpha: 0.2), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            left: 24, bottom: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _badge('POPULAR', lc.primaryColor, lc),
                const SizedBox(height: 12),
                Text(resource.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: -0.5)),
                Text(resource.authorName.toUpperCase(), style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
              ],
            ),
          ),
          Positioned(
            top: 24, right: 24,
            child: CircleAvatar(
              backgroundColor: Colors.white.withValues(alpha: 0.15),
              radius: 18,
              child: const Icon(Icons.favorite_border_rounded, color: Colors.white, size: 18),
            ).blurred(blur: 10, colorOpacity: 0),
          ),
        ],
      ),
    );
  }

  Widget _glassBadge(String label, Color color, LayoutController lc) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(12.0),
      border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
    ),
    child: Text(label, style: GoogleFonts.plusJakartaSans(color: color, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
  ).blurred(blur: 20, colorOpacity: 0);

  Widget _assetBadge(String label, Color color, LayoutController lc) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withValues(alpha: 0.3), width: 0.5)),
    child: Text(label, style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
  ).blurred(blur: 10, colorOpacity: 0);

  Widget _outlineBtn(String label, LayoutController lc, {VoidCallback? onTap}) => GestureDetector(
    onTap: onTap,
    child: Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: lc.textColor.withValues(alpha: 0.1), width: 1.5),
      ),
      child: Center(
        child: Text(label, style: TextStyle(color: lc.textColor, fontWeight: FontWeight.bold, fontSize: 15)),
      ),
    ),
  );

  Widget _buildFloatingDock(LayoutController lc) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 48),
        child: GlassCard(
          borderRadius: 36,
          padding: const EdgeInsets.all(10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _dockAction('Library', MdiIcons.viewGridOutline, 'All', lc),
              _dockAction('Brushes', MdiIcons.brushOutline, 'Linearts', lc),
              _dockAction('Palettes', MdiIcons.paletteOutline, 'Palettes', lc),
              _dockAction('Masters', MdiIcons.rocketLaunchOutline, 'Remix Projects', lc),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(delay: 600.ms, duration: 800.ms).slideY(begin: 0.5, end: 0, curve: Curves.easeOutBack);
  }

  Widget _dockAction(String label, IconData icon, String category, LayoutController lc) {
    return Obx(() {
      final active = controller.selectedCategory.value == category;
      return GestureDetector(
        onTap: () => controller.filterResources(category),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            color: active ? lc.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Row(
            children: [
              Icon(icon, color: active ? lc.onPrimaryColor : lc.textColor.withValues(alpha: 0.4), size: 22),
              if (active) ...[
                const SizedBox(width: 12),
                Text(label, style: TextStyle(color: lc.onPrimaryColor, fontWeight: FontWeight.w900, fontSize: 14)),
              ],
            ],
          ),
        ),
      );
    });
  }

  Widget _badge(String text, Color color, LayoutController lc) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
      child: Text(text, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: lc.textColor)),
    );
  }

  Widget _buildRevenueDashboard(LayoutController lc) {
    return Obx(() {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 48),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: lc.cardColor.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: lc.primaryColor.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlobalSectionTitle(title: 'REVENUE ANALYTICS', subtitle: 'ARTIST MANAGEMENT', lc: lc),
            const SizedBox(height: 32),
            Row(
              children: [
                _revenueStat('TOTAL REVENUE', '${controller.totalRevenue.value}', Colors.teal, lc),
                const SizedBox(width: 24),
                _revenueStat('COMMISSIONS', '${controller.commissionRevenue.value}', Colors.pink, lc),
                const SizedBox(width: 24),
                _revenueStat('TIPS/DONATIONS', '${controller.tipRevenue.value}', Colors.amber, lc),
              ],
            ),
            const SizedBox(height: 32),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  'Monthly Revenue Chart: ${controller.revenueHistory.map((h) => h['month']).join(' → ')}',
                  style: TextStyle(color: lc.textColor.withValues(alpha: 0.1)),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _revenueStat(String label, String val, Color color, LayoutController lc) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: lc.textColor.withValues(alpha: 0.3), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
            const SizedBox(height: 12),
            Text('🌸 $val', style: GoogleFonts.lexend(color: color, fontSize: 24, fontWeight: FontWeight.w900)),
          ],
        ),
      ),
    );
  }

  Widget _gradientButton(String label, LayoutController lc, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 32),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [lc.primaryColor, lc.primaryColor.withValues(alpha: 0.7)]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: lc.primaryColor.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: Center(
          child: Text(label, style: TextStyle(color: lc.onPrimaryColor, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1)),
        ),
      ),
    );
  }

  Color _getAccentColor(LayoutController lc) {
    switch (controller.selectedCategory.value) {
      case 'Palettes': return Colors.teal;
      case 'Linearts': return Colors.blue;
      case 'Remix Projects': return Colors.pink;
      default: return lc.primaryColor;
    }
  }
}
