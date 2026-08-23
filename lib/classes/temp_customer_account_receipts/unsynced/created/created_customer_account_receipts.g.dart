// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'created_customer_account_receipts.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CreatedCustomerAccountReceiptsAdapter
    extends TypeAdapter<CreatedCustomerAccountReceipts> {
  @override
  final int typeId = 128;

  @override
  CreatedCustomerAccountReceipts read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CreatedCustomerAccountReceipts(
      createdCustomerAccountReceipts: fields[0] as CustomerAccountReceipts,
    );
  }

  @override
  void write(BinaryWriter writer, CreatedCustomerAccountReceipts obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.createdCustomerAccountReceipts);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreatedCustomerAccountReceiptsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
