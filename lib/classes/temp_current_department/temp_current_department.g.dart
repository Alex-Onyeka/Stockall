// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'temp_current_department.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TempCurrentDepartmentAdapter extends TypeAdapter<TempCurrentDepartment> {
  @override
  final int typeId = 65;

  @override
  TempCurrentDepartment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TempCurrentDepartment(
      currentDepartmentId: fields[0] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TempCurrentDepartment obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.currentDepartmentId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TempCurrentDepartmentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
