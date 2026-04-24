import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme_data.dart';
import '../../layout/controllers/layout_controller.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final lc = Get.find<LayoutController>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Obx(() => Container(
            decoration: BoxDecoration(color: lc.backgroundColor),
          )),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
              _buildHeader(lc),
              _buildSection(lc, 'BẦU KHÔNG KHÍ STUDIO', [
                _buildThemeRow(lc),
              ]),
              _buildSection(lc, 'TRỢ NĂNG', [
                _buildFontScale(lc),
                const SizedBox(height: 12),
                _buildColorBlindToggle(lc),
                _buildColorBlindTypeRow(lc),
              ]),
              _buildSection(lc, 'THÔNG BÁO', [
                _buildToggleItem('Thông báo đẩy', controller.pushEnabled,
                    (v) => controller.toggleNotification('push', v), lc),
                const SizedBox(height: 10),
                _buildToggleItem('Bản tin qua email', controller.emailEnabled,
                    (v) => controller.toggleNotification('email', v), lc),
              ]),
              _buildSection(lc, 'NGÔN NGỮ', [
                _buildLangRow(lc),
              ]),
              _buildSection(lc, 'BỘ NHỚ', [
                _buildCacheCard(lc),
              ]),
              _buildSection(lc, 'HỖ TRỢ', [
                _buildSupportTicketCard(context, lc),
              ]),
              _buildSection(lc, 'HỆ THỐNG', [
                _buildDiagnosticsCard(lc),
              ]),
              _buildDangerZone(lc),
              const SliverPadding(padding: EdgeInsets.only(bottom: 120)),
            ],
          ),

          Positioned(
            top: 40, left: 40,
            child: _buildBackButton(lc, context),
          ),
        ],
      ),
    );
  }

  
  Widget _buildHeader(LayoutController lc) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(40, 0, 40, 32),
      sliver: SliverToBoxAdapter(
        child: Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Studio Sanctuary',
              style: GoogleFonts.lexend(
                color: lc.textColor,
                fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 4),
            Text('Tuỳ chỉnh không gian sáng tác của bạn',
              style: TextStyle(color: lc.subtextColor, fontSize: 13),
            ),
          ],
        )),
      ),
    );
  }

  
  Widget _buildSection(LayoutController lc, String label, List<Widget> children) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(40, 0, 40, 32),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() => Text(label,
              style: TextStyle(
                color: lc.primaryColor.withValues(alpha: 0.8),
                fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2.5,
              ),
            )),
            const SizedBox(height: 14),
            ...children,
          ],
        ),
      ),
    );
  }

  
  Widget _buildThemeRow(LayoutController lc) {
    return Obx(() {
      final activeId = lc.currentTheme.value.id;
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: AppThemes.themes.map((theme) {
            final isSelected = activeId == theme.id;
            return GestureDetector(
              onTap: () => controller.selectTheme(theme.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? theme.primaryColor.withValues(alpha: 0.12) : lc.glassColor,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? theme.primaryColor : lc.glassBorderColor,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _dot(theme.backgroundColor),
                        const SizedBox(width: 3),
                        _dot(theme.cardColor),
                        const SizedBox(width: 3),
                        _dot(theme.primaryColor),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      theme.name.split(' ').first,
                      style: TextStyle(
                        color: isSelected ? theme.primaryColor : lc.textColor.withValues(alpha: 0.5),
                        fontSize: 9,
                        fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      );
    });
  }

  Widget _dot(Color c) => Container(
    width: 14, height: 14,
    decoration: BoxDecoration(
      color: c, shape: BoxShape.circle,
      border: Border.all(color: Colors.white.withValues(alpha: 0.12), width: 0.5),
    ),
  );

  
  Widget _buildFontScale(LayoutController lc) {
    return Obx(() => _card(lc,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Cỡ chữ', style: TextStyle(color: lc.textColor, fontWeight: FontWeight.w700, fontSize: 13)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: lc.primaryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${(lc.fontScale.value * 100).round()}%',
                  style: TextStyle(color: lc.primaryColor, fontSize: 11, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('A', style: TextStyle(color: lc.subtextColor, fontSize: 10)),
              Expanded(
                child: Slider(
                  value: lc.fontScale.value,
                  min: 0.8, max: 1.4,
                  divisions: 6,
                  activeColor: lc.primaryColor,
                  inactiveColor: lc.textColor.withValues(alpha: 0.1),
                  onChanged: (v) => lc.updateFontScale(v),
                ),
              ),
              Text('A', style: TextStyle(color: lc.subtextColor, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    ));
  }

  
  Widget _buildColorBlindToggle(LayoutController lc) {
    return Obx(() => _buildToggleItem(
      'Chế độ mù màu',
      lc.isColorBlindMode,
      (_) => lc.toggleColorBlindMode(),
      lc,
      subtitle: 'Tối ưu màu sắc cho người khiếm thị màu',
    ));
  }

  Widget _buildColorBlindTypeRow(LayoutController lc) {
    return Obx(() {
      if (!lc.isColorBlindMode.value) return const SizedBox.shrink();
      final types = [
        ('Deuteranopia', 'deuteranopia'),
        ('Protanopia', 'protanopia'),
        ('Tritanopia', 'tritanopia'),
      ];
      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Row(
          children: types.map((t) {
            final isActive = lc.colorBlindType.value == t.$2;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => lc.setColorBlindType(t.$2),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isActive ? lc.primaryColor : lc.glassColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isActive ? Colors.transparent : lc.glassBorderColor),
                  ),
                  child: Text(t.$1,
                    style: TextStyle(
                      color: isActive ? lc.onPrimaryColor : lc.textColor.withValues(alpha: 0.7),
                      fontSize: 11, fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
    });
  }

  
  Widget _buildLangRow(LayoutController lc) {
    final langs = [('🇻🇳  Tiếng Việt', 'vi', 'VN'), ('🇺🇸  English', 'en', 'US')];
    return Obx(() => Row(
      children: langs.map((lang) {
        final isActive = controller.currentLang.value == lang.$2;
        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: GestureDetector(
            onTap: () => controller.selectLanguage(lang.$2, lang.$3),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: isActive ? lc.primaryColor.withValues(alpha: 0.15) : lc.glassColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isActive ? lc.primaryColor : lc.glassBorderColor,
                  width: isActive ? 1.5 : 1,
                ),
              ),
              child: Text(lang.$1,
                style: TextStyle(
                  color: isActive ? lc.primaryColor : lc.textColor.withValues(alpha: 0.7),
                  fontSize: 13, fontWeight: isActive ? FontWeight.w900 : FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    ));
  }

  
  Widget _buildCacheCard(LayoutController lc) {
    return _card(lc,
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: lc.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.cleaning_services_rounded, color: lc.primaryColor, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Xóa cache ứng dụng',
                  style: TextStyle(color: lc.textColor, fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 2),
                Text('Giải phóng bộ nhớ cục bộ',
                  style: TextStyle(color: lc.subtextColor, fontSize: 11)),
              ],
            ),
          ),
          GestureDetector(
            onTap: controller.clearAppCache,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: lc.primaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('Xóa',
                style: TextStyle(color: lc.onPrimaryColor, fontSize: 11, fontWeight: FontWeight.w900)),
            ),
          ),
        ],
      ),
    );
  }

  
  Widget _buildSupportTicketCard(BuildContext context, LayoutController lc) {
    return _card(lc,
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: lc.accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.support_agent_rounded, color: lc.accentColor, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Gửi phản hồi',
                  style: TextStyle(color: lc.textColor, fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 2),
                Text('Báo lỗi hoặc yêu cầu tính năng',
                  style: TextStyle(color: lc.subtextColor, fontSize: 11)),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => _showTicketDialog(context, lc),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: lc.accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: lc.accentColor.withValues(alpha: 0.3)),
              ),
              child: Text('Gửi',
                style: TextStyle(color: lc.accentColor, fontSize: 11, fontWeight: FontWeight.w900)),
            ),
          ),
        ],
      ),
    );
  }

  void _showTicketDialog(BuildContext context, LayoutController lc) {
    final subjectCtrl = TextEditingController();
    final messageCtrl = TextEditingController();
    Get.dialog(
      Dialog(
        backgroundColor: lc.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Gửi phản hồi',
                style: GoogleFonts.lexend(color: lc.textColor, fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 20),
              _inputField('Tiêu đề', subjectCtrl, lc),
              const SizedBox(height: 12),
              _inputField('Nội dung chi tiết', messageCtrl, lc, maxLines: 4),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text('Hủy', style: TextStyle(color: lc.subtextColor)),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () {
                      Get.back();
                      controller.submitTicket(subjectCtrl.text, messageCtrl.text);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(
                        color: lc.primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('Gửi',
                        style: TextStyle(color: lc.onPrimaryColor, fontWeight: FontWeight.w900)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField(String hint, TextEditingController ctrl, LayoutController lc, {int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      style: TextStyle(color: lc.textColor, fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: lc.subtextColor),
        filled: true,
        fillColor: lc.glassColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: lc.glassBorderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: lc.glassBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: lc.primaryColor, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  
  Widget _buildDiagnosticsCard(LayoutController lc) {
    return _card(lc,
      child: Obx(() => Column(
        children: controller.diagnostics.entries.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(e.key.toUpperCase(),
                style: TextStyle(color: lc.subtextColor.withValues(alpha: 0.6),
                  fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
              Text(e.value,
                style: GoogleFonts.lexend(color: lc.textColor, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
        )).toList(),
      )),
    );
  }

  
  Widget _buildDangerZone(LayoutController lc) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(40, 0, 40, 0),
      sliver: SliverToBoxAdapter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('VÙNG NGUY HIỂM',
              style: const TextStyle(color: Colors.redAccent,
                fontWeight: FontWeight.w900, letterSpacing: 2.5, fontSize: 10)),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: controller.requestErasure,
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.redAccent.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.delete_forever_rounded, color: Colors.redAccent, size: 18),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Xóa toàn bộ tác phẩm',
                          style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w800, fontSize: 13)),
                        const SizedBox(height: 2),
                        Text('Hành động này không thể hoàn tác',
                          style: TextStyle(color: Colors.redAccent.withValues(alpha: 0.6), fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  
  Widget _buildToggleItem(String label, RxBool value, Function(bool) onChanged, LayoutController lc, {String? subtitle}) {
    return _card(lc,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: lc.textColor, fontWeight: FontWeight.w700, fontSize: 13)),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(color: lc.subtextColor, fontSize: 11)),
                ],
              ],
            ),
          ),
          Obx(() => Transform.scale(
            scale: 0.85,
            child: Switch(
              value: value.value,
              onChanged: onChanged,
              activeTrackColor: lc.primaryColor.withValues(alpha: 0.4),
              activeThumbColor: lc.primaryColor,
              inactiveTrackColor: lc.textColor.withValues(alpha: 0.08),
              inactiveThumbColor: lc.textColor.withValues(alpha: 0.3),
            ),
          )),
        ],
      ),
    );
  }

  Widget _card(LayoutController lc, {required Widget child}) {
    return Obx(() => Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: lc.glassColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: lc.glassBorderColor),
      ),
      child: child,
    ));
  }

  Widget _buildBackButton(LayoutController lc, BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: Obx(() => Container(
        width: 46, height: 46,
        decoration: BoxDecoration(
          color: lc.glassColor,
          shape: BoxShape.circle,
          border: Border.all(color: lc.glassBorderColor),
        ),
        child: Icon(Icons.arrow_back_ios_new_rounded, color: lc.textColor, size: 16),
      )),
    );
  }
}
