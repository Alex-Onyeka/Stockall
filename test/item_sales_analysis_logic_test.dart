import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_product_slaes_record/temp_product_sale_record.dart';
import 'package:stockall/pages/report/sales_report_/item_sales_analysis/class/item_sales_analysis_logic.dart';
import 'package:stockall/pages/report/sales_report_/item_sales_report_main/class/item_sales_report_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

const midnight = TimeOfDay(hour: 0, minute: 0);

const categoryNames = {
  'c-drinks': 'Drinks',
  'c-snacks': 'Snacks',
};

int _seq = 0;

TempMainReceipt receipt({
  String? uuid,
  DateTime? createdAt,
  int? salesTypeIndex = 1,
  double cash = 0,
  double bank = 0,
  String? staffId = 'staff-a',
  String? staffName = 'Ada',
  String? customerUuid,
  String? customerName,
  String? subStaffUuid,
  String? subStaffName,
  String? departmentUuid,
  String? departmentName,
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
    customerAccount: null,
    departmentName: departmentName,
    departmentUuidNew: departmentUuid,
    isInvoice: invoiceUuid != null,
    invoiceUuid: invoiceUuid,
    generalDiscount: null,
    fixedDiscount: null,
    vat: null,
    originalCost: null,
    balance: null,
    subStaffUuid: subStaffUuid,
    subStaffName: subStaffName,
    cartName: null,
    comment: null,
    salesTypeIndex: salesTypeIndex,
    items: items,
  );
}

TempProductSaleRecord line({
  String? productUuid = 'p-cola',
  String productName = 'Cola',
  double quantity = 1,
  double revenue = 0,
  double? costPrice,
  double? discountedAmount,
  bool customPriceSet = false,
  bool? useWholeSalePrice,
  bool isVoid = false,
}) {
  _seq++;
  return TempProductSaleRecord(
    productRecordId: null,
    createdAt: DateTime(2026, 10, 17, 12),
    productId: 0,
    productName: productName,
    shopId: 1,
    staffId: 'staff-a',
    staffName: 'Ada',
    recepitId: 0,
    quantity: quantity,
    revenue: revenue,
    discountedAmount: discountedAmount,
    originalCost: revenue,
    discount: null,
    fixedDiscount: null,
    costPrice: costPrice,
    customPriceSet: customPriceSet,
    setTotalPrice: null,
    useWholeSalePrice: useWholeSalePrice,
    departmentName: null,
    departmentUuid: null,
    uuid: 'line-$_seq',
    productUuid: productUuid,
    receiptUuid: null,
    isProductManaged: true,
    unit: null,
    useGroupQuantity: false,
    qttyPerGroup: null,
    isVoid: isVoid,
    unitsList: null,
    unitUuid: null,
    pricesList: null,
    priceUuid: null,
    widthDimension: null,
    heightDimension: null,
    quantityType: null,
    manageSalesWastage: null,
    isPercentageWastage: null,
    wastageAmount: null,
    wastageUnitUuid: null,
  );
}

TempProductClass product(
  String uuid, {
  List<String>? categories,
}) {
  return TempProductClass(
    uuid: uuid,
    name: uuid,
    unit: 'Unit(s)',
    isRefundable: false,
    costPrice: 0,
    shopId: 1,
    setCustomPrice: false,
    departmentName: null,
    departmentUuid: null,
    isManaged: true,
    groupUnit: null,
    qttyPerGroup: null,
    categoryUuid: null,
    wholeSalePrice: null,
    storageUuid: null,
    categories: categories,
    useGroupUnit: false,
    unitsList: null,
    pricesList: null,
    widthDimension: null,
    heightDimension: null,
    manageSalesWastage: null,
  );
}

final _products = [
  product('p-cola', categories: ['c-drinks']),
  product('p-chips', categories: ['c-snacks']),
  product('p-combo', categories: ['c-drinks', 'c-snacks']),
  product('p-plain'),
];

/// Rows of [receipts] that pass the default filters (void lines
/// out), as the analysis gets them.
List<ItemSalesRow> rowsOf(
  List<TempMainReceipt> receipts, {
  ItemSalesFilters? filters,
}) {
  final all = ItemSalesRowBuilder.buildAll(
    receipts: receipts,
    legacySales: const [],
    productsByUuid: {for (final p in _products) p.uuid!: p},
    categoryNameByUuid: categoryNames,
  );
  return ItemSalesQuery.filterAndSort(
    rows: all,
    period: const ReceiptsReportPeriod.allTime(),
    filters: filters ?? ItemSalesFilters(),
    sortField: ItemSalesSortField.createdAt,
    ascending: false,
    departmentsEnabled: true,
    subStaffEnabled: true,
    profitVisible: true,
    closingTime: midnight,
  );
}

ItemSalesSummaryGroup byKey(
  List<ItemSalesSummaryGroup> groups,
  String key,
) => groups.firstWhere((g) => g.key == key);

void main() {
  late List<ItemSalesRow> rows;

  setUp(() {
    rows = rowsOf([
      receipt(
        cash: 150,
        customerUuid: 'cu-1',
        customerName: 'Bola',
        departmentUuid: 'd-1',
        departmentName: 'Bar',
        items: [
          line(revenue: 100, costPrice: 60, quantity: 2),
          line(
            productUuid: 'p-chips',
            productName: 'Chips',
            revenue: 50,
            discountedAmount: 5,
          ),
        ],
      ),
      receipt(
        bank: 300,
        staffId: 'staff-b',
        staffName: 'Bayo',
        createdAt: DateTime(2026, 10, 17, 15),
        items: [
          line(
            productUuid: 'p-combo',
            productName: 'Combo',
            revenue: 300,
            costPrice: 200,
            customPriceSet: true,
          ),
          line(revenue: 999, isVoid: true),
        ],
      ),
      receipt(
        cash: 40,
        salesTypeIndex: 2,
        invoiceUuid: 'inv-1',
        items: [
          line(
            productUuid: 'p-gone',
            productName: 'Old Juice',
            revenue: 40,
            costPrice: 10,
            useWholeSalePrice: true,
          ),
        ],
      ),
    ]);
  });

  group('stats', () {
    test('totals over the filtered lines', () {
      final s = ItemSalesAnalysisBuilder.stats(rows);
      expect(s.totalLines, 4);
      expect(s.voidLines, 0);
      expect(s.distinctItems, 4);
      expect(s.receiptCount, 3);
      expect(s.distinctCategories, 2);
      expect(s.totalRevenue, 490);
      // Chips has no cost, so it counts as 0.
      expect(s.totalProfit, 40 + 50 + 100 + 30);
      expect(s.costMissingCount, 1);
      expect(s.margin, closeTo(220 / 490 * 100, 1e-9));
      expect(s.averageLineRevenue, 490 / 4);
      expect(s.totalDiscount, 5);
      expect(s.customPriceLines, 1);
      expect(s.wholesaleLines, 1);
      expect(s.typeCount(ReceiptType.sales), 3);
      expect(s.typeCount(ReceiptType.invoicePayment), 1);
      expect(s.distinctCustomers, 1);
      expect(s.walkInReceipts, 2);
      expect(s.distinctStaff, 2);
      expect(s.noStaffReceipts, 0);
    });

    test('void lines count when the filter includes them', () {
      final all = rowsOf(
        [
          receipt(
            items: [
              line(revenue: 10),
              line(revenue: 5, isVoid: true),
            ],
          ),
        ],
        filters: ItemSalesFilters(
          voidFilter: ItemSalesVoidFilter.all,
        ),
      );
      final s = ItemSalesAnalysisBuilder.stats(all);
      expect(s.totalLines, 2);
      expect(s.voidLines, 1);
      expect(s.totalRevenue, 15);
    });

    test('no lines: zeros and no margin', () {
      final s = ItemSalesAnalysisBuilder.stats(const []);
      expect(s.totalLines, 0);
      expect(s.margin, isNull);
      expect(s.averageLineRevenue, 0);
    });
  });

  group('groups', () {
    test('items: one group per product, newest name', () {
      final items = ItemSalesAnalysisBuilder.items(rows);
      expect(items.length, 4);
      expect(items.first.key, 'p-combo');
      final cola = byKey(items, 'p-cola');
      expect(cola.lineCount, 1);
      expect(cola.receiptCount, 1);
      expect(cola.revenue, 100);
      expect(cola.profit, 40);
      expect(cola.margin, 40);
      expect(cola.revenueShare, closeTo(100 / 490 * 100, 1e-9));
    });

    test('lines without a product id are under No item ID', () {
      final items = ItemSalesAnalysisBuilder.items(
        rowsOf([
          receipt(
            items: [
              line(productUuid: null, revenue: 1000),
              line(revenue: 5),
            ],
          ),
        ]),
      );
      expect(items.last.key, receiptsReportNoneKey);
      expect(items.last.label, 'No item ID');
      expect(items.last.isNone, isTrue);
    });

    test('an item in two categories counts in both', () {
      final cats = ItemSalesAnalysisBuilder.categories(rows);
      final drinks = byKey(cats, 'c-drinks');
      final snacks = byKey(cats, 'c-snacks');
      expect(drinks.label, 'Drinks');
      expect(drinks.lineCount, 2);
      expect(drinks.revenue, 400);
      expect(snacks.lineCount, 2);
      expect(snacks.revenue, 350);
      final shares = cats.fold<double>(
        0,
        (s, g) => s + (g.revenueShare ?? 0),
      );
      expect(shares, greaterThan(100));
    });

    test('no category and deleted items are listed last', () {
      final cats = ItemSalesAnalysisBuilder.categories(
        rowsOf([
          receipt(
            items: [
              line(productUuid: 'p-plain', revenue: 900),
              line(productUuid: 'p-gone', revenue: 800),
              line(revenue: 1),
            ],
          ),
        ]),
      );
      expect(cats.first.key, 'c-drinks');
      final rest = cats.skip(1).toList();
      expect(rest.every((g) => g.isNone), isTrue);
      expect(
        byKey(cats, receiptsReportNoneKey).label,
        itemSalesNoCategoryLabel,
      );
      expect(
        byKey(cats, itemSalesDeletedItemKey).label,
        itemSalesDeletedItemLabel,
      );
    });

    test('receipt groups come from the line\'s receipt', () {
      final staff = ItemSalesAnalysisBuilder.staff(rows);
      expect(byKey(staff, 'staff-a').lineCount, 3);
      expect(byKey(staff, 'staff-a').receiptCount, 2);
      expect(byKey(staff, 'staff-b').label, 'Bayo');
      final customers = ItemSalesAnalysisBuilder.customers(
        rows,
      );
      expect(customers.last.label, 'No Customer');
      expect(byKey(customers, 'cu-1').revenue, 150);
      final departments =
          ItemSalesAnalysisBuilder.departments(rows);
      expect(byKey(departments, 'd-1').label, 'Bar');
      expect(departments.last.label, 'Others');
    });

    test('top3 and least3 skip none groups', () {
      final items = ItemSalesAnalysisBuilder.items(
        rowsOf([
          receipt(
            items: [
              line(productUuid: null, revenue: 1000),
              line(revenue: 10),
              line(
                productUuid: 'p-chips',
                productName: 'Chips',
                revenue: 30,
              ),
              line(
                productUuid: 'p-combo',
                productName: 'Combo',
                revenue: 20,
              ),
            ],
          ),
        ]),
      );
      expect(
        ItemSalesAnalysisBuilder.top3(
          items,
        ).map((g) => g.key),
        ['p-chips', 'p-combo', 'p-cola'],
      );
      expect(
        ItemSalesAnalysisBuilder.least3(
          items,
        ).map((g) => g.key),
        ['p-cola', 'p-combo', 'p-chips'],
      );
    });

    test('sortGroups keeps none groups last', () {
      final items = ItemSalesAnalysisBuilder.items(
        rowsOf([
          receipt(
            items: [
              line(productUuid: null, revenue: 1),
              line(revenue: 10, quantity: 1),
              line(revenue: 5),
              line(
                productUuid: 'p-chips',
                productName: 'Chips',
                revenue: 12,
              ),
            ],
          ),
        ]),
      );
      final byLines = ItemSalesAnalysisBuilder.sortGroups(
        items,
        field: ItemSalesGroupSortField.lineCount,
        ascending: false,
      );
      expect(byLines.map((g) => g.key), [
        'p-cola',
        'p-chips',
        receiptsReportNoneKey,
      ]);
      final asc = ItemSalesAnalysisBuilder.sortGroups(
        items,
        field: ItemSalesGroupSortField.revenue,
        ascending: true,
      );
      expect(asc.map((g) => g.key), [
        'p-chips',
        'p-cola',
        receiptsReportNoneKey,
      ]);
    });
  });

  group('channels and types', () {
    test('channels always in order, values add up', () {
      final c = ItemSalesAnalysisBuilder.channels(rows);
      expect(c.map((x) => x.channel), ReceiptChannel.values);
      expect(
        c.fold<int>(0, (s, x) => s + x.lineCount),
        rows.length,
      );
      expect(
        c.fold<double>(0, (s, x) => s + x.value),
        490,
      );
      final bank = c.firstWhere(
        (x) => x.channel == ReceiptChannel.bank,
      );
      expect(bank.lineCount, 1);
      expect(bank.value, 300);
    });

    test('types: unknown only when present', () {
      final t = ItemSalesAnalysisBuilder.types(rows);
      expect(t.map((x) => x.type), [
        ReceiptType.sales,
        ReceiptType.invoicePayment,
        ReceiptType.orderDelivery,
      ]);
      expect(t.first.lineCount, 3);
      expect(t.first.value, 450);
      expect(t.first.costMissingCount, 1);
      expect(t[1].profit, 30);
      expect(t[2].lineCount, 0);
    });
  });

  group('trend', () {
    test('hourly on one day', () {
      final points = ItemSalesTrendBuilder.build(
        rows: rows,
        period: ReceiptsReportPeriod.day(
          DateTime(2026, 10, 17),
        ),
        closingTime: midnight,
      );
      expect(points.length, 24);
      expect(points[12].lineCount, 3);
      expect(points[12].sales, 2);
      expect(points[12].invoicePayments, 1);
      expect(points[15].revenue, 300);
      expect(points[15].profit, 100);
    });

    test('daily over a range, empty days included', () {
      final points = ItemSalesTrendBuilder.build(
        rows: rowsOf([
          receipt(
            createdAt: DateTime(2026, 10, 1, 9),
            items: [line(revenue: 5)],
          ),
          receipt(
            createdAt: DateTime(2026, 10, 3, 9),
            salesTypeIndex: 3,
            items: [line(revenue: 7), line(revenue: 1)],
          ),
        ]),
        period: ReceiptsReportPeriod.range(
          DateTime(2026, 10, 1),
          DateTime(2026, 10, 4),
        ),
        closingTime: midnight,
      );
      expect(points.length, 4);
      expect(points[0].revenue, 5);
      expect(points[1].lineCount, 0);
      expect(points[2].orderDeliveries, 2);
      expect(points[2].revenue, 8);
    });

    test('all time without lines has no points', () {
      expect(
        ItemSalesTrendBuilder.build(
          rows: const [],
          period: const ReceiptsReportPeriod.allTime(),
          closingTime: midnight,
        ),
        isEmpty,
      );
    });
  });

  group('handoff', () {
    test('adds one key and keeps the rest', () {
      final base = ItemSalesFilters(
        voidFilter: ItemSalesVoidFilter.all,
        wholesale: true,
      )..receipt.staffKey = 'staff-a';
      final f = ItemSalesAnalysisBuilder.handoff(
        base,
        categoryKey: 'c-drinks',
      );
      expect(f.categoryKey, 'c-drinks');
      expect(f.voidFilter, ItemSalesVoidFilter.all);
      expect(f.wholesale, isTrue);
      expect(f.receipt.staffKey, 'staff-a');
      expect(base.categoryKey, isNull);
    });

    test('every key reaches the right filter', () {
      final f = ItemSalesAnalysisBuilder.handoff(
        ItemSalesFilters(),
        productKey: 'p-cola',
        customerKey: 'cu-1',
        subStaffKey: 'ss-1',
        departmentKey: 'd-1',
        channel: ReceiptChannel.bank,
        type: ReceiptType.orderDelivery,
      );
      expect(f.productKey, 'p-cola');
      expect(f.receipt.customerKey, 'cu-1');
      expect(f.receipt.subStaffKey, 'ss-1');
      expect(f.receipt.departmentKey, 'd-1');
      expect(f.receipt.channel, ReceiptChannel.bank);
      expect(f.receipt.type, ReceiptType.orderDelivery);
    });

    test('a group\'s key opens exactly its lines', () {
      final cats = ItemSalesAnalysisBuilder.categories(rows);
      for (final g in cats) {
        final f = ItemSalesAnalysisBuilder.handoff(
          ItemSalesFilters(),
          categoryKey: g.key,
        );
        expect(
          rows.where(f.matchesCategory).length,
          g.lineCount,
        );
      }
    });
  });
}
