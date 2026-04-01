// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deleted_storage_product.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DeletedStorageProductAdapter extends TypeAdapter<DeletedStorageProduct> {
  @override
  final int typeId = 68;

  @override
  DeletedStorageProduct read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DeletedStorageProduct(
      storageProducteUuid: fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, DeletedStorageProduct obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.storageProducteUuid);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeletedStorageProductAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
