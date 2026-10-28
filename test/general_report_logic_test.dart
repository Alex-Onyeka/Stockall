import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/temp_expenses/temp_expenses_class.dart';
import 'package:stockall/pages/report/general_report/class/general_report_logic.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/class/purchase_report_table_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_summary/class/receipts_report_summary_logic.dart';

import 'general_report_fixtures.dart';
import 'purchase_report_fixtures.dart'
    show midnight, purchase, uuidN;

const four = TimeOfDay(hour: 4, minute: 0);

final day17 = ReceiptsReportPeriod.day(DateTime(2026, 10, 17));

final samplePurchases = [
  purchase(uuid: uuidN(1), total: 100),
  purchase(uuid: uuidN(2), total: 250),
  purchase(
    uuid: uuidN(3),
    total: 75,
    createdAt: DateTime(2026, 10, 16, 12),
  ),
];

GeneralReportFigures figuresFor({
  ReceiptsReportPeriod? period,
  bool profitVisible = true,
  List<TempExpensesClass>? expenses,
  TimeOfDay closingTime = midnight,
}) {
  return GeneralReportFigures.build(
    receiptRows: receiptRowsOf(sampleReceipts()),
    purchaseRows: purchaseRowsOf(samplePurchases),
    expenses:
        expenses ??
        [
          expense(uuid: 'e-1', amount: 40),
          expense(uuid: 'e-2', amount: 25),
          expense(
            uuid: 'e-3',
            amount: 500,
            createdDate: DateTime(2026, 10, 16, 12),
          ),
        ],
    period: period ?? day17,
    profitVisible: profitVisible,
    closingTime: closingTime,
  );
}

void main() {
  group('figures match the existing reports', () {
    test('revenue and gross profit equal the Receipts Report', () {
      final rows = receiptRowsOf(sampleReceipts());
      // As the Receipts Report view runs it, with no filters.
      final sorted = ReceiptsReportQuery.filterAndSort(
        rows: rows,
        period: day17,
        filters: ReceiptsReportFilters(),
        sortField: ReceiptsSortField.createdAt,
        ascending: false,
        departmentsEnabled: true,
        subStaffEnabled: true,
        profitVisible: true,
        closingTime: midnight,
      );
      final page = ReceiptsReportQuery.paginate(sorted, 1);
      final stats = ReceiptsSummaryBuilder.stats(sorted);

      final f = figuresFor();
      expect(f.totalRevenue, page.totalRevenue);
      expect(f.grossProfit, page.totalProfit);
      expect(f.costMissingCount, stats.costMissingCount);
      expect(f.noItemDataCount, stats.profitUnknownCount);
      expect(f.receiptCount, page.totalCount);

      // Every receipt type, VAT inside revenue, the invoice
      // payment only as paid, the 16th left out.
      expect(f.totalRevenue, 720);
      // Void line left out, missing cost as 0, no-item receipt
      // left out.
      expect(f.grossProfit, 300);
      expect(f.costMissingCount, 1);
      expect(f.noItemDataCount, 1);
      expect(f.receiptCount, 7);
    });

    test('purchases equal the Purchase Report total', () {
      final sorted = PurchaseReportQuery.filterAndSort(
        rows: purchaseRowsOf(samplePurchases),
        period: day17,
        filters: PurchaseReportFilters(),
        sortField: PurchasesSortField.createdAt,
        ascending: false,
        departmentsEnabled: true,
        closingTime: midnight,
      );
      final page = PurchaseReportQuery.paginate(sorted, 1);

      final f = figuresFor();
      expect(f.totalPurchases, page.total);
      expect(f.totalPurchases, 350);
      expect(f.purchaseCount, 2);
    });

    test('all time covers every loaded record', () {
      final f = figuresFor(
        period: const ReceiptsReportPeriod.allTime(),
      );
      expect(f.totalRevenue, 720 + 999);
      expect(f.grossProfit, 300 + 998);
      expect(f.totalPurchases, 425);
      expect(f.totalExpenses, 565);
    });

    test('rows handed back for the trend are the period rows', () {
      final f = figuresFor();
      expect(f.receiptRows.length, 7);
      expect(
        f.expenses.map((e) => e.uuid),
        unorderedEquals(['e-1', 'e-2']),
      );
    });
  });

  group('net profit', () {
    test('is gross profit minus expenses; purchases ignored', () {
      final f = figuresFor();
      expect(f.totalExpenses, 65);
      expect(f.netProfit, 300 - 65);
    });

    test('can be negative', () {
      final f = figuresFor(
        expenses: [expense(amount: 400)],
      );
      expect(f.netProfit, -100);
    });
  });

  group('without the cost permission', () {
    test('profit values are null, the rest unchanged', () {
      final f = figuresFor(profitVisible: false);
      expect(f.profitVisible, isFalse);
      expect(f.grossProfit, isNull);
      expect(f.netProfit, isNull);
      expect(f.costMissingCount, isNull);
      expect(f.noItemDataCount, isNull);
      expect(f.totalRevenue, 720);
      expect(f.totalPurchases, 350);
      expect(f.totalExpenses, 65);
    });
  });

  group('expense scope', () {
    final expenses = [
      expense(uuid: 'a', userId: 'me', departmentUuid: 'd1'),
      expense(uuid: 'b', userId: 'other', departmentUuid: 'd1'),
      expense(uuid: 'c', userId: 'me', departmentUuid: 'd2'),
      expense(uuid: 'd', userId: 'other'),
    ];

    List<String?> scope({
      bool departmentsEnabled = true,
      bool canViewAllDepartments = true,
      String? currentDepartmentUuid,
      bool canViewAllTransactions = true,
    }) {
      return GeneralReportExpenses.scope(
        expenses: expenses,
        departmentsEnabled: departmentsEnabled,
        canViewAllDepartments: canViewAllDepartments,
        currentDepartmentUuid: currentDepartmentUuid,
        canViewAllTransactions: canViewAllTransactions,
        currentUserId: 'me',
      ).map((e) => e.uuid).toList();
    }

    test('all departments, no department picked: everything', () {
      expect(scope(), ['a', 'b', 'c', 'd']);
    });

    test('all departments, one picked: that department', () {
      expect(scope(currentDepartmentUuid: 'd2'), ['c']);
    });

    test('own department only', () {
      expect(
        scope(
          canViewAllDepartments: false,
          currentDepartmentUuid: 'd1',
        ),
        ['a', 'b'],
      );
    });

    test('departments off: department ignored', () {
      expect(
        scope(
          departmentsEnabled: false,
          canViewAllDepartments: false,
          currentDepartmentUuid: 'd1',
        ),
        ['a', 'b', 'c', 'd'],
      );
    });

    test('own transactions only, with or without departments', () {
      expect(
        scope(canViewAllTransactions: false),
        ['a', 'c'],
      );
      expect(
        scope(
          departmentsEnabled: false,
          canViewAllTransactions: false,
        ),
        ['a', 'c'],
      );
      expect(
        scope(
          canViewAllDepartments: false,
          currentDepartmentUuid: 'd1',
          canViewAllTransactions: false,
        ),
        ['a'],
      );
    });

    test('same rule as ReceiptsReportAccess.scope', () {
      final receipts = [
        saleReceipt(
          uuid: 'a',
          staffId: 'me',
          departmentUuid: 'd1',
        ),
        saleReceipt(
          uuid: 'b',
          staffId: 'other',
          departmentUuid: 'd1',
        ),
        saleReceipt(
          uuid: 'c',
          staffId: 'me',
          departmentUuid: 'd2',
        ),
        saleReceipt(uuid: 'd', staffId: 'other'),
      ];
      for (final departmentsEnabled in [true, false]) {
        for (final canViewAllDepartments in [true, false]) {
          for (final current in [null, 'd1', 'd2']) {
            for (final canViewAll in [true, false]) {
              final fromReceipts =
                  ReceiptsReportAccess.scope(
                    receipts: receipts,
                    departmentsEnabled: departmentsEnabled,
                    canViewAllDepartments:
                        canViewAllDepartments,
                    currentDepartmentUuid: current,
                    canViewAllTransactions: canViewAll,
                    currentUserId: 'me',
                  ).map((r) => r.uuid).toList();
              expect(
                scope(
                  departmentsEnabled: departmentsEnabled,
                  canViewAllDepartments:
                      canViewAllDepartments,
                  currentDepartmentUuid: current,
                  canViewAllTransactions: canViewAll,
                ),
                fromReceipts,
                reason:
                    'departments $departmentsEnabled, all '
                    'departments $canViewAllDepartments, '
                    'current $current, all transactions '
                    '$canViewAll',
              );
            }
          }
        }
      }
    });
  });

  group('expense period', () {
    List<String?> inDay17(
      List<TempExpensesClass> expenses, {
      TimeOfDay closingTime = midnight,
    }) {
      return GeneralReportExpenses.inPeriod(
        expenses,
        day17,
        closingTime: closingTime,
      ).map((e) => e.uuid).toList();
    }

    test('midnight closing: the calendar day', () {
      expect(
        inDay17([
          expense(
            uuid: 'before',
            createdDate: DateTime(2026, 10, 16, 23, 59),
          ),
          expense(
            uuid: 'start',
            createdDate: DateTime(2026, 10, 17),
          ),
          expense(
            uuid: 'end',
            createdDate: DateTime(2026, 10, 17, 23, 59),
          ),
          expense(
            uuid: 'after',
            createdDate: DateTime(2026, 10, 18),
          ),
        ]),
        ['start', 'end'],
      );
    });

    test('4am closing: early morning belongs to the day before', () {
      expect(
        inDay17(
          [
            expense(
              uuid: 'prev-day',
              createdDate: DateTime(2026, 10, 17, 3, 59),
            ),
            expense(
              uuid: 'opening',
              createdDate: DateTime(2026, 10, 17, 4),
            ),
            expense(
              uuid: 'late-night',
              createdDate: DateTime(2026, 10, 18, 3, 59),
            ),
            expense(
              uuid: 'next-day',
              createdDate: DateTime(2026, 10, 18, 4),
            ),
          ],
          closingTime: four,
        ),
        ['opening', 'late-night'],
      );
    });

    test('UTC dates are placed by local time, as receipts', () {
      final local = DateTime(2026, 10, 17, 12);
      expect(
        inDay17([
          expense(uuid: 'utc', createdDate: local.toUtc()),
        ]),
        ['utc'],
      );
    });

    test('an expense without a created date is skipped', () {
      final expenses = [
        expense(uuid: 'dated', amount: 10),
        expense(uuid: 'undated', amount: 99, noDate: true),
      ];
      expect(inDay17(expenses), ['dated']);
      final allTime = GeneralReportExpenses.inPeriod(
        expenses,
        const ReceiptsReportPeriod.allTime(),
      );
      expect(allTime.map((e) => e.uuid), ['dated']);
      expect(GeneralReportExpenses.total(allTime), 10);
    });
  });

  group('previous period', () {
    void expectPeriod(
      ReceiptsReportPeriod? p,
      DateTime start,
      DateTime end,
    ) {
      expect(p, isNotNull);
      expect(p!.start, start);
      expect(p.end, end);
    }

    test('today compares with yesterday', () {
      final today = ReceiptsReportPeriod.today(
        now: DateTime(2026, 10, 17, 12),
        closingTime: midnight,
      );
      final prev = GeneralReportPeriods.previous(today);
      expectPeriod(
        prev,
        DateTime(2026, 10, 16),
        DateTime(2026, 10, 16),
      );
      expect(prev!.isSingleDay, isTrue);
    });

    test('a 7-day range compares with the 7 days before', () {
      expectPeriod(
        GeneralReportPeriods.previous(
          ReceiptsReportPeriod.range(
            DateTime(2026, 10, 11),
            DateTime(2026, 10, 17),
          ),
        ),
        DateTime(2026, 10, 4),
        DateTime(2026, 10, 10),
      );
    });

    test('crosses a month boundary', () {
      expectPeriod(
        GeneralReportPeriods.previous(
          ReceiptsReportPeriod.day(DateTime(2026, 3, 1)),
        ),
        DateTime(2026, 2, 28),
        DateTime(2026, 2, 28),
      );
      // 31 days back from March 2028 runs into a leap February.
      expectPeriod(
        GeneralReportPeriods.previous(
          ReceiptsReportPeriod.range(
            DateTime(2028, 3, 1),
            DateTime(2028, 3, 31),
          ),
        ),
        DateTime(2028, 1, 30),
        DateTime(2028, 2, 29),
      );
    });

    test('crosses a year boundary', () {
      expectPeriod(
        GeneralReportPeriods.previous(
          ReceiptsReportPeriod.range(
            DateTime(2026, 1, 1),
            DateTime(2026, 1, 31),
          ),
        ),
        DateTime(2025, 12, 1),
        DateTime(2025, 12, 31),
      );
      expectPeriod(
        GeneralReportPeriods.previous(
          ReceiptsReportPeriod.range(
            DateTime(2025, 12, 30),
            DateTime(2026, 1, 2),
          ),
        ),
        DateTime(2025, 12, 26),
        DateTime(2025, 12, 29),
      );
    });

    test('day count ignores daylight saving changes', () {
      // Clocks change in late October / late March in many zones.
      expect(
        GeneralReportPeriods.dayCount(
          ReceiptsReportPeriod.range(
            DateTime(2026, 10, 24),
            DateTime(2026, 10, 26),
          ),
        ),
        3,
      );
      expect(
        GeneralReportPeriods.dayCount(
          ReceiptsReportPeriod.range(
            DateTime(2026, 3, 28),
            DateTime(2026, 3, 30),
          ),
        ),
        3,
      );
    });

    test('all time has no previous period', () {
      expect(
        GeneralReportPeriods.previous(
          const ReceiptsReportPeriod.allTime(),
        ),
        isNull,
      );
    });
  });

  group('change', () {
    test('percent against a positive previous value', () {
      final up = GeneralReportChange.compare(
        current: 120,
        previous: 100,
      )!;
      expect(up.isPercent, isTrue);
      expect(up.value, closeTo(20, 1e-9));
      expect(up.isUp, isTrue);

      final down = GeneralReportChange.compare(
        current: 80,
        previous: 100,
      )!;
      expect(down.value, closeTo(-20, 1e-9));
      expect(down.isDown, isTrue);
    });

    test('amount when the previous value is 0', () {
      final c = GeneralReportChange.compare(
        current: 50,
        previous: 0,
      )!;
      expect(c.kind, GeneralReportChangeKind.amount);
      expect(c.value, 50);

      final tiny = GeneralReportChange.compare(
        current: 50,
        previous: 0.001,
      )!;
      expect(tiny.kind, GeneralReportChangeKind.amount);
    });

    test('profit: amount when the previous value is 0 or less', () {
      final fromLoss = GeneralReportChange.compare(
        current: 50,
        previous: -50,
        isProfit: true,
      )!;
      expect(fromLoss.kind, GeneralReportChangeKind.amount);
      expect(fromLoss.value, 100);

      final fromPositive = GeneralReportChange.compare(
        current: 50,
        previous: 100,
        isProfit: true,
      )!;
      expect(fromPositive.isPercent, isTrue);
      expect(fromPositive.value, closeTo(-50, 1e-9));
    });

    test('null without a previous or current value', () {
      expect(
        GeneralReportChange.compare(
          current: 1,
          previous: null,
        ),
        isNull,
      );
      expect(
        GeneralReportChange.compare(
          current: null,
          previous: 1,
        ),
        isNull,
      );
    });

    test('between two periods', () {
      final current = figuresFor();
      final previous = figuresFor(
        period: GeneralReportPeriods.previous(day17),
      );
      // The 16th: revenue 999, profit 998, purchases 75,
      // expenses 500, net 498.
      final c = GeneralReportChanges.between(current, previous);
      expect(c.revenue!.value, closeTo((720 - 999) / 999 * 100, 1e-9));
      expect(c.grossProfit!.value, closeTo((300 - 998) / 998 * 100, 1e-9));
      expect(c.purchases!.value, closeTo((350 - 75) / 75 * 100, 1e-9));
      expect(c.expenses!.value, closeTo((65 - 500) / 500 * 100, 1e-9));
      expect(c.netProfit!.value, closeTo((235 - 498) / 498 * 100, 1e-9));
    });

    test('between: none without a previous period', () {
      final c = GeneralReportChanges.between(figuresFor(), null);
      expect(c.revenue, isNull);
      expect(c.grossProfit, isNull);
      expect(c.purchases, isNull);
      expect(c.expenses, isNull);
      expect(c.netProfit, isNull);
    });

    test('between: profit changes hidden without the permission', () {
      final c = GeneralReportChanges.between(
        figuresFor(profitVisible: false),
        figuresFor(
          profitVisible: false,
          period: GeneralReportPeriods.previous(day17),
        ),
      );
      expect(c.revenue, isNotNull);
      expect(c.grossProfit, isNull);
      expect(c.netProfit, isNull);
    });
  });

  group('trend', () {
    /// The period's rows, as the page hands them to the builders.
    List<ReceiptsReportRow> periodRows(
      List<ReceiptsReportRow> rows,
      ReceiptsReportPeriod period,
      TimeOfDay closingTime,
    ) => ReceiptsReportQuery.filterAndSort(
      rows: rows,
      period: period,
      filters: ReceiptsReportFilters(),
      sortField: ReceiptsSortField.createdAt,
      ascending: false,
      departmentsEnabled: false,
      subStaffEnabled: false,
      profitVisible: true,
      closingTime: closingTime,
    );

    void expectParity(
      List<ReceiptsReportRow> rows,
      ReceiptsReportPeriod period, {
      TimeOfDay closingTime = midnight,
      DateTime? now,
    }) {
      final inPeriod = periodRows(rows, period, closingTime);
      final expected = ReceiptsTrendBuilder.build(
        rows: inPeriod,
        period: period,
        now: now,
        closingTime: closingTime,
      );
      final actual = GeneralReportTrendBuilder.build(
        receiptRows: inPeriod,
        expenses: const [],
        period: period,
        profitVisible: true,
        now: now,
        closingTime: closingTime,
      );
      expect(
        actual.points.map((p) => p.start),
        expected.map((p) => p.start),
      );
      expect(
        actual.points.map((p) => p.revenue),
        expected.map((p) => p.revenue),
      );
      expect(
        actual.points.map((p) => p.grossProfit),
        expected.map((p) => p.knownProfit),
      );
    }

    test('hourly buckets match the receipts trend', () {
      final rows = receiptRowsOf([
        saleReceipt(
          uuid: 'r-0000000000001',
          cash: 10,
          createdAt: DateTime(2026, 10, 17, 4, 10),
          items: [saleLine(revenue: 10, costPrice: 4)],
        ),
        saleReceipt(
          uuid: 'r-0000000000002',
          cash: 20,
          createdAt: DateTime(2026, 10, 17, 13, 5),
          items: [saleLine(revenue: 20, costPrice: 5)],
        ),
        saleReceipt(
          uuid: 'r-0000000000003',
          cash: 30,
          createdAt: DateTime(2026, 10, 18, 3, 30),
        ),
      ]);
      expectParity(rows, day17, closingTime: four);
      final trend = GeneralReportTrendBuilder.build(
        receiptRows: periodRows(rows, day17, four),
        expenses: [
          expense(
            amount: 7,
            createdDate: DateTime(2026, 10, 17, 13, 40),
          ),
        ],
        period: day17,
        profitVisible: true,
        closingTime: four,
      );
      expect(trend.interval, ReceiptsTrendInterval.hourly);
      expect(trend.points.length, 24);
      expect(trend.points[9].expenses, 7);
      expect(trend.points[9].netProfit, 15 - 7);
    });

    test('daily buckets match the receipts trend', () {
      final rows = receiptRowsOf([
        saleReceipt(
          uuid: 'r-0000000000001',
          cash: 5,
          createdAt: DateTime(2026, 10, 1, 9),
          items: [saleLine(revenue: 5, costPrice: 2)],
        ),
        saleReceipt(
          uuid: 'r-0000000000002',
          cash: 7,
          createdAt: DateTime(2026, 10, 3, 9),
        ),
      ]);
      final period = ReceiptsReportPeriod.range(
        DateTime(2026, 10, 1),
        DateTime(2026, 10, 4),
      );
      expectParity(rows, period);
    });

    test('weekly and monthly buckets match the receipts trend', () {
      final rows = receiptRowsOf([
        saleReceipt(
          uuid: 'r-0000000000001',
          cash: 1,
          createdAt: DateTime(2026, 10, 7, 9),
          items: [saleLine(revenue: 1, costPrice: 1)],
        ),
        saleReceipt(
          uuid: 'r-0000000000002',
          cash: 3,
          createdAt: DateTime(2026, 11, 19, 9),
          items: [saleLine(revenue: 3)],
        ),
      ]);
      expectParity(
        rows,
        ReceiptsReportPeriod.range(
          DateTime(2026, 10, 7),
          DateTime(2026, 11, 20),
        ),
      );
      expectParity(
        rows,
        ReceiptsReportPeriod.range(
          DateTime(2026, 1, 1),
          DateTime(2026, 12, 31),
        ),
      );
    });

    test('all time without expenses matches the receipts trend', () {
      expectParity(
        receiptRowsOf(sampleReceipts()),
        const ReceiptsReportPeriod.allTime(),
        now: DateTime(2026, 10, 20, 12),
      );
    });

    test('all time starts at an expense before the first receipt', () {
      final trend = GeneralReportTrendBuilder.build(
        receiptRows: receiptRowsOf([
          saleReceipt(
            cash: 10,
            createdAt: DateTime(2026, 10, 17, 12),
            items: [saleLine(revenue: 10, costPrice: 4)],
          ),
        ]),
        expenses: [
          expense(
            amount: 3,
            createdDate: DateTime(2026, 10, 10, 12),
          ),
          expense(uuid: 'undated', amount: 99, noDate: true),
        ],
        period: const ReceiptsReportPeriod.allTime(),
        profitVisible: true,
        now: DateTime(2026, 10, 17, 18),
        closingTime: midnight,
      );
      expect(trend.interval, ReceiptsTrendInterval.daily);
      expect(trend.points.length, 8);
      expect(trend.points.first.start, DateTime(2026, 10, 10));
      expect(trend.points.first.expenses, 3);
      expect(trend.points.first.netProfit, -3);
      expect(trend.points.last.revenue, 10);
      expect(trend.points.last.grossProfit, 6);
      expect(
        trend.points.fold<double>(0, (s, p) => s + p.expenses),
        3,
      );
    });

    test('empty all time has no buckets', () {
      final trend = GeneralReportTrendBuilder.build(
        receiptRows: const [],
        expenses: const [],
        period: const ReceiptsReportPeriod.allTime(),
        profitVisible: true,
      );
      expect(trend.interval, isNull);
      expect(trend.points, isEmpty);
    });

    test('profit values null without the cost permission', () {
      final f = figuresFor(profitVisible: false);
      final trend = GeneralReportTrendBuilder.build(
        receiptRows: f.receiptRows,
        expenses: f.expenses,
        period: day17,
        profitVisible: false,
        closingTime: midnight,
      );
      expect(trend.points, isNotEmpty);
      expect(
        trend.points.every(
          (p) => p.grossProfit == null && p.netProfit == null,
        ),
        isTrue,
      );
      expect(
        trend.points.fold<double>(0, (s, p) => s + p.revenue),
        720,
      );
      expect(
        trend.points.fold<double>(0, (s, p) => s + p.expenses),
        65,
      );
    });
  });
}
