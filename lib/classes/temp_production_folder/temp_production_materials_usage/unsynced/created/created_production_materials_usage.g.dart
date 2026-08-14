// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'created_production_materials_usage.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CreatedProductionMaterialsUsageAdapter
    extends TypeAdapter<CreatedProductionMaterialsUsage> {
  @override
  final int typeId = 122;

  @override
  CreatedProductionMaterialsUsage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CreatedProductionMaterialsUsage(
      createdProductionMaterialsUsage: fields[0] as ProductionMaterialsUsage,
    );
  }

  @override
  void write(BinaryWriter writer, CreatedProductionMaterialsUsage obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.createdProductionMaterialsUsage);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreatedProductionMaterialsUsageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
