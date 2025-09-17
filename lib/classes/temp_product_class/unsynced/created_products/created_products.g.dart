// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'created_products.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CreatedProductsAdapter extends TypeAdapter<CreatedProducts> {
  @override
  final int typeId = 9;

  @override
  CreatedProducts read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CreatedProducts(
      product: fields[0] as TempProductClass,
    );
  }

  @override
  void write(BinaryWriter writer, CreatedProducts obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.product);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreatedProductsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
