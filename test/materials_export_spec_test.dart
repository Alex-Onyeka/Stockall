import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/pages/report/components/export/report_export_format.dart';
import 'package:stockall/pages/report/components/export/report_export_resolve.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/export/report_roll_builder.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/production_stock_model.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/stock_items_export_spec.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/stock_items_logic.dart';
import 'package:stockall/services/printing/escpos_builder.dart' show fontBDots;

import 'item_history_export_fixtures.dart' show testCtx;
import 'materials_table_logic_test.dart' show materialRows, materialQuery, day2;
import 'production_report_fixtures.dart';

final sample = materialQuery(materialRows());

ReportExportSpec specFor(
  List<ProductionStockRow> rows, {
  ProductionStockFilters? filters,
  bool departmentsEnabled = false,
  bool canSeeCost = true,
  bool canSeeQuantity = true,
}) => productionStockItemsExportSpec(
  kind: ProductionStockKind.material,
  rows: rows,
  state: ProductionStockTableState(filters: filters),
  choices: ProductionStockFilterChoices.fromRows(rows),
  categoryNames: sampleCategories(),
  period: day2,
  currency: '₦',
  departmentsEnabled: departmentsEnabled,
  canSeeCost: canSeeCost,
  canSeeQuantity: canSeeQuantity,
  historyAllowed: true,
);

ResolvedTable tableOf(ReportExportSpec spec) => resolveExport(spec, testCtx).tables.single;

ResolvedCell cellOf(ReportExportSpec spec, String name, String id) {
  final t = tableOf(spec);
  return t.rows.firstWhere((r) => r[0].text == name)[t.indexOf(id)];
}

void main() {
  test('150 materials: every row, in the screen order', () {
    final sorted = materialQuery(
      materialRows(materials: manyMaterials(150), history: const []),
      sort: const ProductionStockSort(ProductionStockSortField.quantity),
    );
    final t = tableOf(specFor(sorted));
    expect(t.rows, hasLength(150));
    expect([for (final r in t.rows) r[0].text], [for (final r in sorted) r.name]);
  });

  test('the Materials columns: low stock, movement, production vs manual use', () {
    expect([for (final c in tableOf(specFor(sample)).columns) if (c.inPdf) c.label], [
      'Material',
      'Primary Unit',
      'Stock',
      'Low Stock Qty',
      'Cost Price',
      'Stock Value',
      'Categories',
      'Expiry',
      'Managed',
      'Created',
      'Opening',
      'Used',
      'Restored',
      'Transferred to Department',
      'Transferred to Branch',
      'Transferred In',
      'Manual Increase',
      'Manual Decrease',
      'Net',
      'Closing',
      'Used in Production',
      'Used Manually',
      'Usage Cost',
    ]);
    final noCost = [for (final c in tableOf(specFor(sample, canSeeCost: false)).columns) c.id];
    expect(noCost, isNot(contains('usageCost')));
  });

  test('cells, masking and totals', () {
    final spec = specFor(sample);
    expect(cellOf(spec, 'Flour', 'quantity').text, '1 Bag');
    expect(cellOf(spec, 'Flour', 'lowQuantity').text, '1');
    expect(cellOf(spec, 'Flour', 'used').text, '1');
    expect(cellOf(spec, 'Flour', 'usedInProduction').raw, 3);
    expect(cellOf(spec, 'Flour', 'usedManually').raw, 0.25);
    expect(cellOf(spec, 'Flour', 'usageCost').text, '₦16,250.00');
    final t = tableOf(spec);
    expect(t.totals![t.indexOf('usageCost')].raw, 17250);
    expect(t.totals![t.indexOf('name')].text, '3 materials');
    final masked = specFor(sample, canSeeQuantity: false);
    for (final id in ['quantity', 'lowQuantity', 'used', 'usedInProduction', 'usedManually']) {
      expect(cellOf(masked, 'Flour', id).text, '****', reason: id);
    }
    expect(cellOf(masked, 'Flour', 'usageCost').text, '₦16,250.00');
  });

  test('splits: Category; Department with departments on', () {
    final f = ExportFormatter(currency: '₦');
    List<String> names(ReportExportSpec s, String id) => [
      for (final g in resolveGroups(s.tables.single, id, f)) g.name,
    ];
    final spec = specFor(sample, departmentsEnabled: true);
    expect(spec.splitOptions.map((s) => s.id), ['category', 'department']);
    expect(names(spec, 'category'), ['Drinks', 'Pastry', 'No Category']);
    expect(names(spec, 'department'), ['Bakery', 'Kitchen', 'No Department']);
  });

  test('the filters and the notes', () {
    final spec = specFor(
      sample,
      filters: ProductionStockFilters(stockLevel: ProductionStockLevel.low),
    );
    expect([for (final x in spec.filters) '${x.label}: ${x.value}'], [
      'Stock Level: Low Stock',
    ]);
    expect(spec.notes.single, startsWith('Use in production comes from the production records'));
  });

  test('roll at 58 and 80mm', () {
    for (final paper in RollPaper.values) {
      final out = renderRollEscPos(
        buildRollLines(specFor(sample), testCtx, paper: paper),
        paper,
      ).preview;
      final lines = out.split('\n');
      final flour = lines.firstWhere((l) => l.startsWith('Flour') && l.endsWith('N5,000.00'));
      if (paper == RollPaper.mm80) expect(flour, contains('1 Bag'));
      expect(
        lines.skipWhile((l) => !l.startsWith('---')).every(
          (l) => l.length <= (paper == RollPaper.mm58 ? 32 : 48),
        ),
        isTrue,
      );
      expect(lines.every((l) => l.length <= paper.dots ~/ fontBDots), isTrue);
    }
  });
}
