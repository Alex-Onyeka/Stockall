// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_category.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExpenseCategoryAdapter extends TypeAdapter<ExpenseCategory> {
  @override
  final int typeId = 155;

  @override
  ExpenseCategory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExpenseCategory(
      uuid: fields[0] as String,
      shopId: fields[1] as int,
      name: fields[2] as String,
      departmentUuid: fields[3] as String?,
      departmentName: fields[4] as String?,
      createdAt: fields[5] as DateTime?,
      updatedAt: fields[6] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ExpenseCategory obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.uuid)
      ..writeByte(1)
      ..write(obj.shopId)
      ..writeByte(2)
      ..write(obj.name)
      ..writeByte(3)
      ..write(obj.departmentUuid)
      ..writeByte(4)
      ..write(obj.departmentName)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
