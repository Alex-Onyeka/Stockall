// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'updated_customer_account_receipts.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UpdatedCustomerAccountReceiptsAdapter
    extends TypeAdapter<UpdatedCustomerAccountReceipts> {
  @override
  final int typeId = 130;

  @override
  UpdatedCustomerAccountReceipts read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UpdatedCustomerAccountReceipts(
      updatedCustomerAccountReceipts: fields[0] as CustomerAccountReceipts,
    );
  }

  @override
  void write(BinaryWriter writer, UpdatedCustomerAccountReceipts obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.updatedCustomerAccountReceipts);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdatedCustomerAccountReceiptsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
