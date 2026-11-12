import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/pages/report/components/export/report_export_resolve.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/export/report_roll_builder.dart';
import 'package:stockall/pages/report/production_report/production_records_table/class/production_records_table_logic.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/stock_analysis_export_spec.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/stock_analysis_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/services/printing/escpos_builder.dart' show fontBDots;

import 'item_history_export_fixtures.dart' show testCtx;
import 'produced_items_analysis_logic_test.dart' show analysis, day2;

ReportExportSpec specFor(
  ProductionStockAnalysis a, {
  ReceiptsReportPeriod? period,
  ProductionStockAnalysisTab activeTab = ProductionStockAnalysisTab.produced,
  ProductionStockAnalysisField? sortField,
  bool ascending = false,
  bool canSeeCost = true,
  bool canSeeQuantity = true,
  bool historyAllowed = true,
}) => productionStockAnalysisExportSpec(
  analysis: a,
  period: period ?? day2,
  tabs: a.tabs.keys.toList(),
  activeTab: activeTab,
  sortField: sortField,
  ascending: ascending,
  currency: '₦',
  canSeeCost: canSeeCost,
  canSeeQuantity: canSeeQuantity,
  historyAllowed: historyAllowed,
);

ResolvedSummary statsOf(ReportExportSpec spec) =>
    resolveExport(spec, testCtx).sections.whereType<ResolvedSummary>().single;

ResolvedTable tableNamed(ReportExportSpec spec, String title) =>
    resolveExport(spec, testCtx).tables.firstWhere((t) => t.title == title);

void main() {
  group('statistics', () {
    test('the cards, with the change against the previous day', () {
      final s = statsOf(specFor(analysis()));
      expect([for (final m in s.metrics) m.label], [
        'Produced Items',
        'Stock Value',
        'Out of Stock',
        'Expired or Expiring',
        'Produced',
        'Transferred to Sales',
        'Transfer-to-Sales Rate (approx.)',
      ]);
      expect(s.metrics[0].raw, 3);
      expect(s.metrics[1].raw, 3000);
      final produced = s.metrics[4];
      expect(produced.raw, '35 Pcs');
      // Nothing produced the day before: an amount, in pieces.
      expect(produced.note, '▲ 35 vs previous period');
      expect(s.metrics[6].raw, closeTo(15 / 35 * 100, 1e-9));
    });

    test('masked without the quantity permission; no cost card without cost', () {
      final s = statsOf(
        specFor(
          analysis(canSeeCost: false, canSeeQuantity: false),
          canSeeCost: false,
          canSeeQuantity: false,
        ),
      );
      expect([for (final m in s.metrics) m.label], isNot(contains('Stock Value')));
      expect(s.metrics.firstWhere((m) => m.label == 'Produced').raw, '****');
      expect(s.metrics.firstWhere((m) => m.label == 'Out of Stock').raw, '****');
    });
  });

  group('tables', () {
    test('one table per tab the screen offers, no splits', () {
      final spec = specFor(analysis());
      expect([for (final t in resolveExport(spec, testCtx).tables) t.title], [
        'Produced',
        'Transferred to Sales',
        'Net Movement',
        'Departments',
        'Categories',
        'Cost per Unit',
      ]);
      expect(spec.splitOptions, isEmpty);
    });

    test('cells as on screen', () {
      final t = tableNamed(specFor(analysis()), 'Produced');
      expect([for (final c in t.columns) c.label], [
        'Produced Item',
        'Produced',
        'Transferred to Sales',
        'Transfer Rate (approx.)',
        'Net',
      ]);
      final donut = t.rows.first;
      expect(donut[0].text, 'Donut');
      expect(donut[t.indexOf('main')].text, '30 Pcs');
      expect(donut[t.indexOf('main')].raw, 30);
      expect(donut[t.indexOf('rate')].text, '50%');
      final cost = tableNamed(specFor(analysis()), 'Cost per Unit');
      expect(cost.rows.single[cost.indexOf('costPrice')].text, '₦200.00');
    });

    test('the active tab sorted like the screen; none stays last', () {
      final spec = specFor(
        analysis(),
        activeTab: ProductionStockAnalysisTab.departments,
        sortField: ProductionStockAnalysisField.name,
        ascending: false,
      );
      final depts = tableNamed(spec, 'Departments');
      expect([for (final r in depts.rows) r[0].text], [
        'Kitchen',
        'Bakery',
        productionNoDepartmentLabel,
      ]);
      // Another tab keeps its built order.
      expect(tableNamed(spec, 'Produced').rows.first[0].text, 'Donut');
    });
  });

  test('notes and roll', () {
    expect(specFor(analysis()).notes.single, contains('approximate'));
    for (final paper in RollPaper.values) {
      final out = renderRollEscPos(
        buildRollLines(specFor(analysis()), testCtx, paper: paper),
        paper,
      ).preview;
      final lines = out.split('\n');
      expect(lines.any((l) => l.startsWith('Donut') && l.endsWith('30 Pcs')), isTrue);
      expect(lines.every((l) => l.length <= paper.dots ~/ fontBDots), isTrue);
    }
  });
}
