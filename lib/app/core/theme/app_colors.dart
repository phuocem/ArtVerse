import 'package:flutter/material.dart';

class AppColors {
  
  static const Color bg = Color(0xFF030303); 
  static const Color bg2 = Color(0xFF0A0A0A);
  static const Color surface = Color(0xFF0F0F0F);
  static const Color surface2 = Color(0xFF161616);
  static const Color border = Color(0xFF1F1F1F);
  static const Color border2 = Color(0xFF2A2A2A);
  static const Color border3 = Color(0xFF3F3F3F);

  static const Color textPrimary = Color(0xFFF5F5F7); 
  static const Color textSecondary = Color(0xFF9E9E9E);
  static const Color textTertiary = Color(0xFF616161);

  static const Color primary = Color(0xFF00D1FF); 
  static const Color secondary = Color(0xFFB8860B); 
  static const Color accent = Color(0xFFFF3B30); 

  
  static const Color violet = Color(0xFF7B61FF);
  static const Color violet2 = Color(0xFF6366F1);
  static const Color violetPinkColor = Color(0xFFD48BFF);
  static const Color teal = Color(0xFF00D1FF); 
  static const Color amber = Color(0xFFFFAB00);
  static const Color pink = Color(0xFFFF3366);
  static const Color blue = Color(0xFF007AFF);

  static const LinearGradient violetPink = LinearGradient(
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
