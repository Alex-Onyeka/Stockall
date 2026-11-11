import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/temp_production_folder/temp_materials_item_history/material_item_history_event_class.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/production_stock_model.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/stock_history_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

import 'production_report_fixtures.dart';

const six = TimeOfDay(hour: 6, minute: 0);
final day2 = ReceiptsReportPeriod.day(DateTime(2026, 10, 2));

List<ProductionHistoryRow> materialHistoryRows() =>
    ProductionHistoryRowBuilder.buildAll(
      entries: materialEntries(),
      items: materialItems(),
      categoryNames: sampleCategories(),
    );

List<ProductionHistoryRow> materialHistoryQuery(
  List<ProductionHistoryRow> rows, {
  ReceiptsReportPeriod? period,
  ProductionHistoryFilters? filters,
  ProductionHistorySortField sortField = ProductionHistorySortField.date,
  bool ascending = false,
  bool canSeeQuantity = true,
}) => ProductionHistoryQuery.filterAndSort(
  rows: rows,
  period: period ?? day2,
  filters: filters ?? ProductionHistoryFilters(),
  sortField: sortField,
  ascending: ascending,
  departmentsEnabled: true,
  canSeeQuantity: canSeeQuantity,
  closingTime: six,
);

List<String> uuids(List<ProductionHistoryRow> rows) => [for (final r in rows) r.uuid];

ProductionHistoryRow rowOf(String uuid) =>
    materialHistoryRows().firstWhere((r) => r.uuid == uuid);

String n(num v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : '$v';

void main() {
  test('the day, newest first', () {
    expect(uuids(materialHistoryQuery(materialHistoryRows())), [
      'sh-3',
      'sh-2',
      'sh-1',
      'mh-2',
    ]);
  });

  test("the material buckets: used, to a department, Alex's flour", () {
    final flour = rowOf('mh-2');
    expect(flour.eventLabel, 'Used');
    expect(productionHistoryChangeText(flour, n), '-1 Bag');
    expect(productionHistoryBalanceText(flour, n), '2 → 1');
    expect(rowOf('sh-2').eventLabel, 'Transferred to Department');
    expect(rowOf('sh-2').destinationLabel, 'Department');
    expect(productionHistoryChangeText(rowOf('sh-3'), n), '-0.5 Kg');
    // A legacy production use, written with no event.
    final legacy = rowOf('yh-1');
    expect(legacy.entry.event, MaterialItemHistoryEventClass.productionCreated);
    expect(legacy.eventLabel, 'Used');
  });

  test('filters: event, destination, item, department', () {
    final rows = materialHistoryRows();
    List<String> f(ProductionHistoryFilters filters) =>
        uuids(materialHistoryQuery(rows, filters: filters))..sort();
    expect(
      f(ProductionHistoryFilters(eventKey: MaterialItemHistoryEventClass.usageCreated)),
      ['mh-2', 'sh-1', 'sh-3'],
    );
    expect(f(ProductionHistoryFilters(destination: 'department')), ['sh-2']);
    expect(f(ProductionHistoryFilters(itemKey: 'flour')), ['mh-2']);
    expect(f(ProductionHistoryFilters(departmentKey: deptKitchen)), ['sh-1', 'sh-2', 'sh-3']);
  });

  test('the note: history can\'t split production from manual use', () {
    for (final page in [
      ProductionStockReportPage.history,
      ProductionStockReportPage.historySummary,
    ]) {
      final notes = productionStockNotes(
        kind: ProductionStockKind.material,
        page: page,
        period: day2,
        historyAllowed: true,
      );
      expect(notes.single, contains("can't tell production use from manual use"));
      expect(notes.single, contains('Materials Table or Analysis'));
    }
    expect(
      productionStockNotes(
        kind: ProductionStockKind.producedItem,
        page: ProductionStockReportPage.history,
        period: day2,
        historyAllowed: true,
      ),
      isEmpty,
    );
  });
}
