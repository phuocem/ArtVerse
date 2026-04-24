import 'package:hive/hive.dart';
import 'drawn_line_model.dart';

part 'layer_model.g.dart';

@HiveType(typeId: 5)
class LayerModel extends HiveObject {
  @HiveField(0)
  List<DrawnLine> lines;
  @HiveField(1)
  String name;
  @HiveField(2)
  double opacity;
  @HiveField(3)
  bool isVisible;

  @HiveField(4, defaultValue: 3)
  int blendModeIndex;

  LayerModel({
    List<DrawnLine>? lines,
    this.name = "New Layer",
    this.opacity = 1.0,
    this.isVisible = true,
    this.blendModeIndex = 3, 
  }) : lines = lines ?? [];

  LayerModel copy() => LayerModel(
    lines: lines.map((line) => line.copy()).toList(),
    name: name,
    opacity: opacity,
    isVisible: isVisible,
    blendModeIndex: blendModeIndex,
  );

  factory LayerModel.fromJson(Map<String, dynamic> json) {
    return LayerModel(
      lines: _parseLines(json['lines']),
      name: (json['name'] ?? "New Layer").toString(),
      opacity: _parseDouble(json['opacity'], 1.0),
      isVisible: _parseBool(json['is_visible'] ?? json['isVisible']),
      blendModeIndex: _parseInt(json['blend_mode_index'] ?? json['blendModeIndex']) == 0 ? 3 : _parseInt(json['blend_mode_index'] ?? json['blendModeIndex']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 3;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 3;
    return 3;
  }

  static List<DrawnLine> _parseLines(dynamic lines) {
    if (lines == null) return [];
    if (lines is List) {
      return lines
          .map((line) => DrawnLine.fromJson(line as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  static double _parseDouble(dynamic value, double defaultValue) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  static bool _parseBool(dynamic value) {
    if (value == null) return true;
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    if (value is int) return value != 0;
    return true;
  }

  Map<String, dynamic> toJson() {
    return {
      'lines': lines.map((line) => line.toJson()).toList(),
      'name': name,
      'opacity': opacity,
      'is_visible': isVisible,
      'blend_mode_index': blendModeIndex,
    };
  }
}
