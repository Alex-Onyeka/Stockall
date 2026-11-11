import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/pages/report/components/export/report_export_resolve.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/export/report_roll_builder.dart';
import 'package:stockall/pages/report/production_report/production_records_table/class/production_records_table_logic.dart';
import 'package:stockall/pages/report/production_report/usage_summary/class/usage_summary_export_spec.dart';
import 'package:stockall/pages/report/production_report/usage_summary/class/usage_summary_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/services/printing/escpos_builder.dart' show fontBDots;

import 'item_history_export_fixtures.dart' show testCtx;
import 'production_report_fixtures.dart';
import 'usage_summary_logic_test.dart' show usageSummary, withYesterday, day2;

ReportExportSpec specFor(
  UsageSummaryResult result, {
  ReceiptsReportPeriod? period,
  List<ProductionRecordRow>? records,
  bool departmentsEnabled = true,
  bool canSeeCost = true,
  bool canSeeQuantity = true,
  UsageBreakdownTab activeTab = UsageBreakdownTab.materials,
  UsageBreakdownField? sortField,
  bool ascending = false,
}) {
  return usageSummaryExportSpec(
    result: result,
    allUsages: usageRows(sampleUsages()),
    recordRows: records ?? recordRows(sampleRecords()),
    period: period ?? day2,
    tabs: usageBreakdownTabs(departmentsEnabled: departmentsEnabled),
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
      final s = statsOf(specFor(usageSummary(rows: withYesterday)));
      expect([for (final m in s.metrics) m.label], [
        'Usage Cost',
        'Usage Records',
        'Production Usage',
        'Manual Usage',
        'Materials Used',
      ]);
      final records = s.metrics.firstWhere((m) => m.label == 'Usage Records');
      expect(records.raw, 5);
      // Worded by the General report's generalReportChangeText.
      expect(records.note, '▲ 400.0% vs previous period');
      final production = s.metrics.firstWhere(
        (m) => m.label == 'Production Usage',
      );
      expect(production.raw, 10800);
      // Nothing from productions yesterday: the change is an amount.
      expect(production.note, '▲ ₦10,800.00 vs previous period');
    });

    test('all time: the subtitles, no change', () {
      final s = statsOf(
        specFor(
          usageSummary(
            rows: withYesterday,
            period: const ReceiptsReportPeriod.allTime(),
          ),
          period: const ReceiptsReportPeriod.allTime(),
        ),
      );
      final records = s.metrics.firstWhere((m) => m.label == 'Usage Records');
      expect(records.note, 'Records in this period');
      expect(records.raw, 6);
    });

    test('no cost permission: the split in records', () {
      final s = statsOf(
        specFor(usageSummary(canSeeCost: false), canSeeCost: false),
      );
      expect([for (final m in s.metrics) m.label], [
        'Usage Records',
        'Production Usage',
        'Manual Usage',
        'Materials Used',
      ]);
      expect([for (final m in s.metrics) m.raw], [5, 3, 2, 2]);
    });
  });

  group('breakdown tables', () {
    test('one table per tab the screen offers, no splits', () {
      final spec = specFor(usageSummary());
      expect([for (final t in resolveExport(spec, testCtx).tables) t.title], [
        'Materials',
        'Source',
        'Staff',
        'Departments',
      ]);
      expect(spec.splitOptions, isEmpty);
      final narrow = specFor(
        usageSummary(departmentsEnabled: false),
        departmentsEnabled: false,
      );
      expect([for (final t in resolveExport(narrow, testCtx).tables) t.title], [
        'Materials',
        'Source',
        'Staff',
      ]);
    });

    test('columns and cells as on screen', () {
      final t = tableNamed(specFor(usageSummary()), 'Materials');
      expect([for (final c in t.columns) c.label], [
        'Material',
        'Records',
        'Qty Used',
        'Cost',
        'Avg Unit Cost',
        'Last Used',
        'Share',
      ]);
      final flour = t.rows.first;
      expect(flour[0].text, 'Flour');
      expect(flour[t.indexOf('quantity')].text, '2.25 Bag');
      expect(flour[t.indexOf('quantity')].raw, 2.25);
      expect(flour[t.indexOf('unitCost')].text, '₦5,000.00');
      expect(flour[t.indexOf('lastDate')].text, 'Oct 2, 2026');
    });

    test('the active tab is sorted like the screen; none stays last', () {
      final spec = specFor(
        usageSummary(),
        activeTab: UsageBreakdownTab.staff,
        sortField: UsageBreakdownField.count,
        ascending: true,
      );
      final staff = tableNamed(spec, 'Staff');
      expect([for (final r in staff.rows) r[0].text], [
        'Ada',
        'Ben',
        productionNoStaffLabel,
      ]);
      // Another tab keeps its built order (cost share, largest first).
      final source = tableNamed(spec, 'Source');
      expect([for (final r in source.rows) r[0].text], ['Production', 'Manual']);
    });

    test('no cost or quantity permission: no money or quantity columns', () {
      final t = tableNamed(
        specFor(
          usageSummary(canSeeCost: false, canSeeQuantity: false),
          canSeeCost: false,
          canSeeQuantity: false,
        ),
        'Materials',
      );
      expect([for (final c in t.columns) c.label], [
        'Material',
        'Records',
        'Last Used',
        'Share',
      ]);
    });
  });

  group('notes and roll', () {
    test('the notes are the screen notes', () {
      expect(specFor(usageSummary()).notes, isEmpty);
      expect(
        specFor(
          usageSummary(),
          records: recordRows([...sampleRecords(), legacyRecord()]),
        ).notes,
        [
          "1 earlier production has no usage records and isn't included. "
              'Their materials appear in the Production Records report.',
        ],
      );
    });

    test('58mm and 80mm: name and cost on one line, within the paper', () {
      for (final paper in RollPaper.values) {
        final out = renderRollEscPos(
          buildRollLines(specFor(usageSummary()), testCtx, paper: paper),
          paper,
        ).preview;
        final lines = out.split('\n');
        expect(
          lines.any((l) => l.startsWith('Flour') && l.endsWith('N11,250.00')),
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
