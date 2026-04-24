import 'package:flutter/material.dart';

class ResponsiveUtils {
  static const double tabletMinWidth = 600;
  static const double tabletMaxWidth = 1200;

  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.shortestSide >= tabletMinWidth;
  }

  static double getResponsiveWidth(
    BuildContext context, {
    required double mobile,
    required double tablet,
  }) {
    return isTablet(context) ? tablet : mobile;
  }

  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1024) return baseSize * 1.2;
    if (width >= 768) return baseSize * 1.1;
    return baseSize;
  }

  static EdgeInsets getResponsivePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1024) return const EdgeInsets.all(32);
    if (width >= 768) return const EdgeInsets.all(24);
    return const EdgeInsets.all(16);
  }

  static int getGridCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1400) return 6;
    if (width >= 1200) return 5;
    if (width >= 1024) return 4;
    if (width >= 768) return 3;
    return 2;
  }

  static double getGridSpacing(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1024) return 24;
    if (width >= 768) return 20;
    return 16;
  }

  static bool isLargeTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1024;
  }

  static bool isMediumTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= 768 &&
        MediaQuery.of(context).size.width < 1024;
  }

  static bool isSmallTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= 600 &&
        MediaQuery.of(context).size.width < 768;
  }
}


extension ResponsiveExtension on BuildContext {
  bool get isTablet => ResponsiveUtils.isTablet(this);

  double responsiveFontSize(double baseSize) =>
      ResponsiveUtils.getResponsiveFontSize(this, baseSize);

  EdgeInsets get responsivePadding =>
      ResponsiveUtils.getResponsivePadding(this);

  int get gridCrossAxisCount => ResponsiveUtils.getGridCrossAxisCount(this);

  double get gridSpacing => ResponsiveUtils.getGridSpacing(this);
}
