import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff006782),
      surfaceTint: Color(0xff006782),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xffbce9ff),
      onPrimaryContainer: Color(0xff001f29),
      secondary: Color(0xff4c626b),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffcfe6f1),
      onSecondaryContainer: Color(0xff071e26),
      tertiary: Color(0xff5a5b7d),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffe0e0ff),
      onTertiaryContainer: Color(0xff171837),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff410002),
      surface: Color(0xfff5fafd),
      onSurface: Color(0xff171c1f),
      onSurfaceVariant: Color(0xff40484c),
      outline: Color(0xff70787d),
      outlineVariant: Color(0xffbfc8cc),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2c3134),
      inversePrimary: Color(0xff86d1ee),
      primaryFixed: Color(0xffbce9ff),
      onPrimaryFixed: Color(0xff001f29),
      primaryFixedDim: Color(0xff86d1ee),
      onPrimaryFixedVariant: Color(0xff004d63),
      secondaryFixed: Color(0xffcfe6f1),
      onSecondaryFixed: Color(0xff071e26),
      secondaryFixedDim: Color(0xffb3cad5),
      onSecondaryFixedVariant: Color(0xff354a53),
      tertiaryFixed: Color(0xffe0e0ff),
      onTertiaryFixed: Color(0xff171837),
      tertiaryFixedDim: Color(0xffc3c3eb),
      onTertiaryFixedVariant: Color(0xff424365),
      surfaceDim: Color(0xffd5dadc),
      surfaceBright: Color(0xfff5fafd),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xffeff4f7),
      surfaceContainer: Color(0xffe9eff2),
      surfaceContainerHigh: Color(0xffe3e9ec),
      surfaceContainerHighest: Color(0xffdee3e6),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff303066),
      surfaceTint: Color(0xff595992),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff6767a1),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff353448),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff6c6b81),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff4d2b40),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff896178),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff740006),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffcf2c27),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffcf8ff),
      onSurface: Color(0xff111116),
      onSurfaceVariant: Color(0xff36353e),
      outline: Color(0xff52515b),
      outlineVariant: Color(0xff6d6c75),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff303036),
      inversePrimary: Color(0xffc2c1ff),
      primaryFixed: Color(0xff6767a1),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff4f4f87),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff6c6b81),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff535368),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff896178),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff6f495f),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffc8c5cd),
      surfaceBright: Color(0xfffcf8ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff6f2fa),
      surfaceContainer: Color(0xffeae7ef),
      surfaceContainerHigh: Color(0xffdfdbe3),
      surfaceContainerHighest: Color(0xffd3d0d8),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff26255c),
      surfaceTint: Color(0xff595992),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff43437b),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff2b2a3d),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff48475b),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff422235),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff623e53),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff600004),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff98000a),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffcf8ff),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000),
      outline: Color(0xff2c2b34),
      outlineVariant: Color(0xff494851),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff303036),
      inversePrimary: Color(0xffc2c1ff),
      primaryFixed: Color(0xff43437b),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff2c2c63),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff48475b),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff313144),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff623e53),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff49283c),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffbab7bf),
      surfaceBright: Color(0xfffcf8ff),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff3eff7),
      surfaceContainer: Color(0xffe4e1e9),
      surfaceContainerHigh: Color(0xffd6d3db),
      surfaceContainerHighest: Color(0xffc8c5cd),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffffb499),
      surfaceTint: Color(0xffffb499),
      onPrimary: Color(0xff561f00),
      primaryContainer: Color(0xff7a3000),
      onPrimaryContainer: Color(0xffffdbcd),
      secondary: Color(0xffe7bdb1),
      onSecondary: Color(0xff442a22),
      secondaryContainer: Color(0xff5d4037),
      onSecondaryContainer: Color(0xffffdbd1),
      tertiary: Color(0xffd7c48c),
      onTertiary: Color(0xff3a3005),
      tertiaryContainer: Color(0xff52461a),
      onTertiaryContainer: Color(0xfff4e0a6),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff130f0e),
      onSurface: Color(0xfff0dfdb),
      onSurfaceVariant: Color(0xffd8c2bb),
      outline: Color(0xffa08d87),
      outlineVariant: Color(0xff53433f),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xfff0dfdb),
      inversePrimary: Color(0xffa73500),
      primaryFixed: Color(0xffffdbcd),
      onPrimaryFixed: Color(0xff350a00),
      primaryFixedDim: Color(0xffffb499),
      onPrimaryFixedVariant: Color(0xff7a3000),
      secondaryFixed: Color(0xffffdbd1),
      onSecondaryFixed: Color(0xff2c150f),
      secondaryFixedDim: Color(0xffe7bdb1),
      onSecondaryFixedVariant: Color(0xff5d4037),
      tertiaryFixed: Color(0xfff4e0a6),
      onTertiaryFixed: Color(0xff231b00),
      tertiaryFixedDim: Color(0xffd7c48c),
      onTertiaryFixedVariant: Color(0xff52461a),
      surfaceDim: Color(0xff1b110f),
      surfaceBright: Color(0xff423734),
      surfaceContainerLowest: Color(0xff130f0e),
      surfaceContainerLow: Color(0xff241a17),
      surfaceContainer: Color(0xff281e1b),
      surfaceContainerHigh: Color(0xff332825),
      surfaceContainerHighest: Color(0xff3e3330),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffdbd9ff),
      surfaceTint: Color(0xffc2c1ff),
      onPrimary: Color(0xff1f1f55),
      primaryContainer: Color(0xff8b8bc8),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xffdcdaf3),
      onSecondary: Color(0xff242436),
      secondaryContainer: Color(0xff908ea5),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xffffcfe8),
      onTertiary: Color(0xff3a1b2f),
      tertiaryContainer: Color(0xffb0849c),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffd2cc),
      onError: Color(0xff540003),
      errorContainer: Color(0xffff5449),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff131318),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffdedbe6),
      outline: Color(0xffb3b0bb),
      outlineVariant: Color(0xff918f99),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe4e1e9),
      inversePrimary: Color(0xff424279),
      primaryFixed: Color(0xffe2dfff),
      onPrimaryFixed: Color(0xff090640),
      primaryFixedDim: Color(0xffc2c1ff),
      onPrimaryFixedVariant: Color(0xff303066),
      secondaryFixed: Color(0xffe2e0f9),
      onSecondaryFixed: Color(0xff0f0f21),
      secondaryFixedDim: Color(0xffc6c4dd),
      onSecondaryFixedVariant: Color(0xff353448),
      tertiaryFixed: Color(0xffffd8eb),
      onTertiaryFixed: Color(0xff220719),
      tertiaryFixedDim: Color(0xffe9b9d2),
      onTertiaryFixedVariant: Color(0xff4d2b40),
      surfaceDim: Color(0xff131318),
      surfaceBright: Color(0xff45444a),
      surfaceContainerLowest: Color(0xff07070c),
      surfaceContainerLow: Color(0xff1d1d23),
      surfaceContainer: Color(0xff28272d),
      surfaceContainerHigh: Color(0xff333238),
      surfaceContainerHighest: Color(0xff3e3d43),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xfff1eeff),
      surfaceTint: Color(0xffc2c1ff),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xffbdbdfd),
      onPrimaryContainer: Color(0xff03003b),
      secondary: Color(0xfff1eeff),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xffc2c0d9),
      onSecondaryContainer: Color(0xff09091b),
      tertiary: Color(0xffffebf3),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xffe5b5ce),
      onTertiaryContainer: Color(0xff1b0313),
      error: Color(0xffffece9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffaea4),
      onErrorContainer: Color(0xff220001),
      surface: Color(0xff131318),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xfff2eefa),
      outlineVariant: Color(0xffc4c1cc),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe4e1e9),
      inversePrimary: Color(0xff424279),
      primaryFixed: Color(0xffe2dfff),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xffc2c1ff),
      onPrimaryFixedVariant: Color(0xff090640),
      secondaryFixed: Color(0xffe2e0f9),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffc6c4dd),
      onSecondaryFixedVariant: Color(0xff0f0f21),
      tertiaryFixed: Color(0xffffd8eb),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xffe9b9d2),
      onTertiaryFixedVariant: Color(0xff220719),
      surfaceDim: Color(0xff131318),
      surfaceBright: Color(0xff504f56),
      surfaceContainerLowest: Color(0xff000000),
      surfaceContainerLow: Color(0xff1f1f25),
      surfaceContainer: Color(0xff303036),
      surfaceContainerHigh: Color(0xff3c3b41),
      surfaceContainerHighest: Color(0xff47464c),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }

  ThemeData theme(ColorScheme colorScheme) => ThemeData(
    useMaterial3: true,
    brightness: colorScheme.brightness,
    colorScheme: colorScheme,
    fontFamily: 'Plus Jakarta Sans',
    textTheme: textTheme.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
      fontFamily: 'Plus Jakarta Sans',
    ),
    scaffoldBackgroundColor: Colors.transparent,
    canvasColor: colorScheme.surface,
    visualDensity: VisualDensity.standard,
    
    
    cardTheme: CardThemeData(
      elevation: 0,
      color: colorScheme.surface.withValues(alpha: 0.6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), 
        side: BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.1)),
      ),
      clipBehavior: Clip.antiAlias,
    ),
    
    
    appBarTheme: AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      foregroundColor: colorScheme.onSurface,
      titleTextStyle: TextStyle(
        fontFamily: 'Plus Jakarta Sans', 
        fontSize: 22,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        color: colorScheme.onSurface,
      ),
    ),
    
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
        shape: const StadiumBorder(),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
        shape: const StadiumBorder(),
      ),
    ),
    
    
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surface.withValues(alpha: 0.8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.outline.withValues(alpha: 0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    ),
    
    
    dialogTheme: DialogThemeData(
      backgroundColor: colorScheme.surface.withValues(alpha: 0.8),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      titleTextStyle: TextStyle(
        fontFamily: 'Lexend',
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: colorScheme.onSurface,
      ),
    ),
  );

  List<ExtendedColor> get extendedColors => [];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
