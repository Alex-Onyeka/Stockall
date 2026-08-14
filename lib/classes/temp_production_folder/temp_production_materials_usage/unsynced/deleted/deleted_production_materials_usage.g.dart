// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deleted_production_materials_usage.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DeletedProductionMaterialsUsageAdapter
    extends TypeAdapter<DeletedProductionMaterialsUsage> {
  @override
  final int typeId = 123;

  @override
  DeletedProductionMaterialsUsage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DeletedProductionMaterialsUsage(
      materialsUsageUuid: fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, DeletedProductionMaterialsUsage obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.materialsUsageUuid);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeletedProductionMaterialsUsageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
