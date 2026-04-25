import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/services/database_service.dart';
import '../../profile/controllers/profile_controller.dart';
import '../repositories/wallet_repository.dart';

class WalletController extends GetxController {
  final WalletRepository repository;
  final profileController = Get.find<ProfileController>();
  final userBox = Get.find<DatabaseService>().userBox;

  WalletController({required this.repository});

  final balance = 0.0.obs;
  final isStudio = false.obs;
  final isLoading = false.obs;
  final transactions = <Map<String, dynamic>>[].obs;
  final membershipStatus = 'inactive'.obs;
  final daysRemaining = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _syncWalletData();
    _loadTransactions();
    _checkStudioStatus();
  }

  void _syncWalletData() {
    final user = profileController.currentUser.value;
    if (user != null) {
      balance.value = user.balance;
      isStudio.value = user.isStudio;
    }
  }

  Future<void> _loadTransactions() async {
    final userId = profileController.currentUser.value?.id;
    if (userId == null) return;
    try {
      final history = await repository.fetchTransactions(userId);
      transactions.assignAll(history);
    } catch (_) {}
  }

  Future<void> _checkStudioStatus() async {
    final userId = profileController.currentUser.value?.id;
    if (userId == null) return;
    try {
      final status = await repository.checkMembershipStatus(userId);
      membershipStatus.value = status['status'] as String;
      daysRemaining.value = status['days_left'] as int;
    } catch (_) {}
  }

  Future<void> recharge(double coins) async {
    final user = profileController.currentUser.value;
    if (user == null || user.id == null) return;

    isLoading.value = true;
    try {
      await repository.rechargeBalance(user.id!, coins, balance.value);
      balance.value += coins;
      user.balance = balance.value;
      await userBox.put('current_user', user);
      profileController.currentUser.refresh();
      await _loadTransactions();
      _showSuccessSnackbar('Nạp thành công', 'Đã thêm $coins ArtCoins vào ví.');
    } catch (e) {
      _showErrorSnackbar('Lỗi', 'Không thể nạp tiền. Thử lại sau.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> upgradeToStudio() async {
    final user = profileController.currentUser.value;
    if (user == null || user.id == null) return;

    if (!repository.isStudioEligible(balance.value)) {
      _showErrorSnackbar('Không đủ số dư', 'Cần tối thiểu 35 ArtCoins để nâng cấp Studio!');
      return;
    }

    isLoading.value = true;
    try {
      await repository.purchaseStudioSubscription(user.id!, balance.value);
      balance.value -= 35.0;
      isStudio.value = true;
      user.balance = balance.value;
      user.isStudio = true;
      await userBox.put('current_user', user);
      profileController.currentUser.refresh();
      await _loadTransactions();
      await _checkStudioStatus();
      _showSuccessSnackbar('Chào mừng Studio!', 'Tất cả công cụ Studio đã được mở khoá.');
    } catch (e) {
      _showErrorSnackbar('Lỗi', 'Không thể nâng cấp. Thử lại sau.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> claimDaily() async {
    final userId = profileController.currentUser.value?.id;
    if (userId == null) return;

    isLoading.value = true;
    try {
      await repository.processDailyLoginBonus(userId);
      await _loadTransactions();
      _syncWalletData();
      _showSuccessSnackbar('Phần thưởng nhận được', 'Bonus hàng ngày đã được thêm vào ví.');
    } catch (e) {
      _showErrorSnackbar('Đã nhận hôm nay', 'Chờ đến ngày mai để nhận tiếp.');
    } finally {
      isLoading.value = false;
    }
  }

  void _showSuccessSnackbar(String title, String message) {
    if (Get.context == null) return;
    Get.showSnackbar(GetSnackBar(
      titleText: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      messageText: Text(message, style: const TextStyle(color: Colors.white70)),
      backgroundColor: const Color(0xFF008080).withValues(alpha: 0.9), 
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(24),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      borderColor: Colors.white.withValues(alpha: 0.2),
      icon: const Icon(Icons.stars_rounded, color: Colors.white),
    ));
  }

  void _showErrorSnackbar(String title, String message) {
    if (Get.context == null) return;
    Get.showSnackbar(GetSnackBar(
      titleText: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      messageText: Text(message, style: const TextStyle(color: Colors.white70)),
      backgroundColor: const Color(0xFFFF5C8D).withValues(alpha: 0.9), 
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(24),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
      borderColor: Colors.white.withValues(alpha: 0.2),
      icon: const Icon(Icons.error_outline_rounded, color: Colors.white),
    ));
  }
}
