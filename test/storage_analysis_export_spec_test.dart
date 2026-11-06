import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_departments_class/department_class.dart';
import 'package:stockall/pages/report/components/export/report_export_resolve.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/export/report_pdf_builder.dart';
import 'package:stockall/pages/report/components/export/report_roll_builder.dart';
import 'package:stockall/pages/report/storage_items_report_/storage_item_history_summary/class/storage_item_history_summary_logic.dart';
import 'package:stockall/pages/report/storage_items_report_/storage_report_analysis/class/storage_report_analysis_export_spec.dart';
import 'package:stockall/pages/report/storage_items_report_/storage_report_analysis/class/storage_report_analysis_logic.dart';
import 'package:stockall/pages/report/storage_items_report_/storage_report_analysis/components/storage_report_analysis_view.dart';
import 'package:stockall/pages/report/storage_items_report_/storage_report_main/class/storage_report_main_logic.dart';
import 'package:stockall/services/printing/escpos_builder.dart' show fontBDots;

import 'item_history_export_fixtures.dart' show testCtx;
import 'report_export_screen_harness.dart';
import 'storage_report_analysis_test.dart' show record, salesItem, storageItem;

final businessNow = DateTime(2026, 10, 20, 16);

// Flour (₦1,250,000 of stock) supplies the Bakery; Sheets (2D) supplies
// nothing; Salt has no cost and is out of stock.
final storage = [
  storageItem(
    uuid: 's-flour',
    name: 'Flour',
    quantity: 50,
    costPrice: 25000,
    unitName: 'Bags',
    createdAt: DateTime(2026, 10, 10),
  ),
  storageItem(
    uuid: 's-sheet',
    name: 'Sheets',
    quantity: 3,
    costPrice: 100,
    unitName: 'Sheets',
    twoD: true,
    createdAt: DateTime(2026, 10, 12),
  ),
  storageItem(uuid: 's-salt', name: 'Salt', quantity: 0, costPrice: null, unitName: 'Kg'),
];
final sales = [
  salesItem(uuid: 'p-1', quantity: 2, storageUuid: 's-flour', departmentUuid: 'bakery'),
];
final departments = [
  DepartmentClass(uuid: 'bakery', createdAt: DateTime(2026), shopId: 1, name: 'Bakery'),
];
final histories = [
  record(
    storageItemUuid: 's-flour',
    event: 'transfered_out',
    createdAt: DateTime(2026, 10, 20, 9),
    oldValue: '55',
    newValue: '50',
    unitName: 'Bags',
  ),
];

final rows = StorageReportRowBuilder.buildAll(storageProducts: storage, salesProducts: sales);

ReportExportSpec specFor({
  bool canSeeCost = true,
  bool departmentsEnabled = true,
  StorageHistoryPeriod period = StorageHistoryPeriod.allTime,
  DateTimeRange? customRange,
  StoragePerformanceMetric metric = StoragePerformanceMetric.transferredOut,
}) {
  final records = StorageReportAnalysisBuilder.computePerformance(
    rows: rows,
    storageProducts: storage,
    histories: histories,
    period: period,
    businessNow: businessNow,
    customRange: customRange,
  );
  return storageAnalysisExportSpec(
    summary: StorageReportAnalysisBuilder.buildSummary(rows),
    records: records,
    best3: StorageReportAnalysisBuilder.getBest3(records: records, metric: metric),
    least3: StorageReportAnalysisBuilder.getLeast3(records: records, metric: metric),
    idle: StorageReportAnalysisBuilder.getIdleItems(records),
    metric: metric,
    departmentDist: StorageReportAnalysisBuilder.computeDepartmentDistribution(
      rows: rows,
      departments: departments,
    ),
    typeDist: StorageReportAnalysisBuilder.computeQuantityTypeDistribution(rows),
    recentItems: StorageReportAnalysisBuilder.getNewlyCreatedItems(rows, limit: 10),
    period: period,
    customRange: customRange,
    resolvedRange: StorageHistorySummaryBuilder.resolveDateRange(
      period: period,
      businessNow: businessNow,
      customRange: customRange,
    ),
    canSeeCost: canSeeCost,
    departmentsEnabled: departmentsEnabled,
    currency: '₦',
  );
}

ResolvedExport resolved(ReportExportSpec s) => resolveExport(s, testCtx);

Map<String, ResolvedMetric> metrics(ReportExportSpec s, String title) => {
  for (final m in resolved(s)
      .sections
      .whereType<ResolvedSummary>()
      .firstWhere((x) => x.title == title)
      .metrics)
    m.label: m,
};

ResolvedTable table(ReportExportSpec s, String prefix) =>
    resolved(s).tables.firstWhere((t) => t.title.startsWith(prefix));

List<String> col(ResolvedTable t, String id) => [
  for (final r in t.rows) r[t.indexOf(id)].text,
];

void main() {
  group('sections', () {
    test('cards, status, rankings, distributions, newly created; no splits', () {
      final spec = specFor();
      expect(spec.sections.map((s) => s.title.split(' (').first), [
        'Statistics',
        'Stock Status',
        'Most Active 3',
        'Least Active 3',
        'Department Distribution',
        'Quantity Type Distribution',
        'Newly Created Items',
      ]);
      expect(spec.splitOptions, isEmpty);
      expect(
        specFor(departmentsEnabled: false).sections.map((s) => s.title),
        isNot(contains('Department Distribution')),
      );
    });
  });

  group('figures', () {
    test('the cards, with cost gating as on screen', () {
      final s = StorageReportAnalysisBuilder.buildSummary(rows);
      final m = metrics(specFor(), 'Statistics');
      expect(m['Stock Cost Value']!.raw, s.totalStockCostValue);
      expect(m['Stock Cost Value']!.note, '1 item has no cost price');
      expect(m['Storage Items']!.text, '3 Items');
      expect(m['Storage Items']!.note, '2 Simple • 1 2-Dimensional');
      expect(m['Linked To Sales Items']!.text, '1 of 3');
      expect(m['Stock In Storage']!.text, '${s.stockByPrimaryUnit.length} Units');
      final locked = metrics(specFor(canSeeCost: false), 'Statistics');
      expect(locked['Stock Cost Value']!.text, 'Restricted');
      expect(locked['Stock Cost Value']!.note, 'Permission Required');
      final status = metrics(specFor(), 'Stock Status');
      expect(status['In Stock']!.raw, s.inStockCount);
      expect(status['Out of Stock']!.note, '33%');
    });
  });

  group('tables', () {
    test('rankings by the chosen metric, distributions and newly created', () {
      final spec = specFor();
      final best = table(spec, 'Most Active 3');
      expect(best.title, 'Most Active 3 (Transferred Out)');
      expect(col(best, 'name').first, 'Flour');
      expect(col(best, 'value').first, '5.0 Bags');
      expect(col(table(spec, 'Department Distribution'), 'name'), ['Bakery', 'Unlinked']);
      expect(col(table(spec, 'Quantity Type Distribution'), 'share'), ['66.7%', '33.3%']);
      final recent = table(spec, 'Newly Created Items');
      expect(col(recent, 'name'), ['Sheets', 'Flour', 'Salt']);
      expect(col(recent, 'stock'), ['3 Sheets (2 x 3)', '50 Bags', 'Out of Stock']);
      expect(col(recent, 'created').last, 'Date not set');
      final byCount = table(specFor(metric: StoragePerformanceMetric.movementCount), 'Most Active 3');
      expect(col(byCount, 'value').first, '1 movement');
    });
  });

  group('info box and notes', () {
    test('the idle line and, with departments, the distribution footnote', () {
      final spec = specFor();
      expect(spec.notes, [
        '2 of 3 storage items had no stock movement in this period. '
            'Quantities are in each item\'s primary unit.',
        storageAnalysisDepartmentFootnote,
      ]);
      expect(specFor(departmentsEnabled: false).notes, hasLength(1));
      final info = {
        for (final e in reportPdfInfoEntries(resolved(spec))) e.$1: e.$2,
      };
      expect(info['Notes'], spec.notes.join('\n'));
      expect(spec.period!.label, 'All Time');
      expect(specFor(period: StorageHistoryPeriod.today).period!.label, 'Today');
    });
  });

  group('roll', () {
    for (final paper in RollPaper.values) {
      test('${paper.name}: pairs and tables fit, 2D stock on one line', () {
        final out = renderRollEscPos(
          buildRollLines(specFor(), testCtx, paper: paper),
          paper,
        ).preview.split('\n');
        expect(out.every((l) => l.length <= paper.dots ~/ fontBDots), isTrue);
        expect(out.any((l) => l.startsWith('Sheets') && l.endsWith('3 Sheets (2 x 3)')), isTrue);
        final cost = out.where((l) => l.contains('N1,250,300.00')).toList();
        expect(cost, isNotEmpty);
        expect(cost.every((l) => l.length <= paper.chars), isTrue);
      });
    }
  });

  group('Storage analysis screen', () {
    setUpAll(setUpScreenEnvironment);
    tearDownAll(() async => Hive.close());

    for (final desktop in [true, false]) {
      testWidgets('shows the Export pill (${desktop ? 'desktop' : 'mobile'})', (
        tester,
      ) async {
        await pumpReportScreen(
          tester,
          StorageReportAnalysisView(isDesktop: desktop),
          desktop: desktop,
        );
        // Beside the period selector at every width (no "View" toggle).
        expect(find.text('Export'), findsOneWidget);
      });
    }
  });
}
