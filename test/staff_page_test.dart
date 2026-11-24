import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:stockall/classes/temp_expenses/temp_expenses_class.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/constants/calculations.dart' show formatDateTime;
import 'package:stockall/constants/functions.dart';
import 'package:stockall/pages/customers/customer_details_page/components/customer_sales_section.dart';
import 'package:stockall/pages/employees/employee_page/components/staff_page_env.dart';
import 'package:stockall/pages/employees/employee_page/components/staff_page_shell.dart';
import 'package:stockall/pages/employees/employee_page/components/staff_salary_history_section.dart';
import 'package:stockall/pages/employees/employee_page/employee_page.dart';
import 'package:stockall/pages/employees/employee_page/platforms/employee_page_desktop.dart';
import 'package:stockall/pages/employees/employee_page/platforms/employee_page_mobile.dart';
import 'package:stockall/pages/report/components/export/report_export_backend.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/export/report_roll_builder.dart';
import 'package:stockall/pages/report/staff_report/staff_report_table/class/staff_report_table_logic.dart';
import 'package:stockall/pages/report/staff_report/staff_report_table/components/staff_report_table_view.dart';
import 'package:stockall/providers/expenses_provider.dart';
import 'package:stockall/providers/receipts_provider.dart';
import 'package:stockall/providers/shop_provider.dart';
import 'package:stockall/providers/theme_provider.dart';

import 'item_history_export_fixtures.dart' show testCtx;
import 'purchase_report_fixtures.dart' show uuidN;
import 'report_export_screen_harness.dart';
import 'staff_report_fixtures.dart';

const closing = TimeOfDay(hour: 4, minute: 0);

/// 03:45 on the 18th: still the 17th's business day.
final clock = DateTime(2026, 10, 18, 3, 45);
final day17 = DateTime(2026, 10, 17);

final staff = [
  testUser(name: 'Ada', email: 'ada@example.com'),
  testUser(userId: 'staff-b', name: 'Bayo'),
];

/// Ada today: 7 receipts (N2,101), an invoice (N300), an order (N80),
/// a purchase (N40) and an expense (N25); and older records.
StaffReportEnv reportEnv({
  StaffReportAccess? access,
  StaffEnvLog? log,
  List<TempExpensesClass>? expenses,
  bool longAmounts = false,
}) {
  // Long amounts stress the rows at narrow widths.
  final m = longAmounts ? 123457.0 : 1.0;
  return fakeStaffEnv(
    staff: staff,
    access: access,
    log: log,
    receipts: [
      for (var i = 1; i <= 6; i++)
        testReceipt(
          uuid: 'r-100000000000$i',
          cash: 100.0 * i * m,
          createdAt: DateTime(2026, 10, 17, 10 + i),
        ),
      testReceipt(
        uuid: 'r-1000000000007',
        cash: 1,
        createdAt: DateTime(2026, 10, 18, 3, 30),
      ),
      testReceipt(
        uuid: 'r-1000000000008',
        cash: 5000,
        createdAt: DateTime(2026, 10, 10, 12),
      ),
    ],
    invoices: [
      testInvoice(
        uuid: 'i-2000000000001',
        total: 300 * m,
        createdAt: DateTime(2026, 10, 17, 12),
      ),
    ],
    orders: [
      staffOrder(
        uuid: 'o-3000000000001',
        total: 80 * m,
        createdAt: DateTime(2026, 10, 18, 3, 30),
      ),
    ],
    purchases: [
      purchase(
        uuid: uuidN(1),
        total: 40 * m,
        createdAt: DateTime(2026, 10, 17, 12),
      ),
    ],
    expenses:
        expenses ??
        [
          testExpense(
            uuid: 'e-1',
            amount: 25 * m,
            createdAt: DateTime(2026, 10, 18, 3, 30),
          ),
        ],
  );
}

/// The page's own calls: lists opened, Edit and Delete.
class PageLog {
  final lists = <(StaffRecordsList, String)>[];
  final edits = <(String, bool)>[];
  final deletes = <String>[];
}

/// Allows everything; keeps the specs it was asked to save.
class CaptureBackend implements ReportExportBackend {
  final specs = <ReportExportSpec>[];

  @override
  bool isAllowed(BuildContext context, ReportPrintGate gate) => true;

  @override
  ExportContext exportContext() => testCtx;

  @override
  RollPaper? savedPaper() => null;

  @override
  void logError(String action, Object error, StackTrace stack) {}

  @override
  Future<void> printRoll(
    BuildContext context,
    ReportExportSpec spec,
    ExportContext ctx, {
    required RollPaper paper,
    required List<String?> groupings,
    required VoidCallback beforeUi,
  }) async => specs.add(spec);

  @override
  Future<void> printA4(
    BuildContext context,
    ReportExportSpec spec,
    ExportContext ctx, {
    required VoidCallback beforeUi,
  }) async => specs.add(spec);

  @override
  Future<ReportSaveResult> downloadPdf(
    BuildContext context,
    ReportExportSpec spec,
    ExportContext ctx, {
    required VoidCallback beforeUi,
  }) async {
    specs.add(spec);
    return const ReportSaveResult(fileName: 'x.pdf', showSaved: false);
  }

  @override
  Future<ReportSaveResult> exportExcel(
    BuildContext context,
    ReportExportSpec spec,
    ExportContext ctx, {
    String? splitId,
    required VoidCallback beforeUi,
  }) async {
    specs.add(spec);
    return const ReportSaveResult(fileName: 'x.xlsx', showSaved: false);
  }
}

final allActions = {
  Authorizations().employeePage,
  Authorizations().updateEmployee,
  Authorizations().deleteEmployee,
};

StaffPageEnv pageEnv({
  StaffReportEnv? report,
  Set<String>? can,
  PageLog? log,
  ReportExportBackend? backend,
}) {
  TempUserClass? find(String id) {
    for (final u in staff) {
      if (u.userId == id) return u;
    }
    return null;
  }

  final allowed = can ?? allActions;
  return StaffPageEnv(
    report: report ?? reportEnv(),
    user: find,
    can: allowed.contains,
    departmentsEnabled: () => false,
    departmentNames: (_) => const [],
    currency: (_) => '₦',
    openList: (context, list, staffId) async {
      log?.lists.add((list, staffId));
    },
    edit: (context, user, {required isDesktop, required onReturn}) {
      log?.edits.add((user.userId!, isDesktop));
    },
    delete: (context, staffId, {required onState}) async {
      log?.deletes.add(staffId);
    },
    exportBackend: backend ?? CaptureBackend(),
    clock: () => clock,
    closingTime: closing,
  );
}

Future<void> pumpPage(
  WidgetTester tester, {
  required bool desktop,
  required StaffPageEnv env,
  double? width,
}) async {
  // Tall enough that every section is built and on screen.
  tester.view.physicalSize = Size(
    width ?? (desktop ? 1800 : 500),
    desktop ? 2600 : 4200,
  );
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
        ChangeNotifierProvider<ShopProvider>.value(value: ShopProvider()),
        ChangeNotifierProvider<ReceiptsProvider>.value(
          value: ReceiptsProvider(),
        ),
      ],
      child: MaterialApp(
        // A new State per pump: the env is read once, in initState.
        home: EmployeePage(key: UniqueKey(), employeeId: 'staff-a', env: env),
      ),
    ),
  );
  await settleReportScreen(tester);
}

/// A few frames: empty states animate forever, so no pumpAndSettle.
Future<void> frames(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Finder inKey(String key, Finder f) =>
    find.descendant(of: find.byKey(ValueKey(key)), matching: f);

Future<void> tapKey(WidgetTester tester, String key) async {
  final f = find.byKey(ValueKey(key));
  await tester.ensureVisible(f);
  await tester.pump();
  await tester.tap(f);
  await frames(tester);
}

void main() {
  setUpAll(setUpScreenEnvironment);

  // The narrowest widths of each layout, with long amounts: a small
  // phone, and the desktop breakpoint (tabletScreenSmall). Any
  // overflow, in the staff widgets or the reused customer rows, fails.
  for (final (desktop, width) in [(false, 360.0), (true, 950.0)]) {
    testWidgets('nothing overflows at $width wide', (tester) async {
      await pumpPage(
        tester,
        desktop: desktop,
        env: pageEnv(report: reportEnv(longAmounts: true)),
        width: width,
      );
      expect(tester.takeException(), isNull);
      expect(
        find.byType(desktop ? EmployeePageDesktop : EmployeePageMobile),
        findsOneWidget,
      );
      for (final id in [
        'sales',
        'invoices',
        'orders',
        'purchases',
        'expenses',
      ]) {
        expect(find.byKey(ValueKey('staff-section-$id')), findsOneWidget);
      }
      expect(
        inKey('staff-section-sales', find.byType(CustomerSalesList)),
        findsNWidgets(5),
      );
    });
  }

  for (final desktop in [true, false]) {
    final width = desktop ? 'desktop' : 'mobile';

    group('Staff page ($width)', () {
      testWidgets('the layout and title', (tester) async {
        await pumpPage(tester, desktop: desktop, env: pageEnv());
        expect(find.text('Staff Details'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('staff-details-card')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('staff-summary-card')),
          findsOneWidget,
        );
        final details = tester.getTopLeft(
          find.byKey(const ValueKey('staff-details-card')),
        );
        final summary = tester.getTopLeft(
          find.byKey(const ValueKey('staff-summary-card')),
        );
        final sales = tester.getTopLeft(
          find.byKey(const ValueKey('staff-section-sales')),
        );
        final invoices = tester.getTopLeft(
          find.byKey(const ValueKey('staff-section-invoices')),
        );
        if (desktop) {
          // Details beside the summary; sections two per row.
          expect(summary.dy, details.dy);
          expect(summary.dx, greaterThan(details.dx));
          expect(invoices.dy, sales.dy);
          expect(invoices.dx, greaterThan(sales.dx));
        } else {
          // Summary, details, then the sections, stacked.
          expect(summary.dy, lessThan(details.dy));
          expect(details.dy, lessThan(sales.dy));
          expect(sales.dy, lessThan(invoices.dy));
          expect(invoices.dx, sales.dx);
        }
        // Name, role, phone, email; date added is null-safe.
        final card = 'staff-details-card';
        expect(inKey(card, find.text('Ada')), findsOneWidget);
        expect(inKey(card, find.text('Cashier')), findsOneWidget);
        expect(inKey(card, find.text('0801')), findsOneWidget);
        expect(inKey(card, find.text('ada@example.com')), findsOneWidget);
        expect(inKey(card, find.text('Not Set')), findsOneWidget);
      });

      testWidgets('the card shows today\'s figures', (tester) async {
        await pumpPage(tester, desktop: desktop, env: pageEnv());
        const card = 'staff-summary-card';
        expect(inKey(card, find.text('TODAY\'S ACTIVITY')), findsOneWidget);
        // The business day: 03:45 on the 18th is still the 17th.
        expect(
          tester
              .widget<Text>(find.byKey(const ValueKey('staff-summary-date')))
              .data,
          formatDateTime(day17),
        );
        expect(
          inKey('staff-figure-sales', find.text('N2101.0')),
          findsOneWidget,
        );
        expect(
          inKey('staff-figure-sales', find.text('7 receipts')),
          findsOneWidget,
        );
        expect(
          inKey('staff-figure-invoices', find.text('N300.0')),
          findsOneWidget,
        );
        expect(
          inKey('staff-figure-invoices', find.text('1 invoice')),
          findsOneWidget,
        );
        expect(
          inKey('staff-figure-orders', find.text('N80.0')),
          findsOneWidget,
        );
        expect(
          inKey('staff-figure-purchases', find.text('N40.0')),
          findsOneWidget,
        );
        expect(
          inKey('staff-figure-expenses', find.text('N25.0')),
          findsOneWidget,
        );
        expect(
          inKey('staff-figure-expenses', find.text('1 expense')),
          findsOneWidget,
        );
      });

      testWidgets('orders, purchases and expenses follow their gates', (
        tester,
      ) async {
        await pumpPage(
          tester,
          desktop: desktop,
          env: pageEnv(
            report: reportEnv(
              access: staffAccess(
                showOrders: false,
                showPurchases: false,
                showExpenses: false,
              ),
            ),
          ),
        );
        for (final id in ['orders', 'purchases', 'expenses']) {
          expect(find.byKey(ValueKey('staff-figure-$id')), findsNothing);
          expect(find.byKey(ValueKey('staff-section-$id')), findsNothing);
        }
        expect(
          find.byKey(const ValueKey('staff-figure-sales')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('staff-figure-invoices')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('staff-section-invoices')),
          findsOneWidget,
        );

        await tapKey(tester, 'staff-records-menu');
        expect(
          find.byKey(const ValueKey('staff-records-sales')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('staff-records-invoices')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('staff-records-orders')),
          findsNothing,
        );
        expect(
          find.byKey(const ValueKey('staff-records-purchases')),
          findsNothing,
        );
        expect(
          find.byKey(const ValueKey('staff-records-expenses')),
          findsNothing,
        );
      });

      testWidgets('sections show the latest 5, and their empty state', (
        tester,
      ) async {
        await pumpPage(
          tester,
          desktop: desktop,
          env: pageEnv(report: reportEnv(expenses: const [])),
        );
        expect(
          inKey('staff-section-sales', find.byType(CustomerSalesList)),
          findsNWidgets(5),
        );
        expect(
          inKey('staff-section-count-sales', find.text('7')),
          findsOneWidget,
        );
        expect(
          inKey('staff-section-sales', find.text('TODAY\'S SALES')),
          findsOneWidget,
        );
        expect(
          find.byKey(ValueKey('staff-purchase-${uuidN(1)}')),
          findsOneWidget,
        );
        expect(
          inKey('staff-section-count-expenses', find.text('0')),
          findsOneWidget,
        );
        expect(
          inKey('staff-section-expenses', find.text('No expenses today')),
          findsOneWidget,
        );
      });

      testWidgets('the Records menu opens each list for the staff', (
        tester,
      ) async {
        final log = PageLog();
        final reportLog = StaffEnvLog();
        await pumpPage(
          tester,
          desktop: desktop,
          env: pageEnv(report: reportEnv(log: reportLog), log: log),
        );
        for (final list in StaffRecordsList.values) {
          await tapKey(tester, 'staff-records-menu');
          await tapKey(tester, 'staff-records-${list.name}');
        }
        // Expenses has no list that takes a staff: the Staff Expenses
        // table, on All time.
        expect(log.lists, [
          (StaffRecordsList.sales, 'staff-a'),
          (StaffRecordsList.invoices, 'staff-a'),
          (StaffRecordsList.orders, 'staff-a'),
          (StaffRecordsList.purchases, 'staff-a'),
        ]);
        expect(reportLog.calls, ['expensesTable']);
        expect(reportLog.expensesStaffKey, 'staff-a');
        expect(reportLog.expensesPeriod!.isAllTime, isTrue);
      });

      testWidgets('View All opens the report table for today', (tester) async {
        final log = StaffEnvLog();
        await pumpPage(
          tester,
          desktop: desktop,
          env: pageEnv(report: reportEnv(log: log)),
        );
        for (final id in [
          'sales',
          'invoices',
          'orders',
          'purchases',
          'expenses',
        ]) {
          await tapKey(tester, 'staff-view-all-$id');
        }
        expect(log.calls, [
          'receiptsTable',
          'invoiceTable',
          'orderTable',
          'purchaseTable',
          'expensesTable',
        ]);
        expect(log.receiptsFilters!.staffKey, 'staff-a');
        expect(log.receiptsPeriod!.start, day17);
        expect(log.receiptsPeriod!.end, day17);
        expect(log.invoiceFilters!.staffId, 'staff-a');
        expect(log.invoiceFilters!.dateRange!.start, day17);
        expect(log.invoiceFilters!.dateRange!.end, day17);
        expect(log.orderFilters!.staffKey, 'staff-a');
        expect(log.orderPeriod!.start, day17);
        expect(log.purchaseFilters!.staffKey, 'staff-a');
        expect(log.purchasePeriod!.start, day17);
        expect(log.expensesStaffKey, 'staff-a');
        expect(log.expensesPeriod!.start, day17);
        expect(log.expensesPeriod!.end, day17);
      });

      testWidgets('another staff without View All Transactions', (
        tester,
      ) async {
        await pumpPage(
          tester,
          desktop: desktop,
          env: pageEnv(
            report: reportEnv(
              access: staffAccess(
                canViewAllTransactions: false,
                currentUserId: 'staff-b',
              ),
            ),
          ),
        );
        expect(
          find.byKey(const ValueKey('staff-details-card')),
          findsOneWidget,
        );
        expect(find.text(staffOwnRecordsNote), findsOneWidget);
        expect(find.byKey(const ValueKey('staff-summary-card')), findsNothing);
        expect(find.byKey(const ValueKey('staff-records-menu')), findsNothing);
        for (final id in [
          'sales',
          'invoices',
          'orders',
          'purchases',
          'expenses',
        ]) {
          expect(find.byKey(ValueKey('staff-section-$id')), findsNothing);
        }
        // Edit and Delete stay: they have their own permissions.
        expect(find.byKey(const ValueKey('staff-edit')), findsOneWidget);
        expect(find.byKey(const ValueKey('staff-delete')), findsOneWidget);
      });

      testWidgets('the staff\'s own page without View All Transactions', (
        tester,
      ) async {
        await pumpPage(
          tester,
          desktop: desktop,
          env: pageEnv(
            report: reportEnv(
              access: staffAccess(
                canViewAllTransactions: false,
                currentUserId: 'staff-a',
              ),
            ),
          ),
        );
        expect(find.text(staffOwnRecordsNote), findsNothing);
        expect(
          inKey('staff-figure-sales', find.text('N2101.0')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('staff-records-menu')),
          findsOneWidget,
        );
      });

      testWidgets('Edit and Delete follow their permissions', (tester) async {
        final log = PageLog();
        await pumpPage(
          tester,
          desktop: desktop,
          env: pageEnv(can: {}, log: log),
        );
        expect(find.byKey(const ValueKey('staff-edit')), findsNothing);
        expect(find.byKey(const ValueKey('staff-delete')), findsNothing);

        await pumpPage(
          tester,
          desktop: desktop,
          env: pageEnv(
            can: {
              Authorizations().employeePage,
              Authorizations().updateEmployee,
            },
            log: log,
          ),
        );
        expect(find.byKey(const ValueKey('staff-edit')), findsOneWidget);
        expect(find.byKey(const ValueKey('staff-delete')), findsNothing);

        await pumpPage(
          tester,
          desktop: desktop,
          env: pageEnv(
            can: {
              Authorizations().employeePage,
              Authorizations().deleteEmployee,
            },
            log: log,
          ),
        );
        expect(find.byKey(const ValueKey('staff-edit')), findsNothing);
        expect(find.byKey(const ValueKey('staff-delete')), findsOneWidget);

        await pumpPage(tester, desktop: desktop, env: pageEnv(log: log));
        await tapKey(tester, 'staff-edit');
        await tapKey(tester, 'staff-delete');
        expect(log.edits, [('staff-a', desktop)]);
        expect(log.deletes, ['staff-a']);
      });

      testWidgets('own page without Employee Page: records, no Edit or Delete', (
        tester,
      ) async {
        // Update / Delete Employee alone are not enough.
        await pumpPage(
          tester,
          desktop: desktop,
          env: pageEnv(
            can: {
              Authorizations().updateEmployee,
              Authorizations().deleteEmployee,
            },
          ),
        );
        expect(
          find.byKey(const ValueKey('staff-details-card')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('staff-summary-card')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('staff-records-menu')),
          findsOneWidget,
        );
        expect(find.byKey(const ValueKey('staff-edit')), findsNothing);
        expect(find.byKey(const ValueKey('staff-delete')), findsNothing);
      });

      testWidgets('another staff\'s page without Employee Page closes', (
        tester,
      ) async {
        await pumpPushedPage(
          tester,
          desktop: desktop,
          env: pageEnv(
            can: {
              Authorizations().updateEmployee,
              Authorizations().deleteEmployee,
            },
            report: reportEnv(access: staffAccess(currentUserId: 'staff-b')),
          ),
        );
        expect(find.byType(EmployeePage), findsNothing);
        expect(
          find.byKey(const ValueKey('staff-details-card')),
          findsNothing,
        );
        expect(find.text('home'), findsOneWidget);
      });

      testWidgets('another staff\'s page with Employee Page stays open', (
        tester,
      ) async {
        await pumpPushedPage(
          tester,
          desktop: desktop,
          env: pageEnv(
            report: reportEnv(access: staffAccess(currentUserId: 'staff-b')),
          ),
        );
        expect(find.byType(EmployeePage), findsOneWidget);
        expect(
          find.byKey(const ValueKey('staff-details-card')),
          findsOneWidget,
        );
      });

      testWidgets('Print Report exports the staff\'s day', (tester) async {
        final backend = CaptureBackend();
        await pumpPage(
          tester,
          desktop: desktop,
          env: pageEnv(backend: backend),
        );
        await tester.tap(find.text('Print Report'));
        await frames(tester);
        expect(find.text('Print'), findsOneWidget);
        expect(find.text('Print A4'), findsOneWidget);
        await tester.tap(find.text('Download PDF'));
        await frames(tester);

        final spec = backend.specs.single;
        expect(spec.reportName, 'Staff Analysis');
        expect(
          {for (final f in spec.filters) f.label: f.value},
          {'Staff': 'Ada'},
        );
        expect(spec.period!.start, day17);
        expect(spec.period!.end, day17);
        final receipts = spec.sections
            .whereType<ExportTableSection>()
            .firstWhere((s) => s.title.startsWith('Receipts'));
        // The whole day, not the screen's 5.
        expect(receipts.rows, hasLength(7));
      });
    });
  }

  group('Salary History rows', () {
    setUp(() {
      ExpensesProvider().expensesMain = [
        TempExpensesClass(
          uuid: 'sal-1',
          name: 'Salary',
          amount: 500,
          creator: 'Owner',
          shopId: 1,
          createdDate: DateTime(2026, 10, 1, 12),
          userId: 'owner',
          departmentName: null,
          departmentUuid: null,
          expenseType: ExpenseType.staffSalary,
          staffUuid: 'staff-a',
        ),
      ];
    });
    tearDown(() => ExpensesProvider().expensesMain = []);

    for (final canOpen in [true, false]) {
      testWidgets(canOpen ? 'open the expense' : 'are read-only', (
        tester,
      ) async {
        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<ThemeProvider>(
                create: (_) => ThemeProvider(),
              ),
              ChangeNotifierProvider<ShopProvider>.value(value: ShopProvider()),
              ChangeNotifierProvider<ExpensesProvider>.value(
                value: ExpensesProvider(),
              ),
            ],
            child: MaterialApp(
              home: Scaffold(
                body: SingleChildScrollView(
                  child: StaffSalaryHistorySection(
                    staffUuid: 'staff-a',
                    canOpen: canOpen,
                  ),
                ),
              ),
            ),
          ),
        );
        await frames(tester);
        final row = tester.widget<InkWell>(
          find.byKey(const ValueKey('staff-salary-row-0')),
        );
        expect(row.onTap != null, canOpen);
      });
    }
  });
}

/// The page pushed over a 'home' route, so closing it can be seen.
Future<void> pumpPushedPage(
  WidgetTester tester, {
  required bool desktop,
  required StaffPageEnv env,
}) async {
  tester.view.physicalSize = Size(desktop ? 1800 : 500, desktop ? 2600 : 4200);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final nav = GlobalKey<NavigatorState>();
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
        ChangeNotifierProvider<ShopProvider>.value(value: ShopProvider()),
        ChangeNotifierProvider<ReceiptsProvider>.value(
          value: ReceiptsProvider(),
        ),
      ],
      child: MaterialApp(
        navigatorKey: nav,
        home: const Scaffold(body: Text('home')),
      ),
    ),
  );
  nav.currentState!.push(
    MaterialPageRoute(
      builder: (_) => EmployeePage(employeeId: 'staff-a', env: env),
    ),
  );
  await settleReportScreen(tester);
  await frames(tester);
}
