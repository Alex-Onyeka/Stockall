import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/pages/report/components/export/report_export_resolve.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/export/report_roll_builder.dart';
import 'package:stockall/pages/report/production_report/production_records_table/class/production_records_table_logic.dart';
import 'package:stockall/pages/report/production_report/production_summary/class/production_summary_export_spec.dart';
import 'package:stockall/pages/report/production_report/production_summary/class/production_summary_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/services/printing/escpos_builder.dart' show fontBDots;

import 'item_history_export_fixtures.dart' show testCtx;
import 'production_report_fixtures.dart';
import 'production_summary_logic_test.dart' show summary, day2;

/// The day before 2 Oct has one ₦4,000 run, so Today has changes.
final withYesterday = recordRows([
  ...sampleRecords(),
  productionRecord(
    uuid: 'prod-0',
    createdAt: oct(1, 10),
    quantity: 20,
    units: donutUnits(),
    totalCost: 4000,
  ),
]);

ReportExportSpec specFor(
  ProductionSummaryResult result, {
  ReceiptsReportPeriod? period,
  bool departmentsEnabled = true,
  bool canSeeCost = true,
  bool canSeeQuantity = true,
  ProductionBreakdownTab activeTab = ProductionBreakdownTab.outputItems,
  ProductionBreakdownField? sortField,
  bool ascending = false,
}) {
  final tabs = productionBreakdownTabs(
    departmentsEnabled: departmentsEnabled,
    canSeeQuantity: canSeeQuantity,
  );
  return productionSummaryExportSpec(
    result: result,
    period: period ?? day2,
    tabs: tabs,
    activeTab: activeTab,
    sortField: sortField,
    ascending: ascending,
    currency: '₦',
    canSeeCost: canSeeCost,
    canSeeQuantity: canSeeQuantity,
  );
}

ResolvedSummary statsOf(ReportExportSpec spec) =>
    resolveExport(spec, testCtx).sections.whereType<ResolvedSummary>().single;

ResolvedTable tableNamed(ReportExportSpec spec, String title) =>
    resolveExport(spec, testCtx).tables.firstWhere((t) => t.title == title);

void main() {
  group('statistics', () {
    test('the cards, with the change against the previous period', () {
      final s = statsOf(specFor(summary(rows: withYesterday)));
      expect([for (final m in s.metrics) m.label], [
        'Production Runs',
        'Recorded Cost',
        'Material Cost',
        'Average Cost per Run',
        'Cost Variance',
        'Items Produced',
        'Materials Used',
        'Staff Involved',
      ]);
      final runs = s.metrics.first;
      expect(runs.raw, 3);
      // Worded by the General report's generalReportChangeText.
      expect(runs.note, '▲ 200.0% vs previous period');
      final material = s.metrics.firstWhere((m) => m.label == 'Material Cost');
      // Nothing yesterday: the change is an amount, not a percentage.
      expect(material.note, '▲ ₦10,800.00 vs previous period');
      final variance = s.metrics.firstWhere((m) => m.label == 'Cost Variance');
      expect(variance.note, 'Recorded minus material cost');
    });

    test('all time: the subtitles, no change', () {
      final s = statsOf(
        specFor(
          summary(rows: withYesterday, period: const ReceiptsReportPeriod.allTime()),
          period: const ReceiptsReportPeriod.allTime(),
        ),
      );
      expect(s.metrics.first.note, 'Records in this period');
      expect(s.metrics.first.raw, 4);
    });

    test('no cost permission: no cost cards', () {
      final s = statsOf(specFor(summary(canSeeCost: false), canSeeCost: false));
      expect([for (final m in s.metrics) m.label], [
        'Production Runs',
        'Items Produced',
        'Materials Used',
        'Staff Involved',
      ]);
    });
  });

  group('breakdown tables', () {
    test('one table per tab the screen offers, no splits', () {
      final spec = specFor(summary());
      expect([for (final t in resolveExport(spec, testCtx).tables) t.title], [
        'Output Items',
        'Materials',
        'Yield',
        'Staff',
        'Departments',
      ]);
      expect(spec.splitOptions, isEmpty);
      final narrow = specFor(
        summary(departmentsEnabled: false, canSeeQuantity: false),
        departmentsEnabled: false,
        canSeeQuantity: false,
      );
      expect([for (final t in resolveExport(narrow, testCtx).tables) t.title], [
        'Output Items',
        'Materials',
        'Staff',
      ]);
    });

    test('columns and cells as on screen', () {
      final t = tableNamed(specFor(summary()), 'Output Items');
      expect([for (final c in t.columns) c.label], [
        'Output Item',
        'Runs',
        'Qty Produced',
        'Recorded Cost',
        'Material Cost',
        'Avg Cost / Unit',
        'Min / Unit',
        'Max / Unit',
        'Last Production',
        'Share',
      ]);
      final donut = t.rows.first;
      expect(donut[0].text, 'Donut');
      expect(donut[t.indexOf('quantity')].text, '66 Pcs');
      expect(donut[t.indexOf('quantity')].raw, 66);
      expect(donut[t.indexOf('maxCostPerUnit')].text, '₦200.00');
      expect(donut[t.indexOf('lastDate')].text, 'Oct 2, 2026');
    });

    test("yield: Alex's 0.0333 bag a donut", () {
      final t = tableNamed(
        specFor(summary(rows: recordRows([AlexExample().record]))),
        'Yield',
      );
      final row = t.rows.single;
      expect(row[t.indexOf('name')].text, 'Donut');
      expect(row[t.indexOf('sublabel')].text, 'Flour');
      expect(row[t.indexOf('ratio')].text, '0.0333 Bag / Pcs');
      expect(row[t.indexOf('costPerUnit')].text, '₦166.67');
    });

    test('the active tab is sorted like the screen; none stays last', () {
      final spec = specFor(
        summary(),
        activeTab: ProductionBreakdownTab.staff,
        sortField: ProductionBreakdownField.count,
        ascending: true,
      );
      final staff = tableNamed(spec, 'Staff');
      expect(staff.rows.last[0].text, productionNoStaffLabel);
      // Another tab keeps its built order (cost share, largest first).
      final materials = tableNamed(spec, 'Materials');
      expect([for (final r in materials.rows) r[0].text], [
        'Flour',
        'Sugar',
        productionNoMaterialsLabel,
      ]);
    });

    test('no cost permission: no money columns', () {
      final t = tableNamed(
        specFor(summary(canSeeCost: false), canSeeCost: false),
        'Staff',
      );
      expect([for (final c in t.columns) c.label], [
        'Staff',
        'Runs',
        'Last Production',
        'Share',
      ]);
    });
  });

  group('notes and roll', () {
    test('the notes are the screen notes', () {
      expect(specFor(summary()).notes, [
        '1 record uses a custom cost; Variance shows the difference from '
            'the materials.',
      ]);
    });

    test('58mm and 80mm: name and cost on one line, within the paper', () {
      for (final paper in RollPaper.values) {
        final out = renderRollEscPos(
          buildRollLines(specFor(summary()), testCtx, paper: paper),
          paper,
        ).preview;
        final lines = out.split('\n');
        expect(
          lines.any((l) => l.startsWith('Donut') && l.endsWith('N12,200.00')),
          isTrue,
          reason: paper.name,
        );
        expect(
          lines.every((l) => l.length <= paper.dots ~/ fontBDots),
          isTrue,
          reason: paper.name,
        );
      }
    });
  });
}
