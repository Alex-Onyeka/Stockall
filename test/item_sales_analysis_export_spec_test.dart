import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:stockall/pages/report/components/export/report_export_resolve.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/export/report_pdf_builder.dart';
import 'package:stockall/pages/report/components/export/report_roll_builder.dart';
import 'package:stockall/pages/report/sales_report_/item_sales_analysis/class/item_sales_analysis_export_spec.dart';
import 'package:stockall/pages/report/sales_report_/item_sales_analysis/class/item_sales_analysis_logic.dart';
import 'package:stockall/pages/report/sales_report_/item_sales_analysis/components/item_sales_analysis_view.dart';
import 'package:stockall/pages/report/sales_report_/item_sales_report_main/class/item_sales_export_spec.dart'
    show itemSalesCartDiscountInView;
import 'package:stockall/pages/report/sales_report_/item_sales_report_main/class/item_sales_report_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/components/receipts_report_filter_widgets.dart';
import 'package:stockall/services/printing/escpos_builder.dart' show fontBDots;

import 'item_history_export_fixtures.dart' show testCtx;
import 'item_sales_export_spec_test.dart' show base, products, receipts;
import 'item_sales_report_logic_test.dart' show build, categoryNames, line, receipt, run;
import 'report_export_screen_harness.dart';

List<String> notesOf(
  List<ItemSalesRow> rows, {
  ItemSalesVoidFilter voidFilter = ItemSalesVoidFilter.notVoid,
  ReceiptsReportPeriod period = const ReceiptsReportPeriod.allTime(),
  bool canSeeCost = true,
}) => itemSalesAnalysisNotes(
  period: period,
  stats: ItemSalesAnalysisBuilder.stats(rows),
  cartDiscountInView: itemSalesCartDiscountInView(rows),
  voidFilter: voidFilter,
  canSeeCost: canSeeCost,
);

ReportExportSpec specFor(
  List<ItemSalesRow> rows, {
  ItemSalesFilters? filters,
  ReceiptsReportPeriod period = const ReceiptsReportPeriod.allTime(),
  bool canSeeCost = true,
  bool departmentsEnabled = true,
  bool subStaffEnabled = true,
}) {
  final f = filters ?? ItemSalesFilters();
  return itemSalesAnalysisExportSpec(
    stats: ItemSalesAnalysisBuilder.stats(rows),
    items: ItemSalesAnalysisBuilder.sortGroups(
      ItemSalesAnalysisBuilder.items(rows),
      field: ItemSalesGroupSortField.revenue,
      ascending: false,
    ),
    categories: ItemSalesAnalysisBuilder.categories(rows),
    customers: ItemSalesAnalysisBuilder.sortGroups(
      ItemSalesAnalysisBuilder.customers(rows),
      field: ItemSalesGroupSortField.revenue,
      ascending: false,
    ),
    staff: ItemSalesAnalysisBuilder.staff(rows),
    subStaff: ItemSalesAnalysisBuilder.subStaff(rows),
    departments: ItemSalesAnalysisBuilder.departments(rows),
    channels: ItemSalesAnalysisBuilder.channels(rows),
    types: ItemSalesAnalysisBuilder.types(rows),
    filters: f,
    categoryOptions: ItemSalesOptions.categories(categoryNames, rows),
    itemOptions: ItemSalesOptions.items(rows),
    choices: ReceiptsFilterChoices.fromRows([for (final r in rows) r.parent]),
    period: period,
    notes: notesOf(rows, voidFilter: f.voidFilter, period: period, canSeeCost: canSeeCost),
    currency: '₦',
    canSeeCost: canSeeCost,
    departmentsEnabled: departmentsEnabled,
    subStaffEnabled: subStaffEnabled,
  );
}

final sample = run(base);

ResolvedExport resolved(ReportExportSpec s) => resolveExport(s, testCtx);

Map<String, ResolvedMetric> statsOf(ReportExportSpec s) => {
  for (final m in resolved(s).sections.whereType<ResolvedSummary>().single.metrics)
    m.label: m,
};

ResolvedTable table(ReportExportSpec s, String title) =>
    resolved(s).tables.firstWhere((t) => t.title == title);

List<String> col(ResolvedTable t, String id) => [
  for (final r in t.rows) r[t.indexOf(id)].text,
];

void main() {
  group('sections', () {
    test('cards and tables as on screen; no charts, no splits', () {
      final spec = specFor(sample);
      expect(spec.sections.map((s) => s.title), [
        'Statistics',
        'Top 3 Items',
        'Least 3 Items',
        'Top 3 Staff',
        'Least 3 Staff',
        'Payment Channel Summary',
        'Transaction Type Summary',
        'Category Summary',
        'Item Summary',
        'Department Summary',
        'Customer Summary',
        'Staff Summary',
        'Sub-Staff Summary',
      ]);
      expect(spec.splitOptions, isEmpty);
      expect(spec.fileSlug, 'item_sales_analysis');
      final off = specFor(sample, departmentsEnabled: false, subStaffEnabled: false);
      expect(off.sections.map((s) => s.title), isNot(contains('Department Summary')));
      expect(off.sections.map((s) => s.title), isNot(contains('Sub-Staff Summary')));
    });
  });

  group('figures', () {
    test('the screen stats', () {
      final s = ItemSalesAnalysisBuilder.stats(sample);
      final m = statsOf(specFor(sample));
      expect(m['Item Records']!.raw, s.totalLines);
      expect(m['Items Sold']!.raw, s.distinctItems);
      expect(m['Receipts']!.raw, s.receiptCount);
      expect(m['Categories Sold']!.raw, s.distinctCategories);
      expect(m['Total Revenue']!.raw, s.totalRevenue);
      expect(m['Total Profit/Loss']!.raw, s.totalProfit);
      expect(m['Total Profit/Loss']!.note, '${s.costMissingCount} records with a missing cost');
      expect(m['Profit Margin']!.raw, s.margin);
      expect(m['Average Item Revenue']!.raw, s.averageLineRevenue);
      expect(m['Invoice Payment Records']!.raw, 1);
    });

    test('no cost access: no profit cards or columns', () {
      final spec = specFor(sample, canSeeCost: false);
      expect(statsOf(spec).containsKey('Total Profit/Loss'), isFalse);
      expect(statsOf(spec).containsKey('Profit Margin'), isFalse);
      for (final t in resolved(spec).tables) {
        expect(t.indexOf('profit'), -1, reason: t.title);
      }
    });
  });

  group('tables', () {
    test('rankings without Receipts; summaries as on screen', () {
      final spec = specFor(sample);
      final top = table(spec, 'Top 3 Items');
      expect(col(top, 'name').first, 'Cola');
      expect(top.indexOf('receipts'), -1);
      expect(table(spec, 'Item Summary').indexOf('lastDate'), greaterThan(0));
      expect(table(spec, 'Item Summary').indexOf('receipts'), greaterThan(0));
      expect(table(spec, 'Category Summary').indexOf('share'), greaterThan(0));
      expect(col(table(spec, 'Category Summary'), 'name'), contains('Drinks'));
      expect(
        col(table(spec, 'Payment Channel Summary'), 'name'),
        ['Cash', 'Bank', 'Customer Account', 'Split'],
      );
      expect(
        col(table(spec, 'Transaction Type Summary'), 'name'),
        containsAll(['Sales', 'Invoice Payment']),
      );
    });

    test('Item Summary carries every item, not the preview', () {
      final rows = run(build([
        for (var i = 0; i < 25; i++)
          receipt(
            uuid: 'r-$i',
            barcode: '$i',
            items: [line(uuid: 'l-$i', productUuid: 'p-$i', productName: 'Item $i', revenue: 10.0 + i)],
          ),
      ], products: products));
      final t = table(specFor(rows), 'Item Summary');
      expect(t.rows, hasLength(25));
      expect(t.rows.first[t.indexOf('name')].text, 'Item 24');
    });
  });

  group('info box and notes', () {
    test('item and receipt filters', () {
      final filters = ItemSalesFilters(
        receipt: ReceiptsReportFilters(staffKey: 'staff-a'),
        categoryKey: 'c-drinks',
      );
      final spec = specFor(run(base, filters: filters), filters: filters);
      expect([for (final x in spec.filters) '${x.label}: ${x.value}'], [
        'Category: Drinks',
        'Staff: Ada',
      ]);
    });

    test('exactly the screen notes, from the screen conditions', () {
      // All time; Chips has no cost; no cart discount; void hidden.
      expect(specFor(sample).notes, [
        'All time covers the receipts loaded on this device.',
        'Revenue is item revenue (VAT included) on every receipt type: '
            'sales, invoice payments and order deliveries.',
        'Profit includes 1 of 5 item records with a missing cost price '
            '(counted as 0).',
      ]);
      // Void lines shown and a cart discount in view.
      final withDiscount = receipts();
      withDiscount.first.generalDiscount = 5;
      final voidAll = ItemSalesFilters(voidFilter: ItemSalesVoidFilter.all);
      final rows = run(build(withDiscount, products: products), filters: voidAll);
      final notes = specFor(rows, filters: voidAll).notes;
      expect(notes, contains('Void lines are included in these totals.'));
      expect(notes, contains('Cart discounts on a receipt are not included in its item revenue.'));
      // One day, no cost access: only the revenue note.
      final day = specFor(
        sample,
        period: ReceiptsReportPeriod.day(DateTime(2026, 10, 17)),
        canSeeCost: false,
      );
      expect(day.notes, hasLength(1));
      final info = {
        for (final e in reportPdfInfoEntries(resolved(specFor(sample)))) e.$1: e.$2,
      };
      expect(info['Notes'], specFor(sample).notes.join('\n'));
    });
  });

  group('roll', () {
    for (final paper in RollPaper.values) {
      test('${paper.name}: Metric · Value pairs, amounts on one line', () {
        final text = renderRollEscPos(
          buildRollLines(specFor(sample), testCtx, paper: paper),
          paper,
        ).preview;
        final out = text.split('\n');
        expect(out.firstWhere((l) => l.startsWith('Total Revenue')), endsWith('N1,250,880.00'));
        expect(
          out.firstWhere((l) => l.contains('Cola') && l.contains('N1,250,600.00')),
          endsWith('N1,250,600.00'),
        );
        expect(out.every((l) => l.length <= paper.dots ~/ fontBDots), isTrue);
        expect(
          out.where((l) => l.contains('.00')).every((l) => l.length <= paper.chars),
          isTrue,
        );
      });
    }
  });

  group('Item Sales Analysis screen', () {
    setUpAll(setUpScreenEnvironment);
    tearDownAll(() async => Hive.close());

    for (final desktop in [true, false]) {
      testWidgets('shows the Export pill (${desktop ? 'desktop' : 'mobile'})', (
        tester,
      ) async {
        await pumpReportScreen(
          tester,
          ItemSalesAnalysisView(isDesktop: desktop),
          desktop: desktop,
        );
        // In the toolbar at every width (no "View" toggle).
        expect(find.text('Export'), findsOneWidget);
      });
    }
  });
}
