// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'updated_storage_product.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UpdatedStorageProductAdapter extends TypeAdapter<UpdatedStorageProduct> {
  @override
  final int typeId = 69;

  @override
  UpdatedStorageProduct read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UpdatedStorageProduct(
      updatedStorageProduct: fields[0] as TempStorageProducts,
    );
  }

  @override
  void write(BinaryWriter writer, UpdatedStorageProduct obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.updatedStorageProduct);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdatedStorageProductAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
