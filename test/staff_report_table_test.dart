import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/temp_expenses/temp_expenses_class.dart';
import 'package:stockall/classes/temp_invoices/temp_invoices.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/classes/temp_orders/orders.dart';
import 'package:stockall/classes/temp_purchase/temp_purchase.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/pages/report/invoice_report/invoice_report_table/class/invoice_report_table_logic.dart';
import 'package:stockall/pages/report/order_report/order_report_table/class/order_report_table_logic.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/class/purchase_report_table_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/components/receipts_report_filter_widgets.dart';
import 'package:stockall/pages/report/staff_report/staff_analysis/class/staff_analysis_logic.dart';
import 'package:stockall/pages/report/staff_report/staff_analysis/components/staff_analysis_view.dart';
import 'package:stockall/pages/report/staff_report/staff_report_table/components/staff_report_table_view.dart';
import 'package:stockall/pages/report/staff_report/staff_expenses/class/staff_expenses_logic.dart';
import 'package:stockall/pages/report/staff_report/staff_report_table/class/staff_report_table_logic.dart';

import 'staff_report_fixtures.dart';

// Expected values come straight from each report's own builders and
// queries, filtered to one staff with the "See all" filters
// (StaffSeeAll), as those tables show them. The Invoice and Order
// tables are scoped as the staff report scopes them: their own
// scope has no own-transactions rule and another department rule
// (reported separately). In tests the Invoice Report query uses
// midnight as the closing time (no shop provider), so periods that
// include invoices use midnight for every report.

class Expected {
  final double receiptSales;
  final int receiptCount;
  final double invoiceSales;
  final int invoiceCount;
  final OrderReportTotals orders;
  final double purchaseTotal;
  final int purchaseCount;
  final double expenseTotal;
  final int expenseCount;

  Expected({
    required this.receiptSales,
    required this.receiptCount,
    required this.invoiceSales,
    required this.invoiceCount,
    required this.orders,
    required this.purchaseTotal,
    required this.purchaseCount,
    required this.expenseTotal,
    required this.expenseCount,
  });
}

Expected expectedFor(
  String staffKey, {
  required List<TempMainReceipt> receipts,
  required List<TempInvoice> invoices,
  required List<Orders> orders,
  required List<TempPurchase> purchases,
  required List<TempExpensesClass> expenses,
  required ReceiptsReportPeriod period,
  StaffReportAccess? access,
  TimeOfDay? closingTime,
}) {
  final a = access ?? staffAccess();

  final receiptsPage = ReceiptsReportQuery.paginate(
    ReceiptsReportQuery.filterAndSort(
      rows: ReceiptsReportRowBuilder.buildAll(
        receipts: ReceiptsReportAccess.scope(
          receipts: receipts,
          departmentsEnabled: a.departmentsEnabled,
          canViewAllDepartments: a.canViewAllDepartments,
          currentDepartmentUuid: a.currentDepartmentUuid,
          canViewAllTransactions: a.canViewAllTransactions,
          currentUserId: a.currentUserId,
        ),
        legacySales: const [],
      ),
      period: period,
      filters: StaffSeeAll.receiptsFilters(staffKey),
      sortField: ReceiptsSortField.createdAt,
      ascending: false,
      departmentsEnabled: true,
      subStaffEnabled: true,
      profitVisible: true,
      closingTime: closingTime,
    ),
    1,
  );

  final invoicePage = InvoiceReportQuery.paginate(
    InvoiceReportQuery.filterAndSort(
      rows: InvoiceReportRowBuilder.buildAll(
        invoices: a.scopeInvoices(invoices),
        allReceipts: receipts,
        allProductSales: const [],
        customerMap: const {},
      ),
      filters: StaffSeeAll.invoiceFilters(staffKey, period),
      sortField: InvoiceSortField.createdAt,
      ascending: false,
      departmentsEnabled: true,
      bulkSaleEnabled: true,
      costFilterAllowed: true,
    ),
    1,
  );

  final orderRows = OrderReportQuery.filterAndSort(
    rows: OrderReportRowBuilder.buildAll(
      orders: a.scopeOrders(orders),
      allReceipts: receipts,
    ),
    period: period,
    filters: StaffSeeAll.orderFilters(staffKey),
    sortField: OrderSortField.createdAt,
    ascending: false,
    departmentsEnabled: true,
    subStaffEnabled: true,
    profitVisible: true,
    closingTime: closingTime,
  );

  final purchasePage = PurchaseReportQuery.paginate(
    PurchaseReportQuery.filterAndSort(
      rows: PurchaseReportRowBuilder.buildAll(
        purchases: PurchaseReportAccess.scope(
          purchases: purchases,
          departmentsEnabled: a.departmentsEnabled,
          canViewAllDepartments: a.canViewAllDepartments,
          currentDepartmentUuid: a.currentDepartmentUuid,
          canViewAllTransactions: a.canViewAllTransactions,
          currentUserId: a.currentUserId,
        ),
      ),
      period: period,
      filters: StaffSeeAll.purchaseFilters(staffKey),
      sortField: PurchasesSortField.createdAt,
      ascending: false,
      departmentsEnabled: true,
      closingTime: closingTime,
    ),
    1,
  );

  // Worked out from the raw expenses, with the receipts rule.
  double expenseTotal = 0;
  int expenseCount = 0;
  final restrictDepartment =
      a.departmentsEnabled &&
      (!a.canViewAllDepartments || a.currentDepartmentUuid != null);
  for (final e in expenses) {
    if (e.userId != staffKey) continue;
    if (restrictDepartment && e.departmentUuid != a.currentDepartmentUuid) {
      continue;
    }
    if (!a.canViewAllTransactions && e.userId != a.currentUserId) continue;
    final at = e.createdDate;
    if (!period.isAllTime &&
        (at == null || !period.contains(at, closingTime: closingTime))) {
      continue;
    }
    expenseTotal += e.amount;
    expenseCount++;
  }

  return Expected(
    receiptSales: receiptsPage.totalRevenue,
    receiptCount: receiptsPage.totalCount,
    invoiceSales: invoicePage.totalRevenue,
    invoiceCount: invoicePage.totalCount,
    orders: OrderReportTotals.of(orderRows),
    purchaseTotal: purchasePage.total,
    purchaseCount: purchasePage.totalCount,
    expenseTotal: expenseTotal,
    expenseCount: expenseCount,
  );
}

void expectMatches(StaffReportRow row, Expected e) {
  final who = row.key;
  expect(row.receiptSales, closeTo(e.receiptSales, 1e-9), reason: who);
  expect(row.receiptCount, e.receiptCount, reason: '$who receipts');
  expect(row.invoiceSales, closeTo(e.invoiceSales, 1e-9), reason: who);
  expect(row.invoiceCount, e.invoiceCount, reason: '$who invoices');
  expect(row.orderTotal, closeTo(e.orders.total, 1e-9), reason: who);
  expect(row.orderCount, e.orders.count, reason: '$who orders');
  expect(row.purchaseTotal, closeTo(e.purchaseTotal, 1e-9), reason: who);
  expect(row.purchaseCount, e.purchaseCount, reason: '$who purchases');
  expect(row.expenseTotal, closeTo(e.expenseTotal, 1e-9), reason: who);
  expect(row.expenseCount, e.expenseCount, reason: '$who expenses');
}

// A shop with an owner, three staff (staff-c never works) and one
// former staff (staff-x), plus records without a staff.
final owner = testUser(userId: 'owner-1', name: 'Ola', role: 'Owner');
final staffList = [
  testUser(userId: 'staff-a', name: 'Ada', lastName: 'Obi'),
  testUser(userId: 'staff-b', name: 'Bayo', phone: '0802', role: 'Manager'),
  testUser(userId: 'staff-c', name: 'Chika', phone: '0803', role: 'cashier'),
];

final receipts = [
  testReceipt(
    uuid: 'r-a1',
    cash: 100,
    departmentUuid: 'd1',
    createdAt: DateTime(2026, 10, 17, 12),
    items: [saleLine(revenue: 100), saleLine(revenue: 30, isVoid: true)],
  ),
  testReceipt(
    uuid: 'r-a2',
    bank: 50,
    account: 20,
    departmentUuid: 'd2',
    createdAt: DateTime(2026, 10, 18, 10),
  ),
  testReceipt(
    uuid: 'r-b1',
    cash: 70,
    staffId: 'staff-b',
    departmentUuid: 'd1',
    createdAt: DateTime(2026, 10, 17, 15),
  ),
  testReceipt(
    uuid: 'r-o1',
    cash: 200,
    staffId: 'owner-1',
    createdAt: DateTime(2026, 10, 16, 12),
  ),
  testReceipt(uuid: 'r-none', cash: 500, staffId: null),
  testReceipt(uuid: 'r-blank', cash: 5, staffId: '  '),
  // staff-b takes a payment on staff-a's invoice.
  invoicePayment(
    uuid: 'p-b1',
    invoiceUuid: 'inv-a1',
    cash: 40,
    staffId: 'staff-b',
    departmentUuid: 'd1',
    createdAt: DateTime(2026, 10, 18, 11),
  ),
  testReceipt(
    uuid: 'r-x1',
    cash: 9,
    staffId: 'staff-x',
    departmentUuid: 'd2',
    createdAt: DateTime(2026, 10, 17, 13),
  )..staffName = 'Xena',
];

final invoices = [
  testInvoice(
    uuid: 'inv-a1',
    total: 100,
    departmentUuid: 'd1',
    createdAt: DateTime(2026, 10, 17, 9),
  ),
  testInvoice(
    uuid: 'inv-b1',
    total: 80,
    staffId: 'staff-b',
    departmentUuid: 'd2',
    createdAt: DateTime(2026, 10, 19, 9),
  ),
  testInvoice(uuid: 'inv-none', total: 1000, staffId: ''),
];

final orders = [
  staffOrder(
    uuid: 'o-a1',
    total: 50,
    departmentUuid: 'd1',
    createdAt: DateTime(2026, 10, 17, 10),
  ),
  staffOrder(
    uuid: 'o-b1',
    total: 40,
    staffId: 'staff-b',
    departmentUuid: 'd2',
    createdAt: DateTime(2026, 10, 18, 9),
  ),
  staffOrder(uuid: 'o-none', total: 300, staffId: null),
];

final purchases = [
  purchase(
    uuid: 'pu-a1',
    total: 60,
    payments: [payment(20)],
    departmentUuid: 'd1',
    createdAt: DateTime(2026, 10, 17, 14),
  ),
  purchase(
    uuid: 'pu-b1',
    total: 90,
    staffId: 'staff-b',
    departmentUuid: 'd2',
    createdAt: DateTime(2026, 10, 18, 14),
  ),
  purchase(uuid: 'pu-none', total: 700, staffId: null),
];

final expenses = [
  testExpense(
    uuid: 'e-a1',
    amount: 15,
    departmentUuid: 'd1',
    createdAt: DateTime(2026, 10, 17, 16),
  ),
  testExpense(
    uuid: 'e-o1',
    amount: 25,
    userId: 'owner-1',
    createdAt: DateTime(2026, 10, 16, 16),
  ),
  testExpense(uuid: 'e-none', amount: 999, userId: null),
  // Newer than r-x1, but a receipt's name wins.
  testExpense(
    uuid: 'e-x1',
    amount: 5,
    userId: 'staff-x',
    creator: 'X Exp',
    departmentUuid: 'd2',
    createdAt: DateTime(2026, 10, 18, 16),
  ),
];

StaffReportBase shopBase({StaffReportAccess? access}) => buildStaffBase(
  staff: staffList,
  owner: owner,
  receipts: receipts,
  invoices: invoices,
  orders: orders,
  purchases: purchases,
  expenses: expenses,
  access: access,
);

void main() {
  group('Totals match the reports filtered to the staff', () {
    final periods = <String, ReceiptsReportPeriod>{
      'all time': allTime,
      'one day': ReceiptsReportPeriod.day(DateTime(2026, 10, 17)),
      'a range': ReceiptsReportPeriod.range(
        DateTime(2026, 10, 17),
        DateTime(2026, 10, 18),
      ),
      'an empty day': ReceiptsReportPeriod.day(DateTime(2026, 9, 1)),
    };
    final accesses = <String, StaffReportAccess>{
      'view all': staffAccess(),
      'restricted to d1': staffAccess(
        departmentsEnabled: true,
        canViewAllDepartments: false,
        currentDepartmentUuid: 'd1',
      ),
      'view all, d2 chosen': staffAccess(
        departmentsEnabled: true,
        currentDepartmentUuid: 'd2',
      ),
      'departments on, none chosen': staffAccess(departmentsEnabled: true),
      'own records only': staffAccess(canViewAllTransactions: false),
    };

    for (final a in accesses.entries) {
      for (final p in periods.entries) {
        test('${a.key}, ${p.key}', () {
          final rows = staffRows(shopBase(access: a.value), period: p.value);
          expect(rows, isNotEmpty);
          for (final row in rows) {
            expectMatches(
              row,
              expectedFor(
                row.key,
                receipts: receipts,
                invoices: invoices,
                orders: orders,
                purchases: purchases,
                expenses: expenses,
                period: p.value,
                access: a.value,
              ),
            );
          }
        });
      }
    }

    test('all-time values, worked out by hand', () {
      final a = staffRowFor(shopBase(), 'staff-a');
      expect(a.name, 'Ada Obi');
      // r-a1 100 (void line left out) + r-a2 50 + 20.
      expect(a.receiptSales, 170);
      expect(a.receiptCount, 2);
      expect(a.invoiceSales, 100);
      expect(a.invoiceCount, 1);
      expect(a.orderTotal, 50);
      expect(a.orderCount, 1);
      expect(a.purchaseTotal, 60);
      expect(a.purchaseCount, 1);
      expect(a.expenseTotal, 15);
      expect(a.expenseCount, 1);
      expect(a.firstActivity, DateTime(2026, 10, 17, 9));
      expect(a.lastActivity, DateTime(2026, 10, 18, 10));

      final b = staffRowFor(shopBase(), 'staff-b');
      // r-b1 70 + the payment on staff-a's invoice, 40.
      expect(b.receiptSales, 110);
      expect(b.invoiceSales, 80);
      expect(b.orderTotal, 40);
      expect(b.purchaseTotal, 90);
      expect(b.expenseTotal, 0);
      expect(b.lastActivity, DateTime(2026, 10, 19, 9));
    });

    test('one row per staff, the owner and the former staff', () {
      final keys = staffRows(shopBase()).map((r) => r.key).toList();
      expect(keys, ['owner-1', 'staff-a', 'staff-b', 'staff-c', 'staff-x']);
    });

    test('records without a staff belong to no row', () {
      final rows = staffRows(shopBase());
      expect(rows.where((r) => r.key.trim().isEmpty), isEmpty);
      final t = StaffReportTotals.of(rows);
      expect(t.receiptSales, 200 + 170 + 110 + 9);
      expect(t.invoiceSales, 180);
      expect(t.orderTotal, 90);
      expect(t.purchaseTotal, 150);
      expect(t.expenseTotal, 25 + 15 + 5);
    });
  });

  group('Staff rows', () {
    test('a staff without activity has a row of zeros', () {
      final c = staffRowFor(shopBase(), 'staff-c');
      expect(c.receiptSales + c.invoiceSales + c.orderTotal, 0);
      expect(c.purchaseTotal + c.expenseTotal, 0);
      expect(c.activityCount, 0);
      expect(c.firstActivity, isNull);
      expect(c.lastActivity, isNull);
      expect(c.isFormer, isFalse);
    });

    test('the owner is a row, once, with its role', () {
      final o = staffRowFor(shopBase(), 'owner-1');
      expect(o.roleLabel, 'Owner');
      expect(o.receiptSales, 200);
      expect(o.expenseTotal, 25);

      final twice = buildStaffBase(staff: [owner, ...staffList], owner: owner);
      expect(staffRows(twice).where((r) => r.key == 'owner-1').length, 1);
    });

    test('the signed-in user has a row before the staff list loads', () {
      final base = buildStaffBase(
        staff: const [],
        currentUser: testUser(userId: 'staff-a'),
      );
      expect(staffRows(base).map((r) => r.key), ['staff-a']);
    });

    test('a user without an id is not a row', () {
      final base = buildStaffBase(
        staff: [testUser(userId: null), testUser(userId: '')],
      );
      expect(staffRows(base), isEmpty);
    });

    test('former staff: named from the records, role Former staff', () {
      final x = staffRowFor(shopBase(), 'staff-x');
      expect(x.isFormer, isTrue);
      expect(x.user, isNull);
      expect(x.name, 'Xena');
      expect(x.roleLabel, staffReportFormerRoleLabel);
      expect(x.roleKey, staffReportFormerRoleKey);
      expect(x.phone, isNull);
      expect(x.receiptSales, 9);
      expect(x.expenseTotal, 5);
    });

    test('former staff: an expense names them only as a fallback', () {
      final base = buildStaffBase(
        expenses: [
          testExpense(uuid: 'e-1', userId: 'staff-y', creator: 'Yemi'),
          testExpense(uuid: 'e-2', userId: 'staff-z', creator: null),
        ],
      );
      expect(staffRowFor(base, 'staff-y').name, 'Yemi');
      expect(staffRowFor(base, 'staff-z').name, 'Not Set');
    });

    test('former staff: the newest saved name wins', () {
      final base = buildStaffBase(
        receipts: [
          testReceipt(
            uuid: 'r-old',
            staffId: 'staff-x',
            createdAt: DateTime(2026, 10, 1),
          )..staffName = 'Old Name',
          testReceipt(
            uuid: 'r-new',
            staffId: 'staff-x',
            createdAt: DateTime(2026, 10, 2),
          )..staffName = 'New Name',
        ],
      );
      expect(staffRowFor(base, 'staff-x').name, 'New Name');
    });

    test('former staff only show in periods with their records', () {
      final keys =
          staffRows(
            shopBase(),
            period: ReceiptsReportPeriod.day(DateTime(2026, 10, 16)),
          ).map((r) => r.key).toList();
      expect(keys, isNot(contains('staff-x')));
      expect(keys, containsAll(['staff-a', 'staff-c']));
    });

    test('single: a former staff without records is a row of zeros', () {
      final slice = staffSlice(
        shopBase(),
        period: ReceiptsReportPeriod.day(DateTime(2026, 10, 16)),
      );
      final x = StaffReportRowBuilder.single(staffKey: 'staff-x', slice: slice);
      expect(x.isFormer, isTrue);
      expect(x.name, 'Xena');
      expect(x.activityCount, 0);
    });
  });

  group('Sales rules', () {
    test('VAT stays inside revenue', () {
      final receipt = testReceipt(uuid: 'r-1', cash: 107.5);
      receipt.vat = 7.5;
      receipt.originalCost = 100;
      final r = staffRowFor(buildStaffBase(receipts: [receipt]), 'staff-a');
      expect(r.receiptSales, 107.5);
    });

    test('every receipt type counts: sales, invoice payment, delivery', () {
      final base = buildStaffBase(
        receipts: [
          testReceipt(uuid: 's-1', cash: 1),
          invoicePayment(uuid: 'p-1', invoiceUuid: 'i-1', bank: 2),
          testReceipt(
            uuid: 'd-1',
            salesTypeIndex: 3,
            orderUuid: 'o-1',
            account: 4,
          ),
        ],
      );
      final r = staffRowFor(base, 'staff-a');
      expect(r.receiptSales, 7);
      expect(r.receiptCount, 3);
    });

    test('a void receipt line is not revenue', () {
      final base = buildStaffBase(
        receipts: [
          testReceipt(
            uuid: 'r-1',
            cash: 100,
            items: [
              saleLine(revenue: 100),
              saleLine(revenue: 40, isVoid: true),
            ],
          ),
        ],
      );
      expect(staffRowFor(base, 'staff-a').receiptSales, 100);
      expect(base.receiptRows.single.lineRevenue, 100);
    });

    test('void invoice lines leave the stored total alone', () {
      final base = buildStaffBase(
        invoices: [
          testInvoice(
            uuid: 'i-1',
            total: 100,
            items: [
              saleLine(revenue: 100),
              saleLine(revenue: 40, isVoid: true),
            ],
          ),
        ],
      );
      expect(staffRowFor(base, 'staff-a').invoiceSales, 100);
      expect(base.invoiceRows.single.totalItems, 1);
    });

    test('invoice part payments: the payer has the revenue', () {
      final base = buildStaffBase(
        staff: [testUser(), testUser(userId: 'staff-b', name: 'Bayo')],
        receipts: [
          invoicePayment(uuid: 'p-1', invoiceUuid: 'i-1', cash: 25),
          invoicePayment(
            uuid: 'p-2',
            invoiceUuid: 'i-1',
            bank: 15,
            staffId: 'staff-b',
          ),
        ],
        invoices: [testInvoice(uuid: 'i-1', total: 100)],
      );
      final a = staffRowFor(base, 'staff-a');
      final b = staffRowFor(base, 'staff-b');
      expect(a.invoiceSales, 100);
      expect(a.receiptSales, 25);
      expect(b.invoiceSales, 0);
      expect(b.receiptSales, 15);
      // The invoice report's balance counts both payments.
      expect(base.invoiceRows.single.balance, 60);
    });

    test('invoice payments count from every receipt, as the report', () {
      // The payment is another staff member's, so out of scope, but
      // the invoice report still counts it as paid.
      final base = buildStaffBase(
        receipts: [
          invoicePayment(
            uuid: 'p-1',
            invoiceUuid: 'i-1',
            cash: 30,
            staffId: 'staff-b',
          ),
        ],
        invoices: [testInvoice(uuid: 'i-1', total: 100)],
        access: staffAccess(canViewAllTransactions: false),
      );
      expect(base.receiptRows, isEmpty);
      expect(base.invoiceRows.single.balance, 70);
    });
  });

  group('Scope', () {
    void expectA(StaffReportAccess access, double value) {
      final r = staffRowFor(
        buildStaffBase(
          receipts: [
            testReceipt(uuid: 'r-d1', cash: 1, departmentUuid: 'd1'),
            testReceipt(uuid: 'r-d2', cash: 10, departmentUuid: 'd2'),
            testReceipt(uuid: 'r-none', cash: 100),
          ],
          invoices: [
            testInvoice(uuid: 'i-d1', total: 1, departmentUuid: 'd1'),
            testInvoice(uuid: 'i-d2', total: 10, departmentUuid: 'd2'),
            testInvoice(uuid: 'i-none', total: 100),
          ],
          orders: [
            staffOrder(uuid: 'o-d1', total: 1, departmentUuid: 'd1'),
            staffOrder(uuid: 'o-d2', total: 10, departmentUuid: 'd2'),
            staffOrder(uuid: 'o-none', total: 100),
          ],
          purchases: [
            purchase(uuid: 'pu-d1', total: 1, departmentUuid: 'd1'),
            purchase(uuid: 'pu-d2', total: 10, departmentUuid: 'd2'),
            purchase(uuid: 'pu-none', total: 100),
          ],
          expenses: [
            testExpense(uuid: 'e-d1', amount: 1, departmentUuid: 'd1'),
            testExpense(uuid: 'e-d2', amount: 10, departmentUuid: 'd2'),
            testExpense(uuid: 'e-none', amount: 100),
          ],
          access: access,
        ),
        'staff-a',
      );
      expect(r.receiptSales, value, reason: 'receipts');
      expect(r.invoiceSales, value, reason: 'invoices');
      expect(r.orderTotal, value, reason: 'orders');
      expect(r.purchaseTotal, value, reason: 'purchases');
      expect(r.expenseTotal, value, reason: 'expenses');
    }

    test('departments off: everything', () {
      expectA(staffAccess(), 111);
    });

    test('restricted user: the current department only', () {
      expectA(
        staffAccess(
          departmentsEnabled: true,
          canViewAllDepartments: false,
          currentDepartmentUuid: 'd1',
        ),
        1,
      );
    });

    test('restricted user without a department: unassigned only', () {
      expectA(
        staffAccess(departmentsEnabled: true, canViewAllDepartments: false),
        100,
      );
    });

    test('view all with a department chosen: that department', () {
      expectA(
        staffAccess(departmentsEnabled: true, currentDepartmentUuid: 'd2'),
        10,
      );
    });

    test('view all, no department chosen: everything', () {
      expectA(staffAccess(departmentsEnabled: true), 111);
    });

    test('without View All Transactions: only the own row', () {
      final access = staffAccess(canViewAllTransactions: false);
      final rows = staffRows(shopBase(access: access));
      expect(rows.map((r) => r.key), ['staff-a']);
      final own = staffRowFor(shopBase(), 'staff-a');
      expectMatches(
        rows.single,
        Expected(
          receiptSales: own.receiptSales,
          receiptCount: own.receiptCount,
          invoiceSales: own.invoiceSales,
          invoiceCount: own.invoiceCount,
          orders: OrderReportTotals.of(
            staffSlice(shopBase()).ordersOf('staff-a'),
          ),
          purchaseTotal: own.purchaseTotal,
          purchaseCount: own.purchaseCount,
          expenseTotal: own.expenseTotal,
          expenseCount: own.expenseCount,
        ),
      );
    });

    test('without View All Transactions: no other former staff', () {
      final access = staffAccess(
        canViewAllTransactions: false,
        currentUserId: 'staff-x',
      );
      // staff-x signed in but not in the list: their own row only.
      final rows = staffRows(shopBase(access: access));
      expect(rows.map((r) => r.key), ['staff-x']);
      expect(rows.single.receiptSales, 9);
    });

    test('other shops: invoices, orders and expenses left out', () {
      final base = buildStaffBase(
        invoices: [
          testInvoice(uuid: 'i-1', total: 1),
          testInvoice(uuid: 'i-2', total: 10, shopId: 2),
        ],
        orders: [
          staffOrder(uuid: 'o-1', total: 1),
          staffOrder(uuid: 'o-2', total: 10, shopId: 2),
        ],
        expenses: [
          testExpense(uuid: 'e-1', amount: 1),
          testExpense(uuid: 'e-2', amount: 10, shopId: 2),
        ],
        shopId: 1,
      );
      final r = staffRowFor(base, 'staff-a');
      expect(r.invoiceSales, 1);
      expect(r.orderTotal, 1);
      expect(r.expenseTotal, 1);
    });

    test('purchases queued for deletion are left out', () {
      final base = buildStaffBase(
        purchases: [
          purchase(uuid: 'pu-1', total: 1),
          purchase(uuid: 'pu-2', total: 10),
        ],
        pendingDeletedPurchaseUuids: {'pu-2'},
      );
      expect(staffRowFor(base, 'staff-a').purchaseTotal, 1);
    });
  });

  group('Period', () {
    const closing = TimeOfDay(hour: 4, minute: 0);
    final day17 = ReceiptsReportPeriod.day(DateTime(2026, 10, 17));
    final base = buildStaffBase(
      receipts: [
        testReceipt(
          uuid: 'before-close',
          cash: 1,
          createdAt: DateTime(2026, 10, 18, 3, 30),
        ),
        testReceipt(
          uuid: 'after-close',
          cash: 10,
          createdAt: DateTime(2026, 10, 18, 4, 30),
        ),
        testReceipt(
          uuid: 'older',
          cash: 100,
          createdAt: DateTime(2026, 10, 10, 12),
        ),
      ],
      orders: [
        staffOrder(
          uuid: 'o-before',
          total: 1,
          createdAt: DateTime(2026, 10, 18, 3, 30),
        ),
        staffOrder(
          uuid: 'o-after',
          total: 10,
          createdAt: DateTime(2026, 10, 18, 4, 30),
        ),
      ],
      purchases: [
        purchase(
          uuid: 'pu-before',
          total: 1,
          createdAt: DateTime(2026, 10, 18, 3, 30),
        ),
        purchase(
          uuid: 'pu-after',
          total: 10,
          createdAt: DateTime(2026, 10, 18, 4, 30),
        ),
      ],
      expenses: [
        testExpense(
          uuid: 'e-before',
          amount: 1,
          createdAt: DateTime(2026, 10, 18, 3, 30),
        ),
        testExpense(
          uuid: 'e-after',
          amount: 10,
          createdAt: DateTime(2026, 10, 18, 4, 30),
        ),
        testExpense(uuid: 'e-undated', amount: 100, undated: true),
      ],
    );

    test('a business day runs to the closing time', () {
      final r = staffRowFor(base, 'staff-a', period: day17, closingTime: closing);
      expect(r.receiptSales, 1);
      expect(r.orderTotal, 1);
      expect(r.purchaseTotal, 1);
      expect(r.expenseTotal, 1);
    });

    test('closing time matches the reports', () {
      expectMatches(
        staffRowFor(base, 'staff-a', period: day17, closingTime: closing),
        expectedFor(
          'staff-a',
          receipts: base.receiptRows.map((r) => r.receipt).toList(),
          invoices: const [],
          orders: base.orderRows.map((r) => r.order).toList(),
          purchases: base.purchaseRows.map((r) => r.purchase).toList(),
          expenses: base.expenseRows.map((r) => r.expense).toList(),
          period: day17,
          closingTime: closing,
        ),
      );
    });

    test('range is inclusive; undated expenses only in all time', () {
      final range = ReceiptsReportPeriod.range(
        DateTime(2026, 10, 10),
        DateTime(2026, 10, 18),
      );
      final r = staffRowFor(
        base,
        'staff-a',
        period: range,
        closingTime: closing,
      );
      expect(r.receiptSales, 111);
      expect(r.expenseTotal, 11);
      expect(staffRowFor(base, 'staff-a').expenseTotal, 111);
    });

    test('invoices use the business day of the invoice report', () {
      final base = buildStaffBase(
        invoices: [
          testInvoice(
            uuid: 'i-in',
            total: 1,
            createdAt: DateTime(2026, 10, 17, 23, 30),
          ),
          testInvoice(
            uuid: 'i-out',
            total: 10,
            createdAt: DateTime(2026, 10, 18, 0, 30),
          ),
        ],
      );
      expect(staffRowFor(base, 'staff-a', period: day17).invoiceSales, 1);
      expect(staffRowFor(base, 'staff-a').invoiceSales, 11);
    });

    test('initial period: all time with View Date, else today', () {
      expect(staffAccess().initialPeriod().isAllTime, isTrue);
      final today = staffAccess(
        canPickDate: false,
      ).initialPeriod(now: DateTime(2026, 10, 18, 3, 45), closingTime: closing);
      expect(today.isSingleDay, isTrue);
      expect(today.start, DateTime(2026, 10, 17));
    });
  });

  group('Column gates', () {
    test('orders hidden: not built, zero, not sortable', () {
      final access = staffAccess(showOrders: false);
      final base = shopBase(access: access);
      expect(base.orderRows, isEmpty);
      expect(staffRowFor(base, 'staff-a').orderTotal, 0);
      expect(
        StaffReportQuery.visibleSort(StaffReportSortField.orderTotal, access),
        StaffReportSortField.name,
      );
      expect(
        StaffReportQuery.visibleSort(StaffReportSortField.orderCount, access),
        StaffReportSortField.name,
      );
    });

    test('purchases hidden: not built, zero, not sortable', () {
      final access = staffAccess(showPurchases: false);
      final base = shopBase(access: access);
      expect(base.purchaseRows, isEmpty);
      expect(staffRowFor(base, 'staff-a').purchaseTotal, 0);
      expect(
        StaffReportQuery.visibleSort(
          StaffReportSortField.purchaseTotal,
          access,
        ),
        StaffReportSortField.name,
      );
    });

    test('expenses hidden: not built, zero, not sortable', () {
      final access = staffAccess(showExpenses: false);
      final base = shopBase(access: access);
      expect(base.expenseRows, isEmpty);
      expect(staffRowFor(base, 'staff-a').expenseTotal, 0);
      expect(
        StaffReportQuery.visibleSort(StaffReportSortField.expenseTotal, access),
        StaffReportSortField.name,
      );
    });

    test('a former staff with hidden records only is not a row', () {
      final base = buildStaffBase(
        expenses: [testExpense(userId: 'staff-y', creator: 'Yemi')],
        access: staffAccess(showExpenses: false),
      );
      expect(staffRows(base).map((r) => r.key), ['staff-a']);
    });

    test('visible columns keep their sort', () {
      for (final f in StaffReportSortField.values) {
        expect(StaffReportQuery.visibleSort(f, staffAccess()), f);
      }
    });
  });

  group('Filters, sorting, totals and paging', () {
    final rows = staffRows(shopBase());

    List<String> keys(Iterable<StaffReportRow> rows) =>
        rows.map((r) => r.key).toList();

    List<StaffReportRow> query(
      StaffReportFilters filters, {
      StaffReportSortField sortField = StaffReportSortField.name,
      bool ascending = true,
      StaffReportAccess? access,
      List<StaffReportRow>? from,
    }) => StaffReportQuery.filterAndSort(
      rows: from ?? rows,
      filters: filters,
      sortField: sortField,
      ascending: ascending,
      access: access ?? staffAccess(),
    );

    test('role choices: one per role, case-insensitive, plus former', () {
      final options = StaffReportOptions.roles(rows);
      expect(options.map((o) => o.label), [
        'Cashier',
        staffReportFormerRoleLabel,
        'Manager',
        'Owner',
      ]);
      expect(options.map((o) => o.key), contains(staffReportFormerRoleKey));
    });

    test('a staff without a role is Not Set', () {
      final base = buildStaffBase(staff: [testUser(role: '  ')]);
      final r = staffRows(base).single;
      expect(r.roleLabel, 'Not Set');
      expect(r.roleKey, staffReportNoRoleKey);
    });

    test('role filter', () {
      expect(keys(query(StaffReportFilters(roleKey: 'cashier'))), [
        'staff-a',
        'staff-c',
      ]);
      expect(
        keys(query(StaffReportFilters(roleKey: staffReportFormerRoleKey))),
        ['staff-x'],
      );
    });

    test('search: name, phone, role', () {
      expect(keys(query(StaffReportFilters(search: 'bay'))), ['staff-b']);
      expect(keys(query(StaffReportFilters(search: 'obi'))), ['staff-a']);
      expect(keys(query(StaffReportFilters(search: '0803'))), ['staff-c']);
      expect(keys(query(StaffReportFilters(search: ' MANAGER '))), [
        'staff-b',
      ]);
      expect(keys(query(StaffReportFilters(search: 'former'))), ['staff-x']);
    });

    test('filters: copy, count, clear', () {
      final f = StaffReportFilters(search: 'a', roleKey: 'cashier');
      final c = f.copy()..clearAll();
      expect(f.activeCount, 1);
      expect(f.hasAnything, isTrue);
      expect(c.hasAnything, isFalse);
      expect(f.roleKey, 'cashier');
    });

    test('sort by name by default, A to Z', () {
      expect(keys(query(StaffReportFilters())), [
        'staff-a',
        'staff-b',
        'staff-c',
        'owner-1',
        'staff-x',
      ]);
    });

    test('sort by receipt sales, both ways', () {
      final desc = query(
        StaffReportFilters(),
        sortField: StaffReportSortField.receiptSales,
        ascending: false,
      );
      expect(keys(desc), [
        'owner-1',
        'staff-a',
        'staff-b',
        'staff-x',
        'staff-c',
      ]);
      final asc = query(
        StaffReportFilters(),
        sortField: StaffReportSortField.receiptSales,
      );
      expect(keys(asc), keys(desc).reversed.toList());
    });

    test('every column sorts', () {
      for (final f in StaffReportSortField.values) {
        expect(query(StaffReportFilters(), sortField: f).length, rows.length);
      }
      expect(
        keys(
          query(
            StaffReportFilters(),
            sortField: StaffReportSortField.purchaseTotal,
            ascending: false,
          ),
        ).take(2),
        ['staff-b', 'staff-a'],
      );
      expect(
        keys(
          query(
            StaffReportFilters(),
            sortField: StaffReportSortField.expenseCount,
            ascending: false,
          ),
        ).take(3),
        ['staff-a', 'owner-1', 'staff-x'],
      );
    });

    test('no phone sinks to the bottom, both ways', () {
      for (final asc in [true, false]) {
        final out = query(
          StaffReportFilters(),
          sortField: StaffReportSortField.phone,
          ascending: asc,
        );
        expect(out.last.key, 'staff-x');
      }
    });

    test('ties break on name, then id', () {
      final base = buildStaffBase(
        staff: [
          testUser(userId: 'id-2', name: 'Same'),
          testUser(userId: 'id-1', name: 'Same'),
          testUser(userId: 'id-3', name: 'Abe'),
        ],
      );
      expect(
        keys(
          query(
            StaffReportFilters(),
            sortField: StaffReportSortField.receiptSales,
            from: staffRows(base),
          ),
        ),
        ['id-3', 'id-1', 'id-2'],
      );
    });

    test('totals cover the full filtered set, not one page', () {
      final staff = [
        for (var i = 0; i < 250; i++)
          testUser(
            userId: 'u-${i.toString().padLeft(3, '0')}',
            name: 'Staff ${i.toString().padLeft(3, '0')}',
            role: i.isEven ? 'Cashier' : 'Manager',
          ),
      ];
      final base = buildStaffBase(
        staff: staff,
        receipts: [
          for (final u in staff)
            testReceipt(uuid: 'r-${u.userId}', cash: 2, staffId: u.userId),
        ],
        expenses: [
          for (final u in staff)
            testExpense(uuid: 'e-${u.userId}', amount: 1, userId: u.userId),
        ],
      );
      final all = staffRows(base);

      final page2 = StaffReportQuery.paginate(
        query(StaffReportFilters(), from: all),
        2,
      );
      expect(page2.totalCount, 250);
      expect(page2.totalPages, 3);
      expect(page2.rows.length, 100);
      expect(page2.firstIndex, 101);
      expect(page2.lastIndex, 200);
      expect(page2.rows.first.name, 'Staff 100');
      expect(page2.totals.count, 250);
      expect(page2.totals.receiptSales, 500);
      expect(page2.totals.receiptCount, 250);
      expect(page2.totals.expenseTotal, 250);

      final cashiers = StaffReportQuery.paginate(
        query(StaffReportFilters(roleKey: 'cashier'), from: all),
        1,
      );
      expect(cashiers.totals.count, 125);
      expect(cashiers.totals.receiptSales, 250);
      expect(cashiers.totalPages, 2);
    });

    test('paging clamps and handles an empty set', () {
      final sorted = query(StaffReportFilters());
      final last = StaffReportQuery.paginate(sorted, 9, pageSize: 2);
      expect(last.page, 3);
      expect(last.rows.map((r) => r.key), ['staff-x']);
      expect(last.firstIndex, 5);
      expect(last.lastIndex, 5);
      expect(StaffReportQuery.paginate(sorted, 0, pageSize: 2).page, 1);

      final empty = StaffReportQuery.paginate(const [], 3);
      expect(empty.page, 1);
      expect(empty.totalPages, 1);
      expect(empty.rows, isEmpty);
      expect(empty.firstIndex, 0);
      expect(empty.lastIndex, 0);
      expect(empty.totals.count, 0);
    });
  });

  group('Staff Expenses table agrees with the row', () {
    test('unfiltered totals are the row values', () {
      final base = shopBase();
      for (final key in ['owner-1', 'staff-a', 'staff-x']) {
        final page = StaffExpensesTable.page(
          base: base,
          staffKey: key,
          period: allTime,
          filters: StaffExpensesFilters(),
        );
        final row = staffRowFor(base, key);
        expect(page.totals.amount, row.expenseTotal, reason: key);
        expect(page.totals.count, row.expenseCount, reason: key);
      }
    });
  });

  group('Last activity and first direction', () {
    final rows = staffRows(shopBase());

    List<String> byLastActivity(bool ascending) =>
        StaffReportQuery.filterAndSort(
          rows: rows,
          filters: StaffReportFilters(),
          sortField: StaffReportSortField.lastActivity,
          ascending: ascending,
          access: staffAccess(),
        ).map((r) => r.key).toList();

    test('last activity: newest first, no activity last', () {
      expect(byLastActivity(false), [
        'staff-b',
        'staff-x',
        'staff-a',
        'owner-1',
        'staff-c',
      ]);
    });

    test('last activity: oldest first, no activity still last', () {
      expect(byLastActivity(true), [
        'owner-1',
        'staff-a',
        'staff-x',
        'staff-b',
        'staff-c',
      ]);
    });

    test('text A-Z first; counts, amounts and dates largest first', () {
      const text = {
        StaffReportSortField.name,
        StaffReportSortField.role,
        StaffReportSortField.phone,
      };
      for (final f in StaffReportSortField.values) {
        expect(
          StaffReportQuery.defaultAscending(f),
          text.contains(f),
          reason: f.name,
        );
      }
    });
  });

  group('Table screen', () {
    // Money shows as 'N<value>' (fakeStaffEnv).
    final day17 = ReceiptsReportPeriod.day(DateTime(2026, 10, 17));
    List<TempUserClass> threeStaff() => [
      testUser(userId: 'staff-a', name: 'Ada'),
      testUser(userId: 'staff-b', name: 'Bayo', role: 'Manager'),
      testUser(userId: 'staff-c', name: 'Chika'),
    ];
    // Receipt sales: Ada 10, Bayo 107 (7 on the 17th), Chika 50.
    List<TempMainReceipt> salesOfThree() => [
      testReceipt(uuid: 'r-a', cash: 10, createdAt: DateTime(2026, 10, 18)),
      testReceipt(
        uuid: 'r-b17',
        cash: 7,
        staffId: 'staff-b',
        createdAt: DateTime(2026, 10, 17, 12),
      ),
      testReceipt(
        uuid: 'r-b10',
        cash: 100,
        staffId: 'staff-b',
        createdAt: DateTime(2026, 10, 10, 12),
      ),
      testReceipt(
        uuid: 'r-c',
        cash: 50,
        staffId: 'staff-c',
        createdAt: DateTime(2026, 10, 18, 12),
      ),
    ];

    for (final isDesktop in [true, false]) {
      final width = isDesktop ? 'desktop' : 'mobile';

      double y(WidgetTester tester, String text) =>
          tester.getTopLeft(find.text(text)).dy;

      void expectOrder(WidgetTester tester, List<String> names) {
        for (var k = 1; k < names.length; k++) {
          expect(
            y(tester, names[k - 1]),
            lessThan(y(tester, names[k])),
            reason: '${names[k - 1]} above ${names[k]}',
          );
        }
      }

      Future<void> tapHeader(WidgetTester tester, String label) async {
        await tester.ensureVisible(find.text(label));
        await tester.pumpAndSettle();
        await tester.tap(find.text(label));
        await tester.pumpAndSettle();
      }

      testWidgets('name A-Z by default ($width)', (tester) async {
        await pumpStaffTable(
          tester,
          isDesktop: isDesktop,
          env: fakeStaffEnv(staff: threeStaff().reversed.toList()),
        );
        expectOrder(tester, ['Ada', 'Bayo', 'Chika']);
        expect(find.byIcon(Icons.arrow_upward_rounded), findsOneWidget);
        expect(find.byIcon(Icons.arrow_downward_rounded), findsNothing);
      });

      testWidgets('first tap on Receipt Sales: largest first ($width)', (
        tester,
      ) async {
        await pumpStaffTable(
          tester,
          isDesktop: isDesktop,
          env: fakeStaffEnv(staff: threeStaff(), receipts: salesOfThree()),
        );
        await tapHeader(tester, 'Receipt Sales');
        expect(find.byIcon(Icons.arrow_downward_rounded), findsOneWidget);
        expectOrder(tester, ['Bayo', 'Chika', 'Ada']);

        await tapHeader(tester, 'Receipt Sales');
        expect(find.byIcon(Icons.arrow_upward_rounded), findsOneWidget);
        expectOrder(tester, ['Ada', 'Chika', 'Bayo']);
      });

      testWidgets('role filter and its chip ($width)', (tester) async {
        await pumpStaffTable(
          tester,
          isDesktop: isDesktop,
          env: fakeStaffEnv(staff: threeStaff()),
        );
        expect(
          find.text('All time covers the data loaded on this device.'),
          findsOneWidget,
        );

        await tester.tap(find.text('Filters'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('All roles'));
        await tester.pumpAndSettle();
        // The dialog's choice, above the table's role cell.
        await tester.tap(find.text('Manager').last);
        await tester.pumpAndSettle();

        expect(find.text('Filters (1)'), findsOneWidget);
        expect(find.text('Bayo'), findsOneWidget);
        expect(find.text('Ada'), findsNothing);
        expect(find.text('Chika'), findsNothing);
        final chip = find.widgetWithText(InputChip, 'Role: Manager');
        expect(chip, findsOneWidget);

        await tester.tap(
          find.descendant(of: chip, matching: find.byIcon(Icons.close)),
        );
        await tester.pumpAndSettle();

        expect(find.widgetWithText(InputChip, 'Role: Manager'), findsNothing);
        expect(find.text('Ada'), findsOneWidget);
        expect(find.text('Chika'), findsOneWidget);
        expect(find.text('Filters'), findsOneWidget);
      });

      testWidgets('Reset All keeps the period ($width)', (tester) async {
        await pumpStaffTable(
          tester,
          isDesktop: isDesktop,
          env: fakeStaffEnv(staff: threeStaff(), receipts: salesOfThree()),
          filters: StaffReportFilters(roleKey: 'manager'),
          period: day17,
        );
        final pill = 'Date: ${receiptsPeriodLabel(day17)}';
        expect(find.text(pill), findsOneWidget);
        expect(find.text('Reset All Filters'), findsOneWidget);
        expect(find.widgetWithText(InputChip, 'Role: Manager'), findsOneWidget);
        expect(find.text('Ada'), findsNothing);

        await tester.tap(find.text('Reset All Filters'));
        await tester.pumpAndSettle();

        expect(find.text('Reset All Filters'), findsNothing);
        expect(find.widgetWithText(InputChip, 'Role: Manager'), findsNothing);
        expect(find.text('Ada'), findsOneWidget);
        expect(find.text(pill), findsOneWidget);
        // Still the 17th only: Bayo's receipt of the 10th stays out.
        expect(find.text('N7.0'), findsWidgets);
        expect(find.text('N107.0'), findsNothing);
        expect(
          find.text('All time covers the data loaded on this device.'),
          findsNothing,
        );
      });

      testWidgets('totals are the same on every page ($width)', (tester) async {
        final staff = [
          for (var i = 0; i < 150; i++)
            testUser(
              userId: 'u-$i',
              name: 'Staff ${i.toString().padLeft(3, '0')}',
            ),
        ];
        final receipts = [
          for (var i = 0; i < 150; i++)
            testReceipt(uuid: 'r-$i', staffId: 'u-$i', cash: 10),
        ];
        await pumpStaffTable(
          tester,
          isDesktop: isDesktop,
          env: fakeStaffEnv(staff: staff, receipts: receipts),
        );
        expect(find.text('Showing 1-100 of 150 staff'), findsOneWidget);
        expect(find.text('N1500.0'), findsOneWidget);

        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();

        expect(find.text('Page 2 of 2'), findsOneWidget);
        expect(find.text('Showing 101-150 of 150 staff'), findsOneWidget);
        expect(find.text('N1500.0'), findsOneWidget);
      });

      final gates = <String, (StaffReportAccess, List<String>)>{
        'orders': (staffAccess(showOrders: false), ['Orders', 'Order Value']),
        'purchases': (
          staffAccess(showPurchases: false),
          ['Purchases', 'Purchase Value'],
        ),
        'expenses': (
          staffAccess(showExpenses: false),
          ['Expenses', 'Expense Value'],
        ),
      };
      const allGated = [
        'Orders',
        'Order Value',
        'Purchases',
        'Purchase Value',
        'Expenses',
        'Expense Value',
      ];
      testWidgets('every column shown by default ($width)', (tester) async {
        await pumpStaffTable(tester, isDesktop: isDesktop, env: fakeStaffEnv());
        for (final label in [
          'Name',
          'Role',
          'Phone',
          'Receipt Sales',
          'Invoice Sales',
          ...allGated,
          'Last Activity',
        ]) {
          expect(find.text(label), findsOneWidget, reason: label);
        }
      });
      for (final g in gates.entries) {
        testWidgets('${g.key} hidden by access ($width)', (tester) async {
          final (access, hidden) = g.value;
          await pumpStaffTable(
            tester,
            isDesktop: isDesktop,
            env: fakeStaffEnv(access: access),
          );
          for (final label in allGated) {
            expect(
              find.text(label),
              hidden.contains(label) ? findsNothing : findsOneWidget,
              reason: label,
            );
          }
          expect(find.text('Receipt Sales'), findsOneWidget);
        });
      }

      testWidgets('former staff are marked ($width)', (tester) async {
        await pumpStaffTable(
          tester,
          isDesktop: isDesktop,
          env: fakeStaffEnv(
            receipts: [
              testReceipt(uuid: 'r-x', cash: 9, staffId: 'staff-x')
                ..staffName = 'Xena',
            ],
          ),
        );
        expect(find.text('Xena'), findsOneWidget);
        // The name's badge; the role cell is a dash.
        expect(find.text(staffReportFormerRoleLabel), findsOneWidget);
        expect(find.text('Ada'), findsOneWidget);
      });

      testWidgets('only the own row without View All Transactions ($width)', (
        tester,
      ) async {
        await pumpStaffTable(
          tester,
          isDesktop: isDesktop,
          env: fakeStaffEnv(
            staff: threeStaff(),
            receipts: salesOfThree(),
            access: staffAccess(canViewAllTransactions: false),
          ),
        );
        expect(find.text('Ada'), findsOneWidget);
        expect(find.text('Bayo'), findsNothing);
        expect(find.text('Chika'), findsNothing);
        expect(find.text('Showing 1-1 of 1 staff'), findsOneWidget);
        // Ada's row and the total: her own receipt only.
        expect(find.text('N10.0'), findsNWidgets(2));
      });

      testWidgets('a row opens the analysis on the period ($width)', (
        tester,
      ) async {
        final opened = <OpenedStaffAnalysis>[];
        await pumpStaffTable(
          tester,
          isDesktop: isDesktop,
          env: fakeStaffEnv(
            staff: threeStaff(),
            receipts: salesOfThree(),
            opened: opened,
          ),
          period: day17,
        );
        await tester.tap(find.text('Bayo'));
        await tester.pumpAndSettle();

        expect(opened.length, 1);
        expect(opened.single.staff.key, 'staff-b');
        expect(opened.single.staff.name, 'Bayo');
        expect(opened.single.period.isAllTime, isFalse);
        expect(opened.single.period.start, day17.start);
        expect(opened.single.period.end, day17.end);
      });

      testWidgets('back from the analysis rebuilds the rows ($width)', (
        tester,
      ) async {
        final receipts = [testReceipt(uuid: 'r-1', cash: 10)];
        await pumpStaffTable(
          tester,
          isDesktop: isDesktop,
          env: fakeStaffEnv(
            receipts: receipts,
            onOpen: () => receipts.add(testReceipt(uuid: 'r-2', cash: 15)),
          ),
        );
        expect(find.text('N10.0'), findsWidgets);
        expect(find.text('N25.0'), findsNothing);

        await tester.tap(find.text('Ada'));
        await tester.pumpAndSettle();

        expect(find.text('N25.0'), findsWidgets);
        expect(find.text('N10.0'), findsNothing);
      });

      testWidgets('without View Date the period is today ($width)', (
        tester,
      ) async {
        await pumpStaffTable(
          tester,
          isDesktop: isDesktop,
          env: fakeStaffEnv(
            receipts: salesOfThree(),
            access: staffAccess(canPickDate: false),
          ),
        );
        expect(
          find.text(
            'Date: ${receiptsPeriodLabel(ReceiptsReportPeriod.today())}',
          ),
          findsOneWidget,
        );
        expect(
          find.text('All time covers the data loaded on this device.'),
          findsNothing,
        );
        expect(
          tester
              .widget<PopupMenuButton<int>>(find.byType(PopupMenuButton<int>))
              .enabled,
          isFalse,
        );
      });

      testWidgets('a row opens the Staff Analysis page ($width)', (
        tester,
      ) async {
        await pumpStaffTable(
          tester,
          isDesktop: isDesktop,
          env: fakeStaffEnv(
            staff: threeStaff(),
            receipts: salesOfThree(),
            pushAnalysis: true,
          ),
          period: day17,
        );
        await tester.tap(find.text('Bayo'));
        await tester.pumpAndSettle();

        // The analysis of Bayo, on the table's period.
        expect(find.byType(StaffAnalysisView), findsOneWidget);
        expect(
          find.byKey(const ValueKey('staff-section-receipts')),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byKey(const ValueKey('staff-kpi-receipt-sales')),
            matching: find.text('N7.0'),
          ),
          findsOneWidget,
        );
        expect(
          find.text('Date: ${receiptsPeriodLabel(day17)}'),
          findsOneWidget,
        );

        // The app bar's own back button (constants/app_bar.dart).
        await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
        await tester.pumpAndSettle();

        expect(find.byType(StaffAnalysisView), findsNothing);
        expect(find.byType(StaffReportTableView), findsOneWidget);
        expect(find.text('Bayo'), findsOneWidget);
      });
    }
  });
}
