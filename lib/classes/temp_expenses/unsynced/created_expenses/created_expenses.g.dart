// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'created_expenses.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CreatedExpensesAdapter extends TypeAdapter<CreatedExpenses> {
  @override
  final int typeId = 14;

  @override
  CreatedExpenses read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CreatedExpenses(
      expenses: fields[0] as TempExpensesClass,
    );
  }

  @override
  void write(BinaryWriter writer, CreatedExpenses obj) {
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
      other is CreatedExpensesAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
