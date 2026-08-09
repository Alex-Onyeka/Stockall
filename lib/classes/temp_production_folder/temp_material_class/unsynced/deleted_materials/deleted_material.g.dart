// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deleted_material.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DeletedMaterialAdapter extends TypeAdapter<DeletedMaterial> {
  @override
  final int typeId = 106;

  @override
  DeletedMaterial read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DeletedMaterial(
      materialUuid: fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, DeletedMaterial obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.materialUuid);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeletedMaterialAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
