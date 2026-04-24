import 'package:get/get.dart';

import '../modules/challenge/bindings/challenge_binding.dart';
import '../modules/challenge/views/challenge_view_tablet.dart';
import '../modules/community/bindings/community_binding.dart';
import '../modules/community/bindings/messaging_binding.dart';
import '../modules/community/bindings/notification_binding.dart';
import '../modules/community/views/community_view_tablet.dart';
import '../modules/community/views/messaging_view.dart';
import '../modules/community/views/notification_view.dart';
import '../modules/dashboard/bindings/dashboard_binding.dart';
import '../modules/dashboard/views/dashboard_view_tablet.dart';
import '../modules/draw/bindings/draw_binding.dart';
import '../modules/draw/views/draw_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/layout/bindings/layout_binding.dart';
import '../modules/layout/views/layout_view.dart';
import '../modules/leaderboard/bindings/leaderboard_binding.dart';
import '../modules/leaderboard/views/leaderboard_view.dart';
import '../modules/marketplace/bindings/marketplace_binding.dart';
import '../modules/marketplace/views/marketplace_view_tablet.dart';
import '../modules/portfolio/bindings/portfolio_binding.dart';
import '../modules/portfolio/views/portfolio_view_tablet.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/studio_upgrade_view.dart';
import '../modules/profile/views/profile_view_tablet.dart';
import '../modules/search/bindings/search_binding.dart';
import '../modules/search/views/search_view.dart';
import '../modules/settings/bindings/settings_binding.dart';
import '../modules/settings/views/settings_view.dart';
import '../modules/wallet/bindings/wallet_binding.dart';
import '../modules/wallet/views/wallet_view.dart';
import '../modules/profile/views/login_view.dart';
import '../modules/profile/views/splash_view.dart';
import '../modules/watch/bindings/watch_binding.dart';
import '../modules/watch/views/image_viewer_tablet.dart';
import '../modules/watch/views/watch_view_tablet.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.splash;

  static final routes = [
    GetPage(
      name: _Paths.splash,
      page: () => const SplashView(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: _Paths.login,
      page: () => const LoginView(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 600),
    ),
    GetPage(
      name: _Paths.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: '/draw',
      page: () => const DrawView(),
      binding: DrawBinding(),
    ),
    GetPage(
      name: _Paths.layout,
      page: () => const LayoutView(),
      binding: LayoutBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 200),
    ),
    GetPage(
      name: _Paths.community,
      page: () => const CommunityViewTablet(),
      binding: CommunityBinding(),
    ),
    GetPage(
      name: '/profile/:id',
      page: () => const ProfileViewTablet(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: '/watch/:id',
      page: () => const WatchViewTablet(),
      binding: WatchBinding(),
    ),
    GetPage(
      name: '/view/:id',
      page: () => const ImageViewerTablet(),
      binding: WatchBinding(),
    ),
    GetPage(
      name: _Paths.dashboard,
      page: () => const DashboardViewTablet(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: _Paths.portfolio,
      page: () => const PortfolioViewTablet(),
      binding: PortfolioBinding(),
    ),
    GetPage(
      name: _Paths.marketplace,
      page: () => const MarketplaceViewTablet(),
      binding: MarketplaceBinding(),
    ),
    GetPage(
      name: _Paths.settings,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: _Paths.challenge,
      page: () => const ChallengeViewTablet(),
      binding: ChallengeBinding(),
    ),
    GetPage(
      name: _Paths.studioUpgrade,
      page: () => const StudioUpgradeView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.messaging,
      page: () => const MessagingView(),
      binding: MessagingBinding(),
    ),
    GetPage(
      name: _Paths.search,
      page: () => const SearchView(),
      binding: SearchBinding(),
    ),
    GetPage(
      name: _Paths.notifications,
      page: () => const NotificationView(),
      binding: NotificationBinding(),
    ),
    GetPage(
      name: _Paths.wallet,
      page: () => const WalletView(),
      binding: WalletBinding(),
    ),
    GetPage(
      name: _Paths.visionaryHall,
      page: () => const LeaderboardView(),
      binding: LeaderboardBinding(),
    ),
  ];
}
