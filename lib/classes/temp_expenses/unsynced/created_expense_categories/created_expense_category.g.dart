// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'created_expense_category.dart';

class CreatedExpenseCategoryAdapter
    extends TypeAdapter<CreatedExpenseCategory> {
  @override
  final int typeId = 156;

  @override
  CreatedExpenseCategory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CreatedExpenseCategory(
      category: fields[0] as ExpenseCategory,
    );
  }

  @override
  void write(BinaryWriter writer, CreatedExpenseCategory obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.category);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreatedExpenseCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
