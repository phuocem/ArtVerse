import 'package:hive/hive.dart';
import 'layer_model.dart';

part 'frame_model.g.dart';

@HiveType(typeId: 4)
class FrameModel extends HiveObject {
  @HiveField(0)
  List<LayerModel> layers;

  @HiveField(1)
  bool isHidden; 

  FrameModel({
    int numberOfLayers = 3,
    this.isHidden = false, 
  }) : layers = List.generate(numberOfLayers, (_) => LayerModel());

  FrameModel.copyFrom(this.layers, {this.isHidden = false});

  FrameModel copy() => FrameModel.copyFrom(
    layers.map((layer) => layer.copy()).toList(),
    isHidden: isHidden, 
  );

  factory FrameModel.fromJson(Map<String, dynamic> json) {
    return FrameModel.copyFrom(
      _parseLayers(json['layers']),
      isHidden: _parseBool(json['is_hidden'] ?? json['isHidden']),
    );
  }

  static List<LayerModel> _parseLayers(dynamic layers) {
    if (layers == null) return [];
    if (layers is List) {
      return layers
          .map((layer) => LayerModel.fromJson(layer as Map<String, dynamic>))
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
      'layers': layers.map((layer) => layer.toJson()).toList(),
      'is_hidden': isHidden,
    };
  }
}
