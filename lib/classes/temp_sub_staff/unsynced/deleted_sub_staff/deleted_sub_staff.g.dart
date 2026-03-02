// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deleted_sub_staff.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DeletedSubStaffAdapter extends TypeAdapter<DeletedSubStaff> {
  @override
  final int typeId = 58;

  @override
  DeletedSubStaff read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DeletedSubStaff(
      subStaffUuid: fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, DeletedSubStaff obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.subStaffUuid);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeletedSubStaffAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
