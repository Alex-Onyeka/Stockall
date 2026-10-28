import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/temp_product_class/units_class/product_units_class.dart';
import 'package:stockall/classes/temp_purchase/temp_purchase.dart';
import 'package:stockall/classes/temp_suppliers/suppliers_class.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_summary/class/receipts_report_summary_logic.dart';
import 'package:stockall/pages/report/supplier_report/supplier_analysis/class/supplier_analysis_logic.dart';

import 'supplier_report_fixtures.dart';

void main() {
  final now = DateTime(2026, 10, 31, 15);

  SupplierAnalysisResult analyse(
    String key,
    List<TempPurchase> purchases, {
    List<SuppliersClass>? suppliers,
    List<SuppliersClass>? allSuppliers,
    ReceiptsReportPeriod period = const ReceiptsReportPeriod.allTime(),
  }) {
    final scoped = suppliers ?? [supplier('sup-a', name: 'Acme')];
    return SupplierAnalysisBuilder.build(
      supplierKey: key,
      purchaseRows: rows(purchases),
      suppliers: scoped,
      allSuppliers: allSuppliers ?? scoped,
      period: period,
      departmentsEnabled: false,
      closingTime: midnight,
      now: now,
    );
  }

  group('KPIs', () {
    final purchases = [
      bought(1, supplierId: 'sup-a', day: 4, total: 100, paid: 100),
      bought(2, supplierId: 'sup-a', day: 12, total: 300, paid: 50),
      bought(3, supplierId: 'sup-a', day: 20, total: 80, paid: 100),
      bought(4, supplierId: 'sup-b', day: 12, total: 999),
      bought(5, supplierId: null, day: 12, total: 999),
    ];

    test('only this supplier\'s purchases', () {
      final r = analyse('sup-a', purchases);
      final s = r.supplier;
      expect(s.label, 'Acme');
      expect(s.purchaseCount, 3);
      expect(s.spend, 480);
      expect(s.paid, 250);
      // 0 + 250 + 0: the overpaid purchase owes nothing.
      expect(s.balance, 250);
      expect(s.average, 160);
      expect(s.firstPurchase, DateTime(2026, 10, 4, 12));
      expect(s.lastPurchase, DateTime(2026, 10, 20, 12));
    });

    test('the same numbers as the table row and "See all"', () {
      for (final period in [
        const ReceiptsReportPeriod.allTime(),
        ReceiptsReportPeriod.range(
          DateTime(2026, 10, 10),
          DateTime(2026, 10, 25),
        ),
      ]) {
        final a = analyse('sup-a', purchases, period: period);
        final row = rowOf(
          supplierRows(
            suppliers: [supplier('sup-a', name: 'Acme')],
            purchases: purchases,
            period: period,
          ),
          'sup-a',
        );
        final table = purchaseTable(
          purchases,
          period: period,
          filters: a.tableFilters,
        );
        expect(a.tableFilters.supplierKey, 'sup-a');
        expect(a.tableFilters.activeCount, 1);
        for (final (count, spend, paid, balance) in [
          (row.purchaseCount, row.spend, row.paid, row.balance),
          (table.totalCount, table.total, table.totalPaid,
              table.totalBalance),
        ]) {
          expect(a.supplier.purchaseCount, count);
          expect(a.supplier.spend, spend);
          expect(a.supplier.paid, paid);
          expect(a.supplier.balance, balance);
        }
        expect(a.rows.length, table.totalCount);
      }
    });

    test('a supplier without purchases', () {
      final r = analyse('sup-a', const []);
      expect(r.supplier.purchaseCount, 0);
      expect(r.supplier.spend, 0);
      expect(r.supplier.average, 0);
      expect(r.supplier.firstPurchase, isNull);
      expect(r.rows, isEmpty);
      expect(r.recent, isEmpty);
      expect(r.hasMore, isFalse);
      expect(r.topItems, isEmpty);
      // All time without purchases has no span to chart.
      expect(r.trend, isEmpty);
      expect(r.interval, isNull);
    });

    test('a deleted supplier, from its purchases', () {
      final r = analyse('gone', [
        bought(1, supplierId: 'gone', supplierName: 'Gone Ltd'),
      ]);
      expect(r.supplier.isDeleted, isTrue);
      expect(r.supplier.inScope, isFalse);
      expect(r.supplier.label, 'Gone Ltd');
      expect(r.supplier.purchaseCount, 1);
    });

    test('a deleted supplier keeps its saved name in an empty '
        'period', () {
      final r = analyse(
        'gone',
        [
          bought(1, supplierId: 'gone', supplierName: 'Old', day: 2),
          bought(2, supplierId: 'gone', supplierName: 'Gone', day: 4),
        ],
        period: ReceiptsReportPeriod.day(DateTime(2026, 10, 20)),
      );
      expect(r.supplier.name, isNull);
      expect(r.supplier.purchaseCount, 0);
      expect(r.title, 'Gone');
      expect(analyse('nobody', const []).title, 'Not Set');
      // A live supplier's current name wins.
      expect(
        analyse('sup-a', [
          bought(1, supplierId: 'sup-a', supplierName: 'Old'),
        ]).title,
        'Acme',
      );
    });

    test('another department\'s supplier keeps its details', () {
      final other = supplier(
        'sup-b',
        name: 'Bolt',
        email: 'b@bolt.ng',
        departmentId: 'dept-b',
      );
      final r = analyse(
        'sup-b',
        purchases,
        suppliers: [supplier('sup-a')],
        allSuppliers: [supplier('sup-a'), other],
      );
      expect(r.supplier.isDeleted, isFalse);
      expect(r.supplier.inScope, isFalse);
      expect(r.supplier.email, 'b@bolt.ng');
      expect(r.supplier.spend, 999);
    });
  });

  group('recent purchases', () {
    test('newest 5 first; ties by uuid; see all when more', () {
      final purchases = [
        for (var i = 1; i <= 7; i++)
          bought(i, supplierId: 'sup-a', day: i == 7 ? 6 : i),
      ];
      final r = analyse('sup-a', purchases);
      expect(r.rows.length, 7);
      expect(r.hasMore, isTrue);
      // Purchases 6 and 7 share a day: the table's tie-breaker.
      expect(
        r.recent.map((p) => p.uuid),
        [uuidN(6), uuidN(7), uuidN(5), uuidN(4), uuidN(3)],
      );
    });

    test('no "See all" with 5 or fewer', () {
      final r = analyse('sup-a', [
        for (var i = 1; i <= 5; i++)
          bought(i, supplierId: 'sup-a', day: i),
      ]);
      expect(r.recent.length, 5);
      expect(r.hasMore, isFalse);
    });

    test('only the period\'s purchases', () {
      final r = analyse(
        'sup-a',
        [
          bought(1, supplierId: 'sup-a', day: 2),
          bought(2, supplierId: 'sup-a', day: 17),
        ],
        period: ReceiptsReportPeriod.day(DateTime(2026, 10, 17)),
      );
      expect(r.recent.map((p) => p.uuid), [uuidN(2)]);
    });
  });

  group('spend trend', () {
    test('buckets add up to the supplier\'s spend and paid', () {
      final r = analyse('sup-a', [
        bought(1, supplierId: 'sup-a', day: 3, total: 100, paid: 20),
        bought(2, supplierId: 'sup-a', day: 3, total: 50),
        bought(3, supplierId: 'sup-a', day: 9, total: 70, paid: 70),
        bought(4, supplierId: 'sup-b', day: 9, total: 999),
      ]);
      expect(r.interval, ReceiptsTrendInterval.daily);
      expect(
        r.trend.fold<double>(0, (s, p) => s + p.spend),
        r.supplier.spend,
      );
      expect(
        r.trend.fold<double>(0, (s, p) => s + p.paid),
        r.supplier.paid,
      );
      // All time runs from the first purchase to today.
      expect(r.trend.first.start, DateTime(2026, 10, 3));
      expect(r.trend.last.start, DateTime(2026, 10, 31));
      expect(r.trend.first.spend, 150);
      expect(r.trend.first.purchaseCount, 2);
    });

    test('a period without purchases charts zeros', () {
      final r = analyse(
        'sup-a',
        const [],
        period: ReceiptsReportPeriod.range(
          DateTime(2026, 10, 1),
          DateTime(2026, 10, 7),
        ),
      );
      expect(r.trend.length, 7);
      expect(r.trend.every((p) => p.spend == 0), isTrue);
    });
  });

  group('top items', () {
    test('by line spend across purchases', () {
      final r = analyse('sup-a', [
        bought(
          1,
          supplierId: 'sup-a',
          day: 3,
          total: 500,
          items: [
            namedLine(
              purchaseId: uuidN(1),
              itemId: 'rice',
              itemName: 'Rice (old name)',
              quantity: 2,
              total: 200,
            ),
            namedLine(
              purchaseId: uuidN(1),
              itemId: 'oil',
              itemName: 'Oil',
              quantity: 3,
              total: 300,
            ),
          ],
        ),
        bought(
          2,
          supplierId: 'sup-a',
          day: 9,
          total: 400,
          items: [
            namedLine(
              purchaseId: uuidN(2),
              itemId: 'rice',
              itemName: 'Rice',
              quantity: 1,
              total: 150,
            ),
            // The same item twice in one purchase: one purchase.
            namedLine(
              purchaseId: uuidN(2),
              itemId: 'rice',
              itemName: 'Rice',
              quantity: 1,
              total: 250,
            ),
          ],
        ),
      ]);
      expect(r.topItems.map((i) => i.key), ['rice', 'oil']);
      final rice = r.topItems.first;
      expect(rice.name, 'Rice');
      expect(rice.spend, 600);
      expect(rice.items, 4);
      expect(rice.purchaseCount, 2);
      expect(rice.lastBought, DateTime(2026, 10, 9, 12));
      final oil = r.topItems.last;
      expect(oil.spend, 300);
      expect(oil.purchaseCount, 1);
      expect(oil.lastBought, DateTime(2026, 10, 3, 12));
    });

    test('lines without an item group by name; storage items '
        'by their id', () {
      final r = analyse('sup-a', [
        bought(
          1,
          supplierId: 'sup-a',
          items: [
            namedLine(
              purchaseId: uuidN(1),
              itemId: null,
              itemName: 'Nails',
              total: 10,
            ),
            namedLine(
              purchaseId: uuidN(1),
              itemId: null,
              itemName: 'nails ',
              total: 15,
            ),
            namedLine(
              purchaseId: uuidN(1),
              itemId: null,
              storageItemId: 'store-1',
              itemName: 'Cement',
              total: 40,
            ),
            namedLine(
              purchaseId: uuidN(1),
              itemId: null,
              itemName: null,
              total: 5,
            ),
          ],
        ),
      ]);
      expect(r.topItems.map((i) => (i.key, i.name, i.spend)), [
        ('store-1', 'Cement', 40.0),
        ('name:nails', 'Nails', 25.0),
        ('name:unknown item', supplierUnknownItemLabel, 5.0),
      ]);
    });

    test('an area line is one item, as in the purchase report', () {
      final area = testUnit(
        'sqm',
        dimensionType: ProductUnitsClass.areaUnit,
      );
      final l = namedLine(
        purchaseId: uuidN(1),
        quantity: 12.5,
        unitUuid: 'sqm',
      )..unitsList = [area];
      final r = analyse('sup-a', [
        bought(1, supplierId: 'sup-a', items: [l]),
      ]);
      expect(r.topItems.single.items, 1);
    });

    test('purchases without lines are counted, not listed', () {
      final r = analyse('sup-a', [
        bought(1, supplierId: 'sup-a', noItems: true),
        bought(2, supplierId: 'sup-a'),
      ]);
      expect(r.purchasesWithoutLines, 1);
      expect(r.topItems.single.purchaseCount, 1);
    });

    test('custom totals are flagged: item spend differs', () {
      final r = analyse('sup-a', [
        bought(
          1,
          supplierId: 'sup-a',
          total: 90,
          isCustomPriceSet: true,
          items: [namedLine(purchaseId: uuidN(1), total: 100)],
        ),
        bought(2, supplierId: 'sup-a', total: 50),
      ]);
      expect(r.adjustedPurchases, 1);
      expect(r.supplier.spend, 140);
      expect(r.topItems.single.spend, 150);
    });

    test('at most 5; ties by items, then name', () {
      final r = analyse('sup-a', [
        bought(
          1,
          supplierId: 'sup-a',
          items: [
            for (final (id, qty) in [
              ('f', 1.0),
              ('e', 1.0),
              ('d', 2.0),
              ('c', 1.0),
              ('b', 1.0),
              ('a', 1.0),
            ])
              namedLine(
                purchaseId: uuidN(1),
                itemId: id,
                itemName: id.toUpperCase(),
                quantity: qty,
                total: 10,
              ),
          ],
        ),
      ]);
      expect(r.topItems.map((i) => i.key), [
        'd',
        'a',
        'b',
        'c',
        'e',
      ]);
      final all = SupplierAnalysisBuilder.topItems(
        r.rows,
        limit: null,
      );
      expect(all.items.length, 6);
    });
  });
}
