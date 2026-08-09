// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'productions_cart_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductionsCartItemAdapter extends TypeAdapter<ProductionsCartItem> {
  @override
  final int typeId = 118;

  @override
  ProductionsCartItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProductionsCartItem(
      uuid: fields[0] as String?,
      itemUuid: fields[1] as String?,
      name: fields[2] as String,
      quantity: fields[3] as double,
      customPrice: fields[5] as double?,
      setCustomPrice: fields[6] as bool,
      addToStock: fields[7] as bool,
      useGroupQuantity: fields[8] as bool?,
      costPrice: fields[4] as double?,
      groupUnit: fields[10] as String?,
      qttyPerGroup: fields[11] as double?,
      unit: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ProductionsCartItem obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.uuid)
      ..writeByte(1)
      ..write(obj.itemUuid)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.quantity)
      ..writeByte(4)
      ..write(obj.costPrice)
      ..writeByte(5)
      ..write(obj.customPrice)
      ..writeByte(6)
      ..write(obj.setCustomPrice)
      ..writeByte(7)
      ..write(obj.addToStock)
      ..writeByte(8)
      ..write(obj.useGroupQuantity)
      ..writeByte(9)
      ..write(obj.unit)
      ..writeByte(10)
      ..write(obj.groupUnit)
      ..writeByte(11)
      ..write(obj.qttyPerGroup);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductionsCartItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
