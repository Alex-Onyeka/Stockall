// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_version.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppVersionAdapter extends TypeAdapter<AppVersion> {
  @override
  final int typeId = 32;

  @override
  AppVersion read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++)
        reader.readByte(): reader.read(),
    };
    return AppVersion(
      id: fields[0] as int,
      mobileVersion: fields[1] as String,
      desktopVersion: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AppVersion obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.mobileVersion)
      ..writeByte(2)
      ..write(obj.desktopVersion);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppVersionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
