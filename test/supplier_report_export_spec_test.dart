import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/pages/report/components/export/report_export_format.dart';
import 'package:stockall/pages/report/components/export/report_export_resolve.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/export/report_pdf_builder.dart';
import 'package:stockall/pages/report/components/export/report_roll_builder.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/supplier_report/supplier_report_table/class/supplier_report_export_spec.dart';
import 'package:stockall/pages/report/supplier_report/supplier_report_table/class/supplier_report_table_logic.dart';
import 'package:stockall/services/printing/escpos_builder.dart' show fontBDots;

import 'item_history_export_fixtures.dart' show testCtx;
import 'supplier_report_fixtures.dart';
import 'supplier_report_table_test.dart' show pumpTable;

// Acme (Lagos, Nigeria) owed ₦250,000 on a ₦1,250,000 purchase; Bolt
// (Ghana) paid in full; Cora with no contact and no purchases; Delta
// deleted, only its purchase remains.
final suppliers = [
  supplier(
    'sup-a',
    name: 'Acme',
    phone: '08010000000',
    email: 'acme@example.com',
    address: '1 Market Road',
    city: 'Lagos',
    state: 'Lagos',
    country: 'Nigeria',
  ),
  supplier('sup-b', name: 'Bolt', country: 'Ghana'),
  supplier('sup-c', name: 'Cora'),
];

final purchases = [
  bought(1, supplierId: 'sup-a', total: 1250000, paid: 1000000, day: 16),
  bought(2, supplierId: 'sup-b', total: 300, paid: 300),
  bought(3, supplierId: 'sup-d', supplierName: 'Delta', total: 50),
];

final allRows = supplierRows(suppliers: suppliers, purchases: purchases);

List<SupplierReportRow> query({
  SupplierReportFilters? filters,
  SupplierSortField sortField = SupplierSortField.name,
  bool ascending = true,
  List<SupplierReportRow>? rows,
}) => SupplierReportQuery.filterAndSort(
  rows: rows ?? allRows,
  filters: filters ?? SupplierReportFilters(),
  sortField: sortField,
  ascending: ascending,
);

ReportExportSpec specFor(
  List<SupplierReportRow> rows, {
  SupplierReportFilters? filters,
  ReceiptsReportPeriod period = const ReceiptsReportPeriod.allTime(),
}) => supplierReportExportSpec(
  rows: rows,
  allRows: allRows,
  state: SupplierReportTableState(filters: filters),
  period: period,
  currency: '₦',
);

ResolvedTable tableOf(ReportExportSpec spec) =>
    resolveExport(spec, testCtx).tables.single;

List<String> col(ResolvedTable t, String id) => [
  for (final r in t.rows) r[t.indexOf(id)].text,
];

void main() {
  group('rows are the screen query, every page', () {
    test('150 suppliers: every row, in the screen order', () {
      final many = [for (var i = 0; i < 150; i++) supplier('s-$i', name: 'Supplier $i')];
      final rows = query(
        rows: supplierRows(suppliers: many, purchases: const []),
        sortField: SupplierSortField.name,
      );
      final t = tableOf(specFor(rows));
      expect(t.rows, hasLength(150));
      expect(col(t, 'name'), [for (final r in rows) r.label]);
      expect(SupplierReportQuery.paginate(rows, 1).rows, hasLength(100));
    });
  });

  group('cells', () {
    final t = tableOf(specFor(query()));
    test('columns as on screen; address in one column; blanks "—"', () {
      expect([for (final c in t.columns) c.label], [
        'Name',
        'Phone',
        'Email',
        'Address',
        'Purchases',
        'Spend',
        'Paid',
        'Balance owed',
        'Last purchase',
      ]);
      expect(col(t, 'address').first, '1 Market Road, Lagos, Lagos, Nigeria');
      final cora = t.rows.firstWhere((r) => r[0].text == 'Cora');
      for (final id in ['phone', 'email', 'address', 'lastPurchase']) {
        expect(cora[t.indexOf(id)].text, '—', reason: id);
      }
    });

    test('the deleted-supplier marker as cell text', () {
      expect(col(t, 'name'), contains('Delta (Deleted supplier)'));
      expect(col(t, 'name'), containsAll(['Acme', 'Bolt', 'Cora']));
    });
  });

  group('totals', () {
    test('equal the SupplierReportPage totals the screen shows', () {
      final rows = query();
      final page = SupplierReportQuery.paginate(rows, 1);
      final t = tableOf(specFor(rows));
      Object? total(String id) => t.totals![t.indexOf(id)].raw;
      expect(t.totals![0].text, '4 suppliers');
      expect(total('purchases'), page.totalPurchases);
      expect(total('spend'), page.totalSpend);
      expect(total('paid'), page.totalPaid);
      expect(total('balance'), page.totalBalance);
      expect(page.totalBalance, 250050);
    });
  });

  group('splits', () {
    test('Country only, "No Country" last', () {
      final spec = specFor(query());
      expect(spec.splitOptions.map((s) => s.id), ['country']);
      final names = [
        for (final g in resolveGroups(
          spec.tables.single,
          'country',
          ExportFormatter(currency: '₦'),
        ))
          g.name,
      ];
      expect(names, ['Ghana', 'Nigeria', 'No Country']);
    });
  });

  group('info box and notes', () {
    test('period, filters with their values and sort', () {
      final filters = SupplierReportFilters(
        search: 'ac',
        countryKey: 'nigeria',
        stateKey: 'lagos',
        hasBalance: true,
      );
      final spec = specFor(query(filters: filters), filters: filters);
      expect([for (final x in spec.filters) '${x.label}: ${x.value}'], [
        'Search: ac',
        'Country: Nigeria',
        'State: Lagos',
        'Balance: Has balance owed',
      ]);
      expect(spec.sortedBy, 'Name (ascending)');
      expect(supplierSortLabel(SupplierSortField.balance, false), 'Balance owed (descending)');
      expect(spec.period!.label, 'All time');
    });

    test('the All time note exactly when the screen shows it', () {
      final all = specFor(query());
      expect(all.notes, ['All time covers the purchases loaded on this device.']);
      final info = {
        for (final e in reportPdfInfoEntries(resolveExport(all, testCtx))) e.$1: e.$2,
      };
      expect(info['Notes'], all.notes.single);
      final day = specFor(query(), period: ReceiptsReportPeriod.day(DateTime(2026, 10, 17)));
      expect(day.notes, isEmpty);
    });
  });

  group('roll', () {
    String preview(RollPaper paper) => renderRollEscPos(
      buildRollLines(specFor(query()), testCtx, paper: paper),
      paper,
    ).preview;

    test('58mm: Name · Spend', () {
      final out = preview(RollPaper.mm58).split('\n');
      expect(out.firstWhere((l) => l.startsWith('Acme')), endsWith('N1,250,000.00'));
      expect(out.every((l) => l.length <= RollPaper.mm58.dots ~/ fontBDots), isTrue);
      expect(out.where((l) => l.contains('.00')).every((l) => l.length <= 32), isTrue);
    });

    test('80mm: Name · Purchases · Balance owed', () {
      final out = preview(RollPaper.mm80).split('\n');
      final acme = out.firstWhere((l) => l.startsWith('Acme'));
      expect(acme, endsWith('N250,000.00'));
      expect(acme, contains(' 1 '));
      expect(out.where((l) => l.contains('.00')).every((l) => l.length <= 48), isTrue);
    });
  });

  group('Supplier table screen', () {
    for (final desktop in [true, false]) {
      testWidgets('shows the Export pill (${desktop ? 'desktop' : 'mobile'})', (
        tester,
      ) async {
        // pumpTable opens "View" on mobile, where the toolbar sits.
        await pumpTable(
          tester,
          isDesktop: desktop,
          env: fakeSupplierEnv(purchases: purchases, suppliers: suppliers),
          period: const ReceiptsReportPeriod.allTime(),
        );
        expect(find.text('Export'), findsOneWidget);
      });
    }
  });
}
