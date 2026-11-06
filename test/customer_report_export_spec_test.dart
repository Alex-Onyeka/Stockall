import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/pages/report/components/export/report_export_resolve.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/export/report_pdf_builder.dart';
import 'package:stockall/pages/report/components/export/report_roll_builder.dart';
import 'package:stockall/pages/report/customer_report/customer_report_table/class/customer_report_export_spec.dart';
import 'package:stockall/pages/report/customer_report/customer_report_table/class/customer_report_table_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/services/printing/escpos_builder.dart' show fontBDots;

import 'customer_report_fixtures.dart';
import 'item_history_export_fixtures.dart' show testCtx;

// Bola (Abuja, Nigeria) with an account balance and reward earnings,
// a ₦1,250,000 sales receipt and an unpaid ₦300 invoice; Chidi with no
// contact details and no records.
final customers = [
  testCustomer(
    name: 'Bola',
    address: '2 Close',
    city: 'Abuja',
    country: 'Nigeria',
    balance: 500,
    cashReward: 20,
  ),
  testCustomer(uuid: 'cust-2', name: 'Chidi', phone: ''),
];

CustomerReportBase baseFor({CustomerReportAccess? access}) => buildBase(
  customers: customers,
  receipts: [testReceipt(uuid: 'r-1', cash: 1250000)],
  invoices: [testInvoice(uuid: 'i-1', total: 300)],
  access: access,
);

List<CustomerReportRow> query({
  CustomerReportAccess? access,
  CustomerReportFilters? filters,
  CustomerReportSortField sortField = CustomerReportSortField.name,
  bool ascending = true,
  List<CustomerReportRow>? rows,
}) {
  final a = access ?? testAccess();
  return CustomerReportQuery.filterAndSort(
    rows: rows ?? rowsOf(baseFor(access: a)),
    filters: filters ?? CustomerReportFilters(),
    sortField: sortField,
    ascending: ascending,
    access: a,
  );
}

ReportExportSpec specFor({
  CustomerReportAccess? access,
  CustomerReportFilters? filters,
  CustomerReportSortField sortField = CustomerReportSortField.name,
  ReceiptsReportPeriod period = allTime,
  List<CustomerReportRow>? rows,
}) {
  final a = access ?? testAccess();
  final all = rowsOf(baseFor(access: a));
  final f = filters ?? CustomerReportFilters();
  return customerReportExportSpec(
    rows: rows ?? query(access: a, filters: f, sortField: sortField),
    filters: f,
    countryOptions: CustomerReportOptions.countries(all),
    stateOptions: CustomerReportOptions.states(all, countryKey: f.countryKey),
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
    test('150 customers: every row, in the screen order', () {
      final base = buildBase(
        customers: [
          for (var i = 0; i < 150; i++)
            testCustomer(uuid: 'c-$i', name: 'Customer ${i.toString().padLeft(3, '0')}'),
        ],
      );
      final rows = query(rows: rowsOf(base));
      final t = tableOf(specFor(rows: rows));
      expect(t.rows, hasLength(150));
      expect([for (final r in t.rows) r[0].text], [for (final r in rows) r.name]);
      expect(CustomerReportQuery.paginate(rows, 1).rows, hasLength(100));
    });
  });

  group('column gates', () {
    test('account, reward and total balance with the setting and permission', () {
      expect(labels(tableOf(specFor())), [
        'Name',
        'Phone',
        'Address',
        'Account Balance',
        'Reward Earnings',
        'Total Balance',
        'Receipt Purchases',
        'Invoice Purchases',
        'Revenue',
        'Credit',
      ]);
      final noAccount = labels(tableOf(specFor(access: testAccess(manageCustomerAccount: false))));
      expect(noAccount, isNot(contains('Account Balance')));
      expect(noAccount, containsAll(['Reward Earnings', 'Total Balance']));
      final noView = labels(tableOf(specFor(access: testAccess(canViewCustomersAccount: false))));
      for (final c in ['Account Balance', 'Reward Earnings', 'Total Balance']) {
        expect(noView, isNot(contains(c)), reason: c);
      }
    });

    test('blanks "—", address in one column', () {
      final t = tableOf(specFor());
      final chidi = t.rows.firstWhere((r) => r[0].text == 'Chidi');
      expect(chidi[t.indexOf('phone')].text, '—');
      expect(chidi[t.indexOf('address')].text, '—');
      final bola = t.rows.firstWhere((r) => r[0].text == 'Bola');
      expect(bola[t.indexOf('address')].text, '2 Close, Abuja, Nigeria');
    });
  });

  group('totals', () {
    test('equal the CustomerReportTotals the screen shows', () {
      final t0 = CustomerReportQuery.paginate(query(), 1).totals;
      final t = tableOf(specFor());
      Object? total(String id) => t.totals![t.indexOf(id)].raw;
      expect(t.totals![0].text, '2 customers');
      expect(total('accountBalance'), t0.accountBalance);
      expect(total('rewardEarnings'), t0.rewardEarnings);
      expect(total('totalBalance'), t0.totalBalance);
      expect(total('receiptPurchases'), t0.receiptPurchases);
      expect(total('invoicePurchases'), t0.invoicePurchases);
      expect(total('revenue'), t0.revenue);
      expect(total('credit'), t0.credit);
      expect(t0.credit, 300);
    });

    test('no splits', () {
      expect(specFor().splitOptions, isEmpty);
    });
  });

  group('info box and notes', () {
    test('filters worded like the chips; the sort actually used', () {
      final filters = CustomerReportFilters(
        search: 'bo',
        countryKey: 'nigeria',
        hasCredit: true,
        hasAccountBalance: true,
      );
      final spec = specFor(filters: filters);
      expect([for (final x in spec.filters) '${x.label}: ${x.value}'], [
        'Search: bo',
        'Country: Nigeria',
        'Credit: Has credit',
        'Account: Has account balance',
      ]);
      // Without account access the chip (and filter) is off.
      final hidden = specFor(
        filters: filters,
        access: testAccess(canViewCustomersAccount: false),
      );
      expect(hidden.filters.map((x) => x.label), isNot(contains('Account')));
      // A hidden column's sort falls back to name, as the table does.
      expect(
        specFor(
          sortField: CustomerReportSortField.accountBalance,
          access: testAccess(manageCustomerAccount: false),
        ).sortedBy,
        'Name (ascending)',
      );
      expect(specFor(sortField: CustomerReportSortField.revenue).sortedBy, 'Revenue (ascending)');
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

    test('58mm: Name · Revenue', () {
      final out = preview(RollPaper.mm58).split('\n');
      expect(out.firstWhere((l) => l.startsWith('Bola')), endsWith('N1,250,000.00'));
      expect(out.every((l) => l.length <= RollPaper.mm58.dots ~/ fontBDots), isTrue);
    });

    test('80mm: Name · Revenue · Credit', () {
      final out = preview(RollPaper.mm80).split('\n');
      final bola = out.firstWhere((l) => l.startsWith('Bola'));
      expect(bola, contains('N1,250,000.00'));
      expect(bola, endsWith('N300.00'));
      expect(out.where((l) => l.contains('.00')).every((l) => l.length <= 48), isTrue);
    });
  });

  group('Customer table screen', () {
    for (final desktop in [true, false]) {
      testWidgets('shows the Export pill (${desktop ? 'desktop' : 'mobile'})', (
        tester,
      ) async {
        // pumpCustomerTable opens "View" on mobile.
        await pumpCustomerTable(
          tester,
          isDesktop: desktop,
          env: fakeCustomerEnv(customers: customers),
        );
        expect(find.text('Export'), findsOneWidget);
      });
    }
  });
}
