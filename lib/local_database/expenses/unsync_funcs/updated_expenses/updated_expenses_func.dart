import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_expenses/unsynced/updated/updated_expenses.dart';

class UpdatedExpensesFunc {
  static final UpdatedExpensesFunc instance =
      UpdatedExpensesFunc._internal();
  factory UpdatedExpensesFunc() => instance;
  UpdatedExpensesFunc._internal();

  Box<UpdatedExpenses>? _updatedExpensesBox;
  final String updatedExpensesBoxName =
      'updatedExpensesBoxStockall';

  /// Initialize Hive box + adapter safely
  Future<void> init() async {
    // Check if adapter is already registered
    if (!Hive.isAdapterRegistered(
      UpdatedExpensesAdapter().typeId,
    )) {
      Hive.registerAdapter(UpdatedExpensesAdapter());
      print('Updated Expenses Adapter registered ✅');
    }

    // Open the box only if it isn’t already open
    if (!Hive.isBoxOpen(updatedExpensesBoxName)) {
      _updatedExpensesBox =
          await Hive.openBox<UpdatedExpenses>(
            updatedExpensesBoxName,
          );
      print('Updated Expenses Box opened ✅');
    } else {
      _updatedExpensesBox = Hive.box<UpdatedExpenses>(
        updatedExpensesBoxName,
      );
      print('Updated Expenses Box already open, reused ✅');
    }
  }

  /// Safe getter for the box
  Box<UpdatedExpenses> get updatedExpensesBox {
    if (_updatedExpensesBox == null) {
      throw Exception(
        "Updated Expenses Func not initialized. Call await updated Expenses Func.instance.init() first.",
      );
    }
    return _updatedExpensesBox!;
  }

  List<UpdatedExpenses> getExpenses() {
    return updatedExpensesBox.values.toList();
  }

  Future<int> createUpdatedExpense(
    UpdatedExpenses updatedExpense,
  ) async {
    try {
      updatedExpense.expenses.updatedAt = DateTime.now()
          .toUtc()
          .add(const Duration(hours: 1));
      await updatedExpensesBox.put(
        updatedExpense.expenses.uuid,
        updatedExpense,
      );
      print(
        'Offline updated Expense inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      print(
        'Offline updated Expense insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> deleteUpdatedExpense(String uuid) async {
    try {
      print(
        updatedExpensesBox.containsKey(uuid).toString(),
      );
      await updatedExpensesBox.delete(uuid);
      print('Updated Expense Deleted');
      return 1;
    } catch (e) {
      print('Expense Delete Failed: ${e.toString()}');
      return 0;
    }
  }

  Future<int> clearupdatedExpenses() async {
    try {
      await updatedExpensesBox.clear();
      print('All updated Expenses cleared ✅');
      return 1;
    } catch (e) {
      print('Error while clearing updated Expenses ❌: $e');
      return 0;
    }
  }
}
