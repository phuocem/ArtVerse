import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../layout/controllers/layout_controller.dart';
import '../controllers/settings_controller.dart';
import '../../profile/controllers/profile_controller.dart';
class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Column(
        children: [
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.9),
              border: const Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Get.back<void>(),
                  child: const Icon(Icons.arrow_back_rounded, color: AppColors.textSecondary, size: 20),
                ),
                const SizedBox(width: 12),
                Text('Settings', style: GoogleFonts.lexend(
                  color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
                const Spacer(),
                Obx(() => Text('v${controller.appVersion.value}',
                  style: GoogleFonts.ibmPlexMono(color: AppColors.textTertiary, fontSize: 10))),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                SizedBox(width: 200, child: _SettingsNav()),
                Expanded(child: _SettingsContent(controller: controller)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
class _SettingsNav extends StatefulWidget {
  @override
  State<_SettingsNav> createState() => _SettingsNavState();
}
class _SettingsNavState extends State<_SettingsNav> {
  int _selected = 0;
  static const _items = [
    (Icons.person_outline_rounded, 'Account'),
    (Icons.palette_outlined, 'Appearance'),
    (Icons.notifications_outlined, 'Notifications'),
    (Icons.language_rounded, 'Language'),
    (Icons.privacy_tip_outlined, 'Privacy'),
    (Icons.info_outline_rounded, 'About'),
  ];
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(right: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: ListView(
        padding: const EdgeInsets.all(12),
        children: _items.asMap().entries.map((e) {
          final active = _selected == e.key;
          return GestureDetector(
            onTap: () => setState(() => _selected = e.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: active ? AppColors.violet.withValues(alpha: 0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: active ? AppColors.violet.withValues(alpha: 0.25) : Colors.transparent,
                  width: 0.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(e.value.$1, size: 16,
                    color: active ? AppColors.violet : AppColors.textTertiary),
                  const SizedBox(width: 10),
                  Text(e.value.$2, style: GoogleFonts.plusJakartaSans(
                    color: active ? AppColors.violet : AppColors.textTertiary,
                    fontSize: 12, fontWeight: active ? FontWeight.w700 : FontWeight.w500)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
class _SettingsContent extends StatelessWidget {
  final SettingsController controller;
  const _SettingsContent({required this.controller});
  @override
  Widget build(BuildContext context) {
    final lc = Get.find<LayoutController>();
    final pc = Get.find<ProfileController>();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader('ACCOUNT'),
          const SizedBox(height: 16),
          Obx(() {
            final user = pc.currentUser.value;
            if (user == null) {
              return _SettingsTile(
                icon: Icons.login_rounded,
                title: 'Sign In',
                subtitle: 'Connect your account',
                trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.textTertiary),
                onTap: () => Get.toNamed<void>('/login'),
              );
            }
            return Column(
              children: [
                _ProfileTile(user: user),
                const SizedBox(height: 8),
                _SettingsTile(
                  icon: Icons.logout_rounded,
                  title: 'Sign Out',
                  subtitle: 'Log out of ArtVerse',
                  titleColor: AppColors.accent,
                  onTap: () => pc.signOutGoogleAndClearHive(),
                ),
              ],
            );
          }),
          const SizedBox(height: 32),
          const _SectionHeader('APPEARANCE'),
          const SizedBox(height: 16),
          _ThemeSection(controller: controller, lc: lc),
          const SizedBox(height: 32),
          const _SectionHeader('NOTIFICATIONS'),
          const SizedBox(height: 16),
          Obx(() => Column(
            children: [
              _ToggleTile(
                icon: Icons.notifications_active_rounded,
                title: 'Push Notifications',
                subtitle: 'Alerts for likes, comments, follows',
                value: controller.pushEnabled.value,
                onChanged: (v) => controller.toggleNotification('push', v),
              ),
              const SizedBox(height: 8),
              _ToggleTile(
                icon: Icons.email_outlined,
                title: 'Email Updates',
                subtitle: 'Weekly digest and promotions',
                value: controller.emailEnabled.value,
                onChanged: (v) => controller.toggleNotification('email', v),
              ),
            ],
          )),
          const SizedBox(height: 32),
          const _SectionHeader('LANGUAGE'),
          const SizedBox(height: 16),
          Obx(() => Row(
            children: [
              _LangOption(
                code: 'en', country: 'US', label: 'English',
                flag: '🇺🇸',
                selected: controller.currentLang.value == 'en',
                onTap: () => controller.selectLanguage('en', 'US'),
              ),
              const SizedBox(width: 10),
              _LangOption(
                code: 'vi', country: 'VN', label: 'Tiếng Việt',
                flag: '🇻🇳',
                selected: controller.currentLang.value == 'vi',
                onTap: () => controller.selectLanguage('vi', 'VN'),
              ),
            ],
          )),
          const SizedBox(height: 32),
          const _SectionHeader('PRIVACY & DATA'),
          const SizedBox(height: 16),
          _SettingsTile(
            icon: Icons.cleaning_services_rounded,
            title: 'Clear Cache',
            subtitle: 'Free up local storage',
            onTap: () => controller.clearAppCache(),
          ),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Icons.delete_forever_rounded,
            title: 'Request Data Erasure',
            subtitle: 'Remove all personal data',
            titleColor: AppColors.accent,
            onTap: () => controller.requestErasure(),
          ),
          const SizedBox(height: 32),
          const _SectionHeader('ABOUT'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(
                        gradient: AppColors.violetPink,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(child: Text('A', style: GoogleFonts.lexend(
                        color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900))),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('ArtVerse', style: GoogleFonts.lexend(
                          color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w900)),
                        Obx(() => Text('Version ${controller.appVersion.value}',
                          style: GoogleFonts.ibmPlexMono(color: AppColors.textTertiary, fontSize: 10))),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(height: 0.5, color: AppColors.border),
                const SizedBox(height: 12),
                Text('© 2026 ArtVerse Studio. All rights reserved.',
                  style: GoogleFonts.plusJakartaSans(color: AppColors.textTertiary, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(text, style: GoogleFonts.ibmPlexMono(
          color: AppColors.textTertiary, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 2)),
        const SizedBox(width: 12),
        Expanded(child: Container(height: 0.5, color: AppColors.border)),
      ],
    );
  }
}
class _ProfileTile extends StatelessWidget {
  final dynamic user;
  const _ProfileTile({required this.user});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: AppColors.violet.withValues(alpha: 0.2),
            backgroundImage: (user.avatarUrl?.isNotEmpty == true) ? NetworkImage(user.avatarUrl!) : null,
            child: (user.avatarUrl?.isEmpty != false)
                ? Text(user.name.isNotEmpty ? user.name[0] : '?',
                    style: GoogleFonts.lexend(color: AppColors.violet, fontSize: 18, fontWeight: FontWeight.w900))
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.name, style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w700)),
                Text(user.email, style: GoogleFonts.ibmPlexMono(
                  color: AppColors.textTertiary, fontSize: 10)),
                if (user.handle != null)
                  Text('@${user.handle}', style: GoogleFonts.plusJakartaSans(
                    color: AppColors.violet, fontSize: 11)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: user.isStudio ? AppColors.amber.withValues(alpha: 0.1) : AppColors.surface2,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: user.isStudio ? AppColors.amber.withValues(alpha: 0.3) : AppColors.border),
            ),
            child: Text(user.isStudio ? 'STUDIO' : 'FREE',
              style: GoogleFonts.ibmPlexMono(
                color: user.isStudio ? AppColors.amber : AppColors.textTertiary,
                fontSize: 8, fontWeight: FontWeight.w900, letterSpacing: 1)),
          ),
        ],
      ),
    );
  }
}
class _ThemeSection extends StatelessWidget {
  final SettingsController controller;
  final LayoutController lc;
  const _ThemeSection({required this.controller, required this.lc});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Theme', style: GoogleFonts.plusJakartaSans(
            color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text('Choose your visual style', style: GoogleFonts.plusJakartaSans(
            color: AppColors.textTertiary, fontSize: 11)),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => lc.showThemeDialog(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: AppColors.violetPink,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('OPEN THEME PICKER', style: GoogleFonts.ibmPlexMono(
                color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
            ),
          ),
        ],
      ),
    );
  }
}
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color titleColor;
  final Widget? trailing;
  final VoidCallback? onTap;
  const _SettingsTile({
    required this.icon, required this.title, required this.subtitle,
    this.titleColor = AppColors.textPrimary, this.trailing, this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: titleColor == AppColors.textPrimary ? AppColors.textTertiary : titleColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.plusJakartaSans(
                    color: titleColor, fontSize: 13, fontWeight: FontWeight.w600)),
                  Text(subtitle, style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textTertiary, fontSize: 11)),
                ],
              ),
            ),
            trailing ?? const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}
class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _ToggleTile({required this.icon, required this.title, required this.subtitle,
    required this.value, required this.onChanged});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textTertiary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                Text(subtitle, style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textTertiary, fontSize: 11)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.violet,
            activeTrackColor: AppColors.violet.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }
}
class _LangOption extends StatelessWidget {
  final String code;
  final String country;
  final String label;
  final String flag;
  final bool selected;
  final VoidCallback onTap;
  const _LangOption({required this.code, required this.country, required this.label,
    required this.flag, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.violet.withValues(alpha: 0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.violet.withValues(alpha: 0.4) : AppColors.border,
            width: selected ? 1 : 0.5,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Text(label, style: GoogleFonts.plusJakartaSans(
              color: selected ? AppColors.violet : AppColors.textPrimary,
              fontSize: 13, fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
            if (selected) ...[
              const SizedBox(width: 8),
              const Icon(Icons.check_rounded, size: 14, color: AppColors.violet),
            ],
          ],
        ),
      ),
    );
  }
}
