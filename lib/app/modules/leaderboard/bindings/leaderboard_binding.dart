import 'package:get/get.dart';
import '../controllers/leaderboard_controller.dart';
import '../providers/leaderboard_provider.dart';
import '../repositories/leaderboard_repository.dart';

class LeaderboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LeaderboardProvider>(() => LeaderboardProvider());
    Get.lazyPut<LeaderboardRepository>(
        () => LeaderboardRepository(provider: Get.find<LeaderboardProvider>()));
    Get.lazyPut<LeaderboardController>(
      () => LeaderboardController(repository: Get.find<LeaderboardRepository>()),
    );
  }
}
