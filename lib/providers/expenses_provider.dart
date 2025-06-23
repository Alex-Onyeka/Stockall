import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_expenses_class.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExpensesProvider extends ChangeNotifier {
  final supabase = Supabase.instance.client;

  List<TempExpensesClass> expenses = [];

  Future<void> addExpense(
    TempExpensesClass expense,
    BuildContext context,
  ) async {
    await supabase
        .from('expenses')
        .insert(expense.toJson());
    if (context.mounted) {
      print('Mounted: Add Expense');
      await getExpenses(shopId(context));
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
  //

  Future<List<TempExpensesClass>> getExpenses(
    int shopId,
  ) async {
    final supabase = Supabase.instance.client;

    final response = await supabase
        .from('expenses')
        .select()
        .eq('shop_id', shopId)
        .order('created_date', ascending: false);
    print('Expenses Gotten: Get Expenses');

    var exp =
        (response as List)
            .map((e) => TempExpensesClass.fromJson(e))
            .toList();
    expenses = exp;
    notifyListeners();
    return exp;
  }

  //
  //
  //
  //
  //
  //
  //

  Future<List<TempExpensesClass>> getExpensesByUser({
    required int shopId,
    required String userId,
  }) async {
    final supabase = Supabase.instance.client;

    final response = await supabase
        .from('expenses')
        .select()
        .eq('shop_id', shopId)
        .eq('user_id', userId)
        .order('created_date', ascending: false);

    return (response as List)
        .map((e) => TempExpensesClass.fromJson(e))
        .toList();
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

      return expenses.where((expenses) {
        final created = expenses.createdDate!.toUtc();
        return created.isAfter(
              weekStartUtc.subtract(
                const Duration(seconds: 1),
              ),
            ) &&
            created.isBefore(weekEndUtc);
      }).toList();
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

    return expenses.where((receipt) {
      final created = receipt.createdDate!.toUtc();
      return created.isAfter(
            startOfDay.subtract(const Duration(seconds: 1)),
          ) &&
          created.isBefore(endOfDay);
    }).toList();
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
    final supabase = Supabase.instance.client;

    await supabase
        .from('expenses')
        .update(expense.toJson())
        .eq('id', expense.id!);

    if (context.mounted) {
      await getExpenses(shopId(context));
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
    int id,
    BuildContext context,
  ) async {
    final supabase = Supabase.instance.client;

    await supabase.from('expenses').delete().eq('id', id);

    if (context.mounted) {
      await getExpenses(shopId(context));
    }
    notifyListeners();
  }

  //
  //
  //
  //
}
