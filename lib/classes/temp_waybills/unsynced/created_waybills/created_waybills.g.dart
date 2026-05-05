// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'created_waybills.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CreatedWaybillsAdapter extends TypeAdapter<CreatedWaybills> {
  @override
  final int typeId = 87;

  @override
  CreatedWaybills read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CreatedWaybills(
      waybill: fields[0] as TempWayBills,
    );
  }

  @override
  void write(BinaryWriter writer, CreatedWaybills obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.waybill);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreatedWaybillsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
