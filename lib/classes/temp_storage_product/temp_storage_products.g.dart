// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'temp_storage_products.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TempStorageProductsAdapter extends TypeAdapter<TempStorageProducts> {
  @override
  final int typeId = 66;

  @override
  TempStorageProducts read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TempStorageProducts(
      uuid: fields[0] as String?,
      createdAt: fields[1] as DateTime?,
      shopId: fields[2] as int,
      name: fields[3] as String,
      desc: fields[4] as String?,
      quantity: fields[5] as double?,
      unit: fields[6] as String?,
      groupUnit: fields[7] as String?,
      updatedAt: fields[8] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, TempStorageProducts obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.uuid)
      ..writeByte(1)
      ..write(obj.createdAt)
      ..writeByte(2)
      ..write(obj.shopId)
      ..writeByte(3)
      ..write(obj.name)
      ..writeByte(4)
      ..write(obj.desc)
      ..writeByte(5)
      ..write(obj.quantity)
      ..writeByte(6)
      ..write(obj.unit)
      ..writeByte(7)
      ..write(obj.groupUnit)
      ..writeByte(8)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TempStorageProductsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
