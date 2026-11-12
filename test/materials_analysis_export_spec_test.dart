import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/pages/report/components/export/report_export_resolve.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/export/report_roll_builder.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/stock_analysis_export_spec.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/stock_analysis_logic.dart';
import 'package:stockall/services/printing/escpos_builder.dart' show fontBDots;

import 'item_history_export_fixtures.dart' show testCtx;
import 'materials_analysis_logic_test.dart' show materialAnalysis, day2;

ReportExportSpec specFor(
  ProductionStockAnalysis a, {
  bool canSeeCost = true,
  bool canSeeQuantity = true,
  ProductionStockAnalysisTab activeTab = ProductionStockAnalysisTab.usedQuantity,
}) => productionStockAnalysisExportSpec(
  analysis: a,
  period: day2,
  tabs: a.tabs.keys.toList(),
  activeTab: activeTab,
  sortField: null,
  ascending: false,
  currency: '₦',
  canSeeCost: canSeeCost,
  canSeeQuantity: canSeeQuantity,
  historyAllowed: true,
);

void main() {
  test('the cards, with the usage cost change', () {
    final s = resolveExport(specFor(materialAnalysis()), testCtx)
        .sections
        .whereType<ResolvedSummary>()
        .single;
    expect([for (final m in s.metrics) m.label], [
      'Materials',
      'Stock Value',
      'Low Stock',
      'Out of Stock',
      'Expired or Expiring',
      'Used',
      'Usage Cost',
    ]);
    expect(s.metrics[5].raw, '3.25 Bag, 2.5 Kg');
    expect(s.metrics[5].note, 'Mixed units: no comparison');
    expect(s.metrics[6].raw, 17250);
    expect(s.metrics[6].note, '▲ ₦17,250.00 vs previous period');
  });

  test('one table per tab, no splits; unused and quantities', () {
    final spec = specFor(materialAnalysis());
    final tables = resolveExport(spec, testCtx).tables.toList();
    expect([for (final t in tables) t.title], [
      'Most Used (Qty)',
      'Most Used (Cost)',
      'Unused',
      'Departments',
      'Categories',
      'Cost Changes',
    ]);
    expect(spec.splitOptions, isEmpty);
    final used = tables.first;
    expect(used.rows.first[used.indexOf('usedTotal')].text, '3.25 Bag');
    final unused = tables[2];
    expect(unused.rows.single[0].text, 'Yeast');
    expect(unused.rows.single[unused.indexOf('lastUsed')].text, '—');
    final masked = resolveExport(
      specFor(materialAnalysis(canSeeQuantity: false), canSeeQuantity: false),
      testCtx,
    ).tables.firstWhere((t) => t.title == 'Unused');
    expect([for (final c in masked.columns) c.id], isNot(contains('stock')));
  });

  test('without the quantity permission: stock value masked, no column', () {
    final a = materialAnalysis(canSeeQuantity: false);
    final resolved = resolveExport(
      specFor(a, canSeeQuantity: false, activeTab: ProductionStockAnalysisTab.unused),
      testCtx,
    );
    final stats = resolved.sections.whereType<ResolvedSummary>().single;
    expect(
      stats.metrics.firstWhere((m) => m.label == 'Stock Value').raw,
      '****',
    );
    for (final title in ['Departments', 'Categories']) {
      final t = resolved.tables.firstWhere((t) => t.title == title);
      expect([for (final c in t.columns) c.id], isNot(contains('stockValue')));
    }
  });

  test('notes and roll', () {
    final spec = specFor(materialAnalysis());
    expect(spec.notes, hasLength(2));
    for (final paper in RollPaper.values) {
      final out = renderRollEscPos(buildRollLines(spec, testCtx, paper: paper), paper).preview;
      final lines = out.split('\n');
      expect(lines.any((l) => l.startsWith('Flour') && l.endsWith('3.25 Bag')), isTrue);
      expect(lines.every((l) => l.length <= paper.dots ~/ fontBDots), isTrue);
    }
  });
}
