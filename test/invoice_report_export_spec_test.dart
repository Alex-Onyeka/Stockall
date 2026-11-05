import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:stockall/classes/temp_invoices/temp_invoices.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/pages/report/components/export/report_export_format.dart';
import 'package:stockall/pages/report/components/export/report_export_resolve.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/export/report_pdf_builder.dart';
import 'package:stockall/pages/report/components/export/report_roll_builder.dart';
import 'package:stockall/pages/report/components/report_group_by.dart';
import 'package:stockall/pages/report/invoice_report/invoice_report_table/class/invoice_report_export_spec.dart';
import 'package:stockall/pages/report/invoice_report/invoice_report_table/class/invoice_report_table_logic.dart';
import 'package:stockall/pages/report/invoice_report/invoice_report_table/components/invoice_report_table_view.dart';

import 'item_history_export_fixtures.dart' show testCtx;
import 'report_export_screen_harness.dart';

// The invoice report tests build their invoices inside main(), so these
// builders follow the same TempInvoice / TempMainReceipt setup
// (invoice_report_table_test.dart, "InvoiceReportGrouping").
TempInvoice inv(
  String uuid, {
  String? barcode,
  String staffId = 'staff-a',
  String staffName = 'Ada',
  String? customerUuid,
  String? customerName,
  double total = 1000,
  double bank = 0,
  DateTime? createdAt,
  String? departmentUuid,
  String? departmentName,
  String? subStaffUuid,
  String? subStaffName,
  double? generalDiscount,
  double? fixedDiscount,
  double? vat,
  double? originalCost,
  String? comment,
}) => TempInvoice(
  uuid: uuid,
  barcode: barcode,
  createdAt: createdAt ?? DateTime(2026, 10, 17, 10),
  shopId: 1,
  staffId: staffId,
  staffName: staffName,
  customerUuid: customerUuid,
  customerName: customerName,
  paymentMethod: 'Cash',
  bank: bank,
  cashAlt: total,
  departmentName: departmentName,
  departmentUuidNew: departmentUuid,
  cartName: 'Cart 1',
  subStaffName: subStaffName,
  subStaffUuid: subStaffUuid,
  comment: comment,
  generalDiscount: generalDiscount,
  fixedDiscount: fixedDiscount,
  vat: vat,
  originalCost: originalCost,
);

TempMainReceipt pay(
  String invoiceUuid,
  String uuid, {
  double cash = 0,
  double bank = 0,
}) => TempMainReceipt(
  uuid: uuid,
  invoiceUuid: invoiceUuid,
  shopId: 1,
  staffId: 'staff-a',
  staffName: 'Ada',
  paymentMethod: bank > 0 ? 'Bank' : 'Cash',
  bank: bank,
  cashAlt: cash,
  customerAccount: 0,
  createdAt: DateTime(2026, 10, 17, 12),
  isInvoice: true,
  salesTypeIndex: 2,
  departmentName: '',
  departmentUuidNew: '',
  cartName: 'Cart 1',
  subStaffName: '',
  comment: '',
);

List<InvoiceReportRow> build(
  List<TempInvoice> invoices, [
  List<TempMainReceipt> payments = const [],
]) => InvoiceReportRowBuilder.buildAll(
  invoices: invoices,
  allReceipts: payments,
  allProductSales: const [],
  customerMap: const {},
);

// Ada's 10% discount + 7.5% VAT invoice, paid in full (Front Shop);
// Bola's walk-in, part paid by bank; Ada's ₦1,250,000 to Dayo, unpaid;
// an invoice with no total and no staff (status N/A).
final sample = build(
  [
    inv(
      'i-1',
      barcode: '1000000000001',
      customerUuid: 'c-chidi',
      customerName: 'Chidi',
      generalDiscount: 10,
      vat: 7.5,
      originalCost: 1100,
      departmentUuid: 'd-front',
      departmentName: 'Front Shop',
      comment: 'Paid at the counter',
      createdAt: DateTime(2026, 10, 17, 9),
    ),
    inv(
      'i-2',
      barcode: '1000000000002',
      staffId: 'staff-b',
      staffName: 'Bola',
      total: 2500,
      createdAt: DateTime(2026, 10, 17, 10),
    ),
    inv(
      'i-3',
      barcode: '1000000000003',
      customerUuid: 'c-dayo',
      customerName: 'Dayo',
      total: 1250000,
      subStaffUuid: 'sub-1',
      subStaffName: 'Kemi',
      createdAt: DateTime(2026, 10, 17, 11),
    ),
    inv(
      'i-4',
      barcode: '1000000000004',
      staffId: '',
      staffName: '',
      total: 0,
      createdAt: DateTime(2026, 10, 17, 12),
    ),
  ],
  [pay('i-1', 'p-1', cash: 1000), pay('i-2', 'p-2', bank: 500)],
);

List<InvoiceReportRow> query(
  List<InvoiceReportRow> rows, {
  InvoiceReportFilters? filters,
  InvoiceSortField sortField = InvoiceSortField.createdAt,
  bool ascending = false,
}) => InvoiceReportQuery.filterAndSort(
  rows: rows,
  filters: filters ?? InvoiceReportFilters(),
  sortField: sortField,
  ascending: ascending,
  departmentsEnabled: true,
  bulkSaleEnabled: true,
  costFilterAllowed: true,
);

ReportExportSpec specFor(
  List<InvoiceReportRow> rows, {
  ReportGroupBy groupBy = ReportGroupBy.off,
  InvoiceReportFilters? filters,
  bool departmentsEnabled = true,
  bool bulkSaleEnabled = true,
}) {
  final groups = InvoiceReportGrouping.sort(
    InvoiceReportGrouping.build(rows, groupBy),
    field: InvoiceGroupSortField.total,
    ascending: false,
  );
  return invoiceReportExportSpec(
    rows: rows,
    groups: groups,
    baseRows: rows,
    groupBy: groupBy,
    filters: filters ?? InvoiceReportFilters(),
    departmentNames: const {'d-front': 'Front Shop'},
    sortField: InvoiceSortField.createdAt,
    ascending: false,
    groupSortField: InvoiceGroupSortField.total,
    groupAscending: false,
    currency: '₦',
    departmentsEnabled: departmentsEnabled,
    bulkSaleEnabled: bulkSaleEnabled,
  );
}

ResolvedTable tableOf(ReportExportSpec spec) =>
    resolveExport(spec, testCtx).tables.single;

ResolvedCell cellOf(ReportExportSpec spec, String id, String columnId) {
  final t = tableOf(spec);
  final r = t.rows.firstWhere((r) => r[t.indexOf('id')].text == id);
  return r[t.indexOf(columnId)];
}

void main() {
  group('rows are the screen query, every page', () {
    test('150 invoices: every row, in the screen order', () {
      final rows = build([
        for (var i = 0; i < 150; i++)
          inv(
            'i-$i',
            barcode: '${2000000000000 + i}',
            total: 100.0 + i,
            createdAt: DateTime(2026, 10, 1).add(Duration(hours: i)),
          ),
      ]);
      final sorted = query(rows, sortField: InvoiceSortField.total);
      final t = tableOf(specFor(sorted));
      expect(t.rows, hasLength(150));
      expect([for (final r in t.rows) r[t.indexOf('id')].text], [
        for (final r in sorted) r.displayId,
      ]);
      expect(InvoiceReportQuery.paginate(sorted, 1).rows, hasLength(100));
    });
  });

  group('columns follow the screen', () {
    test('every column, Comment in Excel only', () {
      final t = tableOf(specFor(sample));
      expect([for (final c in t.columns) c.label], [
        'ID',
        'Staff',
        'Sub-Staff',
        'Customer',
        'Date',
        'Time',
        'Discount',
        'VAT',
        'Items',
        'Department',
        'Comment',
        'Invoice Total',
        'Amount Paid',
        'Balance',
        'Status',
      ]);
      final comment = t.columns[t.indexOf('comment')];
      expect(comment.inPdf, isFalse);
      expect(comment.inExcel, isTrue);
    });

    test('Sub-Staff only with bulk sale, Department only with departments', () {
      final t = tableOf(specFor(sample, departmentsEnabled: false, bulkSaleEnabled: false));
      expect(t.indexOf('subStaff'), -1);
      expect(t.indexOf('department'), -1);
    });
  });

  group('cells', () {
    final spec = specFor(sample);
    test('discount and VAT as the screen words them, never shortened', () {
      expect(cellOf(spec, '#1000000000001', 'discount').text, '10% (₦110.00)');
      expect(cellOf(spec, '#1000000000001', 'discount').raw, 110);
      expect(cellOf(spec, '#1000000000001', 'vat').text, '[7.5%] ₦82.50');
      expect(cellOf(spec, '#1000000000002', 'discount').text, '—');
      expect(cellOf(spec, '#1000000000002', 'vat').text, '—');
      expect(cellOf(spec, '#1000000000003', 'total').text, '₦1,250,000.00');
    });

    test('status, balance and N/A', () {
      expect(cellOf(spec, '#1000000000001', 'status').text, 'Paid');
      expect(cellOf(spec, '#1000000000002', 'status').text, 'Partial');
      expect(cellOf(spec, '#1000000000002', 'balance').raw, 2000);
      expect(cellOf(spec, '#1000000000003', 'status').text, 'Unpaid');
      expect(cellOf(spec, '#1000000000004', 'status').text, 'N/A');
      expect(cellOf(spec, '#1000000000004', 'total').text, 'N/A');
      expect(cellOf(spec, '#1000000000004', 'balance').text, 'N/A');
      expect(cellOf(spec, '#1000000000004', 'items').text, 'N/A');
      expect(cellOf(spec, '#1000000000001', 'comment').text, 'Paid at the counter');
    });
  });

  group('totals', () {
    test('equal the InvoiceReportPageResult totals the screen shows', () {
      final page = InvoiceReportQuery.paginate(sample, 1);
      final t = tableOf(specFor(sample));
      Object? total(String id) => t.totals![t.indexOf(id)].raw;
      expect(t.totals![t.indexOf('id')].text, '4 invoices');
      expect(total('total'), page.totalRevenue);
      expect(total('paid'), page.totalAmountPaid);
      expect(total('balance'), page.totalBalance);
    });

    test('a split sheet gets the totals of its own invoices', () {
      final f = ExportFormatter(currency: '₦');
      final groups = resolveGroups(specFor(sample).tables.single, 'staff', f);
      final ada = groups.firstWhere((g) => g.name == 'Ada').table;
      final adaRows = sample.where((r) => r.invoice.staffId == 'staff-a').toList();
      expect(
        ada.totals![ada.indexOf('total')].raw,
        InvoiceReportQuery.paginate(adaRows, 1).totalRevenue,
      );
    });
  });

  group('grouped', () {
    test('by Staff: the group table, its totals, "Grouped by: Staff"', () {
      final spec = specFor(sample, groupBy: ReportGroupBy.staff);
      final groups = InvoiceReportGrouping.sort(
        InvoiceReportGrouping.build(sample, ReportGroupBy.staff),
        field: InvoiceGroupSortField.total,
        ascending: false,
      );
      final page = InvoiceReportGrouping.paginate(groups, 1);
      final t = tableOf(spec);
      expect([for (final c in t.columns) c.label], [
        'Staff',
        'Invoices',
        'Invoice Total',
        'Amount Paid',
        'Balance',
      ]);
      expect([for (final r in t.rows) r[0].text], [for (final g in groups) g.label]);
      expect(t.rows.last[0].text, 'No staff');
      expect(t.totals![t.indexOf('invoices')].raw, page.totalInvoices);
      expect(t.totals![t.indexOf('total')].raw, page.totalRevenue);
      expect(t.totals![t.indexOf('paid')].raw, page.totalAmountPaid);
      expect(t.totals![t.indexOf('balance')].raw, page.totalBalance);
      expect(spec.groupedBy, 'Staff');
      expect(spec.sortedBy, 'Invoice Total (descending)');
      expect(spec.splitOptions, isEmpty);
    });

    test('by Channel: Unpaid last', () {
      final t = tableOf(specFor(sample, groupBy: ReportGroupBy.channel));
      expect([for (final r in t.rows) r[0].text].last, 'Unpaid');
    });
  });

  group('splits', () {
    final f = ExportFormatter(currency: '₦');
    List<String> names(String id) => [
      for (final g in resolveGroups(specFor(sample).tables.single, id, f)) g.name,
    ];

    test('Staff, Channel, Status, Department, Customer (opt-in, last)', () {
      expect(specFor(sample).splitOptions.map((s) => s.id), [
        'staff',
        'channel',
        'status',
        'department',
        'customer',
      ]);
      expect(
        specFor(sample, departmentsEnabled: false).splitOptions.map((s) => s.id),
        ['staff', 'channel', 'status', 'customer'],
      );
    });

    test('"No …" groups come last', () {
      expect(names('staff'), ['Ada', 'Bola', 'No Staff']);
      expect(names('channel'), ['Bank', 'Cash', 'Unpaid']);
      expect(names('status').last, 'No Status');
      expect(names('status'), containsAll(['Paid', 'Partial', 'Unpaid']));
      expect(names('department'), ['Front Shop', 'No Department']);
      expect(names('customer'), ['Chidi', 'Dayo', 'No Customer']);
    });
  });

  group('info box', () {
    test('the date pill as the period; filters worded like the chips', () {
      final filters = InvoiceReportFilters(
        search: 'ada',
        dateRange: DateTimeRange(
          start: DateTime(2026, 10, 17),
          end: DateTime(2026, 10, 17),
        ),
        staffId: 'staff-a',
        customerUuid: 'c-dayo',
        paymentStatus: InvoicePaymentStatusFilter.partial,
        subStaffUuid: 'sub-1',
        departmentKey: 'd-front',
        totalMin: 100,
        balanceMax: 5000,
      );
      final spec = specFor(sample, filters: filters);
      expect(spec.period!.label, 'Oct 17, 2026');
      expect([for (final x in spec.filters) '${x.label}: ${x.value}'], [
        'Search: ada',
        'Staff: Ada',
        'Customer: Dayo',
        'Status: Partially Paid',
        'Sub-Staff: Kemi',
        'Department: Front Shop',
        'Total: ₦100.00 - Any',
        'Balance: Any - ₦5,000.00',
      ]);
      expect(spec.sortedBy, 'Date (descending)');
      final range = invoicePeriodLabel(
        DateTimeRange(start: DateTime(2026, 10, 1), end: DateTime(2026, 10, 17)),
      );
      expect(range, 'Oct 1, 2026 - Oct 17, 2026');
      expect(specFor(sample).period!.label, 'All Time');
    });

    test('no notes: the screen shows none', () {
      final spec = specFor(sample);
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

    test('58mm: ID · Invoice Total on one line', () {
      final out = preview(specFor(sample), RollPaper.mm58).split('\n');
      expect(
        out.firstWhere((l) => l.startsWith('#1000000000003')),
        endsWith('N1,250,000.00'),
      );
      expect(out.every((l) => l.length <= 32), isTrue);
    });

    test('80mm: ID · Total · Balance, customer | date underneath', () {
      final out = preview(specFor(sample), RollPaper.mm80).split('\n');
      final i = out.indexWhere((l) => l.startsWith('#1000000000003'));
      expect(out[i], endsWith('N1,250,000.00'));
      expect('N1,250,000.00'.allMatches(out[i]), hasLength(2));
      expect(out[i + 1].trim(), 'Dayo | Oct 17, 2026');
      expect(out.every((l) => l.length <= 48), isTrue);
    });
  });

  group('Invoice table screen', () {
    setUpAll(setUpScreenEnvironment);
    tearDownAll(() async => Hive.close());

    for (final desktop in [true, false]) {
      testWidgets('shows the Export pill (${desktop ? 'desktop' : 'mobile'})', (
        tester,
      ) async {
        await pumpReportScreen(
          tester,
          InvoiceReportTableView(isDesktop: desktop),
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
