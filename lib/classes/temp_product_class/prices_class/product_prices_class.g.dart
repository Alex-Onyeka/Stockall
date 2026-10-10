// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_prices_class.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductPricesClassAdapter extends TypeAdapter<ProductPricesClass> {
  @override
  final int typeId = 147;

  @override
  ProductPricesClass read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProductPricesClass(
      uuid: fields[0] as String,
      staffUuid: fields[3] as String?,
      createdAt: fields[1] as DateTime,
      staffName: fields[2] as String?,
      priceValue: fields[4] as double,
      name: fields[5] as String?,
      isPrimary: fields[6] as bool,
      itemUuid: fields[7] as String,
      isFixed: fields[8] as bool?,
      priceType: fields[9] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, ProductPricesClass obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.uuid)
      ..writeByte(1)
      ..write(obj.createdAt)
      ..writeByte(2)
      ..write(obj.staffName)
      ..writeByte(3)
      ..write(obj.staffUuid)
      ..writeByte(4)
      ..write(obj.priceValue)
      ..writeByte(5)
      ..write(obj.name)
      ..writeByte(6)
      ..write(obj.isPrimary)
      ..writeByte(7)
      ..write(obj.itemUuid)
      ..writeByte(8)
      ..write(obj.isFixed)
      ..writeByte(9)
      ..write(obj.priceType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductPricesClassAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
