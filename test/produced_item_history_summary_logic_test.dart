import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/production_stock_model.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/stock_history_summary_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

import 'production_report_fixtures.dart';

const six = TimeOfDay(hour: 6, minute: 0);
final day2 = ReceiptsReportPeriod.day(DateTime(2026, 10, 2));

List<ProductionHistorySummaryRow> summaryRows([ReceiptsReportPeriod? period]) =>
    ProductionHistorySummaryBuilder.build(
      kind: ProductionStockKind.producedItem,
      items: stockItems(),
      entries: stockEntries(),
      categoryNames: sampleCategories(),
      period: period ?? day2,
      closingTime: six,
    );

ProductionHistorySummaryRow rowOf(List<ProductionHistorySummaryRow> rows, String key) =>
    rows.firstWhere((r) => r.key == key);

List<String> keys(List<ProductionHistorySummaryRow> rows) => [for (final r in rows) r.key];

List<String> filtered(
  ProductionHistorySummaryFilters filters, {
  ProductionHistorySummarySort sort = ProductionHistorySummarySort.byName,
  bool canSeeQuantity = true,
}) => keys(
  ProductionHistorySummaryBuilder.filterAndSort(
    rows: summaryRows(),
    filters: filters,
    sort: sort,
    canSeeQuantity: canSeeQuantity,
  ),
);

void main() {
  group('rows', () {
    final rows = summaryRows();

    test('every item, plus deleted items with records in the period', () {
      expect(keys(rows), ['donut', 'juice-base', 'cake', 'muffin']);
      // No muffin records on 3 Oct.
      expect(
        keys(summaryRows(ReceiptsReportPeriod.day(DateTime(2026, 10, 3)))),
        ['donut', 'juice-base', 'cake'],
      );
    });

    test("Alex's donuts: opening 0, +30 produced, −15 to sales, closing 15", () {
      final d = rowOf(rows, 'donut');
      expect(d.balance.opening, 0);
      expect(d.of(ProductionMovementKind.produced), 30);
      expect(d.of(ProductionMovementKind.productionDeleted), 0);
      expect(d.netProduced, 30);
      expect(d.of(ProductionMovementKind.transferredToSales), 15);
      expect(d.additions, 30);
      expect(d.reductions, 15);
      expect(d.net, 15);
      expect(d.balance.closing, 15);
      expect(d.events, 2);
    });

    test('cake: legacy production, a branch transfer and a manual cut', () {
      final c = rowOf(rows, 'cake');
      expect(c.of(ProductionMovementKind.produced), 5);
      expect(c.of(ProductionMovementKind.transferredToBranch), 2);
      expect(c.of(ProductionMovementKind.adjustedDown), 3);
      expect(c.net, 0);
      expect(c.balance.closing, 0);
      expect(c.categoryKeys, [catPastry]);
      expect(c.departmentKey, deptKitchen);
    });

    test('a deleted item, named from its history', () {
      final m = rowOf(rows, 'muffin');
      expect(m.exists, isFalse);
      expect(m.name, 'Muffin');
      expect(m.primaryUnit, 'Pcs');
      expect(m.of(ProductionMovementKind.produced), 12);
      expect(m.balance.opening, 0);
      expect(m.balance.closing, 12);
    });

    test('an unmanaged item without records', () {
      final j = rowOf(rows, 'juice-base');
      expect(j.events, 0);
      expect(j.balance.opening, isNull);
    });
  });

  group('movement filter', () {
    test('as on the Items history summary', () {
      List<String> m(ProductionHistoryMovementFilter f) =>
          filtered(ProductionHistorySummaryFilters(movement: f))..sort();
      expect(m(ProductionHistoryMovementFilter.all), hasLength(4));
      expect(m(ProductionHistoryMovementFilter.hasMovement), ['cake', 'donut', 'muffin']);
      expect(m(ProductionHistoryMovementFilter.inflowOnly), ['cake', 'donut', 'muffin']);
      expect(m(ProductionHistoryMovementFilter.outflowOnly), ['cake', 'donut']);
      expect(m(ProductionHistoryMovementFilter.noChange), ['cake', 'juice-base']);
    });

    test('search by name or unit', () {
      expect(filtered(ProductionHistorySummaryFilters(search: 'litre')), ['juice-base']);
    });
  });

  group('sort', () {
    test('net, largest first; by name without the quantity permission', () {
      const byNet = ProductionHistorySummarySort(
        ProductionHistorySummarySortField.net,
        ascending: false,
      );
      expect(filtered(ProductionHistorySummaryFilters(), sort: byNet).first, 'donut');
      expect(
        filtered(ProductionHistorySummaryFilters(), sort: byNet, canSeeQuantity: false),
        ['cake', 'donut', 'juice-base', 'muffin'],
      );
    });
  });

  group('cards cover every item, whatever the filters', () {
    final stats = ProductionHistorySummaryStats.fromRows(summaryRows());

    test('per-unit totals', () {
      expect(stats.totalItems, 4);
      expect(stats.itemsWithMovement, 3);
      expect(stats.events, 6);
      expect(stats.of(ProductionMovementKind.produced), {'Pcs': 47});
      expect(stats.netProduced, {'Pcs': 47});
      expect(stats.of(ProductionMovementKind.transferredToSales), {'Pcs': 15});
      expect(stats.net['Pcs'], 27);
      expect(stats.net['Litre'], 0);
    });

    test('the cards, masked without the quantity permission', () {
      final cards = productionHistorySummaryCards(
        stats,
        kind: ProductionStockKind.producedItem,
        canSeeQuantity: true,
      );
      expect([for (final c in cards) c.id], ['moved', 'main', 'out', 'net', 'events']);
      String t(String id) => cards
          .firstWhere((c) => c.id == id)
          .valueText((v) => 'N$v', (v) => v.toStringAsFixed(0));
      expect(t('moved'), '3');
      expect(t('main'), '47 Pcs');
      expect(t('out'), '15 Pcs');
      final masked = productionHistorySummaryCards(
        stats,
        kind: ProductionStockKind.producedItem,
        canSeeQuantity: false,
      );
      expect(
        masked.firstWhere((c) => c.id == 'main').valueText((v) => '', (v) => ''),
        '****',
      );
      expect(
        masked.firstWhere((c) => c.id == 'moved').valueText((v) => '', (v) => '$v'),
        isNot('****'),
      );
    });
  });
}
