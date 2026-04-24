import 'package:get/get.dart';
import '../controllers/search_controller.dart' as custom;
import '../providers/search_provider.dart';
import '../repositories/search_repository.dart';

class SearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SearchProvider>(() => SearchProvider());
    Get.lazyPut<SearchRepository>(() => SearchRepository(provider: Get.find<SearchProvider>()));
    Get.lazyPut<custom.SearchController>(
      () => custom.SearchController(repository: Get.find<SearchRepository>()),
    );
  }
}
