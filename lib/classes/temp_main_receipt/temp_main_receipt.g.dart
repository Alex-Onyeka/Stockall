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
      departmentUuid: fields[12] as int?,
      isInvoice: fields[13] as bool,
      uuid: fields[14] as String?,
      customerUuid: fields[15] as String?,
      generalDiscount: fields[16] as double?,
      fixedDiscount: fields[17] as double?,
      vat: fields[18] as double?,
      originalCost: fields[19] as double?,
      invoiceUuid: fields[20] as String?,
      balance: fields[21] as double?,
      subStaffUuid: fields[22] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TempMainReceipt obj) {
    writer
      ..writeByte(23)
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
      ..write(obj.departmentUuid)
      ..writeByte(13)
      ..write(obj.isInvoice)
      ..writeByte(14)
      ..write(obj.uuid)
      ..writeByte(15)
      ..write(obj.customerUuid)
      ..writeByte(16)
      ..write(obj.generalDiscount)
      ..writeByte(17)
      ..write(obj.fixedDiscount)
      ..writeByte(18)
      ..write(obj.vat)
      ..writeByte(19)
      ..write(obj.originalCost)
      ..writeByte(20)
      ..write(obj.invoiceUuid)
      ..writeByte(21)
      ..write(obj.balance)
      ..writeByte(22)
      ..write(obj.subStaffUuid);
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
