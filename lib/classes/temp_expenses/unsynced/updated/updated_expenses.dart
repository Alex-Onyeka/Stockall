import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_expenses/temp_expenses_class.dart';
part 'updated_expenses.g.dart';

@HiveType(typeId: 16)
class UpdatedExpenses extends HiveObject {
  @HiveField(0)
  TempExpensesClass expenses;

  UpdatedExpenses({required this.expenses});
}
