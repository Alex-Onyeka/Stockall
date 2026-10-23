import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/classes/temp_product_class/units_class/product_units_class.dart';
import 'package:stockall/classes/temp_product_slaes_record/temp_product_sale_record.dart';
import 'package:stockall/pages/report/components/report_group_by.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

const midnight = TimeOfDay(hour: 0, minute: 0);

TempMainReceipt receipt({
  String uuid = 'r-0000000000001',
  String? barcode = '111',
  DateTime? createdAt,
  int? salesTypeIndex = 1,
  String paymentMethod = 'Cash',
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
  String? comment,
  double? generalDiscount,
  double? fixedDiscount,
  double? vat,
  double? originalCost,
  double? balance,
  String? invoiceUuid,
  List<TempProductSaleRecord>? items,
}) {
  return TempMainReceipt(
    uuid: uuid,
    barcode: barcode,
    createdAt: createdAt ?? DateTime(2026, 10, 17, 12),
    shopId: 1,
    staffId: staffId,
    staffName: staffName,
    customerUuid: customerUuid,
    customerName: customerName,
    paymentMethod: paymentMethod,
    bank: bank,
    cashAlt: cash,
    customerAccount: account,
    departmentName: departmentName,
    departmentUuidNew: departmentUuid,
    isInvoice: invoiceUuid != null,
    invoiceUuid: invoiceUuid,
    generalDiscount: generalDiscount,
    fixedDiscount: fixedDiscount,
    vat: vat,
    originalCost: originalCost,
    balance: balance,
    subStaffUuid: subStaffUuid,
    subStaffName: subStaffName,
    cartName: null,
    comment: comment,
    salesTypeIndex: salesTypeIndex,
    items: items,
  );
}

ProductUnitsClass unit(
  String uuid, {
  bool isPrimary = true,
  int? dimensionType,
}) {
  return ProductUnitsClass(
    uuid: uuid,
    staffUuid: null,
    createdAt: DateTime.utc(2026),
    staffName: null,
    conversion: 1,
    name: uuid,
    isPrimary: isPrimary,
    productUuid: 'product-1',
    dimensionType: dimensionType,
  );
}

TempProductSaleRecord line({
  double quantity = 1,
  double revenue = 0,
  double? costPrice,
  double? discountedAmount,
  bool isVoid = false,
  String? receiptUuid,
  int? quantityType,
  List<ProductUnitsClass>? unitsList,
  String? unitUuid,
  bool? manageSalesWastage,
  double? wastageAmount,
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
    discountedAmount: discountedAmount,
    originalCost: revenue,
    discount: null,
    costPrice: costPrice,
    customPriceSet: false,
    departmentName: null,
    departmentUuid: null,
    receiptUuid: receiptUuid,
    isProductManaged: true,
    useGroupQuantity: false,
    qttyPerGroup: null,
    isVoid: isVoid,
    unitsList: unitsList,
    unitUuid: unitUuid,
    pricesList: null,
    priceUuid: null,
    widthDimension: null,
    heightDimension: null,
    quantityType: quantityType,
    manageSalesWastage: manageSalesWastage,
    isPercentageWastage: false,
    wastageAmount: wastageAmount,
  );
}

ReceiptsReportRow row(
  TempMainReceipt r, {
  List<TempProductSaleRecord> legacy = const [],
}) {
  return ReceiptsReportRowBuilder.build(
    receipt: r,
    legacyLines:
        ReceiptsReportRowBuilder.legacyLinesByReceipt(
          legacy,
        ),
  );
}

List<ReceiptsReportRow> run(
  List<ReceiptsReportRow> rows, {
  ReceiptsReportFilters? filters,
  ReceiptsReportPeriod period =
      const ReceiptsReportPeriod.allTime(),
  ReceiptsSortField sortField = ReceiptsSortField.createdAt,
  bool ascending = false,
  bool departmentsEnabled = true,
  bool subStaffEnabled = true,
  bool profitVisible = true,
}) {
  return ReceiptsReportQuery.filterAndSort(
    rows: rows,
    period: period,
    filters: filters ?? ReceiptsReportFilters(),
    sortField: sortField,
    ascending: ascending,
    departmentsEnabled: departmentsEnabled,
    subStaffEnabled: subStaffEnabled,
    profitVisible: profitVisible,
    closingTime: midnight,
  );
}

void main() {
  group('type', () {
    test('maps 1, 2 and 3 to their labels', () {
      expect(
        row(receipt(salesTypeIndex: 1)).type.label,
        'Sales',
      );
      expect(
        row(receipt(salesTypeIndex: 2)).type.label,
        'Invoice Payment',
      );
      expect(
        row(receipt(salesTypeIndex: 3)).type.label,
        'Order Delivery',
      );
    });

    test(
      'null index: invoice receipts are invoice payments',
      () {
        expect(
          row(
            receipt(
              salesTypeIndex: null,
              invoiceUuid: 'inv-1',
            ),
          ).type,
          ReceiptType.invoicePayment,
        );
        expect(
          row(receipt(salesTypeIndex: null)).type,
          ReceiptType.sales,
        );
      },
    );

    test('other values are Unknown, not Sales', () {
      expect(
        row(receipt(salesTypeIndex: 7)).type,
        ReceiptType.unknown,
      );
      expect(ReceiptType.unknown.label, 'Unknown');
    });
  });

  group('channel', () {
    test('single methods come from the amounts', () {
      expect(
        row(receipt(cash: 100)).channel,
        ReceiptChannel.cash,
      );
      expect(
        row(receipt(bank: 100)).channel,
        ReceiptChannel.bank,
      );
      final account = row(receipt(account: 100)).channel;
      expect(account, ReceiptChannel.customerAccount);
      expect(account.label, 'Customer Account');
    });

    test('amounts win over the saved label', () {
      expect(
        row(
          receipt(paymentMethod: 'Cash', bank: 100),
        ).channel,
        ReceiptChannel.bank,
      );
    });

    test('two or more methods are Split', () {
      expect(
        row(receipt(cash: 50, bank: 50)).channel,
        ReceiptChannel.split,
      );
      expect(
        row(
          receipt(cash: 10, bank: 10, account: 10),
        ).channel,
        ReceiptChannel.split,
      );
    });

    test('zero total falls back to the saved method', () {
      expect(
        row(receipt(paymentMethod: 'Bank')).channel,
        ReceiptChannel.bank,
      );
      expect(
        row(receipt(paymentMethod: 'Account')).channel,
        ReceiptChannel.customerAccount,
      );
      expect(
        row(receipt(paymentMethod: 'Split')).channel,
        ReceiptChannel.cash,
      );
    });
  });

  group('identity and labels', () {
    test('ID is the barcode, else the uuid digits', () {
      expect(
        row(receipt(barcode: '987')).displayId,
        '#987',
      );
      // 12 digits + EAN-13 checksum, as the printed receipt.
      expect(
        row(
          receipt(barcode: null, uuid: '1234567890123x'),
        ).displayId,
        '#1234567890128',
      );
    });

    test('uuid with too few digits is shown as is', () {
      final r = row(
        receipt(
          barcode: null,
          uuid: 'ab12cd34ef56gh78ij90k1',
        ),
      );
      expect(r.displayId, '#ab12cd34ef56gh78ij90k1');
      expect(
        ReceiptsReportRowBuilder.buildAll(
          receipts: [r.receipt],
          legacySales: const [],
        ).length,
        1,
      );
    });

    test('missing names and comments', () {
      final r = row(
        receipt(
          staffName: null,
          comment: '   ',
          departmentUuid: null,
          departmentName: null,
        ),
      );
      expect(r.staffLabel, 'Not Set');
      expect(r.customerLabel, 'Not Set');
      expect(r.departmentLabel, 'No Department');
      expect(r.comment, isNull);
      expect(
        row(receipt(comment: ' Paid late ')).comment,
        'Paid late',
      );
    });

    test('createdAt is shown in local time', () {
      final utc = DateTime.utc(2026, 10, 17, 10);
      final r = row(receipt(createdAt: utc));
      expect(r.createdAt.isUtc, isFalse);
      expect(r.createdAt, utc.toLocal());
    });
  });

  group('money columns', () {
    test('revenue is cash + bank + customer account', () {
      expect(
        row(
          receipt(cash: 100, bank: 50, account: 25),
        ).revenue,
        175,
      );
    });

    test('fixed discount wins, then percentage', () {
      expect(
        row(
          receipt(fixedDiscount: 500, originalCost: 2000),
        ).discount,
        500,
      );
      expect(
        row(
          receipt(generalDiscount: 10, originalCost: 2000),
        ).discount,
        200,
      );
    });

    test('without a cart discount, sums sold lines', () {
      final r = row(
        receipt(
          items: [
            line(discountedAmount: 30),
            line(discountedAmount: 20),
            line(discountedAmount: 99, isVoid: true),
          ],
        ),
      );
      expect(r.discount, 50);
    });

    test('no cart discount and no lines is unknown', () {
      expect(row(receipt()).discount, isNull);
    });

    test(
      'VAT is the stored rate applied to the subtotal',
      () {
        final r = row(
          receipt(vat: 7.5, originalCost: 2000),
        );
        expect(r.vat, 150);
        expect(r.subtotal, 2000);
        expect(row(receipt(originalCost: 2000)).vat, 0);
      },
    );

    test('invoice and order rows hide document totals', () {
      for (final type in [2, 3]) {
        final r = row(
          receipt(
            salesTypeIndex: type,
            invoiceUuid: type == 2 ? 'inv-1' : null,
            originalCost: 2000,
            vat: 7.5,
            fixedDiscount: 100,
            balance: 400,
          ),
        );
        expect(r.hidesDocumentTotals, isTrue);
        expect(r.subtotal, isNull);
        expect(r.discount, isNull);
        expect(r.vat, isNull);
        expect(r.balance, 400);
      }
    });

    test('sales rows have no balance', () {
      expect(row(receipt(balance: 400)).balance, isNull);
    });
  });

  group('items', () {
    test(
      'counts units, not lines: 2 bottles + 3 bags = 5',
      () {
        final r = row(
          receipt(
            items: [
              line(quantity: 2),
              line(quantity: 3),
              line(quantity: 4, isVoid: true),
            ],
          ),
        );
        expect(r.items, 5);
      },
    );

    test('wastage is not counted', () {
      final r = row(
        receipt(
          items: [
            line(
              quantity: 2,
              quantityType: 2,
              manageSalesWastage: true,
              wastageAmount: 0.5,
            ),
          ],
        ),
      );
      expect(r.items, 2);
    });

    test(
      '2D: area units count 1 per line, others count',
      () {
        final area = unit(
          'sqm',
          dimensionType: ProductUnitsClass.areaUnit,
        );
        final sheet = unit(
          'slab',
          isPrimary: false,
          dimensionType: ProductUnitsClass.sheetUnit,
        );
        final r = row(
          receipt(
            items: [
              line(
                quantity: 4.5,
                quantityType: 2,
                unitsList: [area, sheet],
                unitUuid: 'sqm',
              ),
              line(
                quantity: 3,
                quantityType: 2,
                unitsList: [area, sheet],
                unitUuid: 'slab',
              ),
            ],
          ),
        );
        expect(r.items, 4);
      },
    );

    test('invoice payments and receipts without lines', () {
      expect(
        row(
          receipt(
            salesTypeIndex: 2,
            invoiceUuid: 'inv-1',
            items: [line(quantity: 5)],
          ),
        ).items,
        isNull,
      );
      expect(row(receipt()).items, isNull);
    });
  });

  group('profit and margin', () {
    test('positive profit and margin from sold lines', () {
      final r = row(
        receipt(
          items: [
            line(revenue: 600, costPrice: 400),
            line(revenue: 400, costPrice: 200),
            line(revenue: 999, costPrice: 1, isVoid: true),
          ],
        ),
      );
      expect(r.profit, 400);
      expect(r.lineRevenue, 1000);
      expect(r.margin, 40);
      expect(r.costMissing, isFalse);
    });

    test('loss and zero profit', () {
      final loss = row(
        receipt(
          items: [line(revenue: 100, costPrice: 150)],
        ),
      );
      expect(loss.profit, -50);
      expect(loss.margin, -50);
      final zero = row(
        receipt(
          items: [line(revenue: 100, costPrice: 100)],
        ),
      );
      expect(zero.profit, 0);
      expect(zero.margin, 0);
    });

    test('missing cost counts as 0 and flags the row', () {
      final r = row(
        receipt(
          items: [
            line(revenue: 100, costPrice: 60),
            line(revenue: 50),
          ],
        ),
      );
      expect(r.profit, 90);
      expect(r.costMissing, isTrue);
    });

    test('zero revenue never divides by zero', () {
      final r = row(
        receipt(items: [line(revenue: 0, costPrice: 10)]),
      );
      expect(r.profit, -10);
      expect(r.margin, isNull);
    });

    test('no line data is unknown, not zero', () {
      final r = row(receipt(cash: 500));
      expect(r.lineSource, ReceiptLineSource.none);
      expect(r.profit, isNull);
      expect(r.margin, isNull);
      expect(r.lineRevenue, isNull);
    });

    test(
      'empty items fall back to product_sales lines',
      () {
        final r = row(
          receipt(uuid: 'legacy-1', items: []),
          legacy: [
            line(
              receiptUuid: 'legacy-1',
              quantity: 2,
              revenue: 300,
              costPrice: 100,
            ),
            line(
              receiptUuid: 'other',
              revenue: 999,
              costPrice: 1,
            ),
          ],
        );
        expect(r.lineSource, ReceiptLineSource.legacy);
        expect(r.profit, 200);
        expect(r.items, 2);
      },
    );

    test('embedded items win over product_sales lines', () {
      final r = row(
        receipt(
          uuid: 'both',
          items: [line(revenue: 100, costPrice: 50)],
        ),
        legacy: [
          line(
            receiptUuid: 'both',
            revenue: 999,
            costPrice: 1,
          ),
        ],
      );
      expect(r.lineSource, ReceiptLineSource.embedded);
      expect(r.profit, 50);
    });

    test('invoice payment counts only the payment', () {
      // 300 paid on a 1,000 invoice: the lines were scaled to 30%
      // when the payment receipt was written.
      final r = row(
        receipt(
          salesTypeIndex: 2,
          invoiceUuid: 'inv-1',
          cash: 300,
          originalCost: 1000,
          balance: 700,
          items: [
            line(
              quantity: 10,
              revenue: 300,
              costPrice: 180,
            ),
          ],
        ),
      );
      expect(r.revenue, 300);
      expect(r.profit, 120);
      expect(r.balance, 700);
    });
  });

  group('access', () {
    final receipts = [
      receipt(
        uuid: 'a',
        staffId: 'me',
        departmentUuid: 'd1',
      ),
      receipt(
        uuid: 'b',
        staffId: 'other',
        departmentUuid: 'd1',
      ),
      receipt(
        uuid: 'c',
        staffId: 'me',
        departmentUuid: 'd2',
      ),
    ];

    List<String?> scope({
      bool departmentsEnabled = true,
      bool canViewAllDepartments = true,
      String? currentDepartmentUuid,
      bool canViewAllTransactions = true,
    }) {
      return ReceiptsReportAccess.scope(
        receipts: receipts,
        departmentsEnabled: departmentsEnabled,
        canViewAllDepartments: canViewAllDepartments,
        currentDepartmentUuid: currentDepartmentUuid,
        canViewAllTransactions: canViewAllTransactions,
        currentUserId: 'me',
      ).map((r) => r.uuid).toList();
    }

    test(
      'department rule matches departmentReceipts()',
      () {
        expect(scope(), ['a', 'b', 'c']);
        expect(scope(currentDepartmentUuid: 'd1'), [
          'a',
          'b',
        ]);
        expect(
          scope(
            canViewAllDepartments: false,
            currentDepartmentUuid: 'd2',
          ),
          ['c'],
        );
        expect(
          scope(
            departmentsEnabled: false,
            currentDepartmentUuid: 'd1',
          ),
          ['a', 'b', 'c'],
        );
      },
    );

    test('own-receipts rule applies in both modes', () {
      expect(scope(canViewAllTransactions: false), [
        'a',
        'c',
      ]);
      expect(
        scope(
          departmentsEnabled: false,
          canViewAllTransactions: false,
        ),
        ['a', 'c'],
      );
      expect(
        scope(
          currentDepartmentUuid: 'd1',
          canViewAllTransactions: false,
        ),
        ['a'],
      );
    });
  });

  group('period', () {
    final day = DateTime(2026, 10, 17);

    test('all time includes everything', () {
      const period = ReceiptsReportPeriod.allTime();
      expect(period.isAllTime, isTrue);
      expect(period.contains(DateTime(2001)), isTrue);
    });

    test('calendar day is [00:00, next 00:00)', () {
      final period = ReceiptsReportPeriod.day(day);
      bool has(DateTime d) =>
          period.contains(d, closingTime: midnight);
      expect(has(DateTime(2026, 10, 16, 23, 59)), isFalse);
      expect(has(DateTime(2026, 10, 17)), isTrue);
      expect(has(DateTime(2026, 10, 17, 23, 59)), isTrue);
      expect(has(DateTime(2026, 10, 18)), isFalse);
    });

    test('custom closing time moves the boundary', () {
      const four = TimeOfDay(hour: 4, minute: 0);
      final period = ReceiptsReportPeriod.day(day);
      bool has(DateTime d) =>
          period.contains(d, closingTime: four);
      expect(has(DateTime(2026, 10, 17, 3, 59)), isFalse);
      expect(has(DateTime(2026, 10, 17, 4)), isTrue);
      expect(has(DateTime(2026, 10, 18, 3, 59)), isTrue);
      expect(has(DateTime(2026, 10, 18, 4)), isFalse);
      expect(
        ReceiptsReportPeriod.today(
          now: DateTime(2026, 10, 18, 2),
          closingTime: four,
        ).start,
        day,
      );
    });

    test('UTC timestamps are compared in local time', () {
      final period = ReceiptsReportPeriod.day(day);
      final localMidnightAsUtc =
          DateTime(2026, 10, 17).toUtc();
      expect(
        period.contains(
          localMidnightAsUtc,
          closingTime: midnight,
        ),
        isTrue,
      );
    });

    test('range is inclusive and swaps reversed dates', () {
      final period = ReceiptsReportPeriod.range(
        DateTime(2026, 10, 20, 15),
        DateTime(2026, 10, 18, 9),
      );
      expect(period.start, DateTime(2026, 10, 18));
      expect(period.end, DateTime(2026, 10, 20));
      expect(period.isSingleDay, isFalse);
      expect(
        period.contains(
          DateTime(2026, 10, 20, 23),
          closingTime: midnight,
        ),
        isTrue,
      );
    });
  });

  group('search and filters', () {
    final rows = [
      row(
        receipt(
          uuid: 'r1',
          barcode: '5550001',
          staffId: 's1',
          staffName: 'Ada Obi',
          customerUuid: 'c1',
          customerName: 'Chidi Stores',
          departmentUuid: 'd1',
          departmentName: 'Bar',
          subStaffUuid: 'sub1',
          subStaffName: 'Tobi',
          cash: 1000,
          items: [line(revenue: 1000, costPrice: 600)],
        ),
      ),
      row(
        receipt(
          uuid: 'r2',
          barcode: '5550002',
          staffId: 's2',
          staffName: 'Bola',
          customerUuid: null,
          departmentUuid: null,
          cash: 500,
          bank: 500,
          items: [line(revenue: 1000, costPrice: 1200)],
        ),
      ),
      row(
        receipt(
          uuid: 'r3',
          barcode: '5550003',
          staffId: 's1',
          staffName: 'Ada Obi',
          customerUuid: 'c2',
          customerName: 'Emeka',
          departmentUuid: 'd2',
          departmentName: 'Kitchen',
          bank: 300,
          salesTypeIndex: 2,
          invoiceUuid: 'inv',
        ),
      ),
      row(
        receipt(
          uuid: 'r4',
          barcode: '5550004',
          staffId: 's2',
          staffName: 'Bola',
          customerUuid: 'c1',
          customerName: 'Chidi Stores',
          departmentUuid: 'd1',
          departmentName: 'Bar',
          cash: 200,
          items: [line(revenue: 200)],
        ),
      ),
    ];

    List<String> ids(
      ReceiptsReportFilters f, {
      bool dept = true,
    }) =>
        run(
            rows,
            filters: f,
            departmentsEnabled: dept,
          ).map((r) => r.uuid).toList()
          ..sort();

    test(
      'search: customer, staff, department, barcode',
      () {
        expect(
          ids(ReceiptsReportFilters(search: 'chidi')),
          ['r1', 'r4'],
        );
        expect(ids(ReceiptsReportFilters(search: 'BOLA')), [
          'r2',
          'r4',
        ]);
        expect(
          ids(ReceiptsReportFilters(search: 'kitchen')),
          ['r3'],
        );
        expect(
          ids(
            ReceiptsReportFilters(search: 'kitchen'),
            dept: false,
          ),
          isEmpty,
        );
        expect(
          ids(ReceiptsReportFilters(search: '5550002')),
          ['r2'],
        );
      },
    );

    test('staff, customer and the No Customer bucket', () {
      expect(ids(ReceiptsReportFilters(staffKey: 's1')), [
        'r1',
        'r3',
      ]);
      expect(
        ids(ReceiptsReportFilters(customerKey: 'c1')),
        ['r1', 'r4'],
      );
      expect(
        ids(
          ReceiptsReportFilters(
            customerKey: receiptsReportNoneKey,
          ),
        ),
        ['r2'],
      );
    });

    test('department and sub-staff only when enabled', () {
      expect(
        ids(
          ReceiptsReportFilters(
            departmentKey: receiptsReportNoneKey,
          ),
        ),
        ['r2'],
      );
      expect(
        ids(
          ReceiptsReportFilters(departmentKey: 'd1'),
          dept: false,
        ),
        ['r1', 'r2', 'r3', 'r4'],
      );
      expect(
        run(
          rows,
          filters: ReceiptsReportFilters(
            subStaffKey: 'sub1',
          ),
        ).map((r) => r.uuid),
        ['r1'],
      );
      expect(
        run(
          rows,
          filters: ReceiptsReportFilters(
            subStaffKey: 'sub1',
          ),
          subStaffEnabled: false,
        ).length,
        4,
      );
    });

    test('channel filter matches the column exactly', () {
      expect(
        ids(
          ReceiptsReportFilters(
            channel: ReceiptChannel.cash,
          ),
        ),
        ['r1', 'r4'],
      );
      expect(
        ids(
          ReceiptsReportFilters(
            channel: ReceiptChannel.split,
          ),
        ),
        ['r2'],
      );
      for (final r in run(
        rows,
        filters: ReceiptsReportFilters(
          channel: ReceiptChannel.bank,
        ),
      )) {
        expect(r.channel, ReceiptChannel.bank);
      }
    });

    test('type filter', () {
      expect(
        ids(
          ReceiptsReportFilters(
            type: ReceiptType.invoicePayment,
          ),
        ),
        ['r3'],
      );
    });

    test(
      'profit range includes losses, skips unknowns',
      () {
        expect(ids(ReceiptsReportFilters(profitMax: -1)), [
          'r2',
        ]);
        expect(
          ids(
            ReceiptsReportFilters(
              profitMin: 400,
              profitMax: 400,
            ),
          ),
          ['r1'],
        );
        // r3 has no lines, r4 has a missing cost.
        expect(
          ids(ReceiptsReportFilters(profitMin: -100000)),
          ['r1', 'r2'],
        );
        expect(
          ReceiptsReportQuery.profitExcludedCount(
            rows: rows,
            period: const ReceiptsReportPeriod.allTime(),
            filters: ReceiptsReportFilters(
              profitMin: -100000,
            ),
            departmentsEnabled: true,
            subStaffEnabled: true,
            profitVisible: true,
            closingTime: midnight,
          ),
          2,
        );
      },
    );

    test('profit range is ignored without cost access', () {
      expect(
        run(
          rows,
          filters: ReceiptsReportFilters(profitMax: -1),
          profitVisible: false,
        ).length,
        4,
      );
    });

    test('revenue range uses Total Revenue', () {
      expect(
        ids(
          ReceiptsReportFilters(
            revenueMin: 300,
            revenueMax: 999,
          ),
        ),
        ['r3'],
      );
      expect(ids(ReceiptsReportFilters(revenueMin: 1000)), [
        'r1',
        'r2',
      ]);
    });

    test(
      'invalid ranges report an error and are not applied',
      () {
        final f = ReceiptsReportFilters(
          revenueMin: 900,
          revenueMax: 100,
          profitMin: 5,
          profitMax: 1,
        );
        expect(f.revenueRangeError, isNotNull);
        expect(f.profitRangeError, isNotNull);
        expect(f.revenueRangeActive, isFalse);
        expect(ids(f), ['r1', 'r2', 'r3', 'r4']);
      },
    );

    test('filters combine with AND and with search', () {
      final f = ReceiptsReportFilters(
        search: 'chidi',
        staffKey: 's1',
        channel: ReceiptChannel.cash,
        departmentKey: 'd1',
        revenueMin: 500,
        profitMin: 1,
      );
      expect(ids(f), ['r1']);
      expect(f.activeCount, 5);
    });

    test('clearing and copying', () {
      final f = ReceiptsReportFilters(
        search: 'x',
        staffKey: 's1',
        profitMin: 1,
      );
      final c = f.copy()..staffKey = 's2';
      expect(f.staffKey, 's1');
      expect(c.staffKey, 's2');
      f.clearFiltersOnly();
      expect(f.activeCount, 0);
      expect(f.search, 'x');
      f.clearAll();
      expect(f.hasAnything, isFalse);
    });

    test(
      'options use the newest name and a none bucket',
      () {
        final optionRows = [
          row(
            receipt(
              uuid: 'old',
              staffId: 's1',
              staffName: 'Old Name',
              createdAt: DateTime(2026, 1, 1),
            ),
          ),
          row(
            receipt(
              uuid: 'new',
              staffId: 's1',
              staffName: 'New Name',
              createdAt: DateTime(2026, 2, 1),
            ),
          ),
          row(
            receipt(
              uuid: 'b',
              staffId: 's2',
              staffName: 'Ade',
            ),
          ),
        ];
        final staff = ReceiptsReportOptions.staff(
          optionRows,
        );
        expect(staff.map((o) => o.label), [
          'Ade',
          'New Name',
        ]);
        final customers = ReceiptsReportOptions.customers(
          optionRows,
        );
        expect(customers.single.key, receiptsReportNoneKey);
        expect(customers.single.label, 'No Customer');
      },
    );
  });

  group('sorting', () {
    final rows = [
      row(
        receipt(
          uuid: 'a',
          customerUuid: 'c1',
          customerName: 'bola',
          staffName: 'Zed',
          cash: 300,
          createdAt: DateTime(2026, 10, 1),
          items: [line(revenue: 300, costPrice: 100)],
        ),
      ),
      row(
        receipt(
          uuid: 'b',
          customerUuid: 'c2',
          customerName: 'Ade',
          staffName: 'ann',
          cash: 100,
          createdAt: DateTime(2026, 10, 3),
          salesTypeIndex: 2,
          invoiceUuid: 'inv',
          balance: 50,
          items: [line(revenue: 100, costPrice: 150)],
        ),
      ),
      row(
        receipt(
          uuid: 'c',
          customerUuid: null,
          staffName: 'Mia',
          cash: 200,
          createdAt: DateTime(2026, 10, 2),
          salesTypeIndex: 3,
          balance: 0,
        ),
      ),
    ];

    List<String> order(ReceiptsSortField field, bool asc) =>
        run(
          rows,
          sortField: field,
          ascending: asc,
        ).map((r) => r.uuid).toList();

    test(
      'customer, case-insensitive, no customer last',
      () {
        expect(order(ReceiptsSortField.customer, true), [
          'b',
          'a',
          'c',
        ]);
        expect(order(ReceiptsSortField.customer, false), [
          'a',
          'b',
          'c',
        ]);
      },
    );

    test('staff, case-insensitive', () {
      expect(order(ReceiptsSortField.staff, true), [
        'b',
        'c',
        'a',
      ]);
      expect(order(ReceiptsSortField.staff, false), [
        'a',
        'c',
        'b',
      ]);
    });

    test('created date', () {
      expect(order(ReceiptsSortField.createdAt, true), [
        'a',
        'c',
        'b',
      ]);
      expect(order(ReceiptsSortField.createdAt, false), [
        'b',
        'c',
        'a',
      ]);
    });

    test('revenue', () {
      expect(order(ReceiptsSortField.revenue, true), [
        'b',
        'c',
        'a',
      ]);
      expect(order(ReceiptsSortField.revenue, false), [
        'a',
        'c',
        'b',
      ]);
    });

    test('balance, sales (no balance) last', () {
      expect(order(ReceiptsSortField.balance, true), [
        'c',
        'b',
        'a',
      ]);
      expect(order(ReceiptsSortField.balance, false), [
        'b',
        'c',
        'a',
      ]);
    });

    test('profit, unknown profit last', () {
      expect(order(ReceiptsSortField.profit, true), [
        'b',
        'a',
        'c',
      ]);
      expect(order(ReceiptsSortField.profit, false), [
        'a',
        'b',
        'c',
      ]);
    });

    test('ties fall back to newest first, then uuid', () {
      final tied = [
        row(receipt(uuid: 'x', cash: 5)),
        row(receipt(uuid: 'w', cash: 5)),
        row(
          receipt(
            uuid: 'y',
            cash: 5,
            createdAt: DateTime(2026, 10, 18),
          ),
        ),
      ];
      expect(
        run(
          tied,
          sortField: ReceiptsSortField.revenue,
          ascending: true,
        ).map((r) => r.uuid),
        ['y', 'w', 'x'],
      );
    });
  });

  group('pagination', () {
    final many = List.generate(
      250,
      (i) => row(
        receipt(
          uuid: 'r${i.toString().padLeft(3, '0')}',
          cash: i.toDouble(),
          staffId: i.isEven ? 'even' : 'odd',
          createdAt: DateTime(
            2026,
            10,
            17,
          ).add(Duration(minutes: i)),
        ),
      ),
    );

    test('100 per page, last page partial', () {
      final sorted = run(many);
      final p1 = ReceiptsReportQuery.paginate(sorted, 1);
      final p3 = ReceiptsReportQuery.paginate(sorted, 3);
      expect(p1.totalPages, 3);
      expect(p1.rows.length, 100);
      expect(p1.firstIndex, 1);
      expect(p3.rows.length, 50);
      expect(p3.firstIndex, 201);
      expect(p3.lastIndex, 250);
    });

    test('sorted before paging', () {
      final sorted = run(
        many,
        sortField: ReceiptsSortField.revenue,
        ascending: false,
      );
      final p1 = ReceiptsReportQuery.paginate(sorted, 1);
      expect(p1.rows.first.revenue, 249);
      expect(
        ReceiptsReportQuery.paginate(
          sorted,
          3,
        ).rows.last.revenue,
        0,
      );
    });

    test(
      'page clamps when filtering shrinks the result',
      () {
        final filtered = run(
          many,
          filters: ReceiptsReportFilters(staffKey: 'even'),
        );
        final page = ReceiptsReportQuery.paginate(
          filtered,
          3,
        );
        expect(filtered.length, 125);
        expect(page.totalPages, 2);
        expect(page.page, 2);
        expect(page.rows.length, 25);
      },
    );

    test('empty result is one empty page', () {
      final page = ReceiptsReportQuery.paginate(
        const [],
        4,
      );
      expect(page.page, 1);
      expect(page.totalPages, 1);
      expect(page.rows, isEmpty);
      expect(page.firstIndex, 0);
      expect(page.lastIndex, 0);
    });

    test('period limits rows before paging', () {
      final sorted = run(
        many,
        period: ReceiptsReportPeriod.day(
          DateTime(2026, 10, 18),
        ),
      );
      expect(sorted, isEmpty);
    });
  });

  group('totals', () {
    final rows = [
      for (var i = 0; i < 120; i++)
        row(
          receipt(
            uuid: 'r${i.toString().padLeft(3, '0')}',
            cash: 1000,
            originalCost: 1000,
            fixedDiscount: 50,
            vat: 10,
            items: [
              line(revenue: 600, costPrice: 400),
              line(revenue: 400, costPrice: 200),
              line(quantity: 5, revenue: 999, isVoid: true),
            ],
          ),
        ),
      // No line data: profit unknown.
      row(receipt(uuid: 'r-nolines', cash: 500)),
      row(
        receipt(
          uuid: 'r-payment',
          salesTypeIndex: 2,
          invoiceUuid: 'inv-1',
          cash: 300,
          balance: 400,
        ),
      ),
    ];

    test('cover every page, not just the current one', () {
      final sorted = run(rows);
      final p1 = ReceiptsReportQuery.paginate(sorted, 1);
      final p2 = ReceiptsReportQuery.paginate(sorted, 2);
      expect(p1.totalCount, 122);
      expect(p1.rows.length, 100);
      for (final p in [p1, p2]) {
        expect(p.totalRevenue, 120800);
        expect(p.totalSubtotal, 120000);
        expect(p.totalDiscount, 6000);
        expect(p.totalVat, 12000);
        expect(p.totalItems, 240);
        expect(p.totalBalance, 400);
        expect(p.totalProfit, 48000);
      }
    });

    test('margin skips rows without a profit', () {
      final p = ReceiptsReportQuery.paginate(run(rows), 1);
      expect(p.totalLineRevenue, 120000);
      expect(p.totalMargin, 40);
      expect(
        ReceiptsReportQuery.paginate(const [], 1).totalMargin,
        isNull,
      );
    });
  });

  group('grouping', () {
    final rows = [
      // Ada, renamed: the newest name wins.
      row(
        receipt(
          uuid: 'r-ada-old',
          staffName: 'Ada Old',
          cash: 100,
          customerUuid: 'c-1',
          customerName: 'Chidi',
          createdAt: DateTime(2026, 10, 17, 9),
          items: [line(revenue: 100, costPrice: 60)],
        ),
      ),
      row(
        receipt(
          uuid: 'r-ada-new',
          cash: 300,
          customerUuid: 'c-1',
          customerName: 'Chidi N.',
          createdAt: DateTime(2026, 10, 17, 11),
          items: [line(quantity: 2, revenue: 300, costPrice: 100)],
        ),
      ),
      // Bob: bank, no line data (profit unknown).
      row(
        receipt(
          uuid: 'r-bob',
          staffId: 'staff-b',
          staffName: 'Bob',
          bank: 1000,
          createdAt: DateTime(2026, 10, 17, 10),
        ),
      ),
      // No staff, customer account, invoice part payment.
      row(
        receipt(
          uuid: 'r-none',
          staffId: null,
          staffName: null,
          account: 50,
          salesTypeIndex: 2,
          invoiceUuid: 'inv-1',
          balance: 25,
          createdAt: DateTime(2026, 10, 17, 12),
          items: [line(quantity: 9, revenue: 50, costPrice: 10)],
        ),
      ),
      // Split payment.
      row(
        receipt(
          uuid: 'r-split',
          cash: 20,
          bank: 30,
          createdAt: DateTime(2026, 10, 17, 8),
        ),
      ),
    ];

    List<ReceiptsGroupRow> grouped(
      ReportGroupBy by, {
      ReceiptsTableGroupSortField field =
          ReceiptsTableGroupSortField.revenue,
      bool ascending = false,
    }) => ReceiptsGrouping.sort(
      ReceiptsGrouping.build(run(rows), by),
      field: field,
      ascending: ascending,
    );

    test('off builds nothing', () {
      expect(ReceiptsGrouping.build(rows, ReportGroupBy.off), isEmpty);
    });

    test('staff: newest name, sums, No staff last', () {
      final g = grouped(ReportGroupBy.staff);
      expect(g.map((e) => e.label), [
        'Bob',
        'Ada',
        receiptsNoStaffLabel,
      ]);
      final ada = g[1];
      expect(ada.count, 3); // two sales + the split receipt
      expect(ada.revenue, 450);
      expect(ada.items, 3);
      expect(ada.profit, 240);
      expect(ada.lineRevenue, 400);
      expect(ada.margin, 60);
      final bob = g[0];
      expect(bob.profitUnknown, isTrue);
      expect(bob.margin, isNull);
      expect(bob.items, isNull);
    });

    test('the none row stays last in both directions', () {
      for (final asc in [true, false]) {
        for (final f in ReceiptsTableGroupSortField.values) {
          expect(
            grouped(
              ReportGroupBy.staff,
              field: f,
              ascending: asc,
            ).last.isNone,
            isTrue,
          );
          expect(
            grouped(
              ReportGroupBy.customer,
              field: f,
              ascending: asc,
            ).last.label,
            receiptsNoCustomerLabel,
          );
        }
      }
      expect(
        grouped(
          ReportGroupBy.staff,
          field: ReceiptsTableGroupSortField.name,
          ascending: true,
        ).map((e) => e.label),
        ['Ada', 'Bob', receiptsNoStaffLabel],
      );
    });

    test('customer: keyed by uuid, newest name', () {
      final g = grouped(ReportGroupBy.customer);
      expect(g.length, 2);
      expect(g.first.label, 'Chidi N.');
      expect(g.first.count, 2);
      expect(g.last.count, 3);
    });

    test('channel: one row per channel, part payment items skipped', () {
      final g = grouped(ReportGroupBy.channel);
      expect(
        {for (final e in g) e.label: e.count},
        {
          'Cash': 2,
          'Bank': 1,
          'Customer Account': 1,
          'Split': 1,
        },
      );
      expect(g.any((e) => e.isNone), isFalse);
      final account = g.firstWhere(
        (e) => e.label == 'Customer Account',
      );
      expect(account.items, isNull);
      expect(account.balance, 25);
    });

    test('group totals equal the ungrouped totals', () {
      final sorted = run(rows);
      final plain = ReceiptsReportQuery.paginate(sorted, 1);
      for (final by in [
        ReportGroupBy.staff,
        ReportGroupBy.customer,
        ReportGroupBy.channel,
      ]) {
        final p = ReceiptsGrouping.paginate(
          ReceiptsGrouping.build(sorted, by),
          1,
        );
        expect(p.totalReceipts, plain.totalCount);
        expect(p.totalRevenue, plain.totalRevenue);
        expect(p.totalBalance, plain.totalBalance);
        expect(p.totalItems, plain.totalItems);
        expect(p.totalProfit, plain.totalProfit);
        expect(p.totalMargin, plain.totalMargin);
      }
    });

    test('filters apply before grouping', () {
      final g = ReceiptsGrouping.build(
        run(
          rows,
          filters: ReceiptsReportFilters(staffKey: 'staff-b'),
        ),
        ReportGroupBy.staff,
      );
      expect(g.single.label, 'Bob');
    });

    test('more than 100 groups page like receipts', () {
      final many = [
        for (var i = 0; i < 130; i++)
          row(
            receipt(
              uuid: 'r$i',
              staffId: 's$i',
              staffName: 'S$i',
              cash: i.toDouble(),
            ),
          ),
      ];
      final groups = ReceiptsGrouping.build(
        run(many),
        ReportGroupBy.staff,
      );
      final p2 = ReceiptsGrouping.paginate(groups, 2);
      expect(p2.totalCount, 130);
      expect(p2.totalPages, 2);
      expect(p2.rows.length, 30);
      expect(p2.firstIndex, 101);
      expect(p2.totalReceipts, 130);
      expect(ReceiptsGrouping.paginate(groups, 9).page, 2);
    });
  });
}
