// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'updated_expense_category.dart';

class UpdatedExpenseCategoryAdapter
    extends TypeAdapter<UpdatedExpenseCategory> {
  @override
  final int typeId = 158;

  @override
  UpdatedExpenseCategory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UpdatedExpenseCategory(
      category: fields[0] as ExpenseCategory,
    );
  }

  @override
  void write(BinaryWriter writer, UpdatedExpenseCategory obj) {
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
      other is UpdatedExpenseCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
