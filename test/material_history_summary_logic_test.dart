import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/production_stock_model.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/stock_history_summary_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

import 'production_report_fixtures.dart';

const six = TimeOfDay(hour: 6, minute: 0);
final day2 = ReceiptsReportPeriod.day(DateTime(2026, 10, 2));

List<ProductionHistorySummaryRow> materialSummaryRows([ReceiptsReportPeriod? p]) =>
    ProductionHistorySummaryBuilder.build(
      kind: ProductionStockKind.material,
      items: materialItems(),
      entries: materialEntries(),
      categoryNames: sampleCategories(),
      period: p ?? day2,
      closingTime: six,
    );

ProductionHistorySummaryRow rowOf(List<ProductionHistorySummaryRow> rows, String key) =>
    rows.firstWhere((r) => r.key == key);

void main() {
  test('the material columns', () {
    expect(productionSummaryMovementColumns(ProductionStockKind.material), [
      ProductionMovementKind.used,
      ProductionMovementKind.restored,
      ProductionMovementKind.transferredToDepartment,
      ProductionMovementKind.transferredToBranch,
      ProductionMovementKind.transferredIn,
      ProductionMovementKind.adjustedUp,
      ProductionMovementKind.adjustedDown,
    ]);
  });

  test("flour 2 → 1; sugar used and moved to a department", () {
    final rows = materialSummaryRows();
    final flour = rowOf(rows, 'flour');
    expect(flour.balance.opening, 2);
    expect(flour.of(ProductionMovementKind.used), 1);
    expect(flour.balance.closing, 1);
    final sugar = rowOf(rows, 'sugar');
    expect(sugar.of(ProductionMovementKind.used), 2.5);
    expect(sugar.of(ProductionMovementKind.transferredToDepartment), 2);
    expect(sugar.net, -4.5);
    expect(sugar.balance.closing, 8);
    expect(rowOf(rows, 'yeast').events, 0);
  });

  test('legacy production use and a manual increase', () {
    final oct1 = materialSummaryRows(ReceiptsReportPeriod.day(DateTime(2026, 10, 1)));
    expect(rowOf(oct1, 'yeast').of(ProductionMovementKind.used), 1);
    expect(rowOf(oct1, 'flour').of(ProductionMovementKind.adjustedUp), 2);
    final oct3 = materialSummaryRows(ReceiptsReportPeriod.day(DateTime(2026, 10, 3)));
    expect(rowOf(oct3, 'sugar').of(ProductionMovementKind.adjustedUp), 1);
  });

  test('cards over every material; the movement filter narrows the table', () {
    final rows = materialSummaryRows();
    final stats = ProductionHistorySummaryStats.fromRows(rows);
    final cards = productionHistorySummaryCards(
      stats,
      kind: ProductionStockKind.material,
      canSeeQuantity: true,
    );
    String t(String id) => cards
        .firstWhere((c) => c.id == id)
        .valueText((v) => '', (v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : '$v');
    expect(cards.first.title, 'Materials With Movement');
    expect(t('moved'), '2');
    expect(t('main'), '1 Bag, 2.5 Kg');
    expect(t('out'), '2 Kg');
    final outflow = ProductionHistorySummaryBuilder.filterAndSort(
      rows: rows,
      filters: ProductionHistorySummaryFilters(
        movement: ProductionHistoryMovementFilter.outflowOnly,
      ),
      sort: ProductionHistorySummarySort.byName,
      canSeeQuantity: true,
    );
    expect([for (final r in outflow) r.key], ['flour', 'sugar']);
  });
}
