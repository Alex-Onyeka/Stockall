import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_expenses/temp_expenses_class.dart';

class ExpensesFunc {
  static final ExpensesFunc instance =
      ExpensesFunc._internal();
  factory ExpensesFunc() => instance;
  ExpensesFunc._internal();
  late Box<TempExpensesClass> expensesBox;
  final String expensesBoxName = 'expensesBoxStockall';

  Future<void> init() async {
    Hive.registerAdapter(TempExpensesClassAdapter());
    expensesBox = await Hive.openBox(expensesBoxName);
    print('Expenses Box Initialized');
  }

  List<TempExpensesClass> getExpenses() {
    return expensesBox.values.toList();
  }

  Future<int> insertAllExpenses(
    List<TempExpensesClass> expenses,
  ) async {
    try {
      for (var exp in expenses) {
        await expensesBox.put(exp.id, exp);
      }
      print('Offline Success');
      return 1;
    } catch (e) {
      print('Offline Exp Failed: ${e.toString()}');
      return 0;
    }
  }
}
