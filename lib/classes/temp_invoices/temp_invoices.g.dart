// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'temp_invoices.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TempInvoiceAdapter extends TypeAdapter<TempInvoice> {
  @override
  final int typeId = 43;

  @override
  TempInvoice read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TempInvoice(
      id: fields[0] as int?,
      barcode: fields[1] as String?,
      createdAt: fields[2] as DateTime,
      shopId: fields[3] as int,
      staffId: fields[4] as String,
      staffName: fields[5] as String,
      customerName: fields[6] as String?,
      paymentMethod: fields[7] as String,
      bank: fields[9] as double,
      cashAlt: fields[8] as double,
      departmentName: fields[10] as String?,
      departmentUuid: fields[11] as int?,
      uuid: fields[12] as String?,
      customerUuid: fields[13] as String?,
      generalDiscount: fields[14] as double?,
      fixedDiscount: fields[15] as double?,
      vat: fields[16] as double?,
      originalCost: fields[17] as double?,
      updatedAt: fields[20] as DateTime?,
      subStaffUuid: fields[22] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TempInvoice obj) {
    writer
      ..writeByte(20)
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
      ..write(obj.customerName)
      ..writeByte(7)
      ..write(obj.paymentMethod)
      ..writeByte(8)
      ..write(obj.cashAlt)
      ..writeByte(9)
      ..write(obj.bank)
      ..writeByte(10)
      ..write(obj.departmentName)
      ..writeByte(11)
      ..write(obj.departmentUuid)
      ..writeByte(12)
      ..write(obj.uuid)
      ..writeByte(13)
      ..write(obj.customerUuid)
      ..writeByte(14)
      ..write(obj.generalDiscount)
      ..writeByte(15)
      ..write(obj.fixedDiscount)
      ..writeByte(16)
      ..write(obj.vat)
      ..writeByte(17)
      ..write(obj.originalCost)
      ..writeByte(20)
      ..write(obj.updatedAt)
      ..writeByte(22)
      ..write(obj.subStaffUuid);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TempInvoiceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
