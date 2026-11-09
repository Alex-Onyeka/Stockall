import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_expenses/temp_expenses_class.dart';
import 'package:stockall/local_database/expenses/unsync_funcs/created_expenses/created_expenses_func.dart';
import 'package:stockall/local_database/expenses/unsync_funcs/deleted_expenses/deleted_expenses_func.dart';
import 'package:stockall/local_database/expenses/unsync_funcs/updated_expenses/updated_expenses_func.dart';
import 'package:stockall/local_database/hive_box_helper.dart';
import 'package:stockall/main.dart';

class ExpensesFunc {
  static final ExpensesFunc instance =
      ExpensesFunc._internal();
  factory ExpensesFunc() => instance;
  ExpensesFunc._internal();
  late Box<TempExpensesClass> expensesBox;
  final String expensesBoxName = 'expensesBoxStockall';

  Future<void> init() async {
    try {
      safeRegisterAdapter(TempExpensesClassAdapter());
      expensesBox = await openBoxSafely<TempExpensesClass>(
        expensesBoxName,
      );
      try {
        await CreatedExpensesFunc().init();
      } catch (e, s) {
        await mainLocalLog(
          'Error initializing CreatedExpensesFunc: $e',
          error: e,
          stackTrace: s,
        );
      }
      try {
        await DeletedExpensesFunc().init();
      } catch (e, s) {
        await mainLocalLog(
          'Error initializing DeletedExpensesFunc: $e',
          error: e,
          stackTrace: s,
        );
      }
      try {
        await UpdatedExpensesFunc().init();
      } catch (e, s) {
        await mainLocalLog(
          'Error initializing UpdatedExpensesFunc: $e',
          error: e,
          stackTrace: s,
        );
      }
      await mainLocalLog('Expenses Box Initialized');
    } catch (e, s) {
      await mainLocalLog(
        'Error Initializing Expenses Func Box: ${e.toString()}',
        error: e,
        stackTrace: s,
      );
    }
  }

  List<TempExpensesClass> getExpenses() {
    try {
      List<TempExpensesClass> exps =
          expensesBox.values.toList();
      exps.sort(
        (a, b) => (b.createdDate ?? DateTime(2000))
            .compareTo(a.createdDate ?? DateTime(2000)),
      );
      return exps;
    } catch (e, s) {
      mainLocalLog(
        'Error reading expenses: $e',
        error: e,
        stackTrace: s,
      );
      return [];
    }
  }

  Future<int> insertAllExpenses(
    List<TempExpensesClass> expenses,
  ) async {
    await clearExpenses();
    try {
      for (var exp in expenses) {
        await expensesBox.put(exp.uuid, exp);
      }
      await mainLocalLog('Offline Success');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Exp Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> createExpenses(
    TempExpensesClass expenses,
  ) async {
    try {
      await expensesBox.put(expenses.uuid, expenses);
      await mainLocalLog('Offline Expenses Created');
      return 1;
    } catch (e) {
      await mainLocalLog(
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
      await mainLocalLog('Offline Expenses Updated');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Expenses Update Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> deleteExpenses(String uuid) async {
    try {
      await expensesBox.delete(uuid);
      await mainLocalLog('Offline Expenses Deleted');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Expenses Delete Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> clearExpenses() async {
    try {
      await expensesBox.clear();
      await mainLocalLog('Offline Expenses Cleared');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Expenses Clear Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  bool isSynced() {
    if (CreatedExpensesFunc().getExpenses().isEmpty &&
        UpdatedExpensesFunc().getExpenses().isEmpty &&
        DeletedExpensesFunc().getExpenseIds().isEmpty &&
        returnData().isSyncing == false) {
      return true;
    } else {
      return false;
    }
  }
}
