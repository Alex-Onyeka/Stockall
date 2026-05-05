// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'updated_waybills.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UpdatedWaybillsAdapter extends TypeAdapter<UpdatedWaybills> {
  @override
  final int typeId = 89;

  @override
  UpdatedWaybills read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UpdatedWaybills(
      waybill: fields[0] as TempWayBills,
    );
  }

  @override
  void write(BinaryWriter writer, UpdatedWaybills obj) {
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
      other is UpdatedWaybillsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
