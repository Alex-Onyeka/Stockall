// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lan_paired_server.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LanPairedServerAdapter extends TypeAdapter<LanPairedServer> {
  @override
  final int typeId = 161;

  @override
  LanPairedServer read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LanPairedServer(
      serverDeviceId: fields[0] as String,
      certFingerprint: fields[1] as String,
      port: fields[2] as int,
      addresses: (fields[3] as List).cast<String>(),
      pairedAt: fields[4] as DateTime,
      label: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, LanPairedServer obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.serverDeviceId)
      ..writeByte(1)
      ..write(obj.certFingerprint)
      ..writeByte(2)
      ..write(obj.port)
      ..writeByte(3)
      ..write(obj.addresses)
      ..writeByte(4)
      ..write(obj.pairedAt)
      ..writeByte(5)
      ..write(obj.label);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LanPairedServerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
