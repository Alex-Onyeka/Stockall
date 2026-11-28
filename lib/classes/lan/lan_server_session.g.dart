// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lan_server_session.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LanServerSessionAdapter extends TypeAdapter<LanServerSession> {
  @override
  final int typeId = 163;

  @override
  LanServerSession read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LanServerSession(
      tokenHash: fields[0] as String,
      shopId: fields[1] as int,
      userId: fields[2] as String,
      deviceId: fields[3] as String,
      createdAt: fields[4] as DateTime,
      expiresAt: fields[5] as DateTime,
      lastUsedAt: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, LanServerSession obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.tokenHash)
      ..writeByte(1)
      ..write(obj.shopId)
      ..writeByte(2)
      ..write(obj.userId)
      ..writeByte(3)
      ..write(obj.deviceId)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.expiresAt)
      ..writeByte(6)
      ..write(obj.lastUsedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LanServerSessionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
