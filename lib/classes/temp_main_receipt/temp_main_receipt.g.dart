// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'temp_main_receipt.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TempMainReceiptAdapter extends TypeAdapter<TempMainReceipt> {
  @override
  final int typeId = 3;

  @override
  TempMainReceipt read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TempMainReceipt(
      id: fields[0] as int?,
      barcode: fields[1] as String?,
      createdAt: fields[2] as DateTime,
      shopId: fields[3] as int,
      staffId: fields[4] as String,
      staffName: fields[5] as String,
      customerId: fields[6] as int?,
      customerName: fields[7] as String?,
      paymentMethod: fields[8] as String,
      bank: fields[10] as double,
      cashAlt: fields[9] as double,
      departmentName: fields[11] as String?,
      departmentId: fields[12] as int?,
      isInvoice: fields[13] as bool,
      uuid: fields[14] as String?,
      customerUuid: fields[15] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TempMainReceipt obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.barcode)
      ..writeByte(2)
      ..write(obj.createdAt)
      ..writeByte(3)
      ..write(obj.shopId)
      ..writeByte(4)
      ..write(obj.staffId)
      ..writeByte(5)
      ..write(obj.staffName)
      ..writeByte(6)
      ..write(obj.customerId)
      ..writeByte(7)
      ..write(obj.customerName)
      ..writeByte(8)
      ..write(obj.paymentMethod)
      ..writeByte(9)
      ..write(obj.cashAlt)
      ..writeByte(10)
      ..write(obj.bank)
      ..writeByte(11)
      ..write(obj.departmentName)
      ..writeByte(12)
      ..write(obj.departmentId)
      ..writeByte(13)
      ..write(obj.isInvoice)
      ..writeByte(14)
      ..write(obj.uuid)
      ..writeByte(15)
      ..write(obj.customerUuid);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TempMainReceiptAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
