

part of 'layer_model.dart';





class LayerModelAdapter extends TypeAdapter<LayerModel> {
  @override
  final int typeId = 5;

  @override
  LayerModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LayerModel(
      lines: (fields[0] as List?)?.cast<DrawnLine>(),
      name: fields[1] as String,
      opacity: fields[2] as double,
      isVisible: fields[3] as bool,
      blendModeIndex: fields[4] == null ? 3 : fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, LayerModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.lines)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.opacity)
      ..writeByte(3)
      ..write(obj.isVisible)
      ..writeByte(4)
      ..write(obj.blendModeIndex);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LayerModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
