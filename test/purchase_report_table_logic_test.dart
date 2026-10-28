import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/temp_product_class/units_class/product_units_class.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/class/purchase_lines.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/class/purchase_report_table_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

import 'purchase_report_fixtures.dart';

List<PurchaseReportRow> query(
  List<PurchaseReportRow> rows, {
  ReceiptsReportPeriod period = const ReceiptsReportPeriod.allTime(),
  PurchaseReportFilters? filters,
  PurchasesSortField sortField = PurchasesSortField.createdAt,
  bool ascending = false,
  bool departmentsEnabled = false,
  TimeOfDay closingTime = midnight,
}) {
  return PurchaseReportQuery.filterAndSort(
    rows: rows,
    period: period,
    filters: filters ?? PurchaseReportFilters(),
    sortField: sortField,
    ascending: ascending,
    departmentsEnabled: departmentsEnabled,
    closingTime: closingTime,
  );
}

void main() {
  group('items', () {
    test('counts bought units, not converted: 2 cases + 3 pieces = 5', () {
      final r = row(
        purchase(
          items: [
            line(quantity: 2, unitUuid: 'case'),
            line(uuid: 'line-2', quantity: 3),
          ],
        ),
      );
      expect(r.items, 5);
      expect(r.lineCount, 2);
    });

    test('2D: area units count 1 per line, sheet units count', () {
      final area = testUnit(
        'sqm',
        dimensionType: ProductUnitsClass.areaUnit,
      );
      final sheet = testUnit(
        'slab',
        isPrimary: false,
        dimensionType: ProductUnitsClass.sheetUnit,
      );
      final r = row(
        purchase(
          items: [
            line(
              quantity: 4.5,
              unitUuid: 'sqm',
              units: [area, sheet],
            ),
            line(
              uuid: 'line-2',
              quantity: 3,
              unitUuid: 'slab',
              units: [area, sheet],
            ),
          ],
        ),
      );
      expect(r.items, 4);
    });

    test('unknown unit uuid falls back to the primary unit', () {
      final area = testUnit(
        'sqm',
        dimensionType: ProductUnitsClass.areaUnit,
      );
      final l = line(
        quantity: 7.5,
        unitUuid: 'gone',
        units: [area],
      );
      expect(PurchaseLines.lineUnit(l)?.uuid, 'sqm');
      expect(PurchaseLines.lineItemCount(l), 1);
    });

    test('a line without a units list counts its quantity', () {
      final l = line(quantity: 6, units: []);
      expect(PurchaseLines.lineUnit(l), isNull);
      expect(PurchaseLines.lineItemCount(l), 6);
      expect(
        PurchaseLines.lineItemCount(line(quantity: null)),
        0,
      );
    });

    test('line total sums line totals', () {
      final r = row(
        purchase(
          total: 300,
          items: [
            line(total: 100),
            line(uuid: 'line-2', total: 150),
            line(uuid: 'line-3', total: null),
          ],
        ),
      );
      expect(r.lineTotal, 250);
    });

    test('product key prefers the item, then the storage item', () {
      expect(PurchaseLines.productKey(line()), 'product-a');
      expect(
        PurchaseLines.productKey(
          line(itemId: null, storageItemId: 'store-1'),
        ),
        'store-1',
      );
      expect(
        PurchaseLines.productKey(
          line(itemId: ' ', storageItemId: null),
        ),
        isNull,
      );
    });
  });

  group('legacy purchases', () {
    test('no lines: line values are unknown, not zero', () {
      final r = row(purchase(noItems: true, total: 500));
      expect(r.lineSource, PurchaseLineSource.none);
      expect(r.items, isNull);
      expect(r.lineTotal, isNull);
      expect(r.lineCount, isNull);
      expect(r.total, 500);
      expect(r.hasAdjustment, isFalse);
    });

    test('empty items are treated as no lines', () {
      final r = row(purchase(items: []));
      expect(r.lineSource, PurchaseLineSource.none);
      expect(r.items, isNull);
    });

    test('legacy rows are used when items are missing', () {
      final out = PurchaseReportRowBuilder.buildAll(
        purchases: [purchase(noItems: true, total: 50)],
        legacyLines: [
          line(quantity: 2, total: 20),
          line(uuid: 'line-2', quantity: 3, total: 30),
          line(uuid: 'other', purchaseId: 'p-999999999999'),
        ],
      );
      expect(out.single.lineSource, PurchaseLineSource.legacy);
      expect(out.single.items, 5);
      expect(out.single.lineTotal, 50);
    });

    test('embedded items win over legacy rows', () {
      final out = PurchaseReportRowBuilder.buildAll(
        purchases: [
          purchase(items: [line(quantity: 1)]),
        ],
        legacyLines: [line(uuid: 'old', quantity: 9)],
      );
      expect(
        out.single.lineSource,
        PurchaseLineSource.embedded,
      );
      expect(out.single.items, 1);
    });
  });

  group('payment status', () {
    PurchaseReportRow withPaid(double total, List<double> paid) =>
        row(
          purchase(
            total: total,
            payments: [
              for (var i = 0; i < paid.length; i++)
                payment(paid[i], uuid: 'pay-$i'),
            ],
          ),
        );

    test('zero total without payments is Paid', () {
      final r = withPaid(0, []);
      expect(r.status, PurchaseStatus.paid);
      expect(r.overpaid, isFalse);
      expect(r.balance, 0);
    });

    test('null total counts as 0', () {
      final r = row(purchase(total: null, noItems: true));
      expect(r.total, 0);
      expect(r.status, PurchaseStatus.paid);
    });

    test('nothing paid is Unpaid', () {
      final r = withPaid(100, []);
      expect(r.status, PurchaseStatus.unpaid);
      expect(r.balance, 100);
    });

    test('some paid is Partly Paid; payments are summed', () {
      final r = withPaid(100, [30, 20]);
      expect(r.status, PurchaseStatus.partlyPaid);
      expect(r.paid, 50);
      expect(r.balance, 50);
    });

    test('fully paid is Paid', () {
      expect(
        withPaid(100, [60, 40]).status,
        PurchaseStatus.paid,
      );
    });

    test('overpaid is Paid, flagged, and owes 0', () {
      final r = withPaid(100, [120]);
      expect(r.status, PurchaseStatus.paid);
      expect(r.overpaid, isTrue);
      expect(r.overpaidBy, 20);
      expect(r.balance, 0);
      expect(withPaid(100, [40]).overpaidBy, 0);
    });

    test('float tolerance of 0.005', () {
      expect(
        withPaid(100, [99.996]).status,
        PurchaseStatus.paid,
      );
      expect(
        withPaid(100, [99.99]).status,
        PurchaseStatus.partlyPaid,
      );
      expect(withPaid(100, [100.004]).overpaid, isFalse);
      expect(withPaid(100, [100.006]).overpaid, isTrue);
      expect(
        withPaid(100, [0.004]).status,
        PurchaseStatus.unpaid,
      );
      expect(
        withPaid(0.1 + 0.2, [0.3]).status,
        PurchaseStatus.paid,
      );
    });
  });

  group('channel', () {
    PurchaseChannel? channelOf(List<(double, String)> paid) =>
        row(
          purchase(
            payments: [
              for (var i = 0; i < paid.length; i++)
                payment(
                  paid[i].$1,
                  method: paid[i].$2,
                  uuid: 'pay-$i',
                ),
            ],
          ),
        ).channel;

    test('no payment: no channel, the Unpaid bucket', () {
      final r = row(purchase());
      expect(r.channel, isNull);
      expect(r.channelKey, purchaseReportNoneKey);
      expect(r.channelLabel, 'Unpaid');
    });

    test('methods', () {
      expect(channelOf([(10, 'Cash')]), PurchaseChannel.cash);
      expect(channelOf([(10, 'bank')]), PurchaseChannel.bank);
      expect(
        channelOf([(10, ' Transfer ')]),
        PurchaseChannel.bank,
      );
      expect(channelOf([(10, 'POS')]), PurchaseChannel.cash);
      expect(
        channelOf([(10, 'Cash'), (5, 'Cash')]),
        PurchaseChannel.cash,
      );
      expect(
        channelOf([(10, 'Cash'), (5, 'Bank')]),
        PurchaseChannel.split,
      );
    });

    test('zero payments are not a channel', () {
      expect(channelOf([(0, 'Cash')]), isNull);
      expect(
        channelOf([(10, 'Cash'), (0, 'Bank')]),
        PurchaseChannel.cash,
      );
    });
  });

  group('supplier name', () {
    test('stored name first', () {
      final r = row(
        purchase(supplierName: 'Acme'),
        supplierNames: {'sup-a': 'Acme Ltd'},
      );
      expect(r.supplierName, 'Acme');
      expect(r.supplierLabel, 'Acme');
    });

    test('then the current supplier list', () {
      final r = row(
        purchase(supplierName: '  '),
        supplierNames: {'sup-a': 'Acme Ltd'},
      );
      expect(r.supplierName, 'Acme Ltd');
    });

    test('then Not Set', () {
      final r = row(purchase(supplierName: null));
      expect(r.supplierName, isNull);
      expect(r.supplierLabel, 'Not Set');
    });

    test('no supplier', () {
      final r = row(
        purchase(supplierId: null, supplierName: null),
      );
      expect(r.supplierKey, isNull);
      expect(r.supplierLabel, 'No supplier');
    });
  });

  group('custom price adjustment', () {
    test('custom total different from the lines is flagged', () {
      final r = row(
        purchase(
          total: 90,
          isCustomPriceSet: true,
          items: [line(total: 100)],
        ),
      );
      expect(r.hasAdjustment, isTrue);
      expect(r.adjustment, -10);
      expect(r.total, 90);
      expect(r.lineTotal, 100);
    });

    test('custom total equal to the lines is not flagged', () {
      final r = row(
        purchase(
          total: 100.004,
          isCustomPriceSet: true,
          items: [line(total: 100)],
        ),
      );
      expect(r.hasAdjustment, isFalse);
      expect(r.adjustment, isNull);
    });

    test('only custom totals are flagged', () {
      final r = row(
        purchase(total: 90, items: [line(total: 100)]),
      );
      expect(r.hasAdjustment, isFalse);
    });

    test('custom total without lines is not flagged', () {
      final r = row(
        purchase(
          total: 90,
          isCustomPriceSet: true,
          noItems: true,
        ),
      );
      expect(r.hasAdjustment, isFalse);
    });
  });

  group('rows', () {
    test('display id from the uuid digits', () {
      // 12 digits plus the EAN-13 check digit, as purchase history.
      expect(row(purchase()).displayId, '#0000000000017');
      // Too few digits: the uuid itself, never a dropped row.
      expect(
        row(purchase(uuid: 'p-abcdefghijk1')).displayId,
        '#p-abcdefghijk1',
      );
    });

    test('created at is local', () {
      final r = row(
        purchase(createdAt: DateTime.utc(2026, 10, 17, 12)),
      );
      expect(r.createdAt.isUtc, isFalse);
    });

    test('purchases queued for deletion are left out', () {
      final out = PurchaseReportRowBuilder.buildAll(
        purchases: [
          purchase(uuid: uuidN(1)),
          purchase(uuid: uuidN(2)),
        ],
        pendingDeletedUuids: {uuidN(2)},
      );
      expect(out.map((r) => r.uuid), [uuidN(1)]);
    });

    test('blank keys are no key', () {
      final r = row(
        purchase(
          staffId: ' ',
          supplierId: '',
          departmentUuid: ' ',
        ),
      );
      expect(r.staffKey, isNull);
      expect(r.supplierKey, isNull);
      expect(r.departmentKey, isNull);
      expect(r.departmentLabel, 'No Department');
    });
  });

  group('period', () {
    final day = DateTime(2026, 10, 17);
    final all = rows([
      purchase(
        uuid: uuidN(1),
        createdAt: DateTime(2026, 10, 16, 23, 59),
      ),
      purchase(
        uuid: uuidN(2),
        createdAt: DateTime(2026, 10, 17, 0, 0),
      ),
      purchase(
        uuid: uuidN(3),
        createdAt: DateTime(2026, 10, 17, 23, 59),
      ),
      purchase(
        uuid: uuidN(4),
        createdAt: DateTime(2026, 10, 18, 3, 0),
      ),
      purchase(
        uuid: uuidN(5),
        createdAt: DateTime(2026, 10, 18, 4, 0),
      ),
    ]);

    Set<String> ids(List<PurchaseReportRow> r) =>
        r.map((x) => x.uuid).toSet();

    test('one day, midnight closing', () {
      expect(
        ids(query(all, period: ReceiptsReportPeriod.day(day))),
        {uuidN(2), uuidN(3)},
      );
    });

    test('one day, 4am closing: early hours belong to the day before', () {
      // [17th 04:00, 18th 04:00).
      expect(
        ids(
          query(
            all,
            period: ReceiptsReportPeriod.day(day),
            closingTime: const TimeOfDay(hour: 4, minute: 0),
          ),
        ),
        {uuidN(3), uuidN(4)},
      );
    });

    test('range', () {
      expect(
        ids(
          query(
            all,
            period: ReceiptsReportPeriod.range(
              DateTime(2026, 10, 18),
              DateTime(2026, 10, 16),
            ),
          ),
        ),
        ids(all),
      );
    });

    test('all time', () {
      expect(query(all).length, 5);
    });

    test('today is the business day', () {
      final p = ReceiptsReportPeriod.today(
        now: DateTime(2026, 10, 18, 3),
        closingTime: const TimeOfDay(hour: 4, minute: 0),
      );
      expect(p.start, day);
      expect(p.isSingleDay, isTrue);
    });
  });

  group('access', () {
    final list = [
      purchase(
        uuid: uuidN(1),
        departmentUuid: 'dep-a',
        staffId: 'me',
      ),
      purchase(
        uuid: uuidN(2),
        departmentUuid: 'dep-b',
        staffId: 'me',
      ),
      purchase(
        uuid: uuidN(3),
        departmentUuid: 'dep-a',
        staffId: 'other',
      ),
      purchase(uuid: uuidN(4), staffId: 'other'),
    ];

    Set<String> scoped({
      bool departmentsEnabled = true,
      bool canViewAllDepartments = true,
      String? currentDepartmentUuid,
      bool canViewAllTransactions = true,
    }) {
      return PurchaseReportAccess.scope(
        purchases: list,
        departmentsEnabled: departmentsEnabled,
        canViewAllDepartments: canViewAllDepartments,
        currentDepartmentUuid: currentDepartmentUuid,
        canViewAllTransactions: canViewAllTransactions,
        currentUserId: 'me',
      ).map((p) => p.uuid!).toSet();
    }

    test('departments off: every purchase', () {
      expect(
        scoped(
          departmentsEnabled: false,
          canViewAllDepartments: false,
          currentDepartmentUuid: 'dep-a',
        ),
        {uuidN(1), uuidN(2), uuidN(3), uuidN(4)},
      );
    });

    test('all departments, none selected: every purchase', () {
      expect(scoped().length, 4);
    });

    test('all departments, one selected: that department', () {
      expect(
        scoped(currentDepartmentUuid: 'dep-a'),
        {uuidN(1), uuidN(3)},
      );
    });

    test('own department only', () {
      expect(
        scoped(
          canViewAllDepartments: false,
          currentDepartmentUuid: 'dep-b',
        ),
        {uuidN(2)},
      );
      expect(
        scoped(canViewAllDepartments: false),
        {uuidN(4)},
      );
    });

    test('own purchases only, with or without departments', () {
      expect(
        scoped(canViewAllTransactions: false),
        {uuidN(1), uuidN(2)},
      );
      expect(
        scoped(
          departmentsEnabled: false,
          canViewAllTransactions: false,
        ),
        {uuidN(1), uuidN(2)},
      );
      expect(
        scoped(
          canViewAllTransactions: false,
          currentDepartmentUuid: 'dep-a',
        ),
        {uuidN(1)},
      );
    });
  });

  group('filters', () {
    final all = rows([
      purchase(
        uuid: uuidN(1),
        supplierId: 'sup-a',
        supplierName: 'Acme',
        staffId: 'staff-a',
        staffName: 'Ada',
        departmentUuid: 'dep-a',
        departmentName: 'Bar',
        total: 100,
        payments: [payment(100)],
      ),
      purchase(
        uuid: uuidN(2),
        supplierId: 'sup-b',
        supplierName: 'Bolt',
        staffId: 'staff-b',
        staffName: 'Ben',
        total: 300,
        payments: [payment(100, method: 'Bank')],
      ),
      purchase(
        uuid: uuidN(3),
        supplierId: null,
        supplierName: null,
        staffId: null,
        staffName: null,
        total: 50,
      ),
    ]);

    Set<String> ids(
      PurchaseReportFilters f, {
      bool departmentsEnabled = false,
    }) =>
        query(
          all,
          filters: f,
          departmentsEnabled: departmentsEnabled,
        ).map((r) => r.uuid).toSet();

    test('supplier, including No supplier', () {
      expect(
        ids(PurchaseReportFilters(supplierKey: 'sup-b')),
        {uuidN(2)},
      );
      expect(
        ids(
          PurchaseReportFilters(
            supplierKey: purchaseReportNoneKey,
          ),
        ),
        {uuidN(3)},
      );
    });

    test('staff, including No staff', () {
      expect(
        ids(PurchaseReportFilters(staffKey: 'staff-a')),
        {uuidN(1)},
      );
      expect(
        ids(
          PurchaseReportFilters(
            staffKey: purchaseReportNoneKey,
          ),
        ),
        {uuidN(3)},
      );
    });

    test('department only applies with departments on', () {
      final f = PurchaseReportFilters(departmentKey: 'dep-a');
      expect(ids(f).length, 3);
      expect(ids(f, departmentsEnabled: true), {uuidN(1)});
      expect(
        ids(
          PurchaseReportFilters(
            departmentKey: purchaseReportNoneKey,
          ),
          departmentsEnabled: true,
        ),
        {uuidN(2), uuidN(3)},
      );
    });

    test('channel, including Unpaid', () {
      expect(
        ids(PurchaseReportFilters(channelKey: 'bank')),
        {uuidN(2)},
      );
      expect(
        ids(
          PurchaseReportFilters(
            channelKey: purchaseReportNoneKey,
          ),
        ),
        {uuidN(3)},
      );
    });

    test('status', () {
      expect(
        ids(
          PurchaseReportFilters(
            status: PurchaseStatus.partlyPaid,
          ),
        ),
        {uuidN(2)},
      );
      expect(
        ids(PurchaseReportFilters(status: PurchaseStatus.paid)),
        {uuidN(1)},
      );
    });

    test('total and balance ranges', () {
      expect(
        ids(PurchaseReportFilters(totalMin: 60, totalMax: 300)),
        {uuidN(1), uuidN(2)},
      );
      expect(
        ids(PurchaseReportFilters(balanceMin: 1)),
        {uuidN(2), uuidN(3)},
      );
      expect(
        ids(PurchaseReportFilters(balanceMax: 0)),
        {uuidN(1)},
      );
    });

    test('an invalid range is not applied', () {
      final f = PurchaseReportFilters(totalMin: 500, totalMax: 1);
      expect(f.totalRangeError, isNotNull);
      expect(f.totalRangeActive, isFalse);
      expect(ids(f).length, 3);
      expect(f.activeCount, 1);
    });

    test('search: supplier, staff, id, department when on', () {
      expect(ids(PurchaseReportFilters(search: 'acm')), {
        uuidN(1),
      });
      expect(ids(PurchaseReportFilters(search: 'BEN')), {
        uuidN(2),
      });
      expect(
        ids(PurchaseReportFilters(search: '000000000003')),
        {uuidN(3)},
      );
      expect(ids(PurchaseReportFilters(search: 'bar')), isEmpty);
      expect(
        ids(
          PurchaseReportFilters(search: 'bar'),
          departmentsEnabled: true,
        ),
        {uuidN(1)},
      );
    });

    test('filters combine with AND', () {
      expect(
        ids(
          PurchaseReportFilters(
            supplierKey: 'sup-a',
            status: PurchaseStatus.unpaid,
          ),
        ),
        isEmpty,
      );
    });

    test('copy is independent; clearAll clears everything', () {
      final f = PurchaseReportFilters(
        search: 'x',
        supplierKey: 'sup-a',
        status: PurchaseStatus.paid,
        balanceMin: 1,
      );
      final c = f.copy();
      c.supplierKey = 'sup-b';
      expect(f.supplierKey, 'sup-a');
      expect(f.activeCount, 3);
      expect(f.hasAnything, isTrue);
      f.clearAll();
      expect(f.activeCount, 0);
      expect(f.search, '');
      expect(f.hasAnything, isFalse);
      expect(c.search, 'x');
    });
  });

  group('options', () {
    test('newest name per key, A-Z, none last', () {
      final all = rows([
        purchase(
          uuid: uuidN(1),
          supplierId: 'sup-a',
          supplierName: 'Old Name',
          createdAt: DateTime(2026, 10, 1),
        ),
        purchase(
          uuid: uuidN(2),
          supplierId: 'sup-a',
          supplierName: 'Zed',
          createdAt: DateTime(2026, 10, 2),
        ),
        purchase(
          uuid: uuidN(3),
          supplierId: 'sup-b',
          supplierName: 'acme',
        ),
        purchase(
          uuid: uuidN(4),
          supplierId: null,
          supplierName: null,
        ),
      ]);
      final options = PurchaseReportOptions.suppliers(all);
      expect(options.map((o) => o.label), [
        'acme',
        'Zed',
        'No supplier',
      ]);
      expect(options.last.key, purchaseReportNoneKey);
    });

    test('channels: Cash, Bank, Split, Unpaid', () {
      expect(
        PurchaseReportOptions.channels().map((o) => o.label),
        ['Cash', 'Bank', 'Split', 'Unpaid'],
      );
      expect(
        PurchaseReportOptions.channels().last.key,
        purchaseReportNoneKey,
      );
    });
  });

  group('sort', () {
    final all = rows([
      purchase(
        uuid: uuidN(1),
        supplierName: 'Bolt',
        createdAt: DateTime(2026, 10, 17, 9),
      ),
      purchase(
        uuid: uuidN(2),
        supplierId: null,
        supplierName: null,
        createdAt: DateTime(2026, 10, 17, 10),
        noItems: true,
      ),
      purchase(
        uuid: uuidN(3),
        supplierName: 'acme',
        createdAt: DateTime(2026, 10, 17, 11),
      ),
    ]);

    List<String> order(
      PurchasesSortField f, {
      required bool ascending,
    }) =>
        query(all, sortField: f, ascending: ascending)
            .map((r) => r.uuid)
            .toList();

    test('nulls sink in both directions', () {
      expect(
        order(PurchasesSortField.supplier, ascending: true),
        [uuidN(3), uuidN(1), uuidN(2)],
      );
      expect(
        order(PurchasesSortField.supplier, ascending: false),
        [uuidN(1), uuidN(3), uuidN(2)],
      );
      expect(
        order(PurchasesSortField.items, ascending: true).last,
        uuidN(2),
      );
    });

    test('ties: newest first', () {
      expect(
        order(PurchasesSortField.total, ascending: true),
        [uuidN(3), uuidN(2), uuidN(1)],
      );
    });
  });

  group('pagination', () {
    final all = rows([
      for (var i = 1; i <= 250; i++)
        purchase(
          uuid: uuidN(i),
          total: 10,
          payments: [payment(4)],
          createdAt: DateTime(2026, 10, 17).add(
            Duration(minutes: i),
          ),
        ),
    ]);

    test('totals cover every filtered row, not just the page', () {
      final page = PurchaseReportQuery.paginate(query(all), 2);
      expect(page.rows.length, 100);
      expect(page.page, 2);
      expect(page.totalPages, 3);
      expect(page.totalCount, 250);
      expect(page.firstIndex, 101);
      expect(page.lastIndex, 200);
      expect(page.total, 2500);
      expect(page.totalPaid, 1000);
      expect(page.totalBalance, 1500);
      expect(page.totalItems, 250);
      expect(page.totalLineTotal, 2500);
    });

    test('page is clamped; empty is page 1 of 1', () {
      final last = PurchaseReportQuery.paginate(query(all), 9);
      expect(last.page, 3);
      expect(last.rows.length, 50);
      final empty = PurchaseReportQuery.paginate([], 4);
      expect(empty.page, 1);
      expect(empty.totalPages, 1);
      expect(empty.firstIndex, 0);
      expect(empty.lastIndex, 0);
    });

    test('an overpaid purchase does not lower the Balance total', () {
      final sorted = query(
        rows([
          purchase(uuid: uuidN(1), total: 100),
          purchase(
            uuid: uuidN(2),
            total: 100,
            payments: [payment(30)],
          ),
          purchase(
            uuid: uuidN(3),
            total: 100,
            payments: [payment(250)],
          ),
        ]),
      );
      final page = PurchaseReportQuery.paginate(sorted, 1);
      // 100 + 70 + 0, not 100 + 70 - 150.
      expect(page.totalBalance, 170);
      expect(page.totalPaid, 280);
      final groups = PurchaseGrouping.paginate(
        PurchaseGrouping.build(sorted, PurchaseGroupBy.supplier),
        1,
      );
      expect(groups.totalBalance, 170);
      expect(groups.rows.single.balance, 170);
    });

    test('unknown items are left out of the total', () {
      final page = PurchaseReportQuery.paginate(
        rows([
          purchase(uuid: uuidN(1), noItems: true),
          purchase(
            uuid: uuidN(2),
            items: [line(quantity: 3)],
          ),
        ]),
        1,
      );
      expect(page.totalItems, 3);
      expect(page.total, 200);
    });
  });

  group('grouping', () {
    final all = rows([
      purchase(
        uuid: uuidN(1),
        staffId: 'staff-a',
        staffName: 'Ada',
        supplierId: 'sup-a',
        supplierName: 'Old',
        total: 100,
        payments: [payment(100)],
        createdAt: DateTime(2026, 10, 1),
      ),
      purchase(
        uuid: uuidN(2),
        staffId: 'staff-a',
        staffName: 'Ada',
        supplierId: 'sup-a',
        supplierName: 'Acme',
        total: 200,
        payments: [payment(50, method: 'Bank')],
        createdAt: DateTime(2026, 10, 2),
      ),
      purchase(
        uuid: uuidN(3),
        staffId: null,
        staffName: null,
        supplierId: null,
        supplierName: null,
        total: 9000,
        createdAt: DateTime(2026, 10, 3),
      ),
      purchase(
        uuid: uuidN(4),
        staffId: 'staff-b',
        staffName: 'Ben',
        supplierId: 'sup-b',
        supplierName: 'Bolt',
        total: 10,
        noItems: true,
        createdAt: DateTime(2026, 10, 4),
      ),
    ]);

    test('the none row is last under every sort', () {
      for (final by in [
        PurchaseGroupBy.staff,
        PurchaseGroupBy.supplier,
        PurchaseGroupBy.channel,
      ]) {
        for (final field in PurchaseGroupSortField.values) {
          for (final asc in [true, false]) {
            final groups = PurchaseGrouping.sort(
              PurchaseGrouping.build(all, by),
              field: field,
              ascending: asc,
            );
            expect(
              groups.last.isNone,
              isTrue,
              reason: '$by $field asc=$asc',
            );
            expect(
              groups.where((g) => g.isNone).length,
              1,
            );
          }
        }
      }
    });

    test('none labels', () {
      String noneLabel(PurchaseGroupBy by) => PurchaseGrouping
          .build(all, by)
          .firstWhere((g) => g.isNone)
          .label;
      expect(noneLabel(PurchaseGroupBy.staff), 'No staff');
      expect(
        noneLabel(PurchaseGroupBy.supplier),
        'No supplier',
      );
      expect(noneLabel(PurchaseGroupBy.channel), 'Unpaid');
    });

    test('group values and the newest name', () {
      final groups = PurchaseGrouping.build(
        all,
        PurchaseGroupBy.supplier,
      );
      final acme = groups.firstWhere((g) => g.key == 'sup-a');
      expect(acme.label, 'Acme');
      expect(acme.count, 2);
      expect(acme.total, 300);
      expect(acme.paid, 150);
      expect(acme.balance, 150);
      expect(acme.items, 2);
      final bolt = groups.firstWhere((g) => g.key == 'sup-b');
      expect(bolt.items, isNull);
    });

    test('channel groups', () {
      final groups = PurchaseGrouping.build(
        all,
        PurchaseGroupBy.channel,
      );
      expect(
        groups.map((g) => g.key).toSet(),
        {'cash', 'bank', purchaseReportNoneKey},
      );
      expect(
        groups
            .firstWhere((g) => g.isNone)
            .count,
        2,
      );
    });

    test('sorted by total, largest first, none still last', () {
      final groups = PurchaseGrouping.sort(
        PurchaseGrouping.build(all, PurchaseGroupBy.staff),
        field: PurchaseGroupSortField.total,
        ascending: false,
      );
      expect(groups.map((g) => g.label), [
        'Ada',
        'Ben',
        'No staff',
      ]);
    });

    test('group totals cover every group', () {
      final groups = PurchaseGrouping.build(
        all,
        PurchaseGroupBy.staff,
      );
      final page = PurchaseGrouping.paginate(groups, 1);
      expect(page.totalCount, 3);
      expect(page.totalPurchases, 4);
      expect(page.total, 9310);
      expect(page.totalPaid, 150);
      expect(page.totalBalance, 9160);
      expect(page.totalItems, 3);
    });

    test('off builds no groups', () {
      expect(
        PurchaseGrouping.build(all, PurchaseGroupBy.off),
        isEmpty,
      );
    });

    test('labels', () {
      expect(PurchaseGroupBy.supplier.label, 'Supplier');
      expect(PurchaseGroupBy.supplier.pagerLabel, 'suppliers');
    });
  });

  group('table state', () {
    test('Reset All clears filters, keeps grouping and sorts', () {
      final state = PurchaseReportTableState(
        filters: PurchaseReportFilters(
          search: 'acme',
          supplierKey: 'sup-a',
          status: PurchaseStatus.unpaid,
          totalMin: 5,
        ),
        groupBy: PurchaseGroupBy.supplier,
        sortField: PurchasesSortField.balance,
        ascending: true,
        groupSortField: PurchaseGroupSortField.count,
        page: 3,
      );
      state.resetAll();
      expect(state.filters.hasAnything, isFalse);
      expect(state.page, 1);
      expect(state.groupBy, PurchaseGroupBy.supplier);
      expect(state.grouped, isTrue);
      expect(state.sortField, PurchasesSortField.balance);
      expect(state.ascending, isTrue);
      expect(
        state.groupSortField,
        PurchaseGroupSortField.count,
      );
    });

    test('defaults', () {
      final state = PurchaseReportTableState();
      expect(state.grouped, isFalse);
      expect(state.sortField, PurchasesSortField.createdAt);
      expect(state.ascending, isFalse);
    });
  });
}
