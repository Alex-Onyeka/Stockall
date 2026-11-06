import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/pages/report/components/export/report_export_format.dart';
import 'package:stockall/pages/report/components/export/report_export_resolve.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/export/report_pdf_builder.dart';
import 'package:stockall/pages/report/components/export/report_roll_builder.dart';
import 'package:stockall/pages/report/customer_report/customer_report_table/class/customer_ledger_export_spec.dart';
import 'package:stockall/pages/report/customer_report/customer_report_table/class/customer_report_table_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/services/printing/escpos_builder.dart' show fontBDots;

import 'customer_report_fixtures.dart';
import 'item_history_export_fixtures.dart' show testCtx;

// Bola's ledger: a ₦1,250,000 credit linked to a receipt, a debit by
// Ola with a comment, an entry with no staff; plus reward entries.
final receipts = [testReceipt(uuid: 'r-1000000000001', cash: 100)];

final ledger = [
  ledgerEntry(
    uuid: 'a-1',
    amount: 1250000,
    oldBalance: 0,
    newBalance: 1250000,
    receiptUuid: 'r-1000000000001',
    createdAt: DateTime(2026, 10, 15, 9),
  ),
  ledgerEntry(
    uuid: 'a-2',
    isAdd: false,
    amount: 200,
    comment: 'Refund',
    staffId: 'staff-b',
    staffName: 'Ola',
    createdAt: DateTime(2026, 10, 16, 9),
  ),
  ledgerEntry(
    uuid: 'a-3',
    amount: 50,
    staffId: null,
    staffName: null,
    createdAt: DateTime(2026, 10, 17, 9),
  ),
  ledgerEntry(uuid: 'w-1', isBalance: false, amount: 30, createdAt: DateTime(2026, 10, 14)),
  ledgerEntry(uuid: 'w-2', isBalance: false, isAdd: false, amount: 10),
];

CustomerReportBase base() =>
    buildBase(receipts: receipts, ledger: ledger);

List<CustomerLedgerRow> query(
  CustomerLedgerKind kind, {
  CustomerLedgerFilters? filters,
  CustomerReportBase? b,
}) => CustomerLedgerQuery.filterAndSort(
  base: b ?? base(),
  customerUuid: 'cust-1',
  kind: kind,
  period: allTime,
  filters: filters ?? CustomerLedgerFilters(),
  sortField: CustomerLedgerSortField.createdAt,
  ascending: false,
);

ReportExportSpec specFor(
  CustomerLedgerKind kind, {
  CustomerLedgerFilters? filters,
  ReceiptsReportPeriod period = allTime,
  List<CustomerLedgerRow>? rows,
}) {
  final f = filters ?? CustomerLedgerFilters();
  return customerLedgerExportSpec(
    kind: kind,
    customerName: 'Bola',
    rows: rows ?? query(kind, filters: f),
    filters: f,
    staffOptions: CustomerLedgerOptions.staff(query(kind)),
    sortField: CustomerLedgerSortField.createdAt,
    ascending: false,
    period: period,
    currency: '₦',
  );
}

ResolvedTable tableOf(ReportExportSpec spec) =>
    resolveExport(spec, testCtx).tables.single;

List<String> col(ResolvedTable t, String id) => [
  for (final r in t.rows) r[t.indexOf(id)].text,
];

void main() {
  const account = CustomerLedgerKind.account;
  const reward = CustomerLedgerKind.reward;

  group('rows are the screen query, every page', () {
    test('150 entries: every row, in the screen order', () {
      final many = buildBase(
        ledger: [
          for (var i = 0; i < 150; i++)
            ledgerEntry(
              uuid: 'e-$i',
              amount: 1.0 + i,
              createdAt: DateTime(2026, 10, 1).add(Duration(hours: i)),
            ),
        ],
      );
      final rows = query(account, b: many);
      final t = tableOf(specFor(account, rows: rows));
      expect(t.rows, hasLength(150));
      expect(col(t, 'amount'), [
        for (final r in rows) customerLedgerSigned(r.signedAmount, ExportFormatter(currency: '₦')),
      ]);
    });
  });

  group('columns and cells', () {
    test('as on screen; Comment only on Account Transactions', () {
      expect([for (final c in tableOf(specFor(account)).columns) c.label], [
        'Date',
        'Time',
        'Title',
        'Type',
        'Amount',
        'Old Balance',
        'New Balance',
        'Staff',
        'Comment',
        'Linked Receipt',
      ]);
      expect(tableOf(specFor(reward)).indexOf('comment'), -1);
    });

    test('signed amounts, old / new balance, staff, linked receipt', () {
      final t = tableOf(specFor(account));
      final credit = t.rows.firstWhere((r) => r[t.indexOf('amount')].text == '+₦1,250,000.00');
      expect(credit[t.indexOf('type')].text, 'Credit');
      expect(credit[t.indexOf('oldBalance')].text, '₦0.00');
      expect(credit[t.indexOf('newBalance')].text, '₦1,250,000.00');
      expect(credit[t.indexOf('receipt')].text, '#1000000000001');
      final debit = t.rows.firstWhere((r) => r[t.indexOf('amount')].text == '-₦200.00');
      expect(debit[t.indexOf('amount')].raw, -200);
      expect(debit[t.indexOf('type')].text, 'Debit');
      expect(debit[t.indexOf('staff')].text, 'Ola');
      expect(debit[t.indexOf('comment')].text, 'Refund');
      expect(debit[t.indexOf('oldBalance')].text, '—');
      expect(debit[t.indexOf('receipt')].text, '—');
      final noStaff = t.rows.firstWhere((r) => r[t.indexOf('amount')].text == '+₦50.00');
      expect(noStaff[t.indexOf('staff')].text, 'Not Set');
      expect(col(tableOf(specFor(reward)), 'type'), containsAll(['Earned', 'Redeemed']));
    });
  });

  group('totals', () {
    test('equal the totals bar: count, credits / debits, net', () {
      final t0 = CustomerLedgerQuery.paginate(query(account), 1).totals;
      final t = tableOf(specFor(account));
      expect(t.totals![t.indexOf('date')].text, '3 entries');
      expect(t.totals![t.indexOf('title')].text, 'Credits ₦1,250,050.00 · Debits ₦200.00');
      expect(t.totals![t.indexOf('amount')].text, '+₦1,249,850.00');
      expect(t0.net, 1249850);
      final r = tableOf(specFor(reward));
      expect(r.totals![r.indexOf('title')].text, 'Earned ₦30.00 · Redeemed ₦10.00');
      expect(r.totals![r.indexOf('amount')].text, '+₦20.00');
    });
  });

  group('splits', () {
    final f = ExportFormatter(currency: '₦');
    List<String> names(CustomerLedgerKind kind, String id) => [
      for (final g in resolveGroups(specFor(kind).tables.single, id, f)) g.name,
    ];

    test('Type and Staff, "No Staff" last', () {
      expect(specFor(account).splitOptions.map((s) => s.id), ['type', 'staff']);
      expect(names(account, 'type'), ['Credit', 'Debit']);
      expect(names(reward, 'type'), ['Earned', 'Redeemed']);
      expect(names(account, 'staff'), ['Ada', 'Ola', 'No Staff']);
    });

    test('a split sheet gets its own totals', () {
      final debits = resolveGroups(specFor(account).tables.single, 'type', f)
          .firstWhere((g) => g.name == 'Debit')
          .table;
      expect(debits.totals![debits.indexOf('amount')].text, '-₦200.00');
    });
  });

  group('info box and notes', () {
    test('the customer, filters worded like the chips, sort', () {
      final filters = CustomerLedgerFilters(
        search: 'ref',
        direction: CustomerLedgerDirection.deducted,
        staffKey: 'staff-b',
        amountMin: 100,
      );
      final spec = specFor(account, filters: filters);
      expect([for (final x in spec.filters) '${x.label}: ${x.value}'], [
        'Customer: Bola',
        'Search: ref',
        'Type: Debit',
        'Staff: Ola',
        'Amount: ₦100.00 - Any',
      ]);
      expect(spec.sortedBy, 'Date (descending)');
      expect(spec.reportName, 'Account Transactions');
      expect(specFor(reward).reportName, 'Reward Earnings');
      expect(specFor(reward).fileSlug, 'customer_reward_earnings');
    });

    test('the All time note exactly when the screen shows it', () {
      final all = specFor(account);
      expect(all.notes, ['All time covers the data loaded on this device.']);
      final info = {
        for (final e in reportPdfInfoEntries(resolveExport(all, testCtx))) e.$1: e.$2,
      };
      expect(info['Notes'], all.notes.single);
      expect(
        specFor(account, period: ReceiptsReportPeriod.day(DateTime(2026, 10, 17))).notes,
        isEmpty,
      );
    });
  });

  group('roll', () {
    String preview(RollPaper paper) => renderRollEscPos(
      buildRollLines(specFor(account), testCtx, paper: paper),
      paper,
    ).preview;

    test('58mm: Title · ±Amount, date underneath', () {
      final out = preview(RollPaper.mm58).split('\n');
      final i = out.indexWhere((l) => l.endsWith('+N1,250,000.00'));
      expect(i, greaterThan(0));
      // "Account Credited" wraps under the amount; the date follows.
      expect(out.sublist(i + 1, i + 3).map((l) => l.trim()), contains('Oct 15, 2026'));
      expect(out.every((l) => l.length <= RollPaper.mm58.dots ~/ fontBDots), isTrue);
    });

    test('80mm: Title · Type · ±Amount', () {
      final out = preview(RollPaper.mm80).split('\n');
      final line = out.firstWhere((l) => l.endsWith('+N1,250,000.00'));
      expect(line, contains('Credit'));
      expect(out.where((l) => l.contains('.00')).every((l) => l.length <= 48), isTrue);
    });
  });

  group('Ledger screens', () {
    for (final kind in CustomerLedgerKind.values) {
      for (final desktop in [true, false]) {
        testWidgets('${kind.name}: shows the Export pill (${desktop ? 'desktop' : 'mobile'})', (
          tester,
        ) async {
          // pumpLedgerTable opens "View" on mobile.
          await pumpLedgerTable(
            tester,
            isDesktop: desktop,
            kind: kind,
            env: fakeCustomerEnv(receipts: receipts, ledger: ledger),
          );
          expect(find.text('Export'), findsOneWidget);
        });
      }
    }
  });
}
