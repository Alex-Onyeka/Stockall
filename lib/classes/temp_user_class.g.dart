// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'temp_user_class.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TempUserClassAdapter extends TypeAdapter<TempUserClass> {
  @override
  final int typeId = 0;

  @override
  TempUserClass read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TempUserClass(
      userId: fields[0] as String?,
      createdAt: fields[1] as DateTime?,
      password: fields[2] as String,
      name: fields[3] as String,
      email: fields[4] as String,
      phone: fields[5] as String?,
      role: fields[6] as String,
      authUserId: fields[7] as String?,
      departmentName: fields[8] as String?,
      departmentId: fields[9] as int?,
      pin: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TempUserClass obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.createdAt)
      ..writeByte(2)
      ..write(obj.password)
      ..writeByte(3)
      ..write(obj.name)
      ..writeByte(4)
      ..write(obj.email)
      ..writeByte(5)
      ..write(obj.phone)
      ..writeByte(6)
      ..write(obj.role)
      ..writeByte(7)
      ..write(obj.authUserId)
      ..writeByte(8)
      ..write(obj.departmentName)
      ..writeByte(9)
      ..write(obj.departmentId)
      ..writeByte(10)
      ..write(obj.pin);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TempUserClassAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
