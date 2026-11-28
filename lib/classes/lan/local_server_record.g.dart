// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_server_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LocalServerRecordAdapter extends TypeAdapter<LocalServerRecord> {
  @override
  final int typeId = 160;

  @override
  LocalServerRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LocalServerRecord(
      shopId: fields[0] as int,
      epoch: fields[1] as int,
      serverDeviceId: fields[2] as String?,
      claimedAt: fields[3] as DateTime?,
      claimedByUserId: fields[4] as String?,
      certFingerprint: fields[5] as String?,
      lastKnownAddresses: (fields[6] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, LocalServerRecord obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.shopId)
      ..writeByte(1)
      ..write(obj.epoch)
      ..writeByte(2)
      ..write(obj.serverDeviceId)
      ..writeByte(3)
      ..write(obj.claimedAt)
      ..writeByte(4)
      ..write(obj.claimedByUserId)
      ..writeByte(5)
      ..write(obj.certFingerprint)
      ..writeByte(6)
      ..write(obj.lastKnownAddresses);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocalServerRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
