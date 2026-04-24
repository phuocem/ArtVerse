import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';
import 'frame_model.dart';

part 'draw_project_model.g.dart';

@HiveType(typeId: 3)
class DrawProjectModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  DateTime updatedAt;

  @HiveField(3)
  List<FrameModel> frames;

  @HiveField(4, defaultValue: false)
  bool isAnimation;

  @HiveField(5, defaultValue: false)
  bool isFavorite;

  DrawProjectModel({
    required this.id,
    required this.name,
    required this.updatedAt,
    required this.frames,
    this.isAnimation = false,
    this.isFavorite = false,
  });

  
  factory DrawProjectModel.fromJson(Map<String, dynamic> json) {
    return DrawProjectModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      updatedAt:
          (json['updated_at'] ?? json['updatedAt']) != null
              ? DateTime.parse((json['updated_at'] ?? json['updatedAt']).toString())
              : DateTime.now(),
      frames: _parseFrames(json['frames']),
      isAnimation: _parseBool(json['is_animation'] ?? json['isAnimation']),
      isFavorite: _parseBool(json['is_favorite'] ?? json['isFavorite']),
    );
  }

  
  static DrawProjectModel _isolateParser(Map<String, dynamic> json) => DrawProjectModel.fromJson(json);

  static Future<DrawProjectModel> fromJsonAsync(Map<String, dynamic> json) async {
    return await compute(_isolateParser, json);
  }

  static List<FrameModel> _parseFrames(dynamic frames) {
    if (frames == null) return [];
    if (frames is List) {
      return frames
          .map((e) => FrameModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    if (value is int) return value != 0;
    return false;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'updated_at': updatedAt.toIso8601String(),
      'frames': frames.map((e) => e.toJson()).toList(),
      'is_animation': isAnimation,
      'is_favorite': isFavorite,
    };
  }
}
