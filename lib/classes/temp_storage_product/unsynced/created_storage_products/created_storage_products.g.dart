// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'created_storage_products.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CreatedStorageProductsAdapter
    extends TypeAdapter<CreatedStorageProducts> {
  @override
  final int typeId = 67;

  @override
  CreatedStorageProducts read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CreatedStorageProducts(
      storageProduct: fields[0] as TempStorageProducts,
    );
  }

  @override
  void write(BinaryWriter writer, CreatedStorageProducts obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.storageProduct);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreatedStorageProductsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
