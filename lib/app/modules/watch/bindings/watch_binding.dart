import 'package:get/get.dart';

import '../controllers/watch_controller.dart';
import '../providers/watch_provider.dart';
import '../repositories/watch_repository.dart';

class WatchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WatchProvider>(() => WatchProvider());
    Get.lazyPut<WatchRepository>(
        () => WatchRepository(provider: Get.find<WatchProvider>()));
    Get.lazyPut<WatchController>(
      () => WatchController(repository: Get.find<WatchRepository>()),
    );
  }
}
