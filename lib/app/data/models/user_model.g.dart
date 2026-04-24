

part of 'user_model.dart';





class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 0;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel(
      id: fields[0] as String?,
      createdAt: fields[1] as DateTime,
      editedAt: fields[2] as DateTime,
      name: fields[3] as String,
      bio: fields[4] as String,
      email: fields[5] as String,
      avatarUrl: fields[6] as String?,
      followersCount: fields[7] as int,
      followingCount: fields[8] as int,
      location: fields[9] as String?,
      website: fields[10] as String?,
      instagramUrl: fields[11] as String?,
      twitterUrl: fields[12] as String?,
      isPro: fields[13] as bool,
      balance: fields[14] as double,
      likesCount: fields[15] as int,
      viewsCount: fields[16] as int,
      isVerified: fields[17] == null ? false : fields[17] as bool,
      specialties: (fields[18] as List?)?.cast<String>(),
      tools: (fields[19] as List?)
          ?.map((dynamic e) => (e as Map).cast<String, dynamic>())
          ?.toList(),
      handle: fields[20] as String?,
      selectedFrame: fields[21] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(22)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.createdAt)
      ..writeByte(2)
      ..write(obj.editedAt)
      ..writeByte(3)
      ..write(obj.name)
      ..writeByte(4)
      ..write(obj.bio)
      ..writeByte(5)
      ..write(obj.email)
      ..writeByte(6)
      ..write(obj.avatarUrl)
      ..writeByte(7)
      ..write(obj.followersCount)
      ..writeByte(8)
      ..write(obj.followingCount)
      ..writeByte(9)
      ..write(obj.location)
      ..writeByte(10)
      ..write(obj.website)
      ..writeByte(11)
      ..write(obj.instagramUrl)
      ..writeByte(12)
      ..write(obj.twitterUrl)
      ..writeByte(13)
      ..write(obj.isPro)
      ..writeByte(14)
      ..write(obj.balance)
      ..writeByte(15)
      ..write(obj.likesCount)
      ..writeByte(16)
      ..write(obj.viewsCount)
      ..writeByte(17)
      ..write(obj.isVerified)
      ..writeByte(18)
      ..write(obj.specialties)
      ..writeByte(19)
      ..write(obj.tools)
      ..writeByte(20)
      ..write(obj.handle)
      ..writeByte(21)
      ..write(obj.selectedFrame);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
