import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_item_history/item_history.dart';
import 'package:stockall/pages/report/components/export/report_export_format.dart';
import 'package:stockall/pages/report/components/export/report_export_resolve.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/export/report_pdf_builder.dart';
import 'package:stockall/pages/report/components/export/report_roll_builder.dart';
import 'package:stockall/pages/report/items_report_/item_history_report/class/item_history_export_spec.dart';
import 'package:stockall/pages/report/items_report_/item_history_report/class/item_history_report_logic.dart';
import 'package:stockall/pages/report/items_report_/item_history_report/components/item_history_report_view.dart';

import 'item_history_export_fixtures.dart';
import 'report_export_screen_harness.dart';

// Categories come from the products (history rows carry none); 'gone'
// is a deleted item, so it has no product and no category.
const categoryIdsByItem = {
  'coke': ['c-drinks'],
  'pie': ['c-drinks', 'c-bakery'],
  'sheet': ['c-bakery'],
};
const sizeLabels = {'sheet': ' (4 x 2)'};

final saleOfCoke = makeRecord(
  uuid: 'h-coke',
  title: 'Item Sold In Receipt',
  itemName: 'Coke',
  itemUuid: 'coke',
  createdAt: DateTime(2026, 10, 15, 10, 30),
  oldValue: '10.0',
  newValue: '8.0',
  quantityChange: 2,
  isIncreased: false,
  unit: 'Bottle(s)',
  primaryUnit: 'Bottle(s)',
  event: 'sale',
  source: 'product',
  destination: 'receipt',
  staffId: 's-ada',
  staffName: 'Ada',
  departmentUuid: 'd-front',
  departmentName: 'Front Shop',
  isManaged: true,
  supplierName: 'Coca Cola Plc',
  trackingNumber: 'TRK-1',
  desc: 'Walk-in sale',
);
final sheetProduced = makeRecord(
  uuid: 'h-sheet',
  title: 'Item Produced',
  itemName: 'Sheet',
  itemUuid: 'sheet',
  createdAt: DateTime(2026, 10, 16, 9),
  oldValue: '0',
  newValue: '3',
  quantityChange: 3,
  isIncreased: true,
  unit: 'Sheets (4 x 2)',
  primaryUnit: 'Sheets',
  event: 'production_deleted',
  staffId: 's-bola',
  staffName: 'Bola',
  isManaged: true,
);
final pieCreated = makeRecord(
  uuid: 'h-pie',
  title: 'Item Created',
  itemName: 'Meat Pie',
  itemUuid: 'pie',
  createdAt: DateTime(2026, 10, 17, 9),
  oldValue: null,
  newValue: '5',
  quantityChange: 5,
  isIncreased: true,
  unit: 'Pcs',
  primaryUnit: 'Pcs',
  event: 'created',
  isManaged: null,
);
final goneDeleted = makeRecord(
  uuid: 'h-gone',
  title: 'Item Deleted',
  itemName: 'Old Juice',
  itemUuid: 'gone',
  createdAt: DateTime(2026, 10, 18, 9),
  quantityChange: null,
  event: 'deleted',
  staffId: 's-ada',
  staffName: 'Ada',
  departmentUuid: 'd-back',
  departmentName: 'Back Store',
);
final sample = [saleOfCoke, sheetProduced, pieCreated, goneDeleted];

ReportExportSpec specFor(
  List<ItemHistory> rows, {
  ItemHistoryReportFilters? filters,
  ItemHistorySortField sortField = ItemHistorySortField.createdAt,
  bool ascending = false,
  bool departmentsEnabled = true,
  String dateLabel = 'All Dates',
  String? lockedItemName,
}) {
  return itemHistoryExportSpec(
    rows: rows,
    filters: filters ?? ItemHistoryReportFilters(),
    sortField: sortField,
    ascending: ascending,
    dateLabel: dateLabel,
    currency: '₦',
    departmentsEnabled: departmentsEnabled,
    lockedItemName: lockedItemName,
    itemNames: const {'coke': 'Coke', 'pie': 'Meat Pie'},
    staffNames: const {'s-ada': 'Ada', 's-bola': 'Bola'},
    departmentNames: departmentNames,
    categoryIdsByItem: categoryIdsByItem,
    categoryNames: categoryNames,
    sizeLabels: sizeLabels,
  );
}

ResolvedTable tableOf(ReportExportSpec spec) =>
    resolveExport(spec, testCtx).tables.single;

List<String> columnIds(ReportExportSpec spec) => [
  for (final c in tableOf(spec).columns) c.id,
];

ResolvedCell cellOf(ReportExportSpec spec, String item, String columnId) {
  final t = tableOf(spec);
  final row = t.rows.firstWhere((r) => r[t.indexOf('item')].text == item);
  return row[t.indexOf(columnId)];
}

void main() {
  group('rows are the screen query, every page', () {
    test('150 matching records, filtered and sorted like the screen', () {
      final records = [
        for (var i = 0; i < 160; i++)
          makeRecord(
            uuid: 'r$i',
            itemName: 'Item ${(i * 37) % 160}',
            itemUuid: 'i$i',
            createdAt: DateTime(2026, 10, 1).add(Duration(minutes: i)),
            quantityChange: 1,
            isIncreased: true,
            event: i < 150 ? 'sale' : 'purchase',
          ),
      ];
      final filters = ItemHistoryReportFilters()..event = 'sale';
      final sorted = ItemHistoryReportQuery.filterAndSort(
        rows: records,
        filters: filters,
        sortField: ItemHistorySortField.itemName,
        ascending: true,
        departmentsEnabled: true,
      );
      final page = ItemHistoryReportQuery.paginate(sorted, 1);
      expect(page.rows, hasLength(100));

      final spec = specFor(
        sorted,
        filters: filters,
        sortField: ItemHistorySortField.itemName,
        ascending: true,
      );
      final section = spec.tables.single;
      expect(section.rowCount, 150);
      expect(section.erasedRows, orderedEquals(sorted));

      final t = tableOf(spec);
      expect(t.rows.first[t.indexOf('no')].text, '1');
      expect(t.rows.last[t.indexOf('no')].text, '150');
      expect(
        [for (final r in t.rows) r[t.indexOf('item')].text],
        [for (final h in sorted) h.itemName],
      );
    });
  });

  group('columns follow the screen', () {
    test('every screen column, in order, Department when on', () {
      expect(columnIds(specFor(sample)), [
        'no',
        'item',
        'created',
        'title',
        'event',
        'source',
        'destination',
        'supplier',
        'tracking',
        'desc',
        'qty',
        'unit',
        'old',
        'new',
        'department',
        'managed',
        'staff',
      ]);
      expect(
        columnIds(specFor(sample, departmentsEnabled: false)),
        isNot(contains('department')),
      );
    });

    test('Supplier, Tracking Number, Unit and Managed are Excel-only', () {
      final t = tableOf(specFor(sample));
      final excelOnly = [
        for (final c in t.columns)
          if (!c.inPdf) c.id,
      ];
      expect(excelOnly, ['supplier', 'tracking', 'unit', 'managed']);
      // 13 PDF columns with departments.
      expect(t.pdfColumnIndexes, hasLength(13));
    });
  });

  group('cells', () {
    test('a sale: signed quantity, screen texts', () {
      final spec = specFor(sample);
      final qty = cellOf(spec, 'Coke', 'qty');
      expect(qty.raw, -2);
      expect(qty.text, '-2 Bottle(s)');
      expect(cellOf(spec, 'Coke', 'event').text, 'Sale');
      expect(cellOf(spec, 'Coke', 'source').text, 'Product');
      expect(cellOf(spec, 'Coke', 'destination').text, 'Receipt');
      expect(cellOf(spec, 'Coke', 'created').text, 'Oct 15, 2026 | 10:30 AM');
      expect(cellOf(spec, 'Coke', 'old').raw, 10);
      expect(cellOf(spec, 'Coke', 'old').text, '10.0 Bottle(s)');
      expect(cellOf(spec, 'Coke', 'new').text, '8.0 Bottle(s)');
      expect(cellOf(spec, 'Coke', 'supplier').text, 'Coca Cola Plc');
      expect(cellOf(spec, 'Coke', 'tracking').text, 'TRK-1');
      expect(cellOf(spec, 'Coke', 'managed').text, 'Managed');
      expect(cellOf(spec, 'Coke', 'staff').text, 'Ada');
      expect(cellOf(spec, 'Coke', 'department').text, 'Front Shop');
    });

    test('a 2D sheet item reads "+3 Sheets (4 x 2)"', () {
      final qty = cellOf(specFor(sample), 'Sheet', 'qty');
      expect(qty.raw, 3);
      expect(qty.text, '+3 Sheets (4 x 2)');
    });

    test('empty values read as on screen', () {
      final spec = specFor(sample);
      expect(cellOf(spec, 'Old Juice', 'qty').text, 'N/A');
      expect(cellOf(spec, 'Old Juice', 'qty').raw, isNull);
      expect(cellOf(spec, 'Meat Pie', 'old').text, '—');
      expect(cellOf(spec, 'Meat Pie', 'managed').text, 'N/A');
      expect(cellOf(spec, 'Meat Pie', 'staff').text, '—');
      expect(cellOf(spec, 'Meat Pie', 'department').text, '—');
    });
  });

  group('totals', () {
    test('export-only record count, nothing summed', () {
      final t = tableOf(specFor(sample));
      expect(t.totals![t.indexOf('item')].text, '4 records');
      expect(t.totals![t.indexOf('qty')].text, isEmpty);
      expect(tableOf(specFor([saleOfCoke])).totals![1].text, '1 record');
    });
  });

  group('splits', () {
    final f = ExportFormatter(currency: '₦');
    List<String> items(ResolvedGroup g) => [
      for (final r in g.table.rows) r[g.table.indexOf('item')].text,
    ];

    test('Category, Department and Staff are offered', () {
      expect(specFor(sample).splitOptions.map((s) => s.id), [
        'category',
        'department',
        'staff',
      ]);
      expect(
        specFor(sample, departmentsEnabled: false).splitOptions.map((s) => s.id),
        ['category', 'staff'],
      );
    });

    test('categories from the products; two-category item on both', () {
      final groups = resolveGroups(specFor(sample).tables.single, 'category', f);
      expect(groups.map((g) => g.name), ['Bakery', 'Drinks', 'No Category']);
      // Each group keeps the export's row order.
      expect(items(groups[0]), ['Sheet', 'Meat Pie']);
      expect(items(groups[1]), ['Coke', 'Meat Pie']);
      // The deleted item has no product, so no category.
      expect(items(groups[2]), ['Old Juice']);
      expect(groups[2].table.totals![1].text, '1 record');
    });

    test('departments with "No Department" last', () {
      final groups = resolveGroups(specFor(sample).tables.single, 'department', f);
      expect(groups.map((g) => g.name), [
        'Back Store',
        'Front Shop',
        'No Department',
      ]);
      expect(items(groups[2]), ['Sheet', 'Meat Pie']);
    });

    test('staff with "No Staff" last', () {
      final groups = resolveGroups(specFor(sample).tables.single, 'staff', f);
      expect(groups.map((g) => g.name), ['Ada', 'Bola', 'No Staff']);
      expect(items(groups[0]), ['Coke', 'Old Juice']);
      expect(items(groups[2]), ['Meat Pie']);
    });
  });

  group('info box', () {
    test('date range, filters with values, sort', () {
      final filters = ItemHistoryReportFilters()
        ..search = 'coke'
        ..itemUuid = 'coke'
        ..event = 'sale'
        ..staffId = 's-ada'
        ..quantityDirection = QuantityDirectionFilter.decrease
        ..source = 'product'
        ..supplier = 'Coca Cola Plc'
        ..trackingNumber = 'TRK'
        ..destination = 'receipt'
        ..departmentUuid = itemHistoryReportNoneKey
        ..isManaged = true
        ..dateRange = DateTimeRange(
          start: DateTime(2026, 10, 1),
          end: DateTime(2026, 10, 31),
        );
      final spec = specFor(
        [saleOfCoke],
        filters: filters,
        sortField: ItemHistorySortField.quantityChange,
        ascending: true,
        dateLabel: 'Oct 1, 2026 - Oct 31, 2026',
      );
      expect({for (final x in spec.filters) x.label: x.value}, {
        'Search': '"coke"',
        'Item': 'Coke',
        'Event': 'Sale',
        'Creator': 'Ada',
        'Direction': 'Decrease',
        'Source': 'Product',
        'Supplier': 'Coca Cola Plc',
        'Tracking': 'TRK',
        'Destination': 'Receipt',
        'Department': 'No Department',
        'Managed': 'Managed',
      });
      expect(spec.sortedBy, 'Quantity Change (ascending)');
      expect(spec.period!.start, DateTime(2026, 10, 1));

      final info = {
        for (final e in reportPdfInfoEntries(resolveExport(spec, testCtx)))
          e.$1: e.$2,
      };
      expect(info['Period'], 'Oct 1, 2026 - Oct 31, 2026');
      expect(info['Filters Applied'], contains('Event: Sale'));
      expect(info['Filters Applied'], contains('Creator: Ada'));
      expect(info['Sorted By'], 'Quantity Change (ascending)');
    });

    test('a locked item shows as the Item filter; defaults', () {
      final spec = specFor(sample, lockedItemName: 'Coke');
      expect(spec.filters.single.label, 'Item');
      expect(spec.filters.single.value, 'Coke');
      expect(specFor(sample).filters, isEmpty);
      expect(specFor(sample).sortedBy, 'Created Date (descending)');
      expect(specFor(sample).period!.label, 'All Dates');
      expect(itemHistorySortLabels.length, ItemHistorySortField.values.length);
      expect(specFor(sample).fileSlug, 'item_history');
    });

    test('Department filter hidden when departments are off', () {
      final spec = specFor(
        sample,
        filters: ItemHistoryReportFilters()..departmentUuid = 'd-front',
        departmentsEnabled: false,
      );
      expect(spec.filters, isEmpty);
    });
  });

  group('roll', () {
    String preview(RollPaper paper) => renderRollEscPos(
      buildRollLines(specFor(sample), testCtx, paper: paper),
      paper,
    ).preview;
    List<String> lines(String text) => text.split('\n');

    test('58mm: Item · ±Qty on one line, date/time underneath', () {
      final out = lines(preview(RollPaper.mm58));
      final sheet = out.indexWhere((l) => l.startsWith('Sheet'));
      expect(out[sheet], endsWith('+3 Sheets (4 x 2)'));
      expect(out[sheet + 1].trim(), 'Oct 16, 2026 | 09:00 AM');
      final coke = out.firstWhere((l) => l.startsWith('Coke'));
      expect(coke, endsWith('-2 Bottle(s)'));
      expect(out.every((l) => l.length <= 32), isTrue);
    });

    test('80mm: Item · Event · ±Qty, date | staff underneath', () {
      final out = lines(preview(RollPaper.mm80));
      final sheet = out.indexWhere((l) => l.startsWith('Sheet'));
      expect(out[sheet], contains('Production Deleted'));
      expect(out[sheet], endsWith('+3 Sheets (4 x 2)'));
      expect(out[sheet + 1].trim(), 'Oct 16, 2026 | 09:00 AM | Bola');
      expect(out.firstWhere((l) => l.startsWith('Coke')), contains('Sale'));
      expect(out.every((l) => l.length <= 48), isTrue);
      expect(preview(RollPaper.mm80), contains('4 records'));
    });
  });

  group('Item History screen', () {
    setUpAll(setUpScreenEnvironment);
    tearDownAll(() async => Hive.close());

    for (final desktop in [true, false]) {
      testWidgets('shows the Export pill (${desktop ? 'desktop' : 'mobile'})', (
        tester,
      ) async {
        await pumpReportScreen(
          tester,
          ItemHistoryReportView(isDesktop: desktop),
          desktop: desktop,
        );
        if (!desktop) {
          // The toolbar pills sit behind "View" on narrow screens.
          expect(find.text('Export'), findsNothing);
          await tester.tap(find.text('View'));
          await settleReportScreen(tester);
        }
        expect(find.text('Export'), findsOneWidget);
      });
    }
  });
}
