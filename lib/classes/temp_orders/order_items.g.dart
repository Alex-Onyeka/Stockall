// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_items.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OrderItemsAdapter extends TypeAdapter<OrderItems> {
  @override
  final int typeId = 133;

  @override
  OrderItems read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OrderItems(
      uuid: fields[0] as String,
      orderId: fields[1] as String,
      productName: fields[3] as String,
      productUuid: fields[4] as String,
      createdAt: fields[2] as DateTime,
      staffName: fields[6] as String,
      staffId: fields[5] as String,
      costPrice: fields[14] as double?,
      customerName: fields[7] as String?,
      customerUuid: fields[8] as String?,
      departmentName: fields[16] as String?,
      departmentUuid: fields[17] as String?,
      qttyPerGroup: fields[26] as double?,
      quantity: fields[10] as double,
      revenue: fields[11] as double,
      unit: fields[22] as String?,
      useGroupQuantity: fields[25] as bool?,
      useWholeSalePrice: fields[24] as bool?,
      groupUnit: fields[23] as String?,
      addToStock: fields[18] as bool?,
      customPriceSet: fields[15] as bool,
      discount: fields[9] as double?,
      discountedAmount: fields[12] as double?,
      fixedDiscount: fields[21] as double?,
      isProductManaged: fields[19] as bool?,
      originalCost: fields[13] as double?,
      setTotalPrice: fields[20] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, OrderItems obj) {
    writer
      ..writeByte(27)
      ..writeByte(0)
      ..write(obj.uuid)
      ..writeByte(1)
      ..write(obj.orderId)
      ..writeByte(2)
      ..write(obj.createdAt)
      ..writeByte(3)
      ..write(obj.productName)
      ..writeByte(4)
      ..write(obj.productUuid)
      ..writeByte(5)
      ..write(obj.staffId)
      ..writeByte(6)
      ..write(obj.staffName)
      ..writeByte(7)
      ..write(obj.customerName)
      ..writeByte(8)
      ..write(obj.customerUuid)
      ..writeByte(9)
      ..write(obj.discount)
      ..writeByte(10)
      ..write(obj.quantity)
      ..writeByte(11)
      ..write(obj.revenue)
      ..writeByte(12)
      ..write(obj.discountedAmount)
      ..writeByte(13)
      ..write(obj.originalCost)
      ..writeByte(14)
      ..write(obj.costPrice)
      ..writeByte(15)
      ..write(obj.customPriceSet)
      ..writeByte(16)
      ..write(obj.departmentName)
      ..writeByte(17)
      ..write(obj.departmentUuid)
      ..writeByte(18)
      ..write(obj.addToStock)
      ..writeByte(19)
      ..write(obj.isProductManaged)
      ..writeByte(20)
      ..write(obj.setTotalPrice)
      ..writeByte(21)
      ..write(obj.fixedDiscount)
      ..writeByte(22)
      ..write(obj.unit)
      ..writeByte(23)
      ..write(obj.groupUnit)
      ..writeByte(24)
      ..write(obj.useWholeSalePrice)
      ..writeByte(25)
      ..write(obj.useGroupQuantity)
      ..writeByte(26)
      ..write(obj.qttyPerGroup);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderItemsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
