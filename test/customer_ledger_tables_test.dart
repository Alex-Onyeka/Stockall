import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/temp_customer_account_receipts/customer_account_receipts.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/pages/report/customer_report/customer_account_transactions/class/customer_account_transactions_logic.dart';
import 'package:stockall/pages/report/customer_report/customer_analysis/class/customer_analysis_logic.dart';
import 'package:stockall/pages/report/customer_report/customer_report_table/class/customer_report_table_logic.dart';
import 'package:stockall/pages/report/customer_report/customer_report_table/components/customer_report_table_view.dart';
import 'package:stockall/pages/report/customer_report/customer_reward_earnings/class/customer_reward_earnings_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/components/receipts_report_filter_widgets.dart';

import 'customer_report_fixtures.dart';

void main() {
  final receipts = [testReceipt(uuid: 'rec-1', barcode: '555', cash: 100)];
  final ledger = [
    // Reward: earned 5 + 3, redeemed 4.
    ledgerEntry(
      uuid: 'rew-1',
      isBalance: false,
      amount: 5,
      receiptUuid: 'rec-1',
      createdAt: DateTime(2026, 10, 15, 12),
      newBalance: 5,
    ),
    ledgerEntry(
      uuid: 'rew-2',
      isBalance: false,
      amount: 3,
      createdAt: DateTime(2026, 10, 16, 12),
      newBalance: 8,
    ),
    ledgerEntry(
      uuid: 'rew-3',
      isBalance: false,
      isAdd: false,
      amount: 4,
      title: 'Reward Redeemed',
      createdAt: DateTime(2026, 10, 17, 12),
      newBalance: 4,
    ),
    // Account: credit 100, debit 30 at checkout, debit 20 by hand.
    ledgerEntry(
      uuid: 'acc-1',
      amount: 100,
      comment: 'Cash deposit',
      createdAt: DateTime(2026, 10, 15, 9),
      newBalance: 100,
    ),
    ledgerEntry(
      uuid: 'acc-2',
      isAdd: false,
      amount: 30,
      receiptUuid: 'rec-1',
      staffName: 'Zed',
      createdAt: DateTime(2026, 10, 16, 9),
      newBalance: 70,
    ),
    ledgerEntry(
      uuid: 'acc-3',
      isBalance: null,
      isAdd: false,
      amount: 20,
      createdAt: DateTime(2026, 10, 18, 3, 30),
      newBalance: null,
    ),
    // Another customer's entries are never shown.
    ledgerEntry(uuid: 'rew-x', customerUuid: 'cust-2', isBalance: false),
    ledgerEntry(uuid: 'acc-x', customerUuid: 'cust-2'),
  ];
  final base = buildBase(receipts: receipts, ledger: ledger);

  List<CustomerLedgerRow> rewards({
    ReceiptsReportPeriod period = allTime,
    CustomerLedgerFilters? filters,
    CustomerLedgerSortField sortField = CustomerLedgerSortField.createdAt,
    bool ascending = false,
    TimeOfDay? closingTime,
    CustomerReportBase? from,
  }) => CustomerRewardEarningsTable.filterAndSort(
    base: from ?? base,
    customerUuid: 'cust-1',
    period: period,
    filters: filters ?? CustomerLedgerFilters(),
    sortField: sortField,
    ascending: ascending,
    closingTime: closingTime,
  );

  List<CustomerLedgerRow> account({
    ReceiptsReportPeriod period = allTime,
    CustomerLedgerFilters? filters,
    CustomerLedgerSortField sortField = CustomerLedgerSortField.createdAt,
    bool ascending = false,
    TimeOfDay? closingTime,
  }) => CustomerAccountTransactionsTable.filterAndSort(
    base: base,
    customerUuid: 'cust-1',
    period: period,
    filters: filters ?? CustomerLedgerFilters(),
    sortField: sortField,
    ascending: ascending,
    closingTime: closingTime,
  );

  group('Rows', () {
    test('reward is isBalance false; account is true or null', () {
      expect(rewards().map((r) => r.uuid), ['rew-3', 'rew-2', 'rew-1']);
      expect(account().map((r) => r.uuid), ['acc-3', 'acc-2', 'acc-1']);
    });

    test('stored titles are kept, missing ones defaulted', () {
      final r = {for (final row in rewards()) row.uuid: row};
      expect(r['rew-1']!.title, 'Reward Earned');
      expect(r['rew-3']!.title, 'Reward Redeemed');
      final a = {for (final row in account()) row.uuid: row};
      expect(a['acc-1']!.title, 'Account Credited');
      expect(a['acc-2']!.title, 'Account Debited');
      expect(
        CustomerLedgerRow.defaultTitle(
          ledgerEntry(uuid: 'x', isBalance: false, isAdd: false),
        ),
        'Reward Deducted',
      );
    });

    test('direction labels and signed amounts', () {
      final r = {for (final row in rewards()) row.uuid: row};
      expect(CustomerRewardEarningsTable.directionLabel(r['rew-1']!), 'Earned');
      expect(
        CustomerRewardEarningsTable.directionLabel(r['rew-3']!),
        'Redeemed',
      );
      expect(r['rew-3']!.signedAmount, -4);
      final a = {for (final row in account()) row.uuid: row};
      expect(
        CustomerAccountTransactionsTable.directionLabel(a['acc-1']!),
        'Credit',
      );
      expect(
        CustomerAccountTransactionsTable.directionLabel(a['acc-2']!),
        'Debit',
      );
      expect(a['acc-2']!.signedAmount, -30);
    });

    test('the receipt that wrote an entry is named by its id', () {
      final a = {for (final row in account()) row.uuid: row};
      expect(a['acc-2']!.receiptDisplayId, '#555');
      expect(a['acc-1']!.receiptDisplayId, isNull);
    });
  });

  group('Totals', () {
    test('reward: earned, redeemed, net', () {
      final p = CustomerRewardEarningsTable.page(
        base: base,
        customerUuid: 'cust-1',
        period: allTime,
        filters: CustomerLedgerFilters(),
      );
      expect(p.totals.count, 3);
      expect(p.totals.earned, 8);
      expect(p.totals.redeemed, 4);
      expect(p.totals.net, 4);
    });

    test('account: credits, debits, net', () {
      final p = CustomerAccountTransactionsTable.page(
        base: base,
        customerUuid: 'cust-1',
        period: allTime,
        filters: CustomerLedgerFilters(),
      );
      expect(p.totals.count, 3);
      expect(p.totals.credits, 100);
      expect(p.totals.debits, 50);
      expect(p.totals.net, 50);
    });

    test('totals follow the filters', () {
      final p = CustomerAccountTransactionsTable.page(
        base: base,
        customerUuid: 'cust-1',
        period: allTime,
        filters: CustomerLedgerFilters(
          direction: CustomerLedgerDirection.deducted,
        ),
      );
      expect(p.totals.count, 2);
      expect(p.totals.credits, 0);
      expect(p.totals.debits, 50);
      expect(p.totals.net, -50);
    });
  });

  group('Filters', () {
    test('direction', () {
      expect(
        rewards(
          filters: CustomerLedgerFilters(
            direction: CustomerLedgerDirection.added,
          ),
        ).map((r) => r.uuid),
        ['rew-2', 'rew-1'],
      );
    });

    test('search: title, comment, staff, receipt id', () {
      List<String> find(String q) =>
          account(
            filters: CustomerLedgerFilters(search: q),
          ).map((r) => r.uuid).toList();
      expect(find('credited'), ['acc-1']);
      expect(find('deposit'), ['acc-1']);
      expect(find('zed'), ['acc-2']);
      expect(find('555'), ['acc-2']);
      expect(find(' ').length, 3);
    });

    test('count, copy and Reset All', () {
      final f = CustomerLedgerFilters(
        search: 'x',
        direction: CustomerLedgerDirection.added,
      );
      expect(f.activeCount, 1);
      expect(f.hasAnything, isTrue);
      final copy = f.copy();
      f.clearAll();
      expect(f.hasAnything, isFalse);
      expect(copy.direction, CustomerLedgerDirection.added);
    });
  });

  group('Sorting', () {
    test('amount is signed', () {
      expect(
        account(
          sortField: CustomerLedgerSortField.amount,
          ascending: true,
        ).map((r) => r.uuid),
        ['acc-2', 'acc-3', 'acc-1'],
      );
    });

    test('a missing new balance sinks in both directions', () {
      for (final asc in [true, false]) {
        expect(
          account(
            sortField: CustomerLedgerSortField.newBalance,
            ascending: asc,
          ).last.uuid,
          'acc-3',
        );
      }
    });

    test('oldest first', () {
      expect(rewards(ascending: true).map((r) => r.uuid), [
        'rew-1',
        'rew-2',
        'rew-3',
      ]);
    });

    test('staff and title', () {
      expect(
        account(
          sortField: CustomerLedgerSortField.staff,
          ascending: false,
        ).first.uuid,
        'acc-2',
      );
      expect(
        rewards(
          sortField: CustomerLedgerSortField.title,
          ascending: true,
        ).first.title,
        'Reward Earned',
      );
    });
  });

  group('Period', () {
    const closing = TimeOfDay(hour: 4, minute: 0);

    test('a business day runs to the closing time', () {
      final day17 = ReceiptsReportPeriod.day(DateTime(2026, 10, 17));
      expect(account(period: day17, closingTime: closing).map((r) => r.uuid), [
        'acc-3',
      ]);
      expect(rewards(period: day17, closingTime: closing).map((r) => r.uuid), [
        'rew-3',
      ]);
    });

    test('a range', () {
      expect(
        rewards(
          period: ReceiptsReportPeriod.range(
            DateTime(2026, 10, 15),
            DateTime(2026, 10, 16),
          ),
        ).map((r) => r.uuid),
        ['rew-2', 'rew-1'],
      );
    });

    test('an undated entry shows for All time only, last', () {
      final undated = ledgerEntry(uuid: 'rew-u', isBalance: false);
      undated.createdAt = null;
      final b = buildBase(ledger: [...ledger, undated]);
      expect(rewards(from: b).last.uuid, 'rew-u');
      expect(
        rewards(
          from: b,
          period: ReceiptsReportPeriod.day(DateTime(2026, 10, 17)),
        ).map((r) => r.uuid),
        ['rew-3'],
      );
    });
  });

  group('Scope and settings', () {
    test('own entries only without View All Transactions', () {
      final b = buildBase(
        ledger: [
          ledgerEntry(uuid: 'mine'),
          ledgerEntry(uuid: 'theirs', staffId: 'staff-b'),
        ],
        access: testAccess(canViewAllTransactions: false),
      );
      expect(
        CustomerAccountTransactionsTable.filterAndSort(
          base: b,
          customerUuid: 'cust-1',
          period: allTime,
          filters: CustomerLedgerFilters(),
        ).map((r) => r.uuid),
        ['mine'],
      );
    });

    test('a hidden ledger has no rows', () {
      final b = buildBase(
        ledger: ledger,
        access: testAccess(manageCustomerReward: false),
      );
      expect(rewards(from: b), isEmpty);
      expect(
        CustomerAccountTransactionsTable.filterAndSort(
          base: b,
          customerUuid: 'cust-1',
          period: allTime,
          filters: CustomerLedgerFilters(),
        ).length,
        3,
      );
    });
  });

  group('Paging', () {
    test('100 per page, totals over every page', () {
      final b = buildBase(
        ledger: [
          for (var i = 0; i < 150; i++)
            ledgerEntry(
              uuid: 'e-${i.toString().padLeft(3, '0')}',
              isAdd: i.isEven,
              amount: 2,
              createdAt: DateTime(2026, 10, 1).add(Duration(hours: i)),
            ),
        ],
      );
      final p1 = CustomerAccountTransactionsTable.page(
        base: b,
        customerUuid: 'cust-1',
        period: allTime,
        filters: CustomerLedgerFilters(),
      );
      final p2 = CustomerAccountTransactionsTable.page(
        base: b,
        customerUuid: 'cust-1',
        period: allTime,
        filters: CustomerLedgerFilters(),
        page: 5,
      );
      expect(p1.rows.length, 100);
      expect(p1.totalPages, 2);
      expect(p2.page, 2);
      expect(p2.rows.length, 50);
      expect(p2.firstIndex, 101);
      for (final p in [p1, p2]) {
        expect(p.totals.count, 150);
        expect(p.totals.credits, 150);
        expect(p.totals.debits, 150);
        expect(p.totals.net, 0);
      }
    });
  });

  group('Staff, amount and the new sorts', () {
    final b = buildBase(
      receipts: receipts,
      ledger: [
        ledgerEntry(
          uuid: 'a',
          amount: 5,
          staffId: 'staff-a',
          staffName: 'Ada',
          oldBalance: 10,
          comment: 'zinc',
          receiptUuid: 'rec-1',
          createdAt: DateTime(2026, 10, 15),
        ),
        ledgerEntry(
          uuid: 'b',
          isAdd: false,
          amount: 2,
          staffId: 'staff-b',
          staffName: 'Old name',
          oldBalance: null,
          comment: null,
          receiptUuid: 'missing',
          createdAt: DateTime(2026, 10, 14),
        ),
        ledgerEntry(
          uuid: 'c',
          amount: 9,
          staffId: 'staff-b',
          staffName: 'Bisi',
          oldBalance: 3,
          comment: 'apple',
          createdAt: DateTime(2026, 10, 16),
        ),
        ledgerEntry(
          uuid: 'd',
          amount: 1,
          staffId: null,
          staffName: null,
          oldBalance: 7,
          createdAt: DateTime(2026, 10, 13),
        ),
      ],
    );
    List<String> run({
      CustomerLedgerFilters? filters,
      CustomerLedgerSortField sortField = CustomerLedgerSortField.createdAt,
      bool ascending = false,
    }) =>
        CustomerAccountTransactionsTable.filterAndSort(
          base: b,
          customerUuid: 'cust-1',
          period: allTime,
          filters: filters ?? CustomerLedgerFilters(),
          sortField: sortField,
          ascending: ascending,
        ).map((r) => r.uuid).toList();

    test('staff filter', () {
      expect(run(filters: CustomerLedgerFilters(staffKey: 'staff-b')), [
        'c',
        'b',
      ]);
    });

    test('amount range on the unsigned amount', () {
      expect(run(filters: CustomerLedgerFilters(amountMin: 2, amountMax: 5)), [
        'a',
        'b',
      ]);
      expect(run(filters: CustomerLedgerFilters(amountMax: 1)), ['d']);
    });

    test('an invalid amount range is not applied', () {
      final f = CustomerLedgerFilters(amountMin: 10, amountMax: 1);
      expect(f.amountRangeError, isNotNull);
      expect(run(filters: f).length, 4);
      expect(CustomerLedgerFilters(amountMin: 1).amountRangeError, isNull);
    });

    test('count, copy and Reset All cover the new fields', () {
      final f = CustomerLedgerFilters(
        search: 'x',
        direction: CustomerLedgerDirection.added,
        staffKey: 'staff-a',
        amountMin: 1,
      );
      expect(f.activeCount, 3);
      final copy = f.copy();
      f.clearAll();
      expect(f.hasAnything, isFalse);
      expect(f.staffKey, isNull);
      expect(f.amountMin, isNull);
      expect(copy.staffKey, 'staff-a');
      expect(copy.amountMin, 1);
      expect(copy.activeCount, 3);
    });

    test('type, old balance, comment and receipt sorts', () {
      expect(
        run(sortField: CustomerLedgerSortField.direction, ascending: true),
        ['c', 'a', 'd', 'b'],
      );
      expect(
        run(sortField: CustomerLedgerSortField.oldBalance, ascending: true),
        ['c', 'd', 'a', 'b'],
      );
      expect(run(sortField: CustomerLedgerSortField.oldBalance), [
        'a',
        'd',
        'c',
        'b',
      ]);
      expect(run(sortField: CustomerLedgerSortField.comment, ascending: true), [
        'c',
        'a',
        'b',
        'd',
      ]);
      // Only a has a loaded receipt; the rest sink either way.
      expect(
        run(sortField: CustomerLedgerSortField.receipt, ascending: true).first,
        'a',
      );
      expect(run(sortField: CustomerLedgerSortField.receipt).first, 'a');
    });

    test('staff options: newest name, sorted, no blank staff', () {
      final options = CustomerLedgerOptions.staff(b.ledgerRows);
      expect(options.map((o) => o.key), ['staff-a', 'staff-b']);
      expect(options.map((o) => o.label), ['Ada', 'Bisi']);
    });

    test('the receipt link is set only when the receipt is loaded', () {
      final rows = {for (final r in b.ledgerRows) r.uuid: r};
      expect(rows['a']!.receipt?.uuid, 'rec-1');
      expect(rows['a']!.receiptDisplayId, '#555');
      expect(rows['b']!.receipt, isNull);
      expect(rows['b']!.receiptDisplayId, isNull);
    });
  });

  group('Ledger screen', () {
    // Money shows as 'N<value>' (fakeCustomerEnv). rew-4 links to a
    // receipt that is not loaded.
    final screenLedger = [
      ...ledger,
      ledgerEntry(
        uuid: 'rew-4',
        isBalance: false,
        amount: 1,
        receiptUuid: 'not-loaded',
        createdAt: DateTime(2026, 10, 14, 12),
      ),
    ];
    final range = ReceiptsReportPeriod.range(
      DateTime(2026, 10, 14),
      DateTime(2026, 10, 16),
    );

    CustomerReportEnv env({
      CustomerReportAccess? access,
      CustomerEnvLog? log,
      List<CustomerAccountReceipts>? entries,
      bool pushLedgerTables = false,
    }) => fakeCustomerEnv(
      receipts: [...receipts],
      ledger: entries ?? [...screenLedger],
      access: access,
      log: log,
      pushLedgerTables: pushLedgerTables,
    );

    String totalText(WidgetTester tester, String id) =>
        tester.widget<Text>(find.byKey(ValueKey('ledger-total-$id'))).data!;

    Finder row(String uuid) => find.byKey(ValueKey('ledger-row-$uuid'));

    for (final isDesktop in [true, false]) {
      final width = isDesktop ? 'desktop' : 'mobile';

      testWidgets('each table shows only its own kind ($width)', (
        tester,
      ) async {
        await pumpLedgerTable(
          tester,
          isDesktop: isDesktop,
          env: env(),
          kind: CustomerLedgerKind.reward,
        );
        expect(find.text('Bola: Reward Earnings'), findsOneWidget);
        for (final u in ['rew-1', 'rew-2', 'rew-3', 'rew-4']) {
          expect(row(u), findsOneWidget, reason: u);
        }
        for (final u in ['acc-1', 'acc-2', 'acc-3', 'rew-x', 'acc-x']) {
          expect(row(u), findsNothing, reason: u);
        }
        expect(find.text('Comment'), findsNothing);
      });

      testWidgets('account table: own kind and Comment ($width)', (
        tester,
      ) async {
        await pumpLedgerTable(
          tester,
          isDesktop: isDesktop,
          env: env(),
          kind: CustomerLedgerKind.account,
        );
        expect(find.text('Bola: Account Transactions'), findsOneWidget);
        for (final u in ['acc-1', 'acc-2', 'acc-3']) {
          expect(row(u), findsOneWidget, reason: u);
        }
        for (final u in ['rew-1', 'rew-4', 'acc-x']) {
          expect(row(u), findsNothing, reason: u);
        }
        expect(find.text('Comment'), findsOneWidget);
      });

      for (final kind in CustomerLedgerKind.values) {
        testWidgets('${kind.name} totals equal the analysis ($width)', (
          tester,
        ) async {
          await pumpLedgerTable(
            tester,
            isDesktop: isDesktop,
            env: env(),
            kind: kind,
            period: range,
          );
          final analysis = CustomerAnalysis.build(
            customer: testCustomer(),
            slice: sliceOf(
              buildBase(receipts: receipts, ledger: screenLedger),
              period: range,
            ),
          );
          final t =
              kind == CustomerLedgerKind.reward
                  ? analysis.rewardTotals
                  : analysis.accountTotals;
          expect(t.count, greaterThan(0));
          expect(totalText(tester, 'added'), 'N${t.added}');
          expect(totalText(tester, 'deducted'), 'N${t.deducted}');
          final net = t.net < 0 ? '-N${-t.net}' : '+N${t.net}';
          expect(totalText(tester, 'net'), net);
          expect(find.text('TOTAL (${t.count})'), findsOneWidget);
        });
      }

      for (final (kind, label) in [
        (CustomerLedgerKind.reward, 'Redeemed'),
        (CustomerLedgerKind.account, 'Debit'),
      ]) {
        testWidgets('type filter: $label ($width)', (tester) async {
          await pumpLedgerTable(
            tester,
            isDesktop: isDesktop,
            env: env(),
            kind: kind,
          );
          await tester.tap(find.text('Filters'));
          await tester.pumpAndSettle();
          await tester.tap(find.text('All types'));
          await tester.pumpAndSettle();
          // The dialog's option is the last one in the tree.
          await tester.tap(find.text(label).last);
          await tester.pumpAndSettle();

          expect(find.text('Filters (1)'), findsOneWidget);
          final chip = find.widgetWithText(InputChip, 'Type: $label');
          expect(chip, findsOneWidget);
          if (kind == CustomerLedgerKind.reward) {
            expect(row('rew-3'), findsOneWidget);
            expect(row('rew-1'), findsNothing);
            expect(totalText(tester, 'added'), 'N0.0');
            expect(totalText(tester, 'deducted'), 'N4.0');
          } else {
            expect(row('acc-2'), findsOneWidget);
            expect(row('acc-3'), findsOneWidget);
            expect(row('acc-1'), findsNothing);
            expect(totalText(tester, 'deducted'), 'N50.0');
          }

          await tester.tap(
            find.descendant(of: chip, matching: find.byIcon(Icons.close)),
          );
          await tester.pumpAndSettle();
          expect(find.text('Filters'), findsOneWidget);
          expect(
            row(kind == CustomerLedgerKind.reward ? 'rew-1' : 'acc-1'),
            findsOneWidget,
          );
        });
      }

      testWidgets('Reset All keeps the period ($width)', (tester) async {
        // The 15th and 16th: rew-1 and rew-2.
        final period = ReceiptsReportPeriod.range(
          DateTime(2026, 10, 15),
          DateTime(2026, 10, 16),
        );
        await pumpLedgerTable(
          tester,
          isDesktop: isDesktop,
          env: env(),
          kind: CustomerLedgerKind.reward,
          period: period,
        );
        final pill = 'Date: ${receiptsPeriodLabel(period)}';
        expect(find.text(pill), findsOneWidget);
        expect(row('rew-2'), findsOneWidget);

        // rew-1's linked receipt id.
        await tester.enterText(find.byType(TextField).first, '555');
        await tester.pumpAndSettle();
        expect(row('rew-1'), findsOneWidget);
        expect(row('rew-2'), findsNothing);

        await tester.tap(find.text('Reset All Filters'));
        await tester.pumpAndSettle();

        expect(find.text('Reset All Filters'), findsNothing);
        expect(find.text(pill), findsOneWidget);
        expect(row('rew-1'), findsOneWidget);
        expect(row('rew-2'), findsOneWidget);
        // Still the 15th and 16th only.
        expect(row('rew-3'), findsNothing);
        expect(row('rew-4'), findsNothing);
      });

      testWidgets('totals are the same on every page ($width)', (tester) async {
        await pumpLedgerTable(
          tester,
          isDesktop: isDesktop,
          env: env(
            entries: [
              for (var i = 0; i < 150; i++)
                ledgerEntry(
                  uuid: 'e-${i.toString().padLeft(3, '0')}',
                  isBalance: false,
                  isAdd: i % 3 != 0,
                  amount: 2,
                  createdAt: DateTime(2026, 10, 1).add(Duration(hours: i)),
                ),
            ],
          ),
          kind: CustomerLedgerKind.reward,
        );
        expect(find.text('Showing 1-100 of 150 entries'), findsOneWidget);
        final before = [
          totalText(tester, 'added'),
          totalText(tester, 'deducted'),
          totalText(tester, 'net'),
        ];
        expect(before, ['N200.0', 'N100.0', '+N100.0']);

        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();

        expect(find.text('Showing 101-150 of 150 entries'), findsOneWidget);
        expect([
          totalText(tester, 'added'),
          totalText(tester, 'deducted'),
          totalText(tester, 'net'),
        ], before);
      });

      testWidgets('a row opens the read-only dialog hook ($width)', (
        tester,
      ) async {
        final log = CustomerEnvLog();
        await pumpLedgerTable(
          tester,
          isDesktop: isDesktop,
          env: env(log: log),
          kind: CustomerLedgerKind.reward,
        );
        await tester.tap(
          find.descendant(
            of: row('rew-2'),
            matching: find.text(formatDateTime(DateTime(2026, 10, 16))),
          ),
        );
        await tester.pumpAndSettle();
        expect(log.calls, ['ledgerEntry']);
        expect((log.records.single as CustomerAccountReceipts).uuid, 'rew-2');
      });

      testWidgets('the linked receipt opens the receipt hook ($width)', (
        tester,
      ) async {
        final log = CustomerEnvLog();
        await pumpLedgerTable(
          tester,
          isDesktop: isDesktop,
          env: env(log: log),
          kind: CustomerLedgerKind.reward,
        );
        // Not loaded: a plain dash, no link.
        expect(
          find.byKey(const ValueKey('ledger-receipt-rew-4')),
          findsNothing,
        );
        final link = find.byKey(const ValueKey('ledger-receipt-rew-1'));
        expect(link, findsOneWidget);
        expect(
          find.descendant(of: link, matching: find.text('#555')),
          findsOneWidget,
        );
        await tester.ensureVisible(link);
        await tester.pumpAndSettle();
        await tester.tap(link);
        await tester.pumpAndSettle();
        expect(log.calls, ['receipt']);
        expect((log.records.single as TempMainReceipt).uuid, 'rec-1');
      });

      for (final (kind, id, title, inRange, outOfRange) in [
        (
          CustomerLedgerKind.reward,
          'rewards',
          'Bola: Reward Earnings',
          ['rew-1', 'rew-2', 'rew-4'],
          'rew-3',
        ),
        (
          CustomerLedgerKind.account,
          'account',
          'Bola: Account Transactions',
          ['acc-1', 'acc-2'],
          'acc-3',
        ),
      ]) {
        testWidgets('See all on the analysis opens the ${kind.name} '
            'table ($width)', (tester) async {
          await pumpCustomerAnalysis(
            tester,
            isDesktop: isDesktop,
            env: env(pushLedgerTables: true),
            period: range,
          );
          await tester.tap(find.byKey(ValueKey('customer-see-all-$id')));
          await tester.pumpAndSettle();

          expect(find.text(title), findsOneWidget);
          if (!isDesktop) {
            await tester.tap(find.text('View'));
            await tester.pumpAndSettle();
          }
          expect(
            find.text('Date: ${receiptsPeriodLabel(range)}'),
            findsOneWidget,
          );
          for (final u in inRange) {
            expect(row(u), findsOneWidget, reason: u);
          }
          expect(row(outOfRange), findsNothing);
        });
      }

      testWidgets('without View Date the period is today ($width)', (
        tester,
      ) async {
        await pumpLedgerTable(
          tester,
          isDesktop: isDesktop,
          env: env(access: testAccess(canPickDate: false)),
          kind: CustomerLedgerKind.account,
        );
        expect(
          find.text(
            'Date: ${receiptsPeriodLabel(ReceiptsReportPeriod.today())}',
          ),
          findsOneWidget,
        );
        expect(
          find.text('All time covers the data loaded on this device.'),
          findsNothing,
        );
        expect(
          tester
              .widget<PopupMenuButton<int>>(find.byType(PopupMenuButton<int>))
              .enabled,
          isFalse,
        );
      });
    }
  });
}
