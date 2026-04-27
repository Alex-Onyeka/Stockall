// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'created_item_records.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CreatedItemRecordsAdapter extends TypeAdapter<CreatedItemRecords> {
  @override
  final int typeId = 78;

  @override
  CreatedItemRecords read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CreatedItemRecords(
      record: fields[0] as TempItemPurchaseRecord,
    );
  }

  @override
  void write(BinaryWriter writer, CreatedItemRecords obj) {
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
      other is CreatedItemRecordsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
