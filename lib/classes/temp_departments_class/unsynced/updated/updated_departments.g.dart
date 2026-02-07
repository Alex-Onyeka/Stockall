// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'updated_departments.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UpdatedDepartmentsAdapter extends TypeAdapter<UpdatedDepartments> {
  @override
  final int typeId = 42;

  @override
  UpdatedDepartments read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UpdatedDepartments(
      department: fields[0] as DepartmentClass,
    );
  }

  @override
  void write(BinaryWriter writer, UpdatedDepartments obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.department);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdatedDepartmentsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
