import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_expenses/unsynced/deleted_expenses/deleted_expenses.dart';

class DeletedExpensesFunc {
  static final DeletedExpensesFunc instance =
      DeletedExpensesFunc._internal();
  factory DeletedExpensesFunc() => instance;
  DeletedExpensesFunc._internal();

  Box<DeletedExpenses>? _deletedExpensesBox;
  final String deletedExpensesBoxName =
      'deletedExpensesBoxStockall';

  /// Initialize Hive box + adapter safely
  Future<void> init() async {
    // Check if adapter is already registered
    if (!Hive.isAdapterRegistered(
      DeletedExpensesAdapter().typeId,
    )) {
      Hive.registerAdapter(DeletedExpensesAdapter());
      print('Deleted Expenses Adapter registered ✅');
    }

    // Open the box only if it isn’t already open
    if (!Hive.isBoxOpen(deletedExpensesBoxName)) {
      _deletedExpensesBox =
          await Hive.openBox<DeletedExpenses>(
            deletedExpensesBoxName,
          );
      print('Deleted Expenses Box opened ✅');
    } else {
      _deletedExpensesBox = Hive.box<DeletedExpenses>(
        deletedExpensesBoxName,
      );
      print('Deleted Expenses Box already open, reused ✅');
    }
  }

  /// Safe getter for the box
  Box<DeletedExpenses> get deletedExpensesBox {
    if (_deletedExpensesBox == null) {
      throw Exception(
        "Deleted Expenses Func not initialized. Call await Deleted Expenses Func.instance.init() first.",
      );
    }
    return _deletedExpensesBox!;
  }

  List<DeletedExpenses> getExpenseIds() {
    return deletedExpensesBox.values.toList();
  }

  Future<int> insertAllDeletedExpenses(
    List<DeletedExpenses> deletedExpenses,
  ) async {
    try {
      for (var Expense in deletedExpenses) {
        await deletedExpensesBox.add(Expense);
      }
      print("Offline Deleted Expenses inserted ✅");
      return 1;
    } catch (e) {
      print(
        'Offline Deleted Expenses insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> createDeletedExpense(
    DeletedExpenses deletedExpense,
  ) async {
    try {
      await deletedExpensesBox.add(deletedExpense);
      print(
        'Offline Deleted Expense inserted successfully ✅',
      );
      return 1;
    } catch (e) {
      print(
        'Offline Deleted Expense insertion failed ❌: $e',
      );
      return 0;
    }
  }

  Future<int> clearDeletedExpenses() async {
    try {
      await deletedExpensesBox.clear();
      print('All Deleted Expenses cleared ✅');
      return 1;
    } catch (e) {
      print('Error while clearing Deleted Expenses ❌: $e');
      return 0;
    }
  }
}
