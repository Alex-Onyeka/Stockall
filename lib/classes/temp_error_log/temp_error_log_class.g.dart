// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'temp_error_log_class.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TempErrorLogClassAdapter extends TypeAdapter<TempErrorLogClass> {
  @override
  final int typeId = 94;

  @override
  TempErrorLogClass read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TempErrorLogClass(
      uuid: fields[0] as String?,
      createdAt: fields[1] as DateTime?,
      shopId: fields[2] as int,
      tableName: fields[3] as String,
      title: fields[4] as String,
      error: fields[5] as String,
      message: fields[6] as String?,
      amount: fields[7] as double?,
      staffName: fields[9] as String?,
      itemName: fields[8] as String?,
      departmentUuid: fields[10] as String?,
      departmentName: fields[11] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TempErrorLogClass obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.uuid)
      ..writeByte(1)
      ..write(obj.createdAt)
      ..writeByte(2)
      ..write(obj.shopId)
      ..writeByte(3)
      ..write(obj.tableName)
      ..writeByte(4)
      ..write(obj.title)
      ..writeByte(5)
      ..write(obj.error)
      ..writeByte(6)
      ..write(obj.message)
      ..writeByte(7)
      ..write(obj.amount)
      ..writeByte(8)
      ..write(obj.itemName)
      ..writeByte(9)
      ..write(obj.staffName)
      ..writeByte(10)
      ..write(obj.departmentUuid)
      ..writeByte(11)
      ..write(obj.departmentName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TempErrorLogClassAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
