import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/pages/report/general_report/class/general_report_logic.dart';
import 'package:stockall/pages/report/production_report/production_records_table/class/production_records_table_logic.dart';
import 'package:stockall/pages/report/production_report/production_summary/class/production_summary_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_summary/class/receipts_report_summary_logic.dart';

import 'production_report_fixtures.dart';

const six = TimeOfDay(hour: 6, minute: 0);
final day2 = ReceiptsReportPeriod.day(DateTime(2026, 10, 2));

ProductionSummaryResult summary({
  List<ProductionRecordRow>? rows,
  ReceiptsReportPeriod? period,
  bool departmentsEnabled = true,
  bool canSeeCost = true,
  bool canSeeQuantity = true,
}) => ProductionSummaryBuilder.build(
  rows: rows ?? recordRows(sampleRecords()),
  period: period ?? day2,
  departmentsEnabled: departmentsEnabled,
  canSeeCost: canSeeCost,
  canSeeQuantity: canSeeQuantity,
  closingTime: six,
  now: DateTime(2026, 10, 4, 12),
);

ProductionBreakdownRow rowOf(
  ProductionSummaryResult r,
  ProductionBreakdownTab tab,
  String key,
) => ProductionSummaryBuilder.breakdown(r, tab).firstWhere((x) => x.key == key);

void main() {
  group('stats', () {
    test('the sample day', () {
      final s = summary().stats;
      expect(s.runs, 3);
      expect(s.recordedCost, 13400);
      expect(s.materialCost, 10800);
      expect(s.variance, 2600);
      expect(s.averageCostPerRun, closeTo(13400 / 3, 0.001));
      expect(s.distinctOutputs, 2);
      expect(s.distinctMaterials, 2);
      expect(s.distinctStaff, 2);
      expect(s.customCostCount, 1);
    });

    test("Alex's example: 1 run, 1 item, 1 material", () {
      final s = summary(rows: recordRows([AlexExample().record])).stats;
      expect(s.runs, 1);
      expect(s.recordedCost, 5000);
      expect(s.materialCost, 5000);
      expect(s.variance, 0);
      expect(s.distinctOutputs, 1);
      expect(s.distinctMaterials, 1);
    });
  });

  group('previous period', () {
    final withYesterday = recordRows([
      ...sampleRecords(),
      productionRecord(
        uuid: 'prod-0',
        createdAt: oct(1, 10),
        quantity: 20,
        units: donutUnits(),
        totalCost: 4000,
      ),
    ]);

    test('Today compares with the day before', () {
      final r = summary(rows: withYesterday);
      expect(r.previous!.runs, 1);
      expect(r.changes.runs!.isPercent, isTrue);
      expect(r.changes.runs!.value, 200);
      expect(r.changes.recordedCost!.value, closeTo((13400 - 4000) / 4000 * 100, 1e-9));
      expect(r.changes.materialCost!.isPercent, isFalse);
      expect(r.changes.materialCost!.value, 10800);
      expect(r.changes.distinctOutputs!.value, 100);
    });

    test('All time has no previous period and no changes', () {
      final r = summary(
        rows: withYesterday,
        period: const ReceiptsReportPeriod.allTime(),
      );
      expect(r.previous, isNull);
      expect(r.changes.runs, isNull);
      expect(r.changes.recordedCost, isNull);
      expect(r.stats.runs, 4);
    });

    test('the cards carry the changes; cost cards need the permission', () {
      final r = summary(rows: withYesterday);
      final cards = productionSummaryCards(r, canSeeCost: true);
      expect([for (final c in cards) c.id], [
        'runs',
        'recordedCost',
        'materialCost',
        'averageCost',
        'variance',
        'outputs',
        'materials',
        'staff',
      ]);
      expect(cards.first.change, isA<GeneralReportChange>());
      expect(
        [for (final c in productionSummaryCards(r, canSeeCost: false)) c.id],
        ['runs', 'outputs', 'materials', 'staff'],
      );
    });
  });

  group('trend', () {
    test('one day: hourly from the closing time', () {
      final r = summary();
      expect(r.interval, ReceiptsTrendInterval.hourly);
      expect(r.trend, hasLength(24));
      expect(r.trend.first.start, DateTime(2026, 10, 2, 6));
      // 10:00, 12:00 and 15:00 are hours 4, 6 and 9 after 06:00.
      expect(r.trend[4].runs, 1);
      expect(r.trend[4].recordedCost, 5000);
      expect(r.trend[6].materialCost, 5800);
      expect(r.trend[9].recordedCost, 1200);
      expect(r.trend.fold<int>(0, (s, p) => s + p.runs), 3);
    });

    test('a range: daily buckets, empty days included', () {
      final r = summary(
        period: ReceiptsReportPeriod.range(
          DateTime(2026, 10, 1),
          DateTime(2026, 10, 3),
        ),
      );
      expect(r.interval, ReceiptsTrendInterval.daily);
      expect([for (final p in r.trend) p.runs], [0, 3, 0]);
    });

    test('all time without records has no chart', () {
      final r = summary(rows: const [], period: const ReceiptsReportPeriod.allTime());
      expect(r.trend, isEmpty);
      expect(r.interval, isNull);
    });
  });

  group('breakdowns', () {
    test('output items: runs, quantity, cost per unit with min and max', () {
      final r = summary();
      final rows = ProductionSummaryBuilder.breakdown(
        r,
        ProductionBreakdownTab.outputItems,
      );
      expect(rows.first.key, 'donut');
      final donut = rows.first;
      expect(donut.count, 2);
      expect(donut.quantity, 66);
      expect(donut.unit, 'Pcs');
      expect(donut.recordedCost, 12200);
      expect(donut.materialCost, 10800);
      expect(donut.costPerUnit, closeTo(12200 / 66, 1e-9));
      expect(donut.minCostPerUnit, closeTo(5000 / 30, 1e-9));
      expect(donut.maxCostPerUnit, 200);
      expect(donut.lastDate, oct(2, 12));
      expect(donut.share, closeTo(12200 / 13400 * 100, 1e-9));
      expect(donut.filters.outputKey, 'donut');
      expect(donut.filters.activeCount, 1);
    });

    test('materials: productions using each, quantity and cost; none last', () {
      final r = summary();
      final rows = ProductionSummaryBuilder.breakdown(
        r,
        ProductionBreakdownTab.materials,
      );
      expect([for (final x in rows) x.label], ['Flour', 'Sugar', 'No materials']);
      final flour = rows.first;
      expect(flour.count, 2);
      expect(flour.quantity, 2);
      expect(flour.unit, 'Bag');
      expect(flour.materialCost, 10000);
      expect(flour.share, closeTo(10000 / 10800 * 100, 1e-9));
      expect(rows.last.isNone, isTrue);
      expect(rows.last.count, 1);
      expect(rows.last.filters.materialKey, productionReportNoneKey);
    });

    test("yield: Alex's 1 bag for 30 donuts is 0.0333 bag a donut", () {
      final alex = summary(rows: recordRows([AlexExample().record]));
      final y = ProductionSummaryBuilder.breakdown(
        alex,
        ProductionBreakdownTab.yield,
      ).single;
      expect(y.label, 'Donut');
      expect(y.sublabel, 'Flour');
      expect(y.quantity, 30);
      expect(y.materialQuantity, 1);
      expect(y.ratio, closeTo(1 / 30, 1e-12));
      expect(productionRatioText(y.ratio!, (v) => '$v'), '0.0333');
      expect(y.unitOf(ProductionBreakdownField.ratio), 'Bag / Pcs');
      expect(y.costPerUnit, closeTo(5000 / 30, 1e-9));
      expect(y.filters.outputKey, 'donut');
      expect(y.filters.materialKey, 'flour');
    });

    test('yield over two runs uses only the runs with that material', () {
      final r = summary();
      final flour = rowOf(r, ProductionBreakdownTab.yield, 'donut|flour');
      expect(flour.count, 2);
      expect(flour.quantity, 66);
      expect(flour.materialQuantity, 2);
      expect(flour.ratio, closeTo(2 / 66, 1e-12));
      final sugar = rowOf(r, ProductionBreakdownTab.yield, 'donut|sugar');
      expect(sugar.count, 1);
      expect(sugar.quantity, 36);
      expect(sugar.ratio, closeTo(2 / 36, 1e-12));
      // No yield for juice: it used no materials.
      expect(
        ProductionSummaryBuilder.breakdown(r, ProductionBreakdownTab.yield)
            .any((x) => x.label == 'Juice'),
        isFalse,
      );
    });

    test('staff and departments: none rows last, hand-off keys', () {
      final r = summary();
      final staff = ProductionSummaryBuilder.breakdown(
        r,
        ProductionBreakdownTab.staff,
      );
      expect(staff.last.label, productionNoStaffLabel);
      expect(staff.last.filters.staffKey, productionReportNoneKey);
      final ben = staff.firstWhere((x) => x.key == staffBen);
      expect(ben.variance, 1400);
      final depts = ProductionSummaryBuilder.breakdown(
        r,
        ProductionBreakdownTab.departments,
      );
      expect(depts.first.key, deptBakery);
      expect(depts.first.filters.departmentKey, deptBakery);
      expect(depts.last.label, productionNoDepartmentLabel);
    });

    test('without the cost permission the share is of the runs', () {
      final r = summary(canSeeCost: false);
      final donut = rowOf(r, ProductionBreakdownTab.outputItems, 'donut');
      expect(donut.share, closeTo(2 / 3 * 100, 1e-9));
    });

    test('sorting keeps the none row last', () {
      final r = summary();
      for (final asc in [true, false]) {
        final rows = ProductionSummaryBuilder.sortBreakdown(
          ProductionSummaryBuilder.breakdown(r, ProductionBreakdownTab.staff),
          field: ProductionBreakdownField.count,
          ascending: asc,
        );
        expect(rows.last.isNone, isTrue);
      }
    });
  });

  group('tabs and columns follow the permissions', () {
    test('Departments only with departments; Yield only with quantity', () {
      expect(
        productionBreakdownTabs(departmentsEnabled: true, canSeeQuantity: true),
        ProductionBreakdownTab.values,
      );
      expect(
        productionBreakdownTabs(departmentsEnabled: false, canSeeQuantity: false),
        [
          ProductionBreakdownTab.outputItems,
          ProductionBreakdownTab.materials,
          ProductionBreakdownTab.staff,
        ],
      );
      expect(summary(canSeeQuantity: false, departmentsEnabled: false).breakdowns.keys, [
        ProductionBreakdownTab.outputItems,
        ProductionBreakdownTab.materials,
        ProductionBreakdownTab.staff,
      ]);
    });

    test('cost and quantity columns', () {
      List<String> labels(bool cost, bool qty) => [
        for (final c in productionBreakdownColumns(
          ProductionBreakdownTab.outputItems,
          canSeeCost: cost,
          canSeeQuantity: qty,
        ))
          c.label,
      ];
      expect(labels(true, true), [
        'Output Item',
        'Runs',
        'Qty Produced',
        'Recorded Cost',
        'Material Cost',
        'Avg Cost / Unit',
        'Min / Unit',
        'Max / Unit',
        'Last Production',
        'Share',
      ]);
      expect(labels(false, false), [
        'Output Item',
        'Runs',
        'Last Production',
        'Share',
      ]);
      expect(labels(true, false), contains('Recorded Cost'));
      expect(labels(true, false), isNot(contains('Avg Cost / Unit')));
    });
  });

  test('ratio text keeps small yields readable', () {
    String n(num v) => v.toStringAsFixed(3);
    expect(productionRatioText(1 / 300, n), '0.00333');
    expect(productionRatioText(2.5, n), '2.500');
    expect(productionRatioText(0, n), '0.000');
  });
}
