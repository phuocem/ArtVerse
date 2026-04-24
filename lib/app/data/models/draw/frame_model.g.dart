

part of 'frame_model.dart';





class FrameModelAdapter extends TypeAdapter<FrameModel> {
  @override
  final int typeId = 4;

  @override
  FrameModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FrameModel(
      isHidden: fields[1] as bool,
    )..layers = (fields[0] as List).cast<LayerModel>();
  }

  @override
  void write(BinaryWriter writer, FrameModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.layers)
      ..writeByte(1)
      ..write(obj.isHidden);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FrameModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
