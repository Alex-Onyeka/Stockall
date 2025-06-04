import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_expenses_class.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExpensesProvider extends ChangeNotifier {
  final supabase = Supabase.instance.client;

  Future<void> addExpense(TempExpensesClass expense) async {
    await supabase
        .from('expenses')
        .insert(expense.toJson());
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
    notifyListeners();
  }

  void setExpenseDay(DateTime day) {
    singleDay = day;
    weekStartDate = null;
    isDateSet = true;
    setDate = false;
    dateSet = 'For ${formatDateTime(day)}';
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
    notifyListeners();
  }

  void clearExpenseDate() {
    singleDay = null;
    weekStartDate = null;
    setDate = false;
    isDateSet = false;
    dateSet = null;
    notifyListeners();
  }

  // Future<List<TempExpensesClass>> loadExpensesByDayOrWeek({
  //   required int shopId,
  // }) async {
  //   try {
  //     final now = DateTime.now();
  //     late final List data;

  //     if (expenseWeekStartDate != null) {
  //       final weekEndDate = expenseWeekStartDate!.add(
  //         const Duration(days: 6),
  //       );

  //       data = await Supabase.instance.client
  //           .from('expenses')
  //           .select()
  //           .eq('shop_id', shopId)
  //           .gte(
  //             'created_date',
  //             expenseWeekStartDate!.toIso8601String(),
  //           )
  //           .lte(
  //             'created_date',
  //             weekEndDate.toIso8601String(),
  //           )
  //           .order('created_date', ascending: false);
  //     } else {
  //       final targetDate = expenseSingleDay ?? now;
  //       final startOfDay = DateTime(
  //         targetDate.year,
  //         targetDate.month,
  //         targetDate.day,
  //       );
  //       final endOfDay = startOfDay.add(
  //         const Duration(days: 1),
  //       );

  //       data = await Supabase.instance.client
  //           .from('expenses')
  //           .select()
  //           .eq('shop_id', shopId)
  //           .gte(
  //             'created_date',
  //             startOfDay.toIso8601String(),
  //           )
  //           .lt('created_date', endOfDay.toIso8601String())
  //           .order('created_date', ascending: false);
  //     }

  //     return data
  //         .map((json) => TempExpensesClass.fromJson(json))
  //         .toList();
  //   } catch (e) {
  //     return [];
  //   }
  // }

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
  ) async {
    final supabase = Supabase.instance.client;

    await supabase
        .from('expenses')
        .update(expense.toJson())
        .eq('id', expense.id!);
  }
  //
  //
  //
  //
  //
  //
  //

  Future<void> deleteExpense(int id) async {
    final supabase = Supabase.instance.client;

    await supabase.from('expenses').delete().eq('id', id);
  }

  //
  //
  //
  //
  //
}
