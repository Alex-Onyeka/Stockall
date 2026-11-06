import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:stockall/pages/report/components/export/report_export_format.dart';
import 'package:stockall/pages/report/components/export/report_export_resolve.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/export/report_pdf_builder.dart';
import 'package:stockall/pages/report/components/export/report_roll_builder.dart';
import 'package:stockall/pages/report/components/report_group_by.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_export_spec.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/components/receipts_report_filter_widgets.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/components/receipts_report_main_view.dart';

import 'item_history_export_fixtures.dart' show testCtx;
import 'receipts_report_main_logic_test.dart' show line, receipt, row, run;
import 'report_export_screen_harness.dart';

// Ada sells for cash (with item data, a 10% discount, Front Shop);
// Bola takes a bank payment without item data; an invoice payment has
// no staff; Ada's split payment goes to Dayo.
final sale = row(receipt(
  uuid: 'r-1',
  barcode: '1000000000001',
  createdAt: DateTime(2026, 10, 17, 9),
  cash: 1000,
  customerUuid: 'c-chidi',
  customerName: 'Chidi',
  departmentUuid: 'd-front',
  departmentName: 'Front Shop',
  generalDiscount: 10,
  comment: 'Paid at the counter',
  items: [line(quantity: 2, revenue: 1000, costPrice: 300)],
));
final bankSale = row(receipt(
  uuid: 'r-2',
  barcode: '1000000000002',
  createdAt: DateTime(2026, 10, 17, 10),
  paymentMethod: 'Bank',
  bank: 2500,
  staffId: 'staff-b',
  staffName: 'Bola',
));
final invoicePayment = row(receipt(
  uuid: 'r-3',
  barcode: '1000000000003',
  createdAt: DateTime(2026, 10, 17, 11),
  salesTypeIndex: 2,
  invoiceUuid: 'inv-1',
  cash: 500,
  balance: 1500,
  staffId: null,
  staffName: null,
  originalCost: 2000,
));
final splitSale = row(receipt(
  uuid: 'r-4',
  barcode: '1000000000004',
  createdAt: DateTime(2026, 10, 17, 12),
  cash: 1250000,
  bank: 200,
  customerUuid: 'c-dayo',
  customerName: 'Dayo',
  items: [line(quantity: 1, revenue: 1250200)],
));
final sample = run([sale, bankSale, invoicePayment, splitSale]);

ReportExportSpec specFor(
  List<ReceiptsReportRow> rows, {
  ReportGroupBy groupBy = ReportGroupBy.off,
  ReceiptsReportFilters? filters,
  ReceiptsReportPeriod period = const ReceiptsReportPeriod.allTime(),
  ReceiptsSortField sortField = ReceiptsSortField.createdAt,
  bool ascending = false,
  int profitExcluded = 0,
  bool canSeeCost = true,
  bool departmentsEnabled = true,
  bool subStaffEnabled = true,
}) {
  final groups = ReceiptsGrouping.sort(
    ReceiptsGrouping.build(rows, groupBy),
    field: ReceiptsTableGroupSortField.revenue,
    ascending: false,
  );
  return receiptsReportExportSpec(
    rows: rows,
    groups: groups,
    groupBy: groupBy,
    filters: filters ?? ReceiptsReportFilters(),
    choices: ReceiptsFilterChoices.fromRows(rows),
    period: period,
    sortField: sortField,
    ascending: ascending,
    groupSortField: ReceiptsTableGroupSortField.revenue,
    groupAscending: false,
    profitExcluded: profitExcluded,
    currency: '₦',
    canSeeCost: canSeeCost,
    departmentsEnabled: departmentsEnabled,
    subStaffEnabled: subStaffEnabled,
  );
}

ResolvedTable tableOf(ReportExportSpec spec) =>
    resolveExport(spec, testCtx).tables.single;

ResolvedCell cellOf(ReportExportSpec spec, String id, String columnId) {
  final t = tableOf(spec);
  final r = t.rows.firstWhere((r) => r[t.indexOf('id')].text == id);
  return r[t.indexOf(columnId)];
}

Map<String, String> filtersOf(ReportExportSpec spec) =>
    {for (final f in spec.filters) f.label: f.value};

void main() {
  group('rows are the screen query, every page', () {
    test('150 receipts sorted like the screen, beyond the 100-row page', () {
      final rows = [
        for (var i = 0; i < 150; i++)
          row(receipt(
            uuid: 'r-$i',
            barcode: '${2000 + i}',
            createdAt: DateTime(2026, 10, 17, 8).add(Duration(minutes: i)),
            cash: ((i * 37) % 150 + 1) * 10.0,
          )),
      ];
      final sorted = run(rows, sortField: ReceiptsSortField.revenue);
      expect(ReceiptsReportQuery.paginate(sorted, 1).rows, hasLength(100));
      final spec = specFor(sorted, sortField: ReceiptsSortField.revenue);
      expect(spec.tables.single.erasedRows, orderedEquals(sorted));
      final t = tableOf(spec);
      expect(
        [for (final r in t.rows) r[t.indexOf('id')].text],
        [for (final r in sorted) r.displayId],
      );
      expect(spec.sortedBy, 'Total Revenue (descending)');
    });
  });

  group('columns follow the screen', () {
    List<String> ids(ReportExportSpec s) => [for (final c in tableOf(s).columns) c.id];

    test('every condition on', () {
      expect(ids(specFor(sample)), [
        'id', 'staff', 'subStaff', 'customer', 'channel', 'date', 'time',
        'discount', 'vat', 'items', 'department', 'comment', 'type',
        'balance', 'profit', 'margin', 'costMissing', 'subtotal', 'revenue',
      ]);
    });

    test('cost, departments and sub-staff hide their columns', () {
      final off = ids(specFor(
        sample,
        canSeeCost: false,
        departmentsEnabled: false,
        subStaffEnabled: false,
      ));
      for (final id in ['profit', 'margin', 'costMissing', 'department', 'subStaff']) {
        expect(off, isNot(contains(id)), reason: id);
      }
    });

    test('Comment and Cost Missing are Excel-only', () {
      final t = tableOf(specFor(sample));
      expect([for (final c in t.columns) if (!c.inPdf) c.id], ['comment', 'costMissing']);
    });
  });

  group('cells', () {
    test('a cash sale with item data', () {
      final spec = specFor(sample);
      expect(cellOf(spec, '#1000000000001', 'staff').text, 'Ada');
      expect(cellOf(spec, '#1000000000001', 'channel').text, 'Cash');
      expect(cellOf(spec, '#1000000000001', 'discount').text, endsWith('(10%)'));
      expect(cellOf(spec, '#1000000000001', 'department').text, 'Front Shop');
      expect(cellOf(spec, '#1000000000001', 'comment').text, 'Paid at the counter');
      expect(cellOf(spec, '#1000000000001', 'revenue').raw, sale.revenue);
      expect(cellOf(spec, '#1000000000001', 'profit').raw, sale.profit);
      expect(cellOf(spec, '#1000000000001', 'costMissing').text, 'No');
    });

    test('no item data: profit and margin read N/A', () {
      final spec = specFor(sample);
      expect(cellOf(spec, '#1000000000002', 'profit').text, 'N/A');
      expect(cellOf(spec, '#1000000000002', 'margin').text, 'N/A');
      expect(cellOf(spec, '#1000000000002', 'items').text, '—');
      expect(cellOf(spec, '#1000000000002', 'channel').text, 'Bank');
    });

    test('invoice payments hide the invoice totals, as on screen', () {
      final spec = specFor(sample);
      for (final c in ['discount', 'vat', 'subtotal']) {
        expect(cellOf(spec, '#1000000000003', c).text, '—', reason: c);
      }
      expect(cellOf(spec, '#1000000000003', 'type').text, 'Invoice Payment');
      expect(cellOf(spec, '#1000000000003', 'staff').text, 'Not Set');
      expect(cellOf(spec, '#1000000000003', 'balance').raw, 1500);
    });
  });

  group('totals', () {
    test('equal the ReceiptsReportPage totals the screen shows', () {
      final page = ReceiptsReportQuery.paginate(sample, 1);
      final t = tableOf(specFor(sample));
      Object? total(String id) => t.totals![t.indexOf(id)].raw;
      expect(t.totals![t.indexOf('id')].text, '4 receipts');
      expect(total('revenue'), page.totalRevenue);
      expect(total('discount'), page.totalDiscount);
      expect(total('vat'), page.totalVat);
      expect(total('items'), page.totalItems);
      expect(total('balance'), page.totalBalance);
      expect(total('profit'), page.totalProfit);
      expect(total('margin'), page.totalMargin);
      expect(total('subtotal'), page.totalSubtotal);
    });

    test('a split sheet gets the totals of its own receipts', () {
      final f = ExportFormatter(currency: '₦');
      final groups = resolveGroups(specFor(sample).tables.single, 'staff', f);
      final ada = groups.firstWhere((g) => g.name == 'Ada').table;
      final adaRows = sample.where((r) => r.staffKey == 'staff-a').toList();
      expect(
        ada.totals![ada.indexOf('revenue')].raw,
        ReceiptsReportQuery.paginate(adaRows, 1).totalRevenue,
      );
    });
  });

  group('grouped', () {
    test('by Staff: the group table, its totals, "Grouped by: Staff"', () {
      final spec = specFor(sample, groupBy: ReportGroupBy.staff);
      final groups = ReceiptsGrouping.sort(
        ReceiptsGrouping.build(sample, ReportGroupBy.staff),
        field: ReceiptsTableGroupSortField.revenue,
        ascending: false,
      );
      final page = ReceiptsGrouping.paginate(groups, 1);
      final t = tableOf(spec);
      expect(t.columns.first.label, 'Staff');
      expect([for (final r in t.rows) r[0].text], [for (final g in groups) g.label]);
      expect(t.rows.last[0].text, 'No staff');
      expect(t.totals![t.indexOf('receipts')].raw, page.totalReceipts);
      expect(t.totals![t.indexOf('revenue')].raw, page.totalRevenue);
      expect(t.totals![t.indexOf('balance')].raw, page.totalBalance);
      expect(t.totals![0].text, '3 staff');
      expect(spec.groupedBy, 'Staff');
      expect(spec.sortedBy, 'Total Revenue (descending)');
      expect(spec.splitOptions, isEmpty);
      final info = {
        for (final e in reportPdfInfoEntries(resolveExport(spec, testCtx))) e.$1: e.$2,
      };
      expect(info['Grouped By'], 'Staff');
    });

    test('by Channel without cost access', () {
      final t = tableOf(specFor(sample, groupBy: ReportGroupBy.channel, canSeeCost: false));
      expect([for (final c in t.columns) c.id], ['name', 'receipts', 'items', 'balance', 'revenue']);
      expect({for (final r in t.rows) r[0].text}, {'Cash', 'Bank', 'Split'});
    });
  });

  group('splits', () {
    final f = ExportFormatter(currency: '₦');
    List<String> names(String id) => [
      for (final g in resolveGroups(specFor(sample).tables.single, id, f)) g.name,
    ];

    test('Staff, Channel, Department, Customer (opt-in, last)', () {
      expect(specFor(sample).splitOptions.map((s) => s.id), [
        'staff',
        'channel',
        'department',
        'customer',
      ]);
      expect(
        specFor(sample, departmentsEnabled: false).splitOptions.map((s) => s.id),
        ['staff', 'channel', 'customer'],
      );
    });

    test('"No …" groups come last', () {
      expect(names('staff'), ['Ada', 'Bola', 'No Staff']);
      expect(names('channel'), ['Bank', 'Cash', 'Split']);
      expect(names('department'), ['Front Shop', 'No Department']);
      expect(names('customer'), ['Chidi', 'Dayo', 'No Customer']);
    });
  });

  group('info box', () {
    test('period and filters worded like the chips', () {
      final filters = ReceiptsReportFilters(
        search: 'ada',
        staffKey: 'staff-a',
        customerKey: receiptsReportNoneKey,
        departmentKey: 'd-front',
        channel: ReceiptChannel.cash,
        type: ReceiptType.sales,
        revenueMin: 100,
        profitMax: 5000,
      );
      final spec = specFor(
        sample,
        filters: filters,
        period: ReceiptsReportPeriod.range(DateTime(2026, 10, 1), DateTime(2026, 10, 31)),
      );
      expect(filtersOf(spec), {
        'Search': 'ada',
        'Staff': 'Ada',
        'Customer': 'No Customer',
        'Department': 'Front Shop',
        'Channel': 'Cash',
        'Type': 'Sales',
        'Revenue': '₦100.00 - Any',
        'Profit/Loss': 'Any - ₦5,000.00',
      });
      expect(spec.period!.label, 'Oct 1, 2026 - Oct 31, 2026');
      expect(spec.sortedBy, 'Date (descending)');
    });

    test('profit range hidden without cost access; sub-staff when off', () {
      final filters = ReceiptsReportFilters(profitMin: 1, subStaffKey: 'x');
      final spec = specFor(
        sample,
        filters: filters,
        canSeeCost: false,
        subStaffEnabled: false,
      );
      expect(spec.filters, isEmpty);
      expect(receiptsSortLabels.length, ReceiptsSortField.values.length);
    });
  });

  group('notes', () {
    test('exactly the screen notes, from the screen conditions', () {
      // A profit range leaves out Bola's receipt (no item data).
      final filters = ReceiptsReportFilters(profitMin: 0);
      final excluded = ReceiptsReportQuery.profitExcludedCount(
        rows: sample,
        period: const ReceiptsReportPeriod.allTime(),
        filters: filters,
        departmentsEnabled: true,
        subStaffEnabled: true,
        profitVisible: true,
      );
      expect(excluded, greaterThan(0));
      final spec = specFor(sample, filters: filters, profitExcluded: excluded);
      expect(spec.notes, [
        'All time covers the receipts loaded on this device.',
        '$excluded receipt${excluded == 1 ? ' is' : 's are'} left out of the '
            'profit range: no item data or a missing cost price.',
      ]);
      expect(spec.notes, receiptsReportNotes(
        period: const ReceiptsReportPeriod.allTime(),
        profitExcluded: excluded,
      ));
      final info = {
        for (final e in reportPdfInfoEntries(resolveExport(spec, testCtx))) e.$1: e.$2,
      };
      expect(info['Notes'], spec.notes.join('\n'));
    });

    test('no notes for one day without a profit range', () {
      final spec = specFor(sample, period: ReceiptsReportPeriod.day(DateTime(2026, 10, 17)));
      expect(spec.notes, isEmpty);
      final info = {
        for (final e in reportPdfInfoEntries(resolveExport(spec, testCtx))) e.$1: e.$2,
      };
      expect(info.containsKey('Notes'), isFalse);
    });
  });

  group('roll', () {
    String preview(ReportExportSpec spec, RollPaper paper) => renderRollEscPos(
      buildRollLines(spec, testCtx, paper: paper),
      paper,
    ).preview;

    test('58mm: ID · Total on one line', () {
      final text = preview(specFor(sample), RollPaper.mm58);
      final out = text.split('\n');
      final big = out.firstWhere((l) => l.startsWith('#1000000000004'));
      expect(big, endsWith('N1,250,200.00'));
      expect(out.every((l) => l.length <= 32 || l.startsWith('* ')), isTrue);
      expect(text, contains('4 receipts'));
    });

    test('80mm: ID · Staff · Total, date | channel underneath', () {
      final out = preview(specFor(sample), RollPaper.mm80).split('\n');
      final i = out.indexWhere((l) => l.startsWith('#1000000000004'));
      expect(out[i], contains('Ada'));
      expect(out[i], endsWith('N1,250,200.00'));
      expect(out[i + 1].trim(), 'Oct 17, 2026 | Split');
      expect(out.every((l) => l.length <= 48 || l.startsWith('* ')), isTrue);
    });

    test('grouped: Name · Receipts · Total', () {
      final out = preview(specFor(sample, groupBy: ReportGroupBy.staff), RollPaper.mm80)
          .split('\n');
      final ada = out.firstWhere((l) => l.startsWith('Ada '));
      expect(ada, endsWith('N1,251,200.00'));
      expect(ada, contains(' 2 '));
    });
  });

  group('Receipts screen', () {
    setUpAll(setUpScreenEnvironment);
    tearDownAll(() async => Hive.close());

    for (final desktop in [true, false]) {
      testWidgets('shows the Export pill (${desktop ? 'desktop' : 'mobile'})', (
        tester,
      ) async {
        await pumpReportScreen(
          tester,
          ReceiptsReportMainView(isDesktop: desktop),
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
