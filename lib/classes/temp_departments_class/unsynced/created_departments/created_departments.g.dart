// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'created_departments.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CreatedDepartmentsAdapter extends TypeAdapter<CreatedDepartments> {
  @override
  final int typeId = 40;

  @override
  CreatedDepartments read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CreatedDepartments(
      department: fields[0] as DepartmentClass,
    );
  }

  @override
  void write(BinaryWriter writer, CreatedDepartments obj) {
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
      other is CreatedDepartmentsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
