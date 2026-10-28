import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/temp_expenses/temp_expenses_class.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/components/receipts_report_filter_widgets.dart';
import 'package:stockall/pages/report/staff_report/staff_expenses/class/staff_expenses_logic.dart';
import 'package:stockall/pages/report/staff_report/staff_report_table/class/staff_report_table_logic.dart';
import 'package:stockall/pages/report/staff_report/staff_report_table/components/staff_report_table_view.dart';

import 'staff_report_fixtures.dart';

DateTime day(int d, [int hour = 12]) => DateTime(2026, 10, d, hour);

final sampleExpenses = [
  testExpense(
    uuid: 'e-fuel',
    name: 'Fuel',
    description: 'Generator diesel',
    quantity: 20,
    unit: 'litres',
    amount: 300,
    departmentUuid: 'd1',
    departmentName: 'Bar',
    createdAt: day(17),
  ),
  testExpense(
    uuid: 'e-rent',
    name: 'Rent',
    amount: 1000,
    departmentUuid: 'd2',
    departmentName: 'Kitchen',
    createdAt: day(18),
  ),
  testExpense(
    uuid: 'e-snack',
    name: 'snacks',
    description: 'Staff lunch',
    amount: 50,
    createdAt: day(16),
  ),
  testExpense(uuid: 'e-old', name: 'Old', amount: 5, undated: true),
  testExpense(
    uuid: 'e-b',
    name: 'Fuel',
    amount: 7,
    userId: 'staff-b',
    createdAt: day(17),
  ),
];

StaffReportBase expensesBase({StaffReportAccess? access}) => buildStaffBase(
  staff: [testUser(), testUser(userId: 'staff-b', name: 'Bayo')],
  expenses: sampleExpenses,
  access: access,
);

List<StaffExpenseRow> table({
  StaffReportBase? base,
  String staffKey = 'staff-a',
  ReceiptsReportPeriod period = const ReceiptsReportPeriod.allTime(),
  StaffExpensesFilters? filters,
  StaffExpensesSortField sortField = StaffExpensesSortField.createdAt,
  bool ascending = false,
  TimeOfDay? closingTime,
}) => StaffExpensesTable.filterAndSort(
  base: base ?? expensesBase(),
  staffKey: staffKey,
  period: period,
  filters: filters ?? StaffExpensesFilters(),
  sortField: sortField,
  ascending: ascending,
  closingTime: closingTime,
);

List<String> uuids(Iterable<StaffExpenseRow> rows) =>
    rows.map((r) => r.uuid).toList();

void main() {
  group('Totals match the staff row', () {
    final periods = <String, ReceiptsReportPeriod>{
      'all time': allTime,
      'one day': ReceiptsReportPeriod.day(DateTime(2026, 10, 17)),
      'a range': ReceiptsReportPeriod.range(
        DateTime(2026, 10, 16),
        DateTime(2026, 10, 17),
      ),
      'an empty day': ReceiptsReportPeriod.day(DateTime(2026, 9, 1)),
    };
    for (final p in periods.entries) {
      test(p.key, () {
        final base = expensesBase();
        for (final key in ['staff-a', 'staff-b']) {
          final page = StaffExpensesTable.page(
            base: base,
            staffKey: key,
            period: p.value,
            filters: StaffExpensesFilters(),
          );
          final row = staffRowFor(base, key, period: p.value);
          expect(page.totals.amount, row.expenseTotal, reason: key);
          expect(page.totals.count, row.expenseCount, reason: key);
        }
      });
    }

    test('all time, worked out by hand', () {
      final page = StaffExpensesTable.page(
        base: expensesBase(),
        staffKey: 'staff-a',
        period: allTime,
        filters: StaffExpensesFilters(),
      );
      expect(page.totals.count, 4);
      expect(page.totals.amount, 1355);
    });
  });

  group('Rows', () {
    test("only the staff's expenses, newest first, undated last", () {
      expect(uuids(table()), ['e-rent', 'e-fuel', 'e-snack', 'e-old']);
      expect(uuids(table(staffKey: 'staff-b')), ['e-b']);
    });

    test('row values', () {
      final r = table().firstWhere((r) => r.uuid == 'e-fuel');
      expect(r.title, 'Fuel');
      expect(r.description, 'Generator diesel');
      expect(r.quantity, 20);
      expect(r.unit, 'litres');
      expect(r.amount, 300);
      expect(r.departmentName, 'Bar');
      expect(r.staffName, 'Ada');
      expect(r.createdAt, day(17));
    });

    test('blank text reads as missing', () {
      final r = StaffExpenseRow(
        testExpense(name: '  ', description: ' ', unit: '', creator: ' '),
      );
      expect(r.title, 'Not Set');
      expect(r.description, isNull);
      expect(r.unit, isNull);
      expect(r.staffName, isNull);
    });
  });

  group('Period', () {
    const closing = TimeOfDay(hour: 4, minute: 0);

    test('one day, and undated expenses only in all time', () {
      expect(
        uuids(table(period: ReceiptsReportPeriod.day(DateTime(2026, 10, 17)))),
        ['e-fuel'],
      );
      expect(table().length, 4);
    });

    test('a business day runs to the closing time', () {
      final base = buildStaffBase(
        expenses: [
          testExpense(uuid: 'before', createdAt: DateTime(2026, 10, 18, 3, 30)),
          testExpense(uuid: 'after', createdAt: DateTime(2026, 10, 18, 4, 30)),
        ],
      );
      expect(
        uuids(
          table(
            base: base,
            period: ReceiptsReportPeriod.day(DateTime(2026, 10, 17)),
            closingTime: closing,
          ),
        ),
        ['before'],
      );
    });
  });

  group('Filters', () {
    test('search: title, description, unit', () {
      expect(uuids(table(filters: StaffExpensesFilters(search: 'fuel'))), [
        'e-fuel',
      ]);
      expect(uuids(table(filters: StaffExpensesFilters(search: 'LUNCH'))), [
        'e-snack',
      ]);
      expect(uuids(table(filters: StaffExpensesFilters(search: 'litre'))), [
        'e-fuel',
      ]);
    });

    test('search: the department only while departments are on', () {
      final f = StaffExpensesFilters(search: 'kitchen');
      expect(table(filters: f), isEmpty);
      expect(
        uuids(
          table(
            base: expensesBase(access: staffAccess(departmentsEnabled: true)),
            filters: f,
          ),
        ),
        ['e-rent'],
      );
    });

    test('amount range, inclusive', () {
      expect(
        uuids(
          table(filters: StaffExpensesFilters(amountMin: 50, amountMax: 300)),
        ),
        ['e-fuel', 'e-snack'],
      );
      expect(uuids(table(filters: StaffExpensesFilters(amountMin: 301))), [
        'e-rent',
      ]);
    });

    test('an invalid range is reported and not applied', () {
      final f = StaffExpensesFilters(amountMin: 500, amountMax: 10);
      expect(f.amountRangeError, 'Minimum cannot be more than maximum');
      expect(table(filters: f).length, 4);
      expect(StaffExpensesFilters(amountMin: 1).amountRangeError, isNull);
    });

    test('copy, count, clear', () {
      final f = StaffExpensesFilters(search: 'x', amountMax: 10);
      final c = f.copy()..clearAll();
      expect(f.activeCount, 1);
      expect(f.hasAnything, isTrue);
      expect(c.hasAnything, isFalse);
      expect(c.activeCount, 0);
      expect(f.amountMax, 10);
      expect(StaffExpensesFilters(search: ' ').hasAnything, isFalse);
    });

    test('totals follow the filters', () {
      final page = StaffExpensesTable.page(
        base: expensesBase(),
        staffKey: 'staff-a',
        period: allTime,
        filters: StaffExpensesFilters(amountMax: 300),
      );
      expect(page.totals.count, 3);
      expect(page.totals.amount, 355);
    });
  });

  group('Sorting', () {
    test('amount, both ways', () {
      final asc = table(
        sortField: StaffExpensesSortField.amount,
        ascending: true,
      );
      expect(uuids(asc), ['e-old', 'e-snack', 'e-fuel', 'e-rent']);
      final desc = table(sortField: StaffExpensesSortField.amount);
      expect(uuids(desc), uuids(asc).reversed.toList());
    });

    test('title ignores case', () {
      expect(
        uuids(table(sortField: StaffExpensesSortField.title, ascending: true)),
        ['e-fuel', 'e-old', 'e-rent', 'e-snack'],
      );
    });

    test('missing values sink to the bottom, both ways', () {
      for (final asc in [true, false]) {
        expect(
          table(
            sortField: StaffExpensesSortField.createdAt,
            ascending: asc,
          ).last.uuid,
          'e-old',
        );
        final byQuantity = table(
          sortField: StaffExpensesSortField.quantity,
          ascending: asc,
        );
        expect(byQuantity.first.uuid, 'e-fuel');
      }
    });

    test('every column sorts; ties are newest first', () {
      for (final f in StaffExpensesSortField.values) {
        expect(table(sortField: f).length, 4);
      }
      // No department: e-snack and e-old tie, so newest first.
      final byDept = table(
        sortField: StaffExpensesSortField.department,
        ascending: true,
      );
      expect(uuids(byDept), ['e-fuel', 'e-rent', 'e-snack', 'e-old']);
    });
  });

  group('Paging', () {
    final base = buildStaffBase(
      expenses: [
        for (var i = 0; i < 250; i++)
          testExpense(
            uuid: 'e-${i.toString().padLeft(3, '0')}',
            amount: 2,
            createdAt: DateTime(2026, 1, 1).add(Duration(hours: i)),
          ),
      ],
    );

    test('pages of 100, totals over every page', () {
      final page = StaffExpensesTable.page(
        base: base,
        staffKey: 'staff-a',
        period: allTime,
        filters: StaffExpensesFilters(),
        page: 3,
      );
      expect(page.page, 3);
      expect(page.totalPages, 3);
      expect(page.rows.length, 50);
      expect(page.firstIndex, 201);
      expect(page.lastIndex, 250);
      expect(page.rows.first.uuid, 'e-049');
      expect(page.totals.count, 250);
      expect(page.totals.amount, 500);
    });

    test('clamped, and an empty table', () {
      expect(
        StaffExpensesTable.page(
          base: base,
          staffKey: 'staff-a',
          period: allTime,
          filters: StaffExpensesFilters(),
          page: 99,
        ).page,
        3,
      );
      final empty = StaffExpensesTable.page(
        base: base,
        staffKey: 'nobody',
        period: allTime,
        filters: StaffExpensesFilters(),
        page: 2,
      );
      expect(empty.page, 1);
      expect(empty.totalPages, 1);
      expect(empty.rows, isEmpty);
      expect(empty.firstIndex, 0);
      expect(empty.lastIndex, 0);
      expect(empty.totals.amount, 0);
    });
  });

  group('Scope', () {
    test('restricted to a department', () {
      final rows = table(
        base: expensesBase(
          access: staffAccess(
            departmentsEnabled: true,
            canViewAllDepartments: false,
            currentDepartmentUuid: 'd1',
          ),
        ),
      );
      expect(uuids(rows), ['e-fuel']);
    });

    test("without View All Transactions: no one else's expenses", () {
      final base = expensesBase(
        access: staffAccess(canViewAllTransactions: false),
      );
      expect(table(base: base, staffKey: 'staff-b'), isEmpty);
      expect(table(base: base).length, 4);
    });

    test('expenses hidden: an empty table', () {
      final base = expensesBase(access: staffAccess(showExpenses: false));
      expect(table(base: base), isEmpty);
    });

    test('expenses without a staff are in no table', () {
      final base = buildStaffBase(
        expenses: [
          testExpense(uuid: 'e-null', userId: null),
          testExpense(uuid: 'e-blank', userId: ' '),
        ],
      );
      expect(base.expenseRows, isEmpty);
    });
  });

  group('Expenses screen', () {
    // Money shows as 'N<value>' (fakeStaffEnv). staff-a's expenses:
    // Rent 1000 (18th), Fuel 300 (17th), snacks 50 (16th), Old 5
    // (undated); staff-b's Fuel 7 (17th).
    final day17 = ReceiptsReportPeriod.day(DateTime(2026, 10, 17));
    List<TempExpensesClass> expenses() => [...sampleExpenses];

    StaffReportEnv env({
      List<TempExpensesClass>? list,
      StaffReportAccess? access,
      StaffEnvLog? log,
      VoidCallback? onOpen,
    }) => fakeStaffEnv(
      staff: [testUser(), testUser(userId: 'staff-b', name: 'Bayo')],
      expenses: list ?? expenses(),
      access: access,
      log: log,
      onOpen: onOpen,
    );

    for (final isDesktop in [true, false]) {
      final width = isDesktop ? 'desktop' : 'mobile';

      double y(WidgetTester tester, String text) =>
          tester.getTopLeft(find.text(text)).dy;

      testWidgets("only the staff's expenses in the period ($width)", (
        tester,
      ) async {
        await pumpStaffExpenses(
          tester,
          isDesktop: isDesktop,
          env: env(),
          period: day17,
        );
        expect(find.text('Ada: Expenses'), findsOneWidget);
        expect(find.text('Fuel'), findsOneWidget);
        expect(find.text('Rent'), findsNothing);
        expect(find.text('snacks'), findsNothing);
        expect(find.text('Old'), findsNothing);
        // staff-b's fuel on the same day.
        expect(find.text('N7.0'), findsNothing);
        expect(find.text('1 expense'), findsOneWidget);
        expect(find.text('Showing 1-1 of 1 expenses'), findsOneWidget);
      });

      final periods = <String, ReceiptsReportPeriod>{
        'all time': allTime,
        'a range': ReceiptsReportPeriod.range(
          DateTime(2026, 10, 16),
          DateTime(2026, 10, 17),
        ),
      };
      for (final p in periods.entries) {
        testWidgets('totals equal the expenses KPI, ${p.key} ($width)', (
          tester,
        ) async {
          await pumpStaffExpenses(
            tester,
            isDesktop: isDesktop,
            env: env(),
            period: p.value,
          );
          // The analysis KPI shows the staff's row values.
          final row = staffRowFor(expensesBase(), 'staff-a', period: p.value);
          final n = row.expenseCount;
          expect(find.text('N${row.expenseTotal}'), findsOneWidget);
          expect(
            find.text('$n expense${n == 1 ? '' : 's'}'),
            findsOneWidget,
          );
        });
      }

      testWidgets('search: name and description ($width)', (tester) async {
        await pumpStaffExpenses(tester, isDesktop: isDesktop, env: env());
        await tester.enterText(find.byType(TextField).first, 'lunch');
        await tester.pumpAndSettle();
        expect(find.text('snacks'), findsOneWidget);
        expect(find.text('Fuel'), findsNothing);

        await tester.enterText(find.byType(TextField).first, 'rent');
        await tester.pumpAndSettle();
        expect(find.text('Rent'), findsOneWidget);
        expect(find.text('snacks'), findsNothing);
      });

      testWidgets('amount range filter and its chip ($width)', (tester) async {
        await pumpStaffExpenses(tester, isDesktop: isDesktop, env: env());
        await tester.tap(find.text('Filters'));
        await tester.pumpAndSettle();
        // Search, then the range's min and max.
        await tester.enterText(find.byType(TextField).at(1), '50');
        await tester.enterText(find.byType(TextField).at(2), '300');
        await tester.pumpAndSettle();

        expect(find.text('Filters (1)'), findsOneWidget);
        expect(find.text('Fuel'), findsOneWidget);
        expect(find.text('snacks'), findsOneWidget);
        expect(find.text('Rent'), findsNothing);
        expect(find.text('Old'), findsNothing);
        final chip = find.widgetWithText(InputChip, 'Amount: N50.0 - N300.0');
        expect(chip, findsOneWidget);

        await tester.tap(
          find.descendant(of: chip, matching: find.byIcon(Icons.close)),
        );
        await tester.pumpAndSettle();

        expect(find.byType(InputChip), findsNothing);
        expect(find.text('Rent'), findsOneWidget);
        expect(find.text('Filters'), findsOneWidget);
        expect(
          tester.widget<TextField>(find.byType(TextField).at(1)).controller!
              .text,
          isEmpty,
        );
      });

      testWidgets('Reset All keeps the period ($width)', (tester) async {
        await pumpStaffExpenses(
          tester,
          isDesktop: isDesktop,
          env: env(),
          period: day17,
        );
        final pill = 'Date: ${receiptsPeriodLabel(day17)}';
        // A search that keeps a row: the empty state's "Clear all
        // filters" button overflows under the test font.
        await tester.enterText(find.byType(TextField).first, 'diesel');
        await tester.pumpAndSettle();
        expect(find.text('Reset All Filters'), findsOneWidget);

        await tester.tap(find.text('Reset All Filters'));
        await tester.pumpAndSettle();

        expect(find.text('Reset All Filters'), findsNothing);
        expect(find.text(pill), findsOneWidget);
        expect(find.text('Fuel'), findsOneWidget);
        // Still the 17th only.
        expect(find.text('Rent'), findsNothing);
        expect(
          find.text('All time covers the data loaded on this device.'),
          findsNothing,
        );
      });

      testWidgets('totals are the same on every page ($width)', (
        tester,
      ) async {
        final many = [
          for (var i = 0; i < 150; i++)
            testExpense(
              uuid: 'e-$i',
              name: 'Item ${i.toString().padLeft(3, '0')}',
              amount: 2,
              createdAt: DateTime(2026, 1, 1).add(Duration(hours: i)),
            ),
        ];
        await pumpStaffExpenses(
          tester,
          isDesktop: isDesktop,
          env: env(list: many),
        );
        expect(find.text('Showing 1-100 of 150 expenses'), findsOneWidget);
        expect(find.text('N300.0'), findsOneWidget);
        expect(find.text('150 expenses'), findsOneWidget);

        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();

        expect(find.text('Page 2 of 2'), findsOneWidget);
        expect(find.text('Showing 101-150 of 150 expenses'), findsOneWidget);
        expect(find.text('N300.0'), findsOneWidget);
        expect(find.text('150 expenses'), findsOneWidget);
      });

      testWidgets('newest first by default ($width)', (tester) async {
        await pumpStaffExpenses(tester, isDesktop: isDesktop, env: env());
        expect(y(tester, 'Rent'), lessThan(y(tester, 'Fuel')));
        expect(y(tester, 'Fuel'), lessThan(y(tester, 'snacks')));
        // Undated last.
        expect(y(tester, 'snacks'), lessThan(y(tester, 'Old')));
        expect(find.byIcon(Icons.arrow_downward_rounded), findsOneWidget);
        expect(find.byIcon(Icons.arrow_upward_rounded), findsNothing);
      });

      testWidgets('a row opens the expense ($width)', (tester) async {
        final log = StaffEnvLog();
        await pumpStaffExpenses(
          tester,
          isDesktop: isDesktop,
          env: env(log: log),
        );
        await tester.tap(find.text('Rent'));
        await tester.pumpAndSettle();
        expect(log.calls, ['expense']);
        expect((log.records.single as TempExpensesClass).uuid, 'e-rent');
      });

      testWidgets('back from an expense rebuilds the table ($width)', (
        tester,
      ) async {
        final list = expenses();
        await pumpStaffExpenses(
          tester,
          isDesktop: isDesktop,
          env: env(
            list: list,
            onOpen:
                () => list.add(
                  testExpense(uuid: 'e-new', amount: 1000, createdAt: day(19)),
                ),
          ),
        );
        expect(find.text('N1355.0'), findsOneWidget);

        await tester.tap(find.text('Rent'));
        await tester.pumpAndSettle();

        expect(find.text('N2355.0'), findsOneWidget);
        expect(find.text('5 expenses'), findsOneWidget);
      });

      testWidgets('without View Date the period is today ($width)', (
        tester,
      ) async {
        await pumpStaffExpenses(
          tester,
          isDesktop: isDesktop,
          env: env(access: staffAccess(canPickDate: false)),
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

      testWidgets('no department column by default ($width)', (tester) async {
        await pumpStaffExpenses(tester, isDesktop: isDesktop, env: env());
        expect(find.text('Department'), findsNothing);
        expect(find.text('Bar'), findsNothing);
      });

      testWidgets('department column with departments ($width)', (
        tester,
      ) async {
        await pumpStaffExpenses(
          tester,
          isDesktop: isDesktop,
          env: env(access: staffAccess(departmentsEnabled: true)),
        );
        expect(find.text('Department'), findsOneWidget);
        expect(find.text('Bar'), findsOneWidget);
      });

      testWidgets('former staff in the title ($width)', (tester) async {
        await pumpStaffExpenses(
          tester,
          isDesktop: isDesktop,
          env: env(
            list: [testExpense(userId: 'staff-x', creator: 'Xena')],
          ),
          staffKey: 'staff-x',
        );
        expect(find.text('Xena: Expenses'), findsOneWidget);
        expect(find.text(staffReportFormerRoleLabel), findsOneWidget);
      });

      testWidgets('without the expenses gate: not available ($width)', (
        tester,
      ) async {
        await pumpStaffExpenses(
          tester,
          isDesktop: isDesktop,
          env: env(access: staffAccess(showExpenses: false)),
        );
        expect(find.text('Expenses are not available.'), findsOneWidget);
        expect(find.text('Rent'), findsNothing);
        expect(find.byType(TextField), findsNothing);
      });
    }
  });
}
