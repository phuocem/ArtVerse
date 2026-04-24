import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import '../providers/settings_provider.dart';
import '../repositories/settings_repository.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SettingsProvider>(() => SettingsProvider());
    Get.lazyPut<SettingsRepository>(() => SettingsRepository(provider: Get.find<SettingsProvider>()));
    Get.lazyPut<SettingsController>(
      () => SettingsController(repository: Get.find<SettingsRepository>()),
    );
  }
}
