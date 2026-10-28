import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/class/purchase_report_table_logic.dart';
import 'package:stockall/pages/report/purchase_report/purchase_summary/class/purchase_summary_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_summary/class/receipts_report_summary_logic.dart';

import 'purchase_report_fixtures.dart';

/// 1 Acme paid (cash), 2 Acme partly paid (bank), 3 Bolt unpaid
/// without lines, 4 no supplier / staff, overpaid with a custom
/// total, 5 Cora paid split.
List<PurchaseReportRow> sample() => rows([
  purchase(
    uuid: uuidN(1),
    supplierId: 'sup-a',
    supplierName: 'Acme',
    staffId: 'staff-a',
    staffName: 'Ada',
    total: 100,
    payments: [payment(100)],
    createdAt: DateTime(2026, 10, 17, 9),
  ),
  purchase(
    uuid: uuidN(2),
    supplierId: 'sup-a',
    supplierName: 'Acme',
    staffId: 'staff-a',
    staffName: 'Ada',
    total: 300,
    payments: [payment(100, method: 'Bank')],
    createdAt: DateTime(2026, 10, 17, 10),
  ),
  purchase(
    uuid: uuidN(3),
    supplierId: 'sup-b',
    supplierName: 'Bolt',
    staffId: 'staff-b',
    staffName: 'Ben',
    total: 50,
    noItems: true,
    createdAt: DateTime(2026, 10, 17, 11),
  ),
  purchase(
    uuid: uuidN(4),
    supplierId: null,
    supplierName: null,
    staffId: null,
    staffName: null,
    total: 40,
    isCustomPriceSet: true,
    items: [line(total: 30, purchaseId: uuidN(4))],
    payments: [payment(60)],
    createdAt: DateTime(2026, 10, 17, 12),
  ),
  purchase(
    uuid: uuidN(5),
    supplierId: 'sup-c',
    supplierName: 'Cora',
    staffId: 'staff-a',
    staffName: 'Ada',
    total: 50,
    payments: [
      payment(20),
      payment(30, method: 'Bank', uuid: 'pay-2'),
    ],
    createdAt: DateTime(2026, 10, 17, 13),
  ),
]);

void main() {
  group('stats', () {
    test('KPIs', () {
      final s = PurchaseSummaryBuilder.stats(sample());
      expect(s.totalPurchases, 5);
      expect(s.totalSpend, 540);
      expect(s.totalPaid, 310);
      // Overpaid purchases owe nothing; they don't reduce it.
      expect(s.totalOutstanding, 250);
      expect(s.averagePurchaseValue, 108);
      expect(s.overpaidCount, 1);
      expect(s.adjustedCount, 1);
      expect(s.totalItems, 4);
      expect(s.itemsUnknownCount, 1);
      expect(s.distinctSuppliers, 3);
      expect(s.noSupplierPurchases, 1);
      expect(s.distinctStaff, 2);
      expect(s.noStaffPurchases, 1);
    });

    test('counts by status and channel', () {
      final s = PurchaseSummaryBuilder.stats(sample());
      expect(s.statusCount(PurchaseStatus.paid), 3);
      expect(s.statusCount(PurchaseStatus.partlyPaid), 1);
      expect(s.statusCount(PurchaseStatus.unpaid), 1);
      expect(s.channelCount('cash'), 2);
      expect(s.channelCount('bank'), 1);
      expect(s.channelCount('split'), 1);
      expect(s.channelCount(purchaseReportNoneKey), 1);
    });

    test('Outstanding equals the table Balance total', () {
      final all = sample();
      for (final f in [
        PurchaseReportFilters(),
        PurchaseReportFilters(supplierKey: purchaseReportNoneKey),
        PurchaseReportFilters(status: PurchaseStatus.paid),
        PurchaseReportFilters(staffKey: 'staff-a'),
      ]) {
        final shown = PurchaseReportQuery.filterAndSort(
          rows: all,
          period: const ReceiptsReportPeriod.allTime(),
          filters: f,
          sortField: PurchasesSortField.createdAt,
          ascending: false,
          departmentsEnabled: false,
          closingTime: midnight,
        );
        expect(
          PurchaseSummaryBuilder.stats(shown).totalOutstanding,
          PurchaseReportQuery.paginate(shown, 1).totalBalance,
        );
      }
    });

    test('empty', () {
      final s = PurchaseSummaryBuilder.stats([]);
      expect(s.totalPurchases, 0);
      expect(s.averagePurchaseValue, 0);
      expect(s.statusCount(PurchaseStatus.paid), 0);
    });
  });

  group('groups', () {
    test('suppliers by spend, none last', () {
      final groups = PurchaseSummaryBuilder.suppliers(sample());
      expect(groups.map((g) => g.label), [
        'Acme',
        'Bolt',
        'Cora',
        'No supplier',
      ]);
      final acme = groups.first;
      expect(acme.key, 'sup-a');
      expect(acme.purchaseCount, 2);
      expect(acme.spend, 400);
      expect(acme.paid, 200);
      expect(acme.balance, 200);
      expect(acme.average, 200);
      expect(acme.lastDate, DateTime(2026, 10, 17, 10));
      expect(acme.spendShare, closeTo(400 / 540 * 100, 1e-9));
      final none = groups.last;
      expect(none.isNone, isTrue);
      // Overpaid by 20: owes 0, never a negative balance.
      expect(none.balance, 0);
    });

    test('staff and departments', () {
      expect(
        PurchaseSummaryBuilder.staff(
          sample(),
        ).map((g) => g.label),
        ['Ada', 'Ben', 'No staff'],
      );
      final deps = PurchaseSummaryBuilder.departments(sample());
      expect(deps.single.isNone, isTrue);
      expect(deps.single.label, 'No Department');
    });

    test('newest name per supplier', () {
      final groups = PurchaseSummaryBuilder.suppliers(
        rows([
          purchase(
            uuid: uuidN(1),
            supplierName: 'Old',
            createdAt: DateTime(2026, 10, 1),
          ),
          purchase(
            uuid: uuidN(2),
            supplierName: 'New',
            createdAt: DateTime(2026, 10, 2),
          ),
        ]),
      );
      expect(groups.single.label, 'New');
    });

    test('top and least 3: ties by count, then name; none never ranked', () {
      final groups = PurchaseSummaryBuilder.suppliers(sample());
      expect(
        PurchaseSummaryBuilder.top3(
          groups,
        ).map((g) => g.label),
        ['Acme', 'Bolt', 'Cora'],
      );
      // "No supplier" has the lowest spend (40) but is not ranked.
      expect(
        PurchaseSummaryBuilder.least3(
          groups,
        ).map((g) => g.label),
        ['Bolt', 'Cora', 'Acme'],
      );
    });

    test('top 3: same spend, more purchases first', () {
      final groups = PurchaseSummaryBuilder.suppliers(
        rows([
          purchase(
            uuid: uuidN(1),
            supplierId: 'sup-z',
            supplierName: 'Zed',
            total: 50,
          ),
          purchase(
            uuid: uuidN(2),
            supplierId: 'sup-z',
            supplierName: 'Zed',
            total: 50,
          ),
          purchase(
            uuid: uuidN(3),
            supplierId: 'sup-a',
            supplierName: 'Abe',
            total: 100,
          ),
        ]),
      );
      expect(
        PurchaseSummaryBuilder.top3(
          groups,
        ).map((g) => g.label),
        ['Zed', 'Abe'],
      );
      expect(
        PurchaseSummaryBuilder.least3(
          groups,
        ).map((g) => g.label),
        ['Abe', 'Zed'],
      );
    });

    test('sortGroups keeps none last', () {
      final groups = PurchaseSummaryBuilder.suppliers(sample());
      for (final field in PurchaseSummarySortField.values) {
        for (final asc in [true, false]) {
          expect(
            PurchaseSummaryBuilder.sortGroups(
              groups,
              field: field,
              ascending: asc,
            ).last.isNone,
            isTrue,
          );
        }
      }
      expect(
        PurchaseSummaryBuilder.sortGroups(
          groups,
          field: PurchaseSummarySortField.balance,
          ascending: true,
        ).map((g) => g.label),
        ['Cora', 'Bolt', 'Acme', 'No supplier'],
      );
    });
  });

  group('status and channel summaries', () {
    test('statuses, always all three', () {
      final s = PurchaseSummaryBuilder.statuses(sample());
      expect(s.map((x) => x.status), PurchaseStatus.values);
      expect(s[0].purchaseCount, 3);
      expect(s[0].value, 190);
      expect(s[0].paid, 210);
      expect(s[0].outstanding, 0);
      expect(s[0].countShare, 60);
      expect(s[1].value, 300);
      expect(s[1].outstanding, 200);
      expect(s[2].value, 50);
      expect(s[2].outstanding, 50);
      final empty = PurchaseSummaryBuilder.statuses([]);
      expect(empty.length, 3);
      expect(empty.first.countShare, isNull);
      expect(empty.first.valueShare, isNull);
    });

    test('channels: Cash, Bank, Split, Unpaid', () {
      final c = PurchaseSummaryBuilder.channels(sample());
      expect(c.map((x) => x.label), [
        'Cash',
        'Bank',
        'Split',
        'Unpaid',
      ]);
      expect(c[0].purchaseCount, 2);
      expect(c[0].value, 140);
      expect(c[0].paid, 160);
      expect(c[1].value, 300);
      expect(c[2].paid, 50);
      expect(c[3].isNone, isTrue);
      expect(c[3].key, purchaseReportNoneKey);
      expect(c[3].value, 50);
      expect(c[3].paid, 0);
      expect(c[3].countShare, 20);
    });
  });

  group('handoff', () {
    test('copies the base and sets one key', () {
      final base = PurchaseReportFilters(
        search: 'x',
        status: PurchaseStatus.unpaid,
      );
      final f = PurchaseSummaryBuilder.handoff(
        base,
        supplierKey: 'sup-a',
      );
      expect(f.supplierKey, 'sup-a');
      expect(f.search, 'x');
      expect(f.status, PurchaseStatus.unpaid);
      expect(base.supplierKey, isNull);
    });

    test('none rows and other keys', () {
      final f = PurchaseSummaryBuilder.handoff(
        PurchaseReportFilters(),
        staffKey: purchaseReportNoneKey,
        departmentKey: 'dep-a',
        channelKey: purchaseReportNoneKey,
        status: PurchaseStatus.paid,
      );
      expect(f.staffKey, purchaseReportNoneKey);
      expect(f.departmentKey, 'dep-a');
      expect(f.channelKey, purchaseReportNoneKey);
      expect(f.status, PurchaseStatus.paid);
      expect(f.supplierKey, isNull);
    });

    test('the handed-off table shows exactly the group', () {
      final all = sample();
      final groups = PurchaseSummaryBuilder.suppliers(all);
      for (final g in groups) {
        final f = PurchaseSummaryBuilder.handoff(
          PurchaseReportFilters(),
          supplierKey: g.key,
        );
        final shown = PurchaseReportQuery.filterAndSort(
          rows: all,
          period: const ReceiptsReportPeriod.allTime(),
          filters: f,
          sortField: PurchasesSortField.createdAt,
          ascending: false,
          departmentsEnabled: false,
          closingTime: midnight,
        );
        expect(shown.length, g.purchaseCount);
        expect(
          shown.fold<double>(0, (s, r) => s + r.total),
          g.spend,
        );
      }
    });
  });

  group('trend', () {
    test('one day: 24 hourly buckets from closing time', () {
      final points = PurchaseTrendBuilder.build(
        rows: sample(),
        period: ReceiptsReportPeriod.day(DateTime(2026, 10, 17)),
        closingTime: midnight,
      );
      expect(points.length, 24);
      expect(points.first.start, DateTime(2026, 10, 17));
      expect(points[9].spend, 100);
      expect(points[9].paidCount, 1);
      expect(points[10].partlyPaidCount, 1);
      expect(points[11].unpaidCount, 1);
      expect(
        points.fold<double>(0, (s, p) => s + p.spend),
        540,
      );
      expect(
        points.fold<int>(0, (s, p) => s + p.purchaseCount),
        5,
      );
    });

    test('hourly with a 4am closing time', () {
      final points = PurchaseTrendBuilder.build(
        rows: rows([
          purchase(createdAt: DateTime(2026, 10, 18, 3, 30)),
        ]),
        period: ReceiptsReportPeriod.day(DateTime(2026, 10, 17)),
        closingTime: const TimeOfDay(hour: 4, minute: 0),
      );
      expect(points.first.start, DateTime(2026, 10, 17, 4));
      expect(points[23].purchaseCount, 1);
    });

    test('up to 31 days: daily', () {
      final points = PurchaseTrendBuilder.build(
        rows: sample(),
        period: ReceiptsReportPeriod.range(
          DateTime(2026, 10, 16),
          DateTime(2026, 10, 18),
        ),
        closingTime: midnight,
      );
      expect(points.map((p) => p.start), [
        DateTime(2026, 10, 16),
        DateTime(2026, 10, 17),
        DateTime(2026, 10, 18),
      ]);
      expect(points[1].purchaseCount, 5);
      expect(points[1].paid, 310);
    });

    test('up to 26 weeks: weekly from Monday', () {
      final points = PurchaseTrendBuilder.build(
        rows: sample(),
        period: ReceiptsReportPeriod.range(
          DateTime(2026, 10, 1),
          DateTime(2026, 11, 9),
        ),
        closingTime: midnight,
      );
      expect(points.length, 7);
      expect(points.every((p) => p.start.weekday == 1), isTrue);
      expect(points.first.start, DateTime(2026, 9, 28));
      // Saturday 17 October is in the week of the 12th.
      expect(
        points
            .firstWhere(
              (p) => p.start == DateTime(2026, 10, 12),
            )
            .purchaseCount,
        5,
      );
    });

    test('longer: monthly', () {
      final points = PurchaseTrendBuilder.build(
        rows: sample(),
        period: ReceiptsReportPeriod.range(
          DateTime(2026, 1, 1),
          DateTime(2026, 12, 31),
        ),
        closingTime: midnight,
      );
      expect(points.length, 12);
      expect(points.every((p) => p.start.day == 1), isTrue);
      expect(points[9].spend, 540);
    });

    test('all time: earliest purchase to today; empty is no chart', () {
      final points = PurchaseTrendBuilder.build(
        rows: sample(),
        period: const ReceiptsReportPeriod.allTime(),
        now: DateTime(2026, 10, 20, 12),
        closingTime: midnight,
      );
      expect(points.first.start, DateTime(2026, 10, 17));
      expect(points.last.start, DateTime(2026, 10, 20));
      expect(points.length, 4);
      expect(
        PurchaseTrendBuilder.build(
          rows: [],
          period: const ReceiptsReportPeriod.allTime(),
          now: DateTime(2026, 10, 20),
          closingTime: midnight,
        ),
        isEmpty,
      );
    });
  });

  final day17 = ReceiptsReportPeriod.day(DateTime(2026, 10, 17));

  PurchaseSummaryResult build(
    List<PurchaseReportRow> rows, {
    ReceiptsReportPeriod? period,
    bool departmentsEnabled = false,
  }) => PurchaseSummaryBuilder.build(
    rows: rows,
    period: period ?? day17,
    departmentsEnabled: departmentsEnabled,
    closingTime: midnight,
    now: DateTime(2026, 10, 20, 12),
  );

  group('build', () {
    test('only the period is applied', () {
      final r = build([
        ...sample(),
        ...rows([
          purchase(
            uuid: uuidN(9),
            createdAt: DateTime(2026, 10, 18, 9),
          ),
        ]),
      ]);
      expect(r.rows.length, 5);
      expect(r.stats.totalPurchases, 5);
      expect(r.stats.totalSpend, 540);
    });

    test('rankings, sections and the chart interval', () {
      final r = build(sample());
      expect(r.topSuppliers.map((g) => g.label), [
        'Acme',
        'Bolt',
        'Cora',
      ]);
      expect(r.leastSuppliers.map((g) => g.label), [
        'Bolt',
        'Cora',
        'Acme',
      ]);
      expect(r.statuses.length, 3);
      expect(r.channels.length, 4);
      expect(r.trend.length, 24);
      expect(r.interval, ReceiptsTrendInterval.hourly);
    });

    test('departments only when on', () {
      final withDept = [
        ...sample(),
        ...rows([
          purchase(
            uuid: uuidN(9),
            departmentUuid: 'dep-a',
            departmentName: 'Bar',
            createdAt: DateTime(2026, 10, 17, 14),
          ),
        ]),
      ];
      expect(build(withDept).departments, isEmpty);
      final on = build(withDept, departmentsEnabled: true);
      expect(on.departments.map((g) => g.label), [
        'Bar',
        'No Department',
      ]);
    });

    test('all time without purchases has no chart', () {
      final r = build(
        [],
        period: const ReceiptsReportPeriod.allTime(),
      );
      expect(r.trend, isEmpty);
      expect(r.interval, isNull);
      expect(r.stats.totalPurchases, 0);
    });

    test('channel balance is the clamped Balance', () {
      final c = build(sample()).channels;
      expect(c.map((x) => x.balance), [0, 200, 0, 50]);
    });
  });

  group('breakdown rows', () {
    final result = build(sample());

    List<PurchaseBreakdownRow> tab(PurchaseBreakdownTab t) =>
        PurchaseSummaryBuilder.breakdown(result, t);

    test('suppliers hand off their key; none row last', () {
      final r = tab(PurchaseBreakdownTab.suppliers);
      expect(r.map((x) => x.id), [
        'suppliers-sup-a',
        'suppliers-sup-b',
        'suppliers-sup-c',
        'suppliers-$purchaseReportNoneKey',
      ]);
      expect(r.first.filters.supplierKey, 'sup-a');
      expect(r.first.filters.activeCount, 1);
      expect(r.first.lastDate, DateTime(2026, 10, 17, 10));
      expect(r.first.share, closeTo(400 / 540 * 100, 1e-9));
      expect(r.last.isNone, isTrue);
      expect(r.last.label, 'No supplier');
      expect(r.last.filters.supplierKey, purchaseReportNoneKey);
    });

    test('staff hand off the staff key', () {
      final r = tab(PurchaseBreakdownTab.staff);
      expect(r.first.filters.staffKey, 'staff-a');
      expect(r.first.filters.supplierKey, isNull);
      expect(r.last.filters.staffKey, purchaseReportNoneKey);
    });

    test('status rows: fixed order, status handoff, no last date', () {
      final r = tab(PurchaseBreakdownTab.status);
      expect(r.map((x) => x.label), [
        'Paid',
        'Partly Paid',
        'Unpaid',
      ]);
      expect(r.any((x) => x.isNone), isFalse);
      expect(r[1].filters.status, PurchaseStatus.partlyPaid);
      expect(r[1].balance, 200);
      expect(r.every((x) => x.lastDate == null), isTrue);
    });

    test('channel rows: Unpaid is the none row', () {
      final r = tab(PurchaseBreakdownTab.channel);
      expect(r.map((x) => x.label), [
        'Cash',
        'Bank',
        'Split',
        'Unpaid',
      ]);
      expect(r.last.isNone, isTrue);
      expect(r.last.filters.channelKey, purchaseReportNoneKey);
      expect(r[1].filters.channelKey, 'bank');
    });

    test('departments off: no rows', () {
      expect(tab(PurchaseBreakdownTab.departments), isEmpty);
    });
  });

  group('sortBreakdown', () {
    final result = build(sample());

    test('null keeps the built order', () {
      for (final t in PurchaseBreakdownTab.values) {
        final built = PurchaseSummaryBuilder.breakdown(result, t);
        expect(
          PurchaseSummaryBuilder.sortBreakdown(
            built,
            field: null,
            ascending: true,
          ).map((r) => r.id),
          built.map((r) => r.id),
        );
      }
    });

    test('the none row is last under every sort', () {
      for (final t in [
        PurchaseBreakdownTab.suppliers,
        PurchaseBreakdownTab.staff,
        PurchaseBreakdownTab.channel,
      ]) {
        final built = PurchaseSummaryBuilder.breakdown(result, t);
        for (final f in PurchaseBreakdownSortField.values) {
          for (final asc in [true, false]) {
            final sorted = PurchaseSummaryBuilder.sortBreakdown(
              built,
              field: f,
              ascending: asc,
            );
            expect(
              sorted.last.isNone,
              isTrue,
              reason: '$t $f asc=$asc',
            );
          }
        }
      }
    });

    test('by name, spend and balance', () {
      final built = PurchaseSummaryBuilder.breakdown(
        result,
        PurchaseBreakdownTab.suppliers,
      );
      List<String> labels(
        PurchaseBreakdownSortField f,
        bool asc,
      ) => PurchaseSummaryBuilder.sortBreakdown(
        built,
        field: f,
        ascending: asc,
      ).map((r) => r.label).toList();
      expect(labels(PurchaseBreakdownSortField.name, false), [
        'Cora',
        'Bolt',
        'Acme',
        'No supplier',
      ]);
      expect(labels(PurchaseBreakdownSortField.spend, true), [
        'Bolt',
        'Cora',
        'Acme',
        'No supplier',
      ]);
      expect(labels(PurchaseBreakdownSortField.balance, false), [
        'Acme',
        'Bolt',
        'Cora',
        'No supplier',
      ]);
    });
  });
}
