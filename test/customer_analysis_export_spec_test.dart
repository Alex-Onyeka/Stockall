import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/pages/report/components/export/report_export_resolve.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/export/report_pdf_builder.dart';
import 'package:stockall/pages/report/components/export/report_roll_builder.dart';
import 'package:stockall/pages/report/customer_report/customer_analysis/class/customer_analysis_export_spec.dart';
import 'package:stockall/pages/report/customer_report/customer_analysis/class/customer_analysis_logic.dart';
import 'package:stockall/pages/report/customer_report/customer_report_table/class/customer_report_table_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/services/printing/escpos_builder.dart' show fontBDots;

import 'customer_report_fixtures.dart';
import 'item_history_export_fixtures.dart' show testCtx;

final bola = testCustomer(
  address: '2 Close',
  city: 'Abuja',
  country: 'Nigeria',
  balance: 500,
  cashReward: 20,
);

/// Seven receipts (the screen shows 5), an unpaid invoice, an order
/// and two ledger entries of each kind.
CustomerReportBase baseFor(CustomerReportAccess access) => buildBase(
  customers: [bola],
  receipts: [
    for (var i = 1; i <= 7; i++)
      testReceipt(
        uuid: 'r-100000000000$i',
        cash: i == 7 ? 1250000 : 100.0 * i,
        createdAt: DateTime(2026, 10, 10 + i, 12),
      ),
  ],
  invoices: [testInvoice(uuid: 'i-2000000000001', total: 300)],
  orders: [customerOrder(uuid: 'o-3000000000001', total: 80)],
  ledger: [
    ledgerEntry(uuid: 'a-1', amount: 40),
    ledgerEntry(uuid: 'a-2', isAdd: false, amount: 15, createdAt: DateTime(2026, 10, 16)),
    ledgerEntry(uuid: 'w-1', isBalance: false, amount: 30),
  ],
  access: access,
);

CustomerAnalysis analyse({CustomerReportAccess? access, ReceiptsReportPeriod period = allTime}) {
  final a = access ?? testAccess();
  return CustomerAnalysis.build(
    customer: bola,
    slice: sliceOf(baseFor(a), period: period),
  );
}

ReportExportSpec specFor({
  CustomerReportAccess? access,
  ReceiptsReportPeriod period = allTime,
}) {
  final a = access ?? testAccess();
  return customerAnalysisExportSpec(
    analysis: analyse(access: a, period: period),
    period: period,
    showTotalBalance: a.showTotalBalance,
    currency: '₦',
  );
}

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
    test('contact, KPIs and each section; ledger sections under their gates', () {
      expect(titles(specFor()), [
        'Contact Details',
        'Statistics',
        'Receipts',
        'Invoices',
        'Orders',
        'Reward Earnings',
        'Account Transactions',
      ]);
      expect(titles(specFor(access: testAccess(manageCustomerReward: false))),
          isNot(contains('Reward Earnings')));
      expect(titles(specFor(access: testAccess(canViewCustomersAccount: false))), [
        'Contact Details',
        'Statistics',
        'Receipts',
        'Invoices',
        'Orders',
      ]);
      expect(specFor().splitOptions, isEmpty);
      expect({for (final f in specFor().filters) f.label: f.value}, {'Customer': 'Bola'});
    });
  });

  group('figures', () {
    test('contact details, blanks "—"', () {
      final m = metrics(specFor(), 'Contact Details');
      expect(m['Phone']!.text, '0801');
      expect(m['Email']!.text, '—');
      expect(m['City']!.text, 'Abuja');
      expect(m['State']!.text, '—');
    });

    test('the KPIs are the customer row, under the same gates', () {
      final s = analyse().summary;
      final m = metrics(specFor(), 'Statistics');
      expect(m['Receipt Purchases']!.raw, s.receiptPurchases);
      expect(m['Receipt Purchases']!.note, '${s.salesReceiptCount} sales receipts');
      expect(m['Revenue']!.raw, s.revenue);
      expect(m['Credit']!.raw, s.credit);
      expect(m['Account Balance']!.raw, s.accountBalance);
      expect(m['Reward Earnings']!.raw, s.rewardEarnings);
      expect(m['Total Balance']!.raw, s.totalBalance);
      expect(m['Total Balance']!.note, 'Account + reward');
      expect(m['Receipts']!.raw, 7);
      expect(m['Order Total']!.raw, s.orderTotal);
      expect(m['Last Purchase']!.raw, s.lastPurchase);
      final hidden = metrics(specFor(access: testAccess(canViewCustomersAccount: false)), 'Statistics');
      for (final k in ['Account Balance', 'Reward Earnings', 'Total Balance']) {
        expect(hidden.containsKey(k), isFalse, reason: k);
      }
      final rewardOnly = metrics(specFor(access: testAccess(manageCustomerAccount: false)), 'Statistics');
      expect(rewardOnly['Total Balance']!.note, 'Reward');
    });
  });

  group('recent records', () {
    test('the screen\'s 5 most recent of each section', () {
      final a = analyse();
      final spec = specFor();
      final receipts = table(spec, 'Receipts');
      expect(receipts.title, 'Receipts (5 of 7 in this period)');
      expect(
        [for (final r in receipts.rows) r[receipts.indexOf('record')].text],
        [for (final r in a.recentReceipts) r.displayId],
      );
      expect(receipts.indexOf('balance'), -1);
      final invoices = table(spec, 'Invoices');
      expect(invoices.rows.single[invoices.indexOf('detail')].text, 'Unpaid');
      expect(invoices.rows.single[invoices.indexOf('balance')].raw, 300);
      final account = table(spec, 'Account Transactions');
      expect(
        [for (final r in account.rows) r[account.indexOf('amount')].text],
        containsAll(['+₦40.00', '-₦15.00']),
      );
      expect(
        [for (final r in account.rows) r[account.indexOf('detail')].text],
        containsAll(['Credit', 'Debit']),
      );
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
      expect(info['Period'], 'All time');
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

  group('Customer Analysis screen', () {
    for (final desktop in [true, false]) {
      testWidgets('shows the Export pill (${desktop ? 'desktop' : 'mobile'})', (
        tester,
      ) async {
        await pumpCustomerAnalysis(
          tester,
          isDesktop: desktop,
          customer: bola,
          env: fakeCustomerEnv(customers: [bola]),
        );
        // Beside the period button at every width (no "View" toggle).
        expect(find.text('Export'), findsOneWidget);
      });
    }
  });
}
