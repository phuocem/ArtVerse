import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

part 'drawn_line_model.g.dart';

@HiveType(typeId: 6)
enum BrushType {
  @HiveField(0)
  solid,
  @HiveField(1)
  airbrush,
  @HiveField(2)
  calligraphy,
  @HiveField(3)
  pen,
  @HiveField(4)
  pencil,
  @HiveField(5)
  marker,
  @HiveField(6)
  brush,
  @HiveField(7)
  watercolor,
  @HiveField(8)
  oil,
  @HiveField(9)
  charcoal,
  @HiveField(10)
  neon,
}

@HiveType(typeId: 7)
enum SymmetryType {
  @HiveField(0)
  none,
  @HiveField(1)
  vertical,
  @HiveField(2)
  horizontal,
  @HiveField(3)
  both,
  @HiveField(4)
  radial4,
  @HiveField(5)
  radial8,
}

@HiveType(typeId: 2)
class DrawnLine extends HiveObject {
  @HiveField(0)
  List<Offset> points;

  @HiveField(1)
  int colorValue;

  @HiveField(2)
  double width;

  @HiveField(3)
  BrushType brushType;

  @HiveField(4, defaultValue: 0.0)
  double scatter;

  @HiveField(5, defaultValue: 1.0)
  double hardness;

  @HiveField(6, defaultValue: 1.0)
  double opacity;

  @HiveField(7, defaultValue: 3)
  int blendModeIndex;

  @HiveField(8, defaultValue: 'none')
  String vfxType;

  @HiveField(9, defaultValue: false)
  bool isSmoothed;

  @HiveField(10)
  String? text;

  @HiveField(11, defaultValue: false)
  bool isFill;

  @HiveField(12, defaultValue: 10.0)
  double spacing;

  @HiveField(13, defaultValue: 0.0)
  double angle;

  DrawnLine({
    required this.points,
    required this.colorValue,
    required this.width,
    this.brushType = BrushType.solid,
    this.scatter = 0.0,
    this.hardness = 1.0,
    this.opacity = 1.0,
    this.blendModeIndex = 3, 
    this.vfxType = 'none',
    this.isSmoothed = false,
    this.text,
    this.isFill = false,
    this.spacing = 10.0,
    this.angle = 0.0,
  });

  BlendMode get blendMode => BlendMode.values[blendModeIndex];

  Path? _cachedPath;
  Path get path {
    if (_cachedPath != null) return _cachedPath!;
    final p = Path();
    if (points.isNotEmpty) {
      p.moveTo(points[0].dx, points[0].dy);
      for (int i = 1; i < points.length; i++) {
        p.lineTo(points[i].dx, points[i].dy);
      }
    }
    _cachedPath = p;
    return p;
  }

  void addPoint(Offset point) {
    points.add(point);
    _cachedPath = null;
  }

  void replacePoints(List<Offset> newPoints) {
    points = newPoints;
    _cachedPath = null;
  }

  Color get color => Color(colorValue).withValues(alpha: opacity);

  DrawnLine copy() => DrawnLine(
    points: List.from(points),
    colorValue: colorValue,
    width: width,
    brushType: brushType,
    scatter: scatter,
    hardness: hardness,
    opacity: opacity,
    blendModeIndex: blendModeIndex,
    vfxType: vfxType,
    isSmoothed: isSmoothed,
    text: text,
    isFill: isFill,
    spacing: spacing,
    angle: angle,
  );

  factory DrawnLine.fromJson(Map<String, dynamic> json) {
    return DrawnLine(
      points: _parsePoints(json['points']),
      colorValue: _parseInt(json['color_value'] ?? json['colorValue']),
      width: _parseDouble(json['width'], 2.0),
      brushType: BrushType.values.firstWhere(
        (e) => e.name == ((json['brush_type'] ?? json['brushType'])?.toString() ?? 'solid'),
        orElse: () => BrushType.solid,
      ),
      scatter: _parseDouble(json['scatter'], 0.0),
      hardness: _parseDouble(json['hardness'], 1.0),
      opacity: _parseDouble(json['opacity'], 1.0),
      blendModeIndex: _parseInt(json['blend_mode_index'] ?? json['blendModeIndex']) == 0 ? 3 : _parseInt(json['blend_mode_index'] ?? json['blendModeIndex']),
      vfxType: json['vfx_type'] ?? json['vfxType'] ?? 'none',
      isSmoothed: json['is_smoothed'] ?? json['isSmoothed'] ?? false,
      text: json['text'],
      isFill: json['is_fill'] ?? json['isFill'] ?? false,
      spacing: _parseDouble(json['spacing'], 10.0),
      angle: _parseDouble(json['angle'], 0.0),
    );
  }

  static List<Offset> _parsePoints(dynamic points) {
    if (points == null) return [];
    if (points is List) {
      return points.map((e) {
        if (e is List && e.length >= 2) {
          return Offset(_parseDouble(e[0], 0), _parseDouble(e[1], 0));
        }
        return Offset.zero;
      }).toList();
    }
    return [];
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0xFF000000;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0xFF000000;
    return 0xFF000000;
  }

  static double _parseDouble(dynamic value, double defaultValue) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  Map<String, dynamic> toJson() {
    return {
      'points': points.map((p) => [p.dx, p.dy]).toList(),
      'color_value': colorValue,
      'width': width,
      'brush_type': brushType.name,
      'scatter': scatter,
      'hardness': hardness,
      'opacity': opacity,
      'blend_mode_index': blendModeIndex,
      'vfx_type': vfxType,
      'is_smoothed': isSmoothed,
      'text': text,
      'is_fill': isFill,
      'spacing': spacing,
      'angle': angle,
    };
  }
}
