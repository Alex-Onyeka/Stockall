// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'production_item_quantity_update.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductionItemQuantityUpdateAdapter
    extends TypeAdapter<ProductionItemQuantityUpdate> {
  @override
  final int typeId = 113;

  @override
  ProductionItemQuantityUpdate read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProductionItemQuantityUpdate(
      uuid: fields[0] as String?,
      createdAt: fields[1] as DateTime?,
      quantity: fields[2] as double,
      productionItemUuid: fields[3] as String,
      isIncrement: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ProductionItemQuantityUpdate obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.uuid)
      ..writeByte(1)
      ..write(obj.createdAt)
      ..writeByte(2)
      ..write(obj.quantity)
      ..writeByte(3)
      ..write(obj.productionItemUuid)
      ..writeByte(4)
      ..write(obj.isIncrement);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductionItemQuantityUpdateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
