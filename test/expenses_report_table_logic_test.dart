import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/payment_entry/payment_entry.dart';
import 'package:stockall/classes/temp_expenses/temp_expenses_class.dart';
import 'package:stockall/pages/report/expenses_report/expenses_report_table/class/expenses_report_table_logic.dart';
import 'package:stockall/pages/report/general_report/class/general_report_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

import 'expenses_report_fixtures.dart';

const allTime = ReceiptsReportPeriod.allTime();

List<ExpensesReportRow> query(
  List<ExpensesReportRow> rows, {
  ReceiptsReportPeriod period = allTime,
  ExpensesReportFilters? filters,
  ExpensesSortField sortField = ExpensesSortField.createdAt,
  bool ascending = false,
  bool departmentsEnabled = false,
  bool includeStockPurchases = true,
}) => ExpensesReportQuery.filterAndSort(
  rows: rows,
  period: period,
  filters: filters ?? ExpensesReportFilters(),
  sortField: sortField,
  ascending: ascending,
  departmentsEnabled: departmentsEnabled,
  includeStockPurchases: includeStockPurchases,
  closingTime: midnight,
);

void main() {
  group('Scope', () {
    final expenses = [
      exp(uuid: 'mine-d1', departmentUuid: 'd1'),
      exp(uuid: 'mine-none'),
      exp(uuid: 'mine-blank', departmentUuid: '  '),
      exp(uuid: 'other-d1', userId: 'staff-b', departmentUuid: 'd1'),
      exp(uuid: 'other-d2', userId: 'staff-b', departmentUuid: 'd2'),
      exp(uuid: 'other-shop', shopId: 2),
    ];

    List<String> scoped(ExpensesReportAccess a) =>
        a.scope(expenses).map((e) => e.uuid!).toList();

    test('other shops are left out', () {
      expect(scoped(access()), isNot(contains('other-shop')));
      expect(scoped(access(shopId: null)), contains('other-shop'));
    });

    test('without View All Transactions only own expenses', () {
      expect(scoped(access(canViewAllTransactions: false)), [
        'mine-d1',
        'mine-none',
        'mine-blank',
      ]);
    });

    test('restricted to the current department', () {
      expect(
        scoped(
          access(
            departmentsEnabled: true,
            canViewAllDepartments: false,
            currentDepartmentUuid: 'd1',
          ),
        ),
        ['mine-d1', 'other-d1'],
      );
    });

    test('staff in no department see only expenses in no department', () {
      expect(
        scoped(
          access(departmentsEnabled: true, canViewAllDepartments: false),
        ),
        ['mine-none', 'mine-blank'],
      );
    });

    test('View All Departments without a current one sees all', () {
      expect(scoped(access(departmentsEnabled: true)).length, 5);
    });

    test('same expenses as the General Report scope', () {
      for (final a in [
        access(),
        access(canViewAllTransactions: false),
        access(departmentsEnabled: true, canViewAllDepartments: false),
        access(
          departmentsEnabled: true,
          canViewAllDepartments: false,
          currentDepartmentUuid: 'd2',
          canViewAllTransactions: false,
          currentUserId: 'staff-b',
        ),
      ]) {
        final general = GeneralReportExpenses.scope(
          expenses: expenses.where((e) => e.shopId == 1).toList(),
          departmentsEnabled: a.departmentsEnabled,
          canViewAllDepartments: a.canViewAllDepartments,
          currentDepartmentUuid: a.currentDepartmentUuid,
          canViewAllTransactions: a.canViewAllTransactions,
          currentUserId: a.currentUserId,
        );
        expect(scoped(a), general.map((e) => e.uuid).toList());
      }
    });

    test('initial period is today', () {
      final p = access().initialPeriod(now: day(17), closingTime: midnight);
      expect(p.isSingleDay, isTrue);
      expect(p.start, DateTime(2026, 10, 17));
    });
  });

  group('Rows and categories', () {
    test('system, custom, renamed and deleted custom categories', () {
      final rows = {for (final r in sampleRows()) r.uuid: r};
      expect(rows['e-fuel']!.categoryKey, ExpenseType.simpleExpense);
      expect(rows['e-fuel']!.categoryLabel, 'Simple Expenses');
      expect(rows['e-salary-ada']!.categoryKey, ExpenseType.staffSalary);
      expect(rows['e-stock']!.categoryLabel, 'Stock Purchase');
      // Renamed: the current name, keyed by uuid.
      expect(rows['e-party']!.categoryKey, 'custom:c-welfare');
      expect(rows['e-party']!.categoryLabel, 'Welfare');
      // Deleted: uuid cleared, keyed and labelled by the saved name.
      expect(rows['e-gift']!.categoryKey, 'custom-name:gifts');
      expect(rows['e-gift']!.categoryLabel, 'Gifts');
    });

    test('unknown expense types are Simple Expenses', () {
      final r = buildRows([exp(uuid: 'x', type: 'legacy_type')]).single;
      expect(r.categoryKey, ExpenseType.simpleExpense);
      expect(r.categoryLabel, 'Simple Expenses');
    });

    test('staff paid: current name, else the saved one; salaries only', () {
      final rows = {for (final r in sampleRows()) r.uuid: r};
      expect(rows['e-salary-ada']!.paidStaffKey, 'staff-a');
      expect(rows['e-salary-ada']!.paidStaffName, 'Ada Obi');
      final noLookup = {
        for (final r in buildRows(sampleExpenses())) r.uuid: r,
      };
      expect(noLookup['e-salary-ada']!.paidStaffName, 'Ada Old');
      expect(rows['e-fuel']!.paidStaffKey, isNull);
      expect(rows['e-fuel']!.paidStaffLabel, '—');
      // A non-salary with a stray staffUuid has no staff paid.
      final stray = buildRows([exp(uuid: 's', staffUuid: 'staff-a')]).single;
      expect(stray.paidStaffKey, isNull);
    });

    test('channel: exact label, case-insensitive key, Split', () {
      final rows = {for (final r in sampleRows()) r.uuid: r};
      expect(rows['e-salary-ada']!.channelLabel, 'GTBank (1234)');
      expect(rows['e-salary-ada']!.channelKey, 'gtbank (1234)');
      expect(rows['e-nepa']!.channelLabel, PaymentMethods.split);
      expect(rows['e-fuel']!.channelLabel, PaymentMethods.cash);
    });

    test('quantity label', () {
      expect(expenseQuantityLabel(20, 'litres'), '20 litres');
      expect(expenseQuantityLabel(1.5, null), '1.5');
      expect(expenseQuantityLabel(null, 'Bags'), isNull);
    });
  });

  group('Stock purchases and totals', () {
    test('Total Expenses leaves stock purchases out', () {
      final t = ExpensesReportQuery.paginate(query(sampleRows()), 1).totals;
      expect(t.count, 7);
      expect(t.countedCount, 6);
      expect(t.total, 4070);
      expect(t.stockPurchaseCount, 1);
      expect(t.stockPurchaseTotal, 5000);
    });

    test('total equals the General Report expenses in each period', () {
      final expenses = sampleExpenses();
      final rows = buildRows(expenses);
      for (final period in [
        allTime,
        ReceiptsReportPeriod.day(DateTime(2026, 10, 17)),
        ReceiptsReportPeriod.range(DateTime(2026, 10, 16), DateTime(2026, 10, 17)),
      ]) {
        final general = GeneralReportExpenses.total(
          GeneralReportExpenses.inPeriod(
            expenses,
            period,
            closingTime: midnight,
          ),
        );
        final t =
            ExpensesReportQuery.paginate(query(rows, period: period), 1).totals;
        expect(t.total, general, reason: '$period');
      }
    });

    test('the option off hides stock purchases', () {
      final rows = query(sampleRows(), includeStockPurchases: false);
      expect(uuids(rows), isNot(contains('e-stock')));
      final t = ExpensesReportQuery.paginate(rows, 1).totals;
      expect(t.total, 4070);
      expect(t.stockPurchaseCount, 0);
    });

    test('the Stock Purchase category filter shows them even when off', () {
      final rows = query(
        sampleRows(),
        includeStockPurchases: false,
        filters: ExpensesReportFilters(
          categoryKey: ExpenseType.stockPurchase,
        ),
      );
      expect(uuids(rows), ['e-stock']);
    });
  });

  group('Sub-expenses', () {
    test('lines are never added to the totals', () {
      final rows = query(
        sampleRows(),
        filters: ExpensesReportFilters(hasLines: true),
      );
      expect(uuids(rows), ['e-party', 'e-nepa']);
      final t = ExpensesReportQuery.paginate(rows, 1).totals;
      expect(t.total, 1200);
      expect(t.withLinesCount, 2);
      expect(t.lineCount, 4);
    });

    test('without lines', () {
      final rows = query(
        sampleRows(),
        filters: ExpensesReportFilters(hasLines: false),
      );
      expect(rows.every((r) => !r.hasLines), isTrue);
      expect(rows.length, 5);
    });

    test('search finds an expense by a line name or description', () {
      final rows = query(
        sampleRows(),
        filters: ExpensesReportFilters(search: 'TRANSPORT'),
      );
      expect(uuids(rows), ['e-party', 'e-nepa']);
      final byDescription = query(
        buildRows([
          expWithLines(
            uuid: 'x',
            subs: [line('Misc', 5, description: 'Okada to market')],
          ),
          exp(uuid: 'y'),
        ]),
        filters: ExpensesReportFilters(search: 'okada'),
      );
      expect(uuids(byDescription), ['x']);
    });

    test('lines that no longer add up are flagged', () {
      final edited = expWithLines(uuid: 'x', subs: [line('A', 10)])
        ..amount = 15;
      expect(buildRows([edited]).single.linesMismatch, isTrue);
      expect(
        buildRows([expWithLines(uuid: 'y', subs: [line('A', 10)])])
            .single
            .linesMismatch,
        isFalse,
      );
    });
  });

  group('Filters', () {
    test('category, staff, channel and amount', () {
      final rows = sampleRows();
      expect(
        uuids(
          query(
            rows,
            filters: ExpensesReportFilters(categoryKey: 'custom:c-welfare'),
          ),
        ),
        ['e-party'],
      );
      expect(
        uuids(query(rows, filters: ExpensesReportFilters(staffKey: 'owner'))),
        ['e-salary-bayo', 'e-salary-ada'],
      );
      expect(
        uuids(
          query(
            rows,
            filters: ExpensesReportFilters(channelKey: 'gtbank (1234)'),
          ),
        ),
        ['e-salary-ada'],
      );
      expect(
        uuids(
          query(
            rows,
            filters: ExpensesReportFilters(amountMin: 1000, amountMax: 1500),
          ),
        ),
        ['e-salary-bayo', 'e-nepa', 'e-salary-ada'],
      );
    });

    test('an invalid amount range is not applied', () {
      final f = ExpensesReportFilters(amountMin: 500, amountMax: 100);
      expect(f.amountRangeError, isNotNull);
      expect(query(sampleRows(), filters: f).length, 7);
    });

    test('staff paid, and the none key', () {
      final rows = buildRows([
        ...sampleExpenses(),
        exp(uuid: 'e-salary-none', type: ExpenseType.staffSalary),
      ]);
      expect(
        uuids(
          query(rows, filters: ExpensesReportFilters(paidStaffKey: 'staff-b')),
        ),
        ['e-salary-bayo'],
      );
      expect(
        uuids(
          query(
            rows,
            filters: ExpensesReportFilters(
              categoryKey: ExpenseType.staffSalary,
              paidStaffKey: expensesReportNoneKey,
            ),
          ),
        ),
        ['e-salary-none'],
      );
    });

    test('department filter and search only with departments on', () {
      final rows = sampleRows();
      final f = ExpensesReportFilters(departmentKey: 'd1');
      expect(query(rows, filters: f).length, 7);
      expect(uuids(query(rows, filters: f, departmentsEnabled: true)), [
        'e-fuel',
      ]);
      final none = ExpensesReportFilters(departmentKey: expensesReportNoneKey);
      expect(query(rows, filters: none, departmentsEnabled: true).length, 4);
      final search = ExpensesReportFilters(search: 'kitchen');
      expect(query(rows, filters: search), isEmpty);
      expect(uuids(query(rows, filters: search, departmentsEnabled: true)), [
        'e-stock',
      ]);
    });

    test('active count, copy and reset keep view options', () {
      final state = ExpensesReportTableState(
        filters: ExpensesReportFilters(
          search: 'x',
          categoryKey: 'c',
          hasLines: true,
          amountMin: 1,
        ),
        groupBy: ExpensesGroupBy.channel,
        includeStockPurchases: false,
        page: 3,
      );
      expect(state.filters.activeCount, 3);
      final copy = state.filters.copy()..categoryKey = 'other';
      expect(state.filters.categoryKey, 'c');
      expect(copy.categoryKey, 'other');
      state.resetAll();
      expect(state.filters.hasAnything, isFalse);
      expect(state.page, 1);
      expect(state.groupBy, ExpensesGroupBy.channel);
      expect(state.includeStockPurchases, isFalse);
    });
  });

  group('Options', () {
    test('system categories always, then custom ones A-Z', () {
      final options = ExpensesReportOptions.categories(
        sampleRows(),
        categories: [...sampleCategories, category('c-zz', 'Zebra')],
      );
      expect(options.map((o) => o.label).toList(), [
        'Simple Expenses',
        'Staff Salary',
        'Stock Purchase',
        'Gifts',
        'Welfare',
        'Zebra',
      ]);
    });

    test('staff paid from salaries only; channels from rows', () {
      expect(
        ExpensesReportOptions.paidStaff(
          sampleRows(),
        ).map((o) => o.label).toList(),
        ['Ada Obi', 'Bayo Ade'],
      );
      expect(
        ExpensesReportOptions.channels(sampleRows()).map((o) => o.key).toSet(),
        {'cash', 'gtbank (1234)', 'split'},
      );
      final staff = ExpensesReportOptions.staff(
        buildRows([
          exp(uuid: 'old', creator: 'Ada Old', createdAt: day(1)),
          exp(uuid: 'new', creator: 'Ada New', createdAt: day(2)),
          exp(uuid: 'nobody', userId: null),
        ]),
      );
      expect(staff.map((o) => o.label).toList(), ['Ada New', 'No staff']);
      expect(staff.last.key, expensesReportNoneKey);
    });
  });

  group('Period', () {
    test('business-day window and undated expenses', () {
      final rows = buildRows([
        exp(uuid: 'late', createdAt: DateTime(2026, 10, 17, 23, 59)),
        exp(uuid: 'next', createdAt: DateTime(2026, 10, 18, 0, 1)),
        exp(uuid: 'undated', undated: true),
      ]);
      final day17 = ReceiptsReportPeriod.day(DateTime(2026, 10, 17));
      expect(uuids(query(rows, period: day17)), ['late']);
      expect(uuids(query(rows)), ['next', 'late', 'undated']);
    });
  });

  group('Sorting and paging', () {
    test('amount, largest first, ties newest first', () {
      final rows = query(
        buildRows([
          exp(uuid: 'a', amount: 10, createdAt: day(1)),
          exp(uuid: 'b', amount: 10, createdAt: day(2)),
          exp(uuid: 'c', amount: 50, createdAt: day(1)),
        ]),
        sortField: ExpensesSortField.amount,
      );
      expect(uuids(rows), ['c', 'b', 'a']);
    });

    test('missing staff paid sinks in both directions', () {
      for (final asc in [true, false]) {
        final rows = query(
          sampleRows(),
          sortField: ExpensesSortField.paidStaff,
          ascending: asc,
        );
        expect(
          uuids(rows.take(2)),
          asc
              ? ['e-salary-ada', 'e-salary-bayo']
              : ['e-salary-bayo', 'e-salary-ada'],
        );
        expect(rows.skip(2).every((r) => r.paidStaffName == null), isTrue);
      }
    });

    test('category and lines', () {
      final byCategory = query(
        sampleRows(),
        sortField: ExpensesSortField.category,
        ascending: true,
      );
      expect(byCategory.first.categoryLabel, 'Gifts');
      expect(byCategory.last.categoryLabel, 'Welfare');
      final byLines = query(sampleRows(), sortField: ExpensesSortField.lines);
      expect(uuids(byLines.take(2)), ['e-party', 'e-nepa']);
    });

    test('first direction of a column', () {
      expect(
        ExpensesReportQuery.defaultAscending(ExpensesSortField.name),
        isTrue,
      );
      expect(
        ExpensesReportQuery.defaultAscending(ExpensesSortField.amount),
        isFalse,
      );
    });

    test('100 per page, totals over every page', () {
      final rows = buildRows([
        for (var i = 0; i < 250; i++)
          exp(uuid: 'e$i'.padLeft(5, '0'), amount: 2, createdAt: day(17)),
      ]);
      final sorted = query(rows);
      final p3 = ExpensesReportQuery.paginate(sorted, 3);
      expect(p3.totalPages, 3);
      expect(p3.rows.length, 50);
      expect(p3.firstIndex, 201);
      expect(p3.lastIndex, 250);
      expect(p3.totals.total, 500);
      expect(ExpensesReportQuery.paginate(sorted, 9).page, 3);
      final empty = ExpensesReportQuery.paginate(const [], 1);
      expect(empty.firstIndex, 0);
      expect(empty.totalPages, 1);
    });
  });

  group('Group by', () {
    test('by category: amounts, stock purchase apart', () {
      final groups = ExpensesGrouping.sort(
        ExpensesGrouping.build(query(sampleRows()), ExpensesGroupBy.category),
        field: ExpensesGroupSortField.amount,
        ascending: false,
      );
      expect(groups.map((g) => g.label).toList(), [
        'Stock Purchase',
        'Staff Salary',
        'Simple Expenses',
        'Welfare',
        'Gifts',
      ]);
      expect(groups.first.amount, 5000);
      expect(groups.first.countedAmount, 0);
      expect(groups[1].count, 2);
      expect(groups[2].lineCount, 2);
    });

    test('by staff paid: none last, totals over every expense', () {
      final rows = query(sampleRows());
      final groups = ExpensesGrouping.sort(
        ExpensesGrouping.build(rows, ExpensesGroupBy.paidStaff),
        field: ExpensesGroupSortField.amount,
        ascending: true,
      );
      expect(groups.last.isNone, isTrue);
      expect(groups.last.label, expensesNoPaidStaffLabel);
      final page = ExpensesGrouping.paginate(groups, 1, rows: rows);
      expect(page.totals.total, 4070);
      expect(page.totalCount, 3);
    });
  });
}
