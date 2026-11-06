import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_categories/category_class.dart';
import 'package:stockall/classes/temp_departments_class/department_class.dart';
import 'package:stockall/pages/report/components/export/report_export_format.dart';
import 'package:stockall/pages/report/components/export/report_export_resolve.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/export/report_pdf_builder.dart';
import 'package:stockall/pages/report/components/export/report_roll_builder.dart';
import 'package:stockall/pages/report/items_report_/items_report_analysis/class/items_report_analysis_export_spec.dart';
import 'package:stockall/pages/report/items_report_/items_report_analysis/class/items_report_analysis_logic.dart';
import 'package:stockall/pages/report/items_report_/items_report_analysis/components/items_report_analysis_view.dart';
import 'package:stockall/pages/report/items_report_/items_report_main/class/items_report_main_logic.dart';

import 'item_history_export_fixtures.dart';
import 'report_export_screen_harness.dart';

final categories = [
  for (final e in categoryNames.entries)
    CategoryClass(
      name: e.value,
      shopId: 1,
      uuid: e.key,
      departmentId: null,
      departmentName: null,
    ),
];
final departments = [
  for (final e in departmentNames.entries)
    DepartmentClass(
      uuid: e.key,
      createdAt: DateTime(2026),
      shopId: 1,
      name: e.value,
    ),
];

/// The summary sample plus a fresh item (created yesterday, so it is
/// "newly created") and an un-managed service. Built on first use, after
/// the environment is set up.
final rows = ItemsReportRowBuilder.buildAll(
  products: [
    ...summaryProducts.where((p) => p.uuid != 'sheet'),
    sheetProduct()..createdAt = DateTime.now().subtract(const Duration(days: 1)),
    makeProduct(uuid: 'svc', name: 'Service', quantity: null),
  ],
  categories: categories,
);

const best = [
  ItemPerformanceRecord(
    uuid: 'coke',
    name: 'Coke',
    primaryUnit: 'Bottle(s)',
    sellingPrice: 125,
    costPrice: 100,
    currentQuantity: 5,
    salesRevenue: 1250000,
    unitsSold: 10000,
    realizedProfit: 250000,
    salesCount: 40,
  ),
  ItemPerformanceRecord(
    uuid: 'pie',
    name: 'Meat Pie',
    primaryUnit: 'Pcs',
    sellingPrice: 500,
    costPrice: 300,
    currentQuantity: 7,
    salesRevenue: 6000,
    unitsSold: 12,
    realizedProfit: 2400,
    salesCount: 3,
  ),
];
const least = [
  ItemPerformanceRecord(
    uuid: 'juice',
    name: 'Juice',
    primaryUnit: 'Bottle(s)',
    sellingPrice: 100,
    costPrice: 60,
    currentQuantity: 4,
    salesRevenue: 0,
    unitsSold: 0,
    realizedProfit: 0,
    salesCount: 0,
  ),
];

ReportExportSpec specFor({
  ItemPerformanceMetric metric = ItemPerformanceMetric.salesRevenue,
  bool canSeeCost = true,
  bool departmentsEnabled = true,
  String periodLabel = 'Today',
}) {
  return itemsAnalysisExportSpec(
    summary: ItemsReportAnalysisBuilder.buildSummary(rows),
    best3: best,
    least3: least,
    metric: metric,
    categoryDist: ItemsReportAnalysisBuilder.computeCategoryDistribution(
      rows: rows,
      categories: categories,
    ),
    departmentDist: ItemsReportAnalysisBuilder.computeDepartmentDistribution(
      rows: rows,
      departments: departments,
    ),
    recentItems: ItemsReportAnalysisBuilder.getNewlyCreatedItems(rows),
    periodLabel: periodLabel,
    currency: '₦',
    canSeeCost: canSeeCost,
    departmentsEnabled: departmentsEnabled,
  );
}

ResolvedExport resolved(ReportExportSpec spec) => resolveExport(spec, testCtx);

Map<String, ResolvedMetric> metricsOf(ReportExportSpec spec, String title) {
  final s = resolved(spec)
      .sections
      .whereType<ResolvedSummary>()
      .firstWhere((s) => s.title == title);
  return {for (final m in s.metrics) m.label: m};
}

ResolvedTable tableNamed(ReportExportSpec spec, String title) =>
    resolved(spec).tables.firstWhere((t) => t.title == title);

List<String> column(ResolvedTable t, String id) => [
  for (final r in t.rows) r[t.indexOf(id)].text,
];

void main() {
  // Building item rows reads the shop (Supabase, Hive), as on screen.
  setUpAll(setUpScreenEnvironment);
  tearDownAll(() async => Hive.close());

  group('sections', () {
    test('figures, then the screen tables; no charts, no splits', () {
      final spec = specFor();
      expect(spec.sections.map((s) => s.title), [
        'Inventory Summary',
        'Stock Classification',
        'Best 3 Performing Items',
        'Least 3 Performing Items',
        'Category Distribution',
        'Department Distribution',
        'Newly Created Items',
      ]);
      expect(spec.splitOptions, isEmpty);
      expect(spec.reportName, 'Items Report Analysis');
      expect(spec.fileSlug, 'items_analysis');
      expect(
        specFor(departmentsEnabled: false).sections.map((s) => s.title),
        isNot(contains('Department Distribution')),
      );
    });
  });

  group('figures', () {
    test('the screen summary, money in full', () {
      final summary = ItemsReportAnalysisBuilder.buildSummary(rows);
      final m = metricsOf(specFor(), 'Inventory Summary');
      expect(m['Stock Selling Value']!.raw, summary.totalStockSellingValue);
      expect(m['Stock Cost Value']!.raw, summary.totalStockCostValue);
      expect(m['Potential Profit']!.raw, summary.totalPotentialProfit);
      expect(m['Potential Profit']!.note, startsWith('Margin '));
      expect(m['Available Stock Items']!.raw, summary.totalDistinctItems);
      expect(
        m['Available Stock Items']!.note,
        '${summary.managedCount} Managed • ${summary.unmanagedCount} Unmanaged',
      );
      expect(m['Stock Selling Value']!.text, startsWith('₦'));

      final c = metricsOf(specFor(), 'Stock Classification');
      expect(c['In Stock']!.raw, summary.inStockCount);
      expect(c['Low in Stock']!.raw, summary.lowStockCount);
      expect(c['Out of Stock']!.raw, summary.outOfStockCount);
      expect(c['Managed']!.raw, summary.managedCount);
      expect(c['Un-Managed']!.raw, 1);
    });

    test('cost figures "Restricted" without cost access, as on screen', () {
      final m = metricsOf(specFor(canSeeCost: false), 'Inventory Summary');
      expect(m['Stock Cost Value']!.text, 'Restricted');
      expect(m['Potential Profit']!.text, 'Restricted');
      expect(m['Potential Profit']!.note, 'Permission Required');
      expect(m['Stock Selling Value']!.raw, isA<num>());
    });
  });

  group('tables', () {
    test('best / least 3 for the selected metric', () {
      final b = tableNamed(specFor(), 'Best 3 Performing Items');
      expect(column(b, 'rank'), ['1', '2']);
      expect(column(b, 'name'), ['Coke', 'Meat Pie']);
      expect(b.columns[b.indexOf('value')].label, 'Sales Revenue');
      expect(column(b, 'value'), ['₦1,250,000.00', '₦6,000.00']);
      expect(column(b, 'sell'), ['₦125.00', '₦500.00']);

      final u = tableNamed(
        specFor(metric: ItemPerformanceMetric.unitsSold),
        'Best 3 Performing Items',
      );
      expect(u.columns[u.indexOf('value')].label, 'Units Sold');
      expect(u.rows.first[u.indexOf('value')].raw, 10000);
      expect(
        column(tableNamed(specFor(), 'Least 3 Performing Items'), 'name'),
        ['Juice'],
      );
    });

    test('category distribution with "Others"; departments', () {
      final cats = tableNamed(specFor(), 'Category Distribution');
      expect(column(cats, 'name'), containsAll(['Drinks', 'Bakery', 'Others']));
      expect(column(cats, 'name').last, 'Others');
      final drinks = cats.rows.firstWhere((r) => r[0].text == 'Drinks');
      expect(drinks[cats.indexOf('items')].raw, 2);
      expect(drinks[cats.indexOf('share')].raw, isA<num>());
      final depts = tableNamed(specFor(), 'Department Distribution');
      expect(column(depts, 'name'), containsAll(['Front Shop', 'Back Store']));
    });

    test('newly created items with their stock text', () {
      final t = tableNamed(specFor(), 'Newly Created Items');
      expect(column(t, 'name'), ['Acrylic Sheet']);
      expect(column(t, 'stock'), ['3 Sheets (4 x 2)']);
      final svc = rows.firstWhere((r) => r.name == 'Service');
      final f = ExportFormatter(currency: '₦');
      expect(itemsAnalysisStockText(svc, f), 'Unmanaged');
    });
  });

  group('info box', () {
    test('period and the performance metric', () {
      final spec = specFor(
        metric: ItemPerformanceMetric.unitsSold,
        periodLabel: 'This Month',
      );
      final info = {
        for (final e in reportPdfInfoEntries(resolved(spec))) e.$1: e.$2,
      };
      expect(info['Period'], 'This Month');
      expect(info['Filters Applied'], 'Performance metric: Units Sold');
      final f = ExportFormatter(currency: '₦');
      expect(
        itemsAnalysisPeriodLabel(
          ItemAnalysisPeriod.custom,
          DateTimeRange(start: DateTime(2026, 10, 1), end: DateTime(2026, 10, 9)),
          f,
        ),
        'Oct 1, 2026 - Oct 9, 2026',
      );
      expect(itemsAnalysisPeriodLabel(ItemAnalysisPeriod.today, null, f), 'Today');
    });
  });

  group('roll', () {
    String preview(RollPaper paper) => renderRollEscPos(
      buildRollLines(specFor(), testCtx, paper: paper),
      paper,
    ).preview;

    for (final paper in RollPaper.values) {
      test('${paper.name}: Metric · Value pairs, amounts on one line', () {
        final text = preview(paper);
        final out = text.split('\n');
        final selling = out.firstWhere((l) => l.startsWith('Stock Selling Value'));
        expect(selling, endsWith('.00'));
        final coke = out.firstWhere((l) => l.contains('Coke'));
        expect(coke, endsWith('N1,250,000.00'));
        expect(out.every((l) => l.length <= paper.chars), isTrue);
        expect(text, contains('In Stock'));
      });
    }
  });

  group('Analysis screen', () {
    for (final desktop in [true, false]) {
      testWidgets('shows the Export pill (${desktop ? 'desktop' : 'mobile'})', (
        tester,
      ) async {
        await pumpReportScreen(
          tester,
          ItemsReportAnalysisView(isDesktop: desktop),
          desktop: desktop,
        );
        // Next to the period selector at every width (no "View" toggle).
        expect(find.text('Export'), findsOneWidget);
      });
    }
  });
}
