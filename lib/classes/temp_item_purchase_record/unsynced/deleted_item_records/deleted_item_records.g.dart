// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deleted_item_records.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DeletedItemRecordsAdapter extends TypeAdapter<DeletedItemRecords> {
  @override
  final int typeId = 84;

  @override
  DeletedItemRecords read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DeletedItemRecords(
      recordUuid: fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, DeletedItemRecords obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.recordUuid);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeletedItemRecordsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
