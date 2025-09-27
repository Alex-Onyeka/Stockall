// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'updated_expenses.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UpdatedExpensesAdapter extends TypeAdapter<UpdatedExpenses> {
  @override
  final int typeId = 16;

  @override
  UpdatedExpenses read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UpdatedExpenses(
      expenses: fields[0] as TempExpensesClass,
    );
  }

  @override
  void write(BinaryWriter writer, UpdatedExpenses obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.expenses);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdatedExpensesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
