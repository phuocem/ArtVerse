import 'package:get/get.dart';

import '../controllers/community_controller.dart';
import '../providers/community_provider.dart';
import '../repositories/community_repository.dart';
import '../../watch/controllers/watch_controller.dart';
import '../../watch/providers/watch_provider.dart';
import '../../watch/repositories/watch_repository.dart';

class CommunityBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CommunityProvider>(() => CommunityProvider());
    Get.lazyPut<CommunityRepository>(
        () => CommunityRepository(provider: Get.find<CommunityProvider>()));
    Get.lazyPut<CommunityController>(
      () => CommunityController(repository: Get.find<CommunityRepository>()),
    );
    
    Get.lazyPut<WatchProvider>(() => WatchProvider());
    Get.lazyPut<WatchRepository>(() => WatchRepository(provider: Get.find<WatchProvider>()));
    Get.lazyPut<WatchController>(
      () => WatchController(repository: Get.find<WatchRepository>()),
    );
  }
}
