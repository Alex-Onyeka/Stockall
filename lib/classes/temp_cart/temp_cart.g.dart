// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'temp_cart.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TempCartAdapter extends TypeAdapter<TempCart> {
  @override
  final int typeId = 71;

  @override
  TempCart read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TempCart(
      cartItems: (fields[0] as List).cast<TempCartItem>(),
      isInvoice: fields[2] as bool,
      id: fields[1] as String?,
      selectedCustomer: fields[3] as String?,
      selectedCustomerName: fields[4] as String?,
      paymentMethod: fields[5] as int,
      discount: fields[6] as double?,
      isSettingDiscountOpen: fields[13] as bool,
      isReceiptEdit: fields[7] as bool,
      receiptUuidEdit: fields[8] as String?,
      invoiceUuidEdit: fields[9] as String?,
      setCustomPrice: fields[11] as bool,
      createdDate: fields[10] as DateTime?,
      fixedDiscount: fields[12] as double?,
      cartName: fields[14] as String?,
      subStaffUuid: fields[15] as String?,
      staffName: fields[16] as String?,
      staffId: fields[17] as String?,
      departmentName: fields[19] as String?,
      departmentUuid: fields[18] as String?,
      customDate: fields[20] as DateTime?,
      hasPrintedDocket: fields[21] as bool?,
      subStaffName: fields[22] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TempCart obj) {
    writer
      ..writeByte(23)
      ..writeByte(0)
      ..write(obj.cartItems)
      ..writeByte(1)
      ..write(obj.id)
      ..writeByte(2)
      ..write(obj.isInvoice)
      ..writeByte(3)
      ..write(obj.selectedCustomer)
      ..writeByte(4)
      ..write(obj.selectedCustomerName)
      ..writeByte(5)
      ..write(obj.paymentMethod)
      ..writeByte(6)
      ..write(obj.discount)
      ..writeByte(7)
      ..write(obj.isReceiptEdit)
      ..writeByte(8)
      ..write(obj.receiptUuidEdit)
      ..writeByte(9)
      ..write(obj.invoiceUuidEdit)
      ..writeByte(10)
      ..write(obj.createdDate)
      ..writeByte(11)
      ..write(obj.setCustomPrice)
      ..writeByte(12)
      ..write(obj.fixedDiscount)
      ..writeByte(13)
      ..write(obj.isSettingDiscountOpen)
      ..writeByte(14)
      ..write(obj.cartName)
      ..writeByte(15)
      ..write(obj.subStaffUuid)
      ..writeByte(16)
      ..write(obj.staffName)
      ..writeByte(17)
      ..write(obj.staffId)
      ..writeByte(18)
      ..write(obj.departmentUuid)
      ..writeByte(19)
      ..write(obj.departmentName)
      ..writeByte(20)
      ..write(obj.customDate)
      ..writeByte(21)
      ..write(obj.hasPrintedDocket)
      ..writeByte(22)
      ..write(obj.subStaffName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TempCartAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
