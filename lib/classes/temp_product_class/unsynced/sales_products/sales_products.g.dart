// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_products.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SalesProductsAdapter extends TypeAdapter<SalesProducts> {
  @override
  final int typeId = 12;

  @override
  SalesProducts read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SalesProducts(
      product: fields[0] as TempProductClass,
      date: fields[1] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, SalesProducts obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.product)
      ..writeByte(1)
      ..write(obj.date);
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
