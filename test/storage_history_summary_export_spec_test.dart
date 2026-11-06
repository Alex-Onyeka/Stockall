import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_product_class/units_class/product_units_class.dart';
import 'package:stockall/classes/temp_storage_item_history/storage_item_history.dart';
import 'package:stockall/classes/temp_storage_item_history/storage_item_history_event_class.dart';
import 'package:stockall/classes/temp_storage_product/temp_storage_products.dart';
import 'package:stockall/pages/report/components/export/report_export_resolve.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/export/report_pdf_builder.dart';
import 'package:stockall/pages/report/components/export/report_roll_builder.dart';
import 'package:stockall/pages/report/storage_items_report_/storage_item_history_summary/class/storage_item_history_summary_export_spec.dart';
import 'package:stockall/pages/report/storage_items_report_/storage_item_history_summary/class/storage_item_history_summary_logic.dart';
import 'package:stockall/pages/report/storage_items_report_/storage_item_history_summary/components/storage_item_history_summary_view.dart';
import 'package:stockall/services/printing/escpos_builder.dart' show fontBDots;

import 'item_history_export_fixtures.dart' show testCtx;
import 'report_export_screen_harness.dart';
import 'storage_item_history_summary_test.dart' show oct, record, storageItem, unit;

final businessNow = DateTime(2026, 10, 20, 16);

final flour = storageItem(uuid: 'flour', name: 'Flour', quantity: 15, units: [unit('Bags')]);
final glass = storageItem(
  uuid: 'glass',
  name: 'Glass',
  quantity: 3,
  quantityType: 2,
  width: 2,
  height: 3,
  units: [unit('Sheets', dimensionType: ProductUnitsClass.sheetUnit)],
);
final salt = storageItem(uuid: 'salt', name: 'Salt', quantity: 0, units: [unit('Kg')]);
final storageProducts = [flour, glass, salt];

// Flour: 5 bags transferred to the Bar, 10 stocked in. Glass: 1 sheet
// transferred to the Kitchen. Salt: no movement.
final histories = <StorageItemHistory>[
  record(
    uuid: 'f-in',
    storageItemUuid: 'flour',
    storageItemName: 'Flour',
    event: StorageItemHistoryEventClass.stockIn,
    createdAt: oct(18, 9),
    oldValue: '10',
    newValue: '20',
    quantityChange: 10,
    isIncreased: true,
    storageUnit: 'Bags',
    storagePrimaryUnit: 'Bags',
  ),
  record(
    uuid: 'f-out',
    storageItemUuid: 'flour',
    storageItemName: 'Flour',
    event: StorageItemHistoryEventClass.transferedOut,
    createdAt: oct(18, 10),
    oldValue: '20',
    newValue: '15',
    quantityChange: 5,
    isIncreased: false,
    storageUnit: 'Bags',
    storagePrimaryUnit: 'Bags',
    salesItemUuid: 'p-1',
    salesItemName: 'Flour Sale',
    salesDepartmentUuid: 'd-bar',
    salesDepartmentName: 'Bar',
  ),
  record(
    uuid: 'g-out',
    storageItemUuid: 'glass',
    storageItemName: 'Glass',
    event: StorageItemHistoryEventClass.transferedOut,
    createdAt: oct(18, 11),
    oldValue: '4',
    newValue: '3',
    quantityChange: 1,
    isIncreased: false,
    storageUnit: 'Sheets',
    storagePrimaryUnit: 'Sheets',
    salesDepartmentUuid: 'd-kitchen',
    salesDepartmentName: 'Kitchen',
  ),
];

typedef Screen = ({
  StorageHistorySummaryStats stats,
  List<StorageHistorySummaryRow> all,
  StorageHistoryBreakdowns breakdowns,
});

Screen screenOf({
  List<TempStorageProducts>? products,
  List<StorageItemHistory>? records,
  StorageHistoryPeriod period = StorageHistoryPeriod.allTime,
}) {
  final res = StorageHistorySummaryBuilder.buildSummaryAndRows(
    storageProducts: products ?? storageProducts,
    salesProducts: const [],
    histories: records ?? histories,
    period: period,
    businessNow: businessNow,
  );
  return (
    stats: res.stats,
    all: res.rows,
    breakdowns: StorageHistorySummaryBuilder.buildBreakdowns(
      storageProducts: products ?? storageProducts,
      histories: records ?? histories,
      period: period,
      businessNow: businessNow,
    ),
  );
}

List<StorageHistorySummaryRow> query(
  List<StorageHistorySummaryRow> rows, {
  StorageHistorySummaryFilters? filters,
  StorageHistorySummarySortField sortField = StorageHistorySummarySortField.itemName,
}) => StorageHistorySummaryBuilder.filterAndSortRows(
  rows: rows,
  filters: filters ?? StorageHistorySummaryFilters(),
  sortField: sortField,
  ascending: true,
);

ReportExportSpec specFor({
  Screen? screen,
  StorageHistorySummaryFilters? filters,
  StorageHistoryPeriod period = StorageHistoryPeriod.allTime,
  DateTimeRange? customRange,
  bool departmentsEnabled = true,
}) {
  final s = screen ?? screenOf(period: period);
  return storageHistorySummaryExportSpec(
    stats: s.stats,
    breakdowns: s.breakdowns,
    allRows: s.all,
    rows: query(s.all, filters: filters),
    filters: filters ?? StorageHistorySummaryFilters(),
    sortField: StorageHistorySummarySortField.itemName,
    ascending: true,
    period: period,
    customRange: customRange,
    resolvedRange: StorageHistorySummaryBuilder.resolveDateRange(
      period: period,
      businessNow: businessNow,
      customRange: customRange,
    ),
    departmentsEnabled: departmentsEnabled,
    currency: '₦',
    sizeLabels: storageSizeLabels(storageProducts),
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

ResolvedTable table(ReportExportSpec s, String title) =>
    resolved(s).tables.firstWhere((t) => t.title == title);

ResolvedCell cell(ResolvedTable t, String name, String id) => t.rows
    .firstWhere((r) => r[t.indexOf('name')].text.startsWith(name))[t.indexOf(id)];

void main() {
  group('sections', () {
    test('cards, leaders, breakdowns and the item table; no splits', () {
      final spec = specFor();
      expect(spec.sections.map((s) => s.title), [
        'Statistics',
        'Movement Categories',
        'Top Inflow Items',
        'Top Outflow Items',
        'Sales Items Supplied',
        'Sales Items Returning',
        'Departments',
        'Storekeepers',
        'Other Staff',
        'Storage Item Summary',
      ]);
      expect(spec.splitOptions, isEmpty);
      expect(
        specFor(departmentsEnabled: false).sections.map((s) => s.title),
        isNot(contains('Departments')),
      );
    });
  });

  group('rows are the screen query, every page', () {
    test('150 items: every row, in the screen order', () {
      final many = [
        for (var i = 0; i < 150; i++)
          storageItem(uuid: 's-$i', name: 'Item ${i.toString().padLeft(3, '0')}', quantity: 1, units: [unit('Pcs')]),
      ];
      final s = screenOf(products: many, records: const []);
      final rows = query(s.all);
      final t = table(specFor(screen: s), 'Storage Item Summary');
      expect(t.rows, hasLength(150));
      expect([for (final r in t.rows) r[t.indexOf('name')].text], [for (final r in rows) r.name]);
      expect(StorageHistorySummaryBuilder.paginate(rows, 1).rows, hasLength(50));
    });
  });

  group('figures', () {
    test('the cards, by unit, as the screen formats them', () {
      final s = screenOf().stats;
      final m = metrics(specFor(), 'Statistics');
      expect(m['Net Change']!.text, storageSignedQuantitiesByUnit(s.netChangeByUnit));
      expect(m['Net Change']!.text, '+5.0 Bags, -1.0 Sheets');
      expect(m['Total Stock Additions']!.text, formatQuantitiesByUnit(s.additionsByUnit));
      expect(m['Items With Movement']!.text, '${s.itemsWithMovementCount} of ${s.totalDistinctItems}');
      final c = metrics(specFor(), 'Movement Categories');
      expect(c['Transferred Out To Sales']!.text,
          formatQuantitiesByUnit(s.quantityByUnit(StorageMovementKind.transferredOut)));
      expect(c['Items Created']!.raw, s.countOf(StorageMovementKind.created));
    });
  });

  group('tables', () {
    test('item cells with units and 2D sizes; export-only count totals', () {
      final t = table(specFor(), 'Storage Item Summary');
      expect(cell(t, 'Glass', 'closing').text, '3 Sheets (2 x 3)');
      expect(cell(t, 'Glass', 'transferredOut').text, '-1 Sheets (2 x 3)');
      expect(cell(t, 'Flour', 'stockedIn').text, '+10 Bags');
      expect(cell(t, 'Salt', 'stockedIn').text, '—');
      expect(t.totals![t.indexOf('name')].text, '3 items');
      final rows = query(screenOf().all);
      expect(t.totals![t.indexOf('movements')].raw, rows.fold<int>(0, (s, r) => s + r.movementCount));
    });

    test('leaders and breakdowns as on screen', () {
      final s = screenOf();
      final spec = specFor();
      final out = table(spec, 'Top Outflow Items');
      expect(
        [for (final r in out.rows) r[out.indexOf('name')].text],
        [for (final r in StorageHistorySummaryBuilder.getTopOutflowItems(s.all)) r.name],
      );
      final depts = table(spec, 'Departments');
      expect(
        [for (final r in depts.rows) r[depts.indexOf('name')].text],
        [for (final e in s.breakdowns.departments.take(5)) e.label],
      );
      expect(table(spec, 'Sales Items Supplied').indexOf('in'), -1);
      expect(table(spec, 'Sales Items Returning').indexOf('out'), -1);
    });
  });

  group('info box and notes', () {
    test('period text and filters', () {
      final filters = StorageHistorySummaryFilters()
        ..search = 'fl'
        ..movementFilter = StorageHistoryMovementFilter.hasMovement;
      final spec = specFor(filters: filters);
      expect({for (final x in spec.filters) x.label: x.value}, {
        'Search': 'fl',
        'Movement': 'With Movement',
      });
      expect(spec.period!.label, 'All Time');
      final custom = specFor(
        period: StorageHistoryPeriod.custom,
        customRange: DateTimeRange(start: DateTime(2026, 10, 1), end: DateTime(2026, 10, 18)),
      );
      expect(custom.period!.label, 'Oct 1, 2026 - Oct 18, 2026');
    });

    test('exactly the screen notes', () {
      final all = specFor();
      expect(all.notes, [
        'Quantities are in each storage item\'s primary unit and are never added across units.',
        'All time covers the storage history loaded on this device.',
      ]);
      expect(all.notes, storageHistorySummaryNotes(period: StorageHistoryPeriod.allTime, stats: screenOf().stats));
      final week = specFor(period: StorageHistoryPeriod.thisWeek);
      expect(week.notes, hasLength(1));
      final info = {
        for (final e in reportPdfInfoEntries(resolved(all))) e.$1: e.$2,
      };
      expect(info['Notes'], all.notes.join('\n'));
    });
  });

  group('roll', () {
    for (final paper in RollPaper.values) {
      test('${paper.name}: 2D quantities on one line', () {
        final out = renderRollEscPos(
          buildRollLines(specFor(), testCtx, paper: paper),
          paper,
        ).preview.split('\n');
        expect(out.any((l) => l.startsWith('Glass') && l.endsWith('3 Sheets (2 x 3)')), isTrue);
        expect(out.every((l) => l.length <= paper.dots ~/ fontBDots), isTrue);
      });
    }
  });

  group('Storage summary screen', () {
    setUpAll(setUpScreenEnvironment);
    tearDownAll(() async => Hive.close());

    for (final desktop in [true, false]) {
      testWidgets('shows the Export pill (${desktop ? 'desktop' : 'mobile'})', (
        tester,
      ) async {
        await pumpReportScreen(
          tester,
          StorageItemHistorySummaryView(isDesktop: desktop),
          desktop: desktop,
        );
        // Beside the period selector at every width (no "View" toggle).
        expect(find.text('Export'), findsOneWidget);
      });
    }
  });
}
