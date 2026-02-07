// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deleted_departments.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DeletedDepartmentsAdapter extends TypeAdapter<DeletedDepartments> {
  @override
  final int typeId = 41;

  @override
  DeletedDepartments read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DeletedDepartments(
      departmentUuid: fields[0] as String,
      shopId: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, DeletedDepartments obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.departmentUuid)
      ..writeByte(1)
      ..write(obj.shopId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeletedDepartmentsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
