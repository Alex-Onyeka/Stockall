import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/temp_expenses/temp_expenses_class.dart';
import 'package:stockall/pages/report/expenses_report/expenses_report_table/class/expenses_report_table_logic.dart';
import 'package:stockall/pages/report/expenses_report/expenses_summary/class/expenses_summary_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_summary/class/receipts_report_summary_logic.dart';

import 'expenses_report_fixtures.dart';

const allTime = ReceiptsReportPeriod.allTime();

ExpensesSummaryResult summary(
  List<ExpensesReportRow> rows, {
  ReceiptsReportPeriod period = allTime,
  bool departmentsEnabled = true,
}) => ExpensesSummaryBuilder.build(
  rows: rows,
  period: period,
  departmentsEnabled: departmentsEnabled,
  closingTime: midnight,
  now: day(20),
);

List<String> labels(List<ExpensesBreakdownRow> rows) =>
    rows.map((r) => r.label).toList();

void main() {
  group('Statistics', () {
    test('Total Expenses and the other cards leave stock purchases out', () {
      final s = summary(sampleRows()).stats;
      expect(s.expenseCount, 6);
      expect(s.totalExpenses, 4070);
      expect(s.average, closeTo(4070 / 6, 1e-9));
      expect(s.largest!.uuid, 'e-salary-ada');
      expect(s.salaryCount, 2);
      expect(s.salaryTotal, 2500);
      expect(s.staffPaidCount, 2);
      expect(s.withLinesCount, 2);
      expect(s.lineCount, 4);
      expect(s.linesMismatchCount, 0);
      expect(s.stockPurchaseCount, 1);
      expect(s.stockPurchaseTotal, 5000);
      expect(s.categoriesUsed, 4);
      expect(s.distinctStaff, 3);
    });

    test('equals the table totals for the same period', () {
      final rows = sampleRows();
      final period = ReceiptsReportPeriod.day(DateTime(2026, 10, 17));
      final s = summary(rows, period: period).stats;
      final t =
          ExpensesReportQuery.paginate(
            ExpensesReportQuery.filterAndSort(
              rows: rows,
              period: period,
              filters: ExpensesReportFilters(),
              departmentsEnabled: true,
              closingTime: midnight,
            ),
            1,
          ).totals;
      expect(s.totalExpenses, t.total);
      expect(s.expenseCount, t.countedCount);
      expect(s.stockPurchaseTotal, t.stockPurchaseTotal);
    });

    test('empty period', () {
      final s =
          summary(
            sampleRows(),
            period: ReceiptsReportPeriod.day(DateTime(2026, 9, 1)),
          ).stats;
      expect(s.expenseCount, 0);
      expect(s.average, 0);
      expect(s.largest, isNull);
    });
  });

  group('Breakdowns', () {
    test('categories by amount, stock purchase last and not shared', () {
      final rows = summary(sampleRows()).breakdown(
        ExpensesBreakdownTab.category,
      );
      expect(labels(rows), [
        'Staff Salary',
        'Simple Expenses',
        'Welfare',
        'Gifts',
        'Stock Purchase',
      ]);
      final stock = rows.last;
      expect(stock.excluded, isTrue);
      expect(stock.share, isNull);
      expect(stock.amount, 5000);
      final shares = rows
          .where((r) => !r.excluded)
          .fold<double>(0, (s, r) => s + r.share!);
      expect(shares, closeTo(100, 1e-9));
    });

    test('staff salary per staff paid, shares of the salary total', () {
      final rows = summary(
        buildRows(
          [
            ...sampleExpenses(),
            exp(
              uuid: 'e-salary-none',
              type: ExpenseType.staffSalary,
              amount: 2500,
            ),
          ],
          staffNames: sampleStaffNames,
        ),
      ).breakdown(ExpensesBreakdownTab.salary);
      expect(labels(rows), ['Ada Obi', 'Bayo Ade', expensesNoPaidStaffLabel]);
      expect(rows.first.share, closeTo(30, 1e-9));
      expect(rows.last.isNone, isTrue);
    });

    test('created by, channel and departments', () {
      final r = summary(sampleRows());
      final staff = r.breakdown(ExpensesBreakdownTab.staff);
      expect(staff.map((g) => g.amount).toList(), [2500, 1300, 270]);
      final channels = r.breakdown(ExpensesBreakdownTab.channel);
      expect(labels(channels), ['Cash', 'GTBank (1234)', 'Split']);
      expect(channels.map((g) => g.amount).toList(), [1570, 1500, 1000]);
      final departments = r.breakdown(ExpensesBreakdownTab.department);
      expect(labels(departments), [
        'Not Set',
        'Bar',
        expensesNoDepartmentLabel,
      ]);
      expect(departments.last.amount, 2770);
    });

    test('no Departments tab with departments off', () {
      final r = summary(sampleRows(), departmentsEnabled: false);
      expect(r.breakdown(ExpensesBreakdownTab.department), isEmpty);
    });

    test('every row opens the table on exactly its expenses', () {
      final rows = sampleRows();
      for (final period in [
        allTime,
        ReceiptsReportPeriod.day(DateTime(2026, 10, 17)),
      ]) {
        final r = summary(rows, period: period);
        for (final tab in ExpensesBreakdownTab.values) {
          for (final b in r.breakdown(tab)) {
            final opened = b.handoff.apply(
              rows,
              period: period,
              departmentsEnabled: true,
              closingTime: midnight,
            );
            final reason = '${tab.name} ${b.label} $period';
            expect(opened.length, b.count, reason: reason);
            expect(
              opened.fold<double>(0, (s, x) => s + x.amount),
              b.amount,
              reason: reason,
            );
          }
        }
      }
    });

    test('sorting keeps none and excluded rows last', () {
      final rows = summary(sampleRows()).breakdown(
        ExpensesBreakdownTab.category,
      );
      final byName = ExpensesSummaryBuilder.sortBreakdown(
        rows,
        field: ExpensesBreakdownSortField.name,
        ascending: false,
      );
      expect(byName.last.excluded, isTrue);
      expect(labels(byName).first, 'Welfare');
      final departments = ExpensesSummaryBuilder.sortBreakdown(
        summary(sampleRows()).breakdown(ExpensesBreakdownTab.department),
        field: ExpensesBreakdownSortField.amount,
        ascending: true,
      );
      expect(departments.last.isNone, isTrue);
    });
  });

  group('Top lists', () {
    test('top expenses: largest first, ties newest, no stock purchase', () {
      final top = summary(sampleRows()).topExpenses;
      expect(uuids(top), [
        'e-salary-ada',
        'e-salary-bayo',
        'e-nepa',
        'e-fuel',
        'e-party',
      ]);
    });

    test('sub-expense names across expenses, any case', () {
      final lines = summary(sampleRows()).topLines;
      expect(lines.map((l) => l.label).toList(), [
        'Token',
        'transportation',
        'Drinks',
      ]);
      final transport = lines[1];
      expect(transport.amount, 250);
      expect(transport.lineCount, 2);
      expect(transport.expenseCount, 2);
      expect(transport.handoff.filters.search, 'transportation');
    });
  });

  group('Trend', () {
    test('daily over a range; stock purchases left out', () {
      final r = summary(
        sampleRows(),
        period: ReceiptsReportPeriod.range(
          DateTime(2026, 10, 16),
          DateTime(2026, 10, 18),
        ),
      );
      expect(r.interval, ReceiptsTrendInterval.daily);
      expect(r.trend.map((p) => p.total).toList(), [1570, 1300, 1200]);
      expect(r.trend.map((p) => p.salary).toList(), [1500, 0, 1000]);
      expect(r.trend.fold<double>(0, (s, p) => s + p.total), 4070);
    });

    test('hourly for one day', () {
      final r = summary(
        sampleRows(),
        period: ReceiptsReportPeriod.day(DateTime(2026, 10, 17)),
      );
      expect(r.interval, ReceiptsTrendInterval.hourly);
      expect(r.trend.length, 24);
      expect(r.trend[9].total, 300);
      expect(r.trend[11].total, 0);
      expect(r.trend[14].total, 1000);
    });

    test('all time runs from the first expense to today', () {
      final r = summary(sampleRows());
      expect(r.trend.first.start, DateTime(2026, 10, 16));
      expect(r.trend.last.start, DateTime(2026, 10, 20));
      expect(summary(const []).interval, isNull);
      expect(summary(const []).trend, isEmpty);
    });
  });
}
