import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/pages/report/production_report/production_records_table/class/production_records_table_logic.dart';
import 'package:stockall/pages/report/production_report/shared/class/production_report_access.dart';
import 'package:stockall/pages/report/production_report/usage_records_table/class/usage_records_table_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

import 'production_report_fixtures.dart';

const six = TimeOfDay(hour: 6, minute: 0);
final day2 = ReceiptsReportPeriod.day(DateTime(2026, 10, 2));

/// The table's query: rows in [period] (default 2 Oct), filtered and
/// sorted, newest first.
List<UsageRecordRow> query(
  List<UsageRecordRow> rows, {
  UsageRecordsFilters? filters,
  ReceiptsReportPeriod? period,
  UsageRecordsSortField sortField = UsageRecordsSortField.createdAt,
  bool ascending = false,
  bool departmentsEnabled = true,
  bool canSeeCost = true,
  bool canSeeQuantity = true,
}) => UsageRecordsQuery.filterAndSort(
  rows: rows,
  period: period ?? day2,
  filters: filters ?? UsageRecordsFilters(),
  sortField: sortField,
  ascending: ascending,
  departmentsEnabled: departmentsEnabled,
  canSeeCost: canSeeCost,
  canSeeQuantity: canSeeQuantity,
  closingTime: six,
);

List<String> uuids(List<UsageRecordRow> rows) => [for (final r in rows) r.uuid];

UsageRecordRow rowOf(List<UsageRecordRow> rows, String uuid) =>
    rows.firstWhere((r) => r.uuid == uuid);

void main() {
  group('rows', () {
    test("Alex's example: one Production usage of 1 bag", () {
      final alex = AlexExample();
      final rows = usageRows([alex.usage], records: [alex.record]);
      final r = rows.single;
      expect(r.source, UsageSource.production);
      expect(r.materialName, 'Flour');
      expect(r.quantity, 1);
      expect(r.unitLabel, 'Bag');
      expect(r.primaryQty, 1);
      expect(r.primaryUnit, 'Bag');
      expect(r.cost, AlexExample.bagCost);
      expect(r.unitCost, AlexExample.bagCost);
      expect(r.productionOutputName, 'Donut');
      expect(r.productionId, '#prod-1');
      expect(r.productionLabel, 'Donut #prod-1');
      expect(r.displayId, '#usage-1');
      expect(r.managed, isTrue);
    });

    test('a production usage whose record is not loaded', () {
      final r = usageRows([AlexExample().usage], records: const []).single;
      expect(r.source, UsageSource.production);
      expect(r.productionOutputName, isNull);
      expect(r.productionLabel, 'Not loaded');
    });

    test('manual usages: no production; a missing flag is not managed', () {
      final rows = usageRows(sampleUsages());
      final manual = rowOf(rows, 'usage-4');
      expect(manual.source, UsageSource.manual);
      expect(manual.productionLabel, isNull);
      expect(manual.managed, isFalse);
      expect(manual.staffKey, isNull);
      expect(manual.departmentLabel, productionNoDepartmentLabel);
      final noFlag = usageRows([
        usageRecord(createdAt: oct(2), quantity: 1, isManaged: null),
      ]).single;
      expect(noFlag.managed, isFalse);
    });

    test('the unit cost is per primary unit', () {
      // 1 Kg of sugar costs ₦400; the usage stores the base-unit cost
      // (base = Kg here) and the primary unit is Kg.
      expect(rowOf(usageRows(sampleUsages()), 'usage-3').unitCost, 400);
      final grams = usageRows([
        usageRecord(
          createdAt: oct(2),
          materialUuid: 'sugar',
          materialName: 'Sugar',
          quantity: 500,
          unitUuid: 'sugar-g',
          units: [
            prodUnit('sugar-kg', 'Kg', conversion: 1000, productUuid: 'sugar'),
            prodUnit(
              'sugar-g',
              'g',
              isPrimary: false,
              productUuid: 'sugar',
            ),
          ],
          totalCost: 200,
          originalCostPerItem: 0.4,
        ),
      ]).single;
      expect(grams.primaryQty, closeTo(0.5, 1e-9));
      expect(grams.primaryUnit, 'Kg');
      expect(grams.unitCost, closeTo(400, 1e-9));
    });

    test('pending deletes and usages without a date are left out', () {
      final rows = UsageRecordRowBuilder.buildAll(
        usages: [
          ...sampleUsages(),
          usageRecord(uuid: 'no-date', createdAt: oct(2), quantity: 1)
            ..createdAt = null,
        ],
        pendingDeletedUuids: {'usage-2'},
      );
      expect(uuids(rows), isNot(contains('usage-2')));
      expect(uuids(rows), isNot(contains('no-date')));
      expect(rows, hasLength(4));
    });
  });

  test('scope: own records only without "view all transactions"', () {
    final scoped = ProductionReportAccess.scopeUsages(
      usages: sampleUsages(),
      departmentsEnabled: false,
      canViewAllDepartments: true,
      currentDepartmentUuid: null,
      canViewAllTransactions: false,
      currentUserId: staffBen,
    );
    expect([for (final u in scoped) u.uuid], ['usage-2', 'usage-3', 'usage-5']);
  });

  group('period', () {
    test('the day runs from the closing time (06:00)', () {
      final rows = usageRows([
        usageRecord(uuid: 'early-2', createdAt: oct(2, 3), quantity: 1),
        usageRecord(uuid: 'late-2', createdAt: oct(2, 7), quantity: 1),
        usageRecord(uuid: 'early-3', createdAt: oct(3, 3), quantity: 1),
      ]);
      // 03:00 on 2 Oct is still 1 Oct's business day.
      expect(uuids(query(rows)), ['early-3', 'late-2']);
    });

    test('All time takes every row', () {
      final rows = usageRows([
        ...sampleUsages(),
        usageRecord(uuid: 'old', createdAt: DateTime(2025, 1, 1), quantity: 1),
      ]);
      expect(
        query(rows, period: const ReceiptsReportPeriod.allTime()),
        hasLength(6),
      );
    });
  });

  group('filters', () {
    final rows = usageRows(sampleUsages());
    List<String> f(UsageRecordsFilters filters, {bool departments = true}) =>
        uuids(query(rows, filters: filters, departmentsEnabled: departments))
          ..sort();

    test('material, source and managed', () {
      expect(f(UsageRecordsFilters(materialKey: 'sugar')), ['usage-3', 'usage-4']);
      expect(f(UsageRecordsFilters(source: UsageSource.manual)), [
        'usage-4',
        'usage-5',
      ]);
      expect(f(UsageRecordsFilters(managed: false)), ['usage-4']);
      expect(
        f(UsageRecordsFilters(materialKey: 'flour', source: UsageSource.production)),
        ['usage-1', 'usage-2'],
      );
    });

    test('staff and department, with the none keys', () {
      expect(f(UsageRecordsFilters(staffKey: staffAda)), ['usage-1']);
      expect(f(UsageRecordsFilters(staffKey: productionReportNoneKey)), [
        'usage-4',
      ]);
      expect(f(UsageRecordsFilters(departmentKey: deptKitchen)), ['usage-5']);
      expect(f(UsageRecordsFilters(departmentKey: productionReportNoneKey)), [
        'usage-4',
      ]);
      // Departments off: the department filter is ignored.
      expect(
        f(UsageRecordsFilters(departmentKey: deptKitchen), departments: false),
        hasLength(5),
      );
    });

    test('search: material, staff, production output and ID', () {
      expect(f(UsageRecordsFilters(search: 'sug')), ['usage-3', 'usage-4']);
      expect(f(UsageRecordsFilters(search: 'ben')), [
        'usage-2',
        'usage-3',
        'usage-5',
      ]);
      expect(f(UsageRecordsFilters(search: 'donut')), [
        'usage-1',
        'usage-2',
        'usage-3',
      ]);
      expect(f(UsageRecordsFilters(search: '#usage-5')), ['usage-5']);
    });

    test('ranges, and the permissions that switch them off', () {
      final qty = UsageRecordsFilters(quantityMin: 1, quantityMax: 1);
      expect(f(qty), ['usage-1', 'usage-2']);
      expect(
        query(rows, filters: qty, canSeeQuantity: false),
        hasLength(5),
      );
      final cost = UsageRecordsFilters(costMin: 1000);
      expect(f(cost), ['usage-1', 'usage-2', 'usage-5']);
      expect(query(rows, filters: cost, canSeeCost: false), hasLength(5));
      // A reversed range is an error and doesn't filter.
      final bad = UsageRecordsFilters(costMin: 10, costMax: 1);
      expect(bad.costRangeError, isNotNull);
      expect(query(rows, filters: bad), hasLength(5));
    });

    test('activeCount and clearAll', () {
      final filters = UsageRecordsFilters(
        search: 'x',
        materialKey: 'flour',
        source: UsageSource.manual,
        managed: true,
        costMin: 1,
      );
      expect(filters.activeCount, 4);
      filters.clearAll();
      expect(filters.hasAnything, isFalse);
    });
  });

  group('sort', () {
    test('cost, largest first; ties newest first', () {
      final rows = usageRows(sampleUsages());
      expect(
        uuids(query(rows, sortField: UsageRecordsSortField.cost)),
        ['usage-2', 'usage-1', 'usage-5', 'usage-3', 'usage-4'],
      );
    });

    test('a missing unit cost sinks in both directions', () {
      final rows = usageRows([
        ...sampleUsages(),
        usageRecord(uuid: 'no-cost', createdAt: oct(2, 11), quantity: 1),
      ]);
      for (final asc in [true, false]) {
        expect(
          query(
            rows,
            sortField: UsageRecordsSortField.unitCost,
            ascending: asc,
          ).last.uuid,
          'no-cost',
        );
      }
    });
  });

  group('pages and totals', () {
    final rows = usageRows(manyUsages(150));
    final all = query(rows, period: const ReceiptsReportPeriod.allTime());

    test('totals cover every filtered row, not the page', () {
      final p2 = UsageRecordsQuery.paginate(all, 2);
      expect(p2.rows, hasLength(50));
      expect(p2.firstIndex, 101);
      expect(p2.lastIndex, 150);
      expect(p2.totalCount, 150);
      // Σ (100 + i), i = 1…150.
      expect(p2.totalCost, 100 * 150 + 150 * 151 / 2);
      expect(p2.totalQuantity, isNull);
    });

    test('quantity and unit cost only for one material', () {
      final p = UsageRecordsQuery.paginate(all, 1, singleMaterialKey: 'flour');
      expect(p.totalQuantity, 150 * 151 / 2);
      expect(p.quantityUnit, 'Bag');
      expect(p.averageUnitCost, closeTo(p.totalCost / p.totalQuantity!, 1e-9));
    });

    test('a page past the end is clamped', () {
      expect(UsageRecordsQuery.paginate(all, 9).page, 2);
    });
  });

  group('grouping', () {
    final rows = query(usageRows(sampleUsages()));

    test('by material: records, quantity, cost and unit cost', () {
      final groups = UsageGrouping.build(rows, UsageGroupBy.material);
      final flour = groups.firstWhere((g) => g.key == 'flour');
      expect(flour.count, 3);
      expect(flour.quantity, 2.25);
      expect(flour.unit, 'Bag');
      expect(flour.cost, 11250);
      expect(flour.unitCost, 5000);
      expect(flour.lastDate, oct(2, 16));
      final sugar = groups.firstWhere((g) => g.key == 'sugar');
      expect(sugar.quantity, 2.5);
      expect(sugar.unitCost, 400);
    });

    test('by source; no quantity outside material groups', () {
      final groups = UsageGrouping.build(rows, UsageGroupBy.source);
      final production = groups.firstWhere((g) => g.key == 'production');
      expect(production.label, 'Production');
      expect(production.count, 3);
      expect(production.cost, 10800);
      expect(production.quantity, isNull);
      expect(production.unitCost, isNull);
    });

    test('the none row stays last in both directions', () {
      for (final by in [UsageGroupBy.staff, UsageGroupBy.department]) {
        for (final asc in [true, false]) {
          final sorted = UsageGrouping.sort(
            UsageGrouping.build(rows, by),
            field: UsageGroupSortField.count,
            ascending: asc,
          );
          expect(sorted.last.isNone, isTrue, reason: '$by $asc');
          expect(sorted.last.label, by.noneLabel);
        }
      }
    });

    test('group totals', () {
      final page = UsageGrouping.paginate(
        UsageGrouping.build(rows, UsageGroupBy.staff),
        1,
      );
      expect(page.totalCount, 3);
      expect(page.totalRecords, 5);
      expect(page.totalCost, 12250);
    });

    test('Reset All keeps the grouping and the sort', () {
      final state = UsageRecordsTableState(
        filters: UsageRecordsFilters(staffKey: staffBen, search: 'x'),
        groupBy: UsageGroupBy.material,
        sortField: UsageRecordsSortField.cost,
        page: 3,
      );
      state.resetAll();
      expect(state.filters.hasAnything, isFalse);
      expect(state.groupBy, UsageGroupBy.material);
      expect(state.sortField, UsageRecordsSortField.cost);
      expect(state.page, 1);
    });
  });

  group('earlier productions without usage records', () {
    final records = [...sampleRecords(), legacyRecord()];
    final usages = usageRows(sampleUsages(), records: records);
    final records2 = recordRows(records);

    int count({ReceiptsReportPeriod? period, List<UsageRecordRow>? u}) =>
        legacyProductionsWithoutUsage(
          period: period ?? day2,
          recordRows: records2,
          usages: u ?? usages,
          closingTime: six,
        );

    test('only productions with materials and no linked usage', () {
      // prod-L counts; prod-1 and prod-2 have usages; prod-3 used no
      // materials.
      expect(count(), 1);
      final withoutAlex = usages.where((u) => u.uuid != 'usage-1').toList();
      expect(count(u: withoutAlex), 2);
    });

    test('the count follows the period', () {
      expect(count(period: ReceiptsReportPeriod.day(DateTime(2026, 10, 3))), 0);
      expect(count(period: const ReceiptsReportPeriod.allTime()), 1);
    });

    test('the notes', () {
      expect(
        usageRecordsNotes(
          period: day2,
          usages: usages,
          recordRows: records2,
          closingTime: six,
        ),
        [
          "1 earlier production has no usage records and isn't included. "
              'Their materials appear in the Production Records report.',
        ],
      );
      expect(
        usageRecordsNotes(
          period: const ReceiptsReportPeriod.allTime(),
          usages: usageRows(sampleUsages()),
          recordRows: recordRows(sampleRecords()),
        ),
        ['All time covers the usage records loaded on this device.'],
      );
    });
  });
}
