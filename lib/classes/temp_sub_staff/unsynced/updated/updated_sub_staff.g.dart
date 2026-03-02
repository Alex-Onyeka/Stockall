// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'updated_sub_staff.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UpdatedSubStaffAdapter extends TypeAdapter<UpdatedSubStaff> {
  @override
  final int typeId = 59;

  @override
  UpdatedSubStaff read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UpdatedSubStaff(
      subStaff: fields[0] as TempSubStaff,
    );
  }

  @override
  void write(BinaryWriter writer, UpdatedSubStaff obj) {
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
      other is UpdatedSubStaffAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
