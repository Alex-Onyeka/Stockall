// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lan_user_credential.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LanUserCredentialAdapter extends TypeAdapter<LanUserCredential> {
  @override
  final int typeId = 162;

  @override
  LanUserCredential read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LanUserCredential(
      shopId: fields[0] as int,
      userId: fields[1] as String,
      email: fields[2] as String,
      salt: fields[3] as String,
      hash: fields[4] as String,
      iterations: fields[5] as int,
      role: fields[6] as String,
      access: (fields[7] as List).cast<String>(),
      departmentUuids: (fields[8] as List).cast<String>(),
      isOwner: fields[9] as bool,
      profileJson: fields[10] as String,
      updatedAt: fields[11] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, LanUserCredential obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.shopId)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.email)
      ..writeByte(3)
      ..write(obj.salt)
      ..writeByte(4)
      ..write(obj.hash)
      ..writeByte(5)
      ..write(obj.iterations)
      ..writeByte(6)
      ..write(obj.role)
      ..writeByte(7)
      ..write(obj.access)
      ..writeByte(8)
      ..write(obj.departmentUuids)
      ..writeByte(9)
      ..write(obj.isOwner)
      ..writeByte(10)
      ..write(obj.profileJson)
      ..writeByte(11)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LanUserCredentialAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
