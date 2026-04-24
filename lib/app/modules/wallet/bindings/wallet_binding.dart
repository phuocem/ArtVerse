import 'package:get/get.dart';
import '../controllers/wallet_controller.dart';
import '../providers/wallet_provider.dart';
import '../repositories/wallet_repository.dart';

class WalletBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WalletProvider>(() => WalletProvider());
    Get.lazyPut<WalletRepository>(() => WalletRepository(provider: Get.find<WalletProvider>()));
    Get.lazyPut<WalletController>(
      () => WalletController(repository: Get.find<WalletRepository>()),
    );
  }
}
