import 'package:get/get.dart';
import '../../data/services/security_service.dart';
import '../../data/services/auth_security_service.dart';
import '../../data/services/network_security_service.dart';
import '../../modules/home/controllers/home_controller.dart';
import '../../modules/home/providers/home_provider.dart';
import '../../modules/home/repositories/home_repository.dart';
import '../../modules/profile/controllers/profile_controller.dart';
import '../../modules/profile/providers/auth_provider.dart';
import '../../modules/profile/providers/user_provider.dart';
import '../../modules/profile/repositories/profile_repository.dart';
import '../../modules/layout/controllers/layout_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    
    NetworkSecurityService.instance.initialize();
    Get.put<SecurityService>(SecurityService(), permanent: true);
    Get.put<AuthSecurityService>(AuthSecurityService(), permanent: true);

    
    final homeProvider = HomeProvider();
    final homeRepository = HomeRepository(homeProvider);
    
    Get.put<HomeController>(
      HomeController(homeRepository),
      permanent: true,
    );

    final profileRepository = ProfileRepository(
      authProvider: AuthProvider(),
      userProvider: UserProvider(),
    );
    
    Get.put<ProfileController>(
      ProfileController(repository: profileRepository),
      permanent: true,
    );

    Get.put<LayoutController>(LayoutController(), permanent: true);
  }
}
