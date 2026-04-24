import 'package:flutter/material.dart';

class AppThemeModel {
  final String id;
  final String name;

  final Color layoutColor;
  final Color onLayoutColor;
  final Color backgroundColor;
  final Color onBackgroundColor;
  final Color surfaceColor;
  final Color onSurfaceColor;
  final Color cardColor;
  final Color primaryColor;
  final Color onPrimaryColor;
  final Color accentColor;
  final LinearGradient accentGradient;
  final bool isDark;

  const AppThemeModel({
    required this.id,
    required this.name,
    required this.layoutColor,
    required this.onLayoutColor,
    required this.backgroundColor,
    required this.onBackgroundColor,
    required this.surfaceColor,
    required this.onSurfaceColor,
    required this.cardColor,
    required this.primaryColor,
    required this.onPrimaryColor,
    required this.accentColor,
    required this.accentGradient,
    required this.isDark,
  });

  Color get textColor => onBackgroundColor;
  Color get subtextColor => onBackgroundColor.withValues(alpha: 0.6);

  ThemeData toThemeData() {
    final base = isDark ? ThemeData.dark() : ThemeData.light();
    return base.copyWith(
      scaffoldBackgroundColor: backgroundColor,
      cardColor: cardColor,
      canvasColor: layoutColor,
      dialogTheme: base.dialogTheme.copyWith(backgroundColor: surfaceColor),
      primaryColor: primaryColor,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: isDark ? Brightness.dark : Brightness.light,
        surface: surfaceColor,
        onSurface: onSurfaceColor,
        primary: primaryColor,
        onPrimary: onPrimaryColor,
        secondary: accentColor,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: onBackgroundColor,
        displayColor: onBackgroundColor,
        fontFamily: 'Plus Jakarta Sans',
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: surfaceColor,
        textStyle: TextStyle(color: onSurfaceColor, fontFamily: 'Plus Jakarta Sans', fontSize: 13),
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: onSurfaceColor.withValues(alpha: 0.1)),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: onBackgroundColor.withValues(alpha: 0.1),
        thickness: 1,
      ),
    );
  }
}

class AppThemes {
  static const String defaultThemeId = 'noir_art';

  static final List<AppThemeModel> themes = [
    
    const AppThemeModel(
      id: 'noir_art', name: 'Noir Art 🌑', isDark: true,
      layoutColor: Color(0xFF030303), onLayoutColor: Color(0xFF00D1FF),
      backgroundColor: Color(0xFF000000), onBackgroundColor: Color(0xFFF5F5F7),
      surfaceColor: Color(0xFF0F0F0F), onSurfaceColor: Color(0xFFE0E0E0),
      cardColor: Color(0xFF161616),
      primaryColor: Color(0xFF00D1FF), onPrimaryColor: Color(0xFF000000),
      accentColor: Color(0xFFD4AF37),
      accentGradient: LinearGradient(colors: [Color(0xFF00D1FF), Color(0xFFD4AF37)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    ),
    
    const AppThemeModel(
      id: 'aurora_nova', name: 'Aurora Nova 🌌', isDark: true,
      layoutColor: Color(0xFF030308), onLayoutColor: Color(0xFF00E5FF),
      backgroundColor: Color(0xFF010103), onBackgroundColor: Color(0xFFFFFFFF),
      surfaceColor: Color(0xFF0A0A1F), onSurfaceColor: Color(0xFFE0F7FA),
      cardColor: Color(0xFF16163A),
      primaryColor: Color(0xFF00E5FF), onPrimaryColor: Color(0xFF000000),
      accentColor: Color(0xFF7C4DFF),
      accentGradient: LinearGradient(colors: [Color(0xFF00E5FF), Color(0xFF7C4DFF)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    ),
    
    const AppThemeModel(
      id: 'pink_light', name: 'Pink Blossom 🌸', isDark: false,
      layoutColor: Color(0xFFFFE4E1), onLayoutColor: Color(0xFFE91E63),
      backgroundColor: Color(0xFFFFF5F7), onBackgroundColor: Color(0xFF2D041A),
      surfaceColor: Color(0xFFFFFFFF), onSurfaceColor: Color(0xFF4D142B),
      cardColor: Color(0xFFFFD1DC),
      primaryColor: Color(0xFFFF69B4), onPrimaryColor: Color(0xFFFFFFFF),
      accentColor: Color(0xFFFF1493),
      accentGradient: LinearGradient(colors: [Color(0xFFFF69B4), Color(0xFFFF1493)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    ),
    
    const AppThemeModel(
      id: 'deep_space', name: 'Deep Space 🚀', isDark: true,
      layoutColor: Color(0xFF0F0C0B), onLayoutColor: Color(0xFFFFB499),
      backgroundColor: Color(0xFF050403), onBackgroundColor: Color(0xFFFFFFFF),
      surfaceColor: Color(0xFF1E1B1A), onSurfaceColor: Color(0xFFFDE6D8),
      cardColor: Color(0xFF2D2928),
      primaryColor: Color(0xFFFFB499), onPrimaryColor: Color(0xFF451900),
      accentColor: Color(0xFFD7C48C),
      accentGradient: LinearGradient(colors: [Color(0xFFFFB499), Color(0xFFD7C48C)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    ),
    
    const AppThemeModel(
      id: 'crystal_cool', name: 'Crystal Cool 💎', isDark: false,
      layoutColor: Color(0xFFDFEAF0), onLayoutColor: Color(0xFF003040),
      backgroundColor: Color(0xFFF0F5F9), onBackgroundColor: Color(0xFF051C2C),
      surfaceColor: Color(0xFFFFFFFF), onSurfaceColor: Color(0xFF003040),
      cardColor: Color(0xFFD6E4EF),
      primaryColor: Color(0xFF006782), onPrimaryColor: Color(0xFFFFFFFF),
      accentColor: Color(0xFF00A5B4),
      accentGradient: LinearGradient(colors: [Color(0xFF006782), Color(0xFF00A5B4)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    ),
    
    const AppThemeModel(
      id: 'midnight_emerald', name: 'Emerald 🍃', isDark: true,
      layoutColor: Color(0xFF021912), onLayoutColor: Color(0xFF34D399),
      backgroundColor: Color(0xFF010A08), onBackgroundColor: Color(0xFFE0FFF4),
      surfaceColor: Color(0xFF063B2A), onSurfaceColor: Color(0xFFD1FAE5),
      cardColor: Color(0xFF0D5E46),
      primaryColor: Color(0xFF34D399), onPrimaryColor: Color(0xFF064E3B),
      accentColor: Color(0xFFFCD34D),
      accentGradient: LinearGradient(colors: [Color(0xFF34D399), Color(0xFFFCD34D)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    ),
    
    const AppThemeModel(
      id: 'cyber_neon', name: 'Cyber Neon 🎮', isDark: true,
      layoutColor: Color(0xFF000000), onLayoutColor: Color(0xFFF0ABFC),
      backgroundColor: Color(0xFF000000), onBackgroundColor: Color(0xFFFFFFFF),
      surfaceColor: Color(0xFF0D0D0D), onSurfaceColor: Color(0xFFF5D0FF),
      cardColor: Color(0xFF1A1A1A),
      primaryColor: Color(0xFFF0ABFC), onPrimaryColor: Color(0xFF000000),
      accentColor: Color(0xFF22D3EE),
      accentGradient: LinearGradient(colors: [Color(0xFFF0ABFC), Color(0xFF22D3EE)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    ),
    
    const AppThemeModel(
      id: 'indigo_velvet', name: 'Indigo Velvet 🔵', isDark: true,
      layoutColor: Color(0xFF0F0E28), onLayoutColor: Color(0xFFA5B4FC),
      backgroundColor: Color(0xFF050515), onBackgroundColor: Color(0xFFEEF2FF),
      surfaceColor: Color(0xFF1E1B4B), onSurfaceColor: Color(0xFFE0E7FF),
      cardColor: Color(0xFF2D2A6E),
      primaryColor: Color(0xFF818CF8), onPrimaryColor: Color(0xFF1E1B4B),
      accentColor: Color(0xFFA5B4FC),
      accentGradient: LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    ),
    
    const AppThemeModel(
      id: 'rose_gold', name: 'Rose Gold 🌹', isDark: false,
      layoutColor: Color(0xFFFFF1F2), onLayoutColor: Color(0xFFBE123C),
      backgroundColor: Color(0xFFFFF9FA), onBackgroundColor: Color(0xFF4C0619),
      surfaceColor: Color(0xFFFFFFFF), onSurfaceColor: Color(0xFFBE123C),
      cardColor: Color(0xFFFFDEE2),
      primaryColor: Color(0xFFE11D48), onPrimaryColor: Color(0xFFFFFFFF),
      accentColor: Color(0xFFFB7185),
      accentGradient: LinearGradient(colors: [Color(0xFFE11D48), Color(0xFFFB7185)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    ),
    
    const AppThemeModel(
      id: 'matcha_tea', name: 'Matcha Zen 🍵', isDark: false,
      layoutColor: Color(0xFFECFCCB), onLayoutColor: Color(0xFF1A2E05),
      backgroundColor: Color(0xFFF9FFF0), onBackgroundColor: Color(0xFF1A2E05),
      surfaceColor: Color(0xFFFFFFFF), onSurfaceColor: Color(0xFF3F6212),
      cardColor: Color(0xFFE2EFCA),
      primaryColor: Color(0xFF4D7C0F), onPrimaryColor: Color(0xFFFFFFFF),
      accentColor: Color(0xFF84CC16),
      accentGradient: LinearGradient(colors: [Color(0xFF4D7C0F), Color(0xFF84CC16)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    ),
    
    const AppThemeModel(
      id: 'volcanic_red', name: 'Volcanic 🌋', isDark: true,
      layoutColor: Color(0xFF150000), onLayoutColor: Color(0xFFEF4444),
      backgroundColor: Color(0xFF0A0000), onBackgroundColor: Color(0xFFFFF5F5),
      surfaceColor: Color(0xFF450A0A), onSurfaceColor: Color(0xFFFCA5A5),
      cardColor: Color(0xFF6B1212),
      primaryColor: Color(0xFFF87171), onPrimaryColor: Color(0xFF450A0A),
      accentColor: Color(0xFFFCA5A5),
      accentGradient: LinearGradient(colors: [Color(0xFF991B1B), Color(0xFFF87171)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    ),
    
    const AppThemeModel(
      id: 'coffee_roast', name: 'Coffee Roast ☕', isDark: true,
      layoutColor: Color(0xFF0F0D0B), onLayoutColor: Color(0xFFA8A29E),
      backgroundColor: Color(0xFF0A0807), onBackgroundColor: Color(0xFFFFFFFF),
      surfaceColor: Color(0xFF1C1917), onSurfaceColor: Color(0xFFE7E5E4),
      cardColor: Color(0xFF332F2D),
      primaryColor: Color(0xFFD6D3D1), onPrimaryColor: Color(0xFF1C1917),
      accentColor: Color(0xFFA8A29E),
      accentGradient: LinearGradient(colors: [Color(0xFF78716C), Color(0xFFA8A29E)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    ),
    
    const AppThemeModel(
      id: 'ocean_blue', name: 'Ocean Blue 🌊', isDark: true,
      layoutColor: Color(0xFF050B1F), onLayoutColor: Color(0xFF7DD3FC),
      backgroundColor: Color(0xFF02040A), onBackgroundColor: Color(0xFFF0F9FF),
      surfaceColor: Color(0xFF0F172A), onSurfaceColor: Color(0xFFE2E8F0),
      cardColor: Color(0xFF1E3A5F),
      primaryColor: Color(0xFF38BDF8), onPrimaryColor: Color(0xFF082F49),
      accentColor: Color(0xFF7DD3FC),
      accentGradient: LinearGradient(colors: [Color(0xFF0284C7), Color(0xFF38BDF8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    ),
    
    const AppThemeModel(
      id: 'sunset_orange', name: 'Sunset 🌇', isDark: false,
      layoutColor: Color(0xFFFEF3C7), onLayoutColor: Color(0xFF451A03),
      backgroundColor: Color(0xFFFFF9F2), onBackgroundColor: Color(0xFF451A03),
      surfaceColor: Color(0xFFFFFFFF), onSurfaceColor: Color(0xFF92400E),
      cardColor: Color(0xFFFFE8D1),
      primaryColor: Color(0xFFEA580C), onPrimaryColor: Color(0xFFFFFFFF),
      accentColor: Color(0xFFF97316),
      accentGradient: LinearGradient(colors: [Color(0xFFF97316), Color(0xFFFDBA74)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    ),
    
    const AppThemeModel(
      id: 'lavender_mist', name: 'Lavender 💜', isDark: false,
      layoutColor: Color(0xFFEDE9FE), onLayoutColor: Color(0xFF2E1065),
      backgroundColor: Color(0xFFF9F7FF), onBackgroundColor: Color(0xFF2E1065),
      surfaceColor: Color(0xFFFFFFFF), onSurfaceColor: Color(0xFF5B21B6),
      cardColor: Color(0xFFEBE2FF),
      primaryColor: Color(0xFF7C3AED), onPrimaryColor: Color(0xFFFFFFFF),
      accentColor: Color(0xFFA78BFA),
      accentGradient: LinearGradient(colors: [Color(0xFF8B5CF6), Color(0xFFA78BFA)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    ),
    
    const AppThemeModel(
      id: 'royal_velvet', name: 'Royal Velvet 👑', isDark: true,
      layoutColor: Color(0xFF1E073B), onLayoutColor: Color(0xFFDDD6FE),
      backgroundColor: Color(0xFF0F021B), onBackgroundColor: Color(0xFFFDFBFF),
      surfaceColor: Color(0xFF4C1D95), onSurfaceColor: Color(0xFFDDD6FE),
      cardColor: Color(0xFF541C8A),
      primaryColor: Color(0xFFDDD6FE), onPrimaryColor: Color(0xFF2E1065),
      accentColor: Color(0xFFF5F3FF),
      accentGradient: LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFFA78BFA)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    ),
    
    const AppThemeModel(
      id: 'arctic_frost', name: 'Arctic Frost 🧊', isDark: false,
      layoutColor: Color(0xFFCCEAFF), onLayoutColor: Color(0xFF003D5B),
      backgroundColor: Color(0xFFF7FCFF), onBackgroundColor: Color(0xFF003D5B),
      surfaceColor: Color(0xFFFFFFFF), onSurfaceColor: Color(0xFF0369A1),
      cardColor: Color(0xFFDCF0FF),
      primaryColor: Color(0xFF0284C7), onPrimaryColor: Color(0xFFFFFFFF),
      accentColor: Color(0xFF38BDF8),
      accentGradient: LinearGradient(colors: [Color(0xFF0EA5E9), Color(0xFF38BDF8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    ),
    
    const AppThemeModel(
      id: 'desert_sand', name: 'Desert Sand 🏜️', isDark: false,
      layoutColor: Color(0xFFFEF3C7), onLayoutColor: Color(0xFF452007),
      backgroundColor: Color(0xFFFFFAF0), onBackgroundColor: Color(0xFF452007),
      surfaceColor: Color(0xFFFFFFFF), onSurfaceColor: Color(0xFF92400E),
      cardColor: Color(0xFFF9E7C0),
      primaryColor: Color(0xFFB45309), onPrimaryColor: Color(0xFFFFFFFF),
      accentColor: Color(0xFFD97706),
      accentGradient: LinearGradient(colors: [Color(0xFFB45309), Color(0xFFFBBF24)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    ),
    
    const AppThemeModel(
      id: 'midnight_amethyst', name: 'Amethyst 💎', isDark: true,
      layoutColor: Color(0xFF130528), onLayoutColor: Color(0xFFA78BFA),
      backgroundColor: Color(0xFF0A0216), onBackgroundColor: Color(0xFFF5F3FF),
      surfaceColor: Color(0xFF2E1065), onSurfaceColor: Color(0xFFDDD6FE),
      cardColor: Color(0xFF40168A),
      primaryColor: Color(0xFFC4B5FD), onPrimaryColor: Color(0xFF2E1065),
      accentColor: Color(0xFFA78BFA),
      accentGradient: LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFFC4B5FD)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    ),
    
    const AppThemeModel(
      id: 'slate_gray', name: 'Slate Gray 🌫️', isDark: false,
      layoutColor: Color(0xFFE2E8F0), onLayoutColor: Color(0xFF0F172A),
      backgroundColor: Color(0xFFF8FAFC), onBackgroundColor: Color(0xFF0F172A),
      surfaceColor: Color(0xFFFFFFFF), onSurfaceColor: Color(0xFF1E293B),
      cardColor: Color(0xFFCBD5E1),
      primaryColor: Color(0xFF334155), onPrimaryColor: Color(0xFFFFFFFF),
      accentColor: Color(0xFF64748B),
      accentGradient: LinearGradient(colors: [Color(0xFF334155), Color(0xFF64748B)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    ),
    
    const AppThemeModel(
      id: 'charcoal_dark', name: 'Charcoal 🖤', isDark: true,
      layoutColor: Color(0xFF0A0A0A), onLayoutColor: Color(0xFFD4D4D4),
      backgroundColor: Color(0xFF000000), onBackgroundColor: Color(0xFFFFFFFF),
      surfaceColor: Color(0xFF171717), onSurfaceColor: Color(0xFFE5E5E5),
      cardColor: Color(0xFF262626),
      primaryColor: Color(0xFFE5E5E5), onPrimaryColor: Color(0xFF000000),
      accentColor: Color(0xFFA3A3A3),
      accentGradient: LinearGradient(colors: [Color(0xFF404040), Color(0xFF737373)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    ),
    
    const AppThemeModel(
      id: 'blood_moon', name: 'Blood Moon 🌑', isDark: true,
      layoutColor: Color(0xFF0A0000), onLayoutColor: Color(0xFFFF0000),
      backgroundColor: Color(0xFF000000), onBackgroundColor: Color(0xFFFFFFFF),
      surfaceColor: Color(0xFF1A0000), onSurfaceColor: Color(0xFFFF4D4D),
      cardColor: Color(0xFF450000),
      primaryColor: Color(0xFFFF0000), onPrimaryColor: Color(0xFFFFFFFF),
      accentColor: Color(0xFF8B0000),
      accentGradient: LinearGradient(colors: [Color(0xFF450000), Color(0xFFFF0000)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    ),
    
    const AppThemeModel(
      id: 'pure_white', name: 'Pure White ⬜', isDark: false,
      layoutColor: Color(0xFFF5F5F5), onLayoutColor: Color(0xFF000000),
      backgroundColor: Color(0xFFFFFFFF), onBackgroundColor: Color(0xFF000000),
      surfaceColor: Color(0xFFFAFAFA), onSurfaceColor: Color(0xFF1A1A1A),
      cardColor: Color(0xFFE5E5E5),
      primaryColor: Color(0xFF000000), onPrimaryColor: Color(0xFFFFFFFF),
      accentColor: Color(0xFF333333),
      accentGradient: LinearGradient(colors: [Color(0xFF333333), Color(0xFF666666)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    ),
    
    const AppThemeModel(
      id: 'sakura_night', name: 'Sakura Night 🌸', isDark: true,
      layoutColor: Color(0xFF1A0A12), onLayoutColor: Color(0xFFFFB7C5),
      backgroundColor: Color(0xFF0D0508), onBackgroundColor: Color(0xFFFFE4EC),
      surfaceColor: Color(0xFF2D1020), onSurfaceColor: Color(0xFFFFB7C5),
      cardColor: Color(0xFF3D1A2C),
      primaryColor: Color(0xFFFFB7C5), onPrimaryColor: Color(0xFF1A0A12),
      accentColor: Color(0xFFFF85A1),
      accentGradient: LinearGradient(colors: [Color(0xFFFF85A1), Color(0xFFFFB7C5)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    ),
    
    const AppThemeModel(
      id: 'forest_dusk', name: 'Forest Dusk 🌲', isDark: true,
      layoutColor: Color(0xFF0A1208), onLayoutColor: Color(0xFF86EFAC),
      backgroundColor: Color(0xFF050A04), onBackgroundColor: Color(0xFFDCFCE7),
      surfaceColor: Color(0xFF14291A), onSurfaceColor: Color(0xFFBBF7D0),
      cardColor: Color(0xFF1E4128),
      primaryColor: Color(0xFF4ADE80), onPrimaryColor: Color(0xFF052E16),
      accentColor: Color(0xFF86EFAC),
      accentGradient: LinearGradient(colors: [Color(0xFF16A34A), Color(0xFF4ADE80)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    ),
    
    const AppThemeModel(
      id: 'topaz_gold', name: 'Topaz Gold ✨', isDark: true,
      layoutColor: Color(0xFF150F00), onLayoutColor: Color(0xFFFBBF24),
      backgroundColor: Color(0xFF0A0700), onBackgroundColor: Color(0xFFFEF9E7),
      surfaceColor: Color(0xFF2A1F00), onSurfaceColor: Color(0xFFFDE68A),
      cardColor: Color(0xFF3D2D00),
      primaryColor: Color(0xFFF59E0B), onPrimaryColor: Color(0xFF1A0700),
      accentColor: Color(0xFFFBBF24),
      accentGradient: LinearGradient(colors: [Color(0xFFD97706), Color(0xFFFBBF24)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    ),
    
    const AppThemeModel(
      id: 'mint_fresh', name: 'Mint Fresh 🌿', isDark: false,
      layoutColor: Color(0xFFCCFBF1), onLayoutColor: Color(0xFF134E4A),
      backgroundColor: Color(0xFFF0FDF9), onBackgroundColor: Color(0xFF042F2E),
      surfaceColor: Color(0xFFFFFFFF), onSurfaceColor: Color(0xFF0F766E),
      cardColor: Color(0xFFCCFBF1),
      primaryColor: Color(0xFF0D9488), onPrimaryColor: Color(0xFFFFFFFF),
      accentColor: Color(0xFF2DD4BF),
      accentGradient: LinearGradient(colors: [Color(0xFF0D9488), Color(0xFF2DD4BF)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    ),
    
    const AppThemeModel(
      id: 'obsidian_purple', name: 'Obsidian 🔮', isDark: true,
      layoutColor: Color(0xFF08020F), onLayoutColor: Color(0xFFE879F9),
      backgroundColor: Color(0xFF040008), onBackgroundColor: Color(0xFFFAE8FF),
      surfaceColor: Color(0xFF170829), onSurfaceColor: Color(0xFFF0ABFC),
      cardColor: Color(0xFF260D3D),
      primaryColor: Color(0xFFD946EF), onPrimaryColor: Color(0xFF170829),
      accentColor: Color(0xFFE879F9),
      accentGradient: LinearGradient(colors: [Color(0xFF9333EA), Color(0xFFD946EF)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    ),
    
    const AppThemeModel(
      id: 'coral_reef', name: 'Coral Reef 🪸', isDark: false,
      layoutColor: Color(0xFFFFEDE8), onLayoutColor: Color(0xFF7C2D12),
      backgroundColor: Color(0xFFFFF8F5), onBackgroundColor: Color(0xFF431407),
      surfaceColor: Color(0xFFFFFFFF), onSurfaceColor: Color(0xFF9A3412),
      cardColor: Color(0xFFFFDDD5),
      primaryColor: Color(0xFFEA580C), onPrimaryColor: Color(0xFFFFFFFF),
      accentColor: Color(0xFFF97316),
      accentGradient: LinearGradient(colors: [Color(0xFFEA580C), Color(0xFFFB923C)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    ),
    
    const AppThemeModel(
      id: 'galaxy_blue', name: 'Galaxy Blue 🌌', isDark: true,
      layoutColor: Color(0xFF020512), onLayoutColor: Color(0xFF93C5FD),
      backgroundColor: Color(0xFF010209), onBackgroundColor: Color(0xFFEFF6FF),
      surfaceColor: Color(0xFF0B1230), onSurfaceColor: Color(0xFFBFDBFE),
      cardColor: Color(0xFF112044),
      primaryColor: Color(0xFF60A5FA), onPrimaryColor: Color(0xFF1E3A5F),
      accentColor: Color(0xFF93C5FD),
      accentGradient: LinearGradient(colors: [Color(0xFF1D4ED8), Color(0xFF60A5FA)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    ),
    
    const AppThemeModel(
      id: 'champagne', name: 'Champagne 🥂', isDark: false,
      layoutColor: Color(0xFFF5EDD6), onLayoutColor: Color(0xFF4A3300),
      backgroundColor: Color(0xFFFAF5E9), onBackgroundColor: Color(0xFF3B2800),
      surfaceColor: Color(0xFFFFFFFF), onSurfaceColor: Color(0xFF78600A),
      cardColor: Color(0xFFF0E0B0),
      primaryColor: Color(0xFF9A7B00), onPrimaryColor: Color(0xFFFFFFFF),
      accentColor: Color(0xFFD4AF37),
      accentGradient: LinearGradient(colors: [Color(0xFF9A7B00), Color(0xFFD4AF37)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    ),
    
    const AppThemeModel(
      id: 'neon_lime', name: 'Neon Lime ⚡', isDark: true,
      layoutColor: Color(0xFF050A00), onLayoutColor: Color(0xFFA3E635),
      backgroundColor: Color(0xFF020400), onBackgroundColor: Color(0xFFF7FEE7),
      surfaceColor: Color(0xFF0D1500), onSurfaceColor: Color(0xFFD9F99D),
      cardColor: Color(0xFF162000),
      primaryColor: Color(0xFF84CC16), onPrimaryColor: Color(0xFF1A2E05),
      accentColor: Color(0xFFA3E635),
      accentGradient: LinearGradient(colors: [Color(0xFF65A30D), Color(0xFFA3E635)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    ),
    
    const AppThemeModel(
      id: 'dusk_rose', name: 'Dusk Rose 🌅', isDark: false,
      layoutColor: Color(0xFFFFE4D6), onLayoutColor: Color(0xFF881337),
      backgroundColor: Color(0xFFFFF1EB), onBackgroundColor: Color(0xFF4C0319),
      surfaceColor: Color(0xFFFFFFFF), onSurfaceColor: Color(0xFFBE185D),
      cardColor: Color(0xFFFFD6E0),
      primaryColor: Color(0xFFE11D48), onPrimaryColor: Color(0xFFFFFFFF),
      accentColor: Color(0xFFFB7185),
      accentGradient: LinearGradient(colors: [Color(0xFFE11D48), Color(0xFFFDA4AF)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    ),
    
    const AppThemeModel(
      id: 'cyberpunk_orange', name: 'Cyberpunk 🔶', isDark: true,
      layoutColor: Color(0xFF0F0800), onLayoutColor: Color(0xFFFF8C00),
      backgroundColor: Color(0xFF080400), onBackgroundColor: Color(0xFFFFF3E0),
      surfaceColor: Color(0xFF1A0E00), onSurfaceColor: Color(0xFFFFCC80),
      cardColor: Color(0xFF2A1700),
      primaryColor: Color(0xFFFF8C00), onPrimaryColor: Color(0xFF1A0700),
      accentColor: Color(0xFFFFAB40),
      accentGradient: LinearGradient(colors: [Color(0xFFE65100), Color(0xFFFF8C00)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    ),
    
    const AppThemeModel(
      id: 'storm_gray', name: 'Storm Gray 🌩️', isDark: true,
      layoutColor: Color(0xFF0C0D0F), onLayoutColor: Color(0xFF94A3B8),
      backgroundColor: Color(0xFF060708), onBackgroundColor: Color(0xFFF1F5F9),
      surfaceColor: Color(0xFF181A1E), onSurfaceColor: Color(0xFFCBD5E1),
      cardColor: Color(0xFF252830),
      primaryColor: Color(0xFF64748B), onPrimaryColor: Color(0xFFFFFFFF),
      accentColor: Color(0xFF94A3B8),
      accentGradient: LinearGradient(colors: [Color(0xFF475569), Color(0xFF94A3B8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    ),
    
    const AppThemeModel(
      id: 'peach_cream', name: 'Peach Cream 🍑', isDark: false,
      layoutColor: Color(0xFFFFE5D4), onLayoutColor: Color(0xFF7C2D12),
      backgroundColor: Color(0xFFFFF6F0), onBackgroundColor: Color(0xFF431407),
      surfaceColor: Color(0xFFFFFFFF), onSurfaceColor: Color(0xFF9A3412),
      cardColor: Color(0xFFFFD5BC),
      primaryColor: Color(0xFFF97316), onPrimaryColor: Color(0xFFFFFFFF),
      accentColor: Color(0xFFFB923C),
      accentGradient: LinearGradient(colors: [Color(0xFFF97316), Color(0xFFFB923C)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    ),
    
    const AppThemeModel(
      id: 'ivory_classic', name: 'Ivory Classic 📜', isDark: false,
      layoutColor: Color(0xFFF5F0E8), onLayoutColor: Color(0xFF3D2B1F),
      backgroundColor: Color(0xFFFAF7F0), onBackgroundColor: Color(0xFF2C1810),
      surfaceColor: Color(0xFFFFFFFF), onSurfaceColor: Color(0xFF5C3D2E),
      cardColor: Color(0xFFEDE0CC),
      primaryColor: Color(0xFF8B5E3C), onPrimaryColor: Color(0xFFFFFFFF),
      accentColor: Color(0xFFAD7C59),
      accentGradient: LinearGradient(colors: [Color(0xFF6B4226), Color(0xFFAD7C59)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    ),
    
    const AppThemeModel(
      id: 'vapor_wave', name: 'Vaporwave 🌊', isDark: true,
      layoutColor: Color(0xFF0A0014), onLayoutColor: Color(0xFFFF71CE),
      backgroundColor: Color(0xFF050009), onBackgroundColor: Color(0xFFFEE5F7),
      surfaceColor: Color(0xFF150028), onSurfaceColor: Color(0xFFFF71CE),
      cardColor: Color(0xFF200040),
      primaryColor: Color(0xFFFF71CE), onPrimaryColor: Color(0xFF0A0014),
      accentColor: Color(0xFF01CDFE),
      accentGradient: LinearGradient(colors: [Color(0xFFFF71CE), Color(0xFF01CDFE)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    ),
    
    const AppThemeModel(
      id: 'azure_sky', name: 'Azure Sky ☁️', isDark: false,
      layoutColor: Color(0xFFDBEAFE), onLayoutColor: Color(0xFF1E3A5F),
      backgroundColor: Color(0xFFEFF6FF), onBackgroundColor: Color(0xFF1E3A5F),
      surfaceColor: Color(0xFFFFFFFF), onSurfaceColor: Color(0xFF1D4ED8),
      cardColor: Color(0xFFBFDBFE),
      primaryColor: Color(0xFF2563EB), onPrimaryColor: Color(0xFFFFFFFF),
      accentColor: Color(0xFF3B82F6),
      accentGradient: LinearGradient(colors: [Color(0xFF1D4ED8), Color(0xFF60A5FA)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    ),
    
    const AppThemeModel(
      id: 'bronze_age', name: 'Bronze Age 🏺', isDark: true,
      layoutColor: Color(0xFF100900), onLayoutColor: Color(0xFFCD7F32),
      backgroundColor: Color(0xFF080500), onBackgroundColor: Color(0xFFFDF0E6),
      surfaceColor: Color(0xFF1E1000), onSurfaceColor: Color(0xFFE8A87C),
      cardColor: Color(0xFF2C1800),
      primaryColor: Color(0xFFCD7F32), onPrimaryColor: Color(0xFF100900),
      accentColor: Color(0xFFE8A87C),
      accentGradient: LinearGradient(colors: [Color(0xFF8B4513), Color(0xFFCD7F32)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    ),
    
    const AppThemeModel(
      id: 'electric_teal', name: 'Electric Teal ⚡', isDark: true,
      layoutColor: Color(0xFF000E0F), onLayoutColor: Color(0xFF00E5CC),
      backgroundColor: Color(0xFF000708), onBackgroundColor: Color(0xFFE0FFFD),
      surfaceColor: Color(0xFF001A1C), onSurfaceColor: Color(0xFF80F5F0),
      cardColor: Color(0xFF002B2D),
      primaryColor: Color(0xFF00E5CC), onPrimaryColor: Color(0xFF001A1C),
      accentColor: Color(0xFF80F5F0),
      accentGradient: LinearGradient(colors: [Color(0xFF008080), Color(0xFF00E5CC)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    ),
    
    const AppThemeModel(
      id: 'cherry_dark', name: 'Cherry Dark 🍒', isDark: true,
      layoutColor: Color(0xFF120008), onLayoutColor: Color(0xFFFF6B8A),
      backgroundColor: Color(0xFF0A0005), onBackgroundColor: Color(0xFFFFECF0),
      surfaceColor: Color(0xFF2A0015), onSurfaceColor: Color(0xFFFF9AB2),
      cardColor: Color(0xFF3D0020),
      primaryColor: Color(0xFFFF4D6D), onPrimaryColor: Color(0xFF2A0015),
      accentColor: Color(0xFFFF6B8A),
      accentGradient: LinearGradient(colors: [Color(0xFFFF0055), Color(0xFFFF6B8A)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    ),
    
    const AppThemeModel(
      id: 'morning_dew', name: 'Morning Dew 🌤️', isDark: false,
      layoutColor: Color(0xFFE0F2FE), onLayoutColor: Color(0xFF0C4A6E),
      backgroundColor: Color(0xFFF0F9FF), onBackgroundColor: Color(0xFF082F49),
      surfaceColor: Color(0xFFFFFFFF), onSurfaceColor: Color(0xFF075985),
      cardColor: Color(0xFFBAE6FD),
      primaryColor: Color(0xFF0284C7), onPrimaryColor: Color(0xFFFFFFFF),
      accentColor: Color(0xFF38BDF8),
      accentGradient: LinearGradient(colors: [Color(0xFF0369A1), Color(0xFF38BDF8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    ),
    
    const AppThemeModel(
      id: 'onyx_studio', name: 'Onyx Studio 💎', isDark: true,
      layoutColor: Color(0xFF050505), onLayoutColor: Color(0xFFE8E8E8),
      backgroundColor: Color(0xFF000000), onBackgroundColor: Color(0xFFF5F5F5),
      surfaceColor: Color(0xFF111111), onSurfaceColor: Color(0xFFDDDDDD),
      cardColor: Color(0xFF1E1E1E),
      primaryColor: Color(0xFFE8E8E8), onPrimaryColor: Color(0xFF000000),
      accentColor: Color(0xFFAAAAAA),
      accentGradient: LinearGradient(colors: [Color(0xFF888888), Color(0xFFE8E8E8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    ),
    
    const AppThemeModel(
      id: 'tropical_punch', name: 'Tropical 🍹', isDark: false,
      layoutColor: Color(0xFFFFE8F0), onLayoutColor: Color(0xFF831843),
      backgroundColor: Color(0xFFFFF0F5), onBackgroundColor: Color(0xFF4A0028),
      surfaceColor: Color(0xFFFFFFFF), onSurfaceColor: Color(0xFFBE185D),
      cardColor: Color(0xFFFFCCE0),
      primaryColor: Color(0xFFDB2777), onPrimaryColor: Color(0xFFFFFFFF),
      accentColor: Color(0xFFF472B6),
      accentGradient: LinearGradient(colors: [Color(0xFFEC4899), Color(0xFFF9A8D4)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    ),
    
    const AppThemeModel(
      id: 'midnight_navy', name: 'Midnight Navy 🌃', isDark: true,
      layoutColor: Color(0xFF030714), onLayoutColor: Color(0xFF7B9FCC),
      backgroundColor: Color(0xFF01030A), onBackgroundColor: Color(0xFFE8EEFF),
      surfaceColor: Color(0xFF091233), onSurfaceColor: Color(0xFFACC3E8),
      cardColor: Color(0xFF0E1C4A),
      primaryColor: Color(0xFF4C72B0), onPrimaryColor: Color(0xFFFFFFFF),
      accentColor: Color(0xFF7B9FCC),
      accentGradient: LinearGradient(colors: [Color(0xFF1E3A8A), Color(0xFF4C72B0)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    ),
    
    const AppThemeModel(
      id: 'lemon_zest', name: 'Lemon Zest 🍋', isDark: false,
      layoutColor: Color(0xFFFEF9C3), onLayoutColor: Color(0xFF713F12),
      backgroundColor: Color(0xFFFFFDE7), onBackgroundColor: Color(0xFF422006),
      surfaceColor: Color(0xFFFFFFFF), onSurfaceColor: Color(0xFF854D0E),
      cardColor: Color(0xFFFEF08A),
      primaryColor: Color(0xFFCA8A04), onPrimaryColor: Color(0xFFFFFFFF),
      accentColor: Color(0xFFEAB308),
      accentGradient: LinearGradient(colors: [Color(0xFFCA8A04), Color(0xFFFDE047)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    ),
    
    const AppThemeModel(
      id: 'carbon_fiber', name: 'Carbon Fiber 🖤', isDark: true,
      layoutColor: Color(0xFF0D0D0D), onLayoutColor: Color(0xFF04D9FF),
      backgroundColor: Color(0xFF060606), onBackgroundColor: Color(0xFFE8F8FF),
      surfaceColor: Color(0xFF141414), onSurfaceColor: Color(0xFFB0ECFF),
      cardColor: Color(0xFF1E1E1E),
      primaryColor: Color(0xFF04D9FF), onPrimaryColor: Color(0xFF060606),
      accentColor: Color(0xFF80EEFF),
      accentGradient: LinearGradient(colors: [Color(0xFF0099CC), Color(0xFF04D9FF)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    ),
    
    const AppThemeModel(
      id: 'holographic', name: 'Holographic 🌈', isDark: true,
      layoutColor: Color(0xFF050010), onLayoutColor: Color(0xFFB794F4),
      backgroundColor: Color(0xFF020008), onBackgroundColor: Color(0xFFF5F0FF),
      surfaceColor: Color(0xFF0D0028), onSurfaceColor: Color(0xFFCFBDFF),
      cardColor: Color(0xFF180040),
      primaryColor: Color(0xFF9F7AEA), onPrimaryColor: Color(0xFF050010),
      accentColor: Color(0xFF68D8D6),
      accentGradient: LinearGradient(colors: [Color(0xFF9F7AEA), Color(0xFF68D8D6)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    ),
    
    const AppThemeModel(
      id: 'moonstone', name: 'Moonstone 🌙', isDark: true,
      layoutColor: Color(0xFF07090F), onLayoutColor: Color(0xFFC8D8F0),
      backgroundColor: Color(0xFF030508), onBackgroundColor: Color(0xFFEDF2FF),
      surfaceColor: Color(0xFF101524), onSurfaceColor: Color(0xFFB3C6E8),
      cardColor: Color(0xFF182035),
      primaryColor: Color(0xFF8BA7CC), onPrimaryColor: Color(0xFF07090F),
      accentColor: Color(0xFFC8D8F0),
      accentGradient: LinearGradient(colors: [Color(0xFF4A6FA5), Color(0xFF8BA7CC)], begin: Alignment.topLeft, end: Alignment.bottomRight),
    ),
  ];

  static AppThemeModel getTheme(String id) {
    return themes.firstWhere((t) => t.id == id, orElse: () => themes[0]);
  }
}
