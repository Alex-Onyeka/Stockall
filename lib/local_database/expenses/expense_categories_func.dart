import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_expenses/expense_category.dart';
import 'package:stockall/classes/temp_expenses/unsynced/created_expense_categories/created_expense_category.dart';
import 'package:stockall/classes/temp_expenses/unsynced/deleted_expense_categories/deleted_expense_category.dart';
import 'package:stockall/classes/temp_expenses/unsynced/updated_expense_categories/updated_expense_category.dart';
import 'package:stockall/local_database/hive_box_helper.dart';
import 'package:stockall/main.dart';

class ExpenseCategoriesFunc {
  static final ExpenseCategoriesFunc instance =
      ExpenseCategoriesFunc._internal();
  factory ExpenseCategoriesFunc() => instance;
  ExpenseCategoriesFunc._internal();

  Box<ExpenseCategory>? _categoriesBox;
  Box<CreatedExpenseCategory>? _createdBox;
  Box<UpdatedExpenseCategory>? _updatedBox;
  Box<DeletedExpenseCategory>? _deletedBox;

  static const String categoriesBoxName = 'expenseCategoriesBoxStockall';
  static const String createdBoxName = 'createdExpenseCategoriesBoxStockall';
  static const String updatedBoxName = 'updatedExpenseCategoriesBoxStockall';
  static const String deletedBoxName = 'deletedExpenseCategoriesBoxStockall';

  Future<void> init() async {
    try {
      safeRegisterAdapter(ExpenseCategoryAdapter());
      safeRegisterAdapter(CreatedExpenseCategoryAdapter());
      safeRegisterAdapter(UpdatedExpenseCategoryAdapter());
      safeRegisterAdapter(DeletedExpenseCategoryAdapter());

      _categoriesBox = await openBoxSafely<ExpenseCategory>(categoriesBoxName);
      _createdBox = await openBoxSafely<CreatedExpenseCategory>(createdBoxName);
      _updatedBox = await openBoxSafely<UpdatedExpenseCategory>(updatedBoxName);
      _deletedBox = await openBoxSafely<DeletedExpenseCategory>(deletedBoxName);
      await mainLocalLog('Expense Categories Boxes Initialized');
    } catch (e, s) {
      await mainLocalLog(
        'Error Initializing Expense Categories Boxes: $e',
        error: e,
        stackTrace: s,
      );
    }
  }

  List<ExpenseCategory> getCategories({int? shopId}) {
    if (_categoriesBox == null) return [];
    final all = _categoriesBox!.values.toList();
    final filtered =
        shopId == null
            ? all
            : all.where((c) => c.shopId == shopId).toList();
    filtered.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
    return filtered;
  }

  Future<void> insertAllCategories(List<ExpenseCategory> categories) async {
    if (_categoriesBox == null) return;
    await _categoriesBox!.clear();
    for (final cat in categories) {
      await _categoriesBox!.put(cat.uuid, cat);
    }
  }

  Future<void> upsertCategory(ExpenseCategory category) async {
    if (_categoriesBox == null) return;
    await _categoriesBox!.put(category.uuid, category);
  }

  Future<void> deleteCategory(String uuid) async {
    if (_categoriesBox == null) return;
    await _categoriesBox!.delete(uuid);
  }

  // Unsynced queues
  List<CreatedExpenseCategory> getCreatedQueue() =>
      _createdBox?.values.toList() ?? [];

  Future<void> queueCreated(ExpenseCategory category) async {
    await _createdBox?.put(
      category.uuid,
      CreatedExpenseCategory(category: category),
    );
  }

  Future<void> removeCreated(String uuid) async {
    await _createdBox?.delete(uuid);
  }

  List<UpdatedExpenseCategory> getUpdatedQueue() =>
      _updatedBox?.values.toList() ?? [];

  Future<void> queueUpdated(ExpenseCategory category) async {
    await _updatedBox?.put(
      category.uuid,
      UpdatedExpenseCategory(category: category),
    );
  }

  Future<void> removeUpdated(String uuid) async {
    await _updatedBox?.delete(uuid);
  }

  List<DeletedExpenseCategory> getDeletedQueue() =>
      _deletedBox?.values.toList() ?? [];

  Future<void> queueDeleted(String uuid, int shopId) async {
    await _deletedBox?.put(
      uuid,
      DeletedExpenseCategory(categoryUuid: uuid, shopId: shopId),
    );
  }

  Future<void> removeDeleted(String uuid) async {
    await _deletedBox?.delete(uuid);
  }

  Future<void> clearAllQueues() async {
    await _createdBox?.clear();
    await _updatedBox?.clear();
    await _deletedBox?.clear();
  }

  Future<void> clearAllCategories() async {
    await _categoriesBox?.clear();
    await clearAllQueues();
  }

  bool isSynced() {
    return getCreatedQueue().isEmpty &&
        getUpdatedQueue().isEmpty &&
        getDeletedQueue().isEmpty &&
        returnData().isSyncing == false;
  }
}
