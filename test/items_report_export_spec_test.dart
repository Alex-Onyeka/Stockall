import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_product_class/units_class/product_units_class.dart';
import 'package:stockall/pages/report/components/export/report_export_format.dart';
import 'package:stockall/pages/report/components/export/report_export_resolve.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/export/report_pdf_builder.dart';
import 'package:stockall/pages/report/components/export/report_roll_builder.dart';
import 'package:stockall/pages/report/items_report_/items_report_main/class/items_report_export_spec.dart';
import 'package:stockall/pages/report/items_report_/items_report_main/class/items_report_main_logic.dart';
import 'package:stockall/pages/report/items_report_/items_report_main/components/items_report_main_view.dart';

import 'report_export_screen_harness.dart';

// ---------------------------------------------------------------------
// Fixtures (rows built directly, as item_history_summary_test.dart does)
// ---------------------------------------------------------------------

const categoryNames = {
  'c-drinks': 'Drinks',
  'c-bakery': 'Bakery',
};
const departmentNames = {'d-front': 'Front Shop', 'd-back': 'Back Store'};

final ctx = ExportContext(
  shopName: 'Mama Put Stores',
  currencySymbol: '₦',
  generatedBy: 'Ada Obi',
  generatedAt: DateTime(2026, 11, 4, 14, 5),
);

ItemsReportRow itemRow({
  required String id,
  required String name,
  double? qty = 1,
  String unit = 'Pcs',
  double selling = 100,
  double cost = 50,
  List<String> categories = const [],
  String? dept,
  DateTime? expiry,
  bool expired = false,
  double? discount,
  DateTime? created,
  bool twoD = false,
  int dimensionType = ProductUnitsClass.sheetUnit,
  double? width,
  double? height,
  String? dimensionUnit,
}) {
  final product = TempProductClass(
    uuid: id,
    name: name,
    shopId: 1,
    unit: unit,
    quantityType: twoD ? 2 : 1,
    widthDimension: width,
    heightDimension: height,
    dimensionUnit: dimensionUnit,
    quantity: qty,
    isManaged: qty != null,
    isRefundable: false,
    costPrice: cost,
    sellingPrice: selling,
    setCustomPrice: false,
    departmentName: departmentNames[dept],
    departmentUuid: dept,
    groupUnit: null,
    qttyPerGroup: null,
    wholeSalePrice: null,
    storageUuid: null,
    categories: categories,
    useGroupUnit: false,
    pricesList: [],
    manageSalesWastage: false,
    unitsList: [
      ProductUnitsClass(
        uuid: 'unit-$id',
        staffUuid: null,
        createdAt: DateTime.utc(2026),
        staffName: null,
        conversion: 1,
        name: unit,
        isPrimary: true,
        productUuid: id,
        dimensionType: twoD ? dimensionType : null,
      ),
    ],
    createdAt: created,
  );
  final total = qty == null ? null : qty * selling;
  final totalCost = qty == null ? null : qty * cost;
  return ItemsReportRow(
    product: product,
    name: name,
    primaryUnit: unit,
    quantity: qty,
    sellingPrice: selling,
    costPrice: cost,
    totalSellingValue: total,
    totalCostValue: totalCost,
    profit: total == null ? null : total - totalCost!,
    margin: selling > 0 ? (selling - cost) / selling * 100 : null,
    discount: discount,
    expiryDate: expiry,
    isExpired: expired,
    isTwoDimensional: twoD,
    isManaged: qty != null,
    createdAt: created,
    categoryUuids: categories,
    categoryNames: [for (final c in categories) categoryNames[c]!],
    departmentUuid: dept,
    departmentName: departmentNames[dept],
    stockLevel: qty == null || qty <= 0
        ? StockLevelFilter.outOfStock
        : StockLevelFilter.inStock,
  );
}

final coke = itemRow(
  id: 'coke',
  name: 'Coke',
  qty: 12,
  unit: 'Bottles',
  selling: 125,
  cost: 100,
  categories: const ['c-drinks'],
  dept: 'd-front',
  created: DateTime(2026, 10, 1, 9, 30),
  expiry: DateTime(2027, 1, 31),
);
final pie = itemRow(
  id: 'pie',
  name: 'Meat Pie',
  qty: 5,
  unit: 'Trays',
  selling: 1000,
  cost: 700,
  categories: const ['c-bakery', 'c-drinks'],
  dept: 'd-back',
  discount: 10,
  expiry: DateTime(2026, 10, 1),
  expired: true,
);
final roofing = itemRow(
  id: 'roof',
  name: 'Roofing Sheet',
  qty: 3,
  unit: 'Sheets',
  selling: 800,
  cost: 600,
  twoD: true,
  width: 4,
  height: 2,
);
final service = itemRow(
  id: 'svc',
  name: 'Service Charge',
  qty: null,
  selling: 50,
  cost: 0,
);
final sample = [coke, pie, roofing, service];

ReportExportSpec specFor(
  List<ItemsReportRow> rows, {
  ItemsReportFilters? filters,
  ItemsSortField sortField = ItemsSortField.name,
  bool ascending = true,
  bool canSeeCost = true,
  bool canSeeQuantity = true,
  bool departmentsEnabled = true,
  bool historyTracked = true,
  Map<String, ItemStockMovement> movements = const {},
}) {
  return itemsReportExportSpec(
    rows: rows,
    filters: filters ?? ItemsReportFilters(),
    sortField: sortField,
    ascending: ascending,
    rangeLabel: 'Oct 1, 2026 - Oct 31, 2026',
    currency: '₦',
    canSeeCost: canSeeCost,
    canSeeQuantity: canSeeQuantity,
    departmentsEnabled: departmentsEnabled,
    historyTracked: historyTracked,
    movement: (uuid) => movements[uuid],
    categoryNames: categoryNames,
    departmentNames: departmentNames,
  );
}

ResolvedTable tableOf(ReportExportSpec spec) =>
    resolveExport(spec, ctx).tables.single;

List<String> columnIds(ReportExportSpec spec) => [
  for (final c in tableOf(spec).columns) c.id,
];

String cell(ReportExportSpec spec, String rowName, String columnId) {
  final t = tableOf(spec);
  final row = t.rows.firstWhere(
    (r) => r[t.indexOf('name')].text == rowName,
  );
  return row[t.indexOf(columnId)].text;
}

Object? raw(ReportExportSpec spec, String rowName, String columnId) {
  final t = tableOf(spec);
  final row = t.rows.firstWhere(
    (r) => r[t.indexOf('name')].text == rowName,
  );
  return row[t.indexOf(columnId)].raw;
}

Future<void> pumpItemsScreen(WidgetTester tester, {required bool desktop}) =>
    pumpReportScreen(
      tester,
      ItemsReportMainView(isDesktop: desktop),
      desktop: desktop,
    );

void main() {
  group('columns follow the screen conditions', () {
    test('everything on', () {
      final ids = columnIds(specFor(sample));
      expect(ids, [
        'no',
        'name',
        'qty',
        'unit',
        'opening',
        'closing',
        'change',
        'sell',
        'sellTotal',
        'cost',
        'costTotal',
        'profitUnit',
        'profit',
        'margin',
        'discount',
        'expiry',
        'department',
        'qtyType',
        'managed',
        'created',
        'createdTime',
        'category',
      ]);
    });

    test('cost columns only with cost access', () {
      final ids = columnIds(specFor(sample, canSeeCost: false));
      for (final id in ['cost', 'costTotal', 'profitUnit', 'profit', 'margin']) {
        expect(ids, isNot(contains(id)), reason: id);
      }
      expect(ids, contains('sellTotal'));
    });

    test('department column only when departments are on', () {
      expect(
        columnIds(specFor(sample, departmentsEnabled: false)),
        isNot(contains('department')),
      );
    });

    test('opening/closing/change only when history is tracked', () {
      final ids = columnIds(specFor(sample, historyTracked: false));
      for (final id in ['opening', 'closing', 'change']) {
        expect(ids, isNot(contains(id)), reason: id);
      }
    });

    test('Quantity Type, Is-Managed and Created Time are Excel-only', () {
      final t = tableOf(specFor(sample));
      final excelOnly = [
        for (final c in t.columns)
          if (!c.inPdf) c.id,
      ];
      expect(excelOnly, ['qtyType', 'managed', 'createdTime']);
    });

    test('without quantity access quantities are masked, with no number', () {
      final spec = specFor(
        sample,
        canSeeQuantity: false,
        movements: {'coke': const ItemStockMovement(opening: 10, closing: 12)},
      );
      expect(cell(spec, 'Coke', 'qty'), '****');
      expect(raw(spec, 'Coke', 'qty'), isNull);
      expect(cell(spec, 'Coke', 'opening'), '****');
      expect(raw(spec, 'Coke', 'opening'), isNull);
    });
  });

  group('cells', () {
    test('quantity with unit; un-managed shows a dash', () {
      final spec = specFor(sample);
      expect(cell(spec, 'Coke', 'qty'), '12 Bottles');
      expect(raw(spec, 'Coke', 'qty'), 12);
      expect(cell(spec, 'Service Charge', 'qty'), '—');
    });

    test('2D sheet items show their size', () {
      final spec = specFor(sample);
      expect(cell(spec, 'Roofing Sheet', 'qty'), '3 Sheets (4 x 2)');
      expect(raw(spec, 'Roofing Sheet', 'qty'), 3);

      final withUnit = itemRow(
        id: 'g',
        name: 'Glass',
        qty: 2,
        unit: 'Sheets',
        twoD: true,
        width: 30,
        height: 40,
        dimensionUnit: 'Centimeter',
      );
      expect(cell(specFor([withUnit]), 'Glass', 'qty'), '2 Sheets (30cm x 40cm)');

      final area = itemRow(
        id: 'a',
        name: 'Tiles',
        qty: 24,
        unit: 'Square Meter',
        twoD: true,
        dimensionType: ProductUnitsClass.areaUnit,
        width: 4,
        height: 2,
      );
      expect(cell(specFor([area]), 'Tiles', 'qty'), '24 Square Meter');
    });

    test('stock movement: opening, closing and a signed change', () {
      final spec = specFor(
        sample,
        movements: {
          'coke': const ItemStockMovement(opening: 10, closing: 12),
          'pie': const ItemStockMovement(opening: 8, closing: 5),
        },
      );
      expect(cell(spec, 'Coke', 'opening'), '10');
      expect(cell(spec, 'Coke', 'closing'), '12');
      expect(cell(spec, 'Coke', 'change'), '+2');
      expect(cell(spec, 'Meat Pie', 'change'), '-3');
      expect(cell(spec, 'Roofing Sheet', 'opening'), '—');
      expect(cell(spec, 'Service Charge', 'closing'), '—');
    });

    test('money, margin, discount, expiry and dates as on screen', () {
      final spec = specFor(sample);
      expect(cell(spec, 'Coke', 'sellTotal'), '₦1,500.00');
      expect(cell(spec, 'Service Charge', 'sellTotal'), '—');
      expect(cell(spec, 'Coke', 'margin'), '20%');
      expect(cell(spec, 'Coke', 'discount'), '—');
      expect(cell(spec, 'Meat Pie', 'discount'), '10%');
      expect(cell(spec, 'Coke', 'expiry'), 'Jan 31, 2027');
      expect(cell(spec, 'Meat Pie', 'expiry'), 'Expired');
      expect(raw(spec, 'Meat Pie', 'expiry'), DateTime(2026, 10, 1));
      expect(cell(spec, 'Roofing Sheet', 'expiry'), 'Not Set');
      expect(cell(spec, 'Coke', 'created'), 'Oct 1, 2026');
      expect(cell(spec, 'Coke', 'createdTime'), '09:30 AM');
      expect(cell(spec, 'Meat Pie', 'category'), 'Bakery, Drinks');
      expect(cell(spec, 'Service Charge', 'category'), 'No Category');
      expect(cell(spec, 'Service Charge', 'department'), 'No Department');
      expect(cell(spec, 'Service Charge', 'managed'), 'Un-Managed');
      expect(cell(spec, 'Roofing Sheet', 'qtyType'), '2-Dimensional');
    });
  });

  group('rows', () {
    test('every filtered, sorted row, not just the page', () {
      final rows = [
        for (var i = 0; i < 150; i++)
          itemRow(
            id: 'i$i',
            name: 'Item $i',
            qty: (i % 10).toDouble(),
            selling: 10.0 + i,
            categories: i.isEven ? const ['c-drinks'] : const [],
          ),
      ];
      final filters = ItemsReportFilters()..categoryKey = 'c-drinks';
      final sorted = ItemsReportQuery.filterAndSort(
        rows: rows,
        filters: filters,
        sortField: ItemsSortField.sellingPrice,
        ascending: false,
        departmentsEnabled: true,
        costFilterAllowed: true,
      );
      final page = ItemsReportQuery.paginate(sorted, 1);
      expect(sorted.length, 75);

      final spec = specFor(
        sorted,
        filters: filters,
        sortField: ItemsSortField.sellingPrice,
        ascending: false,
      );
      final section = spec.tables.single;
      expect(section.erasedRows, sorted);
      expect(spec.recordCount, 75);

      final t = tableOf(spec);
      expect(t.rows.length, 75);
      expect(t.rows.first[t.indexOf('name')].text, sorted.first.name);
      expect(t.rows.last[t.indexOf('name')].text, sorted.last.name);
      expect(
        [for (final r in t.rows) r[t.indexOf('no')].text].take(3),
        ['1', '2', '3'],
      );
      expect(t.rows.last[t.indexOf('no')].text, '75');

      // A page holds at most 100 rows; with 150 unfiltered rows the
      // export still has them all.
      final all = ItemsReportQuery.filterAndSort(
        rows: rows,
        filters: ItemsReportFilters(),
        sortField: ItemsSortField.name,
        ascending: true,
        departmentsEnabled: true,
        costFilterAllowed: true,
      );
      expect(ItemsReportQuery.paginate(all, 1).rows.length, itemsReportPageSize);
      expect(tableOf(specFor(all)).rows.length, 150);
      expect(page.rows.length, lessThanOrEqualTo(itemsReportPageSize));
    });
  });

  group('totals (export-only)', () {
    test('with cost access: count, selling, cost and profit', () {
      final t = tableOf(specFor(sample));
      final totals = t.totals!;
      expect(totals[t.indexOf('name')].text, '4 items');
      // 12*125 + 5*1000 + 3*800
      expect(totals[t.indexOf('sellTotal')].raw, 8900);
      // 12*100 + 5*700 + 3*600
      expect(totals[t.indexOf('costTotal')].raw, 6500);
      expect(totals[t.indexOf('profit')].raw, 2400);
      expect(totals[t.indexOf('profit')].text, '₦2,400.00');
      expect(totals[t.indexOf('sell')].text, '');
    });

    test('without cost access: count and selling only', () {
      final t = tableOf(specFor(sample, canSeeCost: false));
      final totals = t.totals!;
      expect(totals[t.indexOf('name')].text, '4 items');
      expect(totals[t.indexOf('sellTotal')].raw, 8900);
      expect(t.indexOf('costTotal'), -1);
      expect(t.indexOf('profit'), -1);
    });

    test('one item reads "1 item"', () {
      final t = tableOf(specFor([coke]));
      expect(t.totals![t.indexOf('name')].text, '1 item');
    });
  });

  group('splits', () {
    final f = ExportFormatter(currency: '₦');

    test('categories: two-category items on both, "No Category" last', () {
      final section = specFor(sample).tables.single;
      final groups = resolveGroups(section, 'category', f);
      expect(groups.map((g) => g.name), ['Bakery', 'Drinks', 'No Category']);
      List<String> names(ResolvedGroup g) => [
        for (final r in g.table.rows) r[g.table.indexOf('name')].text,
      ];
      expect(names(groups[0]), ['Meat Pie']);
      expect(names(groups[1]), ['Coke', 'Meat Pie']);
      expect(names(groups[2]), ['Roofing Sheet', 'Service Charge']);
      // Per-group totals.
      final drinks = groups[1].table;
      expect(drinks.totals![drinks.indexOf('sellTotal')].raw, 6500);
    });

    test('departments with "No Department"', () {
      final section = specFor(sample).tables.single;
      final groups = resolveGroups(section, 'department', f);
      expect(groups.map((g) => g.name), [
        'Back Store',
        'Front Shop',
        'No Department',
      ]);
    });

    test('no department split when departments are off', () {
      final options = specFor(sample, departmentsEnabled: false).splitOptions;
      expect(options.map((s) => s.id), ['category']);
    });

    test('the workbook splits into All + one sheet per category', () {
      final wb = resolveWorkbook(specFor(sample), ctx, splitId: 'category');
      expect(wb.sheets.map((s) => s.name), [
        'All',
        'Bakery',
        'Drinks',
        'No Category',
      ]);
    });
  });

  group('info box: period, filters with values, sort', () {
    test('filters and sort as the screen shows them', () {
      final filters = ItemsReportFilters()
        ..search = '  co '
        ..categoryKey = 'c-drinks'
        ..departmentKey = itemsReportNoneKey
        ..stockLevel = StockLevelFilter.inStock
        ..managed = false
        ..sellingMin = 100
        ..costMax = 5000
        ..quantityMin = 2
        ..quantityMax = 10.5
        ..expiryStart = DateTime(2026, 11, 1)
        ..expiryEnd = DateTime(2026, 11, 30);
      final spec = specFor(
        sample,
        filters: filters,
        sortField: ItemsSortField.totalSellingValue,
        ascending: false,
      );
      final map = {for (final x in spec.filters) x.label: x.value};
      expect(map, {
        'Search': '"co"',
        'Category': 'Drinks',
        'Department': 'No Department',
        'Quantity': 'In Stock',
        'Is-Managed': 'Un-Managed',
        'Selling': '₦100.00 - Any',
        'Cost': 'Any - ₦5,000.00',
        'Qty': '2 - 10.5',
        'Expiry': 'Nov 1, 2026 - Nov 30, 2026',
      });
      expect(spec.sortedBy, 'Total Selling Value (descending)');
      expect(spec.period!.label, 'Oct 1, 2026 - Oct 31, 2026');

      final info = {
        for (final e in reportPdfInfoEntries(resolveExport(spec, ctx)))
          e.$1: e.$2,
      };
      expect(info['Period'], 'Oct 1, 2026 - Oct 31, 2026');
      expect(info['Filters Applied'], contains('Category: Drinks'));
      expect(info['Filters Applied'], contains('Selling: ₦100.00 - Any'));
      expect(info['Sorted By'], 'Total Selling Value (descending)');
    });

    test('cost filter hidden without cost access; departments when off', () {
      final filters = ItemsReportFilters()
        ..costMin = 10
        ..departmentKey = 'd-front';
      final spec = specFor(
        sample,
        filters: filters,
        canSeeCost: false,
        departmentsEnabled: false,
      );
      final labels = spec.filters.map((x) => x.label);
      expect(labels, isNot(contains('Cost')));
      expect(labels, isNot(contains('Department')));
    });

    test('single-day and open-ended expiry filters', () {
      ExportFilter expiry(DateTime? s, DateTime? e) => specFor(
        sample,
        filters: ItemsReportFilters()
          ..expiryStart = s
          ..expiryEnd = e,
      ).filters.single;
      expect(expiry(DateTime(2026, 11, 1), DateTime(2026, 11, 1)).value, 'Nov 1, 2026');
      expect(expiry(DateTime(2026, 11, 1), null).value, 'From Nov 1, 2026');
      expect(expiry(null, DateTime(2026, 11, 30)).value, 'Up to Nov 30, 2026');
    });

    test('ascending sort label and no filters', () {
      final spec = specFor(sample);
      expect(spec.filters, isEmpty);
      expect(spec.sortedBy, 'Item Name (ascending)');
      expect(itemsSortLabels.length, ItemsSortField.values.length);
    });
  });

  group('roll', () {
    String preview(RollPaper paper) => renderRollEscPos(
      buildRollLines(specFor(sample), ctx, paper: paper),
      paper,
    ).preview;

    test('58mm: name and quantity with unit, no money', () {
      final text = preview(RollPaper.mm58);
      final coke = text.split('\n').firstWhere((l) => l.startsWith('Coke'));
      expect(coke, contains('12 Bottles'));
      expect(coke, isNot(contains('N1,500.00')));
      final joined = text.split('\n').map((l) => l.trim()).join(' ');
      expect(joined, contains('3 Sheets'));
      expect(joined, contains('(4 x 2)'));
    });

    test('80mm adds the selling value', () {
      final text = preview(RollPaper.mm80);
      final coke = text.split('\n').firstWhere((l) => l.startsWith('Coke'));
      expect(coke, contains('12 Bottles'));
      expect(coke, endsWith('N1,500.00'));
      expect(text, contains('Total Selling Value'));
    });
  });

  group('Items screen', () {
    setUpAll(setUpScreenEnvironment);
    tearDownAll(() async => Hive.close());

    for (final desktop in [true, false]) {
      testWidgets(
        'shows Export and Printer Settings (${desktop ? 'desktop' : 'mobile'})',
        (tester) async {
          await pumpItemsScreen(tester, desktop: desktop);
          if (!desktop) {
            // The toolbar pills sit behind "View" on narrow screens.
            expect(find.text('Export'), findsNothing);
            await tester.tap(find.text('View'));
            await tester.pumpAndSettle();
          }
          expect(find.text('Export'), findsOneWidget);
          // Not on web (kIsWeb is false in tests).
          expect(find.text('Printer Settings'), findsOneWidget);
          expect(find.text('Print Records'), findsNothing);
        },
      );
    }
  });
}
