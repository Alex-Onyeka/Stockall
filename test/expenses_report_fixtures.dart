import 'package:flutter/material.dart';
import 'package:stockall/classes/payment_entry/payment_entry.dart';
import 'package:stockall/classes/temp_expenses/expense_category.dart';
import 'package:stockall/classes/temp_expenses/sub_expense.dart';
import 'package:stockall/classes/temp_expenses/temp_expenses_class.dart';
import 'package:stockall/pages/report/expenses_report/expenses_report_table/class/expenses_report_table_logic.dart';
import 'package:stockall/pages/report/expenses_report/expenses_report_table/components/expenses_report_table_view.dart';
import 'package:stockall/pages/report/expenses_report/expenses_summary/class/expenses_summary_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

const midnight = TimeOfDay(hour: 0, minute: 0);

/// Noon on 2026-10-[d].
DateTime day(int d, [int hour = 12]) => DateTime(2026, 10, d, hour);

TempExpensesClass exp({
  required String uuid,
  double amount = 100,
  DateTime? createdAt,
  bool undated = false,
  String name = 'Expense',
  String? description,
  double? quantity,
  String? unit,
  String type = ExpenseType.simpleExpense,
  String? categoryUuid,
  String? categoryName,
  String? staffUuid,
  String? staffName,
  String? purchaseUuid,
  String? userId = 'staff-a',
  String? creator = 'Ada',
  String? departmentUuid,
  String? departmentName,
  String? paymentChannel,
  List<PaymentEntry>? entries,
  List<SubExpense>? subs,
  int shopId = 1,
}) {
  return TempExpensesClass(
    uuid: uuid,
    name: name,
    description: description,
    amount: amount,
    quantity: quantity,
    unit: unit,
    creator: creator,
    shopId: shopId,
    createdDate: undated ? null : createdAt ?? day(17),
    userId: userId,
    departmentName: departmentName,
    departmentUuid: departmentUuid,
    expenseType: type,
    expenseCategoryUuid: categoryUuid,
    expenseCategoryName: categoryName,
    staffUuid: staffUuid,
    staffName: staffName,
    purchaseUuid: purchaseUuid,
    paymentChannel: paymentChannel,
    paymentEntries: entries,
    subExpenses: subs,
  );
}

SubExpense line(
  String name,
  double amount, {
  String channel = PaymentMethods.cash,
  String? description,
  double? quantity,
  String? unit,
}) => SubExpense(
  uuid: 'line-$name-$amount',
  name: name,
  amount: amount,
  paymentChannel: channel,
  description: description,
  quantity: quantity,
  unit: unit,
);

/// An expense whose amount and entries come from [subs], as the
/// form saves it.
TempExpensesClass expWithLines({
  required String uuid,
  required List<SubExpense> subs,
  DateTime? createdAt,
  String name = 'NEPA Bill',
  String type = ExpenseType.simpleExpense,
  String? categoryUuid,
  String? categoryName,
  String? userId = 'staff-a',
  String? creator = 'Ada',
  String? departmentUuid,
}) => exp(
  uuid: uuid,
  name: name,
  amount: SubExpense.totalOf(subs),
  entries: SubExpense.paymentEntriesOf(subs),
  subs: subs,
  createdAt: createdAt,
  type: type,
  categoryUuid: categoryUuid,
  categoryName: categoryName,
  userId: userId,
  creator: creator,
  departmentUuid: departmentUuid,
);

ExpenseCategory category(String uuid, String name) =>
    ExpenseCategory(uuid: uuid, shopId: 1, name: name);

ExpensesReportAccess access({
  bool departmentsEnabled = false,
  bool canViewAllDepartments = true,
  String? currentDepartmentUuid,
  bool canViewAllTransactions = true,
  String? currentUserId = 'staff-a',
  bool canPickDate = true,
  int? shopId = 1,
}) => ExpensesReportAccess(
  departmentsEnabled: departmentsEnabled,
  canViewAllDepartments: canViewAllDepartments,
  currentDepartmentUuid: currentDepartmentUuid,
  canViewAllTransactions: canViewAllTransactions,
  currentUserId: currentUserId,
  canPickDate: canPickDate,
  shopId: shopId,
);

/// Scoped and built, as the view does.
List<ExpensesReportRow> buildRows(
  List<TempExpensesClass> expenses, {
  ExpensesReportAccess? scope,
  List<ExpenseCategory> categories = const [],
  Map<String, String> staffNames = const {},
}) => ExpensesReportRowBuilder.buildAll(
  expenses: (scope ?? access()).scope(expenses),
  categories: categories,
  staffNames: staffNames,
);

List<String> uuids(Iterable<ExpensesReportRow> rows) =>
    rows.map((r) => r.uuid).toList();

/// A mixed set over 16-18 Oct: every category, a salary, a stock
/// purchase, sub-expenses, two staff, two channels, two departments.
List<TempExpensesClass> sampleExpenses() => [
  exp(
    uuid: 'e-fuel',
    name: 'Fuel',
    description: 'Generator diesel',
    quantity: 20,
    unit: 'litres',
    amount: 300,
    departmentUuid: 'd1',
    departmentName: 'Bar',
    createdAt: day(17, 9),
  ),
  exp(
    uuid: 'e-salary-ada',
    name: 'Salary - Ada',
    amount: 1500,
    type: ExpenseType.staffSalary,
    staffUuid: 'staff-a',
    staffName: 'Ada Old',
    userId: 'owner',
    creator: 'Owner',
    paymentChannel: 'GTBank (1234)',
    entries: [PaymentEntry(method: 'GTBank (1234)', amount: 1500)],
    createdAt: day(16, 10),
  ),
  exp(
    uuid: 'e-salary-bayo',
    name: 'Salary - Bayo',
    amount: 1000,
    type: ExpenseType.staffSalary,
    staffUuid: 'staff-b',
    staffName: 'Bayo',
    userId: 'owner',
    creator: 'Owner',
    createdAt: day(18, 10),
  ),
  exp(
    uuid: 'e-stock',
    name: 'Stock Purchase (Acme)',
    amount: 5000,
    type: ExpenseType.stockPurchase,
    purchaseUuid: 'p-1',
    departmentUuid: 'd2',
    departmentName: 'Kitchen',
    createdAt: day(17, 11),
  ),
  expWithLines(
    uuid: 'e-nepa',
    subs: [
      line('Transportation', 200),
      line('Token', 800, channel: 'gtbank (1234)'),
    ],
    departmentUuid: 'd2',
    createdAt: day(17, 14),
  ),
  expWithLines(
    uuid: 'e-party',
    name: 'Staff party',
    type: ExpenseType.custom,
    categoryUuid: 'c-welfare',
    categoryName: 'Old Welfare',
    subs: [line('transportation', 50), line('Drinks', 150)],
    userId: 'staff-b',
    creator: 'Bayo',
    createdAt: day(18, 15),
  ),
  exp(
    uuid: 'e-gift',
    name: 'Gift',
    amount: 70,
    type: ExpenseType.custom,
    categoryName: 'Gifts',
    userId: 'staff-b',
    creator: 'Bayo',
    createdAt: day(16, 16),
  ),
];

final sampleCategories = [category('c-welfare', 'Welfare')];

const sampleStaffNames = {'staff-a': 'Ada Obi', 'staff-b': 'Bayo Ade'};

List<ExpensesReportRow> sampleRows({ExpensesReportAccess? scope}) => buildRows(
  sampleExpenses(),
  scope: scope,
  categories: sampleCategories,
  staffNames: sampleStaffNames,
);

/// The view's env over [expenses], without providers.
ExpensesReportEnv fakeExpensesEnv({
  required List<TempExpensesClass> expenses,
  ExpensesReportAccess? scope,
  List<ExpenseCategory> categories = const [],
  Map<String, String> staffNames = const {},
  List<TempExpensesClass>? opened,
  List<(ExpensesTableHandoff, ReceiptsReportPeriod)>? openedTables,
}) {
  return ExpensesReportEnv(
    access: () => scope ?? access(),
    expenses: () => expenses,
    categories: () => categories,
    staffNames: () => staffNames,
    load: (context, {required refreshFromStore, period}) async {},
    signature: () => 'fixed',
    listen: (_) {},
    money: (_, v) => 'N$v',
    openExpense: (context, e) async => opened?.add(e),
    openTable:
        openedTables == null
            ? null
            : (context, handoff, period) async =>
                openedTables.add((handoff, period)),
  );
}

ExpensesReportEnv sampleEnv({
  ExpensesReportAccess? scope,
  List<TempExpensesClass>? opened,
  List<(ExpensesTableHandoff, ReceiptsReportPeriod)>? openedTables,
}) => fakeExpensesEnv(
  expenses: sampleExpenses(),
  scope: scope,
  categories: sampleCategories,
  staffNames: sampleStaffNames,
  opened: opened,
  openedTables: openedTables,
);
