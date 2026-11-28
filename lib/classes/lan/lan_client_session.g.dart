// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lan_client_session.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LanClientSessionAdapter extends TypeAdapter<LanClientSession> {
  @override
  final int typeId = 164;

  @override
  LanClientSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LanClientSession(
      serverDeviceId: fields[0] as String,
      shopId: fields[1] as int,
      userId: fields[2] as String,
      token: fields[3] as String,
      expiresAt: fields[4] as DateTime,
      createdAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, LanClientSession obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.serverDeviceId)
      ..writeByte(1)
      ..write(obj.shopId)
      ..writeByte(2)
      ..write(obj.userId)
      ..writeByte(3)
      ..write(obj.token)
      ..writeByte(4)
      ..write(obj.expiresAt)
      ..writeByte(5)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LanClientSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
