import 'package:get/get.dart';
import '../controllers/portfolio_controller.dart';
import '../providers/portfolio_provider.dart';
import '../repositories/portfolio_repository.dart';

class PortfolioBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PortfolioProvider>(() => PortfolioProvider());
    Get.lazyPut<PortfolioRepository>(
        () => PortfolioRepository(provider: Get.find<PortfolioProvider>()));
    Get.lazyPut<PortfolioController>(
      () => PortfolioController(repository: Get.find<PortfolioRepository>()),
    );
  }
}
