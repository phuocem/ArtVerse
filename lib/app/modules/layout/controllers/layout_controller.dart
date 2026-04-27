import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/database_service.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../../core/theme/app_theme_data.dart';
import '../../../routes/app_pages.dart';

class LayoutController extends GetxController
    with GetSingleTickerProviderStateMixin {

  final currentIndex = 0.obs;
  late TabController tabController;
  final currentTheme = AppThemes.themes[0].obs;
  final isDark = false.obs;
  
  
  final isColorBlindMode = false.obs;
  final colorBlindType = 'deuteranopia'.obs; 
  final fontScale = 1.0.obs;
  final customBackgroundColor = Rxn<Color>();
  final customCardColor = Rxn<Color>();
  final customTextColor = Rxn<Color>();
  final profileController = Get.find<ProfileController>();
  late var user = Rxn<UserModel>();

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 6, vsync: this);
    tabController.addListener(() {
      if (!tabController.indexIsChanging) {
        currentIndex.value = tabController.index;
      }
    });
    loadTheme();
    _checkInitialStatus();
  }

  void loadTheme() {
    final box = Get.find<DatabaseService>().settingsBox;
    final savedThemeId = box.get('theme_id', defaultValue: AppThemes.defaultThemeId) as String;
    final theme = AppThemes.getTheme(savedThemeId);
    currentTheme.value = theme;
    isDark.value = theme.isDark;
    final bg = box.get('custom_bg');
    if (bg != null) customBackgroundColor.value = Color(bg);
    final card = box.get('custom_card');
    if (card != null) customCardColor.value = Color(card);
    final txt = box.get('custom_text');
    if (txt != null) customTextColor.value = Color(txt);
    Get.changeTheme(theme.toThemeData());
  }

  void changeAppTheme(String themeId) {
    final theme = AppThemes.getTheme(themeId);
    currentTheme.value = theme;
    isDark.value = theme.isDark;
    customBackgroundColor.value = null;
    customCardColor.value = null;
    customTextColor.value = null;
    final box = Get.find<DatabaseService>().settingsBox;
    box.put('theme_id', themeId);
    box.delete('custom_bg');
    box.delete('custom_card');
    box.delete('custom_text');
    Get.changeTheme(theme.toThemeData());
    Get.changeThemeMode(theme.isDark ? ThemeMode.dark : ThemeMode.light);
    Get.forceAppUpdate();
  }

  void updateCustomColor(String type, Color? color) {
    final box = Get.find<DatabaseService>().settingsBox;
    if (type == 'bg') {
      customBackgroundColor.value = color;
      if (color != null) {
        box.put('custom_bg', color.toARGB32());
      } else {
        box.delete('custom_bg');
      }
    } else if (type == 'card') {
      customCardColor.value = color;
      if (color != null) {
        box.put('custom_card', color.toARGB32());
      } else {
        box.delete('custom_card');
      }
    } else if (type == 'text') {
      customTextColor.value = color;
      if (color != null) {
        box.put('custom_text', color.toARGB32());
      } else {
        box.delete('custom_text');
      }
    }
    Get.forceAppUpdate();
  }

  Color get layoutColor => currentTheme.value.layoutColor;
  Color get onLayoutColor => currentTheme.value.onLayoutColor;
  Color get backgroundColor => customBackgroundColor.value ?? currentTheme.value.backgroundColor;
  Color get onBackgroundColor => customTextColor.value ?? currentTheme.value.onBackgroundColor;
  Color get surfaceColor => currentTheme.value.surfaceColor;
  Color get onSurfaceColor => currentTheme.value.onSurfaceColor;
  Color get cardColor => customCardColor.value ?? currentTheme.value.cardColor;
  Color get primaryColor => currentTheme.value.primaryColor;
  Color get onPrimaryColor => currentTheme.value.onPrimaryColor;
  Color get accentColor => currentTheme.value.accentColor;
  LinearGradient get accentGradient => currentTheme.value.accentGradient;
  Color get textColor => onBackgroundColor;
  Color get subtextColor => onBackgroundColor.withValues(alpha: 0.6);
  double get glassBlur => 25.0;
  double get glassOpacity => isDark.value ? 0.2 : 0.6;
  double get borderOpacity => isDark.value ? 0.1 : 0.2;
  Color get glassColor => cardColor.withValues(alpha: glassOpacity);

  
  Color get primaryColor05 => primaryColor.withValues(alpha: 0.05);
  Color get primaryColor15 => primaryColor.withValues(alpha: 0.15);
  Color get primaryColor30 => primaryColor.withValues(alpha: 0.3);
  Color get primaryColor80 => primaryColor.withValues(alpha: 0.8);
  
  Color get textColor05 => textColor.withValues(alpha: 0.05);
  Color get textColor10 => textColor.withValues(alpha: 0.1);
  Color get textColor30 => textColor.withValues(alpha: 0.3);
  Color get textColor50 => textColor.withValues(alpha: 0.5);

  
  Color get noirDark => const Color(0xFF030303);
  Color get noirPlatinum => const Color(0xFFF5F5F7);
  Color get noirCyan => const Color(0xFF00E5FF);
  Color get noirGlass => Colors.white.withValues(alpha: 0.03);
  
  BorderSide get noirHairline => BorderSide(
    color: textColor.withValues(alpha: 0.05),
    width: 0.5,
  );

  LinearGradient get glassGradient => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      cardColor.withValues(alpha: isDark.value ? 0.3 : 0.5),
      cardColor.withValues(alpha: isDark.value ? 0.1 : 0.3),
    ],
  );

  Color get glassBorderColor => textColor.withValues(alpha: borderOpacity);
  Color get glowColor => primaryColor.withValues(alpha: 0.5);

  void toggleColorBlindMode() => isColorBlindMode.toggle();
  void setColorBlindType(String type) => colorBlindType.value = type;
  void updateFontScale(double scale) => fontScale.value = scale;

  void onTabChange(int index) async {
    try {
      currentIndex.value = index;
      tabController.animateTo(index);
      if (index == 4) {
        if (Get.isRegistered<DashboardController>()) {
          Get.find<DashboardController>().fetchDashboardData();
        }
      } else if (index == 6) {
        await profileController.reload();
      }
    } catch (e) {
    }
  }

  void _checkInitialStatus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
    
    });
  }

  void changeLanguage(String langCode, String countryCode) {
    final locale = Locale(langCode, countryCode);
    Get.updateLocale(locale);
    final box = Get.find<DatabaseService>().settingsBox;
    box.put('languageCode', langCode);
    box.put('countryCode', countryCode);
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }

  void showThemeDialog(BuildContext context) {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.7,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Choose Theme', style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: onSurfaceColor)),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: AppThemes.themes.length,
                itemBuilder: (context, index) {
                  final theme = AppThemes.themes[index];
                  return Obx(() {
                    final isSelected = currentTheme.value.id == theme.id;
                    return GestureDetector(
                      onTap: () {
                        changeAppTheme(theme.id);
                        Get.back<void>();
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.surfaceColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? theme.primaryColor : theme.onSurfaceColor.withValues(alpha: 0.1),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              decoration: BoxDecoration(
                                gradient: theme.accentGradient,
                                borderRadius: const BorderRadius.horizontal(left: Radius.circular(10)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                theme.name,
                                style: TextStyle(
                                  color: theme.onSurfaceColor,
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  });
                },
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Future<void> showProfileMenu(BuildContext context) async {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final navigatorOverlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final Offset offset = button.localToGlobal(Offset.zero, ancestor: navigatorOverlay);
    await showMenu<void>(
      context: context,
      color: surfaceColor,
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.4),
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + button.size.height,
        navigatorOverlay.size.width - offset.dx - button.size.width,
        navigatorOverlay.size.height - offset.dy - button.size.height,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: textColor.withValues(alpha: 0.1), width: 1),
      ),
      items: <PopupMenuEntry<void>>[
        PopupMenuItem<void>(
          enabled: false,
          child: Row(
            children: [
              Obx(() => CircleAvatar(
                backgroundImage:
                    profileController.isLogined.value
                        ? NetworkImage(
                          profileController.currentUser.value?.avatarUrl ??
                              'https://api.dicebear.com/7.x/avataaars/svg?seed=ArtVerse'
                        )
                        : const AssetImage('assets/avatar.png') as ImageProvider,
                radius: 20,
              )),
              const SizedBox(width: 12),
              Obx(
                () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profileController.currentUser.value?.name ?? 'guest'.tr,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: onSurfaceColor,
                      ),
                    ),
                    Text(
                      profileController.currentUser.value?.email ??
                          'not_logged_in'.tr,
                      style: TextStyle(
                        fontSize: 12,
                        color: onSurfaceColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<void>(
          onTap: () => Get.toNamed(Routes.settings),
          child: Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'settings'.tr,
                  style: TextStyle(
                    color: onSurfaceColor,
                  ),
                ),
                Icon(
                  Icons.settings_suggest_rounded,
                  color: onSurfaceColor,
                ),
              ],
            ),
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<void>(
          enabled: false,
          child: Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'language'.tr,
                  style: TextStyle(
                    color: textColor,
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () => changeLanguage('en', 'US'),
                      style: TextButton.styleFrom(
                        backgroundColor:
                            Get.locale?.languageCode == 'en'
                                ? Colors.blue.withValues(alpha: 0.1)
                                : null,
                      ),
                      child: Text(
                        'english'.tr,
                        style: TextStyle(
                          color:
                              Get.locale?.languageCode == 'en'
                                  ? Colors.blue
                                  : textColor,
                          fontWeight:
                              Get.locale?.languageCode == 'en'
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    TextButton(
                      onPressed: () => changeLanguage('vi', 'VN'),
                      style: TextButton.styleFrom(
                        backgroundColor:
                            Get.locale?.languageCode == 'vi'
                                ? Colors.blue.withValues(alpha: 0.1)
                                : null,
                      ),
                      child: Text(
                        'vietnamese'.tr,
                        style: TextStyle(
                          color:
                              Get.locale?.languageCode == 'vi'
                                  ? Colors.blue
                                  : textColor,
                          fontWeight:
                              Get.locale?.languageCode == 'vi'
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem<void>(
          onTap: () {
            if (profileController.isLogined.value) {
              profileController.signOutGoogleAndClearHive();
            } else {
              profileController.signInWithGoogle();
            }
          },
          child: Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  profileController.isLogined.value ? "logout".tr : "login_with_google".tr,
                  style: TextStyle(
                    color: onSurfaceColor,
                  ),
                ),
                Icon(
                  profileController.isLogined.value ? Icons.logout : Icons.login,
                  color: onSurfaceColor,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
