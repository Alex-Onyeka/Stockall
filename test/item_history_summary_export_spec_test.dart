import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:stockall/local_database/item_history/item_histories_func.dart';
import 'package:stockall/pages/report/components/export/report_export_button.dart';
import 'package:stockall/pages/report/components/export/report_export_format.dart';
import 'package:stockall/pages/report/components/export/report_export_resolve.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/export/report_pdf_builder.dart';
import 'package:stockall/pages/report/components/export/report_roll_builder.dart';
import 'package:stockall/pages/report/items_report_/item_history_summary/class/item_history_summary_export_spec.dart';
import 'package:stockall/pages/report/items_report_/item_history_summary/class/item_history_summary_logic.dart';
import 'package:stockall/pages/report/items_report_/item_history_summary/components/item_history_summary_view.dart';
import 'package:stockall/providers/data_provider.dart';

import 'item_history_export_fixtures.dart';
import 'report_export_screen_harness.dart';

final allTime = ItemHistorySummaryBuilder.resolveDateRange(
  period: ItemHistoryPeriod.allTime,
  businessNow: summaryNow,
);

({ItemHistorySummaryStats stats, List<ItemHistorySummaryRow> rows}) build({
  bool manageProductions = true,
}) => ItemHistorySummaryBuilder.buildSummaryAndRows(
  products: summaryProducts,
  histories: summaryHistories,
  period: ItemHistoryPeriod.allTime,
  businessNow: summaryNow,
  manageProductions: manageProductions,
);

/// The screen's table query (filter, sort, re-index).
List<ItemHistorySummaryRow> query(
  List<ItemHistorySummaryRow> rows,
  ItemHistorySummaryFilters filters, {
  ItemHistorySummarySortField sortField = ItemHistorySummarySortField.rowIndex,
  bool ascending = true,
  bool departmentsEnabled = true,
}) {
  final out = ItemHistorySummaryBuilder.filterAndSortRows(
    rows: rows,
    filters: filters,
    sortField: sortField,
    ascending: ascending,
    departmentsEnabled: departmentsEnabled,
  );
  for (var i = 0; i < out.length; i++) {
    out[i].index = i + 1;
  }
  return out;
}

ReportExportSpec specFor({
  ItemHistorySummaryFilters? filters,
  ItemHistorySummarySortField sortField = ItemHistorySummarySortField.rowIndex,
  bool ascending = true,
  bool manageProductions = true,
  bool departmentsEnabled = true,
  ItemHistoryPeriod period = ItemHistoryPeriod.allTime,
  DateTimeRange? range,
}) {
  final res = build(manageProductions: manageProductions);
  final f = filters ?? ItemHistorySummaryFilters();
  return itemHistorySummaryExportSpec(
    stats: res.stats,
    allRows: res.rows,
    rows: query(
      res.rows,
      f,
      sortField: sortField,
      ascending: ascending,
      departmentsEnabled: departmentsEnabled,
    ),
    filters: f,
    sortField: sortField,
    ascending: ascending,
    period: period,
    range: range ?? allTime,
    currency: '₦',
    manageProductions: manageProductions,
    departmentsEnabled: departmentsEnabled,
    categoryNames: categoryNames,
    departmentNames: departmentNames,
    sizeLabels: stockMovementsSizeLabels(summaryProducts),
  );
}

List<ResolvedSummary> summariesOf(ResolvedExport r) =>
    r.sections.whereType<ResolvedSummary>().toList();

ResolvedTable itemTable(ReportExportSpec spec) => resolveExport(spec, testCtx)
    .tables
    .firstWhere((t) => t.title == 'Item Stock Movements');

ResolvedCell cellOf(ReportExportSpec spec, String item, String columnId) {
  final t = itemTable(spec);
  final row = t.rows.firstWhere((r) => r[t.indexOf('name')].text == item);
  return row[t.indexOf(columnId)];
}

void main() {
  group('rows are the full table query, not the top 10', () {
    test('150 items, sorted like the screen', () {
      final products = [
        for (var i = 0; i < 150; i++)
          makeProduct(uuid: 'p$i', name: 'Item ${(i * 37) % 150}'),
      ];
      final res = ItemHistorySummaryBuilder.buildSummaryAndRows(
        products: products,
        histories: const [],
        period: ItemHistoryPeriod.allTime,
        businessNow: summaryNow,
        manageProductions: false,
      );
      final filters = ItemHistorySummaryFilters();
      final rows = query(
        res.rows,
        filters,
        sortField: ItemHistorySummarySortField.itemName,
        ascending: false,
      );
      final spec = itemHistorySummaryExportSpec(
        stats: res.stats,
        allRows: res.rows,
        rows: rows,
        filters: filters,
        sortField: ItemHistorySummarySortField.itemName,
        ascending: false,
        period: ItemHistoryPeriod.allTime,
        range: allTime,
        currency: '₦',
        manageProductions: false,
        departmentsEnabled: false,
      );
      final section = spec.tables.firstWhere(
        (t) => t.title == 'Item Stock Movements',
      );
      expect(section.rowCount, 150);
      expect(section.erasedRows, orderedEquals(rows));
      final t = itemTable(spec);
      expect(
        [for (final r in t.rows) r[t.indexOf('name')].text],
        [for (final r in rows) r.name],
      );
      expect(t.rows.last[t.indexOf('no')].text, '150');
    });
  });

  group('sections', () {
    test('headline figures, breakdown, movers, then the item table', () {
      final spec = specFor();
      expect(spec.sections.map((s) => s.title), [
        'Stock Movements & Analysis',
        'Movement Breakdown',
        'Top Inflow Items',
        'Top Outflow Items',
        'Item Stock Movements',
      ]);
      expect(spec.reportName, 'Item History Summary');
      expect(spec.fileSlug, 'item_history_summary');
    });

    test('the figures are the screen stats, over every item', () {
      final stats = build().stats;
      // A table filter narrows the table only, as on screen.
      final spec = specFor(filters: ItemHistorySummaryFilters()..search = 'coke');
      final r = resolveExport(spec, testCtx);
      final head = {
        for (final m in summariesOf(r).first.metrics) m.label: m.raw,
      };
      expect(head['Net Change'], stats.netQuantityChange);
      expect(head['Total Stock Additions'], stats.totalStockAdditions);
      expect(head['Total Stock Reductions'], -stats.totalStockReductions);
      expect(
        head['Items With Movement'],
        '${stats.itemsWithMovementCount} of ${stats.totalDistinctItems}',
      );
      expect(stats.totalDistinctItems, 4);
      final breakdown = {
        for (final m in summariesOf(r)[1].metrics) m.label: m.raw,
      };
      expect(breakdown['Total Sold'], 5);
      expect(breakdown['Total Purchased'], 3);
      expect(breakdown['Production'], 2);
      expect(itemTable(spec).rows, hasLength(1));
    });

    test('Production figures only with productions on', () {
      final r = resolveExport(specFor(manageProductions: false), testCtx);
      final labels = [for (final m in summariesOf(r)[1].metrics) m.label];
      expect(labels, isNot(contains('Production')));
      expect(labels, isNot(contains('Production Deleted')));
    });

    test('Top Inflow / Outflow as the screen lists them', () {
      final tables = resolveExport(specFor(), testCtx).tables;
      final inflow = tables.firstWhere((t) => t.title == 'Top Inflow Items');
      final outflow = tables.firstWhere((t) => t.title == 'Top Outflow Items');
      expect(
        [for (final r in inflow.rows) r[inflow.indexOf('name')].text],
        ['Acrylic Sheet', 'Meat Pie'],
      );
      expect(outflow.rows.single[outflow.indexOf('name')].text, 'Coke');
      expect(outflow.rows.single[outflow.indexOf('value')].raw, -5);
    });
  });

  group('item table', () {
    test('columns as on screen; Production only with productions', () {
      List<String> ids(ReportExportSpec s) => [
        for (final c in itemTable(s).columns) c.id,
      ];
      expect(ids(specFor()), [
        'no',
        'name',
        'unit',
        'opening',
        'closing',
        'current',
        'net',
        'sold',
        'returnedSales',
        'purchased',
        'returnedPurchase',
        'transferIn',
        'transferOut',
        'stockIn',
        'stockOut',
        'produced',
        'productionDeleted',
        'delivered',
      ]);
      expect(ids(specFor(manageProductions: false)), isNot(contains('produced')));
      final t = itemTable(specFor());
      expect([for (final c in t.columns) if (!c.inPdf) c.id], ['unit']);
      expect(t.columns[t.indexOf('transferIn')].label, 'Transfered In');
    });

    test('signed numbers in Excel, screen texts in the PDF', () {
      final spec = specFor();
      expect(cellOf(spec, 'Coke', 'sold').raw, -5);
      expect(cellOf(spec, 'Coke', 'sold').text, '-5 Bottle(s)');
      expect(cellOf(spec, 'Coke', 'net').text, '-5 Bottle(s)');
      expect(cellOf(spec, 'Coke', 'opening').text, '10 Bottle(s)');
      expect(cellOf(spec, 'Coke', 'closing').text, '5 Bottle(s)');
      expect(cellOf(spec, 'Coke', 'purchased').raw, 0);
      expect(cellOf(spec, 'Coke', 'purchased').text, '—');
      expect(cellOf(spec, 'Meat Pie', 'produced').text, '+2 Pcs');
      expect(cellOf(spec, 'Juice', 'net').text, '0 Bottle(s)');
    });

    test('a 2D sheet item reads "3 Sheets (4 x 2)"', () {
      final spec = specFor();
      expect(cellOf(spec, 'Acrylic Sheet', 'closing').text, '3 Sheets (4 x 2)');
      expect(cellOf(spec, 'Acrylic Sheet', 'purchased').text, '+3 Sheets (4 x 2)');
      expect(cellOf(spec, 'Acrylic Sheet', 'purchased').raw, 3);
      expect(cellOf(spec, 'Acrylic Sheet', 'unit').text, 'Sheets');
    });

    test('export-only item count', () {
      final t = itemTable(specFor());
      expect(t.totals![t.indexOf('name')].text, '4 items');
      expect(t.totals![t.indexOf('sold')].text, isEmpty);
    });
  });

  group('splits', () {
    final f = ExportFormatter(currency: '₦');
    ExportTableSection<dynamic> section(ReportExportSpec s) =>
        s.tables.firstWhere((t) => t.title == 'Item Stock Movements');
    List<String> names(ResolvedGroup g) => [
      for (final r in g.table.rows) r[g.table.indexOf('name')].text,
    ];

    test('Category and Department only (no staff on per-item rows)', () {
      expect(specFor().splitOptions.map((s) => s.id), ['category', 'department']);
      expect(
        specFor(departmentsEnabled: false).splitOptions.map((s) => s.id),
        ['category'],
      );
    });

    test('categories: two-category item on both, "No Category" last', () {
      final groups = resolveGroups(section(specFor()), 'category', f);
      expect(groups.map((g) => g.name), ['Bakery', 'Drinks', 'No Category']);
      expect(names(groups[0]), ['Acrylic Sheet', 'Meat Pie']);
      expect(names(groups[1]), ['Coke', 'Meat Pie']);
      expect(names(groups[2]), ['Juice']);
    });

    test('departments with "No Department" last', () {
      final groups = resolveGroups(section(specFor()), 'department', f);
      expect(groups.map((g) => g.name), [
        'Back Store',
        'Front Shop',
        'No Department',
      ]);
      expect(names(groups[2]), ['Meat Pie', 'Juice']);
    });

    test('split sheets hold the item table; All keeps every section', () {
      final wb = resolveWorkbook(specFor(), testCtx, splitId: 'category');
      expect(wb.sheets.map((s) => s.name), [
        'All',
        'Bakery',
        'Drinks',
        'No Category',
      ]);
      expect(wb.sheets.first.sections, hasLength(5));
      // A group sheet holds just the item table, titled by its group.
      final bakery = wb.sheets[1].sections.single as ResolvedTable;
      expect(bakery.title, 'Bakery');
      expect(bakery.indexOf('closing'), greaterThan(0));
    });
  });

  group('info box', () {
    test('period with its dates, filters with values, sort', () {
      final range = ItemHistorySummaryBuilder.resolveDateRange(
        period: ItemHistoryPeriod.thisMonth,
        businessNow: summaryNow,
      );
      final filters = ItemHistorySummaryFilters()
        ..search = 'co'
        ..movementFilter = ItemHistoryMovementFilter.hasMovement
        ..categoryKey = itemHistorySummaryNoneKey
        ..departmentKey = 'd-front';
      final spec = specFor(
        filters: filters,
        period: ItemHistoryPeriod.thisMonth,
        range: range,
        sortField: ItemHistorySummarySortField.closingStock,
        ascending: false,
      );
      expect({for (final x in spec.filters) x.label: x.value}, {
        'Search': '"co"',
        'Movement': 'With Movement',
        'Category': 'Uncategorized',
        'Department': 'Front Shop',
      });
      expect(spec.period!.label, 'This Month (Oct 1, 2026 - Oct 22, 2026)');
      expect(spec.sortedBy, 'Closing Stock (descending)');
      final info = {
        for (final e in reportPdfInfoEntries(resolveExport(spec, testCtx)))
          e.$1: e.$2,
      };
      expect(info['Period'], 'This Month (Oct 1, 2026 - Oct 22, 2026)');
      expect(info['Filters Applied'], contains('Movement: With Movement'));
      expect(info['Sorted By'], 'Closing Stock (descending)');
    });

    test('All Time, custom ranges and the default sort', () {
      final f = ExportFormatter(currency: '₦');
      expect(specFor().period!.label, 'All Time');
      expect(specFor().period!.start, isNull);
      expect(specFor().sortedBy, 'No. (ascending)');
      final day = DateTimeRange(
        start: DateTime(2026, 10, 5),
        end: DateTime(2026, 10, 5),
      );
      expect(
        stockMovementsPeriodLabel(ItemHistoryPeriod.custom, day, f),
        'Oct 5, 2026',
      );
      expect(
        stockMovementsSortLabels.length,
        ItemHistorySummarySortField.values.length,
      );
      expect(
        specFor(
          filters: ItemHistorySummaryFilters()..departmentKey = 'd-front',
          departmentsEnabled: false,
        ).filters,
        isEmpty,
      );
    });
  });

  group('roll', () {
    String preview(RollPaper paper) => renderRollEscPos(
      buildRollLines(specFor(), testCtx, paper: paper),
      paper,
    ).preview;
    // The lines of the item table (after the Top Inflow / Outflow ones).
    List<String> itemLines(String text) {
      final out = text.split('\n');
      return out.sublist(out.indexWhere((l) => l.contains('ITEM STOCK MOVEMENTS')));
    }

    test('58mm: Item · Closing; figures as pairs', () {
      final text = preview(RollPaper.mm58);
      final out = itemLines(text);
      final sheet = out.firstWhere((l) => l.startsWith('Acrylic Sheet'));
      expect(sheet, endsWith('3 Sheets (4 x 2)'));
      expect(out.firstWhere((l) => l.startsWith('Coke ')), endsWith('5 Bottle(s)'));
      expect(text, contains('Net Change'));
      expect(text, contains('4 items'));
      expect(text.split('\n').every((l) => l.length <= 32), isTrue);
    });

    test('80mm: Item · Opening · Closing', () {
      final out = itemLines(preview(RollPaper.mm80));
      final coke = out.firstWhere((l) => l.startsWith('Coke '));
      expect(coke, contains('10 Bottle(s)'));
      expect(coke, endsWith('5 Bottle(s)'));
      final sheet = out.firstWhere((l) => l.startsWith('Acrylic'));
      expect(sheet, contains('0 Sheets (4 x 2)'));
      expect(sheet, endsWith('3 Sheets (4 x 2)'));
      expect(out.every((l) => l.length <= 48), isTrue);
    });
  });

  group('History Summary screen', () {
    setUpAll(() async {
      await setUpScreenEnvironment();
      DataProvider().productListMain = summaryProducts;
      await ItemHistoriesFunc().itemHistoryBox.putAll({
        for (final h in summaryHistories) h.uuid: h,
      });
    });
    tearDownAll(() async {
      DataProvider().productListMain = [];
      await Hive.close();
    });

    // The item table's rows, read from the screen's DataTable.
    List<String> tableNames(WidgetTester tester) {
      final table = tester.widget<DataTable>(find.byType(DataTable));
      return [
        for (final row in table.rows)
          tester
              .widgetList<Text>(
                find.descendant(
                  of: find.byWidget(row.cells[1].child),
                  matching: find.byType(Text),
                ),
              )
              .first
              .data!,
      ];
    }

    List<String> exportNames(WidgetTester tester) {
      final spec = tester
          .widget<ReportExportButton>(find.byType(ReportExportButton))
          .buildSpec();
      final t = resolveExport(spec, testCtx).tables.firstWhere(
        (t) => t.title == 'Item Stock Movements',
      );
      return [for (final r in t.rows) r[t.indexOf('name')].text];
    }

    testWidgets('a filter change redraws the table and the export together', (
      tester,
    ) async {
      await pumpReportScreen(
        tester,
        const ItemHistorySummaryView(isDesktop: true),
        desktop: true,
      );
      expect(tableNames(tester), hasLength(4));
      expect(exportNames(tester), tableNames(tester));

      await tester.enterText(
        find.widgetWithText(TextField, 'Search items...'),
        'coke',
      );
      await tester.pump();
      // No other rebuild needed: the table follows straight away.
      expect(tableNames(tester), ['Coke']);
      expect(exportNames(tester), ['Coke']);
    });

    testWidgets('the mobile Filter toggle stays open across a filter change', (
      tester,
    ) async {
      await pumpReportScreen(
        tester,
        const ItemHistorySummaryView(isDesktop: false),
        desktop: false,
      );
      await tester.ensureVisible(find.text('Filter'));
      await tester.tap(find.text('Filter'));
      await tester.pump();
      expect(find.text('Export'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextField, 'Search items...'),
        'coke',
      );
      await tester.pump();
      expect(find.text('Export'), findsOneWidget);
      expect(find.text('All Items'), findsOneWidget);
      expect(exportNames(tester), ['Coke']);
    });

    for (final desktop in [true, false]) {
      testWidgets('shows the Export pill (${desktop ? 'desktop' : 'mobile'})', (
        tester,
      ) async {
        await pumpReportScreen(
          tester,
          ItemHistorySummaryView(isDesktop: desktop),
          desktop: desktop,
        );
        if (!desktop) {
          // The table filters sit behind "Filter" on narrow screens.
          expect(find.text('Export'), findsNothing);
          await tester.ensureVisible(find.text('Filter'));
          await tester.tap(find.text('Filter'));
          await settleReportScreen(tester);
        }
        await tester.ensureVisible(find.text('Export'));
        expect(find.text('Export'), findsOneWidget);
      });
    }
  });
}
