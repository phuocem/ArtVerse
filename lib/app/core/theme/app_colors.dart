import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../modules/layout/controllers/layout_controller.dart';

class AppColors {
  static LayoutController? get _lc => Get.isRegistered<LayoutController>() ? Get.find<LayoutController>() : null;

  static Color get bg => _lc?.backgroundColor ?? const Color(0xFF030303);
  static Color get bg2 => _lc?.cardColor ?? const Color(0xFF0A0A0A);
  
  static Color get surface => _lc?.surfaceColor ?? const Color(0xFF0F0F0F);
  static Color get surface2 => _lc?.cardColor ?? const Color(0xFF161616);
  
  static Color get border => _lc?.textColor.withValues(alpha: 0.1) ?? const Color(0xFF1F1F1F);
  static Color get border2 => _lc?.textColor.withValues(alpha: 0.15) ?? const Color(0xFF2A2A2A);
  static Color get border3 => _lc?.textColor.withValues(alpha: 0.2) ?? const Color(0xFF3F3F3F);

  static Color get textPrimary => _lc?.textColor ?? const Color(0xFFF5F5F7); 
  static Color get textSecondary => _lc?.subtextColor ?? const Color(0xFF9E9E9E);
  static Color get textTertiary => _lc?.textColor.withValues(alpha: 0.4) ?? const Color(0xFF616161);

  static Color get primary => _lc?.primaryColor ?? const Color(0xFF00D1FF); 
  static Color get secondary => _lc?.accentColor ?? const Color(0xFFB8860B); 
  static Color get accent => _lc?.accentColor ?? const Color(0xFFFF3B30); 

  static Color get violet => _lc?.primaryColor ?? const Color(0xFF7B61FF);
  static Color get violet2 => _lc?.accentColor ?? const Color(0xFF6366F1);
  static Color get violetPinkColor => _lc?.accentColor ?? const Color(0xFFD48BFF);
  static Color get teal => _lc?.primaryColor ?? const Color(0xFF00D1FF); 
  static Color get amber => _lc?.accentColor ?? const Color(0xFFFFAB00);
  static Color get pink => _lc?.primaryColor ?? const Color(0xFFFF3366);
  static Color get blue => _lc?.primaryColor ?? const Color(0xFF007AFF);

  static LinearGradient get violetPink => _lc?.accentGradient ?? const LinearGradient(
    colors: [Color(0xFFD48BFF), Color(0xFF6366F1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient noirGrad = LinearGradient(
    colors: [Color(0xFF1A1A1A), Color(0xFF030303)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient platinumGrad = LinearGradient(
    colors: [Color(0xFFE0E0E0), Color(0xFFFFFFFF), Color(0xFFBDBDBD)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient electricCyanGrad = LinearGradient(
    colors: [Color(0xFF00D1FF), Color(0xFF007AFF)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient goldGrad = LinearGradient(
    colors: [Color(0xFFD4AF37), Color(0xFF996515)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassGrad = LinearGradient(
    colors: [Color(0x1A616161), Color(0x0DFFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
