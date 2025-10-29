// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'temp_shop_logos.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TempShopLogosAdapter extends TypeAdapter<TempShopLogos> {
  @override
  final int typeId = 29;

  @override
  TempShopLogos read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TempShopLogos(
      logoPath: fields[0] as String,
      imageName: fields[1] as String,
      imageHeight: fields[2] as int,
      imageWidth: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, TempShopLogos obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.logoPath)
      ..writeByte(1)
      ..write(obj.imageName)
      ..writeByte(2)
      ..write(obj.imageHeight)
      ..writeByte(3)
      ..write(obj.imageWidth);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TempShopLogosAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
