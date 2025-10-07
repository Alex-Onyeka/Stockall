// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'updated_receipts.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UpdatedReceiptsAdapter extends TypeAdapter<UpdatedReceipts> {
  @override
  final int typeId = 25;

  @override
  UpdatedReceipts read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UpdatedReceipts(
      receiptUuid: fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, UpdatedReceipts obj) {
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
      other is UpdatedReceiptsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
