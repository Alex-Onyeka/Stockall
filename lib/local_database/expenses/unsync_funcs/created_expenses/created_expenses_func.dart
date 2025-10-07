import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_expenses/unsynced/created_expenses/created_expenses.dart';

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
      print('Created Expenses Adapter registered ✅');
    }

    // Open the box only if it isn’t already open
    if (!Hive.isBoxOpen(createdExpensesBoxName)) {
      _createdExpensesBox =
          await Hive.openBox<CreatedExpenses>(
            createdExpensesBoxName,
          );
      print('Created Expenses Box opened ✅');
    } else {
      _createdExpensesBox = Hive.box<CreatedExpenses>(
        createdExpensesBoxName,
      );
      print('Created Expenses Box already open, reused ✅');
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
      print("Offline Created Expenses inserted ✅");
      return 1;
    } catch (e) {
      print(
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
      print(
        'Offline Created Expenses inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      print(
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
      print(
        'Offline Created Expenses inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      print(
        'Offline Created Expenses insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> deleteExpenses(String uuid) async {
    try {
      print(
        createdExpensesBox.containsKey(uuid).toString(),
      );
      await createdExpensesBox.delete(uuid);
      print('Expenses Deleted');
      return 1;
    } catch (e) {
      print('Expenses Delete Failed: ${e.toString()}');
      return 0;
    }
  }

  Future<int> clearExpenses() async {
    try {
      await createdExpensesBox.clear();
      print('All Created Expenses cleared ✅');
      return 1;
    } catch (e) {
      print('Error while clearing Created Expenses ❌: $e');
      return 0;
    }
  }
}
