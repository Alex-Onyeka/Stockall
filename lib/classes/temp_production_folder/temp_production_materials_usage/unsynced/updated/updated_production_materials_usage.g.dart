// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'updated_production_materials_usage.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UpdatedProductionMaterialsUsageAdapter
    extends TypeAdapter<UpdatedProductionMaterialsUsage> {
  @override
  final int typeId = 124;

  @override
  UpdatedProductionMaterialsUsage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UpdatedProductionMaterialsUsage(
      updatedProductionMaterialsUsage: fields[0] as ProductionMaterialsUsage,
    );
  }

  @override
  void write(BinaryWriter writer, UpdatedProductionMaterialsUsage obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.updatedProductionMaterialsUsage);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdatedProductionMaterialsUsageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
