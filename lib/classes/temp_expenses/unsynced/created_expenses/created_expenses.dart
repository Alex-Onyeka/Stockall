import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_expenses/temp_expenses_class.dart';
part 'created_expenses.g.dart';

@HiveType(typeId: 14)
class CreatedExpenses extends HiveObject {
  @HiveField(0)
  final TempExpensesClass expenses;

  CreatedExpenses({required this.expenses});
}
