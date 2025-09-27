// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deleted_receipts.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DeletedReceiptsAdapter extends TypeAdapter<DeletedReceipts> {
  @override
  final int typeId = 24;

  @override
  DeletedReceipts read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DeletedReceipts(
      receiptUuid: fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, DeletedReceipts obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.receiptUuid);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeletedReceiptsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
