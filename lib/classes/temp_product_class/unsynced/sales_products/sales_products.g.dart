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
      productUuid: fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, SalesProducts obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
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
