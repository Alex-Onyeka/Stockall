// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'updated_production_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UpdatedProductionRecordAdapter
    extends TypeAdapter<UpdatedProductionRecord> {
  @override
  final int typeId = 103;

  @override
  UpdatedProductionRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UpdatedProductionRecord(
      updatedProductionRecord: fields[0] as ProductionRecord,
    );
  }

  @override
  void write(BinaryWriter writer, UpdatedProductionRecord obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.updatedProductionRecord);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdatedProductionRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
