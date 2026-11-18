import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_expenses/expense_category.dart';

part 'created_expense_category.g.dart';

@HiveType(typeId: 156)
class CreatedExpenseCategory extends HiveObject {
  @HiveField(0)
  final ExpenseCategory category;

  CreatedExpenseCategory({required this.category});
}
