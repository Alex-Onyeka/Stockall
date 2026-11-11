import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/pages/report/components/export/report_export_format.dart';
import 'package:stockall/pages/report/components/export/report_export_resolve.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/export/report_roll_builder.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/production_stock_model.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/stock_history_summary_export_spec.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/stock_history_summary_logic.dart';
import 'package:stockall/services/printing/escpos_builder.dart' show fontBDots;

import 'item_history_export_fixtures.dart' show testCtx;
import 'material_history_summary_logic_test.dart' show materialSummaryRows, day2;
import 'production_report_fixtures.dart';

ReportExportSpec specFor({
  List<ProductionHistorySummaryRow>? allRows,
  ProductionHistorySummaryFilters? filters,
  bool departmentsEnabled = false,
  bool canSeeQuantity = true,
}) {
  final state = ProductionHistorySummaryState(filters: filters);
  final all = allRows ?? materialSummaryRows();
  return productionHistorySummaryExportSpec(
    kind: ProductionStockKind.material,
    allRows: all,
    rows: ProductionHistorySummaryBuilder.filterAndSort(
      rows: all,
      filters: state.filters,
      sort: state.sort,
      canSeeQuantity: canSeeQuantity,
    ),
    state: state,
    categoryNames: sampleCategories(),
    period: day2,
    currency: '₦',
    departmentsEnabled: departmentsEnabled,
    canSeeQuantity: canSeeQuantity,
  );
}

void main() {
  test('150 materials: every row, in the screen order', () {
    final many = ProductionHistorySummaryBuilder.build(
      kind: ProductionStockKind.material,
      items: materialItems(manyMaterials(150)),
      entries: const [],
      categoryNames: const {},
      period: day2,
    );
    final t = resolveExport(specFor(allRows: many), testCtx).tables.single;
    expect(t.rows, hasLength(150));
    expect(t.rows.last[0].text, 'Material 150');
  });

  test('cards over every material, whatever the filter', () {
    final s = resolveExport(
      specFor(
        filters: ProductionHistorySummaryFilters(
          movement: ProductionHistoryMovementFilter.inflowOnly,
        ),
      ),
      testCtx,
    ).sections.whereType<ResolvedSummary>().single;
    expect([for (final m in s.metrics) m.label], [
      'Materials With Movement',
      'Used',
      'Transferred to Department',
      'Net Change',
      'History Records',
    ]);
    expect(s.metrics[0].raw, 2);
    expect(s.metrics[1].raw, '1 Bag, 2.5 Kg');
  });

  test('the material columns, totals and masking', () {
    final t = resolveExport(specFor(), testCtx).tables.single;
    expect([for (final c in t.columns) c.label], [
      'Material',
      'Primary Unit',
      'Opening',
      'Used',
      'Restored',
      'Transferred to Department',
      'Transferred to Branch',
      'Transferred In',
      'Manual Increase',
      'Manual Decrease',
      'Created',
      'Deleted',
      'Additions',
      'Reductions',
      'Net',
      'Closing',
      'Records',
    ]);
    final sugar = t.rows.firstWhere((r) => r[0].text == 'Sugar');
    expect(sugar[t.indexOf('used')].raw, 2.5);
    expect(sugar[t.indexOf('net')].text, '-4.5');
    expect(t.totals![t.indexOf('events')].raw, 4);
    final masked = resolveExport(specFor(canSeeQuantity: false), testCtx).tables.single;
    expect(masked.rows.first[masked.indexOf('used')].text, '****');
  });

  test('splits, the note and the roll', () {
    final f = ExportFormatter(currency: '₦');
    final spec = specFor(departmentsEnabled: true);
    expect(spec.splitOptions.map((s) => s.id), ['category', 'department']);
    expect(
      [for (final g in resolveGroups(spec.tables.last, 'category', f)) g.name],
      ['Drinks', 'Pastry', 'No Category'],
    );
    expect(spec.notes.single, contains("can't tell production use from manual use"));
    for (final paper in RollPaper.values) {
      final out = renderRollEscPos(buildRollLines(spec, testCtx, paper: paper), paper).preview;
      final lines = out.split('\n');
      expect(lines.any((l) => l.startsWith('Sugar') && l.endsWith('-4.5')), isTrue);
      expect(lines.every((l) => l.length <= paper.dots ~/ fontBDots), isTrue);
    }
  });
}
