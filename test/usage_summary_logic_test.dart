import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/pages/report/production_report/production_records_table/class/production_records_table_logic.dart';
import 'package:stockall/pages/report/production_report/usage_records_table/class/usage_records_table_logic.dart';
import 'package:stockall/pages/report/production_report/usage_summary/class/usage_summary_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_summary/class/receipts_report_summary_logic.dart';

import 'production_report_fixtures.dart';

const six = TimeOfDay(hour: 6, minute: 0);
final day2 = ReceiptsReportPeriod.day(DateTime(2026, 10, 2));

UsageSummaryResult usageSummary({
  List<UsageRecordRow>? rows,
  ReceiptsReportPeriod? period,
  bool departmentsEnabled = true,
  bool canSeeCost = true,
  bool canSeeQuantity = true,
}) => UsageSummaryBuilder.build(
  rows: rows ?? usageRows(sampleUsages()),
  period: period ?? day2,
  departmentsEnabled: departmentsEnabled,
  canSeeCost: canSeeCost,
  canSeeQuantity: canSeeQuantity,
  closingTime: six,
  now: DateTime(2026, 10, 4, 12),
);

/// The sample day, plus one ₦1,000 manual usage the day before.
final withYesterday = usageRows([
  ...sampleUsages(),
  usageRecord(
    uuid: 'usage-0',
    createdAt: oct(1, 10),
    quantity: 0.2,
    units: flourUnits(),
    totalCost: 1000,
    originalCostPerItem: 5000,
  ),
]);

List<UsageBreakdownRow> tabRows(UsageSummaryResult r, UsageBreakdownTab tab) =>
    UsageSummaryBuilder.breakdown(r, tab);

void main() {
  group('stats', () {
    test('the sample day: production vs manual', () {
      final s = usageSummary().stats;
      expect(s.records, 5);
      expect(s.cost, 12250);
      expect(s.productionRecords, 3);
      expect(s.productionCost, 10800);
      expect(s.manualRecords, 2);
      expect(s.manualCost, 1450);
      expect(s.distinctMaterials, 2);
      expect(s.distinctStaff, 2);
    });

    test("Alex's example: one production usage of 1 bag", () {
      final alex = AlexExample();
      final r = usageSummary(
        rows: usageRows([alex.usage], records: [alex.record]),
      );
      expect(r.stats.records, 1);
      expect(r.stats.productionRecords, 1);
      expect(r.stats.cost, AlexExample.bagCost);
      final flour = tabRows(r, UsageBreakdownTab.materials).single;
      expect(flour.quantity, 1);
      expect(flour.unit, 'Bag');
      expect(flour.unitCost, AlexExample.bagCost);
    });
  });

  group('previous period', () {
    test('Today compares with the day before', () {
      final r = usageSummary(rows: withYesterday);
      expect(r.previous!.records, 1);
      expect(r.changes.records!.isPercent, isTrue);
      expect(r.changes.records!.value, 400);
      expect(r.changes.cost!.value, closeTo((12250 - 1000) / 1000 * 100, 1e-9));
      // Nothing from productions yesterday: an amount, not a percentage.
      expect(r.changes.productionCost!.isPercent, isFalse);
      expect(r.changes.productionCost!.value, 10800);
      expect(r.changes.manualCost!.value, closeTo(45, 1e-9));
    });

    test('All time has no previous period and no changes', () {
      final r = usageSummary(
        rows: withYesterday,
        period: const ReceiptsReportPeriod.allTime(),
      );
      expect(r.previous, isNull);
      expect(r.changes.records, isNull);
      expect(r.stats.records, 6);
    });
  });

  group('cards', () {
    test('with cost: cost cards and the split in money', () {
      final r = usageSummary(rows: withYesterday);
      final cards = usageSummaryCards(r, canSeeCost: true);
      expect([for (final c in cards) c.id], [
        'cost',
        'records',
        'production',
        'manual',
        'materials',
      ]);
      final production = cards.firstWhere((c) => c.id == 'production');
      expect(production.value, 10800);
      expect(production.isMoney, isTrue);
      expect(production.subtitle, '3 from productions');
      expect(production.change, isNotNull);
    });

    test('without cost: the split in records', () {
      final cards = usageSummaryCards(usageSummary(), canSeeCost: false);
      expect([for (final c in cards) c.id], [
        'records',
        'production',
        'manual',
        'materials',
      ]);
      expect([for (final c in cards) c.value], [5, 3, 2, 2]);
      expect(cards.every((c) => !c.isMoney), isTrue);
    });
  });

  group('trend', () {
    test('one day: hourly from the closing time', () {
      final r = usageSummary();
      expect(r.interval, ReceiptsTrendInterval.hourly);
      expect(r.trend, hasLength(24));
      expect(r.trend.first.start, DateTime(2026, 10, 2, 6));
      // 10:00, 12:00, 14:00 and 16:00 are hours 4, 6, 8 and 10.
      expect(r.trend[4].productionCost, 5000);
      expect(r.trend[6].productionCost, 5800);
      expect(r.trend[6].productionRecords, 2);
      expect(r.trend[8].manualCost, 200);
      expect(r.trend[10].manualRecords, 1);
      expect(r.trend.fold<int>(0, (s, p) => s + p.records), 5);
    });

    test('a range: daily buckets, empty days included', () {
      final r = usageSummary(
        rows: withYesterday,
        period: ReceiptsReportPeriod.range(
          DateTime(2026, 10, 1),
          DateTime(2026, 10, 3),
        ),
      );
      expect(r.interval, ReceiptsTrendInterval.daily);
      expect([for (final p in r.trend) p.records], [1, 5, 0]);
      expect([for (final p in r.trend) p.manualCost], [1000, 1450, 0]);
    });
  });

  group('breakdowns', () {
    test('materials: records, quantity, cost and average unit cost', () {
      final rows = tabRows(usageSummary(), UsageBreakdownTab.materials);
      expect([for (final x in rows) x.label], ['Flour', 'Sugar']);
      final flour = rows.first;
      expect(flour.count, 3);
      expect(flour.quantity, 2.25);
      expect(flour.unit, 'Bag');
      expect(flour.cost, 11250);
      expect(flour.unitCost, 5000);
      expect(flour.lastDate, oct(2, 16));
      expect(flour.share, closeTo(11250 / 12250 * 100, 1e-9));
      expect(flour.filters.materialKey, 'flour');
      expect(flour.filters.activeCount, 1);
      expect(rows.last.unitCost, 400);
    });

    test('source: production and manual hand off the source', () {
      final rows = tabRows(usageSummary(), UsageBreakdownTab.source);
      expect([for (final x in rows) x.label], ['Production', 'Manual']);
      expect(rows.first.filters.source, UsageSource.production);
      expect(rows.last.filters.source, UsageSource.manual);
      expect(rows.last.cost, 1450);
      expect(rows.first.quantity, isNull);
    });

    test('staff and departments: none rows last, hand-off keys', () {
      final staff = tabRows(usageSummary(), UsageBreakdownTab.staff);
      expect(staff.first.label, 'Ben');
      expect(staff.last.label, productionNoStaffLabel);
      expect(staff.last.filters.staffKey, productionReportNoneKey);
      final depts = tabRows(usageSummary(), UsageBreakdownTab.departments);
      expect([for (final x in depts) x.label], [
        'Bakery',
        'Kitchen',
        productionNoDepartmentLabel,
      ]);
      expect(depts.first.filters.departmentKey, deptBakery);
    });

    test('without the cost permission the share is of the records', () {
      final flour = tabRows(
        usageSummary(canSeeCost: false),
        UsageBreakdownTab.materials,
      ).first;
      expect(flour.share, closeTo(3 / 5 * 100, 1e-9));
    });

    test('sorting keeps the none row last', () {
      for (final asc in [true, false]) {
        final rows = UsageSummaryBuilder.sortBreakdown(
          tabRows(usageSummary(), UsageBreakdownTab.staff),
          field: UsageBreakdownField.count,
          ascending: asc,
        );
        expect(rows.last.isNone, isTrue);
      }
    });
  });

  group('tabs and columns follow the settings', () {
    test('Departments only with departments on', () {
      expect(
        usageBreakdownTabs(departmentsEnabled: true),
        UsageBreakdownTab.values,
      );
      expect(usageBreakdownTabs(departmentsEnabled: false), [
        UsageBreakdownTab.materials,
        UsageBreakdownTab.source,
        UsageBreakdownTab.staff,
      ]);
      expect(usageSummary(departmentsEnabled: false).breakdowns.keys, [
        UsageBreakdownTab.materials,
        UsageBreakdownTab.source,
        UsageBreakdownTab.staff,
      ]);
    });

    test('cost and quantity columns', () {
      List<String> labels(UsageBreakdownTab tab, bool cost, bool qty) => [
        for (final c in usageBreakdownColumns(
          tab,
          canSeeCost: cost,
          canSeeQuantity: qty,
        ))
          c.label,
      ];
      expect(labels(UsageBreakdownTab.materials, true, true), [
        'Material',
        'Records',
        'Qty Used',
        'Cost',
        'Avg Unit Cost',
        'Last Used',
        'Share',
      ]);
      expect(labels(UsageBreakdownTab.materials, true, false), [
        'Material',
        'Records',
        'Cost',
        'Last Used',
        'Share',
      ]);
      expect(labels(UsageBreakdownTab.staff, false, true), [
        'Staff',
        'Records',
        'Last Used',
        'Share',
      ]);
    });
  });
}
