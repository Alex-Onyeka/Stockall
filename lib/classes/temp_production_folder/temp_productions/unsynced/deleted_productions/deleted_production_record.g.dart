// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deleted_production_record.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DeletedProductionRecordAdapter
    extends TypeAdapter<DeletedProductionRecord> {
  @override
  final int typeId = 102;

  @override
  DeletedProductionRecord read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DeletedProductionRecord(
      productionRecordUuid: fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, DeletedProductionRecord obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.productionRecordUuid);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeletedProductionRecordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
