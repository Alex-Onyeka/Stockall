// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'department_class.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DepartmentClassAdapter extends TypeAdapter<DepartmentClass> {
  @override
  final int typeId = 39;

  @override
  DepartmentClass read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DepartmentClass(
      uuid: fields[0] as String,
      createdAt: fields[1] as DateTime,
      updatedAt: fields[2] as DateTime?,
      shopId: fields[3] as int,
      name: fields[4] as String,
      description: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, DepartmentClass obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.uuid)
      ..writeByte(1)
      ..write(obj.createdAt)
      ..writeByte(2)
      ..write(obj.updatedAt)
      ..writeByte(3)
      ..write(obj.shopId)
      ..writeByte(4)
      ..write(obj.name)
      ..writeByte(5)
      ..write(obj.description);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DepartmentClassAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
