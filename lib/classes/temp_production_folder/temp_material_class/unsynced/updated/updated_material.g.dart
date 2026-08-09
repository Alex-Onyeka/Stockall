// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'updated_material.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UpdatedMaterialAdapter extends TypeAdapter<UpdatedMaterial> {
  @override
  final int typeId = 108;

  @override
  UpdatedMaterial read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UpdatedMaterial(
      material: fields[0] as MaterialClass,
      includeQuantity: fields[1] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, UpdatedMaterial obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.material)
      ..writeByte(1)
      ..write(obj.includeQuantity);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdatedMaterialAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
