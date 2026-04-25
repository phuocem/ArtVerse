import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../controllers/layout_controller.dart';
import '../../../widgets/performance/lazy_indexed_stack.dart';
import '../../../core/theme/app_colors.dart';
import '../../home/views/home_view.dart';
import '../../community/views/community_view_tablet.dart';
import '../../marketplace/views/marketplace_view_tablet.dart';
import '../../challenge/views/challenge_view_tablet.dart';
import '../../dashboard/views/dashboard_view_tablet.dart';
import '../../profile/views/profile_view_tablet.dart';

class LayoutView extends GetView<LayoutController> {
  const LayoutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      Widget body = Scaffold(
        backgroundColor: AppColors.bg,
        body: Row(
          children: [
            // ── Left Sidebar ──────────────────────────
            const _LeftSidebar(),

            // ── Content Area ──────────────────────────
            Expanded(
              child: LazyIndexedStack(
                index: controller.currentIndex.value,
                children: const [
                  HomeView(),
                  CommunityViewTablet(),
                  MarketplaceViewTablet(),
                  ChallengeViewTablet(),
                  DashboardViewTablet(),
                  ProfileViewTablet(),
                ],
              ),
            ),
          ],
        ),
      );

      if (controller.isColorBlindMode.value) {
        return ColorFiltered(
          colorFilter: ColorFilter.matrix(_getColorMatrix(controller.colorBlindType.value)),
          child: body,
        );
      }
      return body;
    });
  }

  List<double> _getColorMatrix(String type) {
    switch (type) {
      case 'protanopia':
        return [0.567, 0.433, 0.0, 0.0, 0.0, 0.558, 0.442, 0.0, 0.0, 0.0, 0.0, 0.242, 0.758, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0];
      case 'tritanopia':
        return [0.95, 0.05, 0.0, 0.0, 0.0, 0.0, 0.433, 0.567, 0.0, 0.0, 0.0, 0.475, 0.525, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0];
      case 'deuteranopia':
      default:
        return [0.625, 0.375, 0.0, 0.0, 0.0, 0.7, 0.3, 0.0, 0.0, 0.0, 0.0, 0.3, 0.7, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0];
    }
  }
}

// ════════════════════════════════════════════════════════════════════════
// LEFT SIDEBAR
// ════════════════════════════════════════════════════════════════════════

class _LeftSidebar extends GetView<LayoutController> {
  const _LeftSidebar();

  static final _items = [
    _NavItem(icon: MdiIcons.viewDashboardOutline, activeIcon: MdiIcons.viewDashboard, label: 'Studio', index: 0),
    _NavItem(icon: MdiIcons.compassOutline, activeIcon: MdiIcons.compass, label: 'Discover', index: 1),
    _NavItem(icon: MdiIcons.shoppingOutline, activeIcon: MdiIcons.shopping, label: 'Market', index: 2),
    _NavItem(icon: MdiIcons.swordCross, activeIcon: MdiIcons.swordCross, label: 'Arena', index: 3),
    _NavItem(icon: MdiIcons.chartLineVariant, activeIcon: MdiIcons.chartLine, label: 'Pulse', index: 4),
    _NavItem(icon: MdiIcons.accountOutline, activeIcon: MdiIcons.account, label: 'Profile', index: 5),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = controller.isDark.value;
      return Container(
        width: 72,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(
            right: BorderSide(color: AppColors.border, width: 0.5),
          ),
        ),
        child: Column(
          children: [
            // Logo
            const SizedBox(height: 20),
            _buildLogo(),
            const SizedBox(height: 8),
            Container(height: 0.5, color: AppColors.border, margin: const EdgeInsets.symmetric(horizontal: 16)),
            const SizedBox(height: 16),

            // Nav items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 4),
                children: _items.map((item) => _NavTile(item: item)).toList(),
              ),
            ),

            // Bottom actions
            _buildBottomActions(isDark),
            const SizedBox(height: 16),
          ],
        ),
      );
    });
  }

  Widget _buildLogo() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: AppColors.violetPink,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          'A',
          style: GoogleFonts.lexend(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomActions(bool isDark) {
    return Column(
      children: [
        Container(height: 0.5, color: AppColors.border, margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
        _IconBtn(
          icon: isDark ? MdiIcons.weatherSunny : MdiIcons.weatherNight,
          tooltip: isDark ? 'Light Mode' : 'Dark Mode',
          onTap: () {
                controller.isDark.toggle();
                Get.changeThemeMode(controller.isDark.value ? ThemeMode.dark : ThemeMode.light);
              },
        ),
        const SizedBox(height: 4),
        _IconBtn(
          icon: MdiIcons.cog,
          tooltip: 'Settings',
          onTap: () => Get.toNamed<void>('/settings'),
        ),
      ],
    );
  }
}

// ── Nav Tile ────────────────────────────────────────────────────────────

class _NavTile extends GetView<LayoutController> {
  final _NavItem item;
  const _NavTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isActive = controller.currentIndex.value == item.index;
      return GestureDetector(
        onTap: () => controller.onTabChange(item.index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? AppColors.violet.withValues(alpha: 0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? AppColors.violet.withValues(alpha: 0.25) : Colors.transparent,
              width: 0.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isActive ? item.activeIcon : item.icon,
                  key: ValueKey(isActive),
                  size: 22,
                  color: isActive ? AppColors.violet : AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 9,
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                  color: isActive ? AppColors.violet : AppColors.textTertiary,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

// ── Icon Button ─────────────────────────────────────────────────────────

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      preferBelow: false,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: AppColors.textTertiary),
        ),
      ),
    );
  }
}

// ── Data class ──────────────────────────────────────────────────────────

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  const _NavItem({required this.icon, required this.activeIcon, required this.label, required this.index});
}
