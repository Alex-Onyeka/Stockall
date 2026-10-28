import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/classes/temp_orders/orders.dart';
import 'package:stockall/pages/report/components/report_group_by.dart';
import 'package:stockall/pages/report/order_report/order_report_table/class/order_report_table_logic.dart';
import 'package:stockall/pages/report/order_report/order_report_table/components/order_report_table_view.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/providers/theme_provider.dart';

import 'order_report_fixtures.dart';

Future<void> pumpTable(
  WidgetTester tester, {
  required bool isDesktop,
  required OrderReportTableEnv env,
  OrderReportFilters? filters,
}) async {
  // Mobile is below mobileScreen (650), so the toolbar sits behind
  // "View". Not narrower: the test font draws every glyph 1em
  // wide, which pushes the shared ReportPager row past 400 px.
  tester.view.physicalSize =
      isDesktop ? const Size(1800, 1000) : const Size(500, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ChangeNotifierProvider<ThemeProvider>(
      create: (_) => ThemeProvider(),
      child: MaterialApp(
        home: OrderReportTableView(
          isDesktop: isDesktop,
          initialFilters: filters,
          initialPeriod: const ReceiptsReportPeriod.allTime(),
          env: env,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  if (!isDesktop) {
    // Below mobileScreen the toolbar sits behind "View".
    await tester.tap(find.text('View'));
    await tester.pumpAndSettle();
  }
}

OrderReportRow row(
  Orders order, [
  List<TempMainReceipt> receipts = const [],
]) {
  return OrderReportRowBuilder.buildSingle(
    order: order,
    receipts: receipts,
  );
}

List<OrderReportRow> query(
  List<OrderReportRow> rows,
  OrderReportFilters filters, {
  ReceiptsReportPeriod period = const ReceiptsReportPeriod.allTime(),
  OrderSortField sortField = OrderSortField.createdAt,
  bool ascending = false,
  bool departmentsEnabled = true,
  bool subStaffEnabled = true,
  bool profitVisible = true,
  TimeOfDay? closingTime,
}) {
  return OrderReportQuery.filterAndSort(
    rows: rows,
    period: period,
    filters: filters,
    sortField: sortField,
    ascending: ascending,
    departmentsEnabled: departmentsEnabled,
    subStaffEnabled: subStaffEnabled,
    profitVisible: profitVisible,
    closingTime: closingTime,
  );
}

void main() {
  group('Delivery status', () {
    test('nothing delivered is Undelivered', () {
      final r = row(testOrder());
      expect(r.status, OrderDeliveryStatus.undelivered);
      expect(r.recordsDisagree, isFalse);
      expect(r.delivery.orderedItems, 10);
      expect(r.delivery.deliveredItems, 0);
      expect(r.deliveredValue, 0);
      expect(r.undeliveredValue, 50);
    });

    test('stored and receipts agree: Partially Delivered', () {
      final r = row(
        testOrder(lines: [orderLine(remaining: 6)]),
        [
          deliveryReceipt(items: [deliveredLine(quantity: 4)]),
        ],
      );
      expect(r.status, OrderDeliveryStatus.partial);
      expect(r.recordsDisagree, isFalse);
      expect(r.delivery.deliveredItems, 4);
      expect(r.deliveredValue, closeTo(20, 1e-9));
      expect(r.undeliveredValue, closeTo(30, 1e-9));
      expect(r.deliveryCount, 1);
    });

    test('everything delivered is Fully Delivered', () {
      final r = row(
        testOrder(lines: [orderLine(remaining: 0)]),
        [
          deliveryReceipt(items: [deliveredLine(quantity: 10)]),
        ],
      );
      expect(r.status, OrderDeliveryStatus.full);
      expect(r.recordsDisagree, isFalse);
      expect(r.deliveredValue, 50);
      expect(r.undeliveredValue, 0);
    });

    test('over-delivery is Fully Delivered and flagged', () {
      final r = row(
        testOrder(lines: [orderLine(remaining: 0)]),
        [
          deliveryReceipt(items: [deliveredLine(quantity: 12)]),
        ],
      );
      expect(r.status, OrderDeliveryStatus.full);
      expect(r.recordsDisagree, isTrue);
      expect(r.delivery.products.single.isOverDelivered, isTrue);
      expect(r.delivery.deliveredItems, 12);
      // Value is capped at the order total.
      expect(r.deliveredValue, 50);
      expect(r.undeliveredValue, 0);
    });

    test('stored ahead of receipts: max is used, flagged', () {
      final r = row(testOrder(lines: [orderLine(remaining: 6)]));
      expect(r.status, OrderDeliveryStatus.partial);
      expect(r.delivery.deliveredItems, 4);
      expect(r.recordsDisagree, isTrue);
    });

    test('receipts ahead of stored: max is used, flagged', () {
      final r = row(
        testOrder(lines: [orderLine(remaining: 10)]),
        [
          deliveryReceipt(items: [deliveredLine(quantity: 4)]),
        ],
      );
      expect(r.status, OrderDeliveryStatus.partial);
      expect(r.delivery.deliveredItems, 4);
      expect(r.recordsDisagree, isTrue);
    });

    test('receipt without lines: stored only, not a mismatch', () {
      final r = row(
        testOrder(lines: [orderLine(remaining: 6)]),
        [deliveryReceipt(items: null)],
      );
      expect(r.status, OrderDeliveryStatus.partial);
      expect(r.delivery.receiptLinesUnavailable, isTrue);
      expect(r.delivery.products.single.fromReceipts, isNull);
      expect(r.recordsDisagree, isFalse);
      expect(r.delivery.deliveredItems, 4);
    });

    test('legacy product_sales lines are used when items is empty', () {
      final order = testOrder(lines: [orderLine(remaining: 6)]);
      final rows = OrderReportRowBuilder.buildAll(
        orders: [order],
        allReceipts: [deliveryReceipt(items: [])],
        allProductSales: [
          deliveredLine(quantity: 4, receiptUuid: 'rec-1'),
        ],
      );
      final r = rows.single;
      expect(r.delivery.receiptLinesUnavailable, isFalse);
      expect(r.delivery.products.single.fromReceipts, 4);
      expect(r.recordsDisagree, isFalse);
    });

    test('void receipt lines are left out', () {
      final r = row(
        testOrder(lines: [orderLine(remaining: 6)]),
        [
          deliveryReceipt(
            items: [
              deliveredLine(quantity: 4),
              deliveredLine(quantity: 3, isVoid: true),
            ],
          ),
        ],
      );
      expect(r.recordsDisagree, isFalse);
      expect(r.delivery.deliveredItems, 4);
    });

    test('a delivered product the order lacks is a mismatch', () {
      final r = row(
        testOrder(lines: [orderLine(remaining: 0)]),
        [
          deliveryReceipt(
            items: [
              deliveredLine(quantity: 10),
              deliveredLine(product: 'product-z', quantity: 1),
            ],
          ),
        ],
      );
      expect(r.status, OrderDeliveryStatus.full);
      expect(r.recordsDisagree, isTrue);
    });

    test('a failed unit conversion leaves status unknown', () {
      final bad = testUnit('bad', conversion: 0);
      final r = row(
        testOrder(
          lines: [orderLine(units: [bad], unitUuid: 'bad')],
          total: 50,
        ),
      );
      expect(r.status, isNull);
      expect(r.delivery.quantitiesUnavailable, isTrue);
      expect(r.deliveredValue, isNull);
      expect(r.undeliveredValue, isNull);
      expect(r.cost, isNull);
      expect(r.profit, isNull);
    });
  });

  group('Units', () {
    test('order unit is converted to primary units', () {
      final r = row(
        testOrder(
          lines: [
            orderLine(
              quantity: 2,
              remaining: 1,
              unitUuid: 'case',
            ),
          ],
        ),
        [
          deliveryReceipt(items: [deliveredLine(quantity: 12)]),
        ],
      );
      expect(r.delivery.orderedItems, 24);
      expect(r.delivery.deliveredItems, 12);
      expect(r.recordsDisagree, isFalse);
      expect(r.status, OrderDeliveryStatus.partial);
    });

    test('delivery receipt unit is converted too', () {
      final r = row(
        testOrder(
          lines: [
            orderLine(
              quantity: 2,
              remaining: 1,
              unitUuid: 'case',
            ),
          ],
        ),
        [
          deliveryReceipt(
            items: [deliveredLine(quantity: 1, unitUuid: 'case')],
          ),
        ],
      );
      expect(r.recordsDisagree, isFalse);
      expect(r.delivery.deliveredItems, 12);
    });

    test('lines of the same product are added together', () {
      final r = row(
        testOrder(
          lines: [
            orderLine(uuid: 'l1', quantity: 5, remaining: 0),
            orderLine(uuid: 'l2', quantity: 5, remaining: 5),
          ],
        ),
        [
          deliveryReceipt(items: [deliveredLine(quantity: 5)]),
        ],
      );
      final p = r.delivery.products.single;
      expect(p.ordered, 10);
      expect(p.stored, 5);
      expect(p.fromReceipts, 5);
      expect(r.recordsDisagree, isFalse);
      expect(r.status, OrderDeliveryStatus.partial);
    });

    test('2D lines use the line area', () {
      final r = row(
        testOrder(
          lines: [
            orderLine(
              quantity: 2,
              remaining: 1,
              units: [eachUnit],
              quantityType: 2,
              width: 2,
              height: 3,
            ),
          ],
        ),
        [
          deliveryReceipt(
            items: [
              deliveredLine(
                quantity: 1,
                quantityType: 2,
                width: 2,
                height: 3,
              ),
            ],
          ),
        ],
      );
      expect(r.delivery.orderedItems, 12);
      expect(r.delivery.deliveredItems, 6);
      expect(r.recordsDisagree, isFalse);
    });
  });

  group('Values', () {
    test('delivered value is prorated with discount and VAT', () {
      final order = testOrder(
        lines: [
          orderLine(product: 'a', revenue: 6, remaining: 0),
          orderLine(uuid: 'l2', product: 'b', revenue: 4),
        ],
        originalCost: 100,
        generalDiscount: 10,
        vat: 10,
        total: 99,
      );
      final r = row(order, [
        deliveryReceipt(
          items: [deliveredLine(product: 'a', quantity: 10)],
        ),
      ]);
      expect(r.status, OrderDeliveryStatus.partial);
      expect(r.discountAmount, 10);
      expect(r.vatAmount, 10);
      // a is 60 of the 100 line value.
      expect(r.deliveredValue, closeTo(59.4, 1e-9));
      expect(r.undeliveredValue, closeTo(39.6, 1e-9));
    });

    test('part of a product counts by its share', () {
      final r = row(
        testOrder(
          lines: [
            orderLine(product: 'a', remaining: 5),
            orderLine(uuid: 'l2', product: 'b'),
          ],
          total: 100,
        ),
        [
          deliveryReceipt(
            items: [deliveredLine(product: 'a', quantity: 5)],
          ),
        ],
      );
      expect(r.deliveredValue, closeTo(25, 1e-9));
      expect(r.undeliveredValue, closeTo(75, 1e-9));
    });

    test('free items are weighed by quantity', () {
      final r = row(
        testOrder(
          lines: [orderLine(revenue: 0, remaining: 5)],
          total: 0,
        ),
        [
          deliveryReceipt(items: [deliveredLine(quantity: 5)]),
        ],
      );
      expect(r.delivery.deliveredFraction, closeTo(0.5, 1e-9));
    });

    test('Est. profit is total minus cost, VAT kept in revenue', () {
      final lines = [
        orderLine(revenue: 10, costPrice: 2, remaining: 10),
      ];
      final r = row(
        testOrder(
          lines: lines,
          originalCost: 100,
          vat: 10,
          total: 110,
        ),
      );
      expect(r.cost, 20);
      expect(r.profit, 90);
      expect(r.margin, closeTo(90 / 110 * 100, 1e-9));
      expect(r.profitIsEstimate, isTrue);
    });

    test('profit stops being an estimate when Fully Delivered', () {
      final r = row(
        testOrder(lines: [orderLine(remaining: 0)]),
        [
          deliveryReceipt(items: [deliveredLine(quantity: 10)]),
        ],
      );
      expect(r.profit, 30);
      expect(r.profitIsEstimate, isFalse);
    });

    test('Partially Delivered profit is still the whole order', () {
      final r = row(
        testOrder(lines: [orderLine(remaining: 6)]),
        [
          deliveryReceipt(items: [deliveredLine(quantity: 4)]),
        ],
      );
      expect(r.profit, 30);
      expect(r.profitIsEstimate, isTrue);
    });

    test('no cost price: cost and profit are unknown', () {
      final r = row(
        testOrder(lines: [orderLine(costPrice: null)]),
      );
      expect(r.cost, isNull);
      expect(r.profit, isNull);
      expect(r.margin, isNull);
    });
  });

  group('Payments', () {
    test('overpaid: Balance is 0, Paid is the real amount', () {
      final r = row(testOrder(), [
        deliveryReceipt(cash: 30, bank: 40, items: [deliveredLine()]),
      ]);
      expect(r.paid, 70);
      expect(r.balance, 0);
    });

    test('a non-delivery receipt adds to Paid, not to delivered', () {
      final r = row(
        testOrder(lines: [orderLine(remaining: 10)]),
        [
          deliveryReceipt(
            salesTypeIndex: 1,
            cash: 30,
            items: [deliveredLine(quantity: 4)],
          ),
        ],
      );
      expect(r.paid, 30);
      expect(r.balance, 20);
      expect(r.channel, OrderPaymentChannel.cash);
      expect(r.delivery.deliveredItems, 0);
      expect(r.status, OrderDeliveryStatus.undelivered);
      expect(r.deliveryCount, 0);
      expect(r.recordsDisagree, isFalse);
      expect(r.delivery.receiptLinesUnavailable, isFalse);
    });

    test('totals add the clamped balances', () {
      final rows = [
        row(testOrder(uuid: 'o1'), [
          deliveryReceipt(
            orderUuid: 'o1',
            cash: 70,
            items: [deliveredLine()],
          ),
        ]),
        row(testOrder(uuid: 'o2'), [
          deliveryReceipt(
            uuid: 'rec-2',
            orderUuid: 'o2',
            cash: 20,
            items: [deliveredLine()],
          ),
        ]),
      ];
      final page = OrderReportQuery.paginate(rows, 1);
      expect(page.totals.paid, 90);
      expect(page.totals.balance, 30);
    });

    test('channel comes from the delivery receipt amounts', () {
      OrderPaymentChannel channelOf(List<TempMainReceipt> recs) =>
          row(testOrder(), recs).channel;

      expect(
        channelOf([deliveryReceipt(cash: 10)]),
        OrderPaymentChannel.cash,
      );
      expect(
        channelOf([deliveryReceipt(bank: 10)]),
        OrderPaymentChannel.bank,
      );
      expect(
        channelOf([deliveryReceipt(account: 10)]),
        OrderPaymentChannel.account,
      );
      expect(
        channelOf([
          deliveryReceipt(cash: 10),
          deliveryReceipt(uuid: 'rec-2', account: 5),
        ]),
        OrderPaymentChannel.split,
      );
      expect(channelOf([]), OrderPaymentChannel.unpaid);
      expect(
        channelOf([deliveryReceipt()]),
        OrderPaymentChannel.unpaid,
      );
    });

    test('channel filter: All / Cash / Bank / Account / Split / Unpaid', () {
      OrderReportRow paidWith(
        String id, {
        double cash = 0,
        double bank = 0,
        double account = 0,
      }) => row(testOrder(uuid: id), [
        deliveryReceipt(
          uuid: 'rec-$id',
          orderUuid: id,
          cash: cash,
          bank: bank,
          account: account,
        ),
      ]);

      final rows = [
        paidWith('cash', cash: 5),
        paidWith('bank', bank: 5),
        paidWith('account', account: 5),
        paidWith('split', cash: 5, bank: 5),
        paidWith('unpaid'),
      ];

      expect(query(rows, OrderReportFilters()).length, 5);
      for (final c in OrderPaymentChannel.values) {
        final out = query(rows, OrderReportFilters(channel: c));
        expect(out.map((r) => r.uuid), [c.name], reason: c.label);
      }
    });
  });

  group('Filters', () {
    final synced = row(
      testOrder(uuid: 'synced', lines: [orderLine(remaining: 6)]),
      [
        deliveryReceipt(
          orderUuid: 'synced',
          items: [deliveredLine(quantity: 4)],
        ),
      ],
    );
    final mismatched = row(
      testOrder(uuid: 'mismatch', lines: [orderLine(remaining: 6)]),
    );
    final full = row(
      testOrder(uuid: 'full', lines: [orderLine(remaining: 0)]),
      [
        deliveryReceipt(
          orderUuid: 'full',
          items: [deliveredLine(quantity: 10)],
        ),
      ],
    );
    final none = row(
      testOrder(
        uuid: 'none',
        staffId: null,
        staffName: null,
        customerId: null,
        customerName: null,
        barcode: '777123',
      ),
    );
    final rows = [synced, mismatched, full, none];

    test('records disagree shows only mismatched orders', () {
      final f = OrderReportFilters(recordsDisagree: true);
      expect(query(rows, f).map((r) => r.uuid), ['mismatch']);
      expect(f.activeCount, 1);
      expect(f.copy().recordsDisagree, isTrue);
    });

    test('delivery status filter', () {
      expect(
        query(
          rows,
          OrderReportFilters(
            deliveryStatus: OrderDeliveryStatus.full,
          ),
        ).map((r) => r.uuid),
        ['full'],
      );
      expect(
        query(
          rows,
          OrderReportFilters(
            deliveryStatus: OrderDeliveryStatus.partial,
          ),
        ).map((r) => r.uuid).toSet(),
        {'synced', 'mismatch'},
      );
      expect(
        query(
          rows,
          OrderReportFilters(
            deliveryStatus: OrderDeliveryStatus.undelivered,
          ),
        ).map((r) => r.uuid),
        ['none'],
      );
    });

    test('none key matches orders without staff or customer', () {
      expect(
        query(
          rows,
          OrderReportFilters(staffKey: orderReportNoneKey),
        ).map((r) => r.uuid),
        ['none'],
      );
      expect(
        query(
          rows,
          OrderReportFilters(customerKey: orderReportNoneKey),
        ).map((r) => r.uuid),
        ['none'],
      );
    });

    test('search matches id and barcode', () {
      expect(
        query(rows, OrderReportFilters(search: '777')).map(
          (r) => r.uuid,
        ),
        ['none'],
      );
      expect(none.displayId, '#777123');
    });

    test('balance range uses the clamped balance', () {
      final overpaid = row(testOrder(uuid: 'over'), [
        deliveryReceipt(orderUuid: 'over', cash: 80),
      ]);
      final out = query(
        [overpaid, none],
        OrderReportFilters(balanceMin: 0, balanceMax: 0),
      );
      expect(out.map((r) => r.uuid), ['over']);
    });

    test('an invalid range is not applied', () {
      final f = OrderReportFilters(totalMin: 100, totalMax: 1);
      expect(f.totalRangeError, isNotNull);
      expect(query(rows, f).length, rows.length);
    });

    test('profit range is ignored when profit is hidden', () {
      final f = OrderReportFilters(profitMin: 1000);
      expect(query(rows, f), isEmpty);
      expect(
        query(rows, f, profitVisible: false).length,
        rows.length,
      );
    });

    test('Reset All clears every filter', () {
      final f = OrderReportFilters(
        search: 'x',
        staffKey: 's',
        customerKey: 'c',
        subStaffKey: 'ss',
        departmentKey: 'd',
        channel: OrderPaymentChannel.account,
        deliveryStatus: OrderDeliveryStatus.partial,
        recordsDisagree: true,
        totalMin: 1,
        paidMax: 2,
        balanceMin: 3,
        profitMax: 4,
      );
      expect(f.activeCount, 11);
      f.clearAll();
      expect(f.hasAnything, isFalse);
      expect(f.recordsDisagree, isFalse);
      expect(f.channel, isNull);
      expect(f.deliveryStatus, isNull);
    });

    test('Reset All keeps Group by: grouping is not a filter', () {
      var groupBy = ReportGroupBy.staff;
      final f = OrderReportFilters(recordsDisagree: true);
      f.clearAll();
      // The view keeps groupBy itself; clearAll has nothing to
      // reset it with.
      expect(groupBy, ReportGroupBy.staff);
      final groups = OrderReportGrouping.build(
        query(rows, f),
        groupBy,
      );
      expect(groups.fold<int>(0, (s, g) => s + g.count), 4);
    });
  });

  group('Period', () {
    const closing = TimeOfDay(hour: 4, minute: 0);
    final rows = [
      row(
        testOrder(
          uuid: 'before-close',
          createdAt: DateTime(2026, 10, 18, 3, 30),
        ),
      ),
      row(
        testOrder(
          uuid: 'after-close',
          createdAt: DateTime(2026, 10, 18, 4, 30),
        ),
      ),
      row(
        testOrder(
          uuid: 'older',
          createdAt: DateTime(2026, 10, 10, 12),
        ),
      ),
    ];

    test('a business day runs to the closing time', () {
      final out = query(
        rows,
        OrderReportFilters(),
        period: ReceiptsReportPeriod.day(DateTime(2026, 10, 17)),
        closingTime: closing,
      );
      expect(out.map((r) => r.uuid), ['before-close']);
    });

    test('today follows the closing time', () {
      final today = ReceiptsReportPeriod.today(
        now: DateTime(2026, 10, 18, 3, 45),
        closingTime: closing,
      );
      expect(today.start, DateTime(2026, 10, 17));
    });

    test('range and all time', () {
      expect(
        query(
          rows,
          OrderReportFilters(),
          period: ReceiptsReportPeriod.range(
            DateTime(2026, 10, 10),
            DateTime(2026, 10, 18),
          ),
          closingTime: closing,
        ).length,
        3,
      );
      expect(query(rows, OrderReportFilters()).length, 3);
    });
  });

  group('Paging and totals', () {
    final rows = [
      for (var i = 0; i < 150; i++)
        row(
          testOrder(
            uuid: 'o$i',
            createdAt: DateTime(2026, 10, 17, 12).add(
              Duration(minutes: i),
            ),
          ),
          [
            deliveryReceipt(
              uuid: 'r$i',
              orderUuid: 'o$i',
              cash: 10,
            ),
          ],
        ),
    ];

    test('totals cover the full filtered set on every page', () {
      final sorted = query(rows, OrderReportFilters());
      final p1 = OrderReportQuery.paginate(sorted, 1);
      final p2 = OrderReportQuery.paginate(sorted, 2);
      expect(p1.rows.length, 100);
      expect(p2.rows.length, 50);
      expect(p2.firstIndex, 101);
      expect(p2.lastIndex, 150);
      for (final p in [p1, p2]) {
        expect(p.totals.count, 150);
        expect(p.totals.total, 7500);
        expect(p.totals.paid, 1500);
        expect(p.totals.balance, 6000);
        expect(p.totals.undeliveredValue, 7500);
        expect(p.totals.profit, 150 * 30);
      }
    });

    test('a page past the end is clamped', () {
      final p = OrderReportQuery.paginate(rows, 9);
      expect(p.page, 2);
      expect(OrderReportQuery.paginate([], 3).totalPages, 1);
    });

    test('unknown values sink in both sort directions', () {
      final unknown = row(
        testOrder(
          uuid: 'unknown',
          lines: [
            orderLine(
              units: [testUnit('bad', conversion: 0)],
              unitUuid: 'bad',
            ),
          ],
          total: 1,
        ),
      );
      final list = [unknown, rows.first, rows.last];
      for (final asc in [true, false]) {
        final out = query(
          list,
          OrderReportFilters(),
          sortField: OrderSortField.status,
          ascending: asc,
        );
        expect(out.last.uuid, 'unknown');
      }
    });
  });

  group('Grouping', () {
    final rows = [
      row(
        testOrder(
          uuid: 'a1',
          staffId: 's1',
          staffName: 'Old Ada',
          createdAt: DateTime(2026, 10, 1),
        ),
        [deliveryReceipt(orderUuid: 'a1', cash: 10)],
      ),
      row(
        testOrder(
          uuid: 'a2',
          staffId: 's1',
          staffName: 'Ada',
          createdAt: DateTime(2026, 10, 2),
        ),
        [deliveryReceipt(uuid: 'r2', orderUuid: 'a2', bank: 10)],
      ),
      row(
        testOrder(
          uuid: 'b1',
          staffId: 's2',
          staffName: 'Zed',
          customerId: null,
          customerName: null,
        ),
      ),
      row(
        testOrder(
          uuid: 'n1',
          staffId: null,
          staffName: null,
        ),
        [
          deliveryReceipt(uuid: 'r3', orderUuid: 'n1', account: 5),
        ],
      ),
    ];

    List<String> labels(
      ReportGroupBy by,
      OrderGroupSortField field,
      bool asc,
    ) => OrderReportGrouping.sort(
      OrderReportGrouping.build(rows, by),
      field: field,
      ascending: asc,
    ).map((g) => g.label).toList();

    test('staff: newest name, No staff last', () {
      expect(
        labels(ReportGroupBy.staff, OrderGroupSortField.name, true),
        ['Ada', 'Zed', orderNoStaffLabel],
      );
      expect(
        labels(ReportGroupBy.staff, OrderGroupSortField.name, false),
        ['Zed', 'Ada', orderNoStaffLabel],
      );
    });

    test('customer: No customer last', () {
      final out = labels(
        ReportGroupBy.customer,
        OrderGroupSortField.count,
        false,
      );
      expect(out.last, orderNoCustomerLabel);
    });

    test('channel: Unpaid last in both directions', () {
      for (final asc in [true, false]) {
        final out = labels(
          ReportGroupBy.channel,
          OrderGroupSortField.name,
          asc,
        );
        expect(out.last, 'Unpaid');
        expect(out.toSet(), {'Cash', 'Bank', 'Account', 'Unpaid'});
      }
    });

    test('group totals equal the ungrouped totals', () {
      final groups = OrderReportGrouping.build(
        rows,
        ReportGroupBy.staff,
      );
      final page = OrderReportGrouping.paginate(groups, rows, 1);
      final flat = OrderReportQuery.paginate(rows, 1).totals;
      expect(page.totals.total, flat.total);
      expect(page.totals.paid, flat.paid);
      expect(page.totals.balance, flat.balance);
      expect(
        groups.fold<double>(0, (s, g) => s + g.balance),
        flat.balance,
      );
    });

    test('off gives no groups', () {
      expect(
        OrderReportGrouping.build(rows, ReportGroupBy.off),
        isEmpty,
      );
    });
  });

  group('Department scope', () {
    final orders = [
      testOrder(uuid: 'd1', departmentUuid: 'dept-1'),
      testOrder(uuid: 'd2', departmentUuid: 'dept-2'),
      testOrder(uuid: 'other-shop', shopId: 2),
    ];

    List<String?> scoped({
      bool enabled = true,
      bool viewAll = false,
      String? current = 'dept-1',
    }) => OrderReportScope.scope(
      orders: orders,
      shopId: 1,
      departmentsEnabled: enabled,
      canViewAllDepartments: viewAll,
      currentDepartmentUuid: current,
    ).map((o) => o.uuid).toList();

    test('restricted user sees the current department only', () {
      expect(scoped(), ['d1']);
    });

    test('view all, departments off, or no current department', () {
      expect(scoped(viewAll: true), ['d1', 'd2']);
      expect(scoped(enabled: false), ['d1', 'd2']);
      expect(scoped(current: null), ['d1', 'd2']);
    });
  });

  group('Table screen', () {
    // o1: Ada, stored 4 with no receipts, so its records disagree.
    // o2: no staff, Fully Delivered and in sync.
    final orders = [
      testOrder(
        uuid: 'o1',
        staffId: 's1',
        staffName: 'Ada',
        lines: [orderLine(remaining: 6)],
      ),
      testOrder(
        uuid: 'o2',
        staffId: null,
        staffName: null,
        lines: [orderLine(remaining: 0)],
      ),
    ];
    final receipts = [
      deliveryReceipt(
        uuid: 'r2',
        orderUuid: 'o2',
        cash: 50,
        items: [deliveredLine(quantity: 10)],
      ),
    ];

    for (final isDesktop in [true, false]) {
      testWidgets(
        'Reset All keeps Group by (${isDesktop ? 'desktop' : 'mobile'})',
        (tester) async {
          await pumpTable(
            tester,
            isDesktop: isDesktop,
            env: fakeEnv(orders: orders, receipts: receipts),
            filters: OrderReportFilters(recordsDisagree: true),
          );
          expect(find.text('Reset All Filters'), findsOneWidget);

          await tester.tap(find.text('Group by'));
          await tester.pumpAndSettle();
          await tester.tap(
            find.descendant(
              of: find.byType(PopupMenuItem<ReportGroupBy>),
              matching: find.text('Staff'),
            ),
          );
          await tester.pumpAndSettle();
          expect(find.text('Group by: Staff'), findsOneWidget);
          // Only o1 passes the filter.
          expect(find.text('Ada'), findsOneWidget);
          expect(find.text(orderNoStaffLabel), findsNothing);

          await tester.tap(find.text('Reset All Filters'));
          await tester.pumpAndSettle();

          expect(find.text('Reset All Filters'), findsNothing);
          expect(find.text('Group by: Staff'), findsOneWidget);
          // Still grouped, now over every order.
          expect(find.text('Ada'), findsOneWidget);
          expect(find.text(orderNoStaffLabel), findsOneWidget);
        },
      );
    }

    testWidgets('rows show the mismatch note and Est. profit', (
      tester,
    ) async {
      await pumpTable(
        tester,
        isDesktop: true,
        env: fakeEnv(orders: orders, receipts: receipts),
      );
      expect(find.text('Records disagree'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
      // o1 is Partially Delivered: estimate. o2 is not, so its
      // 30 has no label; the totals row (60) is an estimate.
      expect(find.text('Est. N30.0'), findsOneWidget);
      expect(find.text('Est. N60.0'), findsOneWidget);
      expect(find.textContaining('Est.'), findsNWidgets(2));
    });

    testWidgets('profit and margin are hidden without cost access', (
      tester,
    ) async {
      await pumpTable(
        tester,
        isDesktop: true,
        env: fakeEnv(
          orders: orders,
          receipts: receipts,
          canSeeCost: false,
        ),
      );
      expect(find.text('Profit/Loss'), findsNothing);
      expect(find.text('Margin (%)'), findsNothing);
      expect(find.text('Cost'), findsNothing);
    });

    testWidgets('profit and margin show with cost access', (
      tester,
    ) async {
      await pumpTable(
        tester,
        isDesktop: true,
        env: fakeEnv(orders: orders, receipts: receipts),
      );
      expect(find.text('Profit/Loss'), findsOneWidget);
      expect(find.text('Margin (%)'), findsOneWidget);
    });

    testWidgets('tapping a row opens the order', (tester) async {
      final opened = <Orders>[];
      await pumpTable(
        tester,
        isDesktop: true,
        env: fakeEnv(
          orders: orders,
          receipts: receipts,
          opened: opened,
        ),
      );
      await tester.tap(find.text('#1'));
      await tester.pumpAndSettle();
      expect(opened.map((o) => o.uuid), ['o1']);
    });
  });
}
