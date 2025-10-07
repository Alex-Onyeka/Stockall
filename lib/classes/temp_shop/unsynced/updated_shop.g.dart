// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'updated_shop.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UpdatedShopAdapter extends TypeAdapter<UpdatedShop> {
  @override
  final int typeId = 27;

  @override
  UpdatedShop read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UpdatedShop(
      shop: fields[0] as TempShopClass,
    );
  }

  @override
  void write(BinaryWriter writer, UpdatedShop obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.shop);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdatedShopAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
