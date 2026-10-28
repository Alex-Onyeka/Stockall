import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/temp_purchase/temp_purchase.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/class/purchase_report_table_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/supplier_report/supplier_report_table/class/supplier_report_table_logic.dart';

import 'supplier_report_fixtures.dart';

void main() {
  group('initial period', () {
    final now = DateTime(2026, 10, 17, 15);

    test('all time with View Date', () {
      expect(
        supplierReportInitialPeriod(canPickDate: true).isAllTime,
        isTrue,
      );
    });

    test('a passed period wins with View Date', () {
      final p = ReceiptsReportPeriod.day(DateTime(2026, 10, 3));
      expect(
        supplierReportInitialPeriod(
          canPickDate: true,
          initial: p,
        ),
        same(p),
      );
    });

    test('today without View Date, whatever was passed', () {
      final p = supplierReportInitialPeriod(
        canPickDate: false,
        initial: const ReceiptsReportPeriod.allTime(),
        now: now,
        closingTime: midnight,
      );
      expect(p.isAllTime, isFalse);
      expect(p.isSingleDay, isTrue);
      expect(p.start, DateTime(2026, 10, 17));
    });
  });

  group('SupplierReportAccess.scope', () {
    final all = [
      supplier('shared'),
      supplier('a', departmentId: 'dept-a'),
      supplier('b', departmentId: 'dept-b'),
    ];
    List<String?> scope({
      required bool departmentsEnabled,
      required bool canViewAll,
      required String? current,
    }) => SupplierReportAccess.scope(
      suppliers: all,
      departmentsEnabled: departmentsEnabled,
      canViewAllDepartments: canViewAll,
      currentDepartmentUuid: current,
    ).map((s) => s.uuid).toList();

    test('departments off: everyone', () {
      expect(
        scope(
          departmentsEnabled: false,
          canViewAll: false,
          current: 'dept-a',
        ),
        ['shared', 'a', 'b'],
      );
    });

    test('a department: its own and shared suppliers', () {
      for (final canViewAll in [true, false]) {
        expect(
          scope(
            departmentsEnabled: true,
            canViewAll: canViewAll,
            current: 'dept-a',
          ),
          ['shared', 'a'],
        );
      }
    });

    test('view all departments, none picked: everyone', () {
      expect(
        scope(
          departmentsEnabled: true,
          canViewAll: true,
          current: null,
        ),
        ['shared', 'a', 'b'],
      );
    });

    test('no department and no view all: shared only', () {
      expect(
        scope(
          departmentsEnabled: true,
          canViewAll: false,
          current: null,
        ),
        ['shared'],
      );
    });
  });

  group('rows', () {
    test('a supplier without purchases still shows, at 0', () {
      final r = rowOf(
        supplierRows(
          suppliers: [supplier('sup-a', name: 'Acme')],
          purchases: const [],
        ),
        'sup-a',
      );
      expect(r.label, 'Acme');
      expect(r.purchaseCount, 0);
      expect(r.spend, 0);
      expect(r.paid, 0);
      expect(r.balance, 0);
      expect(r.hasBalance, isFalse);
      expect(r.average, 0);
      expect(r.firstPurchase, isNull);
      expect(r.lastPurchase, isNull);
      expect(r.inScope, isTrue);
      expect(r.isDeleted, isFalse);
    });

    test('purchases without a supplier are not a row', () {
      final result = supplierRows(
        suppliers: [supplier('sup-a')],
        purchases: [
          bought(1, supplierId: 'sup-a'),
          bought(2, supplierId: null),
          bought(3, supplierId: '  '),
        ],
      );
      expect(result.map((r) => r.key), ['sup-a']);
      expect(rowOf(result, 'sup-a').purchaseCount, 1);
    });

    test('totals, average and first / last purchase', () {
      final r = rowOf(
        supplierRows(
          suppliers: [supplier('sup-a')],
          purchases: [
            bought(1, supplierId: 'sup-a', day: 5, total: 100),
            bought(
              2,
              supplierId: 'sup-a',
              day: 20,
              total: 300,
              paid: 120,
            ),
            bought(3, supplierId: 'sup-a', day: 9, total: 200),
          ],
        ),
        'sup-a',
      );
      expect(r.purchaseCount, 3);
      expect(r.spend, 600);
      expect(r.paid, 120);
      expect(r.balance, 480);
      expect(r.average, 200);
      expect(r.firstPurchase, DateTime(2026, 10, 5, 12));
      expect(r.lastPurchase, DateTime(2026, 10, 20, 12));
    });

    test('an overpaid purchase owes 0, not a credit', () {
      final r = rowOf(
        supplierRows(
          suppliers: [supplier('sup-a')],
          purchases: [
            bought(1, supplierId: 'sup-a', total: 100, paid: 150),
            bought(2, supplierId: 'sup-a', total: 100, paid: 60),
          ],
        ),
        'sup-a',
      );
      expect(r.paid, 210);
      expect(r.balance, 40);
      expect(r.hasBalance, isTrue);
    });

    test('only purchases in the period count', () {
      final r = rowOf(
        supplierRows(
          suppliers: [supplier('sup-a')],
          purchases: [
            bought(1, supplierId: 'sup-a', day: 3, total: 100),
            bought(2, supplierId: 'sup-a', day: 17, total: 40),
          ],
          period: ReceiptsReportPeriod.day(DateTime(2026, 10, 17)),
        ),
        'sup-a',
      );
      expect(r.purchaseCount, 1);
      expect(r.spend, 40);
      expect(r.firstPurchase, DateTime(2026, 10, 17, 12));
    });

    test('purchases queued for deletion are left out', () {
      final purchases = [
        bought(1, supplierId: 'sup-a', total: 100),
        bought(2, supplierId: 'sup-a', total: 40),
      ];
      final r = rowOf(
        SupplierReportRowBuilder.build(
          suppliers: [supplier('sup-a')],
          purchaseRows: PurchaseReportRowBuilder.buildAll(
            purchases: purchases,
            pendingDeletedUuids: {uuidN(2)},
          ),
          period: const ReceiptsReportPeriod.allTime(),
          departmentsEnabled: false,
        ),
        'sup-a',
      );
      expect(r.spend, 100);
    });

    test('a deleted supplier with purchases shows as deleted', () {
      final result = supplierRows(
        suppliers: [supplier('sup-a')],
        purchases: [
          bought(
            1,
            supplierId: 'gone',
            supplierName: 'Old Name',
            day: 3,
          ),
          bought(
            2,
            supplierId: 'gone',
            supplierName: 'Gone Ltd',
            day: 10,
            total: 50,
          ),
        ],
      );
      final r = rowOf(result, 'gone');
      expect(r.isDeleted, isTrue);
      expect(r.inScope, isFalse);
      // The newest name saved on its purchases.
      expect(r.label, 'Gone Ltd');
      expect(r.phone, isNull);
      expect(r.country, isNull);
      expect(r.purchaseCount, 2);
      expect(r.spend, 150);
    });

    test('a deleted supplier without a saved name is Not Set', () {
      final r = rowOf(
        supplierRows(
          suppliers: const [],
          purchases: [
            bought(1, supplierId: 'gone', supplierName: null),
          ],
        ),
        'gone',
      );
      expect(r.name, isNull);
      expect(r.label, 'Not Set');
    });

    test('another department\'s supplier with visible purchases '
        'keeps its details', () {
      final other = supplier(
        'sup-b',
        name: 'Bolt',
        phone: '0801',
        departmentId: 'dept-b',
      );
      final result = supplierRows(
        suppliers: [supplier('sup-a')],
        allSuppliers: [supplier('sup-a'), other],
        purchases: [bought(1, supplierId: 'sup-b', total: 70)],
      );
      final r = rowOf(result, 'sup-b');
      expect(r.isDeleted, isFalse);
      expect(r.inScope, isFalse);
      expect(r.label, 'Bolt');
      expect(r.phone, '0801');
      expect(r.spend, 70);
    });

    test('another department\'s supplier without visible purchases '
        'is not a row', () {
      final result = supplierRows(
        suppliers: [supplier('sup-a')],
        allSuppliers: [
          supplier('sup-a'),
          supplier('sup-b', departmentId: 'dept-b'),
        ],
        purchases: const [],
      );
      expect(result.map((r) => r.key), ['sup-a']);
    });

    test('the current name wins over the one saved on purchases', () {
      final r = rowOf(
        supplierRows(
          suppliers: [supplier('sup-a', name: 'Acme Ltd')],
          purchases: [
            bought(1, supplierId: 'sup-a', supplierName: 'Acme'),
          ],
        ),
        'sup-a',
      );
      expect(r.label, 'Acme Ltd');
    });

    test('blank details are not set', () {
      final r = rowOf(
        supplierRows(
          suppliers: [
            supplier(
              'sup-a',
              phone: '',
              email: '  ',
              address: '',
              city: ' Ikeja ',
              state: '',
              country: ' Nigeria',
            ),
          ],
          purchases: const [],
        ),
        'sup-a',
      );
      expect(r.phone, isNull);
      expect(r.email, isNull);
      expect(r.address, isNull);
      expect(r.addressLine, 'Ikeja');
      expect(r.fullAddress, 'Ikeja, Nigeria');
      expect(r.state, isNull);
      expect(r.country, 'Nigeria');
      expect(r.countryKey, 'nigeria');
    });

    test('a supplier listed twice is one row; no uuid, no row', () {
      final noUuid = supplier('x')..uuid = null;
      final result = supplierRows(
        suppliers: [
          supplier('sup-a', name: 'First'),
          supplier('sup-a', name: 'Second'),
          noUuid,
        ],
        purchases: const [],
      );
      expect(result.map((r) => r.label), ['First']);
    });
  });

  group('reconciliation with the Purchase Report', () {
    final suppliers = [
      supplier('sup-a', name: 'Acme'),
      supplier('sup-b', name: 'Bolt'),
      supplier('sup-c', name: 'Idle'),
    ];
    final purchases = <TempPurchase>[
      bought(1, supplierId: 'sup-a', day: 2, total: 100, paid: 100),
      bought(2, supplierId: 'sup-a', day: 17, total: 250, paid: 50),
      bought(3, supplierId: 'sup-b', day: 17, total: 80, paid: 120),
      bought(4, supplierId: 'sup-b', day: 18, total: 60),
      bought(5, supplierId: null, day: 17, total: 999, paid: 10),
      bought(6, supplierId: 'gone', supplierName: 'Gone', total: 30),
    ];

    for (final period in [
      const ReceiptsReportPeriod.allTime(),
      ReceiptsReportPeriod.range(
        DateTime(2026, 10, 17),
        DateTime(2026, 10, 18),
      ),
    ]) {
      final name = period.isAllTime ? 'all time' : 'a range';

      test('totals = purchase table - "No supplier" ($name)', () {
        final page = SupplierReportQuery.paginate(
          supplierRows(
            suppliers: suppliers,
            purchases: purchases,
            period: period,
          ),
          1,
        );
        final table = purchaseTable(purchases, period: period);
        final none = purchaseTable(
          purchases,
          period: period,
          filters: PurchaseReportFilters(
            supplierKey: purchaseReportNoneKey,
          ),
        );
        expect(
          page.totalPurchases,
          table.totalCount - none.totalCount,
        );
        expect(page.totalSpend, table.total - none.total);
        expect(page.totalPaid, table.totalPaid - none.totalPaid);
        expect(
          page.totalBalance,
          table.totalBalance - none.totalBalance,
        );
      });

      test('each row = the purchase table on that supplier '
          '($name)', () {
        final result = supplierRows(
          suppliers: suppliers,
          purchases: purchases,
          period: period,
        );
        for (final r in result) {
          final table = purchaseTable(
            purchases,
            period: period,
            filters: PurchaseReportFilters(supplierKey: r.key),
          );
          expect(r.purchaseCount, table.totalCount, reason: r.key);
          expect(r.spend, table.total, reason: r.key);
          expect(r.paid, table.totalPaid, reason: r.key);
          expect(r.balance, table.totalBalance, reason: r.key);
        }
      });
    }
  });

  group('filters and search', () {
    final result = supplierRows(
      suppliers: [
        supplier(
          'a',
          name: 'Acme Foods',
          phone: '08011112222',
          email: 'sales@acme.ng',
          address: '12 Allen Avenue',
          city: 'Ikeja',
          state: 'Lagos',
          country: 'Nigeria',
        ),
        supplier(
          'b',
          name: 'Bolt',
          state: 'Abuja',
          country: 'nigeria ',
        ),
        supplier(
          'c',
          name: 'Cedi Traders',
          state: 'Greater Accra',
          country: 'Ghana',
        ),
        supplier('d', name: 'Dangote'),
      ],
      purchases: [bought(1, supplierId: 'b', total: 100)],
    );
    List<String> keys(SupplierReportFilters f) =>
        result.where(f.matches).map((r) => r.key).toList();

    test('search covers name, contact and address, any case', () {
      for (final (q, expected) in [
        ('acme', ['a']),
        ('0801111', ['a']),
        ('SALES@', ['a']),
        ('allen', ['a']),
        ('ikeja', ['a']),
        ('lagos', ['a']),
        ('ghana', ['c']),
        ('nigeria', ['a', 'b']),
        ('  bolt ', ['b']),
        ('nobody', <String>[]),
      ]) {
        expect(
          keys(SupplierReportFilters(search: q)),
          expected,
          reason: q,
        );
      }
    });

    test('country ignores case and spaces; Not set matches none', () {
      expect(
        keys(SupplierReportFilters(countryKey: 'nigeria')),
        ['a', 'b'],
      );
      expect(
        keys(
          SupplierReportFilters(
            countryKey: purchaseReportNoneKey,
          ),
        ),
        ['d'],
      );
    });

    test('state', () {
      expect(
        keys(SupplierReportFilters(stateKey: 'abuja')),
        ['b'],
      );
    });

    test('has balance owed', () {
      expect(keys(SupplierReportFilters(hasBalance: true)), ['b']);
    });

    test('filters combine with AND', () {
      expect(
        keys(
          SupplierReportFilters(
            countryKey: 'nigeria',
            hasBalance: true,
          ),
        ),
        ['b'],
      );
      expect(
        keys(
          SupplierReportFilters(
            search: 'acme',
            hasBalance: true,
          ),
        ),
        isEmpty,
      );
    });

    test('counts, and clearing', () {
      final f = SupplierReportFilters(
        search: 'x',
        countryKey: 'nigeria',
        stateKey: 'lagos',
        hasBalance: true,
      );
      expect(f.activeCount, 3);
      expect(f.hasAnything, isTrue);
      final copy = f.copy();
      f.clearFiltersOnly();
      expect(f.activeCount, 0);
      expect(f.search, 'x');
      expect(f.hasAnything, isTrue);
      f.clearAll();
      expect(f.hasAnything, isFalse);
      // The copy is independent.
      expect(copy.activeCount, 3);
    });

    test('a new country clears a state that is not one of its', () {
      final f = SupplierReportFilters(stateKey: 'lagos');
      f.setCountry('nigeria', result);
      expect(f.stateKey, 'lagos');
      f.setCountry('ghana', result);
      expect(f.countryKey, 'ghana');
      expect(f.stateKey, isNull);
    });

    test('country and state options', () {
      final countries = SupplierReportOptions.countries(result);
      expect(countries.map((o) => o.key), [
        'ghana',
        'nigeria',
        purchaseReportNoneKey,
      ]);
      expect(countries.map((o) => o.label), [
        'Ghana',
        'Nigeria',
        'Not set',
      ]);
      expect(
        SupplierReportOptions.states(result).map((o) => o.label),
        ['Abuja', 'Greater Accra', 'Lagos', 'Not set'],
      );
      expect(
        SupplierReportOptions.states(
          result,
          countryKey: 'nigeria',
        ).map((o) => o.label),
        ['Abuja', 'Lagos'],
      );
    });
  });

  group('sorting', () {
    final result = supplierRows(
      suppliers: [
        supplier('a', name: 'acme', phone: '0803'),
        supplier('b', name: 'Bolt', phone: '0801'),
        supplier('c', name: 'Cobalt'),
        supplier('d', name: 'Bolt'),
      ],
      purchases: [
        bought(1, supplierId: 'a', day: 3, total: 100),
        bought(2, supplierId: 'b', day: 9, total: 500),
        bought(3, supplierId: 'd', day: 5, total: 500),
      ],
    );
    List<String> sorted(SupplierSortField f, bool asc) =>
        SupplierReportQuery.filterAndSort(
          rows: result,
          filters: SupplierReportFilters(),
          sortField: f,
          ascending: asc,
        ).map((r) => r.key).toList();

    test('names first A-Z, amounts and dates largest first', () {
      expect(
        SupplierReportQuery.defaultAscending(
          SupplierSortField.name,
        ),
        isTrue,
      );
      for (final f in [
        SupplierSortField.purchases,
        SupplierSortField.spend,
        SupplierSortField.paid,
        SupplierSortField.balance,
        SupplierSortField.lastPurchase,
      ]) {
        expect(
          SupplierReportQuery.defaultAscending(f),
          isFalse,
          reason: f.name,
        );
      }
    });

    test('name ignores case; ties by key', () {
      expect(sorted(SupplierSortField.name, true), [
        'a',
        'b',
        'd',
        'c',
      ]);
    });

    test('highest spend first, ties by name then key', () {
      expect(sorted(SupplierSortField.spend, false), [
        'b',
        'd',
        'a',
        'c',
      ]);
      expect(sorted(SupplierSortField.spend, true), [
        'c',
        'a',
        'b',
        'd',
      ]);
    });

    test('no last purchase sinks in both directions', () {
      expect(sorted(SupplierSortField.lastPurchase, false), [
        'b',
        'd',
        'a',
        'c',
      ]);
      expect(sorted(SupplierSortField.lastPurchase, true), [
        'a',
        'd',
        'b',
        'c',
      ]);
    });

    test('address sorts by country, state, then street', () {
      final located = supplierRows(
        suppliers: [
          supplier('a', country: 'Nigeria', state: 'Lagos'),
          supplier('b', country: 'Ghana', state: 'Volta'),
          supplier(
            'c',
            country: 'nigeria',
            state: 'Abuja',
            address: 'Z Street',
          ),
          supplier(
            'd',
            country: 'Nigeria',
            state: 'Abuja',
            address: 'A Street',
          ),
          supplier('e'),
        ],
        purchases: const [],
      );
      List<String> keys(bool asc) =>
          SupplierReportQuery.filterAndSort(
            rows: located,
            filters: SupplierReportFilters(),
            sortField: SupplierSortField.address,
            ascending: asc,
          ).map((r) => r.key).toList();
      expect(keys(true), ['b', 'd', 'c', 'a', 'e']);
      expect(keys(false), ['a', 'c', 'd', 'b', 'e']);
    });

    test('no phone sinks', () {
      expect(sorted(SupplierSortField.phone, true), [
        'b',
        'a',
        'd',
        'c',
      ]);
    });
  });

  group('table state', () {
    test('opens on Name A-Z', () {
      final s = SupplierReportTableState();
      expect(s.sortField, SupplierSortField.name);
      expect(s.ascending, isTrue);
    });

    test('the biggest supplier is one tap away', () {
      final s = SupplierReportTableState()..page = 3;
      s.setSort(SupplierSortField.spend);
      expect(s.sortField, SupplierSortField.spend);
      expect(s.ascending, isFalse);
      expect(s.page, 1);
      s.setSort(SupplierSortField.spend);
      expect(s.ascending, isTrue);
    });

    test('Reset All keeps the sort', () {
      final s = SupplierReportTableState(
        filters: SupplierReportFilters(
          search: 'x',
          hasBalance: true,
        ),
      )..setSort(SupplierSortField.balance);
      s.page = 2;
      s.resetAll();
      expect(s.filters.hasAnything, isFalse);
      expect(s.sortField, SupplierSortField.balance);
      expect(s.page, 1);
    });
  });

  group('pagination', () {
    final many = [
      for (var i = 0; i < 250; i++)
        supplier('s$i', name: 'Supplier $i'),
    ];
    final purchases = [
      for (var i = 0; i < 250; i++)
        bought(i + 1, supplierId: 's$i', total: 10, paid: 4),
    ];
    final result = supplierRows(
      suppliers: many,
      purchases: purchases,
    );

    test('pages of 100, totals over every filtered row', () {
      final page = SupplierReportQuery.paginate(result, 3);
      expect(page.totalPages, 3);
      expect(page.rows.length, 50);
      expect(page.firstIndex, 201);
      expect(page.lastIndex, 250);
      expect(page.totalCount, 250);
      expect(page.totalPurchases, 250);
      expect(page.totalSpend, 2500);
      expect(page.totalPaid, 1000);
      expect(page.totalBalance, 1500);
    });

    test('the page is clamped', () {
      expect(SupplierReportQuery.paginate(result, 9).page, 3);
      expect(SupplierReportQuery.paginate(result, 0).page, 1);
      final empty = SupplierReportQuery.paginate(const [], 4);
      expect(empty.page, 1);
      expect(empty.totalPages, 1);
      expect(empty.firstIndex, 0);
      expect(empty.lastIndex, 0);
    });
  });

  test('closing time moves a purchase to the previous day', () {
    final early = purchase(
      uuid: uuidN(1),
      createdAt: DateTime(2026, 10, 17, 3),
      supplierId: 'sup-a',
    );
    final r = rowOf(
      SupplierReportRowBuilder.build(
        suppliers: [supplier('sup-a')],
        purchaseRows: rows([early]),
        period: ReceiptsReportPeriod.day(DateTime(2026, 10, 16)),
        departmentsEnabled: false,
        closingTime: const TimeOfDay(hour: 4, minute: 0),
      ),
      'sup-a',
    );
    expect(r.purchaseCount, 1);
  });
}
