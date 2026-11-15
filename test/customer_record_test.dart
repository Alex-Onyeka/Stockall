import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/pages/customers/customer_details_page/components/customer_record_data.dart';
import 'package:stockall/pages/report/components/export/report_export_resolve.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/export/report_roll_builder.dart';
import 'package:stockall/pages/report/customer_report/customer_report_table/class/customer_report_table_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

import 'customer_report_fixtures.dart';
import 'item_history_export_fixtures.dart' show testCtx;

// The customer page's Print Record: the Customer Analysis export with
// every record, and nothing of a hidden account or reward part.

final bola = testCustomer(
  address: '2 Close',
  city: 'Abuja',
  country: 'Nigeria',
  balance: 500,
  cashReward: 20,
);

/// Seven sales receipts (more than the analysis page's 5), an
/// invoice payment, an unpaid invoice, an order, two account entries
/// and a reward entry.
CustomerReportBase baseFor(CustomerReportAccess access) => buildBase(
  customers: [bola],
  receipts: [
    for (var i = 1; i <= 7; i++)
      testReceipt(
        uuid: 'r-100000000000$i',
        cash: 100.0 * i,
        createdAt: DateTime(2026, 10, 10 + i, 12),
      ),
    invoicePayment(
      uuid: 'p-4000000000001',
      invoiceUuid: 'i-2000000000002',
      cash: 50,
    ),
  ],
  invoices: [testInvoice(uuid: 'i-2000000000001', total: 300)],
  orders: [customerOrder(uuid: 'o-3000000000001', total: 80)],
  ledger: [
    ledgerEntry(uuid: 'a-1', amount: 40),
    ledgerEntry(
      uuid: 'a-2',
      isAdd: false,
      amount: 15,
      createdAt: DateTime(2026, 10, 16),
    ),
    ledgerEntry(uuid: 'w-1', isBalance: false, amount: 30),
  ],
  access: access,
);

ReportExportSpec specFor({
  CustomerReportAccess? access,
  ReceiptsReportPeriod? period,
}) => customerRecordSpec(
  base: baseFor(access ?? testAccess()),
  customer: bola,
  currency: '₦',
  period: period,
);

ResolvedExport resolved(ReportExportSpec s) => resolveExport(s, testCtx);

List<String> titles(ReportExportSpec s) => [
  for (final x in s.sections) x.title.split(' (').first,
];

Map<String, ResolvedMetric> statistics(ReportExportSpec s) => {
  for (final m
      in resolved(s)
          .sections
          .whereType<ResolvedSummary>()
          .firstWhere((x) => x.title == 'Statistics')
          .metrics)
    m.label: m,
};

ResolvedTable table(ReportExportSpec s, String prefix) =>
    resolved(s).tables.firstWhere((t) => t.title.startsWith(prefix));

/// Every word the PDF and Excel builders read: titles, metric labels,
/// values and notes, column labels and cells.
String documentText(ReportExportSpec s) {
  final r = resolved(s);
  final out = StringBuffer();
  for (final section in r.sections) {
    out.writeln(section.title);
    if (section is ResolvedSummary) {
      for (final m in section.metrics) {
        out.writeln('${m.label} ${m.text} ${m.note ?? ''}');
      }
    } else if (section is ResolvedTable) {
      out.writeln([for (final c in section.columns) c.label].join(' '));
      for (final row in section.rows) {
        out.writeln([for (final c in row) c.text].join(' '));
      }
      if (section.totals != null) {
        out.writeln([for (final c in section.totals!) c.text].join(' '));
      }
    }
  }
  return out.toString();
}

/// What a roll print shows.
String rollText(ReportExportSpec s) => renderRollEscPos(
  buildRollLines(s, testCtx, paper: RollPaper.mm80),
  RollPaper.mm80,
).preview;

void main() {
  group('the document', () {
    test('is the Customer Analysis export, named for the customer', () {
      final s = specFor();
      expect(s.reportName, 'Customer Analysis');
      expect(s.fileSlug, 'customer_analysis');
      expect({for (final f in s.filters) f.label: f.value}, {
        'Customer': 'Bola',
      });
      expect(titles(s), [
        'Contact Details',
        'Statistics',
        'Receipts',
        'Invoices',
        'Orders',
        'Reward Earnings',
        'Account Transactions',
      ]);
    });

    test('every record of the period, not the latest 5', () {
      final s = specFor();
      final receipts = table(s, 'Receipts');
      expect(receipts.title, 'Receipts (8 of 8 in this period)');
      expect(receipts.rows, hasLength(8));
      final details = [
        for (final r in receipts.rows) r[receipts.indexOf('detail')].text,
      ];
      expect(details, contains('Invoice Payment'));
      expect(details.where((d) => d == 'Sales'), hasLength(7));
      expect(table(s, 'Account Transactions').rows, hasLength(2));
      expect(table(s, 'Reward Earnings').rows, hasLength(1));
      final invoices = table(s, 'Invoices');
      expect(invoices.rows.single[invoices.indexOf('balance')].raw, 300);
    });

    test('current balances from the customer', () {
      final m = statistics(specFor());
      expect(m['Account Balance']!.raw, 500);
      expect(m['Reward Earnings']!.raw, 20);
      expect(m['Total Balance']!.raw, 520);
    });
  });

  group('period', () {
    test('All time with View Date', () {
      final s = specFor();
      expect(s.period!.label, 'All time');
      expect(s.notes, ['All time covers the data loaded on this device.']);
    });

    test('today without View Date', () {
      final s = specFor(access: testAccess(canPickDate: false));
      expect(s.period!.label, isNot('All time'));
      expect(s.period!.start, isNotNull);
      expect(s.notes, isEmpty);
    });

    test('a given period limits every section', () {
      final s = specFor(period: ReceiptsReportPeriod.day(DateTime(2026, 10, 17)));
      expect(table(s, 'Receipts').rows, hasLength(2));
      expect(table(s, 'Account Transactions').rows, hasLength(1));
    });
  });

  group('hidden parts appear nowhere', () {
    test('account off: no account section, figure or rows', () {
      final s = specFor(access: testAccess(manageCustomerAccount: false));
      expect(titles(s), isNot(contains('Account Transactions')));
      expect(titles(s), contains('Reward Earnings'));
      final m = statistics(s);
      expect(m.containsKey('Account Balance'), isFalse);
      expect(m['Total Balance']!.raw, 20);
      for (final text in [documentText(s), rollText(s)]) {
        expect(text, isNot(contains('Account')));
      }
    });

    test('reward off: no reward section, figure or rows', () {
      final s = specFor(access: testAccess(manageCustomerReward: false));
      expect(titles(s), isNot(contains('Reward Earnings')));
      expect(titles(s), contains('Account Transactions'));
      final m = statistics(s);
      expect(m.containsKey('Reward Earnings'), isFalse);
      expect(m['Total Balance']!.raw, 500);
      for (final text in [documentText(s), rollText(s)]) {
        expect(text, isNot(contains('Reward')));
        expect(text, isNot(contains('Earned')));
      }
    });

    for (final (name, access) in [
      (
        'both off',
        testAccess(manageCustomerAccount: false, manageCustomerReward: false),
      ),
      ('no View Customers Account', testAccess(canViewCustomersAccount: false)),
    ]) {
      test('$name: no balance, account or reward anywhere', () {
        final s = specFor(access: access);
        expect(titles(s), [
          'Contact Details',
          'Statistics',
          'Receipts',
          'Invoices',
          'Orders',
        ]);
        final m = statistics(s);
        for (final k in ['Account Balance', 'Reward Earnings', 'Total Balance']) {
          expect(m.containsKey(k), isFalse, reason: k);
        }
        for (final text in [documentText(s), rollText(s)]) {
          expect(text, isNot(contains('Account')));
          expect(text, isNot(contains('Reward')));
          expect(text, isNot(contains('Total Balance')));
        }
      });
    }
  });
}
