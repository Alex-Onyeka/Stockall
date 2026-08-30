// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'orders.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OrdersAdapter extends TypeAdapter<Orders> {
  @override
  final int typeId = 134;

  @override
  Orders read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Orders(
      createdAt: fields[1] as DateTime,
      shopId: fields[2] as int,
      staffId: fields[3] as String?,
      staffName: fields[4] as String?,
      departmentName: fields[8] as String?,
      departmentUuid: fields[7] as String?,
      uuid: fields[0] as String?,
      total: fields[9] as double?,
      customerId: fields[5] as String?,
      customerName: fields[6] as String?,
      orderItems: (fields[10] as List).cast<OrderItems>(),
      updatedAt: fields[11] as DateTime?,
      barcode: fields[12] as String?,
      vat: fields[13] as double?,
      comment: fields[14] as String?,
      originalCost: fields[15] as double?,
      balance: fields[16] as double?,
      cartName: fields[19] as String?,
      fixedDiscount: fields[18] as double?,
      generalDiscount: fields[17] as double?,
      subStaffName: fields[20] as String?,
      subStaffUuid: fields[21] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Orders obj) {
    writer
      ..writeByte(22)
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
      ..write(obj.customerName)
      ..writeByte(7)
      ..write(obj.departmentUuid)
      ..writeByte(8)
      ..write(obj.departmentName)
      ..writeByte(9)
      ..write(obj.total)
      ..writeByte(10)
      ..write(obj.orderItems)
      ..writeByte(11)
      ..write(obj.updatedAt)
      ..writeByte(12)
      ..write(obj.barcode)
      ..writeByte(13)
      ..write(obj.vat)
      ..writeByte(14)
      ..write(obj.comment)
      ..writeByte(15)
      ..write(obj.originalCost)
      ..writeByte(16)
      ..write(obj.balance)
      ..writeByte(17)
      ..write(obj.generalDiscount)
      ..writeByte(18)
      ..write(obj.fixedDiscount)
      ..writeByte(19)
      ..write(obj.cartName)
      ..writeByte(20)
      ..write(obj.subStaffName)
      ..writeByte(21)
      ..write(obj.subStaffUuid);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrdersAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
