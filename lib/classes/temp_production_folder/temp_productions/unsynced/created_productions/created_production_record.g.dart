// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'created_production_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CreatedProductionRecordAdapter
    extends TypeAdapter<CreatedProductionRecord> {
  @override
  final int typeId = 101;

  @override
  CreatedProductionRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CreatedProductionRecord(
      createdProductionRecord: fields[0] as ProductionRecord,
    );
  }

  @override
  void write(BinaryWriter writer, CreatedProductionRecord obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.createdProductionRecord);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreatedProductionRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
