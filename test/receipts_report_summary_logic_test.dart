import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/classes/temp_product_slaes_record/temp_product_sale_record.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_summary/class/receipts_report_summary_logic.dart';

const midnight = TimeOfDay(hour: 0, minute: 0);
const four = TimeOfDay(hour: 4, minute: 0);

int _seq = 0;

TempMainReceipt receipt({
  String? uuid,
  DateTime? createdAt,
  int? salesTypeIndex = 1,
  double cash = 0,
  double bank = 0,
  double? account,
  String? staffId = 'staff-a',
  String? staffName = 'Ada',
  String? customerUuid,
  String? customerName,
  String? subStaffUuid,
  String? subStaffName,
  String? departmentUuid,
  String? departmentName,
  double? fixedDiscount,
  double? vat,
  double? originalCost,
  String? invoiceUuid,
  List<TempProductSaleRecord>? items,
}) {
  _seq++;
  return TempMainReceipt(
    uuid: uuid ?? 'r$_seq',
    barcode: '$_seq',
    createdAt: createdAt ?? DateTime(2026, 10, 17, 12),
    shopId: 1,
    staffId: staffId,
    staffName: staffName,
    customerUuid: customerUuid,
    customerName: customerName,
    paymentMethod: 'Cash',
    bank: bank,
    cashAlt: cash,
    customerAccount: account,
    departmentName: departmentName,
    departmentUuidNew: departmentUuid,
    isInvoice: invoiceUuid != null,
    invoiceUuid: invoiceUuid,
    fixedDiscount: fixedDiscount,
    vat: vat,
    originalCost: originalCost,
    subStaffUuid: subStaffUuid,
    subStaffName: subStaffName,
    cartName: null,
    comment: null,
    salesTypeIndex: salesTypeIndex,
    items: items,
  );
}

TempProductSaleRecord line({
  double quantity = 1,
  double revenue = 0,
  double? costPrice,
}) {
  return TempProductSaleRecord(
    createdAt: DateTime(2026, 10, 17, 12),
    productId: 1,
    productName: 'Item',
    shopId: 1,
    staffId: 'staff-a',
    staffName: 'Ada',
    recepitId: 0,
    quantity: quantity,
    revenue: revenue,
    discountedAmount: null,
    originalCost: revenue,
    discount: null,
    costPrice: costPrice,
    customPriceSet: false,
    departmentName: null,
    departmentUuid: null,
    isProductManaged: true,
    useGroupQuantity: false,
    qttyPerGroup: null,
    isVoid: false,
    unitsList: null,
    unitUuid: null,
    pricesList: null,
    priceUuid: null,
    widthDimension: null,
    heightDimension: null,
    quantityType: null,
    manageSalesWastage: null,
    isPercentageWastage: false,
    wastageAmount: null,
  );
}

List<ReceiptsReportRow> rowsOf(
  List<TempMainReceipt> receipts,
) => ReceiptsReportRowBuilder.buildAll(
  receipts: receipts,
  legacySales: const [],
);

List<ReceiptsReportRow> tableRows(
  List<ReceiptsReportRow> rows,
  ReceiptsReportFilters filters, {
  ReceiptsReportPeriod period =
      const ReceiptsReportPeriod.allTime(),
}) {
  return ReceiptsReportQuery.filterAndSort(
    rows: rows,
    period: period,
    filters: filters,
    sortField: ReceiptsSortField.createdAt,
    ascending: false,
    departmentsEnabled: true,
    subStaffEnabled: true,
    profitVisible: true,
    closingTime: midnight,
  );
}

void main() {
  // A small shop day: three sales, an invoice payment, an order
  // delivery and a sale without item data.
  late List<ReceiptsReportRow> rows;

  setUp(() {
    rows = rowsOf([
      receipt(
        uuid: 's1',
        staffId: 'st1',
        staffName: 'Ada',
        customerUuid: 'c1',
        customerName: 'Chidi',
        departmentUuid: 'd1',
        departmentName: 'Bar',
        subStaffUuid: 'sub1',
        subStaffName: 'Tobi',
        cash: 1000,
        fixedDiscount: 100,
        vat: 10,
        originalCost: 1000,
        items: [
          line(quantity: 2, revenue: 1000, costPrice: 600),
        ],
      ),
      receipt(
        uuid: 's2',
        staffId: 'st2',
        staffName: 'Bola',
        customerUuid: 'c2',
        customerName: 'Emeka',
        departmentUuid: 'd1',
        departmentName: 'Bar',
        cash: 300,
        bank: 200,
        items: [
          line(quantity: 3, revenue: 500, costPrice: 700),
        ],
      ),
      receipt(
        uuid: 's3',
        staffId: 'st1',
        staffName: 'Ada',
        customerUuid: null,
        departmentUuid: null,
        bank: 400,
        items: [line(quantity: 1, revenue: 400)],
      ),
      receipt(
        uuid: 'i1',
        salesTypeIndex: 2,
        invoiceUuid: 'inv',
        staffId: 'st2',
        staffName: 'Bola',
        customerUuid: 'c1',
        customerName: 'Chidi',
        departmentUuid: 'd2',
        departmentName: 'Kitchen',
        account: 250,
        fixedDiscount: 999,
        vat: 10,
        originalCost: 5000,
        items: [
          line(quantity: 9, revenue: 250, costPrice: 50),
        ],
      ),
      receipt(
        uuid: 'o1',
        salesTypeIndex: 3,
        staffId: 'st1',
        staffName: 'Ada',
        customerUuid: 'c3',
        customerName: 'Femi',
        departmentUuid: 'd2',
        departmentName: 'Kitchen',
        cash: 150,
        items: [
          line(quantity: 4, revenue: 150, costPrice: 100),
        ],
      ),
      receipt(
        uuid: 'n1',
        staffId: null,
        staffName: null,
        customerUuid: 'c2',
        customerName: 'Emeka',
        cash: 50,
      ),
    ]);
  });

  group('stats', () {
    test('counts by type and channel', () {
      final s = ReceiptsSummaryBuilder.stats(rows);
      expect(s.totalReceipts, 6);
      expect(s.typeCount(ReceiptType.sales), 4);
      expect(s.typeCount(ReceiptType.invoicePayment), 1);
      expect(s.typeCount(ReceiptType.orderDelivery), 1);
      expect(s.channelCount(ReceiptChannel.cash), 3);
      expect(s.channelCount(ReceiptChannel.bank), 1);
      expect(s.channelCount(ReceiptChannel.split), 1);
      expect(
        s.channelCount(ReceiptChannel.customerAccount),
        1,
      );
    });

    test('revenue counts every receipt type', () {
      final s = ReceiptsSummaryBuilder.stats(rows);
      expect(
        s.totalRevenue,
        1000 + 500 + 400 + 250 + 150 + 50,
      );
    });

    test('average is per Sales receipt', () {
      final s = ReceiptsSummaryBuilder.stats(rows);
      expect(s.salesCount, 4);
      expect(
        s.averageReceiptValue,
        (1000 + 500 + 400 + 50) / 4,
      );
    });

    test('profit is known profit only, with coverage', () {
      final s = ReceiptsSummaryBuilder.stats(rows);
      // 400 - 200 + 400 (cost missing) + 200 + 50
      expect(s.knownProfit, 850);
      expect(s.profitKnownCount, 5);
      expect(s.profitUnknownCount, 1);
      expect(s.costMissingCount, 1);
    });

    test(
      'discount and VAT skip invoice and order rows',
      () {
        final s = ReceiptsSummaryBuilder.stats(rows);
        expect(s.totalDiscount, 100);
        expect(s.totalVat, 100);
      },
    );

    test('items skip invoice payments', () {
      final s = ReceiptsSummaryBuilder.stats(rows);
      expect(s.totalItems, 2 + 3 + 1 + 4);
    });

    test(
      'distinct customers and staff, walk-ins apart',
      () {
        final s = ReceiptsSummaryBuilder.stats(rows);
        expect(s.distinctCustomers, 3);
        expect(s.walkInReceipts, 1);
        expect(s.distinctStaff, 2);
        expect(s.noStaffReceipts, 1);
      },
    );

    test('collected by method uses the stored amounts', () {
      final s = ReceiptsSummaryBuilder.stats(rows);
      expect(s.collectedCash, 1000 + 300 + 150 + 50);
      expect(s.collectedBank, 200 + 400);
      expect(s.collectedAccount, 250);
      expect(
        s.collectedCash +
            s.collectedBank +
            s.collectedAccount,
        s.totalRevenue,
      );
    });

    test('empty data never divides by zero', () {
      final s = ReceiptsSummaryBuilder.stats(const []);
      expect(s.totalReceipts, 0);
      expect(s.averageReceiptValue, 0);
      expect(s.knownProfit, 0);
      expect(
        ReceiptsSummaryBuilder.channels(const []).every(
          (c) =>
              c.countShare == null && c.valueShare == null,
        ),
        isTrue,
      );
    });
  });

  group('groups', () {
    test('each receipt is counted once per section', () {
      for (final groups in [
        ReceiptsSummaryBuilder.customers(rows),
        ReceiptsSummaryBuilder.staff(rows),
        ReceiptsSummaryBuilder.subStaff(rows),
        ReceiptsSummaryBuilder.departments(rows),
      ]) {
        expect(
          groups.fold<int>(0, (s, g) => s + g.receiptCount),
          rows.length,
        );
        final share = groups.fold<double>(
          0,
          (s, g) => s + (g.revenueShare ?? 0),
        );
        expect(share, closeTo(100, 1e-9));
      }
    });

    test('departments: no department is Others, last', () {
      final d = ReceiptsSummaryBuilder.departments(rows);
      expect(d.map((g) => g.label), [
        'Bar',
        'Kitchen',
        'Others',
      ]);
      expect(d.last.key, receiptsReportNoneKey);
      expect(d.first.revenue, 1500);
      expect(d.first.salesCount, 2);
      expect(d.first.average, 750);
    });

    test('customers: No Customer row comes last', () {
      final c = ReceiptsSummaryBuilder.customers(rows);
      expect(c.last.label, 'No Customer');
      expect(c.last.isNone, isTrue);
      final chidi = c.firstWhere((g) => g.key == 'c1');
      expect(chidi.receiptCount, 2);
      expect(chidi.revenue, 1250);
      expect(chidi.salesCount, 1);
      expect(chidi.average, 1000);
      expect(chidi.lastDate, DateTime(2026, 10, 17, 12));
    });

    test('groups use the newest name for a key', () {
      final g = ReceiptsSummaryBuilder.staff(
        rowsOf([
          receipt(
            staffId: 'x',
            staffName: 'Old',
            createdAt: DateTime(2026, 1, 1),
          ),
          receipt(
            staffId: 'x',
            staffName: 'New',
            createdAt: DateTime(2026, 2, 1),
          ),
        ]),
      );
      expect(g.single.label, 'New');
    });

    test('group profit counts unknowns separately', () {
      final c = ReceiptsSummaryBuilder.customers(rows);
      final emeka = c.firstWhere((g) => g.key == 'c2');
      expect(emeka.knownProfit, -200);
      expect(emeka.profitKnownCount, 1);
      expect(emeka.profitUnknownCount, 1);
    });

    test(
      'revenue share is null when there is no revenue',
      () {
        final g = ReceiptsSummaryBuilder.customers(
          rowsOf([receipt(customerUuid: 'z')]),
        );
        expect(g.single.revenueShare, isNull);
      },
    );
  });

  group('rankings', () {
    List<ReceiptsSummaryGroup> groups(
      List<(String, double, int)> data,
    ) {
      final out = <ReceiptsSummaryGroup>[];
      for (final (name, revenue, count) in data) {
        final g =
            ReceiptsSummaryGroup(name, name)
              ..revenue = revenue
              ..receiptCount = count;
        out.add(g);
      }
      out.add(
        ReceiptsSummaryGroup(
            receiptsReportNoneKey,
            'No Customer',
          )
          ..revenue = 1e9
          ..receiptCount = 99,
      );
      return out;
    }

    test('top 3 by revenue, ties by count then name', () {
      final g = groups([
        ('b', 500, 1),
        ('a', 500, 1),
        ('c', 500, 3),
        ('d', 900, 1),
        ('e', 100, 1),
      ]);
      expect(
        ReceiptsSummaryBuilder.top3(g).map((x) => x.key),
        ['d', 'c', 'a'],
      );
    });

    test('least 3 by revenue, ties by fewer receipts', () {
      final g = groups([
        ('b', 100, 2),
        ('a', 100, 5),
        ('c', 50, 1),
        ('d', 900, 1),
      ]);
      expect(
        ReceiptsSummaryBuilder.least3(g).map((x) => x.key),
        ['c', 'b', 'a'],
      );
    });

    test(
      'none group is never ranked; fewer than 3 is fine',
      () {
        final g = groups([('a', 10, 1)]);
        expect(
          ReceiptsSummaryBuilder.top3(g).map((x) => x.key),
          ['a'],
        );
        expect(
          ReceiptsSummaryBuilder.least3(
            g,
          ).map((x) => x.key),
          ['a'],
        );
      },
    );

    test('sorting keeps the none group last', () {
      final c = ReceiptsSummaryBuilder.customers(rows);
      for (final asc in [true, false]) {
        for (final f in ReceiptsGroupSortField.values) {
          final s = ReceiptsSummaryBuilder.sortGroups(
            c,
            field: f,
            ascending: asc,
          );
          expect(s.last.isNone, isTrue);
        }
      }
      final byCount = ReceiptsSummaryBuilder.sortGroups(
        c,
        field: ReceiptsGroupSortField.receiptCount,
        ascending: false,
      );
      expect(byCount.first.receiptCount, 2);
    });
  });

  group('channels and types', () {
    test(
      'Split counted once; values add up to revenue',
      () {
        final c = ReceiptsSummaryBuilder.channels(rows);
        expect(
          c.map((x) => x.channel),
          ReceiptChannel.values,
        );
        final split = c.firstWhere(
          (x) => x.channel == ReceiptChannel.split,
        );
        expect(split.receiptCount, 1);
        expect(split.value, 500);
        expect(
          c.fold<int>(0, (s, x) => s + x.receiptCount),
          rows.length,
        );
        expect(
          c.fold<double>(0, (s, x) => s + x.value),
          ReceiptsSummaryBuilder.stats(rows).totalRevenue,
        );
        expect(
          c.fold<double>(0, (s, x) => s + x.countShare!),
          closeTo(100, 1e-9),
        );
      },
    );

    test('types: Unknown only when present', () {
      final t = ReceiptsSummaryBuilder.types(rows);
      expect(t.map((x) => x.type), [
        ReceiptType.sales,
        ReceiptType.invoicePayment,
        ReceiptType.orderDelivery,
      ]);
      expect(t.first.receiptCount, 4);
      expect(t.first.value, 1950);
      expect(t.first.profitKnownCount, 3);
      final withUnknown = ReceiptsSummaryBuilder.types(
        rowsOf([receipt(salesTypeIndex: 9, cash: 5)]),
      );
      expect(withUnknown.last.type, ReceiptType.unknown);
      expect(withUnknown.last.value, 5);
    });
  });

  group('handoff to the table', () {
    test('every group opens exactly its receipts', () {
      final base = ReceiptsReportFilters();
      void check(
        List<ReceiptsSummaryGroup> groups,
        ReceiptsReportFilters Function(String key) filters,
      ) {
        for (final g in groups) {
          expect(
            tableRows(rows, filters(g.key)).length,
            g.receiptCount,
            reason: g.label,
          );
        }
      }

      check(
        ReceiptsSummaryBuilder.customers(rows),
        (k) => ReceiptsSummaryBuilder.handoff(
          base,
          customerKey: k,
        ),
      );
      check(
        ReceiptsSummaryBuilder.staff(rows),
        (k) => ReceiptsSummaryBuilder.handoff(
          base,
          staffKey: k,
        ),
      );
      check(
        ReceiptsSummaryBuilder.subStaff(rows),
        (k) => ReceiptsSummaryBuilder.handoff(
          base,
          subStaffKey: k,
        ),
      );
      check(
        ReceiptsSummaryBuilder.departments(rows),
        (k) => ReceiptsSummaryBuilder.handoff(
          base,
          departmentKey: k,
        ),
      );
      for (final c in ReceiptsSummaryBuilder.channels(
        rows,
      )) {
        expect(
          tableRows(
            rows,
            ReceiptsSummaryBuilder.handoff(
              base,
              channel: c.channel,
            ),
          ).length,
          c.receiptCount,
        );
      }
    });

    test(
      'summary filters carry over and are not changed',
      () {
        final base = ReceiptsReportFilters(
          type: ReceiptType.sales,
          revenueMin: 100,
        );
        final summaryRows = tableRows(rows, base);
        final groups = ReceiptsSummaryBuilder.departments(
          summaryRows,
        );
        for (final g in groups) {
          final f = ReceiptsSummaryBuilder.handoff(
            base,
            departmentKey: g.key,
          );
          expect(f.type, ReceiptType.sales);
          expect(f.revenueMin, 100);
          expect(tableRows(rows, f).length, g.receiptCount);
        }
        expect(base.departmentKey, isNull);
      },
    );

    test('the period is applied the same way', () {
      final mixed = rowsOf([
        receipt(customerUuid: 'c', cash: 1),
        receipt(
          customerUuid: 'c',
          cash: 2,
          createdAt: DateTime(2026, 10, 16, 23),
        ),
      ]);
      final period = ReceiptsReportPeriod.day(
        DateTime(2026, 10, 17),
      );
      final inPeriod = tableRows(
        mixed,
        ReceiptsReportFilters(),
        period: period,
      );
      final g =
          ReceiptsSummaryBuilder.customers(inPeriod).single;
      expect(g.receiptCount, 1);
      expect(
        tableRows(
          mixed,
          ReceiptsSummaryBuilder.handoff(
            ReceiptsReportFilters(),
            customerKey: g.key,
          ),
          period: period,
        ).length,
        1,
      );
    });
  });

  group('trend', () {
    test('interval follows the span', () {
      final d = DateTime(2026, 10, 1);
      expect(
        ReceiptsTrendBuilder.intervalFor(d, d),
        ReceiptsTrendInterval.hourly,
      );
      expect(
        ReceiptsTrendBuilder.intervalFor(
          d,
          DateTime(2026, 10, 31),
        ),
        ReceiptsTrendInterval.daily,
      );
      expect(
        ReceiptsTrendBuilder.intervalFor(
          d,
          DateTime(2026, 11, 1),
        ),
        ReceiptsTrendInterval.weekly,
      );
      expect(
        ReceiptsTrendBuilder.intervalFor(
          d,
          DateTime(2027, 6, 1),
        ),
        ReceiptsTrendInterval.monthly,
      );
    });

    test('single day: 24 hours from the closing time', () {
      final day = rowsOf([
        receipt(
          cash: 10,
          createdAt: DateTime(2026, 10, 17, 4, 30),
        ),
        receipt(
          cash: 20,
          createdAt: DateTime(2026, 10, 17, 13),
        ),
        receipt(
          cash: 30,
          createdAt: DateTime(2026, 10, 18, 3, 30),
        ),
      ]);
      final points = ReceiptsTrendBuilder.build(
        rows: day,
        period: ReceiptsReportPeriod.day(
          DateTime(2026, 10, 17),
        ),
        closingTime: four,
      );
      expect(points.length, 24);
      expect(points.first.start, DateTime(2026, 10, 17, 4));
      expect(points[0].revenue, 10);
      expect(points[9].revenue, 20);
      expect(points[23].revenue, 30);
      expect(points[1].revenue, 0);
    });

    test('daily buckets keep empty days as zero', () {
      final r = rowsOf([
        receipt(
          cash: 5,
          createdAt: DateTime(2026, 10, 1, 9),
        ),
        receipt(
          cash: 7,
          createdAt: DateTime(2026, 10, 3, 9),
        ),
      ]);
      final points = ReceiptsTrendBuilder.build(
        rows: r,
        period: ReceiptsReportPeriod.range(
          DateTime(2026, 10, 1),
          DateTime(2026, 10, 4),
        ),
        closingTime: midnight,
      );
      expect(points.map((p) => p.revenue), [5, 0, 7, 0]);
    });

    test(
      'closing time moves early-morning receipts back',
      () {
        final r = rowsOf([
          receipt(
            cash: 5,
            createdAt: DateTime(2026, 10, 2, 3),
          ),
        ]);
        final points = ReceiptsTrendBuilder.build(
          rows: r,
          period: ReceiptsReportPeriod.range(
            DateTime(2026, 10, 1),
            DateTime(2026, 10, 2),
          ),
          closingTime: four,
        );
        expect(points.map((p) => p.revenue), [5, 0]);
      },
    );

    test('weekly buckets start on Monday', () {
      final points = ReceiptsTrendBuilder.build(
        rows: rowsOf([
          receipt(
            cash: 1,
            createdAt: DateTime(2026, 10, 7, 9),
          ),
        ]),
        period: ReceiptsReportPeriod.range(
          DateTime(2026, 10, 7),
          DateTime(2026, 11, 20),
        ),
        closingTime: midnight,
      );
      expect(
        points.every(
          (p) => p.start.weekday == DateTime.monday,
        ),
        isTrue,
      );
      expect(points.first.start, DateTime(2026, 10, 5));
      expect(points.first.revenue, 1);
    });

    test('monthly buckets and type counts', () {
      final points = ReceiptsTrendBuilder.build(
        rows: rowsOf([
          receipt(
            cash: 1,
            createdAt: DateTime(2026, 1, 15),
          ),
          receipt(
            cash: 2,
            salesTypeIndex: 2,
            invoiceUuid: 'i',
            createdAt: DateTime(2026, 3, 2),
          ),
          receipt(
            cash: 3,
            salesTypeIndex: 3,
            createdAt: DateTime(2026, 9, 30),
          ),
        ]),
        period: ReceiptsReportPeriod.range(
          DateTime(2026, 1, 1),
          DateTime(2026, 9, 30),
        ),
        closingTime: midnight,
      );
      expect(points.length, 9);
      expect(points.first.start, DateTime(2026, 1, 1));
      expect(points.first.sales, 1);
      expect(points[2].invoicePayments, 1);
      expect(points.last.orderDeliveries, 1);
      expect(points[1].receiptCount, 0);
    });

    test(
      'all time runs from the first receipt to today',
      () {
        final points = ReceiptsTrendBuilder.build(
          rows: rowsOf([
            receipt(
              cash: 1,
              createdAt: DateTime(2026, 10, 10, 9),
            ),
          ]),
          period: const ReceiptsReportPeriod.allTime(),
          now: DateTime(2026, 10, 17, 12),
          closingTime: midnight,
        );
        expect(points.length, 8);
        expect(points.first.start, DateTime(2026, 10, 10));
        expect(points.last.start, DateTime(2026, 10, 17));
        expect(
          ReceiptsTrendBuilder.build(
            rows: const [],
            period: const ReceiptsReportPeriod.allTime(),
            closingTime: midnight,
          ),
          isEmpty,
        );
      },
    );

    test('chart totals equal the summary totals', () {
      final period = ReceiptsReportPeriod.day(
        DateTime(2026, 10, 17),
      );
      final inPeriod = tableRows(
        rows,
        ReceiptsReportFilters(),
        period: period,
      );
      final points = ReceiptsTrendBuilder.build(
        rows: inPeriod,
        period: period,
        closingTime: midnight,
      );
      final s = ReceiptsSummaryBuilder.stats(inPeriod);
      expect(
        points.fold<double>(0, (t, p) => t + p.revenue),
        s.totalRevenue,
      );
      expect(
        points.fold<double>(0, (t, p) => t + p.knownProfit),
        s.knownProfit,
      );
      expect(
        points.fold<int>(0, (t, p) => t + p.receiptCount),
        s.totalReceipts,
      );
    });
  });
}
