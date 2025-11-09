// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'temp_current_shop.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TempCurrentShopAdapter extends TypeAdapter<TempCurrentShop> {
  @override
  final int typeId = 30;

  @override
  TempCurrentShop read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TempCurrentShop(
      currentShop: fields[0] as TempShopClass,
    );
  }

  @override
  void write(BinaryWriter writer, TempCurrentShop obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.currentShop);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TempCurrentShopAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
