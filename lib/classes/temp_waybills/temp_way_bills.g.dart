// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'temp_way_bills.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TempWayBillsAdapter extends TypeAdapter<TempWayBills> {
  @override
  final int typeId = 85;

  @override
  TempWayBills read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TempWayBills(
      uuid: fields[0] as String?,
      createdAt: fields[1] as DateTime?,
      shopId: fields[2] as int?,
      staffId: fields[3] as String?,
      staffName: fields[4] as String?,
      customerId: fields[5] as String?,
      customCustomerName: fields[6] as String?,
      customCustomerEmail: fields[7] as String?,
      customCustomerPhone: fields[8] as String?,
      customCustomerAddress: fields[9] as String?,
      departmentId: fields[10] as String?,
      departmentName: fields[11] as String?,
      totalAmount: fields[12] as double?,
      receiptId: fields[13] as String?,
      invoiceId: fields[14] as String?,
      status: fields[15] as String?,
      updatedAt: fields[16] as DateTime?,
      deliveryLocation: fields[18] as String?,
      courierName: fields[19] as String?,
      courierPhone: fields[20] as String?,
      items: (fields[17] as List).cast<WaybillItems>(),
    );
  }

  @override
  void write(BinaryWriter writer, TempWayBills obj) {
    writer
      ..writeByte(21)
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
      ..write(obj.customerId)
      ..writeByte(6)
      ..write(obj.customCustomerName)
      ..writeByte(7)
      ..write(obj.customCustomerEmail)
      ..writeByte(8)
      ..write(obj.customCustomerPhone)
      ..writeByte(9)
      ..write(obj.customCustomerAddress)
      ..writeByte(10)
      ..write(obj.departmentId)
      ..writeByte(11)
      ..write(obj.departmentName)
      ..writeByte(12)
      ..write(obj.totalAmount)
      ..writeByte(13)
      ..write(obj.receiptId)
      ..writeByte(14)
      ..write(obj.invoiceId)
      ..writeByte(15)
      ..write(obj.status)
      ..writeByte(16)
      ..write(obj.updatedAt)
      ..writeByte(17)
      ..write(obj.items)
      ..writeByte(18)
      ..write(obj.deliveryLocation)
      ..writeByte(19)
      ..write(obj.courierName)
      ..writeByte(20)
      ..write(obj.courierPhone);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TempWayBillsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
