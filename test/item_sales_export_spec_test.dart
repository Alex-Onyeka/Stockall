import 'package:flutter/material.dart' show TimeOfDay;
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/pages/report/components/export/report_export_format.dart';
import 'package:stockall/pages/report/components/export/report_export_resolve.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/export/report_pdf_builder.dart';
import 'package:stockall/pages/report/components/export/report_roll_builder.dart';
import 'package:stockall/pages/report/sales_report_/item_sales_report_main/class/item_sales_export_spec.dart';
import 'package:stockall/pages/report/sales_report_/item_sales_report_main/class/item_sales_report_logic.dart';
import 'package:stockall/pages/report/sales_report_/item_sales_report_main/components/item_sales_report_main_view.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/components/receipts_report_filter_widgets.dart';

import 'item_history_export_fixtures.dart' show testCtx;
import 'item_sales_report_logic_test.dart'
    show build, categoryNames, line, product, receipt, run;
import 'report_export_screen_harness.dart';

final products = [
  product('p-1', categories: ['c-drinks']),
  product('p-2', categories: ['c-snacks', 'c-drinks']),
];

/// Ada's cash sale (Cola x2, Chips x1 without a cost, a void Cola),
/// Bola's ₦1,250,000 bank sale of Cola, an invoice part payment that
/// repeats Cola x5, and a line of a deleted item.
List<TempMainReceipt> receipts({String chipsUnit = 'Bottles'}) => [
  receipt(
    uuid: 'r-1',
    barcode: '1000000000001',
    createdAt: DateTime(2026, 10, 17, 9),
    cash: 700,
    customerUuid: 'c-chidi',
    customerName: 'Chidi',
    departmentUuid: 'd-front',
    departmentName: 'Front Shop',
    items: [
      line(uuid: 'l-cola', productUuid: 'p-1', productName: 'Cola', quantity: 2, revenue: 500, costPrice: 300, unitText: 'Bottles'),
      line(uuid: 'l-chips', productUuid: 'p-2', productName: 'Chips', quantity: 1, revenue: 200, unitText: chipsUnit),
      line(uuid: 'l-void', productUuid: 'p-1', productName: 'Cola', quantity: 1, revenue: 50, costPrice: 30, unitText: 'Bottles', isVoid: true),
    ],
  ),
  receipt(
    uuid: 'r-2',
    barcode: '1000000000002',
    createdAt: DateTime(2026, 10, 17, 10),
    bank: 1250000,
    staffId: 'staff-b',
    staffName: 'Bola',
    items: [
      line(uuid: 'l-big', productUuid: 'p-1', productName: 'Cola', quantity: 1, revenue: 1250000, costPrice: 1000, unitText: 'Bottles'),
    ],
  ),
  receipt(
    uuid: 'r-3',
    barcode: '1000000000003',
    createdAt: DateTime(2026, 10, 17, 11),
    salesTypeIndex: 2,
    invoiceUuid: 'inv-1',
    cash: 100,
    items: [
      line(uuid: 'l-part', productUuid: 'p-1', productName: 'Cola', quantity: 5, revenue: 100, costPrice: 60, unitText: 'Bottles'),
    ],
  ),
  receipt(
    uuid: 'r-4',
    barcode: '1000000000004',
    createdAt: DateTime(2026, 10, 17, 12),
    cash: 80,
    items: [
      line(uuid: 'l-gone', productUuid: 'gone', productName: 'Old Juice', quantity: 1, revenue: 80, costPrice: 40, unitText: 'Bottles'),
    ],
  ),
];

final base = build(receipts(), products: products);
final sample = run(base);

ReportExportSpec specFor(
  List<ItemSalesRow> rows, {
  bool groupByItem = false,
  ItemSalesFilters? filters,
  ReceiptsReportPeriod period = const ReceiptsReportPeriod.allTime(),
  ItemSalesSortField sortField = ItemSalesSortField.createdAt,
  bool ascending = false,
  List<String> notes = const [],
  bool canSeeCost = true,
  bool departmentsEnabled = true,
  bool subStaffEnabled = true,
  String? lockedItemName,
}) {
  final groups = ItemSalesGrouping.sort(
    ItemSalesGrouping.build(rows),
    field: ItemSalesSortField.revenue,
    ascending: false,
  );
  return itemSalesExportSpec(
    rows: rows,
    groups: groups,
    groupByItem: groupByItem,
    filters: filters ?? ItemSalesFilters(),
    categoryOptions: ItemSalesOptions.categories(categoryNames, rows),
    itemOptions: ItemSalesOptions.items(rows),
    choices: ReceiptsFilterChoices.fromRows([for (final r in rows) r.parent]),
    period: period,
    sortField: sortField,
    ascending: ascending,
    groupSortField: ItemSalesSortField.revenue,
    groupAscending: false,
    notes: notes,
    currency: '₦',
    canSeeCost: canSeeCost,
    departmentsEnabled: departmentsEnabled,
    subStaffEnabled: subStaffEnabled,
    lockedItemName: lockedItemName,
  );
}

ResolvedTable tableOf(ReportExportSpec spec) =>
    resolveExport(spec, testCtx).tables.single;

List<ResolvedCell> rowOf(ReportExportSpec spec, String lineUuid) {
  final t = tableOf(spec);
  final rows = spec.tables.single.erasedRows.cast<ItemSalesRow>();
  return t.rows[rows.indexWhere((r) => r.line.uuid == lineUuid)];
}

String cell(ReportExportSpec spec, String lineUuid, String column) =>
    rowOf(spec, lineUuid)[tableOf(spec).indexOf(column)].text;

void main() {
  group('rows are the screen query, every page', () {
    test('150 lines in the screen order, beyond the 100-row page', () {
      final many = build([
        for (var i = 0; i < 150; i++)
          receipt(
            uuid: 'r-$i',
            barcode: '$i',
            createdAt: DateTime(2026, 10, 17, 8).add(Duration(minutes: i)),
            items: [
              line(uuid: 'l-$i', quantity: 1, revenue: ((i * 37) % 150 + 1) * 10.0),
            ],
          ),
      ], products: products);
      final sorted = run(many, sortField: ItemSalesSortField.revenue);
      expect(ItemSalesQuery.paginate(sorted, 1).rows, hasLength(100));
      final spec = specFor(sorted, sortField: ItemSalesSortField.revenue);
      expect(spec.tables.single.erasedRows, orderedEquals(sorted));
      expect(tableOf(spec).rows, hasLength(150));
      expect(spec.sortedBy, 'Revenue (descending)');
    });

    test('void lines are hidden by the screen filter, as on screen', () {
      expect(sample.any((r) => r.isVoid), isFalse);
      expect(sample, hasLength(5));
    });
  });

  group('columns', () {
    test('ItemSalesColumnInfo.visible, in order, plus the roll-only cell', () {
      for (final cost in [true, false]) {
        final visible = ItemSalesColumnInfo.visible(
          departmentsEnabled: true,
          subStaffEnabled: false,
          costVisible: cost,
        );
        final t = tableOf(specFor(sample, canSeeCost: cost, subStaffEnabled: false));
        expect([for (final c in t.columns) c.id], [
          for (final c in visible) c.name,
          'itemQty',
        ]);
        expect([for (final c in t.columns.take(visible.length)) c.label], [
          for (final c in visible) c.label,
        ]);
      }
    });

    test('Excel-only and roll-only columns', () {
      final t = tableOf(specFor(sample));
      expect([for (final c in t.columns) if (!c.inPdf && c.inExcel) c.id], [
        'recordId', 'sellingPrice', 'grossValue', 'customPrice',
        'wholesale', 'managed', 'voidStatus', 'wastage',
      ]);
      expect(t.excelColumnIndexes, isNot(contains(t.indexOf('itemQty'))));
      expect(t.pdfColumnIndexes, isNot(contains(t.indexOf('itemQty'))));
      // Void moves into the PDF when the void filter shows void lines.
      final all = specFor(
        run(base, filters: ItemSalesFilters(voidFilter: ItemSalesVoidFilter.all)),
        filters: ItemSalesFilters(voidFilter: ItemSalesVoidFilter.all),
      );
      final at = tableOf(all);
      expect(at.columns[at.indexOf('voidStatus')].inPdf, isTrue);
    });
  });

  group('cells', () {
    test('screen texts', () {
      final spec = specFor(sample);
      expect(cell(spec, 'l-cola', 'item'), 'Cola');
      expect(cell(spec, 'l-cola', 'quantity'), '2');
      expect(cell(spec, 'l-cola', 'unit'), 'Bottles');
      expect(cell(spec, 'l-cola', 'category'), 'Drinks');
      expect(cell(spec, 'l-chips', 'category'), contains('Snacks'));
      expect(cell(spec, 'l-chips', 'costPrice'), 'N/A');
      expect(cell(spec, 'l-gone', 'category'), 'Unknown (deleted item)');
      expect(cell(spec, 'l-part', 'type'), 'Invoice Payment');
      expect(cell(spec, 'l-cola', 'receiptId'), '#1000000000001');
      expect(cell(spec, 'l-cola', 'voidStatus'), 'No');
      expect(cell(spec, 'l-cola', 'itemQty'), 'Cola ×2');
    });
  });

  group('totals', () {
    test('equal ItemSalesPage: void and part-payment rules as the screen', () {
      final page = ItemSalesQuery.paginate(sample, 1);
      final t = tableOf(specFor(sample));
      Object? total(String id) => t.totals![t.indexOf(id)].raw;
      expect(total('revenue'), page.totalRevenue);
      expect(total('profit'), page.totalProfit);
      expect(total('margin'), page.totalMargin);
      expect(total('discount'), page.totalDiscount);
      expect(total('grossValue'), page.totalGrossValue);
      expect(total('costPrice'), page.totalCost);
      // The part payment's 5 is left out: 2 + 1 + 1 + 1.
      expect(page.totalQuantity, 5);
      expect(t.totals![t.indexOf('quantity')].text, '5 Bottles');
      expect(t.totals![t.indexOf('item')].text, '5 item records');
    });

    test('void lines are never counted, even when shown', () {
      final filters = ItemSalesFilters(voidFilter: ItemSalesVoidFilter.all);
      final rows = run(base, filters: filters);
      final t = tableOf(specFor(rows, filters: filters));
      expect(rows.any((r) => r.isVoid), isTrue);
      expect(t.totals![t.indexOf('revenue')].raw, ItemSalesQuery.paginate(sample, 1).totalRevenue);
    });

    test('no quantity total with mixed units, as on screen', () {
      final rows = run(build(receipts(chipsUnit: 'Packs'), products: products));
      final t = tableOf(specFor(rows));
      expect(ItemSalesQuery.paginate(rows, 1).totalQuantity, isNull);
      expect(t.totals![t.indexOf('quantity')].text, isEmpty);
    });

    test('no cost access: no cost totals', () {
      final t = tableOf(specFor(sample, canSeeCost: false));
      expect(t.indexOf('profit'), -1);
      expect(t.indexOf('costPrice'), -1);
    });
  });

  group('grouped by item', () {
    test('the group table, no totals row, "Grouped by: Item", no splits', () {
      final spec = specFor(sample, groupByItem: true);
      final groups = ItemSalesGrouping.sort(
        ItemSalesGrouping.build(sample),
        field: ItemSalesSortField.revenue,
        ascending: false,
      );
      final t = tableOf(spec);
      expect([for (final c in t.columns) c.label], [
        for (final c in ItemSalesGroupColumnInfo.visible(costVisible: true)) c.label,
      ]);
      expect([for (final r in t.rows) r[0].text], [for (final g in groups) g.itemLabel]);
      expect(t.totals, isNull);
      expect(spec.groupedBy, 'Item');
      expect(spec.sortedBy, 'Total Revenue (descending)');
      expect(spec.splitOptions, isEmpty);
      // Cola: 2 + 1 counted, the part payment's 5 left out.
      final cola = t.rows.firstWhere((r) => r[0].text == 'Cola');
      expect(cola[t.indexOf('quantity')].raw, 3);
    });
  });

  group('splits', () {
    final f = ExportFormatter(currency: '₦');
    List<String> names(String id) => [
      for (final g in resolveGroups(specFor(sample).tables.single, id, f)) g.name,
    ];

    test('Category, Department, Staff, Channel', () {
      expect(specFor(sample).splitOptions.map((s) => s.id), [
        'category',
        'department',
        'staff',
        'channel',
      ]);
      expect(names('category'), ['Drinks', 'Snacks', 'No Category']);
      expect(names('department'), ['Front Shop', 'No Department']);
      expect(names('staff'), ['Ada', 'Bola']);
      expect(names('channel'), ['Bank', 'Cash']);
    });

    test('an item in two categories is on both; a deleted item has none', () {
      final groups = resolveGroups(specFor(sample).tables.single, 'category', f);
      List<String> items(int i) => [
        for (final r in groups[i].table.rows) r[groups[i].table.indexOf('item')].text,
      ];
      expect(items(0), contains('Chips'));
      expect(items(1), ['Chips']);
      expect(items(2), ['Old Juice']);
    });
  });

  group('info box', () {
    test('item chips then receipt chips, as on screen', () {
      final filters = ItemSalesFilters(
        receipt: ReceiptsReportFilters(search: 'co', staffKey: 'staff-a'),
        categoryKey: 'c-drinks',
        productKey: 'p-1',
        voidFilter: ItemSalesVoidFilter.voidOnly,
        customPrice: false,
        wholesale: true,
        quantityMin: 2,
      );
      final spec = specFor(sample, filters: filters);
      expect([for (final x in spec.filters) '${x.label}: ${x.value}'], [
        'Category: Drinks',
        'Item: Cola',
        'Void: Void',
        'Custom Price: No',
        'Wholesale Price: Yes',
        'Quantity: 2 - Any',
        'Search: co',
        'Staff: Ada',
      ]);
      expect(itemSalesSortLabels.length, ItemSalesSortField.values.length);
    });

    test('the locked item shows as the Item filter', () {
      final spec = specFor(sample, lockedItemName: 'Cola');
      expect(spec.filters.single.label, 'Item');
      expect(spec.filters.single.value, 'Cola');
    });
  });

  group('notes', () {
    List<String> notesFor(
      List<ItemSalesRow> rows,
      ItemSalesFilters filters, {
      ReceiptsReportPeriod period = const ReceiptsReportPeriod.allTime(),
      bool grouped = false,
    }) {
      int count(int Function({
        required List<ItemSalesRow> rows,
        required ReceiptsReportPeriod period,
        required ItemSalesFilters filters,
        required bool departmentsEnabled,
        required bool subStaffEnabled,
        required bool profitVisible,
        TimeOfDay? closingTime,
      }) fn) => fn(
        rows: base,
        period: period,
        filters: filters,
        departmentsEnabled: true,
        subStaffEnabled: true,
        profitVisible: true,
      );
      final groups = ItemSalesGrouping.build(rows);
      return itemSalesNotes(
        period: period,
        cartDiscountInView: itemSalesCartDiscountInView(rows),
        profitExcluded: count(ItemSalesQuery.profitExcludedCount),
        quantityExcluded: count(ItemSalesQuery.quantityExcludedCount),
        groupByItem: grouped,
        groupQuantityExcluded: groups.fold(0, (s, g) => s + g.quantityExcludedCount),
      );
    }

    test('appear exactly when the screen conditions hold', () {
      // Quantity range on Cola: the part payment is left out of the
      // range (and so of the rows, so no Total Quantity note even when
      // grouped). All time: the device note.
      final filters = ItemSalesFilters(productKey: 'p-1', quantityMin: 0);
      final rows = run(base, filters: filters);
      final notes = notesFor(rows, filters, grouped: true);
      expect(notes, [
        'All time covers the receipts loaded on this device.',
        '1 item record is left out of the quantity range: invoice part '
            'payment or unknown unit.',
      ]);
      // Grouped with the part payment in view: it is not in Total
      // Quantity.
      expect(notesFor(sample, ItemSalesFilters(), grouped: true), [
        'All time covers the receipts loaded on this device.',
        '1 invoice part-payment line is not in Total Quantity: they '
            'repeat the invoice\'s full quantity.',
      ]);
      final profitOnly = ItemSalesFilters()..receipt.profitMin = -1000000;
      expect(
        notesFor(run(base, filters: profitOnly), profitOnly),
        contains('1 item record is left out of the profit range: missing cost price.'),
      );
      final spec = specFor(rows, filters: filters, groupByItem: true, notes: notes);
      final info = {
        for (final e in reportPdfInfoEntries(resolveExport(spec, testCtx))) e.$1: e.$2,
      };
      expect(info['Notes'], notes.join('\n'));
    });

    test('the cart-discount note follows the receipts in view', () {
      final withDiscount = receipts();
      withDiscount.first.generalDiscount = 10;
      final rows = run(build(withDiscount, products: products));
      expect(
        notesFor(rows, ItemSalesFilters()),
        contains('Cart discounts on a receipt are not included in its item revenue.'),
      );
    });

    test('none for one day without ranges or grouping', () {
      final notes = notesFor(
        sample,
        ItemSalesFilters(),
        period: ReceiptsReportPeriod.day(DateTime(2026, 10, 17)),
      );
      expect(notes, isEmpty);
      // Not grouped, so the part payment's Total Quantity note is off.
      expect(notesFor(sample, ItemSalesFilters()), [
        'All time covers the receipts loaded on this device.',
      ]);
    });
  });

  group('roll', () {
    String preview(ReportExportSpec spec, RollPaper paper) => renderRollEscPos(
      buildRollLines(spec, testCtx, paper: paper),
      paper,
    ).preview;

    test('58mm: Item ×qty · Revenue', () {
      final out = preview(specFor(sample), RollPaper.mm58).split('\n');
      expect(out.firstWhere((l) => l.startsWith('Cola x2 ')), endsWith('N500.00'));
      expect(out.firstWhere((l) => l.startsWith('Cola x1 ')), endsWith('N1,250,000.00'));
      expect(out.every((l) => l.length <= 32), isTrue);
      // The quantity total keeps its label.
      expect(out.firstWhere((l) => l.startsWith('Quantity')), endsWith('5 Bottles'));
    });

    test('80mm: Item · Qty · Revenue, receipt ID | time underneath', () {
      final out = preview(specFor(sample), RollPaper.mm80).split('\n');
      final i = out.indexWhere((l) => l.startsWith('Cola') && l.endsWith('N1,250,000.00'));
      expect(i, greaterThan(0));
      expect(out[i], contains(' 1 '));
      expect(out[i + 1].trim(), '#1000000000002 | 10:00 AM');
      expect(out.every((l) => l.length <= 48), isTrue);
    });

    test('grouped: Item · Total Quantity · Total Revenue', () {
      final out = preview(specFor(sample, groupByItem: true), RollPaper.mm80).split('\n');
      final cola = out.firstWhere((l) => l.startsWith('Cola '));
      expect(cola, contains(' 3 '));
      // 500 + 1,250,000 + the part payment's 100.
      expect(cola, endsWith('N1,250,600.00'));
    });
  });

  group('Item Sales screen', () {
    setUpAll(setUpScreenEnvironment);
    tearDownAll(() async => Hive.close());

    for (final desktop in [true, false]) {
      testWidgets('shows the Export pill (${desktop ? 'desktop' : 'mobile'})', (
        tester,
      ) async {
        await pumpReportScreen(
          tester,
          ItemSalesReportMainView(isDesktop: desktop),
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
