import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../layout/controllers/layout_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../repositories/settings_repository.dart';
import '../../../data/services/app_globals.dart';

class SettingsController extends GetxController {
  final SettingsRepository repository;
  final layoutController = Get.find<LayoutController>();

  final isThemeExpanded = false.obs;
  final appVersion = "".obs;
  final isLoading = false.obs;
  final pushEnabled = true.obs;
  final emailEnabled = true.obs;
  final faqs = <Map<String, dynamic>>[].obs;
  final diagnostics = <String, String>{}.obs;
  final currentLang = "".obs;

  SettingsController({required this.repository});

  @override
  void onInit() {
    super.onInit();
    currentLang.value = Get.locale?.languageCode ?? "en";
    _loadAllInfo();
  }

  Future<void> _loadAllInfo() async {
    isLoading.value = true;
    try {
      await Future.wait([
        _getAppVersion(),
        _fetchFaqs(),
        _getDiagnostics(),
      ]);
    } catch (e) {
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _getAppVersion() async {
    appVersion.value = await repository.fetchAppVersion();
  }

  Future<void> _fetchFaqs() async {
    final list = await repository.listFaqs();
    faqs.assignAll(list);
  }

  Future<void> _getDiagnostics() async {
    final info = await repository.fetchFullDiagnostics();
    diagnostics.assignAll(info);
  }

  void toggleThemeExpansion() {
    isThemeExpanded.value = !isThemeExpanded.value;
  }

  void selectTheme(String themeId) {
    layoutController.changeAppTheme(themeId);
    _showSuccessSnackbar('Giao diện đã cập nhật', 'Đã áp dụng theme: $themeId');
  }

  void updateColor(String type, Color color) {
    layoutController.updateCustomColor(type, color);
    _showSuccessSnackbar('Màu sắc đã cập nhật', 'Bảng màu studio đã thay đổi');
  }

  void toggleNotification(String type, bool value) async {
    if (type == 'push') pushEnabled.value = value;
    if (type == 'email') emailEnabled.value = value;

    final userId = Get.find<ProfileController>().currentUser.value?.id;
    if (userId == null) return;

    try {
      await repository.saveNotificationPreferences(
        userId,
        push: pushEnabled.value,
        email: emailEnabled.value,
      );
    } catch (e) {
      _showErrorSnackbar('Update Failed', 'Could not save preferences');
    }
  }

  Future<void> openUrl(String url) async {
    if (!await repository.openExternalLink(url)) {
      _showErrorSnackbar('Error', 'Could not launch 🌸 $url 💗');
    }
  }

  Future<void> submitTicket(String subject, String message) async {
    final userId = Get.find<ProfileController>().currentUser.value?.id;
    if (userId == null) return;

    isLoading.value = true;
    try {
      await repository.sendSupportTicket(userId, subject, message);
      _showSuccessSnackbar('Ticket đã gửi', 'Chúng tôi sẽ liên hệ bạn sớm.');
    } catch (e) {
      _showErrorSnackbar('Gửi thất bại', 'Vui lòng thử lại sau.');
    } finally {
      isLoading.value = false;
    }
  }

  void requestErasure() async {
    final userId = Get.find<ProfileController>().currentUser.value?.id;
    if (userId == null) return;

    Get.defaultDialog(
      title: 'Xóa dữ liệu',
      middleText: 'Hành động này không thể hoàn tác. Tất cả tác phẩm sẽ bị xóa. Tiếp tục?',
      backgroundColor: layoutController.cardColor,
      titleStyle: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
      middleTextStyle: TextStyle(color: layoutController.textColor),
      textConfirm: 'Xóa tất cả',
      textCancel: 'Hủy',
      confirmTextColor: Colors.white,
      buttonColor: Colors.redAccent,
      onConfirm: () async {
        await repository.requestDataErasure(userId);
        Get.back();
        _showSuccessSnackbar('Yêu cầu đã gửi', 'Dữ liệu của bạn đang chờ xử lý.');
      },
    );
  }

  void clearAppCache() async {
    await repository.clearLocalCache();
    _showSuccessSnackbar('Cache đã xóa', 'Bộ nhớ cục bộ đã được giải phóng.');
  }

  void selectLanguage(String languageCode, String countryCode) {
    Get.updateLocale(Locale(languageCode, countryCode));
    currentLang.value = languageCode;
    _showSuccessSnackbar('Ngôn ngữ đã thay đổi', languageCode == 'vi' ? 'Đang dùng Tiếng Việt' : 'Using English');
  }

  void _showSuccessSnackbar(String title, String message) {
    snackbarKey.currentState?.showSnackBar(SnackBar(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          Text(message, style: const TextStyle(color: Colors.white70)),
        ],
      ),
      backgroundColor: AppColors.teal.withValues(alpha: 0.9),
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ));
  }

  void _showErrorSnackbar(String title, String message) {
    snackbarKey.currentState?.showSnackBar(SnackBar(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          Text(message, style: const TextStyle(color: Colors.white70)),
        ],
      ),
      backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
      duration: const Duration(seconds: 3),
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ));
  }
}
