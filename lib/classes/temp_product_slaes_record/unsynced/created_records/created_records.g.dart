// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'created_records.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CreatedRecordsAdapter extends TypeAdapter<CreatedRecords> {
  @override
  final int typeId = 20;

  @override
  CreatedRecords read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CreatedRecords(
      record: fields[0] as TempProductSaleRecord,
    );
  }

  @override
  void write(BinaryWriter writer, CreatedRecords obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.record);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreatedRecordsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
