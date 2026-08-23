// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_account_receipts.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CustomerAccountReceiptsAdapter
    extends TypeAdapter<CustomerAccountReceipts> {
  @override
  final int typeId = 127;

  @override
  CustomerAccountReceipts read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CustomerAccountReceipts(
      uuid: fields[0] as String?,
      createdAt: fields[1] as DateTime?,
      shopId: fields[2] as int?,
      staffId: fields[3] as String?,
      staffName: fields[4] as String?,
      updatedAt: fields[7] as DateTime?,
      amount: fields[9] as double?,
      customerName: fields[6] as String?,
      customerUuid: fields[5] as String?,
      newBalance: fields[11] as double?,
      oldBalance: fields[10] as double?,
      isAdd: fields[12] as bool,
      comment: fields[13] as String?,
      title: fields[14] as String?,
      isBalance: fields[15] as bool?,
      receiptUuid: fields[16] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, CustomerAccountReceipts obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.uuid)
      ..writeByte(1)
      ..write(obj.createdAt)
      ..writeByte(2)
      ..write(obj.shopId)
      ..writeByte(3)
      ..write(obj.staffId)
      ..writeByte(4)
      ..write(obj.staffName)
      ..writeByte(5)
      ..write(obj.customerUuid)
      ..writeByte(6)
      ..write(obj.customerName)
      ..writeByte(7)
      ..write(obj.updatedAt)
      ..writeByte(9)
      ..write(obj.amount)
      ..writeByte(10)
      ..write(obj.oldBalance)
      ..writeByte(11)
      ..write(obj.newBalance)
      ..writeByte(12)
      ..write(obj.isAdd)
      ..writeByte(13)
      ..write(obj.comment)
      ..writeByte(14)
      ..write(obj.title)
      ..writeByte(15)
      ..write(obj.isBalance)
      ..writeByte(16)
      ..write(obj.receiptUuid);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomerAccountReceiptsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
