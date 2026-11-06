import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_storage_item_history/storage_item_history.dart';
import 'package:stockall/classes/temp_storage_item_history/storage_item_history_event_class.dart';
import 'package:stockall/pages/report/components/export/report_export_format.dart';
import 'package:stockall/pages/report/components/export/report_export_resolve.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/export/report_pdf_builder.dart';
import 'package:stockall/pages/report/components/export/report_roll_builder.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/storage_items_report_/storage_item_history_report/class/storage_item_history_export_spec.dart';
import 'package:stockall/pages/report/storage_items_report_/storage_item_history_report/class/storage_item_history_report_logic.dart';
import 'package:stockall/pages/report/storage_items_report_/storage_item_history_report/components/storage_item_history_report_view.dart';
import 'package:stockall/services/printing/escpos_builder.dart' show fontBDots;

import 'item_history_export_fixtures.dart' show testCtx;
import 'report_export_screen_harness.dart';
import 'storage_item_history_summary_test.dart' show oct, record;

// Flour transferred to the Bar's sales item by Ada; stocked in by Bola
// with no department; a renamed sheet item transferred to the Kitchen;
// a stock-in with no storekeeper at all.
final records = [
  record(
    uuid: 'h-1',
    storageItemUuid: 's-flour',
    storageItemName: 'Flour',
    event: StorageItemHistoryEventClass.transferedOut,
    createdAt: oct(17, 9),
    oldValue: '10',
    newValue: '7',
    quantityChange: 3,
    isIncreased: false,
    storageUnit: 'Bags',
    storagePrimaryUnit: 'Bags',
    salesItemUuid: 'p-1',
    salesItemName: 'Flour Sale',
    salesDepartmentUuid: 'd-bar',
    salesDepartmentName: 'Bar',
    salesStaffUuid: 'staff-c',
    salesStaffName: 'Chidi',
  ),
  record(
    uuid: 'h-2',
    storageItemUuid: 's-flour',
    storageItemName: 'Flour',
    event: StorageItemHistoryEventClass.stockIn,
    createdAt: oct(17, 10),
    oldValue: '7',
    newValue: '12',
    quantityChange: 5,
    isIncreased: true,
    storageUnit: 'Bags',
    storagePrimaryUnit: 'Bags',
    storageStaffId: 'keeper-2',
    storageStaffName: 'Bola',
  ),
  record(
    uuid: 'h-3',
    storageItemUuid: 's-sheet',
    storageItemName: 'Old Sheet',
    event: StorageItemHistoryEventClass.transferedOut,
    createdAt: oct(17, 11),
    oldValue: '5',
    newValue: '4',
    quantityChange: 1,
    isIncreased: false,
    storageUnit: 'Sheets',
    storagePrimaryUnit: 'Sheets',
    salesDepartmentUuid: 'd-kitchen',
    salesDepartmentName: 'Kitchen',
  ),
  record(
    uuid: 'h-4',
    storageItemUuid: 's-salt',
    storageItemName: 'Salt',
    event: StorageItemHistoryEventClass.stockIn,
    createdAt: oct(17, 12),
    oldValue: '0',
    newValue: '2',
    quantityChange: 2,
    isIncreased: true,
    storageUnit: 'Kg',
    storagePrimaryUnit: 'Kg',
    storageStaffId: null,
    storageStaffName: null,
  ),
];

const names = StorageHistoryExportNames(
  storageItems: {'s-flour': 'Flour', 's-sheet': 'Sheet', 's-salt': 'Salt'},
  salesItems: {'p-1': 'Flour Sale'},
  departments: {'d-bar': 'Bar', 'd-kitchen': 'Kitchen'},
  storekeepers: {'keeper-1': 'Ada Keeper', 'keeper-2': 'Bola'},
  otherStaff: {'staff-c': 'Chidi'},
  currentStorageNames: {'s-flour': 'Flour', 's-sheet': 'Sheet'},
);

List<StorageItemHistory> query({
  StorageItemHistoryReportFilters? filters,
  List<StorageItemHistory>? rows,
  bool departmentsEnabled = true,
}) => StorageItemHistoryReportQuery.filterAndSort(
  rows: rows ?? records,
  filters: filters ?? StorageItemHistoryReportFilters(),
  sortField: StorageItemHistorySortField.createdAt,
  ascending: false,
  departmentsEnabled: departmentsEnabled,
);

ReportExportSpec specFor({
  StorageItemHistoryReportFilters? filters,
  List<StorageItemHistory>? rows,
  bool departmentsEnabled = true,
  ReceiptsReportPeriod period = const ReceiptsReportPeriod.allTime(),
}) => storageHistoryExportSpec(
  rows: rows ?? query(filters: filters, departmentsEnabled: departmentsEnabled),
  filters: filters ?? StorageItemHistoryReportFilters(),
  names: names,
  sortField: StorageItemHistorySortField.createdAt,
  ascending: false,
  period: period,
  departmentsEnabled: departmentsEnabled,
  currency: '₦',
);

ResolvedTable tableOf(ReportExportSpec spec) =>
    resolveExport(spec, testCtx).tables.single;

List<String> col(ResolvedTable t, String id) => [
  for (final r in t.rows) r[t.indexOf(id)].text,
];

void main() {
  group('rows are the screen query, every page', () {
    test('150 records: every row, in the screen order', () {
      final many = [
        for (var i = 0; i < 150; i++)
          record(
            uuid: 'm-$i',
            storageItemUuid: 's-$i',
            storageItemName: 'Item $i',
            event: StorageItemHistoryEventClass.stockIn,
            createdAt: oct(1, 0).add(Duration(hours: i)),
            oldValue: '0',
            newValue: '1',
            quantityChange: 1,
            isIncreased: true,
            storageUnit: 'Pcs',
            storagePrimaryUnit: 'Pcs',
          ),
      ];
      final rows = query(rows: many);
      final t = tableOf(specFor(rows: rows));
      expect(t.rows, hasLength(150));
      expect(col(t, 'item'), [for (final r in rows) r.storageItemName]);
      expect(StorageItemHistoryReportQuery.paginate(rows, 1).rows, hasLength(100));
    });
  });

  group('columns and cells', () {
    test('Department only with departments on; Excel-only columns', () {
      final t = tableOf(specFor());
      expect(t.indexOf('department'), greaterThan(0));
      expect(
        [for (final c in t.columns) if (!c.inPdf) c.id],
        ['supplier', 'tracking', 'desc', 'unit', 'primaryUnit', 'salesOld', 'salesNew'],
      );
      expect(tableOf(specFor(departmentsEnabled: false)).indexOf('department'), -1);
    });

    test('names, events, quantities and values as on screen', () {
      final t = tableOf(specFor());
      final flour = t.rows.firstWhere((r) => r[t.indexOf('department')].text == 'Bar');
      expect(flour[t.indexOf('event')].text, 'Transferred Out');
      expect(flour[t.indexOf('qty')].text, storageHistoryQuantityText(records.first));
      expect(flour[t.indexOf('storageOld')].text, '10 Bags');
      expect(flour[t.indexOf('department')].text, 'Bar');
      expect(flour[t.indexOf('otherStaff')].text, 'Chidi');
      expect(col(t, 'item'), contains('Old Sheet (now: Sheet)'));
      expect(col(t, 'salesItem'), contains('—'));
    });
  });

  group('totals and splits', () {
    test('export-only total: the record count', () {
      final t = tableOf(specFor());
      expect(t.totals![t.indexOf('item')].text, '4 records');
    });

    final f = ExportFormatter(currency: '₦');
    List<String> names(String id) => [
      for (final g in resolveGroups(specFor().tables.single, id, f)) g.name,
    ];

    test('Department (the filter\'s key) and Staff, "No …" last', () {
      expect(specFor().splitOptions.map((s) => s.id), ['department', 'staff']);
      expect(names('department'), ['Bar', 'Kitchen', 'No Department']);
      expect(names('staff'), ['Ada Keeper', 'Bola', 'No Staff']);
      expect(specFor(departmentsEnabled: false).splitOptions.map((s) => s.id), ['staff']);
    });
  });

  group('info box and notes', () {
    test('filters worded like the chips', () {
      final filters = StorageItemHistoryReportFilters()
        ..search = 'fl'
        ..storageItemUuid = 's-flour'
        ..departmentUuid = storageItemHistoryReportNoneKey
        ..storekeeperKey = 'keeper-2'
        ..event = StorageItemHistoryEventClass.stockIn;
      final spec = specFor(filters: filters);
      expect([for (final x in spec.filters) '${x.label}: ${x.value}'], [
        'Search: fl',
        'Storage Item: Flour',
        'Department: No Department',
        'Storekeeper: Bola',
        'Event: Stock In',
      ]);
      expect(spec.sortedBy, 'Created Date (descending)');
    });

    test('the All time note exactly when the screen shows it', () {
      final all = specFor();
      expect(all.notes, ['All time covers the storage history loaded on this device.']);
      final info = {
        for (final e in reportPdfInfoEntries(resolveExport(all, testCtx))) e.$1: e.$2,
      };
      expect(info['Notes'], all.notes.single);
      final day = specFor(period: ReceiptsReportPeriod.day(DateTime(2026, 10, 17)));
      expect(day.notes, isEmpty);
    });
  });

  group('roll', () {
    for (final paper in RollPaper.values) {
      test('${paper.name}: item and quantity change on one line', () {
        final out = renderRollEscPos(
          buildRollLines(specFor(), testCtx, paper: paper),
          paper,
        ).preview.split('\n');
        final qty = storageHistoryQuantityText(records.first);
        final line = out.firstWhere((l) => l.contains(qty));
        expect(line, endsWith(qty));
        expect(out.every((l) => l.length <= paper.dots ~/ fontBDots), isTrue);
      });
    }
  });

  group('Storage history screen', () {
    setUpAll(setUpScreenEnvironment);
    tearDownAll(() async => Hive.close());

    for (final desktop in [true, false]) {
      testWidgets('shows the Export pill (${desktop ? 'desktop' : 'mobile'})', (
        tester,
      ) async {
        await pumpReportScreen(
          tester,
          StorageItemHistoryReportView(isDesktop: desktop),
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
