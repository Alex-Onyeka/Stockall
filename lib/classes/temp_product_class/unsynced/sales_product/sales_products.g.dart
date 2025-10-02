// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_products.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SalesProductsAdapter extends TypeAdapter<SalesProducts> {
  @override
  final int typeId = 28;

  @override
  SalesProducts read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SalesProducts(
      quantity: fields[0] as double,
      productUuid: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SalesProducts obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.quantity)
      ..writeByte(1)
      ..write(obj.productUuid);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SalesProductsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
