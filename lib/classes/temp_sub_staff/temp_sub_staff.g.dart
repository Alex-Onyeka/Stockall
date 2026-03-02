// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'temp_sub_staff.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TempSubStaffAdapter extends TypeAdapter<TempSubStaff> {
  @override
  final int typeId = 56;

  @override
  TempSubStaff read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TempSubStaff(
      uuid: fields[0] as String?,
      phone: fields[4] as String?,
      createdAt: fields[1] as DateTime,
      shopId: fields[2] as int,
      staffName: fields[3] as String?,
      departmentName: fields[5] as String?,
      departmentUuid: fields[6] as String?,
      updatedAt: fields[7] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, TempSubStaff obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.uuid)
      ..writeByte(1)
      ..write(obj.createdAt)
      ..writeByte(2)
      ..write(obj.shopId)
      ..writeByte(3)
      ..write(obj.staffName)
      ..writeByte(4)
      ..write(obj.phone)
      ..writeByte(5)
      ..write(obj.departmentName)
      ..writeByte(6)
      ..write(obj.departmentUuid)
      ..writeByte(7)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TempSubStaffAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
