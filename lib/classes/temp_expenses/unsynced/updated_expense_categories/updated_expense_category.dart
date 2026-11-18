import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_expenses/expense_category.dart';

part 'updated_expense_category.g.dart';

@HiveType(typeId: 158)
class UpdatedExpenseCategory extends HiveObject {
  @HiveField(0)
  final ExpenseCategory category;

  UpdatedExpenseCategory({required this.category});
}
