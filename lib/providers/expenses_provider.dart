import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_expenses/temp_expenses_class.dart';
import 'package:stockall/classes/temp_expenses/unsynced/created_expenses/created_expenses.dart';
import 'package:stockall/classes/temp_expenses/unsynced/deleted_expenses/deleted_expenses.dart';
import 'package:stockall/classes/temp_expenses/unsynced/updated/updated_expenses.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/local_database/expenses/expenses_func.dart';
import 'package:stockall/local_database/expenses/unsync_funcs/created_expenses/created_expenses_func.dart';
import 'package:stockall/local_database/expenses/unsync_funcs/deleted_expenses/deleted_expenses_func.dart';
import 'package:stockall/local_database/expenses/unsync_funcs/updated_expenses/updated_expenses_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/connectivity_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExpensesProvider extends ChangeNotifier {
  static final ExpensesProvider _instance = ExpensesProvider._internal();
  factory ExpensesProvider() => _instance;
  ExpensesProvider._internal();
  final supabase = Supabase.instance.client;
  final ConnectivityProvider connectivity = ConnectivityProvider();

  List<TempExpensesClass> expensesMain = [];
  final Set<String> _fetchedDateKeys = {};
  int? _fetchedShopId;

  String _dateKey(DateTime d) => '${d.year}-${d.month}-${d.day}';

  bool _isRangeFetched(int shopId, DateTime start, DateTime end) {
    if (_fetchedShopId != shopId) return false;
    var cursor = DateTime(start.year, start.month, start.day);
    final last = DateTime(end.year, end.month, end.day);
    while (!cursor.isAfter(last)) {
      if (!_fetchedDateKeys.contains(_dateKey(cursor))) return false;
      cursor = cursor.add(const Duration(days: 1));
    }
    return true;
  }

  void _markRangeFetched(int shopId, DateTime start, DateTime end) {
    if (_fetchedShopId != shopId) {
      _fetchedDateKeys.clear();
      _fetchedShopId = shopId;
    }
    var cursor = DateTime(start.year, start.month, start.day);
    final last = DateTime(end.year, end.month, end.day);
    while (!cursor.isAfter(last)) {
      _fetchedDateKeys.add(_dateKey(cursor));
      cursor = cursor.add(const Duration(days: 1));
    }
  }

  void clearExpenses() {
    expensesMain.clear();
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
        endDate ?? rangeEndDate ?? dateSet ?? effectiveStart;
    final windowStart = fourAm(effectiveStart);
    final windowEnd = fourAmNextDay(effectiveEnd);

    bool isOnline = await connectivity.isOnline();
    if (isOnline && ExpensesFunc().isSynced()) {
      if (!forceRefresh &&
          !fetchAll &&
          _isRangeFetched(shopId, effectiveStart, effectiveEnd)) {
        return expensesMain;
      }
      try {
        var query = supabase
            .from('expenses')
            .select()
            .eq('shop_id', shopId);
        if (!fetchAll) {
          query = query
              .gte('created_date', windowStart.toUtc().toIso8601String())
              .lt('created_date', windowEnd.toUtc().toIso8601String());
        }
        final response = await query.order('created_date', ascending: false);
        await mainLocalLog('Expenses Gotten: ${response.length}');

        final fetched =
            (response as List)
                .map((e) => TempExpensesClass.fromJson(e))
                .toList();

        if (fetchAll) {
          expensesMain = fetched;
        } else {
          final fetchedUuids = fetched.map((e) => e.uuid).toSet();
          final outsideWindow =
              expensesMain.where((exp) {
                if (fetchedUuids.contains(exp.uuid)) return false;
                final dt = exp.createdDate;
                if (dt == null) return true;
                final inWindow =
                    !dt.isBefore(windowStart) && dt.isBefore(windowEnd);
                return !inWindow;
              }).toList();
          expensesMain = [...fetched, ...outsideWindow]
            ..sort(
              (a, b) => (b.createdDate ?? DateTime(0))
                  .compareTo(a.createdDate ?? DateTime(0)),
            );
          _markRangeFetched(shopId, effectiveStart, effectiveEnd);
        }

        await ExpensesFunc().insertAllExpenses(expensesMain);
        notifyListeners();
        return expensesMain;
      } catch (e) {
        await mainLocalLog('Error Getting Expenses Online: ${e.toString()}');
        notifyListeners();
        return [];
      }
    } else {
      try {
        expensesMain = ExpensesFunc().getExpenses();
        notifyListeners();
        return expensesMain;
      } catch (e) {
        await mainLocalLog('Error Getting Expenses Offline: ${e.toString()}');
        notifyListeners();
        return [];
      }
    }
  }

  Future<List<TempExpensesClass>> getExpensesOffline(int shopId) async {
    try {
      expensesMain = ExpensesFunc().getExpenses();
      notifyListeners();
      return expensesMain;
    } catch (e) {
      await mainLocalLog('Error Getting Expenses Offline: ${e.toString()}');
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
      if (sid != null && !_isRangeFetched(sid, date, date)) {
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
    mainLocalLog('Date Range set: Start: $rangeStart End: $endOfrange ');
    dateSet = null;
    final sid = returnShopProvider().userShop()?.shopId;
    if (sid != null && !_isRangeFetched(sid, rangeStart, endOfrange)) {
      getExpenses(sid, startDate: rangeStart, endDate: endOfrange);
    }
    notifyListeners();
  }

  List<TempExpensesClass> departmentExpenses() {
    if (returnShopProvider().userShop()?.manageDepartments == true) {
      if (!authorization(authorized: Authorizations().viewAllDepartments)) {
        return expensesMain.where((cat) {
          return cat.departmentUuid ==
              returnDepartmentProvider().currentDepartment()?.uuid;
          // }
        }).toList();
      } else {
        if (returnDepartmentProvider().currentDepartment()?.uuid == null) {
          return expensesMain;
        } else {
          return expensesMain.where((cat) {
            return cat.departmentUuid ==
                returnDepartmentProvider().currentDepartment()?.uuid;
          }).toList();
        }
      }
    } else {
      return expensesMain;
    }
  }

  List<TempExpensesClass> returnExpensesByDayOrWeek(BuildContext context) {
    if (returnShopProvider().userShop()?.manageDepartments == true) {
      if (rangeStartDate != null) {
        return departmentExpenses().where((expense) {
          final created = expense.createdDate!.toUtc();
          return !created.isBefore(fourAm(rangeStartDate!)) &&
              created.isBefore(
                fourAmNextDay(
                  rangeEndDate ?? resolveBusinessDate(DateTime.now()),
                ),
              );
        }).toList();
      } else {
        var currentDate = dateSet ?? resolveBusinessDate(DateTime.now());

        return departmentExpenses()
            .where(
              (expense) =>
                  !expense.createdDate!.isBefore(fourAm(currentDate)) &&
                  expense.createdDate!.isBefore(fourAmNextDay(currentDate)),
            )
            .toList();
      }
    } else {
      if (rangeStartDate != null) {
        if (authorization(
          authorized: Authorizations().viewAllTransactionRecords,
        )) {
          return expensesMain.where((expense) {
            final created = expense.createdDate!.toUtc();
            return !created.isBefore(fourAm(rangeStartDate!)) &&
                created.isBefore(
                  fourAmNextDay(
                    rangeEndDate ?? resolveBusinessDate(DateTime.now()),
                  ),
                );
          }).toList();
        } else {
          return expensesMain.where((expense) {
            final created = expense.createdDate!.toUtc();
            return !created.isBefore(fourAm(rangeStartDate!)) &&
                created.isBefore(
                  fourAmNextDay(
                    rangeEndDate ?? resolveBusinessDate(DateTime.now()),
                  ),
                ) &&
                expense.userId == currentUser().userId;
          }).toList();
        }
      } else {
        var currentDate = dateSet ?? resolveBusinessDate(DateTime.now());

        if (authorization(
          authorized: Authorizations().viewAllTransactionRecords,
        )) {
          return expensesMain
              .where(
                (expense) =>
                    !expense.createdDate!.isBefore(fourAm(currentDate)) &&
                    expense.createdDate!.isBefore(fourAmNextDay(currentDate)),
              )
              .toList();
        } else {
          return expensesMain
              .where(
                (expense) =>
                    !expense.createdDate!.isBefore(fourAm(currentDate)) &&
                    expense.createdDate!.isBefore(fourAmNextDay(currentDate)) &&
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
            .where((exp) => exp.expenses.uuid == expense.uuid)
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
            .where((exp) => exp.expenses.uuid == uuid)
            .toList();
    var containsUpdated =
        UpdatedExpensesFunc()
            .getExpenses()
            .where((exp) => exp.expenses.uuid == expenses.uuid)
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
      UpdatedExpensesFunc().deleteUpdatedExpense(expenses.uuid!);
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
      if (CreatedExpensesFunc().getExpenses().isNotEmpty && isOnline) {
        final tempExpenses = CreatedExpensesFunc().getExpenses().toList();
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
            await CreatedExpensesFunc().deleteExpenses(item.expenses.uuid!);
          } on PostgrestException catch (e) {
            if (e.code == '23505') {
              await CreatedExpensesFunc().deleteExpenses(item.expenses.uuid!);
            }
            await mainLocalLog(
              'Error Synchronizing Created Expenses ${item.expenses.name}: $e',
            );
          }
        }

        await mainLocalLog('$count items added successfully ✅');
        // await CreatedExpensesFunc().clearExpenses();
        await mainLocalLog('Unsynced Expenses Cleared');
      }
    } catch (e) {
      await mainLocalLog('Batch Expenses insert failed ❌: $e');
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

      if (DeletedExpensesFunc().getExpenseIds().isNotEmpty && isOnline) {
        final uuids =
            DeletedExpensesFunc()
                .getExpenseIds()
                .map((p) => p.expensesUuid)
                .toList();

        final data =
            await supabase
                .from('expenses')
                .delete()
                .inFilter('uuid', uuids) // delete where id is in the list
                .select('uuid');

        await mainLocalLog('${data.length} items deleted successfully ✅');

        await DeletedExpensesFunc().clearDeletedExpenses();
        await mainLocalLog('Unsynced deleted Expenses cleared');
      }
    } catch (e) {
      await mainLocalLog('Batch Expenses delete failed ❌: $e');
    }
  }

  //
  //
  //

  Future<void> updateExpensesSync() async {
    try {
      bool isOnline = await connectivity.isOnline();
      await mainLocalLog(UpdatedExpensesFunc().getExpenses().length.toString());

      if (UpdatedExpensesFunc().getExpenses().isNotEmpty && isOnline) {
        final updatedExpenses = UpdatedExpensesFunc().getExpenses();

        for (final updated in updatedExpenses) {
          final localExpenses = updated.expenses;

          localExpenses.updatedAt ??= DateTime.now().toLocal();

          if (localExpenses.uuid == null) {
            await mainLocalLog('Local Expenses Uuid is Null');
          }
          final remoteData =
              await supabase
                  .from('expenses')
                  .select('uuid, updated_at')
                  .eq('uuid', localExpenses.uuid!)
                  .maybeSingle();

          if (remoteData == null) {
            await supabase.from('expenses').insert(localExpenses.toJson());
            await mainLocalLog(
              'Inserted Expenses with uuid ${localExpenses.uuid}',
            );
            await UpdatedExpensesFunc().deleteUpdatedExpense(
              localExpenses.uuid ?? '',
            );
          } else {
            final remoteUpdatedAtRaw = remoteData['updated_at'];
            final remoteUpdatedAt =
                remoteUpdatedAtRaw == null
                    ? null
                    : DateTime.parse(remoteUpdatedAtRaw).toUtc();

            localExpenses.updatedAt =
                (localExpenses.updatedAt ?? DateTime.now())
                    .toUtc(); // ✅ keep both UTC
            await mainLocalLog("Local updatedAt: ${localExpenses.updatedAt}");
            await mainLocalLog("Remote updatedAt: $remoteUpdatedAt");

            if (remoteUpdatedAt == null ||
                localExpenses.updatedAt!.isAfter(remoteUpdatedAt)) {
              await supabase
                  .from('expenses')
                  .update(localExpenses.toJson())
                  .eq('uuid', localExpenses.uuid!);
              await mainLocalLog(
                'Updated Expenses with uuid ${localExpenses.uuid}',
              );
              await UpdatedExpensesFunc().deleteUpdatedExpense(
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
        await mainLocalLog('Unsynced updated Expenses cleared');
        await mainLocalLog('Mounted, refreshing Expenses ✅');
        await getExpenses(returnShopProvider().userShop()!.shopId!);
      }
    } catch (e) {
      await mainLocalLog('Batch Expenses update failed ❌: $e');
    }
  }

  //
  //
  //
  //
}
