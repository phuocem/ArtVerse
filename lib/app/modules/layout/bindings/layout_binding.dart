import 'package:artverse/app/modules/home/providers/home_provider.dart';
import 'package:artverse/app/modules/home/repositories/home_repository.dart';
import 'package:get/get.dart';

import '../../home/controllers/home_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../marketplace/controllers/marketplace_controller.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../../challenge/controllers/challenge_controller.dart';
import '../controllers/layout_controller.dart';
import '../../draw/controllers/draw_controller.dart';
import '../../community/controllers/community_controller.dart';
import '../../community/providers/community_provider.dart';
import '../../community/repositories/community_repository.dart';
import '../../challenge/providers/challenge_provider.dart';
import '../../challenge/repositories/challenge_repository.dart';
import '../../profile/providers/auth_provider.dart';
import '../../profile/providers/user_provider.dart';
import '../../profile/repositories/profile_repository.dart';

class LayoutBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<LayoutController>(LayoutController());

    final homeProvider = Get.put<HomeProvider>(HomeProvider());
    final homeRepository = Get.put<HomeRepository>(HomeRepository(homeProvider));

    Get.put<HomeController>(HomeController(homeRepository));

    Get.lazyPut<DrawController>(() => DrawController());

    final communityRepository = Get.put<CommunityRepository>(
      CommunityRepository(provider: Get.put<CommunityProvider>(CommunityProvider())),
    );
    Get.put<CommunityController>(CommunityController(repository: communityRepository));

    final profileRepository = Get.put<ProfileRepository>(
      ProfileRepository(
        authProvider: Get.put<AuthProvider>(AuthProvider()),
        userProvider: Get.put<UserProvider>(UserProvider()),
      ),
    );
    Get.put<ProfileController>(ProfileController(repository: profileRepository));

    Get.put<MarketplaceController>(MarketplaceController());
    Get.put<DashboardController>(DashboardController());

    final challengeRepository = Get.put<ChallengeRepository>(
      ChallengeRepository(Get.put<ChallengeProvider>(ChallengeProvider())),
    );
    Get.put<ChallengeController>(ChallengeController(
      repository: challengeRepository,
      homeRepository: homeRepository,
    ));
  }
}
