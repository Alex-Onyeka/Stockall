// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deleted_customer_account_receipts.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DeletedCustomerAccountReceiptsAdapter
    extends TypeAdapter<DeletedCustomerAccountReceipts> {
  @override
  final int typeId = 129;

  @override
  DeletedCustomerAccountReceipts read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DeletedCustomerAccountReceipts(
      customerAccountReceiptUuid: fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, DeletedCustomerAccountReceipts obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.customerAccountReceiptUuid);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeletedCustomerAccountReceiptsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
