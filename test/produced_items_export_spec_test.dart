import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/pages/report/components/export/report_export_format.dart';
import 'package:stockall/pages/report/components/export/report_export_resolve.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/export/report_roll_builder.dart';
import 'package:stockall/pages/report/production_report/production_records_table/class/production_records_table_logic.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/production_stock_model.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/stock_items_export_spec.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/stock_items_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/services/printing/escpos_builder.dart' show fontBDots;

import 'item_history_export_fixtures.dart' show testCtx;
import 'produced_items_table_logic_test.dart' show stockRows, stockQuery, day2, day3;
import 'production_report_fixtures.dart';

final sample = stockQuery(stockRows());

ReportExportSpec specFor(
  List<ProductionStockRow> rows, {
  ProductionStockFilters? filters,
  ReceiptsReportPeriod? period,
  bool departmentsEnabled = false,
  bool canSeeCost = true,
  bool canSeeQuantity = true,
  bool historyAllowed = true,
}) => productionStockItemsExportSpec(
  kind: ProductionStockKind.producedItem,
  rows: rows,
  state: ProductionStockTableState(filters: filters),
  choices: ProductionStockFilterChoices.fromRows(rows),
  categoryNames: sampleCategories(),
  period: period ?? day2,
  currency: '₦',
  departmentsEnabled: departmentsEnabled,
  canSeeCost: canSeeCost,
  canSeeQuantity: canSeeQuantity,
  historyAllowed: historyAllowed,
);

ResolvedTable tableOf(ReportExportSpec spec) =>
    resolveExport(spec, testCtx).tables.single;

ResolvedCell cellOf(ReportExportSpec spec, String name, String id) {
  final t = tableOf(spec);
  return t.rows.firstWhere((r) => r[t.indexOf('name')].text == name)[t.indexOf(id)];
}

List<String> pdfLabels(ReportExportSpec spec) => [
  for (final c in tableOf(spec).columns)
    if (c.inPdf) c.label,
];

void main() {
  test('150 items: every row, in the screen order', () {
    final sorted = stockQuery(
      stockRows(items: manyProducedItems(150), history: const []),
      sort: const ProductionStockSort(
        ProductionStockSortField.quantity,
        ascending: false,
      ),
    );
    final t = tableOf(specFor(sorted));
    expect(t.rows, hasLength(150));
    expect([for (final r in t.rows) r[t.indexOf('name')].text], [
      for (final r in sorted) r.name,
    ]);
  });

  group('columns follow the screen', () {
    test('every column, the movement of the period last', () {
      expect(pdfLabels(specFor(sample)), [
        'Produced Item',
        'Primary Unit',
        'Stock',
        'Cost Price',
        'Stock Value',
        'Categories',
        'Expiry',
        'Managed',
        'Created',
        'Opening',
        'Produced',
        'Production Deleted',
        'Transferred to Sales',
        'Transferred to Branch',
        'Transferred In',
        'Manual Increase',
        'Manual Decrease',
        'Net',
        'Closing',
      ]);
    });

    test('Department with departments on; cost and history gates', () {
      expect(pdfLabels(specFor(sample, departmentsEnabled: true)), contains('Department'));
      final noCost = pdfLabels(specFor(sample, canSeeCost: false));
      expect(noCost, isNot(contains('Cost Price')));
      expect(noCost, isNot(contains('Stock Value')));
      final noHistory = pdfLabels(specFor(sample, historyAllowed: false));
      expect(noHistory, isNot(contains('Opening')));
      expect(noHistory, isNot(contains('Produced')));
    });
  });

  group('cells', () {
    final spec = specFor(sample);

    test('stock, value, expiry and movement', () {
      expect(cellOf(spec, 'Donut', 'quantity').text, '15 Pcs');
      expect(cellOf(spec, 'Donut', 'quantity').raw, 15);
      expect(cellOf(spec, 'Donut', 'stockValue').text, '₦3,000.00');
      expect(cellOf(spec, 'Donut', 'expiry').text, 'Oct 20, 2026');
      expect(cellOf(spec, 'Cake', 'expiry').text, 'Oct 1, 2026 (Expired)');
      expect(cellOf(spec, 'Juice Base', 'quantity').text, '—');
      expect(cellOf(spec, 'Donut', 'produced').text, '30');
      expect(cellOf(spec, 'Donut', 'transferredToSales').text, '15');
      expect(cellOf(spec, 'Donut', 'net').text, '+15');
      expect(cellOf(spec, 'Donut', 'closing').text, '15');
    });

    test('quantities masked without the permission, as on screen', () {
      final masked = specFor(sample, canSeeQuantity: false);
      for (final id in ['quantity', 'stockValue', 'opening', 'produced', 'closing']) {
        expect(cellOf(masked, 'Donut', id).text, '****', reason: id);
        expect(cellOf(masked, 'Donut', id).raw, isNull, reason: id);
      }
      expect(cellOf(masked, 'Donut', 'costPrice').text, '₦200.00');
      expect(tableOf(masked).totals![tableOf(masked).indexOf('stockValue')].text, '****');
    });
  });

  test('totals: items and stock value', () {
    final t = tableOf(specFor(sample));
    expect(t.totals![t.indexOf('name')].text, '3 items');
    expect(t.totals![t.indexOf('stockValue')].raw, 3000);
    expect(t.totals![t.indexOf('quantity')].text, isNot(contains('Pcs')));
  });

  group('splits', () {
    final f = ExportFormatter(currency: '₦');
    List<String> names(ReportExportSpec spec, String id) => [
      for (final g in resolveGroups(spec.tables.single, id, f)) g.name,
    ];

    test('Category; Department with departments on', () {
      final spec = specFor(sample);
      expect(spec.splitOptions.map((s) => s.id), ['category']);
      expect(names(spec, 'category'), ['Pastry', 'No Category']);
      final withDept = specFor(sample, departmentsEnabled: true);
      expect(withDept.splitOptions.map((s) => s.id), ['category', 'department']);
      expect(names(withDept, 'department'), ['Bakery', 'Kitchen', 'No Department']);
    });

    test('a split sheet totals its own rows', () {
      final section =
          specFor(sample).tables.single as ExportTableSection<ProductionStockRow>;
      final pastry = sample.where((r) => r.categoryKeys.contains(catPastry)).toList();
      expect(section.totalsFor!(pastry)['name'], '2 items');
      expect(section.totalsFor!(pastry)['stockValue'], 3000);
    });
  });

  group('info box and notes', () {
    test('filters worded like the chips', () {
      final filters = ProductionStockFilters(
        search: 'd',
        itemKey: 'donut',
        categoryKey: productionReportNoneKey,
        departmentKey: deptBakery,
        stockLevel: ProductionStockLevel.inStock,
        managed: true,
        costMin: 100,
        quantityMax: 20,
        expiryStart: DateTime(2026, 10, 1),
        expiryEnd: DateTime(2026, 10, 30),
      );
      final spec = specFor(sample, filters: filters, departmentsEnabled: true);
      expect([for (final x in spec.filters) '${x.label}: ${x.value}'], [
        'Search: d',
        'Produced Item: Donut',
        'Category: No Category',
        'Department: Bakery',
        'Stock Level: In Stock',
        'Managed: Managed',
        'Cost Price: ₦100.00 - Any',
        'Stock: Any - 20',
        'Expiry: Oct 1, 2026 - Oct 30, 2026',
      ]);
      expect(spec.sortedBy, 'Produced Item (ascending)');
      // The label follows the sort actually used.
      final byValue = productionStockItemsExportSpec(
        kind: ProductionStockKind.producedItem,
        rows: sample,
        state: ProductionStockTableState(
          sort: const ProductionStockSort(
            ProductionStockSortField.stockValue,
            ascending: false,
          ),
        ),
        choices: ProductionStockFilterChoices.fromRows(sample),
        categoryNames: sampleCategories(),
        period: day2,
        currency: '₦',
        departmentsEnabled: false,
        canSeeCost: true,
        canSeeQuantity: false,
        historyAllowed: true,
      );
      expect(byValue.sortedBy, 'Produced Item (ascending)');
      final hidden = specFor(
        sample,
        filters: filters,
        canSeeCost: false,
        canSeeQuantity: false,
      );
      expect(
        [for (final x in hidden.filters) x.label],
        isNot(anyOf(contains('Cost Price'), contains('Stock'), contains('Stock Level'))),
      );
    });

    test('the notes are the screen notes', () {
      expect(specFor(sample).notes, isEmpty);
      final oct3 = stockQuery(stockRows(period: day3));
      expect(specFor(oct3, period: day3).notes.single, startsWith('1 history record'));
      expect(
        specFor(sample, period: const ReceiptsReportPeriod.allTime()).notes.first,
        'All time covers the history loaded on this device.',
      );
    });
  });

  group('roll', () {
    String preview(ReportExportSpec spec, RollPaper paper) =>
        renderRollEscPos(buildRollLines(spec, testCtx, paper: paper), paper).preview;
    bool fits(String out, int width) => out
        .split('\n')
        .skipWhile((l) => !l.startsWith('---'))
        .every((l) => l.length <= width);

    test('58mm: name and value; 80mm: name, stock, value on one line', () {
      final s58 = preview(specFor(sample), RollPaper.mm58);
      expect(
        s58.split('\n').any((l) => l.startsWith('Donut') && l.endsWith('N3,000.00')),
        isTrue,
      );
      expect(fits(s58, 32), isTrue);
      expect(
        s58.split('\n').every((l) => l.length <= RollPaper.mm58.dots ~/ fontBDots),
        isTrue,
      );
      final s80 = preview(specFor(sample), RollPaper.mm80);
      final line = s80
          .split('\n')
          .firstWhere((l) => l.startsWith('Donut') && l.endsWith('N3,000.00'));
      expect(line, contains('15 Pcs'));
      expect(fits(s80, 48), isTrue);
    });

    test('masked and without cost: the stock shows as ****', () {
      final out = preview(
        specFor(sample, canSeeCost: false, canSeeQuantity: false),
        RollPaper.mm58,
      );
      expect(
        out.split('\n').any((l) => l.startsWith('Donut') && l.endsWith('****')),
        isTrue,
      );
    });
  });
}
