import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/temp_invoices/temp_invoices.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/classes/temp_orders/orders.dart';
import 'package:stockall/pages/report/customer_report/customer_report_table/class/customer_report_table_logic.dart';
import 'package:stockall/pages/report/invoice_report/invoice_report_table/class/invoice_report_table_logic.dart';
import 'package:stockall/pages/report/order_report/order_report_table/class/order_report_table_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/components/receipts_report_filter_widgets.dart';

import 'customer_report_fixtures.dart';

// Expected values come straight from each report's own builders and
// queries, filtered to one customer, as the "See all" tables show
// them. In tests the Invoice Report query uses midnight as the
// closing time (no shop provider), so periods that include invoices
// use midnight for every report.

class ExpectedTotals {
  final double revenue;
  final double receiptPurchases;
  final int receiptCount;
  final double invoicePurchases;
  final double credit;
  final int invoiceCount;
  final OrderReportTotals orders;

  ExpectedTotals({
    required this.revenue,
    required this.receiptPurchases,
    required this.receiptCount,
    required this.invoicePurchases,
    required this.credit,
    required this.invoiceCount,
    required this.orders,
  });
}

ExpectedTotals expectedFor(
  String customerUuid, {
  required List<TempMainReceipt> receipts,
  required List<TempInvoice> invoices,
  required List<Orders> orders,
  required ReceiptsReportPeriod period,
  CustomerReportAccess? access,
  TimeOfDay? closingTime,
}) {
  final a = access ?? testAccess();
  final receiptRows = ReceiptsReportRowBuilder.buildAll(
    receipts: ReceiptsReportAccess.scope(
      receipts: receipts,
      departmentsEnabled: a.departmentsEnabled,
      canViewAllDepartments: a.canViewAllDepartments,
      currentDepartmentUuid: a.currentDepartmentUuid,
      canViewAllTransactions: a.canViewAllTransactions,
      currentUserId: a.currentUserId,
    ),
    legacySales: const [],
  );
  ReceiptsReportPage receiptsPage(ReceiptType? type) =>
      ReceiptsReportQuery.paginate(
        ReceiptsReportQuery.filterAndSort(
          rows: receiptRows,
          period: period,
          filters: ReceiptsReportFilters(customerKey: customerUuid, type: type),
          sortField: ReceiptsSortField.createdAt,
          ascending: false,
          departmentsEnabled: true,
          subStaffEnabled: true,
          profitVisible: true,
          closingTime: closingTime,
        ),
        1,
      );
  final allReceipts = receiptsPage(null);
  final sales = receiptsPage(ReceiptType.sales);

  final invoicePage = InvoiceReportQuery.paginate(
    InvoiceReportQuery.filterAndSort(
      rows: InvoiceReportRowBuilder.buildAll(
        invoices: a.scopeInvoices(invoices),
        allReceipts: receipts,
        allProductSales: const [],
        customerMap: const {},
      ),
      filters: InvoiceReportFilters(
        customerUuid: customerUuid,
        dateRange: customerReportDateRange(period),
      ),
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
    filters: OrderReportFilters(customerKey: customerUuid),
    sortField: OrderSortField.createdAt,
    ascending: false,
    departmentsEnabled: true,
    subStaffEnabled: true,
    profitVisible: true,
    closingTime: closingTime,
  );

  return ExpectedTotals(
    revenue: allReceipts.totalRevenue,
    receiptPurchases: sales.totalRevenue,
    receiptCount: allReceipts.totalCount,
    invoicePurchases: invoicePage.totalRevenue,
    credit: invoicePage.totalBalance,
    invoiceCount: invoicePage.totalCount,
    orders: OrderReportTotals.of(orderRows),
  );
}

void expectMatches(CustomerReportRow row, ExpectedTotals e) {
  expect(row.revenue, closeTo(e.revenue, 1e-9), reason: 'revenue');
  expect(
    row.receiptPurchases,
    closeTo(e.receiptPurchases, 1e-9),
    reason: 'receipt purchases',
  );
  expect(row.receiptCount, e.receiptCount, reason: 'receipts');
  expect(
    row.invoicePurchases,
    closeTo(e.invoicePurchases, 1e-9),
    reason: 'invoice purchases',
  );
  expect(row.credit, closeTo(e.credit, 1e-9), reason: 'credit');
  expect(row.invoiceCount, e.invoiceCount, reason: 'invoices');
  expect(row.orderCount, e.orders.count, reason: 'orders');
  expect(row.orderTotal, closeTo(e.orders.total, 1e-9));
  expect(row.orderPaid, closeTo(e.orders.paid, 1e-9));
  expect(row.orderBalance, closeTo(e.orders.balance, 1e-9));
}

void main() {
  group('Totals match the reports filtered to the customer', () {
    final customers = [
      testCustomer(uuid: 'cust-1', name: 'Bola'),
      testCustomer(uuid: 'cust-2', name: 'Chidi'),
      testCustomer(uuid: 'cust-3', name: 'Dayo'),
    ];
    final receipts = [
      testReceipt(
        uuid: 's-1',
        cash: 100,
        createdAt: DateTime(2026, 10, 17, 12),
        items: [saleLine(revenue: 100), saleLine(revenue: 30, isVoid: true)],
      ),
      testReceipt(
        uuid: 's-2',
        bank: 50,
        account: 20,
        createdAt: DateTime(2026, 10, 18, 10),
      ),
      testReceipt(
        uuid: 's-3',
        customerUuid: 'cust-2',
        cash: 70,
        createdAt: DateTime(2026, 10, 17, 15),
      ),
      testReceipt(
        uuid: 'w-1',
        customerUuid: null,
        customerName: null,
        cash: 500,
      ),
      invoicePayment(
        uuid: 'p-1',
        invoiceUuid: 'inv-1',
        cash: 40,
        createdAt: DateTime(2026, 10, 18, 11),
      ),
      invoicePayment(
        uuid: 'p-2',
        invoiceUuid: 'inv-3',
        cash: 60,
        createdAt: DateTime(2026, 10, 16, 11),
      ),
      testReceipt(
        uuid: 'd-1',
        salesTypeIndex: 3,
        orderUuid: 'ord-1',
        cash: 30,
        createdAt: DateTime(2026, 10, 19, 9),
      ),
      // Order deposit at checkout: a Sales receipt with orderUuid.
      testReceipt(
        uuid: 'dep-1',
        customerUuid: 'cust-2',
        orderUuid: 'ord-2',
        cash: 10,
        createdAt: DateTime(2026, 10, 17, 16),
      ),
    ];
    final invoices = [
      testInvoice(
        uuid: 'inv-1',
        total: 100,
        createdAt: DateTime(2026, 10, 17, 9),
      ),
      testInvoice(
        uuid: 'inv-2',
        customerUuid: 'cust-2',
        total: 80,
        createdAt: DateTime(2026, 10, 19, 9),
      ),
      testInvoice(
        uuid: 'inv-3',
        total: 60,
        createdAt: DateTime(2026, 10, 16, 9),
      ),
    ];
    final orders = [
      customerOrder(
        uuid: 'ord-1',
        total: 50,
        createdAt: DateTime(2026, 10, 17, 10),
      ),
      customerOrder(
        uuid: 'ord-2',
        customerId: 'cust-2',
        total: 40,
        createdAt: DateTime(2026, 10, 17, 11),
      ),
    ];
    final base = buildBase(
      customers: customers,
      receipts: receipts,
      invoices: invoices,
      orders: orders,
    );

    final periods = <String, ReceiptsReportPeriod>{
      'all time': allTime,
      'one day': ReceiptsReportPeriod.day(DateTime(2026, 10, 17)),
      'a range': ReceiptsReportPeriod.range(
        DateTime(2026, 10, 17),
        DateTime(2026, 10, 18),
      ),
      'an empty day': ReceiptsReportPeriod.day(DateTime(2026, 9, 1)),
    };

    for (final p in periods.entries) {
      for (final uuid in ['cust-1', 'cust-2', 'cust-3']) {
        test('$uuid, ${p.key}', () {
          expectMatches(
            rowFor(base, uuid, period: p.value),
            expectedFor(
              uuid,
              receipts: receipts,
              invoices: invoices,
              orders: orders,
              period: p.value,
            ),
          );
        });
      }
    }

    test('all-time values, worked out by hand', () {
      final r = rowFor(base, 'cust-1');
      // s-1 100 + s-2 70 + p-1 40 + p-2 60 + d-1 30.
      expect(r.revenue, 300);
      expect(r.receiptPurchases, 170);
      expect(r.invoicePurchases, 160);
      // inv-1 100 - 40; inv-3 fully paid.
      expect(r.credit, 60);
      expect(r.receiptCount, 5);
      expect(r.salesReceiptCount, 2);
      expect(r.invoiceCount, 2);
      expect(r.orderCount, 1);
      expect(r.orderTotal, 50);
      expect(r.orderPaid, 30);
      expect(r.orderBalance, 20);
    });

    test('an order deposit is a receipt purchase and order paid', () {
      final r = rowFor(base, 'cust-2');
      expect(r.receiptPurchases, 80);
      expect(r.orderPaid, 10);
      expect(r.orderBalance, 30);
    });

    test('a customer without activity has a row of zeros', () {
      final r = rowFor(base, 'cust-3');
      expect(r.revenue, 0);
      expect(r.credit, 0);
      expect(r.receiptCount + r.invoiceCount + r.orderCount, 0);
      expect(r.firstPurchase, isNull);
      expect(r.lastPurchase, isNull);
    });

    test('walk-in receipts belong to no customer', () {
      final rows = rowsOf(base);
      expect(rows.length, 3);
      final total = rows.fold<double>(0, (s, r) => s + r.revenue);
      expect(total, 300 + 80);
    });

    test('first and last purchase: Sales receipts, invoices, orders', () {
      final r = rowFor(base, 'cust-1');
      expect(r.firstPurchase, DateTime(2026, 10, 16, 9));
      // d-1 on the 19th is a delivery, not a purchase.
      expect(r.lastPurchase, DateTime(2026, 10, 18, 10));
    });
  });

  group('Revenue rules', () {
    test('VAT stays inside revenue', () {
      final receipt = testReceipt(uuid: 'r-1', cash: 107.5);
      receipt.vat = 7.5;
      receipt.originalCost = 100;
      final r = rowFor(buildBase(receipts: [receipt]), 'cust-1');
      expect(r.revenue, 107.5);
      expect(r.receiptPurchases, 107.5);
    });

    test('revenue counts cash, bank and customer account', () {
      final r = rowFor(
        buildBase(
          receipts: [testReceipt(uuid: 'r-1', cash: 1, bank: 2, account: 4)],
        ),
        'cust-1',
      );
      expect(r.revenue, 7);
    });

    test('invoice part payments: revenue is paid, credit the rest', () {
      final base = buildBase(
        receipts: [
          invoicePayment(uuid: 'p-1', invoiceUuid: 'i-1', cash: 25),
          invoicePayment(uuid: 'p-2', invoiceUuid: 'i-1', bank: 15),
        ],
        invoices: [testInvoice(uuid: 'i-1', total: 100)],
      );
      final r = rowFor(base, 'cust-1');
      expect(r.revenue, 40);
      expect(r.receiptPurchases, 0);
      expect(r.invoicePurchases, 100);
      expect(r.credit, 60);
    });

    test('an overpaid invoice gives negative credit, as the report', () {
      final base = buildBase(
        receipts: [invoicePayment(uuid: 'p-1', invoiceUuid: 'i-1', cash: 120)],
        invoices: [testInvoice(uuid: 'i-1', total: 100)],
      );
      expect(rowFor(base, 'cust-1').credit, -20);
      expect(rowFor(base, 'cust-1').hasCredit, isFalse);
    });
  });

  group('Void lines', () {
    test('a void receipt line is not revenue', () {
      final base = buildBase(
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
      expect(rowFor(base, 'cust-1').revenue, 100);
      expect(base.receiptRows.single.lineRevenue, 100);
    });

    test('void invoice lines leave the stored total alone', () {
      final base = buildBase(
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
      expect(rowFor(base, 'cust-1').invoicePurchases, 100);
      expect(base.invoiceRows.single.totalItems, 1);
    });
  });

  group('Scope', () {
    final receipts = [
      testReceipt(uuid: 'r-d1', cash: 1, departmentUuid: 'd1'),
      testReceipt(uuid: 'r-d2', cash: 10, departmentUuid: 'd2'),
      testReceipt(uuid: 'r-none', cash: 100),
      testReceipt(
        uuid: 'r-other',
        cash: 1000,
        departmentUuid: 'd1',
        staffId: 'staff-b',
      ),
    ];
    final invoices = [
      testInvoice(uuid: 'i-d1', total: 1, departmentUuid: 'd1'),
      testInvoice(uuid: 'i-d2', total: 10, departmentUuid: 'd2'),
      testInvoice(uuid: 'i-none', total: 100),
      testInvoice(
        uuid: 'i-other',
        total: 1000,
        departmentUuid: 'd1',
        staffId: 'staff-b',
      ),
    ];
    final orders = [
      customerOrder(uuid: 'o-d1', total: 1, departmentUuid: 'd1'),
      customerOrder(uuid: 'o-d2', total: 10, departmentUuid: 'd2'),
      customerOrder(uuid: 'o-none', total: 100),
      customerOrder(
        uuid: 'o-other',
        total: 1000,
        departmentUuid: 'd1',
        staffId: 'staff-b',
      ),
    ];

    CustomerReportRow rowWith(CustomerReportAccess access) => rowFor(
      buildBase(
        receipts: receipts,
        invoices: invoices,
        orders: orders,
        access: access,
      ),
      'cust-1',
    );

    void expectAll(CustomerReportRow r, double value) {
      expect(r.revenue, value, reason: 'receipts');
      expect(r.invoicePurchases, value, reason: 'invoices');
      expect(r.orderTotal, value, reason: 'orders');
    }

    test('departments off: everything', () {
      expectAll(rowWith(testAccess()), 1111);
    });

    test('restricted user: the current department only', () {
      expectAll(
        rowWith(
          testAccess(
            departmentsEnabled: true,
            canViewAllDepartments: false,
            currentDepartmentUuid: 'd1',
          ),
        ),
        1001,
      );
    });

    test('restricted user without a department: unassigned only', () {
      expectAll(
        rowWith(
          testAccess(departmentsEnabled: true, canViewAllDepartments: false),
        ),
        100,
      );
    });

    test('view all with a department chosen: that department', () {
      expectAll(
        rowWith(
          testAccess(departmentsEnabled: true, currentDepartmentUuid: 'd2'),
        ),
        10,
      );
    });

    test('view all, no department chosen: everything', () {
      expectAll(rowWith(testAccess(departmentsEnabled: true)), 1111);
    });

    test('without View All Transactions: own records only', () {
      expectAll(rowWith(testAccess(canViewAllTransactions: false)), 111);
    });

    test('each scope matches the receipts rule, report by report', () {
      final accesses = [
        testAccess(),
        testAccess(
          departmentsEnabled: true,
          canViewAllDepartments: false,
          currentDepartmentUuid: 'd1',
        ),
        testAccess(departmentsEnabled: true, canViewAllDepartments: false),
        testAccess(departmentsEnabled: true, currentDepartmentUuid: 'd2'),
        testAccess(canViewAllTransactions: false),
      ];
      for (final a in accesses) {
        expectMatches(
          rowWith(a),
          expectedFor(
            'cust-1',
            receipts: receipts,
            invoices: invoices,
            orders: orders,
            period: allTime,
            access: a,
          ),
        );
      }
    });

    test('invoice payments count from every receipt, as the report', () {
      // The payment is another staff member's, so out of scope, but
      // the invoice report still counts it as paid.
      final base = buildBase(
        receipts: [
          invoicePayment(
            uuid: 'p-1',
            invoiceUuid: 'i-1',
            cash: 30,
            staffId: 'staff-b',
          ),
        ],
        invoices: [testInvoice(uuid: 'i-1', total: 100)],
        access: testAccess(canViewAllTransactions: false),
      );
      final r = rowFor(base, 'cust-1');
      expect(r.revenue, 0);
      expect(r.credit, 70);
    });

    test('invoices and orders of other shops are left out', () {
      final base = buildBase(
        invoices: [
          testInvoice(uuid: 'i-1', total: 1),
          testInvoice(uuid: 'i-2', total: 10, shopId: 2),
        ],
        orders: [
          customerOrder(uuid: 'o-1', total: 1),
          customerOrder(uuid: 'o-2', total: 10, shopId: 2),
        ],
        shopId: 1,
      );
      final r = rowFor(base, 'cust-1');
      expect(r.invoicePurchases, 1);
      expect(r.orderTotal, 1);
    });

    test('ledger: own entries only without View All Transactions', () {
      final base = buildBase(
        ledger: [
          ledgerEntry(uuid: 'l-1'),
          ledgerEntry(uuid: 'l-2', staffId: 'staff-b'),
        ],
        access: testAccess(canViewAllTransactions: false),
      );
      expect(base.ledgerRows.map((r) => r.uuid), ['l-1']);
    });
  });

  group('Period', () {
    const closing = TimeOfDay(hour: 4, minute: 0);
    final receipts = [
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
    ];
    final orders = [
      customerOrder(
        uuid: 'o-before',
        total: 1,
        createdAt: DateTime(2026, 10, 18, 3, 30),
      ),
      customerOrder(
        uuid: 'o-after',
        total: 10,
        createdAt: DateTime(2026, 10, 18, 4, 30),
      ),
    ];
    final base = buildBase(receipts: receipts, orders: orders);
    final day17 = ReceiptsReportPeriod.day(DateTime(2026, 10, 17));

    test('a business day runs to the closing time', () {
      final r = rowFor(base, 'cust-1', period: day17, closingTime: closing);
      expect(r.revenue, 1);
      expect(r.orderTotal, 1);
    });

    test('closing time matches the reports', () {
      expectMatches(
        rowFor(base, 'cust-1', period: day17, closingTime: closing),
        expectedFor(
          'cust-1',
          receipts: receipts,
          invoices: const [],
          orders: orders,
          period: day17,
          closingTime: closing,
        ),
      );
    });

    test('range is inclusive and all time is everything', () {
      final range = ReceiptsReportPeriod.range(
        DateTime(2026, 10, 10),
        DateTime(2026, 10, 18),
      );
      expect(
        rowFor(base, 'cust-1', period: range, closingTime: closing).revenue,
        111,
      );
      expect(rowFor(base, 'cust-1').revenue, 111);
      expect(rowFor(base, 'cust-1').orderTotal, 11);
    });

    test('invoices use the business day of the invoice report', () {
      final base = buildBase(
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
      expect(rowFor(base, 'cust-1', period: day17).invoicePurchases, 1);
      expect(rowFor(base, 'cust-1').invoicePurchases, 11);
    });

    test('initial period: all time with View Date, else today', () {
      expect(testAccess().initialPeriod().isAllTime, isTrue);
      final today = testAccess(
        canPickDate: false,
      ).initialPeriod(now: DateTime(2026, 10, 18, 3, 45), closingTime: closing);
      expect(today.isSingleDay, isTrue);
      expect(today.start, DateTime(2026, 10, 17));
    });
  });

  group('Current balances', () {
    test('account and reward balances ignore the period', () {
      final base = buildBase(
        customers: [testCustomer(balance: 250, cashReward: 15)],
        receipts: [testReceipt(uuid: 'r-1', cash: 10)],
      );
      for (final period in [
        allTime,
        ReceiptsReportPeriod.day(DateTime(2026, 10, 17)),
        ReceiptsReportPeriod.day(DateTime(2025, 1, 1)),
      ]) {
        final r = rowFor(base, 'cust-1', period: period);
        expect(r.accountBalance, 250);
        expect(r.rewardEarnings, 15);
        expect(r.totalBalance, 265);
      }
    });

    test('null balances are 0', () {
      final r = rowFor(buildBase(), 'cust-1');
      expect(r.accountBalance, 0);
      expect(r.rewardEarnings, 0);
      expect(r.totalBalance, 0);
    });
  });

  group('Column gating', () {
    final customers = [testCustomer(balance: 100, cashReward: 7)];
    final ledger = [
      ledgerEntry(uuid: 'acc', isBalance: true),
      ledgerEntry(uuid: 'rew', isBalance: false),
    ];

    test('settings and View Customers Account decide', () {
      final cases = <List<bool>>[
        // account, reward, permission -> showAccount, showReward
        [true, true, true, true, true],
        [true, false, true, true, false],
        [false, true, true, false, true],
        [false, false, true, false, false],
        [true, true, false, false, false],
      ];
      for (final c in cases) {
        final a = testAccess(
          manageCustomerAccount: c[0],
          manageCustomerReward: c[1],
          canViewCustomersAccount: c[2],
        );
        expect(a.showAccount, c[3], reason: '$c');
        expect(a.showReward, c[4], reason: '$c');
        expect(a.showTotalBalance, c[3] || c[4], reason: '$c');
      }
    });

    test('total balance adds the visible parts only', () {
      double total(CustomerReportAccess a) =>
          rowFor(
            buildBase(customers: customers, access: a),
            'cust-1',
          ).totalBalance;
      expect(total(testAccess()), 107);
      expect(total(testAccess(manageCustomerReward: false)), 100);
      expect(total(testAccess(manageCustomerAccount: false)), 7);
      expect(total(testAccess(canViewCustomersAccount: false)), 0);
    });

    test('hidden ledger kinds are not loaded', () {
      List<String> uuids(CustomerReportAccess a) =>
          buildBase(
            ledger: ledger,
            access: a,
          ).ledgerRows.map((r) => r.uuid).toList();
      expect(uuids(testAccess()), ['acc', 'rew']);
      expect(uuids(testAccess(manageCustomerReward: false)), ['acc']);
      expect(uuids(testAccess(manageCustomerAccount: false)), ['rew']);
      expect(uuids(testAccess(canViewCustomersAccount: false)), isEmpty);
    });

    test('has-account-balance filter needs the account column', () {
      final rows = rowsOf(
        buildBase(
          customers: [
            testCustomer(uuid: 'a', balance: 5),
            testCustomer(uuid: 'b'),
          ],
        ),
      );
      final filters = CustomerReportFilters(hasAccountBalance: true);
      List<String> run(CustomerReportAccess a) =>
          CustomerReportQuery.filterAndSort(
            rows: rows,
            filters: filters,
            sortField: CustomerReportSortField.name,
            ascending: true,
            access: a,
          ).map((r) => r.uuid).toList();
      expect(run(testAccess()), ['a']);
      expect(run(testAccess(manageCustomerAccount: false)), ['a', 'b']);
      expect(filters.activeCount(showAccount: true), 1);
      expect(filters.activeCount(showAccount: false), 0);
    });

    test('a hidden column cannot be the sort', () {
      final hidden = testAccess(canViewCustomersAccount: false);
      for (final f in [
        CustomerReportSortField.accountBalance,
        CustomerReportSortField.rewardEarnings,
        CustomerReportSortField.totalBalance,
      ]) {
        expect(
          CustomerReportQuery.visibleSort(f, hidden),
          CustomerReportSortField.name,
        );
        expect(CustomerReportQuery.visibleSort(f, testAccess()), f);
      }
    });
  });

  group('Filters', () {
    final rows = rowsOf(
      buildBase(
        customers: [
          testCustomer(
            uuid: 'a',
            name: 'Amaka',
            phone: '0701',
            address: '1 Broad St',
            city: 'Ikeja',
            state: 'Lagos',
            country: 'Nigeria',
          ),
          testCustomer(
            uuid: 'b',
            name: 'Bayo',
            phone: '0802',
            state: ' lagos ',
            country: 'NIGERIA',
            balance: 50,
          ),
          testCustomer(
            uuid: 'c',
            name: 'Kofi',
            phone: '0903',
            state: 'Accra',
            country: 'Ghana',
          ),
          testCustomer(uuid: 'd', name: 'Dele', phone: '0604'),
        ],
        invoices: [testInvoice(uuid: 'i-1', customerUuid: 'c', total: 30)],
      ),
    );

    List<String> run(CustomerReportFilters f) =>
        CustomerReportQuery.filterAndSort(
          rows: rows,
          filters: f,
          sortField: CustomerReportSortField.name,
          ascending: true,
          access: testAccess(),
        ).map((r) => r.uuid).toList();

    test('search: name, phone, address, city, state, country', () {
      expect(run(CustomerReportFilters(search: 'amak')), ['a']);
      expect(run(CustomerReportFilters(search: '0903')), ['c']);
      expect(run(CustomerReportFilters(search: 'broad')), ['a']);
      expect(run(CustomerReportFilters(search: 'ikeja')), ['a']);
      expect(run(CustomerReportFilters(search: 'ACCRA')), ['c']);
      expect(run(CustomerReportFilters(search: 'ghana')), ['c']);
      expect(run(CustomerReportFilters(search: '  ')).length, 4);
    });

    test('country and state ignore case and spaces', () {
      expect(run(CustomerReportFilters(countryKey: 'nigeria')), ['a', 'b']);
      expect(run(CustomerReportFilters(stateKey: 'lagos')), ['a', 'b']);
      expect(
        run(CustomerReportFilters(countryKey: 'ghana', stateKey: 'lagos')),
        isEmpty,
      );
    });

    test('options: one per place, states of the chosen country', () {
      final countries = CustomerReportOptions.countries(rows);
      expect(countries.map((o) => o.key), ['ghana', 'nigeria']);
      expect(countries.last.label, 'Nigeria');
      expect(CustomerReportOptions.states(rows).map((o) => o.key), [
        'accra',
        'lagos',
      ]);
      expect(
        CustomerReportOptions.states(
          rows,
          countryKey: 'nigeria',
        ).map((o) => o.key),
        ['lagos'],
      );
    });

    test('has credit and has account balance', () {
      expect(run(CustomerReportFilters(hasCredit: true)), ['c']);
      expect(run(CustomerReportFilters(hasAccountBalance: true)), ['b']);
    });

    test('count, copy and Reset All', () {
      final f = CustomerReportFilters(
        search: 'x',
        countryKey: 'nigeria',
        stateKey: 'lagos',
        hasCredit: true,
        hasAccountBalance: true,
      );
      expect(f.activeCount(showAccount: true), 4);
      final copy = f.copy();
      f.clearAll();
      expect(f.hasAnything(showAccount: true), isFalse);
      expect(copy.search, 'x');
      expect(copy.activeCount(showAccount: true), 4);
    });
  });

  group('Sorting', () {
    final rows = rowsOf(
      buildBase(
        customers: [
          testCustomer(uuid: 'a', name: 'Bola', phone: '', balance: 30),
          testCustomer(uuid: 'b', name: 'ada', phone: '0802', balance: 10),
          testCustomer(uuid: 'c', name: 'Chidi', phone: '0801', balance: 10),
        ],
        receipts: [
          testReceipt(uuid: 'r-1', customerUuid: 'a', cash: 5),
          testReceipt(uuid: 'r-2', customerUuid: 'b', cash: 50),
        ],
      ),
    );

    List<String> run(CustomerReportSortField f, bool asc) =>
        CustomerReportQuery.filterAndSort(
          rows: rows,
          filters: CustomerReportFilters(),
          sortField: f,
          ascending: asc,
          access: testAccess(),
        ).map((r) => r.uuid).toList();

    test('name ignores case', () {
      expect(run(CustomerReportSortField.name, true), ['b', 'a', 'c']);
      expect(run(CustomerReportSortField.name, false), ['c', 'a', 'b']);
    });

    test('numbers, ties broken by name', () {
      expect(run(CustomerReportSortField.revenue, false), ['b', 'a', 'c']);
      expect(run(CustomerReportSortField.accountBalance, true), [
        'b',
        'c',
        'a',
      ]);
      expect(run(CustomerReportSortField.accountBalance, false), [
        'a',
        'b',
        'c',
      ]);
    });

    test('missing text sinks in both directions', () {
      expect(run(CustomerReportSortField.phone, true), ['c', 'b', 'a']);
      expect(run(CustomerReportSortField.phone, false), ['b', 'c', 'a']);
      expect(run(CustomerReportSortField.location, true).length, 3);
    });
  });

  group('Paging and totals', () {
    final customers = [
      for (var i = 0; i < 250; i++)
        testCustomer(
          uuid: 'c-$i',
          name: 'Customer ${i.toString().padLeft(3, '0')}',
          balance: 1,
          cashReward: 2,
          country: i.isEven ? 'Nigeria' : 'Ghana',
        ),
    ];
    final receipts = [
      for (var i = 0; i < 250; i++)
        testReceipt(uuid: 'r-$i', customerUuid: 'c-$i', cash: 10),
    ];
    final invoices = [
      for (var i = 0; i < 250; i++)
        testInvoice(uuid: 'i-$i', customerUuid: 'c-$i', total: 4),
    ];
    final rows = rowsOf(
      buildBase(customers: customers, receipts: receipts, invoices: invoices),
    );

    test('100 per page, totals over the full filtered set', () {
      final sorted = CustomerReportQuery.filterAndSort(
        rows: rows,
        filters: CustomerReportFilters(countryKey: 'nigeria'),
        sortField: CustomerReportSortField.name,
        ascending: true,
        access: testAccess(),
      );
      expect(sorted.length, 125);
      final p1 = CustomerReportQuery.paginate(sorted, 1);
      final p2 = CustomerReportQuery.paginate(sorted, 2);
      expect(p1.rows.length, 100);
      expect(p2.rows.length, 25);
      expect(p1.totalPages, 2);
      expect(p2.firstIndex, 101);
      expect(p2.lastIndex, 125);
      for (final p in [p1, p2]) {
        expect(p.totals.count, 125);
        expect(p.totals.revenue, 1250);
        expect(p.totals.receiptPurchases, 1250);
        expect(p.totals.invoicePurchases, 500);
        expect(p.totals.credit, 500);
        expect(p.totals.accountBalance, 125);
        expect(p.totals.rewardEarnings, 250);
        expect(p.totals.totalBalance, 375);
      }
    });

    test('a page past the end is clamped, empty is one page', () {
      final all = CustomerReportQuery.filterAndSort(
        rows: rows,
        filters: CustomerReportFilters(),
        sortField: CustomerReportSortField.name,
        ascending: true,
        access: testAccess(),
      );
      final p = CustomerReportQuery.paginate(all, 9);
      expect(p.page, 3);
      expect(p.rows.length, 50);
      final empty = CustomerReportQuery.paginate(const [], 2);
      expect(empty.page, 1);
      expect(empty.totalPages, 1);
      expect(empty.firstIndex, 0);
      expect(empty.totals.count, 0);
    });
  });

  group('Rows', () {
    test('location joins what is stored', () {
      final r = rowFor(
        buildBase(
          customers: [
            testCustomer(
              address: ' 1 Broad St ',
              city: '',
              state: 'Lagos',
              country: 'Nigeria',
            ),
          ],
        ),
        'cust-1',
      );
      expect(r.locationLabel, '1 Broad St, Lagos, Nigeria');
      expect(rowFor(buildBase(), 'cust-1').locationLabel, isNull);
    });

    test('a customer without a uuid gets a row of zeros', () {
      final rows = rowsOf(
        buildBase(
          customers: [testCustomer(uuid: null)],
          receipts: [testReceipt(uuid: 'r-1', cash: 10)],
        ),
      );
      expect(rows.single.revenue, 0);
      expect(rows.single.uuid, '');
    });
  });

  group('Table screen', () {
    // Money shows as 'N<value>' (fakeCustomerEnv).
    final day17 = ReceiptsReportPeriod.day(DateTime(2026, 10, 17));
    List<TempMainReceipt> twoReceipts() => [
      testReceipt(
        uuid: 'r-17',
        cash: 10,
        createdAt: DateTime(2026, 10, 17, 12),
      ),
      testReceipt(
        uuid: 'r-10',
        cash: 100,
        createdAt: DateTime(2026, 10, 10, 12),
      ),
    ];
    List<TempInvoice> creditInvoice() => [
      testInvoice(uuid: 'i-1', total: 30, createdAt: DateTime(2026, 10, 17, 9)),
    ];
    final twoCustomers = [
      testCustomer(uuid: 'cust-1', name: 'Bola'),
      testCustomer(uuid: 'cust-2', name: 'Chidi'),
    ];

    for (final isDesktop in [true, false]) {
      final width = isDesktop ? 'desktop' : 'mobile';

      final gating = <String, (CustomerReportAccess, List<bool>)>{
        'all on': (testAccess(), [true, true, true]),
        'account off': (
          testAccess(manageCustomerAccount: false),
          [false, true, true],
        ),
        'reward off': (
          testAccess(manageCustomerReward: false),
          [true, false, true],
        ),
        'both off': (
          testAccess(manageCustomerAccount: false, manageCustomerReward: false),
          [false, false, false],
        ),
        'no View Customers Account': (
          testAccess(canViewCustomersAccount: false),
          [false, false, false],
        ),
      };
      for (final g in gating.entries) {
        final (access, shown) = g.value;
        testWidgets('balance columns, ${g.key} ($width)', (tester) async {
          await pumpCustomerTable(
            tester,
            isDesktop: isDesktop,
            env: fakeCustomerEnv(
              customers: [testCustomer(balance: 100, cashReward: 7)],
              access: access,
            ),
          );
          final labels = [
            'Account Balance',
            'Reward Earnings',
            'Total Balance',
          ];
          for (var k = 0; k < labels.length; k++) {
            expect(
              find.text(labels[k]),
              shown[k] ? findsOneWidget : findsNothing,
              reason: '${labels[k]}: $shown',
            );
          }
          // Total balance is the visible parts only.
          final total = (shown[0] ? 100.0 : 0.0) + (shown[1] ? 7.0 : 0.0);
          if (shown[2]) {
            expect(find.text('N$total'), findsWidgets);
          }
          expect(find.text('Revenue'), findsOneWidget);
          expect(find.text('Credit'), findsOneWidget);
        });
      }

      testWidgets('Reset All keeps the period ($width)', (tester) async {
        await pumpCustomerTable(
          tester,
          isDesktop: isDesktop,
          env: fakeCustomerEnv(
            customers: twoCustomers,
            receipts: twoReceipts(),
            invoices: creditInvoice(),
          ),
          filters: CustomerReportFilters(hasCredit: true),
          period: day17,
        );
        final pill = 'Date: ${receiptsPeriodLabel(day17)}';
        expect(find.text(pill), findsOneWidget);
        expect(find.text('Reset All Filters'), findsOneWidget);
        expect(find.text('Has credit'), findsOneWidget);
        expect(find.text('Chidi'), findsNothing);

        await tester.tap(find.text('Reset All Filters'));
        await tester.pumpAndSettle();

        expect(find.text('Reset All Filters'), findsNothing);
        expect(find.text('Has credit'), findsNothing);
        expect(find.text('Chidi'), findsOneWidget);
        expect(find.text(pill), findsOneWidget);
        // Still the 17th only: the receipt of the 10th stays out.
        expect(find.text('N10.0'), findsWidgets);
        expect(find.text('N110.0'), findsNothing);
        expect(
          find.text('All time covers the data loaded on this device.'),
          findsNothing,
        );
      });

      testWidgets('Has credit filter and its chip ($width)', (tester) async {
        await pumpCustomerTable(
          tester,
          isDesktop: isDesktop,
          env: fakeCustomerEnv(
            customers: twoCustomers,
            invoices: creditInvoice(),
          ),
        );
        expect(find.text('Chidi'), findsOneWidget);
        expect(
          find.text('All time covers the data loaded on this device.'),
          findsOneWidget,
        );

        await tester.tap(find.text('Filters'));
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(FilterChip, 'Has credit'));
        await tester.pumpAndSettle();

        expect(find.text('Filters (1)'), findsOneWidget);
        expect(find.text('Bola'), findsOneWidget);
        expect(find.text('Chidi'), findsNothing);
        final chip = find.widgetWithText(InputChip, 'Has credit');
        expect(chip, findsOneWidget);

        await tester.tap(
          find.descendant(of: chip, matching: find.byIcon(Icons.close)),
        );
        await tester.pumpAndSettle();

        expect(find.widgetWithText(InputChip, 'Has credit'), findsNothing);
        expect(find.text('Chidi'), findsOneWidget);
        expect(find.text('Filters'), findsOneWidget);
      });

      testWidgets('totals are the same on every page ($width)', (tester) async {
        final customers = [
          for (var i = 0; i < 150; i++)
            testCustomer(
              uuid: 'c-$i',
              name: 'Customer ${i.toString().padLeft(3, '0')}',
            ),
        ];
        final receipts = [
          for (var i = 0; i < 150; i++)
            testReceipt(uuid: 'r-$i', customerUuid: 'c-$i', cash: 10),
        ];
        await pumpCustomerTable(
          tester,
          isDesktop: isDesktop,
          env: fakeCustomerEnv(customers: customers, receipts: receipts),
        );
        expect(find.text('Showing 1-100 of 150 customers'), findsOneWidget);
        // Receipt purchases and revenue totals.
        expect(find.text('N1500.0'), findsNWidgets(2));

        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();

        expect(find.text('Page 2 of 2'), findsOneWidget);
        expect(find.text('Showing 101-150 of 150 customers'), findsOneWidget);
        expect(find.text('N1500.0'), findsNWidgets(2));
      });

      testWidgets('a row opens the analysis on the period ($width)', (
        tester,
      ) async {
        final opened = <OpenedAnalysis>[];
        await pumpCustomerTable(
          tester,
          isDesktop: isDesktop,
          env: fakeCustomerEnv(
            customers: twoCustomers,
            receipts: twoReceipts(),
            opened: opened,
          ),
          period: day17,
        );
        await tester.tap(find.text('Chidi'));
        await tester.pumpAndSettle();

        expect(opened.length, 1);
        expect(opened.single.customer.uuid, 'cust-2');
        expect(opened.single.period.isAllTime, isFalse);
        expect(opened.single.period.start, day17.start);
        expect(opened.single.period.end, day17.end);
      });

      testWidgets('back from the analysis rebuilds the rows ($width)', (
        tester,
      ) async {
        final receipts = [testReceipt(uuid: 'r-1', cash: 10)];
        await pumpCustomerTable(
          tester,
          isDesktop: isDesktop,
          env: fakeCustomerEnv(
            receipts: receipts,
            onOpen: () => receipts.add(testReceipt(uuid: 'r-2', cash: 15)),
          ),
        );
        expect(find.text('N10.0'), findsWidgets);
        expect(find.text('N25.0'), findsNothing);

        await tester.tap(find.text('Bola'));
        await tester.pumpAndSettle();

        expect(find.text('N25.0'), findsWidgets);
        expect(find.text('N10.0'), findsNothing);
      });

      testWidgets('without View Date the period is today ($width)', (
        tester,
      ) async {
        await pumpCustomerTable(
          tester,
          isDesktop: isDesktop,
          env: fakeCustomerEnv(
            receipts: twoReceipts(),
            access: testAccess(canPickDate: false),
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
    }
  });
}
