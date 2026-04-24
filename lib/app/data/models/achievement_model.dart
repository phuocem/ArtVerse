import 'package:flutter/material.dart';

class AchievementModel {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;
  final bool isUnlocked;

  AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.gradientColors,
    required this.isUnlocked,
  });
}
