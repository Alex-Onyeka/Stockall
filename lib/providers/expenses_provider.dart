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
  final supabase = Supabase.instance.client;
  final ConnectivityProvider connectivity =
      ConnectivityProvider();

  List<TempExpensesClass> expenses = [];
  void clearExpenses() {
    expenses.clear();
    print('Expenses Cleared');
    notifyListeners();
  }

  Future<void> addExpense(
    TempExpensesClass expense,
    // BuildContext context,
  ) async {
    bool isOnline = await connectivity.isOnline();
    expense.updatedAt = DateTime.now();
    if (isOnline) {
      Map<String, dynamic> res =
          await supabase
              .from('expenses')
              .insert(expense.toJson())
              .select()
              .single();

      TempExpensesClass exp = TempExpensesClass.fromJson(
        res,
      );
      await ExpensesFunc().createExpenses(exp);
      await returnEventsLogProvider().createLog(
        returnEventsLogProvider(
          // ignore: use_build_context_synchronously
        ).expensesAdapter(expense, 1),
        // ignore: use_build_context_synchronously
      );
    } else {
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
    }
    // if (context.mounted) {
    print('Mounted: Add Expense');
    await getExpenses(shopId());
    // } else {
    //   print('Context not Mounted for create Expenses');
    // }
    notifyListeners();
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
    int shopId,
  ) async {
    bool isOnline = await connectivity.isOnline();
    if (isOnline) {
      final response = await supabase
          .from('expenses')
          .select()
          .eq('shop_id', shopId)
          .order('created_date', ascending: false);
      print('Expenses Gotten: Get Expenses');

      expenses =
          (response as List)
              .map((e) => TempExpensesClass.fromJson(e))
              .toList();

      await ExpensesFunc().insertAllExpenses(expenses);
    } else {
      expenses = ExpensesFunc().getExpenses();
    }
    notifyListeners();
    return expenses;
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

  DateTime? singleDay;
  DateTime? weekStartDate;

  bool setDate = false;
  bool isDateSet = false;
  String? dateSet;

  void openExpenseDatePicker() {
    setDate = true;
    print('Opened Date Picker');
    notifyListeners();
  }

  void setExpenseDay(DateTime day) {
    singleDay = day;
    weekStartDate = null;
    isDateSet = true;
    setDate = false;
    dateSet = 'For ${formatDateTime(day)}';
    print('Date Set');
    notifyListeners();
  }

  void setExpenseWeek(
    DateTime weekStart,
    DateTime endOfWeek,
  ) {
    weekStartDate = weekStart;
    singleDay = null;
    isDateSet = true;
    setDate = false;
    dateSet =
        '${formatDateWithoutYear(weekStart)} - ${formatDateWithoutYear(endOfWeek)}';
    print('Week Set');
    notifyListeners();
  }

  void clearExpenseDate() {
    singleDay = null;
    weekStartDate = null;
    setDate = false;
    isDateSet = false;
    dateSet = null;
    print('Date Closed');
    notifyListeners();
  }

  List<TempExpensesClass> returnExpensesByDayOrWeek(
    BuildContext context,
    List<TempExpensesClass> expenses,
  ) {
    if (weekStartDate != null) {
      final weekStartUtc = weekStartDate!.toUtc();
      final weekEndUtc = weekStartUtc.add(
        const Duration(days: 7),
      ); // end exclusive

      if (authorization(
        authorized:
            Authorizations().viewAllTransactionRecords,
      )) {
        return expenses.where((expenses) {
          final created = expenses.createdDate!.toUtc();
          return created.isAfter(
                weekStartUtc.subtract(
                  const Duration(seconds: 1),
                ),
              ) &&
              created.isBefore(weekEndUtc);
        }).toList();
      } else {
        return expenses.where((expense) {
          final created = expense.createdDate!.toUtc();
          return created.isAfter(
                weekStartUtc.subtract(
                  const Duration(seconds: 1),
                ),
              ) &&
              created.isBefore(weekEndUtc) &&
              expense.userId == currentUser().userId;
        }).toList();
      }
    }

    final targetDate =
        (singleDay ?? DateTime.now()).toUtc();
    final startOfDay = DateTime.utc(
      targetDate.year,
      targetDate.month,
      targetDate.day,
    );
    final endOfDay = startOfDay.add(
      const Duration(days: 1),
    );
    if (authorization(
      authorized:
          Authorizations().viewAllTransactionRecords,
    )) {
      return expenses.where((expense) {
        final created = expense.createdDate!.toUtc();
        return created.isAfter(
              startOfDay.subtract(
                const Duration(seconds: 1),
              ),
            ) &&
            created.isBefore(endOfDay);
      }).toList();
    } else {
      return expenses.where((expense) {
        final created = expense.createdDate!.toUtc();
        return created.isAfter(
              startOfDay.subtract(
                const Duration(seconds: 1),
              ),
            ) &&
            created.isBefore(endOfDay) &&
            expense.userId == currentUser().userId;
      }).toList();
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
    bool isOnline = await connectivity.isOnline();
    expense.updatedAt = DateTime.now();
    print(expense.uuid);
    if (isOnline) {
      await supabase
          .from('expenses')
          .update(expense.toJson())
          .eq('uuid', expense.uuid!);
      await returnEventsLogProvider().createLog(
        returnEventsLogProvider().expensesAdapter(
          expense,
          2,
        ),
      );
    } else {
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
    }
    if (context.mounted) {
      await getExpenses(shopId());
    }
    notifyListeners();
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
    bool isOnline = await connectivity.isOnline();
    if (isOnline) {
      await supabase
          .from('expenses')
          .delete()
          .eq('uuid', expenses.uuid!);
      await returnEventsLogProvider().createLog(
        returnEventsLogProvider(
          // ignore: use_build_context_synchronously
        ).expensesAdapter(expenses, 3),
        // ignore: use_build_context_synchronously
      );
    } else {
      var containsCreated =
          CreatedExpensesFunc()
              .getExpenses()
              .where((exp) => exp.expenses.uuid == uuid)
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
        CreatedExpensesFunc().deleteExpenses(
          expenses.uuid!,
        );
      } else {
        await DeletedExpensesFunc().createDeletedExpense(
          DeletedExpenses(
            expensesUuid: expenses.uuid!,
            shopId:
                returnShopProvider().userShop()!.shopId!,
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
    }

    if (context.mounted) {
      await getExpenses(shopId());
    }
    notifyListeners();
  }

  //
  //
  //
  //
  //

  Future<void> createExpensesSync(
    BuildContext context,
  ) async {
    try {
      bool isOnline = await connectivity.isOnline();
      // Prepare batch payload
      if (CreatedExpensesFunc().getExpenses().isNotEmpty &&
          isOnline) {
        final tempExpenses =
            CreatedExpensesFunc().getExpenses().toList();
        for (var exp in tempExpenses) {
          print(
            'Updated Time: ${exp.expenses.updatedAt?.toString()}',
          );
        }
        final payload =
            tempExpenses
                .map((p) => p.expenses.toJson())
                .toList();

        // Insert all at once
        final data =
            await supabase
                .from('expenses')
                .insert(payload)
                .select();

        print('${data.length} items added successfully ✅');
        await CreatedExpensesFunc().clearExpenses();
        print('Unsynced Expenses Cleared');
      }
    } catch (e) {
      print('Batch Expenses insert failed ❌: $e');
    }

    if (context.mounted) {
      print('Mounted, refreshing Expenses ✅');
      await getExpenses(
        returnShopProvider().userShop()!.shopId!,
      );
    }
  }

  //
  //
  //
  //
  //

  Future<void> deleteExpensesSync(
    BuildContext context,
  ) async {
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

        final data =
            await supabase
                .from('expenses')
                .delete()
                .inFilter(
                  'uuid',
                  uuids,
                ) // delete where id is in the list
                .select();

        print(
          '${data.length} items deleted successfully ✅',
        );

        await DeletedExpensesFunc().clearDeletedExpenses();
        print('Unsynced deleted Expenses cleared');
      }
    } catch (e) {
      print('Batch delete failed ❌: $e');
    }

    if (context.mounted) {
      print('Mounted, refreshing Expenses ✅');
      await getExpenses(
        returnShopProvider().userShop()!.shopId!,
      );
    }
  }

  //
  //
  //

  Future<void> updateExpensesSync(
    BuildContext context,
  ) async {
    try {
      bool isOnline = await connectivity.isOnline();
      print(
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
            print('Local Expenses Uuid is Null');
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
            print(
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
            print(
              "Local updatedAt: ${localExpenses.updatedAt}",
            );
            print("Remote updatedAt: $remoteUpdatedAt");

            if (remoteUpdatedAt == null ||
                localExpenses.updatedAt!.isAfter(
                  remoteUpdatedAt,
                )) {
              await supabase
                  .from('expenses')
                  .update(localExpenses.toJson())
                  .eq('uuid', localExpenses.uuid!);
              print(
                'Updated Expenses with uuid ${localExpenses.uuid}',
              );
              await UpdatedExpensesFunc()
                  .deleteUpdatedExpense(
                    localExpenses.uuid ?? '',
                  );
            } else {
              print(
                'Skipped Expenses ${localExpenses.uuid}, remote is newer ✅',
              );
            }
          }
        }

        await UpdatedExpensesFunc().clearupdatedExpenses();
        print('Unsynced updated Expenses cleared');
      }
    } catch (e) {
      print('Batch update failed ❌: $e');
    }

    if (context.mounted) {
      print('Mounted, refreshing Expenses ✅');
      await getExpenses(
        returnShopProvider().userShop()!.shopId!,
      );
    }
  }

  //
  //
  //
  //
}
