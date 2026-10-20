import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/temp_customers/temp_customers_class.dart';
import 'package:stockall/classes/temp_invoices/temp_invoices.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/classes/temp_product_class/units_class/product_units_class.dart';
import 'package:stockall/classes/temp_product_slaes_record/temp_product_sale_record.dart';
import 'package:stockall/pages/report/invoice_report/invoice_report_table/class/invoice_report_table_logic.dart';

void main() {
  group('InvoiceReportRowBuilder Tests', () {
    test(
      'Calculates ID with priority: id -> barcode -> uuid digits -> dash',
      () {
        final invWithId = TempInvoice(
          id: 101,
          barcode: 'BAR123',
          uuid: 'inv-uuid-abc',
          createdAt: DateTime(2026, 5, 1, 10, 0),
          shopId: 1,
          staffId: 'staff-1',
          staffName: 'Alice',
          paymentMethod: 'Cash',
          bank: 0,
          cashAlt: 1000,
          departmentName: null,
          departmentUuidNew: null,
          cartName: 'Cart 1',
          subStaffName: null,
          comment: null,
        );

        final row1 = InvoiceReportRowBuilder.buildSingle(
          invoice: invWithId,
          relatedReceipts: [],
          fallbackSales: [],
          customerMap: {},
        );
        expect(row1.displayId, equals('#101'));

        final invWithBarcode = TempInvoice(
          id: null,
          barcode: 'BAR123',
          uuid: 'inv-uuid-abc',
          createdAt: DateTime(2026, 5, 1, 10, 0),
          shopId: 1,
          staffId: 'staff-1',
          staffName: 'Alice',
          paymentMethod: 'Cash',
          bank: 0,
          cashAlt: 1000,
          departmentName: null,
          departmentUuidNew: null,
          cartName: 'Cart 1',
          subStaffName: null,
          comment: null,
        );
        final row2 = InvoiceReportRowBuilder.buildSingle(
          invoice: invWithBarcode,
          relatedReceipts: [],
          fallbackSales: [],
          customerMap: {},
        );
        expect(row2.displayId, equals('#BAR123'));

        final invWithUuid = TempInvoice(
          id: null,
          barcode: null,
          uuid: 'abc-9876-xyz',
          createdAt: DateTime(2026, 5, 1, 10, 0),
          shopId: 1,
          staffId: 'staff-1',
          staffName: 'Alice',
          paymentMethod: 'Cash',
          bank: 0,
          cashAlt: 1000,
          departmentName: null,
          departmentUuidNew: null,
          cartName: 'Cart 1',
          subStaffName: null,
          comment: null,
        );
        final row3 = InvoiceReportRowBuilder.buildSingle(
          invoice: invWithUuid,
          relatedReceipts: [],
          fallbackSales: [],
          customerMap: {},
        );
        expect(row3.displayId, equals('#9876'));
      },
    );

    test(
      'Resolves customer name from invoice, customerMap, or walk-in fallback',
      () {
        final Map<String, TempCustomersClass> custMap = {
          'cust-1': TempCustomersClass(
            name: 'John Doe',
            uuid: 'cust-1',
            dateAdded: DateTime(2026, 1, 1),
            email: '',
            phone: '',
            address: '',
            city: '',
            state: '',
            shopId: 1,
            departmentName: '',
            departmentUuid: '',
            balance: 0,
            cashReward: 0,
          ),
        };

        final inv1 = TempInvoice(
          customerName: 'Direct Customer',
          customerUuid: 'cust-1',
          createdAt: DateTime(2026, 5, 1),
          shopId: 1,
          staffId: 'staff-1',
          staffName: 'Alice',
          paymentMethod: 'Cash',
          bank: 0,
          cashAlt: 500,
          departmentName: null,
          departmentUuidNew: null,
          cartName: 'Cart 1',
          subStaffName: null,
          comment: null,
        );
        final row1 = InvoiceReportRowBuilder.buildSingle(
          invoice: inv1,
          relatedReceipts: [],
          fallbackSales: [],
          customerMap: custMap,
        );
        expect(
          row1.customerName,
          equals('Direct Customer'),
        );

        final inv2 = TempInvoice(
          customerName: null,
          customerUuid: 'cust-1',
          createdAt: DateTime(2026, 5, 1),
          shopId: 1,
          staffId: 'staff-1',
          staffName: 'Alice',
          paymentMethod: 'Cash',
          bank: 0,
          cashAlt: 500,
          departmentName: null,
          departmentUuidNew: null,
          cartName: 'Cart 1',
          subStaffName: null,
          comment: null,
        );
        final row2 = InvoiceReportRowBuilder.buildSingle(
          invoice: inv2,
          relatedReceipts: [],
          fallbackSales: [],
          customerMap: custMap,
        );
        expect(row2.customerName, equals('John Doe'));

        final inv3 = TempInvoice(
          customerName: null,
          customerUuid: null,
          createdAt: DateTime(2026, 5, 1),
          shopId: 1,
          staffId: 'staff-1',
          staffName: 'Alice',
          paymentMethod: 'Cash',
          bank: 0,
          cashAlt: 500,
          departmentName: null,
          departmentUuidNew: null,
          cartName: 'Cart 1',
          subStaffName: null,
          comment: null,
        );
        final row3 = InvoiceReportRowBuilder.buildSingle(
          invoice: inv3,
          relatedReceipts: [],
          fallbackSales: [],
          customerMap: custMap,
        );
        expect(
          row3.customerName,
          equals('Walk-in Customer'),
        );
      },
    );

    test(
      'Aggregates payments and classifies payment channels correctly',
      () {
        final inv = TempInvoice(
          uuid: 'inv-1',
          createdAt: DateTime(2026, 5, 1),
          shopId: 1,
          staffId: 'staff-1',
          staffName: 'Alice',
          paymentMethod: 'Cash',
          bank: 0,
          cashAlt: 10000,
          departmentName: null,
          departmentUuidNew: null,
          cartName: 'Cart 1',
          subStaffName: null,
          comment: null,
        );

        // No payments => Unpaid channel, status 0
        final rowUnpaid =
            InvoiceReportRowBuilder.buildSingle(
              invoice: inv,
              relatedReceipts: [],
              fallbackSales: [],
              customerMap: {},
            );
        expect(rowUnpaid.amountPaid, equals(0));
        expect(rowUnpaid.balance, equals(10000));
        expect(rowUnpaid.status, equals(0));
        expect(rowUnpaid.paymentChannel, equals('Unpaid'));

        // Partial payment by Cash
        final recCash = TempMainReceipt(
          uuid: 'rec-1',
          invoiceUuid: 'inv-1',
          shopId: 1,
          staffId: 'staff-1',
          staffName: 'Alice',
          paymentMethod: 'Cash',
          bank: 0,
          cashAlt: 4000,
          customerAccount: 0,
          createdAt: DateTime(2026, 5, 2),
          isInvoice: true,
          salesTypeIndex: 2,
          departmentName: '',
          departmentUuidNew: '',
          cartName: 'Cart 1',
          subStaffName: '',
          comment: '',
        );
        final rowPartial =
            InvoiceReportRowBuilder.buildSingle(
              invoice: inv,
              relatedReceipts: [recCash],
              fallbackSales: [],
              customerMap: {},
            );
        expect(rowPartial.amountPaid, equals(4000));
        expect(rowPartial.balance, equals(6000));
        expect(rowPartial.status, equals(1));
        expect(rowPartial.paymentChannel, equals('Cash'));

        // Additional payment by Bank => Split channel, fully paid (status 2)
        final recBank = TempMainReceipt(
          uuid: 'rec-2',
          invoiceUuid: 'inv-1',
          shopId: 1,
          staffId: 'staff-1',
          staffName: 'Alice',
          paymentMethod: 'Bank',
          bank: 6000,
          cashAlt: 0,
          customerAccount: 0,
          createdAt: DateTime(2026, 5, 3),
          isInvoice: true,
          salesTypeIndex: 2,
          departmentName: '',
          departmentUuidNew: '',
          cartName: 'Cart 1',
          subStaffName: '',
          comment: '',
        );
        final rowPaid = InvoiceReportRowBuilder.buildSingle(
          invoice: inv,
          relatedReceipts: [recCash, recBank],
          fallbackSales: [],
          customerMap: {},
        );
        expect(rowPaid.amountPaid, equals(10000));
        expect(rowPaid.balance, equals(0));
        expect(rowPaid.status, equals(2));
        expect(rowPaid.paymentChannel, equals('Split'));
      },
    );

    test(
      'Calculates items, cost, profit, and margin from sold lines',
      () {
        final line1 = TempProductSaleRecord(
          createdAt: DateTime(2026, 5, 1),
          productId: 1,
          productName: 'Bottle',
          shopId: 1,
          staffId: 'staff-1',
          staffName: 'Alice',
          recepitId: 0,
          quantity: 2,
          revenue: 2000,
          discountedAmount: 0,
          originalCost: 2000,
          costPrice: 1200,
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
          unitsList: [
            ProductUnitsClass(
              uuid: 'u-1',
              staffUuid: 'staff-1',
              createdAt: DateTime(2026, 1, 1),
              staffName: 'Alice',
              conversion: 1,
              name: 'Bottle',
              isPrimary: true,
              productUuid: 'prod-1',
            ),
          ],
          unitUuid: 'u-1',
        );

        final line2 = TempProductSaleRecord(
          createdAt: DateTime(2026, 5, 1),
          productId: 2,
          productName: 'Pack (10)',
          shopId: 1,
          staffId: 'staff-1',
          staffName: 'Alice',
          recepitId: 0,
          quantity: 3,
          revenue: 3000,
          discountedAmount: 0,
          originalCost: 3000,
          costPrice: 1800,
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
          unitsList: [
            ProductUnitsClass(
              uuid: 'u-pack',
              staffUuid: 'staff-1',
              createdAt: DateTime(2026, 1, 1),
              staffName: 'Alice',
              conversion: 10,
              name: 'Pack',
              isPrimary: false,
              productUuid: 'prod-2',
            ),
          ],
          unitUuid: 'u-pack',
        );

        final inv = TempInvoice(
          uuid: 'inv-items',
          createdAt: DateTime(2026, 5, 1),
          shopId: 1,
          staffId: 'staff-1',
          staffName: 'Alice',
          paymentMethod: 'Cash',
          bank: 0,
          cashAlt: 5000,
          departmentName: 'Beverages',
          departmentUuidNew: 'dept-1',
          cartName: 'Cart 1',
          subStaffName: null,
          comment: 'Handle with care',
          items: [line1, line2],
        );

        final row = InvoiceReportRowBuilder.buildSingle(
          invoice: inv,
          relatedReceipts: [],
          fallbackSales: [],
          customerMap: {},
        );

        // line 1: 2 * 1 = 2 items
        // line 2: 3 * 10 = 30 items
        // total items = 32
        expect(row.totalItems, equals(32));

        // Cost: 1200 + 1800 = 3000
        expect(row.cost, equals(3000));

        // Revenue: 5000, Cost: 3000 => Profit = 2000
        expect(row.profit, equals(2000));

        // Margin: (2000 / 5000) * 100 = 40.0%
        expect(row.margin, equals(40.0));
        expect(row.departmentName, equals('Beverages'));
        expect(row.comment, equals('Handle with care'));
      },
    );

    test(
      'Handles invoices with null/empty items safely without crash',
      () {
        final emptyInv = TempInvoice(
          uuid: 'inv-empty',
          createdAt: DateTime(2026, 5, 1),
          shopId: 1,
          staffId: 'staff-1',
          staffName: 'Alice',
          paymentMethod: 'Cash',
          bank: 0,
          cashAlt: 4000,
          departmentName: null,
          departmentUuidNew: null,
          cartName: 'Cart 1',
          subStaffName: null,
          comment: null,
          items: null,
        );

        final row = InvoiceReportRowBuilder.buildSingle(
          invoice: emptyInv,
          relatedReceipts: [],
          fallbackSales: [],
          customerMap: {},
        );

        expect(row.totalItems, isNull);
        expect(row.cost, isNull);
        expect(row.profit, isNull);
        expect(row.margin, isNull);
        expect(row.invoiceTotal, equals(4000));
        expect(row.balance, equals(4000));
        expect(row.status, equals(0));
      },
    );
  });

  group(
    'InvoiceReportQuery Filtering, Sorting, and Pagination',
    () {
      late List<InvoiceReportRow> testRows;

      setUp(() {
        testRows = [
          InvoiceReportRow(
            invoice: TempInvoice(
              id: 1,
              uuid: 'inv-1',
              createdAt: DateTime(2026, 5, 1, 9, 0),
              shopId: 1,
              staffId: 'staff-1',
              staffName: 'Alice',
              paymentMethod: 'Cash',
              bank: 0,
              cashAlt: 1000,
              departmentName: 'Dept A',
              departmentUuidNew: 'dept-a',
              cartName: 'Cart 1',
              subStaffName: 'Sub 1',
              subStaffUuid: 'sub-1',
              comment: null,
            ),
            displayId: '#1',
            staffName: 'Alice',
            subStaffName: 'Sub 1',
            customerName: 'Charlie',
            createdAt: DateTime(2026, 5, 1, 9, 0),
            discountAmount: 0,
            discountDisplay: '—',
            vatAmount: 0,
            vatDisplay: '—',
            totalItems: 5,
            departmentName: 'Dept A',
            departmentKey: 'dept-a',
            comment: '—',
            paymentChannel: 'Cash',
            invoiceTotal: 1000,
            amountPaid: 1000,
            balance: 0,
            cost: 600,
            profit: 400,
            margin: 40.0,
            status: 2, // Paid
          ),
          InvoiceReportRow(
            invoice: TempInvoice(
              id: 2,
              uuid: 'inv-2',
              createdAt: DateTime(2026, 5, 2, 11, 0),
              shopId: 1,
              staffId: 'staff-2',
              staffName: 'Bob',
              paymentMethod: 'Bank',
              bank: 5000,
              cashAlt: 0,
              departmentName: null,
              departmentUuidNew: null,
              cartName: 'Cart 2',
              subStaffName: null,
              comment: null,
            ),
            displayId: '#2',
            staffName: 'Bob',
            subStaffName: '—',
            customerName: 'David',
            createdAt: DateTime(2026, 5, 2, 11, 0),
            discountAmount: 0,
            discountDisplay: '—',
            vatAmount: 0,
            vatDisplay: '—',
            totalItems: 10,
            departmentName: 'No Department',
            departmentKey: null,
            comment: '—',
            paymentChannel: 'Unpaid',
            invoiceTotal: 5000,
            amountPaid: 0,
            balance: 5000,
            cost: 3500,
            profit: 1500,
            margin: 30.0,
            status: 0, // Unpaid
          ),
          InvoiceReportRow(
            invoice: TempInvoice(
              id: 3,
              uuid: 'inv-3',
              createdAt: DateTime(2026, 5, 3, 14, 0),
              shopId: 1,
              staffId: 'staff-1',
              staffName: 'Alice',
              paymentMethod: 'Split',
              bank: 1000,
              cashAlt: 2000,
              departmentName: 'Dept B',
              departmentUuidNew: 'dept-b',
              cartName: 'Cart 3',
              subStaffName: 'Sub 2',
              subStaffUuid: 'sub-2',
              comment: null,
            ),
            displayId: '#3',
            staffName: 'Alice',
            subStaffName: 'Sub 2',
            customerName: 'Eve',
            createdAt: DateTime(2026, 5, 3, 14, 0),
            discountAmount: 0,
            discountDisplay: '—',
            vatAmount: 0,
            vatDisplay: '—',
            totalItems: 8,
            departmentName: 'Dept B',
            departmentKey: 'dept-b',
            comment: '—',
            paymentChannel: 'Split',
            invoiceTotal: 3000,
            amountPaid: 1500,
            balance: 1500,
            cost: 3200,
            profit: -200, // Loss
            margin: -6.67,
            status: 1, // Partial
          ),
        ];
      });

      test(
        'Search filters across customer, staff, ID, and department',
        () {
          final filters =
              InvoiceReportFilters()..search = 'Alice';
          final res = InvoiceReportQuery.filterAndSort(
            rows: testRows,
            filters: filters,
            sortField: InvoiceSortField.id,
            ascending: true,
            departmentsEnabled: true,
            bulkSaleEnabled: true,
            costFilterAllowed: true,
          );
          expect(res.length, equals(2));
          expect(
            res.map((r) => r.displayId),
            containsAll(['#1', '#3']),
          );

          filters.search = 'David';
          final resCust = InvoiceReportQuery.filterAndSort(
            rows: testRows,
            filters: filters,
            sortField: InvoiceSortField.id,
            ascending: true,
            departmentsEnabled: true,
            bulkSaleEnabled: true,
            costFilterAllowed: true,
          );
          expect(resCust.length, equals(1));
          expect(resCust.first.displayId, equals('#2'));

          filters.search = 'Dept B';
          final resDept = InvoiceReportQuery.filterAndSort(
            rows: testRows,
            filters: filters,
            sortField: InvoiceSortField.id,
            ascending: true,
            departmentsEnabled: true,
            bulkSaleEnabled: true,
            costFilterAllowed: true,
          );
          expect(resDept.length, equals(1));
          expect(resDept.first.displayId, equals('#3'));
        },
      );

      test(
        'Filter by payment status and payment channel',
        () {
          // Payment status: Unpaid
          final filters =
              InvoiceReportFilters()
                ..paymentStatus =
                    InvoicePaymentStatusFilter.unpaid;
          final resStatus =
              InvoiceReportQuery.filterAndSort(
                rows: testRows,
                filters: filters,
                sortField: InvoiceSortField.id,
                ascending: true,
                departmentsEnabled: true,
                bulkSaleEnabled: true,
                costFilterAllowed: true,
              );
          expect(resStatus.length, equals(1));
          expect(resStatus.first.displayId, equals('#2'));

          // Payment channel: Split
          filters.paymentStatus =
              InvoicePaymentStatusFilter.all;
          filters.paymentChannel =
              InvoicePaymentChannelFilter.split;
          final resChannel =
              InvoiceReportQuery.filterAndSort(
                rows: testRows,
                filters: filters,
                sortField: InvoiceSortField.id,
                ascending: true,
                departmentsEnabled: true,
                bulkSaleEnabled: true,
                costFilterAllowed: true,
              );
          expect(resChannel.length, equals(1));
          expect(resChannel.first.displayId, equals('#3'));
        },
      );

      test(
        'Filter by numeric ranges (total, paid, balance, profit)',
        () {
          // Total between 2000 and 6000
          final filters =
              InvoiceReportFilters()
                ..totalMin = 2000
                ..totalMax = 6000;
          final resTotal = InvoiceReportQuery.filterAndSort(
            rows: testRows,
            filters: filters,
            sortField: InvoiceSortField.id,
            ascending: true,
            departmentsEnabled: true,
            bulkSaleEnabled: true,
            costFilterAllowed: true,
          );
          expect(resTotal.length, equals(2));
          expect(
            resTotal.map((r) => r.displayId),
            containsAll(['#2', '#3']),
          );

          // Profit filter supports negative numbers (loss-making)
          filters.clearAll();
          filters.profitMin = -500;
          filters.profitMax = 0;
          final resLoss = InvoiceReportQuery.filterAndSort(
            rows: testRows,
            filters: filters,
            sortField: InvoiceSortField.id,
            ascending: true,
            departmentsEnabled: true,
            bulkSaleEnabled: true,
            costFilterAllowed: true,
          );
          expect(resLoss.length, equals(1));
          expect(resLoss.first.displayId, equals('#3'));
        },
      );

      test('Sorts correctly ascending and descending', () {
        final filters = InvoiceReportFilters();

        // Sort by Total Descending
        final descTotal = InvoiceReportQuery.filterAndSort(
          rows: testRows,
          filters: filters,
          sortField: InvoiceSortField.total,
          ascending: false,
          departmentsEnabled: true,
          bulkSaleEnabled: true,
          costFilterAllowed: true,
        );
        expect(
          descTotal.map((r) => r.invoiceTotal),
          equals([5000, 3000, 1000]),
        );

        // Sort by Customer Ascending
        final ascCust = InvoiceReportQuery.filterAndSort(
          rows: testRows,
          filters: filters,
          sortField: InvoiceSortField.customer,
          ascending: true,
          departmentsEnabled: true,
          bulkSaleEnabled: true,
          costFilterAllowed: true,
        );
        expect(
          ascCust.map((r) => r.customerName),
          equals(['Charlie', 'David', 'Eve']),
        );
      });

      test('Paginates properly across dataset', () {
        final page1 = InvoiceReportQuery.paginate(
          testRows,
          1,
          pageSize: 2,
        );
        expect(page1.rows.length, equals(2));
        expect(page1.totalCount, equals(3));
        expect(page1.totalPages, equals(2));
        expect(page1.firstIndex, equals(1));
        expect(page1.lastIndex, equals(2));
        expect(page1.totalRevenue, equals(9000));
        expect(page1.totalAmountPaid, equals(2500));
        expect(page1.totalBalance, equals(6500));

        final page2 = InvoiceReportQuery.paginate(
          testRows,
          2,
          pageSize: 2,
        );
        expect(page2.rows.length, equals(1));
        expect(page2.firstIndex, equals(3));
        expect(page2.lastIndex, equals(3));
        expect(page2.totalRevenue, equals(9000));
        expect(page2.totalAmountPaid, equals(2500));
        expect(page2.totalBalance, equals(6500));
      });
    },
  );
}
