// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deleted_products.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DeletedProductsAdapter extends TypeAdapter<DeletedProducts> {
  @override
  final int typeId = 10;

  @override
  DeletedProducts read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DeletedProducts(
      productid: fields[0] as int,
      date: fields[1] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, DeletedProducts obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.productid)
      ..writeByte(1)
      ..write(obj.date);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeletedProductsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
