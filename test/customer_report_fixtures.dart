import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:stockall/classes/temp_customer_account_receipts/customer_account_receipts.dart';
import 'package:stockall/classes/temp_customers/temp_customers_class.dart';
import 'package:stockall/classes/temp_invoices/temp_invoices.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/classes/temp_orders/orders.dart';
import 'package:stockall/classes/temp_product_slaes_record/temp_product_sale_record.dart';
import 'package:stockall/pages/report/customer_report/customer_analysis/components/customer_analysis_view.dart';
import 'package:stockall/pages/report/customer_report/customer_report_table/class/customer_report_table_logic.dart';
import 'package:stockall/pages/report/customer_report/customer_report_table/components/customer_report_table_view.dart';
import 'package:stockall/pages/report/invoice_report/invoice_report_table/class/invoice_report_table_logic.dart';
import 'package:stockall/pages/report/order_report/order_report_table/class/order_report_table_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/providers/theme_provider.dart';

import 'order_report_fixtures.dart';

// Shared by the customer report tests. Orders, order lines and
// units come from order_report_fixtures.dart. Every sale line has
// a unitsList, so no unit lookup reaches the user provider.

const allTime = ReceiptsReportPeriod.allTime();

CustomerReportAccess testAccess({
  bool departmentsEnabled = false,
  bool canViewAllDepartments = true,
  String? currentDepartmentUuid,
  bool canViewAllTransactions = true,
  String? currentUserId = 'staff-a',
  bool manageCustomerAccount = true,
  bool manageCustomerReward = true,
  bool canViewCustomersAccount = true,
  bool canPickDate = true,
}) {
  return CustomerReportAccess(
    departmentsEnabled: departmentsEnabled,
    canViewAllDepartments: canViewAllDepartments,
    currentDepartmentUuid: currentDepartmentUuid,
    canViewAllTransactions: canViewAllTransactions,
    currentUserId: currentUserId,
    manageCustomerAccount: manageCustomerAccount,
    manageCustomerReward: manageCustomerReward,
    canViewCustomersAccount: canViewCustomersAccount,
    canPickDate: canPickDate,
  );
}

TempCustomersClass testCustomer({
  String? uuid = 'cust-1',
  String name = 'Bola',
  String phone = '0801',
  String email = '',
  String? address,
  String? city,
  String? state,
  String? country,
  double? balance,
  double? cashReward,
  String? departmentUuid,
}) {
  return TempCustomersClass(
    uuid: uuid,
    name: name,
    email: email,
    phone: phone,
    address: address,
    city: city,
    state: state,
    country: country,
    dateAdded: DateTime(2026, 1, 1),
    shopId: 1,
    departmentName: null,
    departmentUuid: departmentUuid,
    balance: balance,
    cashReward: cashReward,
  );
}

TempProductSaleRecord saleLine({
  double revenue = 0,
  double quantity = 1,
  double? costPrice,
  bool isVoid = false,
  String? receiptUuid,
  String? invoiceUuid,
}) {
  final line = deliveredLine(
    quantity: quantity,
    isVoid: isVoid,
    receiptUuid: receiptUuid,
  );
  line.revenue = revenue;
  line.originalCost = revenue;
  line.costPrice = costPrice;
  line.invoiceUuid = invoiceUuid;
  return line;
}

TempMainReceipt testReceipt({
  required String uuid,
  String? barcode,
  DateTime? createdAt,
  int? salesTypeIndex = 1,
  double cash = 0,
  double bank = 0,
  double? account,
  String? customerUuid = 'cust-1',
  String? customerName = 'Bola',
  String? staffId = 'staff-a',
  String? departmentUuid,
  String? invoiceUuid,
  String? orderUuid,
  List<TempProductSaleRecord>? items,
}) {
  return TempMainReceipt(
    uuid: uuid,
    barcode: barcode ?? uuid.replaceAll(RegExp(r'\D'), ''),
    createdAt: createdAt ?? DateTime(2026, 10, 17, 12),
    shopId: 1,
    staffId: staffId,
    staffName: 'Ada',
    customerUuid: customerUuid,
    customerName: customerName,
    paymentMethod: 'Cash',
    bank: bank,
    cashAlt: cash,
    customerAccount: account,
    departmentName: null,
    departmentUuidNew: departmentUuid,
    isInvoice: salesTypeIndex != 1,
    invoiceUuid: invoiceUuid,
    orderUuid: orderUuid,
    cartName: null,
    subStaffName: null,
    comment: null,
    salesTypeIndex: salesTypeIndex,
    items: items,
  );
}

/// An invoice payment receipt (`salesTypeIndex` 2).
TempMainReceipt invoicePayment({
  required String uuid,
  required String invoiceUuid,
  double cash = 0,
  double bank = 0,
  double? account,
  DateTime? createdAt,
  String? customerUuid = 'cust-1',
  String? staffId = 'staff-a',
  String? departmentUuid,
}) {
  return testReceipt(
    uuid: uuid,
    salesTypeIndex: 2,
    cash: cash,
    bank: bank,
    account: account,
    createdAt: createdAt,
    customerUuid: customerUuid,
    staffId: staffId,
    departmentUuid: departmentUuid,
    invoiceUuid: invoiceUuid,
  );
}

/// [total] is the stored invoice total (`cashAlt + bank`).
TempInvoice testInvoice({
  required String uuid,
  double total = 100,
  DateTime? createdAt,
  String? customerUuid = 'cust-1',
  String? customerName = 'Bola',
  String staffId = 'staff-a',
  String? departmentUuid,
  int shopId = 1,
  List<TempProductSaleRecord>? items,
}) {
  return TempInvoice(
    uuid: uuid,
    barcode: uuid.replaceAll(RegExp(r'\D'), ''),
    createdAt: createdAt ?? DateTime(2026, 10, 17, 12),
    shopId: shopId,
    staffId: staffId,
    staffName: 'Ada',
    customerName: customerName,
    customerUuid: customerUuid,
    paymentMethod: 'Cash',
    bank: 0,
    cashAlt: total,
    departmentName: null,
    departmentUuidNew: departmentUuid,
    cartName: null,
    subStaffName: null,
    comment: null,
    items: items,
  );
}

Orders customerOrder({
  required String uuid,
  double total = 50,
  DateTime? createdAt,
  String? customerId = 'cust-1',
  String? staffId = 'staff-a',
  String? departmentUuid,
  int shopId = 1,
}) {
  return testOrder(
    uuid: uuid,
    total: total,
    createdAt: createdAt,
    customerId: customerId,
    staffId: staffId,
    departmentUuid: departmentUuid,
    shopId: shopId,
  );
}

CustomerAccountReceipts ledgerEntry({
  required String uuid,
  String? customerUuid = 'cust-1',
  DateTime? createdAt,
  bool? isBalance = true,
  bool isAdd = true,
  double amount = 10,
  String? title,
  String? comment,
  String? staffId = 'staff-a',
  String? staffName = 'Ada',
  String? receiptUuid,
  double? oldBalance,
  double? newBalance,
}) {
  return CustomerAccountReceipts(
    uuid: uuid,
    createdAt: createdAt ?? DateTime(2026, 10, 17, 12),
    shopId: 1,
    staffId: staffId,
    staffName: staffName,
    customerUuid: customerUuid,
    customerName: 'Bola',
    amount: amount,
    isAdd: isAdd,
    isBalance: isBalance,
    title: title,
    comment: comment,
    receiptUuid: receiptUuid,
    oldBalance: oldBalance,
    newBalance: newBalance,
  );
}

CustomerReportBase buildBase({
  List<TempCustomersClass>? customers,
  List<TempMainReceipt> receipts = const [],
  List<TempProductSaleRecord> productSales = const [],
  List<TempInvoice> invoices = const [],
  List<Orders> orders = const [],
  List<CustomerAccountReceipts> ledger = const [],
  int? shopId,
  CustomerReportAccess? access,
}) {
  return CustomerReportBase.build(
    source: CustomerReportSource(
      customers: customers ?? [testCustomer()],
      receipts: receipts,
      productSales: productSales,
      invoices: invoices,
      orders: orders,
      ledger: ledger,
      shopId: shopId,
    ),
    access: access ?? testAccess(),
  );
}

CustomerReportSlice sliceOf(
  CustomerReportBase base, {
  ReceiptsReportPeriod period = allTime,
  TimeOfDay? closingTime,
}) => CustomerReportSlice.of(base, period, closingTime: closingTime);

List<CustomerReportRow> rowsOf(
  CustomerReportBase base, {
  ReceiptsReportPeriod period = allTime,
  TimeOfDay? closingTime,
}) => CustomerReportRowBuilder.buildAll(
  sliceOf(base, period: period, closingTime: closingTime),
);

CustomerReportRow rowFor(
  CustomerReportBase base,
  String uuid, {
  ReceiptsReportPeriod period = allTime,
  TimeOfDay? closingTime,
}) => rowsOf(
  base,
  period: period,
  closingTime: closingTime,
).firstWhere((r) => r.uuid == uuid);

/// One `openAnalysis` call of [fakeCustomerEnv].
class OpenedAnalysis {
  final TempCustomersClass customer;
  final ReceiptsReportPeriod period;

  OpenedAnalysis(this.customer, this.period);
}

/// Every navigation hook call of [fakeCustomerEnv] other than
/// `openAnalysis`, in order.
class CustomerEnvLog {
  /// Records opened on their detail page: receipts, invoices,
  /// orders and ledger entries.
  final List<Object> records = [];

  ReceiptsReportFilters? receiptsFilters;
  ReceiptsReportPeriod? receiptsPeriod;
  InvoiceReportFilters? invoiceFilters;
  OrderReportFilters? orderFilters;
  ReceiptsReportPeriod? orderPeriod;
  final List<(TempCustomersClass, CustomerLedgerKind, ReceiptsReportPeriod)>
  ledgerTables = [];

  /// Names of the hooks called, e.g. 'receiptsTable'.
  final List<String> calls = [];
}

/// The customer report screens without providers: data and
/// permissions come from here, as `CustomerReportEnv.live` reads
/// them in the app. The lists are read on every rebuild, so a test
/// can change them. [onOpen] runs inside every navigation hook, as
/// if the user changed something on the opened page before going
/// back. With [pushLedgerTables] the ledger "See all" pushes the
/// real table (`CustomerReportEnv.ledgerTablePage`, as the app
/// does) on this same env.
CustomerReportEnv fakeCustomerEnv({
  List<TempCustomersClass>? customers,
  List<TempMainReceipt>? receipts,
  List<TempInvoice>? invoices,
  List<Orders>? orders,
  List<CustomerAccountReceipts>? ledger,
  CustomerReportAccess? access,
  List<OpenedAnalysis>? opened,
  CustomerEnvLog? log,
  VoidCallback? onOpen,
  bool pushLedgerTables = false,
}) {
  late final CustomerReportEnv env;
  Future<void> record(String call, [Object? item]) async {
    log?.calls.add(call);
    if (item != null) log?.records.add(item);
    onOpen?.call();
  }

  final c = customers ?? [testCustomer()];
  final r = receipts ?? <TempMainReceipt>[];
  final i = invoices ?? <TempInvoice>[];
  final o = orders ?? <Orders>[];
  final l = ledger ?? <CustomerAccountReceipts>[];
  env = CustomerReportEnv(
    access: () => access ?? testAccess(),
    source:
        () => CustomerReportSource(
          customers: c,
          receipts: r,
          invoices: i,
          orders: o,
          ledger: l,
        ),
    load: (context, {required refreshFromStore}) async {},
    signature: () => 'fixed',
    listen: (_) {},
    money: (_, v) => 'N$v',
    openAnalysis: (context, customer, period) async {
      opened?.add(OpenedAnalysis(customer, period));
      onOpen?.call();
    },
    openReceipt: (context, r) => record('receipt', r),
    openInvoice: (context, i) => record('invoice', i),
    openOrder: (context, o) => record('order', o),
    openLedgerEntry: (context, e) => record('ledgerEntry', e),
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
    openLedgerTable: (context, customer, kind, period) async {
      log?.ledgerTables.add((customer, kind, period));
      if (pushLedgerTables) {
        log?.calls.add('ledgerTable');
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => CustomerReportEnv.ledgerTablePage(
                  customer: customer,
                  kind: kind,
                  period: period,
                  env: env,
                ),
          ),
        );
        onOpen?.call();
        return;
      }
      return record('ledgerTable');
    },
  );
  return env;
}

/// The Reward Earnings or Account Transactions table of
/// [customer], as the analysis page opens it.
Future<void> pumpLedgerTable(
  WidgetTester tester, {
  required bool isDesktop,
  required CustomerReportEnv env,
  required CustomerLedgerKind kind,
  TempCustomersClass? customer,
  ReceiptsReportPeriod? period = allTime,
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
        home: CustomerReportEnv.ledgerTablePage(
          customer: customer ?? testCustomer(),
          kind: kind,
          period: period ?? allTime,
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

Future<void> pumpCustomerAnalysis(
  WidgetTester tester, {
  required bool isDesktop,
  required CustomerReportEnv env,
  TempCustomersClass? customer,
  ReceiptsReportPeriod? period = allTime,
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
        home: CustomerAnalysisView(
          isDesktop: isDesktop,
          customer: customer ?? testCustomer(),
          initialPeriod: period,
          env: env,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> pumpCustomerTable(
  WidgetTester tester, {
  required bool isDesktop,
  required CustomerReportEnv env,
  CustomerReportFilters? filters,
  ReceiptsReportPeriod? period = allTime,
}) async {
  // Mobile is below mobileScreen (650), so the toolbar sits behind
  // "View", as in the order report tests.
  tester.view.physicalSize =
      isDesktop ? const Size(1800, 1000) : const Size(500, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ChangeNotifierProvider<ThemeProvider>(
      create: (_) => ThemeProvider(),
      child: MaterialApp(
        home: CustomerReportTableView(
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
