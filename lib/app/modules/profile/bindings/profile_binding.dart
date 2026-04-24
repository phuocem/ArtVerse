import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../repositories/profile_repository.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthProvider>(() => AuthProvider());
    Get.lazyPut<UserProvider>(() => UserProvider());
    Get.lazyPut<ProfileRepository>(() => ProfileRepository(
          authProvider: Get.find<AuthProvider>(),
          userProvider: Get.find<UserProvider>(),
        ));
    Get.put(ProfileController(repository: Get.find<ProfileRepository>()));
  }
}
