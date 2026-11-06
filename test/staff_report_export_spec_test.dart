import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/pages/report/components/export/report_export_format.dart';
import 'package:stockall/pages/report/components/export/report_export_resolve.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/export/report_pdf_builder.dart';
import 'package:stockall/pages/report/components/export/report_roll_builder.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/staff_report/staff_report_table/class/staff_report_export_spec.dart';
import 'package:stockall/pages/report/staff_report/staff_report_table/class/staff_report_table_logic.dart';
import 'package:stockall/services/printing/escpos_builder.dart' show fontBDots;

import 'item_history_export_fixtures.dart' show testCtx;
import 'purchase_report_fixtures.dart' show uuidN;
import 'staff_report_fixtures.dart';

// Ada (Cashier) sells ₦1,250,000 over two receipts; Bayo has no role;
// Xena left the shop (former staff) but her receipt remains; Ada has
// an order, a purchase and an expense.
final staff = [
  testUser(name: 'Ada'),
  testUser(userId: 'staff-b', name: 'Bayo', role: '', phone: null),
];

final receipts = [
  testReceipt(uuid: 'r-1', cash: 1000000),
  testReceipt(uuid: 'r-2', cash: 250000, createdAt: DateTime(2026, 10, 18, 9)),
  testReceipt(uuid: 'r-3', cash: 70, staffId: 'staff-b'),
  testReceipt(uuid: 'r-4', cash: 9, staffId: 'staff-x')..staffName = 'Xena',
];

StaffReportBase baseFor(StaffReportAccess access) => buildStaffBase(
  staff: staff,
  receipts: receipts,
  orders: [staffOrder(uuid: 'o-1', total: 60)],
  purchases: [purchase(uuid: uuidN(1), staffId: 'staff-a', total: 40)],
  expenses: [testExpense(amount: 25)],
  access: access,
);

List<StaffReportRow> query({
  StaffReportAccess? access,
  StaffReportFilters? filters,
  StaffReportSortField sortField = StaffReportSortField.name,
  List<StaffReportRow>? rows,
}) {
  final a = access ?? staffAccess();
  return StaffReportQuery.filterAndSort(
    rows: rows ?? staffRows(baseFor(a)),
    filters: filters ?? StaffReportFilters(),
    sortField: sortField,
    ascending: true,
    access: a,
  );
}

ReportExportSpec specFor({
  StaffReportAccess? access,
  StaffReportFilters? filters,
  StaffReportSortField sortField = StaffReportSortField.name,
  ReceiptsReportPeriod period = allTime,
  List<StaffReportRow>? rows,
}) {
  final a = access ?? staffAccess();
  return staffReportExportSpec(
    rows: rows ?? query(access: a, filters: filters, sortField: sortField),
    filters: filters ?? StaffReportFilters(),
    roleOptions: StaffReportOptions.roles(staffRows(baseFor(a))),
    sortField: sortField,
    ascending: true,
    access: a,
    period: period,
    currency: '₦',
  );
}

ResolvedTable tableOf(ReportExportSpec spec) =>
    resolveExport(spec, testCtx).tables.single;

List<String> labels(ResolvedTable t) => [for (final c in t.columns) c.label];

void main() {
  group('rows are the screen query, every page', () {
    test('150 staff: every row, in the screen order', () {
      final many = buildStaffBase(
        staff: [
          for (var i = 0; i < 150; i++)
            testUser(userId: 's-$i', name: 'Staff ${i.toString().padLeft(3, '0')}'),
        ],
      );
      final rows = query(rows: staffRows(many));
      final t = tableOf(specFor(rows: rows));
      expect(t.rows, hasLength(150));
      expect([for (final r in t.rows) r[0].text], [for (final r in rows) r.name]);
      expect(StaffReportQuery.paginate(rows, 1).rows, hasLength(100));
    });
  });

  group('column gates and cells', () {
    test('orders, purchases and expenses columns under their gates', () {
      expect(labels(tableOf(specFor())), [
        'Name',
        'Role',
        'Phone',
        'Receipts',
        'Receipt Sales',
        'Invoice Sales',
        'Orders',
        'Order Value',
        'Purchases',
        'Purchase Value',
        'Expenses',
        'Expense Value',
        'Last Activity',
      ]);
      final t = tableOf(specFor());
      final receipts = t.columns[t.indexOf('receipts')];
      expect((receipts.inPdf, receipts.inExcel), (false, false));
      final none = labels(
        tableOf(specFor(access: staffAccess(showOrders: false, showPurchases: false, showExpenses: false))),
      );
      for (final c in ['Orders', 'Order Value', 'Purchases', 'Purchase Value', 'Expenses', 'Expense Value']) {
        expect(none, isNot(contains(c)), reason: c);
      }
    });

    test('the "Former staff" marker; blanks "—"', () {
      final t = tableOf(specFor());
      final names = [for (final r in t.rows) r[0].text];
      expect(names, contains('Xena (Former staff)'));
      final xena = t.rows.firstWhere((r) => r[0].text.startsWith('Xena'));
      expect(xena[t.indexOf('role')].text, '—');
      final bayo = t.rows.firstWhere((r) => r[0].text == 'Bayo');
      expect(bayo[t.indexOf('role')].text, 'Not Set');
      expect(bayo[t.indexOf('phone')].text, '—');
    });
  });

  group('totals', () {
    test('equal the StaffReportTotals the screen shows', () {
      final t0 = StaffReportQuery.paginate(query(), 1).totals;
      final t = tableOf(specFor());
      Object? total(String id) => t.totals![t.indexOf(id)].raw;
      expect(t.totals![0].text, '3 staff');
      expect(total('receiptSales'), t0.receiptSales);
      expect(total('invoiceSales'), t0.invoiceSales);
      expect(total('orderCount'), t0.orderCount);
      expect(total('orderTotal'), t0.orderTotal);
      expect(total('purchaseTotal'), t0.purchaseTotal);
      expect(total('expenseTotal'), t0.expenseTotal);
      expect(t0.receiptSales, 1250079);
    });
  });

  group('splits', () {
    test('by Role: Former staff its own sheet, "No Role" last', () {
      final spec = specFor();
      expect(spec.splitOptions.map((s) => s.id), ['role']);
      final names = [
        for (final g in resolveGroups(spec.tables.single, 'role', ExportFormatter(currency: '₦')))
          g.name,
      ];
      expect(names, ['Cashier', 'Former staff', 'No Role']);
    });
  });

  group('info box and notes', () {
    test('filters and the sort actually used', () {
      final spec = specFor(filters: StaffReportFilters(search: 'a', roleKey: 'cashier'));
      expect([for (final x in spec.filters) '${x.label}: ${x.value}'], [
        'Search: a',
        'Role: Cashier',
      ]);
      expect(
        specFor(sortField: StaffReportSortField.orderTotal, access: staffAccess(showOrders: false))
            .sortedBy,
        'Name (ascending)',
      );
      expect(specFor(sortField: StaffReportSortField.receiptSales).sortedBy, 'Receipt Sales (ascending)');
    });

    test('the All time note exactly when the screen shows it', () {
      final all = specFor();
      expect(all.notes, ['All time covers the data loaded on this device.']);
      final info = {
        for (final e in reportPdfInfoEntries(resolveExport(all, testCtx))) e.$1: e.$2,
      };
      expect(info['Notes'], all.notes.single);
      expect(specFor(period: ReceiptsReportPeriod.day(DateTime(2026, 10, 17))).notes, isEmpty);
    });
  });

  group('roll', () {
    String preview(RollPaper paper) =>
        renderRollEscPos(buildRollLines(specFor(), testCtx, paper: paper), paper).preview;

    test('58mm: Name · Receipt Sales', () {
      final out = preview(RollPaper.mm58).split('\n');
      expect(out.firstWhere((l) => l.startsWith('Ada')), endsWith('N1,250,000.00'));
      expect(out.every((l) => l.length <= RollPaper.mm58.dots ~/ fontBDots), isTrue);
    });

    test('80mm: Name · Receipts · Receipt Sales', () {
      final out = preview(RollPaper.mm80).split('\n');
      final ada = out.firstWhere((l) => l.startsWith('Ada'));
      expect(ada, endsWith('N1,250,000.00'));
      expect(ada, contains(' 2 '));
      expect(out.where((l) => l.contains('.00')).every((l) => l.length <= 48), isTrue);
    });
  });

  group('Staff table screen', () {
    for (final desktop in [true, false]) {
      testWidgets('shows the Export pill (${desktop ? 'desktop' : 'mobile'})', (
        tester,
      ) async {
        // pumpStaffTable opens "View" on mobile.
        await pumpStaffTable(
          tester,
          isDesktop: desktop,
          env: fakeStaffEnv(staff: staff, receipts: receipts),
        );
        expect(find.text('Export'), findsOneWidget);
      });
    }
  });
}
