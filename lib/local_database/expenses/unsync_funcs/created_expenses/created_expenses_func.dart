import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_expenses/unsynced/created_expenses/created_expenses.dart';
import 'package:stockall/main.dart';

class CreatedExpensesFunc {
  static final CreatedExpensesFunc instance =
      CreatedExpensesFunc._internal();
  factory CreatedExpensesFunc() => instance;
  CreatedExpensesFunc._internal();

  Box<CreatedExpenses>? _createdExpensesBox;
  final String createdExpensesBoxName =
      'createdExpensesBoxStockall';

  /// Initialize Hive box + adapter safely
  Future<void> init() async {
    // Check if adapter is already registered
    if (!Hive.isAdapterRegistered(
      CreatedExpensesAdapter().typeId,
    )) {
      Hive.registerAdapter(CreatedExpensesAdapter());
      await mainLocalLog(
        'Created Expenses Adapter registered ✅',
      );
    }

    // Open the box only if it isn’t already open
    if (!Hive.isBoxOpen(createdExpensesBoxName)) {
      _createdExpensesBox =
          await Hive.openBox<CreatedExpenses>(
            createdExpensesBoxName,
          );
      await mainLocalLog('Created Expenses Box opened ✅');
    } else {
      _createdExpensesBox = Hive.box<CreatedExpenses>(
        createdExpensesBoxName,
      );
      await mainLocalLog(
        'Created Expenses Box already open, reused ✅',
      );
    }
  }

  /// Safe getter for the box
  Box<CreatedExpenses> get createdExpensesBox {
    if (_createdExpensesBox == null) {
      throw Exception(
        "Created Expenses Func not initialized. Call await CreatedExpensesFunc.instance.init() first.",
      );
    }
    return _createdExpensesBox!;
  }

  List<CreatedExpenses> getExpenses() {
    return createdExpensesBox.values.toList();
  }

  Future<int> insertAllExpenses(
    List<CreatedExpenses> createdExpenses,
  ) async {
    try {
      for (var expenses in createdExpenses) {
        await createdExpensesBox.put(
          expenses.expenses.uuid,
          expenses,
        );
      }
      await mainLocalLog(
        "Offline Created Expenses inserted ✅",
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Created Expenses insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> createExpenses(
    CreatedExpenses createdExpenses,
  ) async {
    try {
      await createdExpensesBox.put(
        createdExpenses.expenses.uuid,
        createdExpenses,
      );
      await mainLocalLog(
        'Offline Created Expenses inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Created Expenses insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> updateExpenses(
    CreatedExpenses createdExpenses,
  ) async {
    try {
      await createdExpensesBox.put(
        createdExpenses.expenses.uuid,
        createdExpenses,
      );
      await mainLocalLog(
        'Offline Created Expenses inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Offline Created Expenses insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> deleteExpenses(String uuid) async {
    try {
      await mainLocalLog(
        createdExpensesBox.containsKey(uuid).toString(),
      );
      await createdExpensesBox.delete(uuid);
      await mainLocalLog('Expenses Deleted');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Expenses Delete Failed: ${e.toString()}',
      );
      return 0;
    }
  }

  Future<int> clearExpenses() async {
    try {
      await createdExpensesBox.clear();
      await mainLocalLog('All Created Expenses cleared ✅');
      return 1;
    } catch (e) {
      await mainLocalLog(
        'Error while clearing Created Expenses ❌: $e',
      );
      return 0;
    }
  }
}
