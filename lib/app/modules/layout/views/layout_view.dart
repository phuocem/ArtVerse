import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/layout_controller.dart';
import 'pro_side_rail.dart';
import '../../../widgets/performance/lazy_indexed_stack.dart';
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
        body: Stack(
          fit: StackFit.expand,
          children: [
            

            
            LazyIndexedStack(
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

            
            const Align(
              alignment: Alignment.bottomCenter,
              child: ProSideRail(),
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
        return [
          0.567, 0.433, 0.0, 0.0, 0.0,
          0.558, 0.442, 0.0, 0.0, 0.0,
          0.0, 0.242, 0.758, 0.0, 0.0,
          0.0, 0.0, 0.0, 1.0, 0.0
        ];
      case 'tritanopia':
        return [
          0.95, 0.05, 0.0, 0.0, 0.0,
          0.0, 0.433, 0.567, 0.0, 0.0,
          0.0, 0.475, 0.525, 0.0, 0.0,
          0.0, 0.0, 0.0, 1.0, 0.0
        ];
      case 'deuteranopia':
      default:
        return [
          0.625, 0.375, 0.0, 0.0, 0.0,
          0.7, 0.3, 0.0, 0.0, 0.0,
          0.0, 0.3, 0.7, 0.0, 0.0,
          0.0, 0.0, 0.0, 1.0, 0.0
        ];
    }
  }
}
