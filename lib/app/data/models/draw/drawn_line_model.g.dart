

part of 'drawn_line_model.dart';





class DrawnLineAdapter extends TypeAdapter<DrawnLine> {
  @override
  final int typeId = 2;

  @override
  DrawnLine read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DrawnLine(
      points: (fields[0] as List).cast<Offset>(),
      colorValue: fields[1] as int,
      width: fields[2] as double,
      brushType: fields[3] as BrushType,
      scatter: fields[4] == null ? 0.0 : fields[4] as double,
      hardness: fields[5] == null ? 1.0 : fields[5] as double,
      opacity: fields[6] == null ? 1.0 : fields[6] as double,
      blendModeIndex: fields[7] == null ? 3 : fields[7] as int,
      vfxType: fields[8] == null ? 'none' : fields[8] as String,
      isSmoothed: fields[9] == null ? false : fields[9] as bool,
      text: fields[10] as String?,
      isFill: fields[11] == null ? false : fields[11] as bool,
      spacing: fields[12] == null ? 10.0 : fields[12] as double,
      angle: fields[13] == null ? 0.0 : fields[13] as double,
    );
  }

  @override
  void write(BinaryWriter writer, DrawnLine obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.points)
      ..writeByte(1)
      ..write(obj.colorValue)
      ..writeByte(2)
      ..write(obj.width)
      ..writeByte(3)
      ..write(obj.brushType)
      ..writeByte(4)
      ..write(obj.scatter)
      ..writeByte(5)
      ..write(obj.hardness)
      ..writeByte(6)
      ..write(obj.opacity)
      ..writeByte(7)
      ..write(obj.blendModeIndex)
      ..writeByte(8)
      ..write(obj.vfxType)
      ..writeByte(9)
      ..write(obj.isSmoothed)
      ..writeByte(10)
      ..write(obj.text)
      ..writeByte(11)
      ..write(obj.isFill)
      ..writeByte(12)
      ..write(obj.spacing)
      ..writeByte(13)
      ..write(obj.angle);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DrawnLineAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BrushTypeAdapter extends TypeAdapter<BrushType> {
  @override
  final int typeId = 6;

  @override
  BrushType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return BrushType.solid;
      case 1:
        return BrushType.airbrush;
      case 2:
        return BrushType.calligraphy;
      case 3:
        return BrushType.pen;
      case 4:
        return BrushType.pencil;
      case 5:
        return BrushType.marker;
      case 6:
        return BrushType.brush;
      case 7:
        return BrushType.watercolor;
      case 8:
        return BrushType.oil;
      case 9:
        return BrushType.charcoal;
      case 10:
        return BrushType.neon;
      default:
        return BrushType.solid;
    }
  }

  @override
  void write(BinaryWriter writer, BrushType obj) {
    switch (obj) {
      case BrushType.solid:
        writer.writeByte(0);
        break;
      case BrushType.airbrush:
        writer.writeByte(1);
        break;
      case BrushType.calligraphy:
        writer.writeByte(2);
        break;
      case BrushType.pen:
        writer.writeByte(3);
        break;
      case BrushType.pencil:
        writer.writeByte(4);
        break;
      case BrushType.marker:
        writer.writeByte(5);
        break;
      case BrushType.brush:
        writer.writeByte(6);
        break;
      case BrushType.watercolor:
        writer.writeByte(7);
        break;
      case BrushType.oil:
        writer.writeByte(8);
        break;
      case BrushType.charcoal:
        writer.writeByte(9);
        break;
      case BrushType.neon:
        writer.writeByte(10);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BrushTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SymmetryTypeAdapter extends TypeAdapter<SymmetryType> {
  @override
  final int typeId = 7;

  @override
  SymmetryType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SymmetryType.none;
      case 1:
        return SymmetryType.vertical;
      case 2:
        return SymmetryType.horizontal;
      case 3:
        return SymmetryType.both;
      case 4:
        return SymmetryType.radial4;
      case 5:
        return SymmetryType.radial8;
      default:
        return SymmetryType.none;
    }
  }

  @override
  void write(BinaryWriter writer, SymmetryType obj) {
    switch (obj) {
      case SymmetryType.none:
        writer.writeByte(0);
        break;
      case SymmetryType.vertical:
        writer.writeByte(1);
        break;
      case SymmetryType.horizontal:
        writer.writeByte(2);
        break;
      case SymmetryType.both:
        writer.writeByte(3);
        break;
      case SymmetryType.radial4:
        writer.writeByte(4);
        break;
      case SymmetryType.radial8:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SymmetryTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
