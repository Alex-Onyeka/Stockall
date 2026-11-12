import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/pages/report/production_report/production_records_table/class/production_records_export_spec.dart';
import 'package:stockall/pages/report/production_report/production_records_table/class/production_records_table_logic.dart';
import 'package:stockall/pages/report/production_report/shared/class/production_report_access.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

import 'production_report_fixtures.dart';

/// The table's query, with every permission and departments on unless
/// a test says otherwise.
List<ProductionRecordRow> query(
  List<ProductionRecordRow> rows, {
  ProductionRecordsFilters? filters,
  ReceiptsReportPeriod period = const ReceiptsReportPeriod.allTime(),
  ProductionRecordsSortField sortField = ProductionRecordsSortField.createdAt,
  bool ascending = false,
  bool departmentsEnabled = true,
  bool canSeeCost = true,
  bool canSeeQuantity = true,
  TimeOfDay? closingTime,
}) => ProductionRecordsQuery.filterAndSort(
  rows: rows,
  period: period,
  filters: filters ?? ProductionRecordsFilters(),
  sortField: sortField,
  ascending: ascending,
  departmentsEnabled: departmentsEnabled,
  canSeeCost: canSeeCost,
  canSeeQuantity: canSeeQuantity,
  closingTime: closingTime,
);

List<String> ids(List<ProductionRecordRow> rows) => [
  for (final r in rows) r.uuid,
];

ProductionRecordRow rowOf(String uuid) =>
    recordRows(sampleRecords()).firstWhere((r) => r.uuid == uuid);

void main() {
  final sample = recordRows(sampleRecords());

  group("Alex's example", () {
    test('1 record, 30 donuts, material cost = 1 bag, cost per donut', () {
      final rows = recordRows([AlexExample().record]);
      expect(rows, hasLength(1));
      final r = rows.single;
      expect(r.outputName, 'Donut');
      expect(r.outputType, ProductionOutputType.producedItem);
      expect(r.quantity, 30);
      expect(r.primaryQty, 30);
      expect(r.primaryUnit, 'Pcs');
      expect(r.materialCost, AlexExample.bagCost);
      expect(r.recordedCost, AlexExample.bagCost);
      expect(r.variance, 0);
      expect(r.costSource, ProductionCostSource.materials);
      expect(r.costPerUnit, closeTo(166.67, 0.01));
      expect(r.lines.single.name, 'Flour');
      expect(r.lines.single.quantity, 1);
      expect(r.lines.single.unit, 'Bag');
      expect(r.lines.single.cost, 5000);
    });
  });

  group('rows', () {
    test('material cost vs recorded cost vs variance', () {
      final r2 = rowOf('prod-2');
      expect(r2.materialCost, 5800);
      expect(r2.recordedCost, 7200);
      expect(r2.variance, 1400);
      expect(r2.costSource, ProductionCostSource.itemCost);

      final r3 = rowOf('prod-3');
      expect(r3.materialCost, 0);
      expect(r3.recordedCost, 1200);
      expect(r3.variance, 1200);
      expect(r3.costSource, ProductionCostSource.custom);
    });

    test('cost per unit is in the primary unit (boxes count as pieces)', () {
      final r = rowOf('prod-2');
      expect(r.quantity, 3);
      expect(r.unitLabel, 'Box');
      expect(r.primaryQty, 36);
      expect(r.primaryUnit, 'Pcs');
      expect(r.costPerUnit, 200);
      expect(productionRecordQuantityText(r, (v) => '$v'), '3.0 Box (36.0 Pcs)');
      expect(
        productionRecordQuantityText(rowOf('prod-1'), (v) => '$v'),
        '30.0 Pcs',
      );
    });

    test('a sales-item output with no materials and no staff', () {
      final r = rowOf('prod-3');
      expect(r.outputType, ProductionOutputType.salesItem);
      expect(r.outputKey, 'juice');
      expect(r.unitLabel, 'Litre');
      expect(r.primaryUnit, 'Litre');
      expect(r.lines, isEmpty);
      expect(r.materialsLabel, productionNoMaterialsLabel);
      expect(r.staffKey, isNull);
      expect(r.staffLabel, 'Not Set');
      expect(r.departmentLabel, productionNoDepartmentLabel);
    });

    test('legacy records: group fields and embedded materials only', () {
      final r =
          recordRows([
            productionRecord(
              uuid: 'legacy',
              createdAt: oct(1),
              quantity: 2,
              unitUuid: null,
              units: null,
              useGroupQuantity: true,
              qttyPerGroup: 12,
              groupUnit: 'Box',
              unit: 'Pcs',
              totalCost: 4800,
              selectedCostPriceOption: null,
              materials: [
                materialLine(
                  quantity: 1,
                  unitUuid: null,
                  units: null,
                  totalCost: 5000,
                ),
              ],
            ),
          ]).single;
      expect(r.unitLabel, 'Box');
      expect(r.primaryQty, 24);
      expect(r.primaryUnit, 'Pcs');
      expect(r.costPerUnit, 200);
      expect(r.materialCost, 5000);
      expect(r.variance, -200);
      expect(r.costSource, ProductionCostSource.unknown);
      expect(r.lines.single.quantity, 1);
      expect(r.lines.single.unit, 'Bag');
      expect(productionRecordQuantityText(r, (v) => '$v'), '2.0 Box (24.0 Pcs)');
    });

    test('display ids: digits of a long uuid, a short uuid as it is', () {
      final long = recordRows(manyRecords(1)).single;
      expect(long.displayId, '#000000000001');
      expect(rowOf('prod-1').displayId, '#prod-1');
    });

    test('records queued for deletion or without a date are left out', () {
      final rows = ProductionRecordRowBuilder.buildAll(
        records: [
          ...sampleRecords(),
          productionRecord(uuid: 'no-date', createdAt: oct(2), quantity: 1)
            ..createdAt = null,
        ],
        manageProductionItems: true,
        pendingDeletedUuids: {'prod-2'},
      );
      expect(ids(rows)..sort(), ['prod-1', 'prod-3']);
    });
  });

  group('period', () {
    test('a business day with a 6 AM closing time', () {
      final rows = recordRows([
        productionRecord(uuid: 'early', createdAt: oct(2, 5), quantity: 1),
        productionRecord(uuid: 'day', createdAt: oct(2, 10), quantity: 1),
        productionRecord(uuid: 'night', createdAt: oct(3, 3), quantity: 1),
        productionRecord(uuid: 'next', createdAt: oct(3, 7), quantity: 1),
      ]);
      final day = ReceiptsReportPeriod.day(DateTime(2026, 10, 2));
      const six = TimeOfDay(hour: 6, minute: 0);
      // 05:00 belongs to 1 Oct; 03:00 on 3 Oct still to 2 Oct.
      expect(ids(query(rows, period: day, closingTime: six)), [
        'night',
        'day',
      ]);
      expect(ids(query(rows)), ['next', 'night', 'day', 'early']);
    });

    test('a range covers every day in it', () {
      final rows = recordRows([
        productionRecord(uuid: 'a', createdAt: oct(1, 10), quantity: 1),
        productionRecord(uuid: 'b', createdAt: oct(3, 10), quantity: 1),
        productionRecord(uuid: 'c', createdAt: oct(5, 10), quantity: 1),
      ]);
      final range = ReceiptsReportPeriod.range(
        DateTime(2026, 10, 1),
        DateTime(2026, 10, 3),
      );
      const midnight = TimeOfDay(hour: 0, minute: 0);
      expect(ids(query(rows, period: range, closingTime: midnight)), [
        'b',
        'a',
      ]);
    });
  });

  group('filters', () {
    List<String> filtered(
      ProductionRecordsFilters f, {
      bool departmentsEnabled = true,
      bool canSeeCost = true,
      bool canSeeQuantity = true,
    }) =>
        ids(
          query(
            sample,
            filters: f,
            departmentsEnabled: departmentsEnabled,
            canSeeCost: canSeeCost,
            canSeeQuantity: canSeeQuantity,
          ),
        )..sort();

    test('output item, output type and their none key', () {
      expect(filtered(ProductionRecordsFilters(outputKey: 'donut')), [
        'prod-1',
        'prod-2',
      ]);
      expect(
        filtered(
          ProductionRecordsFilters(outputType: ProductionOutputType.salesItem),
        ),
        ['prod-3'],
      );
      final noOutput = recordRows([
        ...sampleRecords(),
        productionRecord(
          uuid: 'orphan',
          createdAt: oct(2, 16),
          itemUuid: null,
          quantity: 1,
        ),
      ]);
      expect(
        ids(
          query(
            noOutput,
            filters: ProductionRecordsFilters(outputKey: productionReportNoneKey),
          ),
        ),
        ['orphan'],
      );
    });

    test('material: any line uses it; none = no materials', () {
      expect(filtered(ProductionRecordsFilters(materialKey: 'flour')), [
        'prod-1',
        'prod-2',
      ]);
      expect(filtered(ProductionRecordsFilters(materialKey: 'sugar')), [
        'prod-2',
      ]);
      expect(
        filtered(ProductionRecordsFilters(materialKey: productionReportNoneKey)),
        ['prod-3'],
      );
    });

    test('staff and department, with their none keys', () {
      expect(filtered(ProductionRecordsFilters(staffKey: staffBen)), [
        'prod-2',
      ]);
      expect(
        filtered(ProductionRecordsFilters(staffKey: productionReportNoneKey)),
        ['prod-3'],
      );
      expect(
        filtered(
          ProductionRecordsFilters(departmentKey: productionReportNoneKey),
        ),
        ['prod-3'],
      );
      // Departments off: the department filter is ignored.
      expect(
        filtered(
          ProductionRecordsFilters(departmentKey: productionReportNoneKey),
          departmentsEnabled: false,
        ),
        ['prod-1', 'prod-2', 'prod-3'],
      );
    });

    test('cost source and cost range need the cost permission', () {
      final custom = ProductionRecordsFilters(
        costSource: ProductionCostSource.custom,
      );
      expect(filtered(custom), ['prod-3']);
      expect(filtered(custom, canSeeCost: false), [
        'prod-1',
        'prod-2',
        'prod-3',
      ]);
      final range = ProductionRecordsFilters(costMin: 5000, costMax: 6000);
      expect(filtered(range), ['prod-1']);
      expect(filtered(range, canSeeCost: false), hasLength(3));
    });

    test('quantity range (primary unit) needs the quantity permission', () {
      final range = ProductionRecordsFilters(quantityMin: 31);
      expect(filtered(range), ['prod-2']);
      expect(filtered(range, canSeeQuantity: false), hasLength(3));
    });

    test('an invalid range is not applied', () {
      final f = ProductionRecordsFilters(costMin: 9000, costMax: 10);
      expect(f.costRangeError, isNotNull);
      expect(f.costRangeActive, isFalse);
      expect(filtered(f), hasLength(3));
    });

    test('search covers output, staff, materials, comment and ID', () {
      expect(filtered(ProductionRecordsFilters(search: 'juice')), ['prod-3']);
      expect(filtered(ProductionRecordsFilters(search: 'sugar')), ['prod-2']);
      expect(filtered(ProductionRecordsFilters(search: 'BIG ORDER')), [
        'prod-2',
      ]);
      expect(filtered(ProductionRecordsFilters(search: 'ben')), ['prod-2']);
      expect(filtered(ProductionRecordsFilters(search: '#prod-1')), [
        'prod-1',
      ]);
    });

    test('options come from the rows, none last', () {
      final materials = ProductionRecordsOptions.materials(sample);
      expect([for (final o in materials) o.label], [
        'Flour',
        'Sugar',
        productionNoMaterialsLabel,
      ]);
      final staff = ProductionRecordsOptions.staff(sample);
      expect(staff.last.key, productionReportNoneKey);
      expect([for (final o in ProductionRecordsOptions.outputs(sample)) o.key], [
        'donut',
        'juice',
      ]);
    });
  });

  group('sort', () {
    test('by cost per unit; unknown values sink in both directions', () {
      final rows = recordRows([
        ...sampleRecords(),
        productionRecord(
          uuid: 'zero',
          createdAt: oct(2, 18),
          quantity: 0,
          totalCost: 10,
        ),
      ]);
      for (final asc in [true, false]) {
        final out = ids(
          query(
            rows,
            sortField: ProductionRecordsSortField.costPerUnit,
            ascending: asc,
          ),
        );
        expect(out.last, 'zero');
      }
      expect(
        ids(
          query(
            rows,
            sortField: ProductionRecordsSortField.costPerUnit,
            ascending: true,
          ),
        ).take(3),
        ['prod-3', 'prod-1', 'prod-2'],
      );
    });
  });

  group('pages and totals', () {
    test('totals cover the full filtered set, not the page', () {
      final rows = query(recordRows(manyRecords(150)));
      final p1 = ProductionRecordsQuery.paginate(rows, 1);
      final p2 = ProductionRecordsQuery.paginate(rows, 2);
      expect(p1.rows, hasLength(productionRecordsPageSize));
      expect(p2.rows, hasLength(50));
      expect(p2.firstIndex, 101);
      expect(p2.lastIndex, 150);
      final recorded = [
        for (var i = 1; i <= 150; i++) 100.0 + i,
      ].fold<double>(0, (a, b) => a + b);
      for (final p in [p1, p2]) {
        expect(p.totalCount, 150);
        expect(p.totalRecordedCost, recorded);
        expect(p.totalMaterialCost, 150 * 50);
        expect(p.totalVariance, recorded - 150 * 50);
      }
      // A page past the end is clamped.
      expect(ProductionRecordsQuery.paginate(rows, 9).page, 2);
    });

    test('quantity is totalled only for one selected output item', () {
      final all = ProductionRecordsQuery.paginate(query(sample), 1);
      expect(all.totalQuantity, isNull);
      expect(all.totalCostPerUnit, isNull);
      expect(all.totalMaterialCost, 10800);
      expect(all.totalRecordedCost, 13400);
      expect(all.totalVariance, 2600);

      final f = ProductionRecordsFilters(outputKey: 'donut');
      final donuts = ProductionRecordsQuery.paginate(
        query(sample, filters: f),
        1,
        singleOutputKey: f.singleOutputKey,
      );
      expect(donuts.totalQuantity, 66);
      expect(donuts.quantityUnit, 'Pcs');
      expect(donuts.totalCostPerUnit, closeTo(12200 / 66, 0.0001));

      expect(
        ProductionRecordsFilters(outputKey: productionReportNoneKey)
            .singleOutputKey,
        isNull,
      );
    });
  });

  group('grouping', () {
    List<ProductionGroupRow> grouped(
      ProductionGroupBy by, {
      ProductionGroupSortField field = ProductionGroupSortField.count,
      bool ascending = false,
    }) => ProductionGrouping.sort(
      ProductionGrouping.build(query(sample), by),
      field: field,
      ascending: ascending,
    );

    test('by staff: the none row is last in both directions', () {
      for (final asc in [true, false]) {
        final g = grouped(
          ProductionGroupBy.staff,
          field: ProductionGroupSortField.name,
          ascending: asc,
        );
        expect(g.last.isNone, isTrue);
        expect(g.last.label, productionNoStaffLabel);
      }
      final g = grouped(
        ProductionGroupBy.staff,
        field: ProductionGroupSortField.name,
        ascending: true,
      );
      expect([for (final x in g) x.label], ['Ada', 'Ben', 'No staff']);
    });

    test('by output item: quantity in the primary unit and cost per unit', () {
      final g = grouped(ProductionGroupBy.outputItem);
      final donut = g.firstWhere((x) => x.key == 'donut');
      expect(donut.count, 2);
      expect(donut.quantity, 66);
      expect(donut.unit, 'Pcs');
      expect(donut.recordedCost, 12200);
      expect(donut.materialCost, 10800);
      expect(donut.variance, 1400);
      expect(donut.costPerUnit, closeTo(12200 / 66, 0.0001));
      final juice = g.firstWhere((x) => x.key == 'juice');
      expect(juice.quantity, 10);
      expect(juice.unit, 'Litre');
    });

    test('by material: each material once per record; totals not doubled', () {
      final g = grouped(ProductionGroupBy.material);
      final flour = g.firstWhere((x) => x.key == 'flour');
      expect(flour.count, 2);
      expect(flour.quantity, 2);
      expect(flour.unit, 'Bag');
      expect(flour.materialCost, 10000);
      expect(flour.recordedCost, isNull);
      final sugar = g.firstWhere((x) => x.key == 'sugar');
      expect(sugar.count, 1);
      expect(sugar.quantity, 2);
      expect(sugar.unit, 'Kg');
      expect(g.last.label, productionNoMaterialsLabel);
      expect(g.last.count, 1);

      final page = ProductionGrouping.paginate(g, 1, recordCount: 3);
      // 2 + 1 + 1 group counts, but 3 records.
      expect(page.totalRecords, 3);
      expect(page.totalMaterialCost, 10800);
      expect(page.totalRecordedCost, isNull);
      expect(page.totalVariance, isNull);
    });

    test('Reset All clears filters and keeps grouping and sorting', () {
      final state = ProductionRecordsTableState(
        filters: ProductionRecordsFilters(search: 'x', staffKey: staffAda),
        groupBy: ProductionGroupBy.material,
        sortField: ProductionRecordsSortField.recordedCost,
        page: 3,
      );
      state.resetAll();
      expect(state.filters.hasAnything, isFalse);
      expect(state.groupBy, ProductionGroupBy.material);
      expect(state.sortField, ProductionRecordsSortField.recordedCost);
      expect(state.page, 1);
    });
  });

  group('notes', () {
    test('All time and custom-cost notes, the latter with the cost '
        'permission only', () {
      expect(
        productionRecordsNotes(
          period: const ReceiptsReportPeriod.allTime(),
          rows: sample,
          canSeeCost: true,
        ),
        [
          'All time covers the production records loaded on this device.',
          '1 record uses a custom cost; Variance shows the difference '
              'from the materials.',
        ],
      );
      expect(
        productionRecordsNotes(
          period: ReceiptsReportPeriod.day(DateTime(2026, 10, 2)),
          rows: sample,
          canSeeCost: false,
        ),
        isEmpty,
      );
    });
  });
}
