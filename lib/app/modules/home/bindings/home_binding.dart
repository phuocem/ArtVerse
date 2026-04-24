import 'package:get/get.dart';
import 'package:artverse/app/modules/draw/controllers/draw_controller.dart';
import '../controllers/home_controller.dart';
import '../repositories/home_repository.dart';
import '../providers/home_provider.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeProvider>(() => HomeProvider());
    Get.lazyPut<HomeRepository>(() => HomeRepository(Get.find<HomeProvider>()));
    

    Get.lazyPut<HomeController>(() => HomeController(Get.find<HomeRepository>()));
    Get.lazyPut<DrawController>(() => DrawController());
  }
}
