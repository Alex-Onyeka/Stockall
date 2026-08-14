// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'materials_usage_cart.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MaterialsUsageCartAdapter extends TypeAdapter<MaterialsUsageCart> {
  @override
  final int typeId = 125;

  @override
  MaterialsUsageCart read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MaterialsUsageCart(
      cartItems: (fields[0] as List).cast<MaterialsUsageCartItem>(),
      uuid: fields[2] as String,
      isEdit: fields[1] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, MaterialsUsageCart obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.cartItems)
      ..writeByte(1)
      ..write(obj.isEdit)
      ..writeByte(2)
      ..write(obj.uuid);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MaterialsUsageCartAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
