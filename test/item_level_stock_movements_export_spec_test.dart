import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/pages/report/components/export/report_export_format.dart';
import 'package:stockall/pages/report/components/export/report_export_resolve.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/export/report_pdf_builder.dart';
import 'package:stockall/pages/report/components/export/report_roll_builder.dart';
import 'package:stockall/pages/report/items_report_/item_history_summary/class/item_history_summary_export_spec.dart';
import 'package:stockall/pages/report/items_report_/item_history_summary/class/item_history_summary_logic.dart';
import 'package:stockall/pages/report/items_report_/item_level_stock_movements/class/item_level_stock_movements_export_spec.dart';
import 'package:stockall/pages/report/items_report_/item_level_stock_movements/components/item_level_stock_movements_view.dart';

import 'item_history_export_fixtures.dart';
import 'report_export_screen_harness.dart';

final thisMonth = ItemHistorySummaryBuilder.resolveDateRange(
  period: ItemHistoryPeriod.thisMonth,
  businessNow: summaryNow,
);

/// The screen's rows: build, filter, sort, re-index.
List<ItemHistorySummaryRow> screenRows({
  List<TempProductClass>? products,
  ItemHistorySummaryFilters? filters,
  ItemHistorySummarySortField sortField = ItemHistorySummarySortField.rowIndex,
  bool ascending = true,
  bool departmentsEnabled = true,
}) {
  final res = ItemHistorySummaryBuilder.buildSummaryAndRows(
    products: products ?? summaryProducts,
    histories: summaryHistories,
    period: ItemHistoryPeriod.allTime,
    businessNow: summaryNow,
    manageProductions: true,
  );
  final out = ItemHistorySummaryBuilder.filterAndSortRows(
    rows: res.rows,
    filters: filters ?? ItemHistorySummaryFilters(),
    sortField: sortField,
    ascending: ascending,
    departmentsEnabled: departmentsEnabled,
  );
  for (var i = 0; i < out.length; i++) {
    out[i].index = i + 1;
  }
  return out;
}

ReportExportSpec specFor(
  List<ItemHistorySummaryRow> rows, {
  ItemHistorySummaryFilters? filters,
  ItemHistorySummarySortField sortField = ItemHistorySummarySortField.rowIndex,
  bool ascending = true,
  bool manageProductions = true,
  bool departmentsEnabled = true,
}) {
  return itemStockMovementsExportSpec(
    rows: rows,
    filters: filters ?? ItemHistorySummaryFilters(),
    sortField: sortField,
    ascending: ascending,
    period: ItemHistoryPeriod.thisMonth,
    range: thisMonth,
    currency: '₦',
    manageProductions: manageProductions,
    departmentsEnabled: departmentsEnabled,
    categoryNames: categoryNames,
    departmentNames: departmentNames,
    sizeLabels: stockMovementsSizeLabels(summaryProducts),
  );
}

ResolvedTable tableOf(ReportExportSpec spec) =>
    resolveExport(spec, testCtx).tables.single;

ResolvedCell cellOf(ReportExportSpec spec, String item, String columnId) {
  final t = tableOf(spec);
  final row = t.rows.firstWhere((r) => r[t.indexOf('name')].text == item);
  return row[t.indexOf(columnId)];
}

void main() {
  group('rows are the full list, not the 100-row page', () {
    test('150 items, sorted like the screen', () {
      final products = [
        for (var i = 0; i < 150; i++)
          makeProduct(uuid: 'p$i', name: 'Item ${(i * 37) % 150}', quantity: i.toDouble()),
      ];
      final rows = screenRows(
        products: products,
        sortField: ItemHistorySummarySortField.currentQuantity,
        ascending: false,
      );
      final page = ItemHistorySummaryBuilder.paginate(
        rows,
        1,
        pageSize: itemStockMovementsPageSize,
      );
      expect(page.rows, hasLength(100));

      final spec = specFor(
        rows,
        sortField: ItemHistorySummarySortField.currentQuantity,
        ascending: false,
      );
      expect(spec.tables.single.rowCount, 150);
      expect(spec.tables.single.erasedRows, orderedEquals(rows));
      final t = tableOf(spec);
      expect(
        [for (final r in t.rows) r[t.indexOf('name')].text],
        [for (final r in rows) r.name],
      );
      expect(t.rows.first[t.indexOf('current')].raw, 149);
      expect(t.totals![t.indexOf('name')].text, '150 items');
    });
  });

  group('spec', () {
    test('the movement table only, named for the page', () {
      final spec = specFor(screenRows());
      expect(spec.sections, hasLength(1));
      expect(spec.sections.single.title, 'Item Stock Movements');
      expect(spec.reportName, 'Item-Level Stock Movements');
      expect(spec.fileSlug, 'item_stock_movements');
    });

    test('same columns and cells as the summary table', () {
      final spec = specFor(screenRows());
      expect(cellOf(spec, 'Coke', 'sold').raw, -5);
      expect(cellOf(spec, 'Coke', 'sold').text, '-5 Bottle(s)');
      expect(cellOf(spec, 'Acrylic Sheet', 'closing').text, '3 Sheets (4 x 2)');
      final noProd = specFor(screenRows(), manageProductions: false);
      expect(tableOf(noProd).indexOf('produced'), -1);
      expect(tableOf(spec).indexOf('produced'), greaterThan(0));
    });

    test('a search narrows the export like the screen', () {
      final filters = ItemHistorySummaryFilters()..search = 'co';
      final rows = screenRows(filters: filters);
      final t = tableOf(specFor(rows, filters: filters));
      expect([for (final r in t.rows) r[t.indexOf('name')].text], ['Coke']);
      expect(t.totals![t.indexOf('name')].text, '1 item');
    });
  });

  group('splits', () {
    final f = ExportFormatter(currency: '₦');

    test('Category and Department, "No …" last', () {
      final spec = specFor(screenRows());
      expect(spec.splitOptions.map((s) => s.id), ['category', 'department']);
      final cats = resolveGroups(spec.tables.single, 'category', f);
      expect(cats.map((g) => g.name), ['Bakery', 'Drinks', 'No Category']);
      final depts = resolveGroups(spec.tables.single, 'department', f);
      expect(depts.map((g) => g.name), [
        'Back Store',
        'Front Shop',
        'No Department',
      ]);
      expect(
        specFor(screenRows(), departmentsEnabled: false)
            .splitOptions
            .map((s) => s.id),
        ['category'],
      );
    });
  });

  group('info box', () {
    test('period with dates, filters, sort', () {
      final filters = ItemHistorySummaryFilters()
        ..movementFilter = ItemHistoryMovementFilter.outflowOnly
        ..categoryKey = 'c-drinks'
        ..departmentKey = itemHistorySummaryNoneKey;
      final spec = specFor(
        screenRows(filters: filters),
        filters: filters,
        sortField: ItemHistorySummarySortField.sold,
        ascending: false,
      );
      expect({for (final x in spec.filters) x.label: x.value}, {
        'Movement': 'Outflow Only',
        'Category': 'Drinks',
        'Department': 'Unassigned',
      });
      final info = {
        for (final e in reportPdfInfoEntries(resolveExport(spec, testCtx)))
          e.$1: e.$2,
      };
      expect(info['Period'], 'This Month (Oct 1, 2026 - Oct 22, 2026)');
      expect(info['Filters Applied'], contains('Category: Drinks'));
      expect(info['Sorted By'], 'Sold (descending)');
    });
  });

  group('roll', () {
    String preview(RollPaper paper) => renderRollEscPos(
      buildRollLines(specFor(screenRows()), testCtx, paper: paper),
      paper,
    ).preview;

    test('58mm: Item · Closing', () {
      final text = preview(RollPaper.mm58);
      final out = text.split('\n');
      expect(
        out.firstWhere((l) => l.startsWith('Acrylic Sheet')),
        endsWith('3 Sheets (4 x 2)'),
      );
      final coke = out.firstWhere((l) => l.startsWith('Coke '));
      expect(coke, endsWith('5 Bottle(s)'));
      expect(coke, isNot(contains('10 Bottle(s)')));
      expect(out.every((l) => l.length <= 32), isTrue);
    });

    test('80mm: Item · Opening · Closing', () {
      final out = preview(RollPaper.mm80).split('\n');
      final coke = out.firstWhere((l) => l.startsWith('Coke '));
      expect(coke, contains('10 Bottle(s)'));
      expect(coke, endsWith('5 Bottle(s)'));
      final sheet = out.firstWhere((l) => l.startsWith('Acrylic'));
      expect(sheet, contains('0 Sheets (4 x 2)'));
      expect(sheet, endsWith('3 Sheets (4 x 2)'));
      expect(out.every((l) => l.length <= 48), isTrue);
    });
  });

  group('Stock Movements screen', () {
    setUpAll(setUpScreenEnvironment);
    tearDownAll(() async => Hive.close());

    for (final desktop in [true, false]) {
      testWidgets('shows the Export pill (${desktop ? 'desktop' : 'mobile'})', (
        tester,
      ) async {
        await pumpReportScreen(
          tester,
          ItemLevelStockMovementsView(isDesktop: desktop),
          desktop: desktop,
        );
        if (!desktop) {
          // The toolbar items sit behind "Filter" on narrow screens.
          expect(find.text('Export'), findsNothing);
          await tester.tap(find.text('Filter'));
          await settleReportScreen(tester);
        }
        expect(find.text('Export'), findsOneWidget);
      });
    }
  });
}
