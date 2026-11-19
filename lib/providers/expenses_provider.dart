import 'package:flutter/material.dart';
import 'package:stockall/classes/payment_entry/payment_entry.dart';
import 'package:stockall/classes/temp_expenses/expense_category.dart';
import 'package:stockall/classes/temp_expenses/temp_expenses_class.dart';
import 'package:stockall/classes/temp_expenses/unsynced/created_expenses/created_expenses.dart';
import 'package:stockall/classes/temp_expenses/unsynced/deleted_expenses/deleted_expenses.dart';
import 'package:stockall/classes/temp_expenses/unsynced/updated/updated_expenses.dart';
import 'package:stockall/classes/temp_purchase/temp_purchase.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/local_database/expenses/expense_categories_func.dart';
import 'package:stockall/local_database/expenses/expenses_func.dart';
import 'package:stockall/local_database/expenses/unsync_funcs/created_expenses/created_expenses_func.dart';
import 'package:stockall/local_database/expenses/unsync_funcs/deleted_expenses/deleted_expenses_func.dart';
import 'package:stockall/local_database/expenses/unsync_funcs/updated_expenses/updated_expenses_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExpensesProvider extends ChangeNotifier {
  static final ExpensesProvider _instance =
      ExpensesProvider._internal();
  factory ExpensesProvider() => _instance;
  ExpensesProvider._internal();
  final supabase = Supabase.instance.client;
  final ConnectivityProvider connectivity =
      ConnectivityProvider();

  List<TempExpensesClass> expensesMain = [];
  List<ExpenseCategory> expenseCategories = [];
  String? selectedCategoryFilter;
  final Set<String> _fetchedDateKeys = {};
  int? _fetchedShopId;

  void setCategoryFilter(String? filter) {
    selectedCategoryFilter = filter;
    notifyListeners();
  }

  void clearCategoryFilter() {
    if (selectedCategoryFilter == null) return;
    selectedCategoryFilter = null;
    notifyListeners();
  }

  List<TempExpensesClass> applyCategoryFilter(
    List<TempExpensesClass> list,
  ) {
    final filter = selectedCategoryFilter;
    if (filter == null || filter.isEmpty) return list;
    if (filter.startsWith('custom:')) {
      final catUuid = filter.substring('custom:'.length);
      return list
          .where(
            (e) =>
                e.expenseType == ExpenseType.custom &&
                e.expenseCategoryUuid == catUuid,
          )
          .toList();
    }
    return list
        .where((e) => e.expenseType == filter)
        .toList();
  }

  String _dateKey(DateTime d) =>
      '${d.year}-${d.month}-${d.day}';
  bool _isRangeFetched(
    int shopId,
    DateTime start,
    DateTime end,
  ) {
    if (_fetchedShopId != shopId) return false;
    var cursor = DateTime(
      start.year,
      start.month,
      start.day,
    );
    final last = DateTime(end.year, end.month, end.day);
    while (!cursor.isAfter(last)) {
      if (!_fetchedDateKeys.contains(_dateKey(cursor)))
        return false;
      cursor = cursor.add(const Duration(days: 1));
    }
    return true;
  }

  void _markRangeFetched(
    int shopId,
    DateTime start,
    DateTime end,
  ) {
    if (_fetchedShopId != shopId) {
      _fetchedDateKeys.clear();
      _fetchedShopId = shopId;
    }
    var cursor = DateTime(
      start.year,
      start.month,
      start.day,
    );
    final last = DateTime(end.year, end.month, end.day);
    while (!cursor.isAfter(last)) {
      _fetchedDateKeys.add(_dateKey(cursor));
      cursor = cursor.add(const Duration(days: 1));
    }
  }

  void clearExpenses() {
    expensesMain.clear();
    expenseCategories.clear();
    selectedCategoryFilter = null;
    _fetchedDateKeys.clear();
    _fetchedShopId = null;
    mainLocalLog('Expenses Cleared');
    notifyListeners();
  }

  Future<void> addExpense(TempExpensesClass expense) async {
    expense.updatedAt = DateTime.now();
    expense.createdDate ??= DateTime.now();
    await ExpensesFunc().createExpenses(expense);
    await CreatedExpensesFunc().createExpenses(
      CreatedExpenses(expenses: expense),
    );
    await returnEventsLogProvider().createLog(
      returnEventsLogProvider(
        // ignore: use_build_context_synchronously
      ).expensesAdapter(expense, 1),
      // ignore: use_build_context_synchronously
    );
    await mainLocalLog('Mounted: Add Expense');
    await getExpensesOffline(shopId());
    notifyListeners();
    syncData();
  }

  //
  //
  //
  //
  //
  //
  //
  //

  Future<List<TempExpensesClass>> getExpenses(
    int shopId, {
    bool forceRefresh = false,
    bool fetchAll = false,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    await getExpensesOffline(shopId);
    final effectiveStart =
        startDate ??
        rangeStartDate ??
        dateSet ??
        resolveBusinessDate(DateTime.now());
    final effectiveEnd =
        endDate ??
        rangeEndDate ??
        dateSet ??
        effectiveStart;
    final windowStart = fourAm(effectiveStart);
    final windowEnd = fourAmNextDay(effectiveEnd);

    bool isOnline = await connectivity.isOnline();
    if (isOnline && ExpensesFunc().isSynced()) {
      if (!forceRefresh &&
          !fetchAll &&
          _isRangeFetched(
            shopId,
            effectiveStart,
            effectiveEnd,
          )) {
        return expensesMain;
      }
      try {
        var query = supabase
            .from('expenses')
            .select()
            .eq('shop_id', shopId);
        if (!fetchAll) {
          query = query
              .gte(
                'created_date',
                windowStart.toUtc().toIso8601String(),
              )
              .lt(
                'created_date',
                windowEnd.toUtc().toIso8601String(),
              );
        }
        final response = await query.order(
          'created_date',
          ascending: false,
        );
        await mainLocalLog(
          'Expenses Gotten: ${response.length}',
        );

        final fetched =
            (response as List)
                .map((e) => TempExpensesClass.fromJson(e))
                .toList();

        if (fetchAll) {
          expensesMain = fetched;
        } else {
          final fetchedUuids =
              fetched.map((e) => e.uuid).toSet();
          final outsideWindow =
              expensesMain.where((exp) {
                if (fetchedUuids.contains(exp.uuid))
                  return false;
                final dt = exp.createdDate;
                if (dt == null) return true;
                final inWindow =
                    !dt.isBefore(windowStart) &&
                    dt.isBefore(windowEnd);
                return !inWindow;
              }).toList();
          expensesMain = [...fetched, ...outsideWindow]
            ..sort(
              (a, b) => (b.createdDate ?? DateTime(0))
                  .compareTo(a.createdDate ?? DateTime(0)),
            );
          _markRangeFetched(
            shopId,
            effectiveStart,
            effectiveEnd,
          );
        }

        await ExpensesFunc().insertAllExpenses(
          expensesMain,
        );
        notifyListeners();
        return expensesMain;
      } catch (e) {
        await mainLocalLog(
          'Error Getting Expenses Online: ${e.toString()}',
        );
        notifyListeners();
        return [];
      }
    } else {
      try {
        expensesMain = ExpensesFunc().getExpenses();
        notifyListeners();
        return expensesMain;
      } catch (e) {
        await mainLocalLog(
          'Error Getting Expenses Offline: ${e.toString()}',
        );
        notifyListeners();
        return [];
      }
    }
  }

  Future<List<TempExpensesClass>> getExpensesOffline(
    int shopId,
  ) async {
    try {
      expensesMain = ExpensesFunc().getExpenses();
      notifyListeners();
      return expensesMain;
    } catch (e) {
      await mainLocalLog(
        'Error Getting Expenses Offline: ${e.toString()}',
      );
      notifyListeners();
      return [];
    }
  }

  //
  //
  //
  //
  //
  //
  //
  //
  //
  //
  //

  DateTime? dateSet;

  void clearDate() {
    dateSet = null;
    rangeStartDate = null;
    rangeEndDate = null;
    notifyListeners();
  }

  void setDate(DateTime date) {
    if (dateSet == null) {
      dateSet = date;
      rangeStartDate = null;
      rangeEndDate = null;
      mainLocalLog('Date set: $date');
      final sid = returnShopProvider().userShop()?.shopId;
      if (sid != null &&
          !_isRangeFetched(sid, date, date)) {
        getExpenses(sid, startDate: date, endDate: date);
      }
    } else {
      dateSet = null;
      mainLocalLog('Date Cleared');
    }
    notifyListeners();
  }

  DateTime? rangeStartDate;
  DateTime? rangeEndDate;

  void setRange(DateTime rangeStart, DateTime endOfrange) {
    rangeStartDate = rangeStart;
    rangeEndDate = endOfrange;
    mainLocalLog(
      'Date Range set: Start: $rangeStart End: $endOfrange ',
    );
    dateSet = null;
    final sid = returnShopProvider().userShop()?.shopId;
    if (sid != null &&
        !_isRangeFetched(sid, rangeStart, endOfrange)) {
      getExpenses(
        sid,
        startDate: rangeStart,
        endDate: endOfrange,
      );
    }
    notifyListeners();
  }

  List<TempExpensesClass> departmentExpenses() {
    return expensesMain.where((cat) {
      return returnDepartmentProvider()
          .matchesCurrentDepartment(
            departmentUuid: cat.departmentUuid,
          );
    }).toList();
  }

  List<TempExpensesClass> returnExpensesByDayOrWeek(
    BuildContext context,
  ) {
    if (returnShopProvider()
            .userShop()
            ?.manageDepartments ==
        true) {
      if (rangeStartDate != null) {
        return departmentExpenses().where((expense) {
          final created = expense.createdDate!.toUtc();
          return !created.isBefore(
                fourAm(rangeStartDate!),
              ) &&
              created.isBefore(
                fourAmNextDay(
                  rangeEndDate ??
                      resolveBusinessDate(DateTime.now()),
                ),
              );
        }).toList();
      } else {
        var currentDate =
            dateSet ?? resolveBusinessDate(DateTime.now());

        return departmentExpenses()
            .where(
              (expense) =>
                  !expense.createdDate!.isBefore(
                    fourAm(currentDate),
                  ) &&
                  expense.createdDate!.isBefore(
                    fourAmNextDay(currentDate),
                  ),
            )
            .toList();
      }
    } else {
      if (rangeStartDate != null) {
        if (authorization(
          authorized:
              Authorizations().viewAllTransactionRecords,
        )) {
          return expensesMain.where((expense) {
            final created = expense.createdDate!.toUtc();
            return !created.isBefore(
                  fourAm(rangeStartDate!),
                ) &&
                created.isBefore(
                  fourAmNextDay(
                    rangeEndDate ??
                        resolveBusinessDate(DateTime.now()),
                  ),
                );
          }).toList();
        } else {
          return expensesMain.where((expense) {
            final created = expense.createdDate!.toUtc();
            return !created.isBefore(
                  fourAm(rangeStartDate!),
                ) &&
                created.isBefore(
                  fourAmNextDay(
                    rangeEndDate ??
                        resolveBusinessDate(DateTime.now()),
                  ),
                ) &&
                expense.userId == currentUser().userId;
          }).toList();
        }
      } else {
        var currentDate =
            dateSet ?? resolveBusinessDate(DateTime.now());

        if (authorization(
          authorized:
              Authorizations().viewAllTransactionRecords,
        )) {
          return expensesMain
              .where(
                (expense) =>
                    !expense.createdDate!.isBefore(
                      fourAm(currentDate),
                    ) &&
                    expense.createdDate!.isBefore(
                      fourAmNextDay(currentDate),
                    ),
              )
              .toList();
        } else {
          return expensesMain
              .where(
                (expense) =>
                    !expense.createdDate!.isBefore(
                      fourAm(currentDate),
                    ) &&
                    expense.createdDate!.isBefore(
                      fourAmNextDay(currentDate),
                    ) &&
                    expense.userId == currentUser().userId,
              )
              .toList();
        }
      }
    }
  }

  //
  //
  //
  //
  //
  //
  //
  //
  //
  //
  Future<void> updateExpense(
    TempExpensesClass expense,
    BuildContext context,
  ) async {
    // bool isOnline = await connectivity.isOnline();
    expense.updatedAt = DateTime.now();
    await mainLocalLog(expense.uuid);
    // if (isOnline) {
    //   await supabase
    //       .from('expenses')
    //       .update(expense.toJson())
    //       .eq('uuid', expense.uuid!);
    //   await returnEventsLogProvider().createLog(
    //     returnEventsLogProvider().expensesAdapter(
    //       expense,
    //       2,
    //     ),
    //   );
    // } else {
    await ExpensesFunc().updateExpenses(expense);
    var containsCreated =
        CreatedExpensesFunc()
            .getExpenses()
            .where(
              (exp) => exp.expenses.uuid == expense.uuid,
            )
            .toList();
    if (containsCreated.isEmpty) {
      await UpdatedExpensesFunc().createUpdatedExpense(
        UpdatedExpenses(expenses: expense),
      );
    } else {
      await CreatedExpensesFunc().updateExpenses(
        CreatedExpenses(expenses: expense),
      );
    }
    await returnEventsLogProvider().createLog(
      returnEventsLogProvider(
        // ignore: use_build_context_synchronously
      ).expensesAdapter(expense, 2),
      // ignore: use_build_context_synchronously
    );
    // }
    if (context.mounted) {
      await getExpensesOffline(shopId());
    }
    notifyListeners();
    syncData();
  }
  //
  //
  //
  //
  //
  //
  //

  Future<void> deleteExpense(
    TempExpensesClass expenses,
    BuildContext context,
  ) async {
    // bool isOnline = await connectivity.isOnline();
    // if (isOnline) {
    //   await supabase
    //       .from('expenses')
    //       .delete()
    //       .eq('uuid', expenses.uuid!);
    //   await returnEventsLogProvider().createLog(
    //     returnEventsLogProvider(
    //       // ignore: use_build_context_synchronously
    //     ).expensesAdapter(expenses, 3),
    //     // ignore: use_build_context_synchronously
    //   );
    // } else {
    var containsCreated =
        CreatedExpensesFunc()
            .getExpenses()
            .where(
              (exp) => exp.expenses.uuid == expenses.uuid,
            )
            .toList();
    var containsUpdated =
        UpdatedExpensesFunc()
            .getExpenses()
            .where(
              (exp) => exp.expenses.uuid == expenses.uuid,
            )
            .toList();
    await ExpensesFunc().deleteExpenses(expenses.uuid!);

    if (containsCreated.isNotEmpty) {
      CreatedExpensesFunc().deleteExpenses(expenses.uuid!);
    } else {
      await DeletedExpensesFunc().createDeletedExpense(
        DeletedExpenses(
          expensesUuid: expenses.uuid!,
          shopId: returnShopProvider().userShop()!.shopId!,
        ),
      );
    }
    if (containsUpdated.isNotEmpty) {
      UpdatedExpensesFunc().deleteUpdatedExpense(
        expenses.uuid!,
      );
    }
    await returnEventsLogProvider().createLog(
      returnEventsLogProvider(
        // ignore: use_build_context_synchronously
      ).expensesAdapter(expenses, 3),
      // ignore: use_build_context_synchronously
    );
    // }

    if (context.mounted) {
      await getExpensesOffline(shopId());
    }
    notifyListeners();
    syncData();
  }

  //
  //
  //
  //
  //

  Future<void> createExpensesSync() async {
    try {
      bool isOnline = await connectivity.isOnline();
      // Prepare batch payload
      if (CreatedExpensesFunc().getExpenses().isNotEmpty &&
          isOnline) {
        final tempExpenses =
            CreatedExpensesFunc().getExpenses().toList();
        // for (var exp in tempExpenses) {
        //   await mainLocalLog(
        //     'Updated Time: ${exp.expenses.updatedAt?.toString()}',
        //   );
        // }
        // final payload =
        //     tempExpenses
        //         .map((p) => p.expenses.toJson())
        //         .toList();

        // Insert all at once

        int count = 0;
        for (var item in tempExpenses) {
          try {
            // Insert all at once
            await supabase
                .from('expenses')
                .insert(item.expenses.toJson());
            count++;
            await CreatedExpensesFunc().deleteExpenses(
              item.expenses.uuid!,
            );
          } on PostgrestException catch (e) {
            if (e.code == '23505') {
              if (item.expenses.isStockPurchase &&
                  item.expenses.purchaseUuid != null) {
                try {
                  // Keep the server row's uuid: other devices
                  // know the expense by it.
                  final payload = item.expenses.toJson()
                    ..remove('uuid');
                  await supabase
                      .from('expenses')
                      .update(payload)
                      .eq(
                        'purchase_uuid',
                        item.expenses.purchaseUuid!,
                      );
                } catch (_) {}
              }
              await CreatedExpensesFunc().deleteExpenses(
                item.expenses.uuid!,
              );
            } else if (e.code == '23503' &&
                item.expenses.isCustomCategory &&
                item.expenses.expenseCategoryUuid != null &&
                await _isCategoryMissingOnServer(
                  item.expenses.expenseCategoryUuid!,
                )) {
              // Its category was deleted before it reached the
              // server: keep the saved name, drop the link and
              // retry once. A stock purchase whose purchase is
              // not on the server yet stays queued instead.
              final fixed = await _clearMissingCategory(
                item.expenses,
              );
              try {
                await supabase
                    .from('expenses')
                    .insert(fixed.toJson());
                count++;
                await CreatedExpensesFunc().deleteExpenses(
                  fixed.uuid!,
                );
              } catch (retryError) {
                await mainLocalLog(
                  'Retry Failed For Created Expense ${fixed.name}: $retryError',
                );
              }
            }
            await mainLocalLog(
              'Error Synchronizing Created Expenses ${item.expenses.name}: $e',
            );
          }
        }

        await mainLocalLog(
          '$count items added successfully ✅',
        );
        // await CreatedExpensesFunc().clearExpenses();
        await mainLocalLog('Unsynced Expenses Cleared');
      }
    } catch (e) {
      await mainLocalLog(
        'Batch Expenses insert failed ❌: $e',
      );
    }
  }

  //
  //
  //
  //
  //

  Future<void> deleteExpensesSync() async {
    try {
      bool isOnline = await connectivity.isOnline();

      if (DeletedExpensesFunc()
              .getExpenseIds()
              .isNotEmpty &&
          isOnline) {
        final uuids =
            DeletedExpensesFunc()
                .getExpenseIds()
                .map((p) => p.expensesUuid)
                .toList();

        final data = await supabase
            .from('expenses')
            .delete()
            .inFilter(
              'uuid',
              uuids,
            ) // delete where id is in the list
            .select('uuid');

        await mainLocalLog(
          '${data.length} items deleted successfully ✅',
        );

        await DeletedExpensesFunc().clearDeletedExpenses();
        await mainLocalLog(
          'Unsynced deleted Expenses cleared',
        );
      }
    } catch (e) {
      await mainLocalLog(
        'Batch Expenses delete failed ❌: $e',
      );
    }
  }

  //
  //
  //

  Future<void> updateExpensesSync() async {
    try {
      bool isOnline = await connectivity.isOnline();
      await mainLocalLog(
        UpdatedExpensesFunc()
            .getExpenses()
            .length
            .toString(),
      );

      if (UpdatedExpensesFunc().getExpenses().isNotEmpty &&
          isOnline) {
        final updatedExpenses =
            UpdatedExpensesFunc().getExpenses();

        for (final updated in updatedExpenses) {
          final localExpenses = updated.expenses;

          localExpenses.updatedAt ??=
              DateTime.now().toLocal();

          if (localExpenses.uuid == null) {
            await mainLocalLog(
              'Local Expenses Uuid is Null',
            );
          }
          final remoteData =
              await supabase
                  .from('expenses')
                  .select('uuid, updated_at')
                  .eq('uuid', localExpenses.uuid!)
                  .maybeSingle();

          if (remoteData == null) {
            await supabase
                .from('expenses')
                .insert(localExpenses.toJson());
            await mainLocalLog(
              'Inserted Expenses with uuid ${localExpenses.uuid}',
            );
            await UpdatedExpensesFunc()
                .deleteUpdatedExpense(
                  localExpenses.uuid ?? '',
                );
          } else {
            final remoteUpdatedAtRaw =
                remoteData['updated_at'];
            final remoteUpdatedAt =
                remoteUpdatedAtRaw == null
                    ? null
                    : DateTime.parse(
                      remoteUpdatedAtRaw,
                    ).toUtc();

            localExpenses.updatedAt =
                (localExpenses.updatedAt ?? DateTime.now())
                    .toUtc(); // ✅ keep both UTC
            await mainLocalLog(
              "Local updatedAt: ${localExpenses.updatedAt}",
            );
            await mainLocalLog(
              "Remote updatedAt: $remoteUpdatedAt",
            );

            if (remoteUpdatedAt == null ||
                localExpenses.updatedAt!.isAfter(
                  remoteUpdatedAt,
                )) {
              await supabase
                  .from('expenses')
                  .update(localExpenses.toJson())
                  .eq('uuid', localExpenses.uuid!);
              await mainLocalLog(
                'Updated Expenses with uuid ${localExpenses.uuid}',
              );
              await UpdatedExpensesFunc()
                  .deleteUpdatedExpense(
                    localExpenses.uuid ?? '',
                  );
            } else {
              await mainLocalLog(
                'Skipped Expenses ${localExpenses.uuid}, remote is newer ✅',
              );
            }
          }
        }

        await UpdatedExpensesFunc().clearupdatedExpenses();
        await mainLocalLog(
          'Unsynced updated Expenses cleared',
        );
        await mainLocalLog(
          'Mounted, refreshing Expenses ✅',
        );
        await getExpenses(
          returnShopProvider().userShop()!.shopId!,
        );
      }
    } catch (e) {
      await mainLocalLog(
        'Batch Expenses update failed ❌: $e',
      );
    }
  }

  // ===========================================================================
  // Custom Expense Categories
  // ===========================================================================

  Future<List<ExpenseCategory>> getExpenseCategories(
    int shopId, {
    bool forceRefresh = false,
  }) async {
    expenseCategories = ExpenseCategoriesFunc()
        .getCategories(shopId: shopId);
    notifyListeners();

    final isOnline = await connectivity.isOnline();
    if (isOnline && ExpenseCategoriesFunc().isSynced()) {
      try {
        final response = await supabase
            .from('expense_categories')
            .select()
            .eq('shop_id', shopId)
            .order('name', ascending: true);
        final fetched =
            (response as List)
                .map((e) => ExpenseCategory.fromJson(e))
                .toList();
        expenseCategories = fetched;
        await ExpenseCategoriesFunc().insertAllCategories(
          fetched,
        );
        notifyListeners();
      } catch (e) {
        await mainLocalLog(
          'Error Getting Expense Categories: $e',
        );
      }
    }
    return expenseCategories;
  }

  /// Category label of [expense], with a custom category's current
  /// name (see [TempExpensesClass.categoryLabelWith]).
  String categoryLabelFor(TempExpensesClass expense) =>
      expense.categoryLabelWith(expenseCategories);

  bool isDuplicateCategoryName(
    int shopId,
    String name, {
    String? excludeUuid,
  }) {
    if (ExpenseType.isReservedName(name)) return true;
    final normalized = name.trim().toLowerCase();
    return expenseCategories.any(
      (c) =>
          c.shopId == shopId &&
          c.uuid != excludeUuid &&
          c.name.trim().toLowerCase() == normalized,
    );
  }

  Future<bool> createExpenseCategory({
    required int shopId,
    required String name,
    String? departmentUuid,
    String? departmentName,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty ||
        isDuplicateCategoryName(shopId, trimmed)) {
      return false;
    }
    final now = DateTime.now();
    final category = ExpenseCategory(
      uuid: uuidGen(),
      shopId: shopId,
      name: trimmed,
      departmentUuid: departmentUuid,
      departmentName: departmentName,
      createdAt: now,
      updatedAt: now,
    );
    await ExpenseCategoriesFunc().upsertCategory(category);
    await ExpenseCategoriesFunc().queueCreated(category);
    expenseCategories = ExpenseCategoriesFunc()
        .getCategories(shopId: shopId);
    notifyListeners();
    syncData();
    return true;
  }

  Future<bool> updateExpenseCategory(
    ExpenseCategory category,
    String newName,
  ) async {
    final trimmed = newName.trim();
    if (trimmed.isEmpty ||
        isDuplicateCategoryName(
          category.shopId,
          trimmed,
          excludeUuid: category.uuid,
        )) {
      return false;
    }
    category.name = trimmed;
    category.updatedAt = DateTime.now();
    await ExpenseCategoriesFunc().upsertCategory(category);

    final isQueuedCreated = ExpenseCategoriesFunc()
        .getCreatedQueue()
        .any((c) => c.category.uuid == category.uuid);
    if (isQueuedCreated) {
      await ExpenseCategoriesFunc().queueCreated(category);
    } else {
      await ExpenseCategoriesFunc().queueUpdated(category);
    }

    // Expenses show the current name through categoryLabelFor, so
    // no expense row changes on a rename.
    expenseCategories = ExpenseCategoriesFunc()
        .getCategories(shopId: category.shopId);
    expensesMain = ExpensesFunc().getExpenses();
    notifyListeners();
    syncData();
    return true;
  }

  Future<void> deleteExpenseCategory(
    ExpenseCategory category,
  ) async {
    await ExpenseCategoriesFunc().deleteCategory(
      category.uuid,
    );

    final isQueuedCreated = ExpenseCategoriesFunc()
        .getCreatedQueue()
        .any((c) => c.category.uuid == category.uuid);
    if (isQueuedCreated) {
      await ExpenseCategoriesFunc().removeCreated(
        category.uuid,
      );
    } else {
      await ExpenseCategoriesFunc().queueDeleted(
        category.uuid,
        category.shopId,
      );
    }
    await ExpenseCategoriesFunc().removeUpdated(
      category.uuid,
    );

    // Preserve historical expense records (ON DELETE SET NULL + keep snapshot name).
    // The queued copies change too, so an unsynced expense never
    // sends the deleted category's uuid.
    for (final exp in ExpensesFunc().getExpenses()) {
      if (exp.expenseCategoryUuid == category.uuid) {
        exp.expenseCategoryUuid = null;
        exp.expenseCategoryName = category.name;
        await _saveAndQueueExpense(exp);
      }
    }
    expenseCategories = ExpenseCategoriesFunc()
        .getCategories(shopId: category.shopId);
    expensesMain = ExpensesFunc().getExpenses();
    notifyListeners();
    syncData();
  }

  Future<void> createExpenseCategoriesSync() async {
    try {
      final isOnline = await connectivity.isOnline();
      final queue =
          ExpenseCategoriesFunc().getCreatedQueue();
      if (queue.isEmpty || !isOnline) return;
      for (final item in queue) {
        try {
          await supabase
              .from('expense_categories')
              .insert(item.category.toJson());
          await ExpenseCategoriesFunc().removeCreated(
            item.category.uuid,
          );
        } on PostgrestException catch (e) {
          if (e.code == '23505') {
            await _adoptServerCategory(item.category);
            await ExpenseCategoriesFunc().removeCreated(
              item.category.uuid,
            );
          }
          await mainLocalLog(
            'Error Syncing Created Expense Category ${item.category.name}: $e',
          );
        }
      }
    } catch (e) {
      await mainLocalLog(
        'Expense Categories create sync failed: $e',
      );
    }
  }

  Future<void> updateExpenseCategoriesSync() async {
    try {
      final isOnline = await connectivity.isOnline();
      final queue =
          ExpenseCategoriesFunc().getUpdatedQueue();
      if (queue.isEmpty || !isOnline) return;
      for (final item in queue) {
        try {
          await supabase
              .from('expense_categories')
              .update({
                'name': item.category.name,
                'updated_at':
                    (item.category.updatedAt ??
                            DateTime.now())
                        .toUtc()
                        .toIso8601String(),
              })
              .eq('uuid', item.category.uuid);
          await ExpenseCategoriesFunc().removeUpdated(
            item.category.uuid,
          );
        } catch (e) {
          await mainLocalLog(
            'Error Syncing Updated Expense Category ${item.category.name}: $e',
          );
        }
      }
    } catch (e) {
      await mainLocalLog(
        'Expense Categories update sync failed: $e',
      );
    }
  }

  Future<void> deleteExpenseCategoriesSync() async {
    try {
      final isOnline = await connectivity.isOnline();
      final queue =
          ExpenseCategoriesFunc().getDeletedQueue();
      if (queue.isEmpty || !isOnline) return;
      final uuids =
          queue.map((e) => e.categoryUuid).toList();
      await supabase
          .from('expense_categories')
          .delete()
          .inFilter('uuid', uuids);
      for (final item in queue) {
        await ExpenseCategoriesFunc().removeDeleted(
          item.categoryUuid,
        );
      }
    } catch (e) {
      await mainLocalLog(
        'Expense Categories delete sync failed: $e',
      );
    }
  }

  /// Saves [exp] locally and in its unsynced queue: the created
  /// copy if it was never synced, otherwise an update.
  Future<void> _saveAndQueueExpense(
    TempExpensesClass exp,
  ) async {
    await ExpensesFunc().updateExpenses(exp);
    final isQueuedCreated = CreatedExpensesFunc()
        .getExpenses()
        .any((c) => c.expenses.uuid == exp.uuid);
    if (isQueuedCreated) {
      await CreatedExpensesFunc().updateExpenses(
        CreatedExpenses(expenses: exp),
      );
    } else {
      await UpdatedExpensesFunc().createUpdatedExpense(
        UpdatedExpenses(expenses: exp),
      );
    }
  }

  /// True when category [categoryUuid] is not on the server.
  /// False on any error, so a failure never drops a link.
  Future<bool> _isCategoryMissingOnServer(
    String categoryUuid,
  ) async {
    try {
      final row =
          await supabase
              .from('expense_categories')
              .select('uuid')
              .eq('uuid', categoryUuid)
              .maybeSingle();
      return row == null;
    } catch (e) {
      await mainLocalLog(
        'Error Checking Expense Category $categoryUuid: $e',
      );
      return false;
    }
  }

  /// Drops the category link of queued created expense [queued]
  /// (keeping its saved name) in the local box and the queue.
  /// Returns the copy to send.
  Future<TempExpensesClass> _clearMissingCategory(
    TempExpensesClass queued,
  ) async {
    final localList =
        ExpensesFunc()
            .getExpenses()
            .where((e) => e.uuid == queued.uuid)
            .toList();
    final target =
        localList.isNotEmpty ? localList.first : queued;
    target.expenseCategoryUuid = null;
    if (localList.isNotEmpty) {
      await ExpensesFunc().updateExpenses(target);
    }
    await CreatedExpensesFunc().updateExpenses(
      CreatedExpenses(expenses: target),
    );
    expensesMain = ExpensesFunc().getExpenses();
    notifyListeners();
    return target;
  }

  /// [local] could not be created because the shop already has a
  /// category of that name (e.g. made on another device). Replaces
  /// it with the server's category and moves its expenses, and
  /// their queued copies, to the server uuid.
  Future<void> _adoptServerCategory(
    ExpenseCategory local,
  ) async {
    try {
      final response = await supabase
          .from('expense_categories')
          .select()
          .eq('shop_id', local.shopId);
      final normalized = local.name.trim().toLowerCase();
      final matches =
          (response as List)
              .map((e) => ExpenseCategory.fromJson(e))
              .where(
                (c) =>
                    c.name.trim().toLowerCase() == normalized,
              )
              .toList();
      // Same uuid: it was already created, nothing to move.
      if (matches.isEmpty || matches.first.uuid == local.uuid) {
        return;
      }
      final server = matches.first;
      await ExpenseCategoriesFunc().deleteCategory(local.uuid);
      await ExpenseCategoriesFunc().removeUpdated(local.uuid);
      await ExpenseCategoriesFunc().upsertCategory(server);
      for (final exp in ExpensesFunc().getExpenses()) {
        if (exp.expenseCategoryUuid == local.uuid) {
          exp.expenseCategoryUuid = server.uuid;
          exp.expenseCategoryName = server.name;
          await _saveAndQueueExpense(exp);
        }
      }
      expenseCategories = ExpenseCategoriesFunc()
          .getCategories(shopId: local.shopId);
      expensesMain = ExpensesFunc().getExpenses();
      notifyListeners();
    } catch (e) {
      await mainLocalLog(
        'Error Adopting Server Expense Category ${local.name}: $e',
      );
    }
  }

  // ===========================================================================
  // Staff Salary History
  // ===========================================================================

  List<TempExpensesClass> getSalaryHistoryForStaff(
    String staffUuid, {
    int? targetShopId,
  }) {
    final sid = targetShopId ?? shopId();
    return expensesMain
        .where(
          (e) =>
              e.shopId == sid &&
              e.isStaffSalary &&
              e.staffUuid == staffUuid,
        )
        .toList()
      ..sort(
        (a, b) => (b.createdDate ?? DateTime(0)).compareTo(
          a.createdDate ?? DateTime(0),
        ),
      );
  }

  /// True when the last [fetchSalaryHistoryForStaff] could not
  /// reach the server and returned local data, which may be
  /// incomplete.
  bool salaryHistoryIsLocal = false;

  /// Deletes local salary rows of [staffUuid] in the fetched
  /// window that the server did not return (deleted, or moved to
  /// another staff, on another device). Unsynced ones are kept.
  Future<void> _removeStaleSalaries(
    String staffUuid,
    int targetShopId, {
    required Set<String?> fetchedUuids,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queued = <String?>{
      ...CreatedExpensesFunc().getExpenses().map(
        (c) => c.expenses.uuid,
      ),
      ...UpdatedExpensesFunc().getExpenses().map(
        (u) => u.expenses.uuid,
      ),
    };
    final start = startDate == null ? null : fourAm(startDate);
    final end = endDate == null ? null : fourAmNextDay(endDate);
    for (final exp in ExpensesFunc().getExpenses()) {
      final uuid = exp.uuid;
      if (uuid == null ||
          exp.shopId != targetShopId ||
          !exp.isStaffSalary ||
          exp.staffUuid != staffUuid ||
          fetchedUuids.contains(uuid) ||
          queued.contains(uuid)) {
        continue;
      }
      final dt = exp.createdDate;
      if (start != null && (dt == null || dt.isBefore(start))) {
        continue;
      }
      if (end != null && (dt == null || !dt.isBefore(end))) {
        continue;
      }
      await ExpensesFunc().deleteExpenses(uuid);
    }
  }

  Future<List<TempExpensesClass>>
  fetchSalaryHistoryForStaff(
    String staffUuid,
    int targetShopId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final isOnline = await connectivity.isOnline();
    if (isOnline && ExpensesFunc().isSynced()) {
      try {
        var query = supabase
            .from('expenses')
            .select()
            .eq('shop_id', targetShopId)
            .eq('expense_type', ExpenseType.staffSalary)
            .eq('staff_uuid', staffUuid);
        if (startDate != null) {
          query = query.gte(
            'created_date',
            fourAm(startDate).toUtc().toIso8601String(),
          );
        }
        if (endDate != null) {
          query = query.lt(
            'created_date',
            fourAmNextDay(
              endDate,
            ).toUtc().toIso8601String(),
          );
        }
        final response = await query.order(
          'created_date',
          ascending: false,
        );
        final fetched =
            (response as List)
                .map((e) => TempExpensesClass.fromJson(e))
                .toList();
        for (final exp in fetched) {
          await ExpensesFunc().createExpenses(exp);
        }
        await _removeStaleSalaries(
          staffUuid,
          targetShopId,
          fetchedUuids: fetched.map((e) => e.uuid).toSet(),
          startDate: startDate,
          endDate: endDate,
        );
        salaryHistoryIsLocal = false;
        expensesMain = ExpensesFunc().getExpenses();
        notifyListeners();
        return fetched;
      } catch (e) {
        await mainLocalLog(
          'Error Fetching Staff Salary History: $e',
        );
      }
    }
    // Only the date windows loaded so far are on this device.
    salaryHistoryIsLocal = true;
    notifyListeners();
    var local = getSalaryHistoryForStaff(
      staffUuid,
      targetShopId: targetShopId,
    );
    if (startDate != null && endDate != null) {
      final start = fourAm(startDate);
      final end = fourAmNextDay(endDate);
      local =
          local
              .where(
                (e) =>
                    e.createdDate != null &&
                    !e.createdDate!.isBefore(start) &&
                    e.createdDate!.isBefore(end),
              )
              .toList();
    }
    return local;
  }

  // ===========================================================================
  // Stock Purchase -> Expense Synchronization (Idempotent, Paid-Amount Only)
  // ===========================================================================

  Future<void> syncPurchaseExpense(
    TempPurchase purchase,
  ) async {
    final purchaseUuid = purchase.uuid;
    if (purchaseUuid == null || purchaseUuid.isEmpty)
      return;

    final paidAmount = purchase.purchasePayments
        .fold<double>(0.0, (sum, p) => sum + p.amount);

    final existingList =
        ExpensesFunc()
            .getExpenses()
            .where((e) => e.purchaseUuid == purchaseUuid)
            .toList();
    var existing =
        existingList.isNotEmpty ? existingList.first : null;

    // Not loaded on this device: reuse the server's expense (and
    // its uuid) instead of creating a second one.
    if (existing == null) {
      existing = await _fetchServerPurchaseExpense(purchaseUuid);
      if (existing != null) {
        await ExpensesFunc().createExpenses(existing);
      }
    }

    if (paidAmount <= 0) {
      if (existing != null) {
        await _deleteExpenseRecord(existing);
        await getExpensesOffline(purchase.shopId);
        notifyListeners();
      }
      return;
    }

    final paymentEntries =
        purchase.purchasePayments
            .map(
              (p) => PaymentEntry(
                method: p.paymentMethod,
                amount: p.amount,
              ),
            )
            .toList();
    final paymentChannel =
        PaymentBreakdown(paymentEntries).label;
    final supplierSuffix =
        (purchase.supplierName != null &&
                purchase.supplierName!.trim().isNotEmpty)
            ? ' (${purchase.supplierName!.trim()})'
            : '';
    final shortRef =
        purchaseUuid.split('-').first.toUpperCase();
    final trackingPart =
        (purchase.trackingNumber != null &&
                purchase.trackingNumber!.trim().isNotEmpty)
            ? ' • Ref: ${purchase.trackingNumber!.trim()}'
            : '';
    final name = 'Stock Purchase$supplierSuffix';
    final description = 'Purchase #$shortRef$trackingPart';

    if (existing != null) {
      existing.name = name;
      existing.description = description;
      existing.amount = paidAmount;
      existing.expenseType = ExpenseType.stockPurchase;
      existing.paymentChannel = paymentChannel;
      existing.paymentEntries = paymentEntries;
      existing.departmentUuid = purchase.departmentUuid;
      existing.departmentName = purchase.departmentName;
      existing.updatedAt = DateTime.now();

      await ExpensesFunc().updateExpenses(existing);
      final existingUuid = existing.uuid;
      final isQueuedCreated = CreatedExpensesFunc()
          .getExpenses()
          .any((exp) => exp.expenses.uuid == existingUuid);
      if (isQueuedCreated) {
        await CreatedExpensesFunc().updateExpenses(
          CreatedExpenses(expenses: existing),
        );
      } else {
        await UpdatedExpensesFunc().createUpdatedExpense(
          UpdatedExpenses(expenses: existing),
        );
      }
    } else {
      final expense = TempExpensesClass(
        uuid: uuidGen(),
        shopId: purchase.shopId,
        name: name,
        description: description,
        amount: paidAmount,
        createdDate: purchase.createdAt,
        updatedAt: DateTime.now(),
        userId: purchase.staffId ?? currentUser().userId,
        creator: purchase.staffName ?? currentUser().name,
        departmentUuid: purchase.departmentUuid,
        departmentName: purchase.departmentName,
        expenseType: ExpenseType.stockPurchase,
        purchaseUuid: purchaseUuid,
        paymentChannel: paymentChannel,
        paymentEntries: paymentEntries,
      );
      await ExpensesFunc().createExpenses(expense);
      await CreatedExpensesFunc().createExpenses(
        CreatedExpenses(expenses: expense),
      );
    }

    await getExpensesOffline(purchase.shopId);
    notifyListeners();
    syncData();
  }

  /// The local Stock Purchase expense of purchase [purchaseUuid],
  /// or null when there is none on this device.
  TempExpensesClass? expenseForPurchase(String purchaseUuid) {
    for (final exp in ExpensesFunc().getExpenses()) {
      if (exp.purchaseUuid == purchaseUuid) return exp;
    }
    return null;
  }

  /// The server's expense for purchase [purchaseUuid], or null
  /// when offline, missing or on error.
  Future<TempExpensesClass?> _fetchServerPurchaseExpense(
    String purchaseUuid,
  ) async {
    try {
      if (!await connectivity.isOnline()) return null;
      final row =
          await supabase
              .from('expenses')
              .select()
              .eq('purchase_uuid', purchaseUuid)
              .maybeSingle();
      return row == null ? null : TempExpensesClass.fromJson(row);
    } catch (e) {
      await mainLocalLog(
        'Error Fetching Purchase Expense $purchaseUuid: $e',
      );
      return null;
    }
  }

  Future<void> deletePurchaseExpense(
    String purchaseUuid,
  ) async {
    final existingList =
        ExpensesFunc()
            .getExpenses()
            .where((e) => e.purchaseUuid == purchaseUuid)
            .toList();
    if (existingList.isEmpty) return;
    for (final existing in existingList) {
      await _deleteExpenseRecord(existing);
    }
    await getExpensesOffline(shopId());
    notifyListeners();
    syncData();
  }

  Future<void> _deleteExpenseRecord(
    TempExpensesClass expense,
  ) async {
    final expUuid = expense.uuid;
    if (expUuid == null) return;
    final containsCreated =
        CreatedExpensesFunc()
            .getExpenses()
            .where((exp) => exp.expenses.uuid == expUuid)
            .toList();
    final containsUpdated =
        UpdatedExpensesFunc()
            .getExpenses()
            .where((exp) => exp.expenses.uuid == expUuid)
            .toList();
    await ExpensesFunc().deleteExpenses(expUuid);
    if (containsCreated.isNotEmpty) {
      await CreatedExpensesFunc().deleteExpenses(expUuid);
    } else {
      await DeletedExpensesFunc().createDeletedExpense(
        DeletedExpenses(
          expensesUuid: expUuid,
          shopId: expense.shopId,
        ),
      );
    }
    if (containsUpdated.isNotEmpty) {
      await UpdatedExpensesFunc().deleteUpdatedExpense(
        expUuid,
      );
    }
  }
}
