import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/temp_purchase/temp_purchase.dart';
import 'package:stockall/pages/report/components/export/report_export_format.dart';
import 'package:stockall/pages/report/components/export/report_export_resolve.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/export/report_pdf_builder.dart';
import 'package:stockall/pages/report/components/export/report_roll_builder.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/class/purchase_report_export_spec.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/class/purchase_report_table_logic.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/components/purchase_report_filter_widgets.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/services/printing/escpos_builder.dart' show fontBDots;

import 'item_history_export_fixtures.dart' show testCtx;
import 'purchase_report_fixtures.dart';
import 'purchase_report_table_logic_test.dart' show query;
import 'purchase_report_table_test.dart' show pumpTable;

// Acme paid in full by Ada; Bolt part paid by bank (Ben), with a custom
// total above its lines; Acme overpaid on a ₦1,250,000 purchase; one
// with no supplier, no staff and no line data, unpaid.
List<TempPurchase> samplePurchases() => [
  purchase(
    uuid: uuidN(1),
    total: 100,
    payments: [payment(100)],
    createdAt: DateTime(2026, 10, 17, 9),
  ),
  purchase(
    uuid: uuidN(2),
    supplierId: 'sup-b',
    supplierName: 'Bolt',
    staffId: 'staff-b',
    staffName: 'Ben',
    total: 300,
    isCustomPriceSet: true,
    items: [line(total: 250, purchaseId: uuidN(2))],
    payments: [payment(50, method: 'Bank')],
    createdAt: DateTime(2026, 10, 17, 10),
  ),
  purchase(
    uuid: uuidN(3),
    total: 1250000,
    payments: [payment(1250020)],
    createdAt: DateTime(2026, 10, 17, 11),
  ),
  purchase(
    uuid: uuidN(4),
    supplierId: null,
    supplierName: null,
    staffId: null,
    staffName: null,
    total: 50,
    noItems: true,
    createdAt: DateTime(2026, 10, 17, 12),
  ),
];

final sample = query(rows(samplePurchases()));

ReportExportSpec specFor(
  List<PurchaseReportRow> rs, {
  PurchaseGroupBy groupBy = PurchaseGroupBy.off,
  PurchaseReportFilters? filters,
  ReceiptsReportPeriod period = const ReceiptsReportPeriod.allTime(),
  bool departmentsEnabled = false,
}) {
  final state = PurchaseReportTableState(filters: filters, groupBy: groupBy);
  final groups = PurchaseGrouping.sort(
    PurchaseGrouping.build(rs, groupBy),
    field: state.groupSortField,
    ascending: state.groupAscending,
  );
  return purchaseReportExportSpec(
    rows: rs,
    groups: groups,
    state: state,
    choices: PurchaseFilterChoices.fromRows(rs),
    period: period,
    currency: '₦',
    departmentsEnabled: departmentsEnabled,
  );
}

ResolvedTable tableOf(ReportExportSpec spec) =>
    resolveExport(spec, testCtx).tables.single;

ResolvedCell cellOf(ReportExportSpec spec, int n, String columnId) {
  final t = tableOf(spec);
  final id = PurchaseReportRowBuilder.displayId(purchase(uuid: uuidN(n)));
  final r = t.rows.firstWhere((r) => r[t.indexOf('id')].text == id);
  return r[t.indexOf(columnId)];
}

void main() {
  group('rows are the screen query, every page', () {
    test('150 purchases: every row, in the screen order', () {
      final sorted = query(
        rows([
          for (var i = 1; i <= 150; i++)
            purchase(
              uuid: uuidN(i),
              total: 100.0 + i,
              createdAt: DateTime(2026, 10, 1).add(Duration(hours: i)),
            ),
        ]),
        sortField: PurchasesSortField.total,
      );
      final t = tableOf(specFor(sorted));
      expect(t.rows, hasLength(150));
      expect([for (final r in t.rows) r[t.indexOf('id')].text], [
        for (final r in sorted) r.displayId,
      ]);
    });
  });

  group('columns follow the screen', () {
    test('every column, Line Total in Excel only, Department when enabled', () {
      final t = tableOf(specFor(sample));
      expect([for (final c in t.columns) c.label], [
        'ID',
        'Supplier',
        'Staff',
        'Date',
        'Time',
        'Status',
        'Channel',
        'Lines',
        'Items',
        'Total',
        'Paid',
        'Balance',
        'Notes',
        'Line Total',
      ]);
      expect([for (final c in t.columns) if (!c.inPdf) c.id], ['lineTotal']);
      expect(tableOf(specFor(sample, departmentsEnabled: true)).indexOf('department'), 5);
    });
  });

  group('cells', () {
    final spec = specFor(sample);
    test('the clamped balance and the overpaid note', () {
      expect(cellOf(spec, 3, 'status').text, 'Paid');
      expect(cellOf(spec, 3, 'balance').raw, 0);
      expect(cellOf(spec, 3, 'notes').text, 'Overpaid by ₦20.00');
      expect(cellOf(spec, 3, 'total').text, '₦1,250,000.00');
    });

    test('the custom-total indicator', () {
      expect(cellOf(spec, 2, 'notes').text, 'Custom total (lines ₦250.00, +₦50.00)');
      expect(cellOf(spec, 2, 'lineTotal').raw, 250);
      expect(cellOf(spec, 2, 'status').text, 'Partly Paid');
      expect(cellOf(spec, 2, 'channel').text, 'Bank');
    });

    test('no line data, no supplier, unpaid', () {
      expect(cellOf(spec, 4, 'lines').text, '—');
      expect(cellOf(spec, 4, 'items').text, '—');
      expect(cellOf(spec, 4, 'supplier').text, 'No supplier');
      expect(cellOf(spec, 4, 'channel').text, 'Unpaid');
      expect(cellOf(spec, 4, 'notes').text, '—');
      expect(cellOf(spec, 1, 'notes').text, '—');
    });
  });

  group('totals', () {
    test('equal the PurchaseReportPage totals the screen shows', () {
      final page = PurchaseReportQuery.paginate(sample, 1);
      final t = tableOf(specFor(sample));
      Object? total(String id) => t.totals![t.indexOf(id)].raw;
      expect(t.totals![t.indexOf('id')].text, '4 purchases');
      expect(total('items'), page.totalItems);
      expect(total('total'), page.total);
      expect(total('paid'), page.totalPaid);
      expect(total('balance'), page.totalBalance);
      expect(total('lineTotal'), page.totalLineTotal);
    });
  });

  group('grouped', () {
    test('by Supplier: the group table, its totals, "Grouped by: Supplier"', () {
      final spec = specFor(sample, groupBy: PurchaseGroupBy.supplier);
      final groups = PurchaseGrouping.sort(
        PurchaseGrouping.build(sample, PurchaseGroupBy.supplier),
        field: PurchaseGroupSortField.total,
        ascending: false,
      );
      final page = PurchaseGrouping.paginate(groups, 1);
      final t = tableOf(spec);
      expect([for (final c in t.columns) c.label], [
        'Supplier',
        'Purchases',
        'Items',
        'Total',
        'Paid',
        'Balance',
      ]);
      expect([for (final r in t.rows) r[0].text], [for (final g in groups) g.label]);
      expect(t.rows.last[0].text, 'No supplier');
      expect(t.totals![t.indexOf('purchases')].raw, page.totalPurchases);
      expect(t.totals![t.indexOf('total')].raw, page.total);
      expect(t.totals![t.indexOf('balance')].raw, page.totalBalance);
      expect(spec.groupedBy, 'Supplier');
      expect(spec.sortedBy, 'Total (descending)');
      expect(spec.splitOptions, isEmpty);
    });
  });

  group('splits', () {
    final f = ExportFormatter(currency: '₦');
    List<String> names(String id) => [
      for (final g in resolveGroups(specFor(sample).tables.single, id, f)) g.name,
    ];

    test('Supplier, Staff, Status; "No …" last', () {
      expect(specFor(sample).splitOptions.map((s) => s.id), ['supplier', 'staff', 'status']);
      expect(names('supplier'), ['Acme', 'Bolt', 'No Supplier']);
      expect(names('staff'), ['Ada', 'Ben', 'No Staff']);
      expect(names('status'), containsAll(['Paid', 'Partly Paid', 'Unpaid']));
    });
  });

  group('info box and notes', () {
    test('filters worded like the chips', () {
      final filters = PurchaseReportFilters(
        search: 'acme',
        supplierKey: 'sup-a',
        staffKey: purchaseReportNoneKey,
        channelKey: purchaseReportNoneKey,
        status: PurchaseStatus.unpaid,
        totalMin: 10,
        balanceMax: 500,
      );
      final spec = specFor(sample, filters: filters);
      expect([for (final x in spec.filters) '${x.label}: ${x.value}'], [
        'Search: acme',
        'Supplier: Acme',
        'Staff: No staff',
        'Channel: Unpaid',
        'Status: Unpaid',
        'Total: ₦10.00 - Any',
        'Balance: Any - ₦500.00',
      ]);
      expect(specFor(sample).sortedBy, 'Date (descending)');
    });

    test('the All time note exactly when the screen shows it', () {
      final all = specFor(sample);
      expect(all.notes, ['All time covers the purchases loaded on this device.']);
      final day = specFor(sample, period: ReceiptsReportPeriod.day(DateTime(2026, 10, 17)));
      expect(day.notes, isEmpty);
      expect(day.period!.label, 'Oct 17, 2026');
      final info = {
        for (final e in reportPdfInfoEntries(resolveExport(all, testCtx))) e.$1: e.$2,
      };
      expect(info['Notes'], all.notes.single);
    });
  });

  group('roll', () {
    String preview(ReportExportSpec spec, RollPaper paper) => renderRollEscPos(
      buildRollLines(spec, testCtx, paper: paper),
      paper,
    ).preview;

    test('58mm: Supplier · Total, ID | date underneath', () {
      final out = preview(specFor(sample), RollPaper.mm58).split('\n');
      final i = out.indexWhere((l) => l.endsWith('N1,250,000.00') && l.startsWith('Acme'));
      expect(i, greaterThan(0));
      expect(out[i + 1].trim(), '${sample.firstWhere((r) => r.total == 1250000).displayId} | Oct 17, 2026');
      expect(out.every((l) => l.length <= 32 || l.startsWith('* ')), isTrue);
      expect(out.every((l) => l.length <= RollPaper.mm58.dots ~/ fontBDots), isTrue);
    });

    test('80mm: Supplier · Paid · Total, money on one line', () {
      final out = preview(specFor(sample), RollPaper.mm80).split('\n');
      final i = out.indexWhere((l) => l.startsWith('Acme') && l.endsWith('N1,250,000.00'));
      expect(out[i], contains('N1,250,020.00'));
      expect(out[i + 1].trim(), '${sample.firstWhere((r) => r.total == 1250000).displayId} | Oct 17, 2026');
      expect(out.every((l) => l.length <= 48 || l.startsWith('* ')), isTrue);
    });
  });

  group('Purchase table screen', () {
    for (final desktop in [true, false]) {
      testWidgets('shows the Export pill (${desktop ? 'desktop' : 'mobile'})', (
        tester,
      ) async {
        // pumpTable opens "View" on mobile, where the toolbar sits.
        await pumpTable(
          tester,
          isDesktop: desktop,
          env: fakeEnv(purchases: samplePurchases()),
        );
        expect(find.text('Export'), findsOneWidget);
      });
    }
  });
}
