// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'temp_expenses_class.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TempExpensesClassAdapter extends TypeAdapter<TempExpensesClass> {
  @override
  final int typeId = 2;

  @override
  TempExpensesClass read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TempExpensesClass(
      name: fields[3] as String,
      description: fields[5] as String?,
      amount: fields[6] as double,
      creator: fields[4] as String,
      quantity: fields[7] as double?,
      unit: fields[8] as String?,
      shopId: fields[2] as int,
      id: fields[0] as int?,
      createdDate: fields[1] as DateTime?,
      userId: fields[9] as String,
      departmentName: fields[10] as String?,
      departmentId: fields[11] as int?,
      uuid: fields[12] as String?,
      updatedAt: fields[13] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, TempExpensesClass obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.createdDate)
      ..writeByte(2)
      ..write(obj.shopId)
      ..writeByte(3)
      ..write(obj.name)
      ..writeByte(4)
      ..write(obj.creator)
      ..writeByte(5)
      ..write(obj.description)
      ..writeByte(6)
      ..write(obj.amount)
      ..writeByte(7)
      ..write(obj.quantity)
      ..writeByte(8)
      ..write(obj.unit)
      ..writeByte(9)
      ..write(obj.userId)
      ..writeByte(10)
      ..write(obj.departmentName)
      ..writeByte(11)
      ..write(obj.departmentId)
      ..writeByte(12)
      ..write(obj.uuid)
      ..writeByte(13)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TempExpensesClassAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
