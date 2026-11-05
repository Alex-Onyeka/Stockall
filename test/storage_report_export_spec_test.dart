import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:stockall/pages/report/components/export/report_export_resolve.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/export/report_roll_builder.dart';
import 'package:stockall/pages/report/storage_items_report_/storage_report_main/class/storage_report_export_spec.dart';
import 'package:stockall/pages/report/storage_items_report_/storage_report_main/class/storage_report_main_logic.dart';
import 'package:stockall/pages/report/storage_items_report_/storage_report_main/components/storage_report_main_view.dart';
import 'package:stockall/services/printing/escpos_builder.dart' show fontBDots;

import 'item_history_export_fixtures.dart' show testCtx;
import 'report_export_screen_harness.dart';
import 'storage_report_analysis_test.dart' show salesItem, storageItem;

// Flour (bags, ₦1,250,000 of stock) supplies two sales items; Sheets is a
// 2D item (2 x 3); Salt has no cost price and is out of stock.
final storage = [
  storageItem(
    uuid: 's-flour',
    name: 'Flour',
    quantity: 50,
    costPrice: 25000,
    unitName: 'Bags',
    createdAt: DateTime(2026, 10, 1, 9),
  ),
  storageItem(
    uuid: 's-sheet',
    name: 'Sheets',
    quantity: 3,
    costPrice: 100,
    unitName: 'Sheets',
    twoD: true,
    createdAt: DateTime(2026, 10, 2, 9),
  ),
  storageItem(uuid: 's-salt', name: 'Salt', quantity: 0, costPrice: null, unitName: 'Kg'),
];

final sales = [
  salesItem(uuid: 'p-1', quantity: 2, storageUuid: 's-flour'),
  salesItem(uuid: 'p-2', quantity: 1, storageUuid: 's-flour'),
];

final baseRows = StorageReportRowBuilder.buildAll(storageProducts: storage, salesProducts: sales);

final day = DateTimeRange(start: DateTime(2026, 10, 17), end: DateTime(2026, 10, 17));

List<StorageReportRow> query({StorageReportFilters? filters, List<StorageReportRow>? rows}) =>
    StorageReportQuery.filterAndSort(
      rows: rows ?? baseRows,
      filters: filters ?? StorageReportFilters(),
      sortField: StorageSortField.name,
      ascending: true,
      costFilterAllowed: true,
    );

Map<String, StorageStockMovement> movementsOf(List<StorageReportRow> rows) => {
  for (final r in rows)
    r.uuid: StorageStockMovementCalculator.calculate(
      row: r,
      histories: const [],
      startCutoff: DateTime(2026, 10, 17, 4),
      endCutoff: DateTime(2026, 10, 18, 4),
    ),
};

ReportExportSpec specFor({
  List<StorageReportRow>? rows,
  StorageReportFilters? filters,
  bool canSeeCost = true,
  bool canSeeQuantity = true,
  bool historyTracked = true,
}) {
  final r = rows ?? query(filters: filters);
  return storageReportExportSpec(
    rows: r,
    movements: movementsOf(r),
    filters: filters ?? StorageReportFilters(),
    sortField: StorageSortField.name,
    ascending: true,
    range: day,
    canSeeCost: canSeeCost,
    canSeeQuantity: canSeeQuantity,
    historyTracked: historyTracked,
    currency: '₦',
  );
}

ResolvedTable tableOf(ReportExportSpec spec) =>
    resolveExport(spec, testCtx).tables.single;

ResolvedCell cell(ResolvedTable t, String name, String id) =>
    t.rows.firstWhere((r) => r[t.indexOf('name')].text == name)[t.indexOf(id)];

void main() {
  group('rows are the screen query, every page', () {
    test('150 items: every row, in the screen order', () {
      final many = StorageReportRowBuilder.buildAll(
        storageProducts: [
          for (var i = 0; i < 150; i++)
            storageItem(
              uuid: 's-$i',
              name: 'Item ${i.toString().padLeft(3, '0')}',
              quantity: 1.0 + i,
              costPrice: 1,
              unitName: 'Pcs',
            ),
        ],
        salesProducts: const [],
      );
      final rows = query(rows: many);
      final t = tableOf(specFor(rows: rows));
      expect(t.rows, hasLength(150));
      expect([for (final r in t.rows) r[t.indexOf('name')].text], [for (final r in rows) r.name]);
      expect(StorageReportQuery.paginate(rows, 1).rows, hasLength(100));
    });
  });

  group('columns and cells', () {
    test('as on screen; cost columns only with cost access', () {
      expect([for (final c in tableOf(specFor()).columns) c.label], [
        'No.',
        'Item Name',
        'Quantity',
        'Primary Unit',
        'Opening Stock',
        'Closing Stock',
        'Stock Change',
        'Cost Price',
        'Total Cost Value',
        'Quantity Type',
        'Created Date',
        'Created Time',
        'Item In Sales',
        'Quantity In Sales',
        'Total Quantity',
      ]);
      final t = tableOf(specFor(canSeeCost: false));
      expect(t.indexOf('costPrice'), -1);
      expect(t.indexOf('costTotal'), -1);
    });

    test('2D sizes, quantities with units, blanks "—"', () {
      final t = tableOf(specFor());
      expect(cell(t, 'Sheets', 'unit').text, 'Sheets (2 x 3)');
      expect(cell(t, 'Sheets', 'quantity').text, '3 Sheets (2 x 3)');
      expect(cell(t, 'Flour', 'quantity').text, '50 Bags');
      expect(cell(t, 'Flour', 'costTotal').text, '₦1,250,000.00');
      expect(cell(t, 'Flour', 'inSales').text, 'Sales p-1, Sales p-2');
      expect(cell(t, 'Salt', 'costPrice').text, '—');
      expect(cell(t, 'Salt', 'inSales').text, '—');
      expect(cell(t, 'Sheets', 'type').text, '2-Dimensional');
    });

    test('quantity access masks every quantity; no tracking shows N/A', () {
      final masked = tableOf(specFor(canSeeQuantity: false));
      for (final id in ['quantity', 'opening', 'closing', 'change', 'quantityInSales', 'totalQuantity']) {
        expect(cell(masked, 'Flour', id).text, '****', reason: id);
      }
      final untracked = tableOf(specFor(historyTracked: false));
      for (final id in ['opening', 'closing', 'change']) {
        expect(cell(untracked, 'Flour', id).text, 'N/A', reason: id);
      }
      expect(cell(untracked, 'Flour', 'quantity').text, '50 Bags');
    });
  });

  group('totals and splits', () {
    test('export-only totals: the item count and the cost value', () {
      final t = tableOf(specFor());
      expect(t.totals![t.indexOf('name')].text, '3 items');
      expect(t.totals![t.indexOf('costTotal')].raw, 1250300);
      expect(t.totals![t.indexOf('quantity')].text, '');
    });

    test('no splits: no Department filter on screen, no categories', () {
      expect(specFor().splitOptions, isEmpty);
      expect(specFor().notes, isEmpty);
    });
  });

  group('info box', () {
    test('the date pill and the filters worded like the chips', () {
      final filters = StorageReportFilters()
        ..search = 'fl'
        ..costMin = 100
        ..quantityMax = 60
        ..salesItemsCountMin = 1;
      final spec = specFor(filters: filters);
      expect(spec.period!.label, 'Oct 17, 2026');
      expect([for (final x in spec.filters) '${x.label}: ${x.value}'], [
        'Search: fl',
        'Cost: ₦100.00 - Any',
        'Qty: Any - 60',
        'Sales items: 1 - Any',
      ]);
      expect(
        specFor(filters: filters, canSeeCost: false).filters.map((x) => x.label),
        isNot(contains('Cost')),
      );
      expect(spec.sortedBy, 'Item Name (ascending)');
    });
  });

  group('roll', () {
    String preview(RollPaper paper, {bool canSeeCost = true}) => renderRollEscPos(
      buildRollLines(specFor(canSeeCost: canSeeCost), testCtx, paper: paper),
      paper,
    ).preview;

    test('58mm: Name · Quantity, 2D quantities on one line', () {
      final out = preview(RollPaper.mm58).split('\n');
      expect(out.firstWhere((l) => l.startsWith('Sheets')), endsWith('3 Sheets (2 x 3)'));
      expect(out.every((l) => l.length <= RollPaper.mm58.dots ~/ fontBDots), isTrue);
    });

    test('80mm: Name · Quantity · Total Cost Value (Total Quantity without cost)', () {
      final out = preview(RollPaper.mm80).split('\n');
      final flour = out.firstWhere((l) => l.startsWith('Flour'));
      expect(flour, contains('50 Bags'));
      expect(flour, endsWith('N1,250,000.00'));
      final noCost = preview(RollPaper.mm80, canSeeCost: false).split('\n');
      expect(noCost.firstWhere((l) => l.startsWith('Flour')), endsWith('53 Bags'));
      expect(out.every((l) => l.length <= 48), isTrue);
    });
  });

  group('Storage Report screen', () {
    setUpAll(setUpScreenEnvironment);
    tearDownAll(() async => Hive.close());

    for (final desktop in [true, false]) {
      testWidgets('shows the Export pill (${desktop ? 'desktop' : 'mobile'})', (
        tester,
      ) async {
        await pumpReportScreen(
          tester,
          StorageReportMainView(isDesktop: desktop),
          desktop: desktop,
        );
        if (!desktop) {
          expect(find.text('Export'), findsNothing);
          await tester.tap(find.text('View'));
          await settleReportScreen(tester);
        }
        expect(find.text('Export'), findsOneWidget);
      });
    }
  });
}
