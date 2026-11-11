import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_item_history/production_item_history.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_item_history/production_item_history_event_class.dart';
import 'package:stockall/pages/report/general_report/class/general_report_logic.dart';
import 'package:stockall/pages/report/production_report/production_records_table/class/production_records_table_logic.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/production_stock_model.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/stock_analysis_logic.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/stock_items_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

import 'production_report_fixtures.dart';

const six = TimeOfDay(hour: 6, minute: 0);
final day2 = ReceiptsReportPeriod.day(DateTime(2026, 10, 2));

List<ProductionStockRow> rowsFor(
  ReceiptsReportPeriod p, {
  List<ProductionItemHistory>? history,
  bool historyAllowed = true,
}) => ProductionStockRowBuilder.buildAll(
  items: stockItems(),
  entries: stockEntries(history),
  categoryNames: sampleCategories(),
  period: p,
  businessNow: stockNow,
  historyAllowed: historyAllowed,
  closingTime: six,
);

ProductionStockAnalysis analysis({
  ReceiptsReportPeriod? period,
  List<ProductionItemHistory>? history,
  bool departmentsEnabled = true,
  bool canSeeCost = true,
  bool canSeeQuantity = true,
  bool historyAllowed = true,
  ProductionStockKind kind = ProductionStockKind.producedItem,
}) {
  final p = period ?? day2;
  final previous = GeneralReportPeriods.previous(p);
  return ProductionStockAnalysisBuilder.build(
    kind: kind,
    rows: rowsFor(p, history: history, historyAllowed: historyAllowed),
    previousRows:
        previous == null
            ? null
            : rowsFor(previous, history: history, historyAllowed: historyAllowed),
    records: recordRows(sampleRecords()),
    period: p,
    businessNow: stockNow,
    departmentsEnabled: departmentsEnabled,
    canSeeCost: canSeeCost,
    canSeeQuantity: canSeeQuantity,
    historyAllowed: historyAllowed,
    closingTime: six,
  );
}

List<ProductionStockCard> cards(
  ProductionStockAnalysis a, {
  bool canSeeCost = true,
  bool canSeeQuantity = true,
  bool historyAllowed = true,
}) => productionStockAnalysisCards(
  a,
  canSeeCost: canSeeCost,
  canSeeQuantity: canSeeQuantity,
  historyAllowed: historyAllowed,
);

String text(ProductionStockCard c) =>
    c.valueText((v) => 'N$v', (v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : '$v');

/// 10 Litre of juice base produced on 2 Oct: a second unit.
final juiceRun = stockRecord(
  uuid: 'jh-1',
  title: 'Item Produced',
  event: ProductionItemHistoryEventClass.productionCreated,
  createdAt: oct(2, 15),
  itemUuid: 'juice-base',
  itemName: 'Juice Base',
  quantityChange: 10,
  unit: 'Litre',
  primaryUnit: 'Litre',
  oldValue: '0',
  newValue: '10',
  isIncreased: true,
);

void main() {
  group('headline figures', () {
    final a = analysis();

    test('stock: items, value, out of stock, expiring', () {
      expect(a.items, 3);
      expect(a.managed, 2);
      expect(a.stockValue, 3000);
      expect(a.outOfStock, 1);
      expect(a.expired, 1);
      // The cake has expired; the donuts expire within 30 days.
      expect(a.expiring, 2);
    });

    test('movement of the period, per unit, and the transfer rate', () {
      expect(a.main['Pcs'], 35);
      expect(a.out['Pcs'], 15);
      expect(a.rate, closeTo(15 / 35 * 100, 1e-9));
    });

    test('the cards and the change against the previous day', () {
      final c = cards(a);
      expect([for (final x in c) x.id], [
        'items',
        'stockValue',
        'outOfStock',
        'expiring',
        'main',
        'out',
        'rate',
      ]);
      final main = c.firstWhere((x) => x.id == 'main');
      expect(text(main), '35 Pcs');
      // Nothing produced on 1 Oct: the change is an amount.
      expect(main.change!.kind, GeneralReportChangeKind.amount);
      expect(main.change!.value, 35);
      expect(c.firstWhere((x) => x.id == 'expiring').subtitle, startsWith('1 expired'));
    });

    test('mixed units: no comparison and no rate', () {
      final mixed = analysis(history: [...sampleProducedHistory(), juiceRun]);
      expect(mixed.main, {'Pcs': 35, 'Litre': 10});
      expect(mixed.rate, isNull);
      final main = cards(mixed).firstWhere((x) => x.id == 'main');
      expect(text(main), '10 Litre, 35 Pcs');
      expect(main.change, isNull);
      expect(main.subtitle, 'Mixed units: no comparison');
    });

    test('permissions: cost, quantity and history', () {
      expect(
        [for (final x in cards(a, canSeeCost: false)) x.id],
        isNot(contains('stockValue')),
      );
      final masked = cards(a, canSeeQuantity: false);
      expect(text(masked.firstWhere((x) => x.id == 'main')), '****');
      expect(text(masked.firstWhere((x) => x.id == 'outOfStock')), '****');
      expect(text(masked.firstWhere((x) => x.id == 'items')), '3');
      // Stock value is cost × quantity: masked like the table's.
      expect(text(masked.firstWhere((x) => x.id == 'stockValue')), '****');
      final noHistory = analysis(historyAllowed: false);
      expect(
        [for (final x in cards(noHistory, historyAllowed: false)) x.id],
        ['items', 'stockValue', 'outOfStock', 'expiring'],
      );
    });
  });

  group('tabs', () {
    test('rankings need history and quantity; departments; cost per unit', () {
      expect(analysis().tabs.keys, [
        ProductionStockAnalysisTab.produced,
        ProductionStockAnalysisTab.transferred,
        ProductionStockAnalysisTab.net,
        ProductionStockAnalysisTab.departments,
        ProductionStockAnalysisTab.categories,
        ProductionStockAnalysisTab.costPerUnit,
      ]);
      expect(analysis(canSeeQuantity: false).tabs.keys, [
        ProductionStockAnalysisTab.departments,
        ProductionStockAnalysisTab.categories,
        ProductionStockAnalysisTab.costPerUnit,
      ]);
      expect(
        analysis(departmentsEnabled: false, canSeeCost: false).tabs.keys,
        [
          ProductionStockAnalysisTab.produced,
          ProductionStockAnalysisTab.transferred,
          ProductionStockAnalysisTab.net,
          ProductionStockAnalysisTab.categories,
        ],
      );
      expect(
        productionStockAnalysisTabs(
          kind: ProductionStockKind.material,
          departmentsEnabled: false,
          canSeeCost: true,
          canSeeQuantity: true,
          historyAllowed: true,
        ),
        isNot(contains(ProductionStockAnalysisTab.costPerUnit)),
      );
    });

    test('produced ranking: largest first, with the rate', () {
      final rows = analysis().tabs[ProductionStockAnalysisTab.produced]!;
      expect([for (final r in rows) r.label], ['Donut', 'Cake']);
      final donut = rows.first;
      expect(donut.valueOf(ProductionStockAnalysisField.main), 30);
      expect(donut.valueOf(ProductionStockAnalysisField.out), 15);
      expect(donut.valueOf(ProductionStockAnalysisField.rate), 50);
      expect(donut.unitOf(ProductionStockAnalysisField.main), 'Pcs');
      expect(donut.filters.itemKey, 'donut');
    });

    test('transferred and net rankings', () {
      final a = analysis();
      expect(
        [for (final r in a.tabs[ProductionStockAnalysisTab.transferred]!) r.key],
        ['donut'],
      );
      final net = a.tabs[ProductionStockAnalysisTab.net]!;
      expect([for (final r in net) r.key], ['donut', 'cake']);
      expect(net.first.valueOf(ProductionStockAnalysisField.opening), 0);
      expect(net.first.valueOf(ProductionStockAnalysisField.closing), 15);
    });

    test('distribution by department and category, none last', () {
      final a = analysis();
      final depts = a.tabs[ProductionStockAnalysisTab.departments]!;
      expect([for (final r in depts) r.label], [
        'Bakery',
        'Kitchen',
        productionNoDepartmentLabel,
      ]);
      expect(depts.first.valueOf(ProductionStockAnalysisField.stockValue), 3000);
      expect(depts.first.valueOf(ProductionStockAnalysisField.share), 100);
      expect(depts.first.filters.departmentKey, deptBakery);
      expect(depts.last.filters.departmentKey, productionReportNoneKey);
      final cats = a.tabs[ProductionStockAnalysisTab.categories]!;
      expect([for (final r in cats) r.label], ['Pastry', 'No Category']);
      expect(cats.first.valueOf(ProductionStockAnalysisField.items), 2);
      expect(cats.first.filters.categoryKey, catPastry);
    });

    test('without the quantity permission: no stock value, share by count', () {
      final a = analysis(canSeeQuantity: false);
      final depts = a.tabs[ProductionStockAnalysisTab.departments]!;
      for (final r in depts) {
        expect(
          r.valueOf(ProductionStockAnalysisField.share),
          (r.valueOf(ProductionStockAnalysisField.items) as int) / 3 * 100,
        );
      }
      for (final tab in [
        ProductionStockAnalysisTab.departments,
        ProductionStockAnalysisTab.categories,
      ]) {
        final ids = [
          for (final c in productionStockAnalysisColumns(
            tab,
            kind: ProductionStockKind.producedItem,
            canSeeCost: true,
            canSeeQuantity: false,
          ))
            c.field,
        ];
        expect(ids, isNot(contains(ProductionStockAnalysisField.stockValue)));
      }
    });

    test('cost per unit: the runs against the cost price', () {
      final rows = analysis().tabs[ProductionStockAnalysisTab.costPerUnit]!;
      final donut = rows.single;
      expect(donut.valueOf(ProductionStockAnalysisField.runs), 2);
      final perUnit = donut.valueOf(ProductionStockAnalysisField.recordedCostPerUnit) as double;
      // ₦12,200 over 66 Pcs.
      expect(perUnit, closeTo(12200 / 66, 1e-9));
      expect(donut.valueOf(ProductionStockAnalysisField.costPrice), 200);
      expect(
        donut.valueOf(ProductionStockAnalysisField.difference) as double,
        closeTo(12200 / 66 - 200, 1e-9),
      );
      expect(donut.filters.itemKey, 'donut');
    });

    test('sorting keeps the none row last', () {
      final depts = analysis().tabs[ProductionStockAnalysisTab.departments]!;
      for (final asc in [true, false]) {
        expect(
          ProductionStockAnalysisBuilder.sortTab(
            depts,
            field: ProductionStockAnalysisField.items,
            ascending: asc,
          ).last.isNone,
          isTrue,
        );
      }
    });
  });
}
