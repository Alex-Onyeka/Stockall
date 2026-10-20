import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/temp_invoices/temp_invoices.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/classes/temp_product_class/units_class/product_units_class.dart';
import 'package:stockall/classes/temp_product_slaes_record/temp_product_sale_record.dart';
import 'package:stockall/pages/report/invoice_report/invoice_report_table/class/invoice_report_table_logic.dart';
import 'package:stockall/pages/report/invoice_report/invoice_summary/class/invoice_summary_logic.dart';

void main() {
  group('InvoiceSummaryBuilder Tests', () {
    final now = DateTime(2026, 5, 10, 12, 0);

    final unit1 = ProductUnitsClass(
      uuid: 'u-1',
      staffUuid: 'staff-alice',
      createdAt: DateTime(2026, 1, 1),
      staffName: 'Alice',
      conversion: 1,
      name: 'Pcs',
      isPrimary: true,
      productUuid: 'prod-1',
    );

    // Sample invoices
    final inv1 = TempInvoice(
      id: 1,
      barcode: 'INV001',
      uuid: 'inv-1',
      createdAt: DateTime(2026, 5, 10, 10, 0), // Today
      shopId: 1,
      staffId: 'staff-alice',
      staffName: 'Alice',
      customerUuid: 'cust-bob',
      customerName: 'Bob',
      paymentMethod: 'Cash',
      bank: 0,
      cashAlt: 10000,
      departmentName: 'Beverages',
      departmentUuidNew: 'dept-bev',
      cartName: 'Cart 1',
      subStaffUuid: 'sub-charlie',
      subStaffName: 'Charlie',
      comment: null,
      items: [
        TempProductSaleRecord(
          createdAt: DateTime(2026, 5, 10),
          productId: 1,
          productName: 'Juice',
          shopId: 1,
          staffId: 'staff-alice',
          staffName: 'Alice',
          recepitId: 0,
          quantity: 2,
          revenue: 10000,
          discountedAmount: 0,
          originalCost: 10000,
          costPrice: 6000,
          customPriceSet: false,
          discount: 0,
          departmentName: 'Beverages',
          departmentUuid: 'dept-bev',
          isProductManaged: true,
          useGroupQuantity: false,
          qttyPerGroup: 0,
          isVoid: false,
          pricesList: [],
          priceUuid: '',
          widthDimension: 0,
          heightDimension: 0,
          quantityType: 0,
          manageSalesWastage: false,
          isPercentageWastage: false,
          wastageAmount: 0,
          unitsList: [unit1],
          unitUuid: 'u-1',
        ),
      ],
    );

    final inv2 = TempInvoice(
      id: 2,
      barcode: 'INV002',
      uuid: 'inv-2',
      createdAt: DateTime(2026, 5, 10, 11, 0), // Today
      shopId: 1,
      staffId: 'staff-alice',
      staffName: 'Alice',
      customerUuid: 'cust-dan',
      customerName: 'Dan',
      paymentMethod: 'Bank',
      bank: 20000,
      cashAlt: 0,
      departmentName: 'Bakery',
      departmentUuidNew: 'dept-bak',
      cartName: 'Cart 2',
      subStaffUuid: null,
      subStaffName: null,
      comment: null,
      items: [
        TempProductSaleRecord(
          createdAt: DateTime(2026, 5, 10),
          productId: 2,
          productName: 'Bread',
          shopId: 1,
          staffId: 'staff-alice',
          staffName: 'Alice',
          recepitId: 0,
          quantity: 10,
          revenue: 20000,
          discountedAmount: 0,
          originalCost: 20000,
          costPrice: 12000,
          customPriceSet: false,
          discount: 0,
          departmentName: 'Bakery',
          departmentUuid: 'dept-bak',
          isProductManaged: true,
          useGroupQuantity: false,
          qttyPerGroup: 0,
          isVoid: false,
          pricesList: [],
          priceUuid: '',
          widthDimension: 0,
          heightDimension: 0,
          quantityType: 0,
          manageSalesWastage: false,
          isPercentageWastage: false,
          wastageAmount: 0,
          unitsList: [unit1],
          unitUuid: 'u-1',
        ),
      ],
    );

    final inv3 = TempInvoice(
      id: 3,
      barcode: 'INV003',
      uuid: 'inv-3',
      createdAt: DateTime(2026, 5, 10, 11, 30), // Today
      shopId: 1,
      staffId: 'staff-eve',
      staffName: 'Eve',
      customerUuid: null,
      customerName: null, // Walk-in
      paymentMethod: 'Cash',
      bank: 0,
      cashAlt: 5000,
      departmentName: null, // No department (Others)
      departmentUuidNew: null,
      cartName: 'Cart 3',
      subStaffUuid: null,
      subStaffName: null,
      comment: null,
      items: [
        TempProductSaleRecord(
          createdAt: DateTime(2026, 5, 10),
          productId: 3,
          productName: 'Candy',
          shopId: 1,
          staffId: 'staff-eve',
          staffName: 'Eve',
          recepitId: 0,
          quantity: 10,
          revenue: 5000,
          discountedAmount: 0,
          originalCost: 5000,
          costPrice: 3000,
          customPriceSet: false,
          discount: 0,
          departmentName: '',
          departmentUuid: '',
          isProductManaged: true,
          useGroupQuantity: false,
          qttyPerGroup: 0,
          isVoid: false,
          pricesList: [],
          priceUuid: '',
          widthDimension: 0,
          heightDimension: 0,
          quantityType: 0,
          manageSalesWastage: false,
          isPercentageWastage: false,
          wastageAmount: 0,
          unitsList: [unit1],
          unitUuid: 'u-1',
        ),
      ],
    );

    // Receipts: inv-1 fully paid (10,000 cash), inv-2 partially paid (5,000 bank + 5,000 cash = 10,000 split), inv-3 unpaid (0 receipts)
    final rec1 = TempMainReceipt(
      uuid: 'rec-1',
      invoiceUuid: 'inv-1',
      shopId: 1,
      staffId: 'staff-alice',
      staffName: 'Alice',
      paymentMethod: 'Cash',
      bank: 0,
      cashAlt: 10000,
      customerAccount: 0,
      createdAt: DateTime(2026, 5, 10, 10, 15),
      isInvoice: true,
      salesTypeIndex: 2,
      departmentName: '',
      departmentUuidNew: '',
      cartName: 'Cart 1',
      subStaffName: '',
      comment: '',
    );

    final rec2 = TempMainReceipt(
      uuid: 'rec-2',
      invoiceUuid: 'inv-2',
      shopId: 1,
      staffId: 'staff-alice',
      staffName: 'Alice',
      paymentMethod: 'Split',
      bank: 5000,
      cashAlt: 5000,
      customerAccount: 0,
      createdAt: DateTime(2026, 5, 10, 11, 15),
      isInvoice: true,
      salesTypeIndex: 2,
      departmentName: '',
      departmentUuidNew: '',
      cartName: 'Cart 2',
      subStaffName: '',
      comment: '',
    );

    final List<TempMainReceipt> allReceipts = [rec1, rec2];
    final allInvoices = [inv1, inv2, inv3];

    final rows = InvoiceReportRowBuilder.buildAll(
      invoices: allInvoices,
      allReceipts: allReceipts,
      allProductSales: [],
      customerMap: {},
    );

    test('Computes aggregate summary statistics correctly', () {
      final res = InvoiceSummaryBuilder.build(
        allRows: rows,
        allReceipts: allReceipts,
        period: InvoiceSummaryPeriod.today,
        businessNow: now,
        departmentsEnabled: true,
        bulkSaleEnabled: true,
      );

      final stats = res.stats;
      // 3 qualifying invoices
      expect(stats.totalInvoices, equals(3));
      // Total value: 10,000 + 20,000 + 5,000 = 35,000
      expect(stats.totalInvoiceValue, equals(35000.0));
      // Total paid towards invoices: 10,000 (inv-1) + 10,000 (inv-2) = 20,000
      expect(stats.totalAmountPaid, equals(20000.0));
      // Outstanding balance: 0 (inv-1) + 10,000 (inv-2) + 5,000 (inv-3) = 15,000
      expect(
        stats.totalOutstandingBalance,
        equals(15000.0),
      );

      // Statuses
      expect(stats.fullyPaidInvoices, equals(1)); // inv-1
      expect(
        stats.partiallyPaidInvoices,
        equals(1),
      ); // inv-2
      expect(stats.unpaidInvoices, equals(1)); // inv-3
      expect(stats.unresolvedInvoices, equals(0));

      // Average invoice value: 35,000 / 3 = 11,666.666...
      expect(
        stats.averageInvoiceValue,
        closeTo(11666.67, 0.1),
      );

      // Cost & Profit:
      // Cost: 6000 + 12000 + 3000 = 21000
      // Profit: 35000 - 21000 = 14000
      expect(stats.totalCost, equals(21000.0));
      expect(stats.totalProfitLoss, equals(14000.0));
      // Margin: 14000 / 35000 * 100 = 40%
      expect(
        stats.averageProfitMargin,
        closeTo(40.0, 0.01),
      );

      // Items: 2 + 10 + 10 = 22
      expect(stats.totalItemsInvoiced, equals(22.0));

      // Customers: cust-bob, cust-dan, walkin (inv-3) = 3 distinct
      expect(stats.totalCustomers, equals(3));
      // Staff: staff-alice, staff-eve = 2 distinct
      expect(stats.totalStaffInvolved, equals(2));

      // Payment channel classification on invoices:
      // inv-1: Cash, inv-2: Split, inv-3: Unpaid
      expect(stats.cashPaymentTransactions, equals(1));
      expect(stats.bankPaymentTransactions, equals(0));
      expect(stats.splitPaymentTransactions, equals(1));
    });

    test(
      'Ranks Top 3 Customers and Least 3 Customers correctly',
      () {
        final res = InvoiceSummaryBuilder.build(
          allRows: rows,
          allReceipts: allReceipts,
          period: InvoiceSummaryPeriod.today,
          businessNow: now,
          departmentsEnabled: true,
          bulkSaleEnabled: true,
        );

        // Top customer by value: Dan (20,000) -> Bob (10,000) -> Walk-in (5,000)
        expect(res.top3Customers.length, equals(3));
        expect(
          res.top3Customers[0].customerName,
          equals('Dan'),
        );
        expect(
          res.top3Customers[0].totalInvoiceValue,
          equals(20000.0),
        );
        expect(
          res.top3Customers[1].customerName,
          equals('Bob'),
        );
        expect(
          res.top3Customers[1].totalInvoiceValue,
          equals(10000.0),
        );
        expect(
          res.top3Customers[2].customerName,
          contains('Walk-in'),
        );

        // Least performing: Walk-in (5,000) -> Bob (10,000) -> Dan (20,000)
        expect(res.least3Customers.length, equals(3));
        expect(
          res.least3Customers[0].customerName,
          contains('Walk-in'),
        );
        expect(
          res.least3Customers[0].totalInvoiceValue,
          equals(5000.0),
        );
        expect(
          res.least3Customers[1].customerName,
          equals('Bob'),
        );
        expect(
          res.least3Customers[2].customerName,
          equals('Dan'),
        );
      },
    );

    test(
      'Ranks Top Creditors and Least Creditors correctly by outstanding balance',
      () {
        final res = InvoiceSummaryBuilder.build(
          allRows: rows,
          allReceipts: allReceipts,
          period: InvoiceSummaryPeriod.allTime,
          businessNow: now,
          departmentsEnabled: true,
          bulkSaleEnabled: true,
        );

        // In the sample dataset:
        // Dan (inv2): total 20,000, paid 10,000 -> balance 10,000
        // Walk-in (inv3): total 5,000, paid 0 -> balance 5,000
        // Bob (inv1): total 10,000, paid 10,000 -> balance 0 (not a creditor)
        expect(res.topCreditors.length, equals(2));
        expect(
          res.topCreditors[0].customerName,
          equals('Dan'),
        );
        expect(
          res.topCreditors[0].outstandingBalance,
          equals(10000.0),
        );
        expect(
          res.topCreditors[1].customerName,
          contains('Walk-in'),
        );
        expect(
          res.topCreditors[1].outstandingBalance,
          equals(5000.0),
        );

        // Least Creditors: Lowest positive balance up to highest
        expect(res.leastCreditors.length, equals(2));
        expect(
          res.leastCreditors[0].customerName,
          contains('Walk-in'),
        );
        expect(
          res.leastCreditors[0].outstandingBalance,
          equals(5000.0),
        );
        expect(
          res.leastCreditors[1].customerName,
          equals('Dan'),
        );
        expect(
          res.leastCreditors[1].outstandingBalance,
          equals(10000.0),
        );
      },
    );

    test('Ranks Staff and groups Departments with Others', () {
      final res = InvoiceSummaryBuilder.build(
        allRows: rows,
        allReceipts: allReceipts,
        period: InvoiceSummaryPeriod.today,
        businessNow: now,
        departmentsEnabled: true,
        bulkSaleEnabled: true,
      );

      // Staff: Alice has inv1 + inv2 = 30,000; Eve has inv3 = 5,000
      expect(res.top3Staff.length, equals(2));
      expect(res.top3Staff[0].staffName, equals('Alice'));
      expect(
        res.top3Staff[0].totalInvoiceValue,
        equals(30000.0),
      );
      expect(res.top3Staff[0].invoiceCount, equals(2));
      expect(res.top3Staff[1].staffName, equals('Eve'));
      expect(
        res.top3Staff[1].totalInvoiceValue,
        equals(5000.0),
      );

      // Departments: Bakery (20,000), Beverages (10,000), Others (5,000)
      expect(res.departmentSummaries.length, equals(3));
      final deptNames =
          res.departmentSummaries
              .map((d) => d.departmentName)
              .toList();
      expect(
        deptNames,
        containsAll(['Bakery', 'Beverages', 'Others']),
      );

      final othersDept = res.departmentSummaries.firstWhere(
        (d) => d.departmentName == 'Others',
      );
      expect(othersDept.totalInvoiceValue, equals(5000.0));
      expect(othersDept.departmentKey, isNull);

      // Sub-staff: Charlie has inv1 = 10,000
      expect(
        res.subStaffSummaries.length,
        greaterThanOrEqualTo(1),
      );
      final charlie = res.subStaffSummaries.firstWhere(
        (s) => s.subStaffName == 'Charlie',
      );
      expect(charlie.totalInvoiceValue, equals(10000.0));
    });

    test(
      'Payment Collection Summary classifies Cash and Split correctly',
      () {
        final res = InvoiceSummaryBuilder.build(
          allRows: rows,
          allReceipts: allReceipts,
          period: InvoiceSummaryPeriod.today,
          businessNow: now,
          departmentsEnabled: true,
          bulkSaleEnabled: true,
        );

        // Receipts in period:
        // rec1: 10,000 cash (pure cash)
        // rec2: 5,000 cash + 5,000 bank (split transaction)
        final pCol = res.paymentChannelSummaries;
        expect(pCol.length, greaterThanOrEqualTo(3));

        final cashItem = pCol.firstWhere(
          (p) => p.channelName == 'Cash',
        );
        final bankItem = pCol.firstWhere(
          (p) => p.channelName == 'Bank',
        );
        final splitItem = pCol.firstWhere(
          (p) => p.channelName == 'Split',
        );

        // Pure cash receipt count = 1
        expect(cashItem.transactionCount, equals(1));
        // Pure bank receipt count = 0
        expect(bankItem.transactionCount, equals(0));
        // Split receipt count = 1
        expect(splitItem.transactionCount, equals(1));

        // Split amount = 10,000
        expect(splitItem.amountCollected, equals(10000.0));
        // Total collected across all receipts = 20,000
        expect(
          res.stats.totalCollectionsInPeriod,
          equals(20000.0),
        );
      },
    );
  });
}
