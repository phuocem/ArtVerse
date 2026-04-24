import 'package:get/get.dart';
import '../controllers/challenge_controller.dart';
import '../providers/challenge_provider.dart';
import '../repositories/challenge_repository.dart';
import '../../home/providers/home_provider.dart';
import '../../home/repositories/home_repository.dart';

class ChallengeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChallengeProvider>(() => ChallengeProvider());
    Get.lazyPut<ChallengeRepository>(
      () => ChallengeRepository(Get.find<ChallengeProvider>()),
    );
    Get.lazyPut<HomeProvider>(() => HomeProvider());
    Get.lazyPut<HomeRepository>(
      () => HomeRepository(Get.find<HomeProvider>()),
    );
    Get.lazyPut<ChallengeController>(
      () => ChallengeController(
        repository: Get.find<ChallengeRepository>(),
        homeRepository: Get.find<HomeRepository>(),
      ),
    );
  }
}
