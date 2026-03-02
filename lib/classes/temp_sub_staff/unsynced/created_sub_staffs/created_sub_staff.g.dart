// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'created_sub_staff.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CreatedSubStaffAdapter extends TypeAdapter<CreatedSubStaff> {
  @override
  final int typeId = 57;

  @override
  CreatedSubStaff read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CreatedSubStaff(
      subStaff: fields[0] as TempSubStaff,
    );
  }

  @override
  void write(BinaryWriter writer, CreatedSubStaff obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.subStaff);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreatedSubStaffAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
