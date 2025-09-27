import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_expenses/temp_expenses_class.dart';
import 'package:stockall/local_database/expenses/unsync_funcs/created_expenses/created_expenses_func.dart';
import 'package:stockall/local_database/expenses/unsync_funcs/deleted_expenses/deleted_expenses_func.dart';
import 'package:stockall/local_database/expenses/unsync_funcs/updated_expenses/updated_expenses_func.dart';

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
    await CreatedExpensesFunc().init();
    await DeletedExpensesFunc().init();
    await UpdatedExpensesFunc().init();
    print('Expenses Box Initialized');
  }

  List<TempExpensesClass> getExpenses() {
    List<TempExpensesClass> exps =
        expensesBox.values.toList();
    exps.sort(
      (a, b) => b.createdDate!.compareTo(a.createdDate!),
    );
    return exps;
  }

  Future<int> insertAllExpenses(
    List<TempExpensesClass> expenses,
  ) async {
    await clearExpenses();
    try {
      for (var exp in expenses) {
        await expensesBox.put(exp.uuid, exp);
      }
      print('Offline Success');
      return 1;
    } catch (e) {
      print('Offline Exp Failed: ${e.toString()}');
      return 0;
    }
  }

  Future<int> createExpenses(
    TempExpensesClass expenses,
  ) async {
    try {
      await expensesBox.put(expenses.uuid, expenses);
      print('Offline Expenses Created');
      return 1;
    } catch (e) {
      print(
        'Offline Expenses Creation Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> updateExpenses(
    TempExpensesClass expenses,
  ) async {
    expenses.updatedAt = DateTime.now().add(
      (Duration(hours: 1)),
    );
    try {
      await expensesBox.put(expenses.uuid, expenses);
      print('Offline Expenses Updated');
      return 1;
    } catch (e) {
      print(
        'Offline Expenses Update Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> deleteExpenses(String uuid) async {
    try {
      await expensesBox.delete(uuid);
      print('Offline Expenses Deleted');
      return 1;
    } catch (e) {
      print(
        'Offline Expenses Delete Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> clearExpenses() async {
    try {
      await expensesBox.clear();
      print('Offline Expenses Cleared');
      return 1;
    } catch (e) {
      print('Expenses Clear Failed: ${e.toString()}');
      return 0;
    }
  }
}
