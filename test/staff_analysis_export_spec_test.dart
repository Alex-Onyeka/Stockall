import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/pages/report/components/export/report_export_resolve.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/export/report_pdf_builder.dart';
import 'package:stockall/pages/report/components/export/report_roll_builder.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/staff_report/staff_analysis/class/staff_analysis_export_spec.dart';
import 'package:stockall/pages/report/staff_report/staff_analysis/class/staff_analysis_logic.dart';
import 'package:stockall/pages/report/staff_report/staff_report_table/class/staff_report_table_logic.dart';
import 'package:stockall/services/printing/escpos_builder.dart' show fontBDots;

import 'item_history_export_fixtures.dart' show testCtx;
import 'purchase_report_fixtures.dart' show uuidN;
import 'staff_report_fixtures.dart';

final staff = [testUser(name: 'Ada', email: 'ada@example.com')];

/// Seven receipts (the screen shows 5), an order, a purchase and an
/// expense, all Ada's; one receipt of a former staff.
StaffReportBase baseFor(StaffReportAccess access) => buildStaffBase(
  staff: staff,
  receipts: [
    for (var i = 1; i <= 7; i++)
      testReceipt(
        uuid: 'r-100000000000$i',
        cash: i == 7 ? 1250000 : 100.0 * i,
        createdAt: DateTime(2026, 10, 10 + i, 12),
      ),
    testReceipt(uuid: 'r-x', cash: 9, staffId: 'staff-x')..staffName = 'Xena',
  ],
  invoices: [testInvoice(uuid: 'i-2000000000001', total: 300)],
  orders: [staffOrder(uuid: 'o-3000000000001', total: 80)],
  purchases: [purchase(uuid: uuidN(1), staffId: 'staff-a', total: 40)],
  expenses: [testExpense(amount: 25, description: 'Generator diesel')],
  access: access,
);

StaffAnalysis analyse(String key, {StaffReportAccess? access, ReceiptsReportPeriod period = allTime}) {
  final a = access ?? staffAccess();
  return StaffAnalysis.build(staffKey: key, slice: staffSlice(baseFor(a), period: period));
}

ReportExportSpec specFor({
  String key = 'staff-a',
  StaffReportAccess? access,
  ReceiptsReportPeriod period = allTime,
}) => staffAnalysisExportSpec(
  analysis: analyse(key, access: access, period: period),
  period: period,
  currency: '₦',
);

ResolvedExport resolved(ReportExportSpec s) => resolveExport(s, testCtx);

Map<String, ResolvedMetric> metrics(ReportExportSpec s, String title) => {
  for (final m in resolved(s)
      .sections
      .whereType<ResolvedSummary>()
      .firstWhere((x) => x.title == title)
      .metrics)
    m.label: m,
};

ResolvedTable table(ReportExportSpec s, String prefix) =>
    resolved(s).tables.firstWhere((t) => t.title.startsWith(prefix));

List<String> titles(ReportExportSpec s) => [for (final x in s.sections) x.title.split(' (').first];

void main() {
  group('sections', () {
    test('contact, KPIs and each section under its gate; no splits', () {
      expect(titles(specFor()), [
        'Contact Details',
        'Statistics',
        'Receipts',
        'Invoices',
        'Orders',
        'Purchases',
        'Expenses',
      ]);
      expect(
        titles(specFor(access: staffAccess(showOrders: false, showPurchases: false, showExpenses: false))),
        ['Contact Details', 'Statistics', 'Receipts', 'Invoices'],
      );
      expect(specFor().splitOptions, isEmpty);
      expect({for (final f in specFor().filters) f.label: f.value}, {'Staff': 'Ada'});
    });
  });

  group('figures', () {
    test('contact details; the former-staff marker', () {
      final m = metrics(specFor(), 'Contact Details');
      expect(m['Role']!.text, 'Cashier');
      expect(m['Phone']!.text, '0801');
      expect(m['Email']!.text, 'ada@example.com');
      expect(m.containsKey('Status'), isFalse);
      final former = metrics(specFor(key: 'staff-x'), 'Contact Details');
      expect(former['Role']!.text, '—');
      expect(former['Status']!.text, staffReportFormerRoleLabel);
    });

    test('the KPIs are the staff row, under the same gates', () {
      final s = analyse('staff-a').summary;
      final m = metrics(specFor(), 'Statistics');
      expect(m['Receipt Sales']!.raw, s.receiptSales);
      expect(m['Receipt Sales']!.note, '7 receipts');
      expect(m['Invoice Sales']!.raw, s.invoiceSales);
      expect(m['Orders']!.raw, s.orderTotal);
      expect(m['Orders']!.note, '1 order');
      expect(m['Purchases']!.raw, s.purchaseTotal);
      expect(m['Expenses']!.raw, s.expenseTotal);
      expect(m['Last Activity']!.raw, s.lastActivity);
      final hidden = metrics(specFor(access: staffAccess(showExpenses: false)), 'Statistics');
      expect(hidden.containsKey('Expenses'), isFalse);
    });
  });

  group('recent records', () {
    test('the screen\'s 5 most recent of each section', () {
      final a = analyse('staff-a');
      final spec = specFor();
      final receipts = table(spec, 'Receipts');
      expect(receipts.title, 'Receipts (5 of 7 in this period)');
      expect(
        [for (final r in receipts.rows) r[receipts.indexOf('record')].text],
        [for (final r in a.recentReceipts) r.displayId],
      );
      final purchases = table(spec, 'Purchases');
      expect(purchases.rows.single[purchases.indexOf('detail')].text, 'Acme');
      expect(purchases.indexOf('balance'), greaterThan(0));
      final expenses = table(spec, 'Expenses');
      expect(expenses.rows.single[expenses.indexOf('detail')].text, 'Generator diesel');
      expect(expenses.indexOf('balance'), -1);
    });
  });

  group('info box and notes', () {
    test('the All time note exactly when the screen shows it', () {
      final all = specFor();
      expect(all.notes, ['All time covers the data loaded on this device.']);
      final info = {
        for (final e in reportPdfInfoEntries(resolved(all))) e.$1: e.$2,
      };
      expect(info['Notes'], all.notes.single);
      expect(specFor(period: ReceiptsReportPeriod.day(DateTime(2026, 10, 17))).notes, isEmpty);
    });
  });

  group('roll', () {
    for (final paper in RollPaper.values) {
      test('${paper.name}: pairs and records fit, amounts on one line', () {
        final out = renderRollEscPos(
          buildRollLines(specFor(), testCtx, paper: paper),
          paper,
        ).preview.split('\n');
        expect(out.every((l) => l.length <= paper.dots ~/ fontBDots), isTrue);
        final big = out.where((l) => l.contains('N1,250,000.00')).toList();
        expect(big, isNotEmpty);
        expect(big.every((l) => l.length <= paper.chars), isTrue);
      });
    }
  });

  group('Staff Analysis screen', () {
    for (final desktop in [true, false]) {
      testWidgets('shows the Export pill (${desktop ? 'desktop' : 'mobile'})', (
        tester,
      ) async {
        await pumpStaffAnalysis(
          tester,
          isDesktop: desktop,
          env: fakeStaffEnv(staff: staff),
        );
        // Beside the period button at every width (no "View" toggle).
        expect(find.text('Export'), findsOneWidget);
      });
    }
  });
}
