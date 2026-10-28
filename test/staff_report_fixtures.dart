import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:stockall/classes/temp_expenses/temp_expenses_class.dart';
import 'package:stockall/classes/temp_invoices/temp_invoices.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/classes/temp_orders/orders.dart';
import 'package:stockall/classes/temp_product_slaes_record/temp_product_sale_record.dart';
import 'package:stockall/classes/temp_purchase/temp_purchase.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/pages/report/invoice_report/invoice_report_table/class/invoice_report_table_logic.dart';
import 'package:stockall/pages/report/order_report/order_report_table/class/order_report_table_logic.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/class/purchase_report_table_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/staff_report/staff_analysis/components/staff_analysis_view.dart';
import 'package:stockall/pages/report/staff_report/staff_expenses/components/staff_expenses_view.dart';
import 'package:stockall/pages/report/staff_report/staff_report_table/class/staff_report_table_logic.dart';
import 'package:stockall/pages/report/staff_report/staff_report_table/components/staff_report_table_view.dart';
import 'package:stockall/providers/theme_provider.dart';

import 'order_report_fixtures.dart' show testOrder;

export 'customer_report_fixtures.dart'
    show allTime, testReceipt, invoicePayment, testInvoice, saleLine;
export 'purchase_report_fixtures.dart' show purchase, payment;

// Shared by the staff report tests. Receipts, invoices and sale
// lines come from customer_report_fixtures.dart, purchases from
// purchase_report_fixtures.dart, orders from
// order_report_fixtures.dart. Every record is staff-a's unless a
// test says otherwise.

StaffReportAccess staffAccess({
  bool departmentsEnabled = false,
  bool canViewAllDepartments = true,
  String? currentDepartmentUuid,
  bool canViewAllTransactions = true,
  String? currentUserId = 'staff-a',
  bool showOrders = true,
  bool showPurchases = true,
  bool showExpenses = true,
  bool canPickDate = true,
}) {
  return StaffReportAccess(
    departmentsEnabled: departmentsEnabled,
    canViewAllDepartments: canViewAllDepartments,
    currentDepartmentUuid: currentDepartmentUuid,
    canViewAllTransactions: canViewAllTransactions,
    currentUserId: currentUserId,
    showOrders: showOrders,
    showPurchases: showPurchases,
    showExpenses: showExpenses,
    canPickDate: canPickDate,
  );
}

TempUserClass testUser({
  String? userId = 'staff-a',
  String name = 'Ada',
  String? lastName,
  String? phone = '0801',
  String role = 'Cashier',
  String email = '',
}) {
  return TempUserClass(
    userId: userId,
    password: '',
    name: name,
    lastName: lastName,
    email: email,
    phone: phone,
    role: role,
    departmentUuids: const [],
    access: const [],
  );
}

TempExpensesClass testExpense({
  String? uuid = 'e-1',
  double amount = 10,
  DateTime? createdAt,
  bool undated = false,
  String? userId = 'staff-a',
  String? creator = 'Ada',
  String name = 'Fuel',
  String? description,
  double? quantity,
  String? unit,
  String? departmentUuid,
  String? departmentName,
  int shopId = 1,
}) {
  return TempExpensesClass(
    uuid: uuid,
    name: name,
    description: description,
    amount: amount,
    creator: creator,
    quantity: quantity,
    unit: unit,
    shopId: shopId,
    createdDate: undated ? null : createdAt ?? DateTime(2026, 10, 17, 12),
    userId: userId,
    departmentName: departmentName,
    departmentUuid: departmentUuid,
  );
}

/// An order of [staffId], from order_report_fixtures.dart.
Orders staffOrder({
  required String uuid,
  double total = 50,
  DateTime? createdAt,
  String? staffId = 'staff-a',
  String? departmentUuid,
  int shopId = 1,
}) {
  return testOrder(
    uuid: uuid,
    total: total,
    createdAt: createdAt,
    staffId: staffId,
    departmentUuid: departmentUuid,
    shopId: shopId,
  );
}

StaffReportBase buildStaffBase({
  List<TempUserClass>? staff,
  TempUserClass? owner,
  TempUserClass? currentUser,
  List<TempMainReceipt> receipts = const [],
  List<TempProductSaleRecord> productSales = const [],
  List<TempInvoice> invoices = const [],
  List<Orders> orders = const [],
  List<TempPurchase> purchases = const [],
  List<TempExpensesClass> expenses = const [],
  Set<String> pendingDeletedPurchaseUuids = const {},
  int? shopId,
  StaffReportAccess? access,
}) {
  return StaffReportBase.build(
    source: StaffReportSource(
      staff: staff ?? [testUser()],
      owner: owner,
      currentUser: currentUser,
      receipts: receipts,
      productSales: productSales,
      invoices: invoices,
      orders: orders,
      purchases: purchases,
      expenses: expenses,
      pendingDeletedPurchaseUuids: pendingDeletedPurchaseUuids,
      shopId: shopId,
    ),
    access: access ?? staffAccess(),
  );
}

StaffReportSlice staffSlice(
  StaffReportBase base, {
  ReceiptsReportPeriod period = const ReceiptsReportPeriod.allTime(),
  TimeOfDay? closingTime,
}) => StaffReportSlice.of(base, period, closingTime: closingTime);

List<StaffReportRow> staffRows(
  StaffReportBase base, {
  ReceiptsReportPeriod period = const ReceiptsReportPeriod.allTime(),
  TimeOfDay? closingTime,
}) => StaffReportRowBuilder.buildAll(
  staffSlice(base, period: period, closingTime: closingTime),
);

StaffReportRow staffRowFor(
  StaffReportBase base,
  String key, {
  ReceiptsReportPeriod period = const ReceiptsReportPeriod.allTime(),
  TimeOfDay? closingTime,
}) => staffRows(
  base,
  period: period,
  closingTime: closingTime,
).firstWhere((r) => r.key == key);

/// One `openAnalysis` call of [fakeStaffEnv].
class OpenedStaffAnalysis {
  final StaffReportRow staff;
  final ReceiptsReportPeriod period;

  OpenedStaffAnalysis(this.staff, this.period);
}

/// Every navigation hook call of [fakeStaffEnv] other than
/// `openAnalysis`, in order.
class StaffEnvLog {
  /// Records opened on their detail page: receipts, invoices,
  /// orders, purchases and expenses.
  final List<Object> records = [];

  ReceiptsReportFilters? receiptsFilters;
  ReceiptsReportPeriod? receiptsPeriod;
  InvoiceReportFilters? invoiceFilters;
  OrderReportFilters? orderFilters;
  ReceiptsReportPeriod? orderPeriod;
  PurchaseReportFilters? purchaseFilters;
  ReceiptsReportPeriod? purchasePeriod;
  String? expensesStaffKey;
  ReceiptsReportPeriod? expensesPeriod;

  /// Names of the hooks called, e.g. 'receiptsTable'.
  final List<String> calls = [];
}

/// The staff report screens without providers: data and
/// permissions come from here, as `StaffReportEnv.live` reads them
/// in the app. The lists are read on every rebuild, so a test can
/// change them. [onOpen] runs inside every navigation hook, as if
/// the user changed something on the opened page before going
/// back. With [pushAnalysis] a row opens the real Staff Analysis
/// page (`StaffReportEnv.analysisPage`, as the app does) on this
/// same env; with [pushExpensesTable] the expenses "See all" opens
/// the real Staff Expenses table (`StaffReportEnv.expensesPage`).
StaffReportEnv fakeStaffEnv({
  List<TempUserClass>? staff,
  TempUserClass? owner,
  List<TempMainReceipt>? receipts,
  List<TempInvoice>? invoices,
  List<Orders>? orders,
  List<TempPurchase>? purchases,
  List<TempExpensesClass>? expenses,
  StaffReportAccess? access,
  List<OpenedStaffAnalysis>? opened,
  StaffEnvLog? log,
  VoidCallback? onOpen,
  bool pushAnalysis = false,
  bool pushExpensesTable = false,
}) {
  late final StaffReportEnv env;
  Future<void> record(String call, [Object? item]) async {
    log?.calls.add(call);
    if (item != null) log?.records.add(item);
    onOpen?.call();
  }

  final s = staff ?? [testUser()];
  final r = receipts ?? <TempMainReceipt>[];
  final i = invoices ?? <TempInvoice>[];
  final o = orders ?? <Orders>[];
  final p = purchases ?? <TempPurchase>[];
  final e = expenses ?? <TempExpensesClass>[];
  env = StaffReportEnv(
    access: (_) => access ?? staffAccess(),
    source:
        () => StaffReportSource(
          staff: s,
          owner: owner,
          receipts: r,
          invoices: i,
          orders: o,
          purchases: p,
          expenses: e,
        ),
    load: (context, {required refreshFromStore}) async {},
    signature: (_) => 'fixed',
    listen: (_) {},
    money: (_, v) => 'N$v',
    openAnalysis: (context, staff, period) async {
      opened?.add(OpenedStaffAnalysis(staff, period));
      if (pushAnalysis) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => StaffReportEnv.analysisPage(
                  staffKey: staff.key,
                  period: period,
                  env: env,
                ),
          ),
        );
      }
      onOpen?.call();
    },
    openReceipt: (context, r) => record('receipt', r),
    openInvoice: (context, i) => record('invoice', i),
    openOrder: (context, o) => record('order', o),
    openPurchase: (context, p) => record('purchase', p),
    openExpense: (context, e) => record('expense', e),
    openReceiptsTable: (context, filters, period) {
      log?.receiptsFilters = filters;
      log?.receiptsPeriod = period;
      return record('receiptsTable');
    },
    openInvoiceTable: (context, filters) {
      log?.invoiceFilters = filters;
      return record('invoiceTable');
    },
    openOrderTable: (context, filters, period) {
      log?.orderFilters = filters;
      log?.orderPeriod = period;
      return record('orderTable');
    },
    openPurchaseTable: (context, filters, period) {
      log?.purchaseFilters = filters;
      log?.purchasePeriod = period;
      return record('purchaseTable');
    },
    openExpensesTable: (context, staffKey, period) async {
      log?.expensesStaffKey = staffKey;
      log?.expensesPeriod = period;
      if (pushExpensesTable) {
        log?.calls.add('expensesTable');
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => StaffReportEnv.expensesPage(
                  staffKey: staffKey,
                  period: period,
                  env: env,
                ),
          ),
        );
        onOpen?.call();
        return;
      }
      return record('expensesTable');
    },
  );
  return env;
}

Future<void> pumpStaffAnalysis(
  WidgetTester tester, {
  required bool isDesktop,
  required StaffReportEnv env,
  String staffKey = 'staff-a',
  ReceiptsReportPeriod? period = const ReceiptsReportPeriod.allTime(),
}) async {
  // Tall enough that every section is built and on screen.
  tester.view.physicalSize =
      isDesktop ? const Size(1800, 2600) : const Size(500, 4200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ChangeNotifierProvider<ThemeProvider>(
      create: (_) => ThemeProvider(),
      child: MaterialApp(
        home: StaffAnalysisView(
          isDesktop: isDesktop,
          staffKey: staffKey,
          initialPeriod: period,
          env: env,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> pumpStaffTable(
  WidgetTester tester, {
  required bool isDesktop,
  required StaffReportEnv env,
  StaffReportFilters? filters,
  ReceiptsReportPeriod? period = const ReceiptsReportPeriod.allTime(),
}) async {
  // Mobile is below mobileScreen (650), so the toolbar sits behind
  // "View", as in the customer table tests.
  tester.view.physicalSize =
      isDesktop ? const Size(1800, 1000) : const Size(500, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ChangeNotifierProvider<ThemeProvider>(
      create: (_) => ThemeProvider(),
      child: MaterialApp(
        home: StaffReportTableView(
          isDesktop: isDesktop,
          initialFilters: filters,
          initialPeriod: period,
          env: env,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  if (!isDesktop) {
    await tester.tap(find.text('View'));
    await tester.pumpAndSettle();
  }
}

Future<void> pumpStaffExpenses(
  WidgetTester tester, {
  required bool isDesktop,
  required StaffReportEnv env,
  String staffKey = 'staff-a',
  ReceiptsReportPeriod? period = const ReceiptsReportPeriod.allTime(),
}) async {
  // Mobile is below mobileScreen (650), so the toolbar sits behind
  // "View", as in the staff table tests.
  tester.view.physicalSize =
      isDesktop ? const Size(1800, 1000) : const Size(500, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ChangeNotifierProvider<ThemeProvider>(
      create: (_) => ThemeProvider(),
      child: MaterialApp(
        home: StaffExpensesView(
          isDesktop: isDesktop,
          staffKey: staffKey,
          initialPeriod: period,
          env: env,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  if (!isDesktop && find.text('View').evaluate().isNotEmpty) {
    await tester.tap(find.text('View'));
    await tester.pumpAndSettle();
  }
}
