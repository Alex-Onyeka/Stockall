// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'updated_products.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UpdatedProductsAdapter extends TypeAdapter<UpdatedProducts> {
  @override
  final int typeId = 11;

  @override
  UpdatedProducts read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UpdatedProducts(
      product: fields[0] as TempProductClass,
    );
  }

  @override
  void write(BinaryWriter writer, UpdatedProducts obj) {
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
      other is UpdatedProductsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
