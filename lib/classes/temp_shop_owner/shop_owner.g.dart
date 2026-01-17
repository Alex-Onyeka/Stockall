// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shop_owner.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ShopOwnerAdapter extends TypeAdapter<ShopOwner> {
  @override
  final int typeId = 33;

  @override
  ShopOwner read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ShopOwner(
      shopOwner: fields[0] as TempUserClass?,
    );
  }

  @override
  void write(BinaryWriter writer, ShopOwner obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.shopOwner);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShopOwnerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
