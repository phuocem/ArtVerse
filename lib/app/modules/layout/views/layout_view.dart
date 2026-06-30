import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../controllers/layout_controller.dart';
import '../../../data/models/user_model.dart';
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
        backgroundColor: controller.backgroundColor,
        body: Row(
          children: [
            const _LeftSidebar(),
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
class _LeftSidebar extends GetView<LayoutController> {
  const _LeftSidebar();
  static final _items = [
    _NavItem(icon: MdiIcons.paletteOutline, activeIcon: MdiIcons.palette, label: 'Studio', index: 0, imagePath: 'assets/images/branding/studio_btn.png'),
    _NavItem(icon: MdiIcons.accountGroupOutline, activeIcon: MdiIcons.accountGroup, label: 'Community', index: 1, imagePath: 'assets/images/branding/community_btn.png'),
    _NavItem(icon: MdiIcons.storefrontOutline, activeIcon: MdiIcons.storefront, label: 'Market', index: 2, imagePath: 'assets/images/branding/market_btn.png'),
    _NavItem(icon: MdiIcons.tournament, activeIcon: MdiIcons.tournament, label: 'Arena', index: 3, imagePath: 'assets/images/branding/arena_btn.png'),
    _NavItem(icon: MdiIcons.lightningBoltOutline, activeIcon: MdiIcons.lightningBolt, label: 'Pulse', index: 4, imagePath: 'assets/images/branding/pulse_btn.png'),
    _NavItem(icon: MdiIcons.accountCircleOutline, activeIcon: MdiIcons.accountCircle, label: 'Profile', index: 5),
  ];
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = controller.isDark.value;
      return Container(
        width: 72,
        decoration: BoxDecoration(
          color: controller.surfaceColor,
          border: Border(
            right: BorderSide(color: AppColors.border, width: 0.5),
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const _LogoView(),
            const SizedBox(height: 8),
            Container(height: 0.5, color: AppColors.border, margin: const EdgeInsets.symmetric(horizontal: 16)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 4),
                children: _items.map((item) => _NavTile(item: item)).toList(),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    });
  }
}
class _NavTile extends StatefulWidget {
  final _NavItem item;
  const _NavTile({required this.item});

  @override
  State<_NavTile> createState() => _NavTileState();
}

class _NavTileState extends State<_NavTile> with TickerProviderStateMixin {
  bool _isHovered = false;
  bool _isPressed = false;
  
  late AnimationController _shimmerController;
  
  late AnimationController _morphController;
  late Animation<double> _morphAnimation;

  @override
  void initState() {
    super.initState();

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _morphController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _morphAnimation = CurvedAnimation(parent: _morphController, curve: Curves.easeInOut);
    
    _morphController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _morphController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LayoutController>();
    return Obx(() {
      final isActive = controller.currentIndex.value == widget.item.index;
      final user = controller.profileController.currentUser.value;

      if (isActive) {
        if (!_shimmerController.isAnimating && _shimmerController.value == 0) {
          _shimmerController.forward();
        }
      } else {
        _shimmerController.reset();
      }

      double scale = 1.0;
      if (_isPressed) {
        scale = 0.90;
      } else if (_isHovered) {
        scale = 1.05;
      }

      final activeColor = controller.primaryColor;
      final inactiveColor = AppColors.textTertiary;
      
      final borderRadius = BorderRadius.only(
        topLeft: Radius.circular(12 + (8 * _morphAnimation.value)),
        topRight: Radius.circular(20 - (8 * _morphAnimation.value)),
        bottomLeft: Radius.circular(20 - (6 * _morphAnimation.value)),
        bottomRight: Radius.circular(12 + (8 * _morphAnimation.value)),
      );

      Color bgColor = Colors.transparent;
      Color borderColor = Colors.transparent;
      List<BoxShadow>? shadows;

      if (isActive) {
        bgColor = activeColor.withValues(alpha: 0.15);
        borderColor = activeColor.withValues(alpha: 0.35);
        shadows = [
          BoxShadow(
            color: activeColor.withValues(alpha: 0.25),
            blurRadius: 15,
            spreadRadius: 1,
          )
        ];
      } else if (_isHovered) {
        bgColor = controller.textColor.withValues(alpha: 0.06);
        borderColor = controller.textColor.withValues(alpha: 0.15);
      }

      return MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: () => controller.onTabChange(widget.item.index),
          child: AnimatedScale(
            scale: scale,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOutCubic,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: borderRadius,
                  border: Border.all(
                    color: borderColor,
                    width: 1.0,
                  ),
                  boxShadow: shadows,
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    if (isActive)
                      AnimatedBuilder(
                        animation: _shimmerController,
                        builder: (context, child) {
                          return Positioned.fill(
                            child: ClipRRect(
                              borderRadius: borderRadius,
                              child: ShaderMask(
                                shaderCallback: (bounds) {
                                  return LinearGradient(
                                    begin: Alignment(-2.0 + 4.0 * _shimmerController.value, -1.0),
                                    end: Alignment(-1.0 + 4.0 * _shimmerController.value, 1.0),
                                    colors: const [
                                      Colors.transparent,
                                      Colors.white10,
                                      Colors.white24,
                                      Colors.white10,
                                      Colors.transparent,
                                    ],
                                    stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
                                  ).createShader(bounds);
                                },
                                blendMode: BlendMode.srcATop,
                                child: Container(color: Colors.transparent),
                              ),
                            ),
                          );
                        },
                      ),
                    
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOutCubic,
                      left: isActive ? -4 : -10,
                      top: 18,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: isActive ? 1.0 : 0.0,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: activeColor,
                            boxShadow: [
                              BoxShadow(
                                color: activeColor,
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            if (isActive)
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: activeColor.withValues(alpha: 0.25),
                                    width: 1.0,
                                  ),
                                ),
                              ),
                            _buildNavIcon(isActive, activeColor, inactiveColor, user),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Text(
                          widget.item.label,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 8.5,
                            fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
                            color: isActive 
                                ? activeColor 
                                : (_isHovered ? controller.textColor.withValues(alpha: 0.9) : inactiveColor),
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildNavIcon(bool isActive, Color activeColor, Color inactiveColor, UserModel? user) {
    if (widget.item.index == 5 && user?.avatarUrl != null) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isActive ? activeColor : activeColor.withValues(alpha: 0.3),
            width: isActive ? 1.5 : 1.0,
          ),
          image: DecorationImage(
            image: NetworkImage(user!.avatarUrl!),
            fit: BoxFit.cover,
          ),
        ),
      );
    } else if (widget.item.imagePath != null) {
      return AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isActive || _isHovered ? 1.0 : 0.85,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(
            widget.item.imagePath!,
            width: 34,
            height: 34,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.medium,
          ),
        ),
      );
    } else {
      return Icon(
        isActive ? widget.item.activeIcon : widget.item.icon,
        size: 26,
        color: isActive 
            ? activeColor 
            : (_isHovered ? activeColor.withValues(alpha: 0.8) : inactiveColor),
      );
    }
  }
}


class _LogoView extends StatefulWidget {
  const _LogoView();

  @override
  State<_LogoView> createState() => _LogoViewState();
}

class _LogoViewState extends State<_LogoView> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.1 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutBack,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.asset(
            'assets/images/branding/app_icon.png',
            width: 54,
            height: 54,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.medium,
          ),
        ),
      ),
    );
  }
}
class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final String? imagePath;
  const _NavItem({required this.icon, required this.activeIcon, required this.label, required this.index, this.imagePath});
}