// Alex's example end to end, across the four elements, from one set of
// fixtures: 2 bags of flour, 1 used to make 30 donuts, 15 donuts moved
// to sales. Each page's rows go through its own query and its export,
// as the screen builds them.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/pages/report/components/export/report_export_resolve.dart';
import 'package:stockall/pages/report/production_report/production_records_table/class/production_records_export_spec.dart';
import 'package:stockall/pages/report/production_report/production_records_table/class/production_records_table_logic.dart';
import 'package:stockall/pages/report/production_report/production_records_table/components/production_records_filter_widgets.dart';
import 'package:stockall/pages/report/production_report/shared/class/production_report_access.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/material_usage_logic.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/production_stock_model.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/stock_history_summary_export_spec.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/stock_history_summary_logic.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/stock_items_export_spec.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/stock_items_logic.dart';
import 'package:stockall/pages/report/production_report/usage_records_table/class/usage_records_export_spec.dart';
import 'package:stockall/pages/report/production_report/usage_records_table/class/usage_records_table_logic.dart';
import 'package:stockall/pages/report/production_report/usage_records_table/components/usage_records_filter_widgets.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

import 'item_history_export_fixtures.dart' show testCtx;
import 'production_report_fixtures.dart';

const six = TimeOfDay(hour: 6, minute: 0);
final day2 = ReceiptsReportPeriod.day(DateTime(2026, 10, 2));

void main() {
  final alex = AlexExample();

  // ---------------------------------------------------------------
  // P1: Production Records Table
  // ---------------------------------------------------------------
  final p1Rows = ProductionRecordsQuery.filterAndSort(
    rows: recordRows([alex.record]),
    period: day2,
    filters: ProductionRecordsFilters(),
    sortField: ProductionRecordsSortField.createdAt,
    ascending: false,
    departmentsEnabled: true,
    canSeeCost: true,
    canSeeQuantity: true,
    closingTime: six,
  );
  final p1Page = ProductionRecordsQuery.paginate(p1Rows, 1);

  // ---------------------------------------------------------------
  // U1: Usage Records Table
  // ---------------------------------------------------------------
  final u1Rows = UsageRecordsQuery.filterAndSort(
    rows: usageRows([alex.usage], records: [alex.record]),
    period: day2,
    filters: UsageRecordsFilters(),
    sortField: UsageRecordsSortField.createdAt,
    ascending: false,
    departmentsEnabled: true,
    canSeeCost: true,
    canSeeQuantity: true,
    closingTime: six,
  );
  final u1Page = UsageRecordsQuery.paginate(u1Rows, 1);

  // ---------------------------------------------------------------
  // I1 / I4: Produced Items Table and History Summary
  // ---------------------------------------------------------------
  final donutItems = stockItems([alex.donut]);
  final donutEntries = stockEntries(alex.donutHistory);
  final i1Rows = ProductionStockQuery.filterAndSort(
    rows: ProductionStockRowBuilder.buildAll(
      items: donutItems,
      entries: donutEntries,
      categoryNames: sampleCategories(),
      period: day2,
      businessNow: stockNow,
      historyAllowed: true,
      closingTime: six,
    ),
    filters: ProductionStockFilters(),
    sort: ProductionStockSort.byName,
    departmentsEnabled: true,
    canSeeCost: true,
    canSeeQuantity: true,
  );
  final i4Rows = ProductionHistorySummaryBuilder.build(
    kind: ProductionStockKind.producedItem,
    items: donutItems,
    entries: donutEntries,
    categoryNames: sampleCategories(),
    period: day2,
    closingTime: six,
  );

  // ---------------------------------------------------------------
  // M1 / M4: Materials Table and Material History Summary
  // ---------------------------------------------------------------
  final flourItems = materialItems([alex.flour]);
  final flourEntries = materialEntries(alex.flourHistory);
  final m1Rows = ProductionStockQuery.filterAndSort(
    rows: ProductionStockRowBuilder.buildAll(
      items: flourItems,
      entries: flourEntries,
      categoryNames: sampleCategories(),
      period: day2,
      businessNow: stockNow,
      historyAllowed: true,
      closingTime: six,
      usageByItem: ProductionMaterialUsageBuilder.build(
        records: recordRows([alex.record]),
        usages: usageRows([alex.usage], records: [alex.record]),
        period: day2,
        items: {for (final i in flourItems) i.uuid: i},
        closingTime: six,
      ),
    ),
    filters: ProductionStockFilters(),
    sort: ProductionStockSort.byName,
    departmentsEnabled: true,
    canSeeCost: true,
    canSeeQuantity: true,
  );
  final m4Rows = ProductionHistorySummaryBuilder.build(
    kind: ProductionStockKind.material,
    items: flourItems,
    entries: flourEntries,
    categoryNames: sampleCategories(),
    period: day2,
    closingTime: six,
  );

  group('P1: 1 record, 30 donuts, ₦5,000, ₦166.67 per donut', () {
    test('on screen', () {
      final r = p1Rows.single;
      expect(r.outputName, 'Donut');
      expect(r.quantity, 30);
      expect(r.primaryQty, 30);
      expect(r.primaryUnit, 'Pcs');
      expect(r.materialCost, 5000);
      expect(r.recordedCost, 5000);
      expect(r.variance, 0);
      expect(r.costSource, ProductionCostSource.materials);
      expect(r.costPerUnit, closeTo(166.67, 0.005));
      expect(p1Page.totalCount, 1);
      expect(p1Page.totalMaterialCost, 5000);
      expect(p1Page.totalRecordedCost, 5000);
    });

    test('in the export', () {
      final t = resolveExport(
        productionRecordsExportSpec(
          rows: p1Rows,
          groups: const [],
          periodRows: p1Rows,
          state: ProductionRecordsTableState(),
          choices: ProductionRecordsFilterChoices.fromRows(p1Rows),
          period: day2,
          currency: '₦',
          departmentsEnabled: true,
          canSeeCost: true,
          canSeeQuantity: true,
        ),
        testCtx,
      ).tables.first;
      final row = t.rows.single;
      expect(row[t.indexOf('output')].text, 'Donut');
      expect(row[t.indexOf('quantity')].text, contains('30'));
      expect(row[t.indexOf('recordedCost')].raw, 5000);
      expect(row[t.indexOf('costPerUnit')].text, contains('166.67'));
      expect(t.totals![t.indexOf('recordedCost')].raw, 5000);
    });
  });

  group('U1: one Production usage of 1 bag', () {
    test('on screen', () {
      final r = u1Rows.single;
      expect(r.source, UsageSource.production);
      expect(r.materialName, 'Flour');
      expect(r.quantity, 1);
      expect(r.unitLabel, 'Bag');
      expect(r.cost, 5000);
      expect(r.productionLabel, 'Donut #prod-1');
      expect(u1Page.totalCount, 1);
      expect(u1Page.totalCost, 5000);
    });

    test('in the export', () {
      final t = resolveExport(
        usageRecordsExportSpec(
          rows: u1Rows,
          groups: const [],
          allUsages: u1Rows,
          recordRows: recordRows([alex.record]),
          state: UsageRecordsTableState(),
          choices: UsageRecordsFilterChoices.fromRows(u1Rows),
          period: day2,
          currency: '₦',
          departmentsEnabled: true,
          canSeeCost: true,
          canSeeQuantity: true,
        ),
        testCtx,
      ).tables.first;
      final row = t.rows.single;
      expect(row[t.indexOf('material')].text, 'Flour');
      expect(row[t.indexOf('source')].text, 'Production');
      expect(row[t.indexOf('quantity')].text, contains('1 Bag'));
      expect(row[t.indexOf('cost')].raw, 5000);
    });
  });

  group('I1 / I4: donuts 0 → +30 → −15 → 15', () {
    test('the table row', () {
      final d = i1Rows.single;
      expect(d.balance.opening, 0);
      expect(d.movement.of(ProductionMovementKind.produced), 30);
      expect(d.movement.of(ProductionMovementKind.transferredToSales), 15);
      expect(d.movement.net, 15);
      expect(d.balance.closing, 15);
      expect(d.quantity, 15);
    });

    test('the history summary row', () {
      final d = i4Rows.single;
      expect(d.balance.opening, 0);
      expect(d.of(ProductionMovementKind.produced), 30);
      expect(d.of(ProductionMovementKind.transferredToSales), 15);
      expect(d.net, 15);
      expect(d.balance.closing, 15);
    });

    test('in the exports', () {
      final t = resolveExport(
        productionStockItemsExportSpec(
          kind: ProductionStockKind.producedItem,
          rows: i1Rows,
          state: ProductionStockTableState(),
          choices: ProductionStockFilterChoices.fromRows(i1Rows),
          categoryNames: sampleCategories(),
          period: day2,
          currency: '₦',
          departmentsEnabled: true,
          canSeeCost: true,
          canSeeQuantity: true,
          historyAllowed: true,
        ),
        testCtx,
      ).tables.first;
      final row = t.rows.single;
      expect(row[t.indexOf('opening')].raw, 0);
      expect(row[t.indexOf('produced')].raw, 30);
      expect(row[t.indexOf('transferredToSales')].raw, 15);
      expect(row[t.indexOf('closing')].raw, 15);

      final s = resolveExport(
        productionHistorySummaryExportSpec(
          kind: ProductionStockKind.producedItem,
          allRows: i4Rows,
          rows: i4Rows,
          state: ProductionHistorySummaryState(),
          categoryNames: sampleCategories(),
          period: day2,
          currency: '₦',
          departmentsEnabled: true,
          canSeeQuantity: true,
        ),
        testCtx,
      ).tables.first;
      final srow = s.rows.single;
      expect(srow[s.indexOf('produced')].raw, 30);
      expect(srow[s.indexOf('closing')].raw, 15);
    });
  });

  group('M1 / M4: flour 2 → 1, 1 used in production, ₦5,000', () {
    test('the table row: counted once, from the record', () {
      final f = m1Rows.single;
      expect(f.balance.opening, 2);
      expect(f.movement.of(ProductionMovementKind.used), 1);
      expect(f.balance.closing, 1);
      expect(f.materialUsage!.productionQty, 1);
      expect(f.materialUsage!.manualQty, 0);
      expect(f.materialUsage!.totalCost, 5000);
    });

    test('the history summary row', () {
      final f = m4Rows.single;
      expect(f.balance.opening, 2);
      expect(f.of(ProductionMovementKind.used), 1);
      expect(f.balance.closing, 1);
    });

    test('in the exports', () {
      final t = resolveExport(
        productionStockItemsExportSpec(
          kind: ProductionStockKind.material,
          rows: m1Rows,
          state: ProductionStockTableState(),
          choices: ProductionStockFilterChoices.fromRows(m1Rows),
          categoryNames: sampleCategories(),
          period: day2,
          currency: '₦',
          departmentsEnabled: true,
          canSeeCost: true,
          canSeeQuantity: true,
          historyAllowed: true,
        ),
        testCtx,
      ).tables.first;
      final row = t.rows.single;
      expect(row[t.indexOf('opening')].raw, 2);
      expect(row[t.indexOf('used')].raw, 1);
      expect(row[t.indexOf('closing')].raw, 1);
      expect(row[t.indexOf('usedInProduction')].raw, 1);
      expect(row[t.indexOf('usedManually')].raw, 0);
      expect(row[t.indexOf('usageCost')].raw, 5000);
      expect(t.totals![t.indexOf('usageCost')].raw, 5000);

      final s = resolveExport(
        productionHistorySummaryExportSpec(
          kind: ProductionStockKind.material,
          allRows: m4Rows,
          rows: m4Rows,
          state: ProductionHistorySummaryState(),
          categoryNames: sampleCategories(),
          period: day2,
          currency: '₦',
          departmentsEnabled: true,
          canSeeQuantity: true,
        ),
        testCtx,
      ).tables.first;
      expect(s.rows.single[s.indexOf('used')].raw, 1);
    });
  });

  test('the four elements agree', () {
    final record = p1Rows.single;
    final usage = u1Rows.single;
    final flour = m1Rows.single;
    // Cost: production record = usage record = material usage.
    expect(record.materialCost, usage.cost);
    expect(flour.materialUsage!.totalCost, record.materialCost);
    // Flour: the usage = use in production = the history's use.
    expect(usage.primaryQty, flour.materialUsage!.productionQty);
    expect(m4Rows.single.of(ProductionMovementKind.used), usage.primaryQty);
    // Donuts: produced in the record = produced in the history.
    expect(i4Rows.single.of(ProductionMovementKind.produced), record.primaryQty);
    expect(i1Rows.single.balance.closing, record.primaryQty - 15);
  });
}
