// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'continuous_print_docket.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ContinuousPrintDocketAdapter extends TypeAdapter<ContinuousPrintDocket> {
  @override
  final int typeId = 138;

  @override
  ContinuousPrintDocket read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ContinuousPrintDocket(
      id: fields[0] as int,
      isOn: fields[1] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ContinuousPrintDocket obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.isOn);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContinuousPrintDocketAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
