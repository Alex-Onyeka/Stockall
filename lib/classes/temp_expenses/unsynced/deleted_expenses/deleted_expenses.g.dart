// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deleted_expenses.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DeletedExpensesAdapter extends TypeAdapter<DeletedExpenses> {
  @override
  final int typeId = 15;

  @override
  DeletedExpenses read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DeletedExpenses(
      expensesUuid: fields[0] as String,
      shopId: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, DeletedExpenses obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.expensesUuid)
      ..writeByte(1)
      ..write(obj.shopId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeletedExpensesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
