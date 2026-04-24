import 'package:flutter/material.dart';

class LayerItem {
  final String name;
  final String subtitle;
  final String emoji;
  final Color iconBg;
  bool isActive;
  bool isVisible;
  bool isLocked;

  LayerItem({
    required this.name,
    required this.subtitle,
    required this.emoji,
    required this.iconBg,
    this.isActive = false,
    this.isVisible = true,
    this.isLocked = false,
  });
}

class BrushTool {
  final String name;
  final String emoji;
  BrushTool({required this.name, required this.emoji});
}

final brushTools = [
  BrushTool(name: 'Bút chì', emoji: '✏️'),
  BrushTool(name: 'Bút sắt', emoji: '✒️'),
  BrushTool(name: 'Cọ dầu', emoji: '🖌️'),
  BrushTool(name: 'Phun sơn', emoji: '💨'),
  BrushTool(name: 'Tẩy', emoji: '🧽'),
];

final swatchColors = [
  const Color(0xFF6B4EFF),
  const Color(0xFFFF4D8A),
  const Color(0xFF00CFA8),
  const Color(0xFFFF9F3C),
  const Color(0xFF3B9EFF),
  const Color(0xFFFFFFFF),
];
