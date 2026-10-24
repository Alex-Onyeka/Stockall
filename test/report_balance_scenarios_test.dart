import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/temp_invoices/temp_invoices.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/classes/temp_product_class/prices_class/product_prices_class.dart';
import 'package:stockall/classes/temp_product_class/units_class/product_units_class.dart';
import 'package:stockall/classes/temp_product_slaes_record/temp_product_sale_record.dart';
import 'package:stockall/pages/report/invoice_report/invoice_report_table/class/invoice_report_table_logic.dart';
import 'package:stockall/pages/report/sales_report_/item_sales_report_main/class/item_sales_report_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

TempMainReceipt makeReceipt({
  required String uuid,
  required double cash,
  required double bank,
  required int salesTypeIndex,
  String? invoiceUuid,
  String? orderUuid,
  double? balance,
  List<TempProductSaleRecord>? items,
}) {
  return TempMainReceipt(
    uuid: uuid,
    barcode: '111',
    createdAt: DateTime(2026, 10, 20, 10),
    shopId: 1,
    staffId: 'staff-1',
    staffName: 'Staff One',
    paymentMethod:
        cash > 0 && bank > 0
            ? 'Split'
            : (bank > 0 ? 'Bank' : 'Cash'),
    bank: bank,
    cashAlt: cash,
    customerAccount: 0,
    departmentName: null,
    departmentUuidNew: null,
    isInvoice: invoiceUuid != null,
    invoiceUuid: invoiceUuid,
    orderUuid: orderUuid,
    generalDiscount: null,
    fixedDiscount: null,
    vat: null,
    originalCost: cash + bank,
    balance: balance,
    subStaffUuid: null,
    subStaffName: null,
    cartName: null,
    comment: null,
    salesTypeIndex: salesTypeIndex,
    items: items,
  );
}

TempInvoice makeInvoice({
  required String uuid,
  required double cash,
  required double bank,
  List<TempProductSaleRecord>? items,
}) {
  return TempInvoice(
    uuid: uuid,
    barcode: 'INV111',
    createdAt: DateTime(2026, 10, 20, 10),
    shopId: 1,
    staffId: 'staff-1',
    staffName: 'Staff One',
    paymentMethod:
        cash > 0 && bank > 0
            ? 'Split'
            : (bank > 0 ? 'Bank' : 'Cash'),
    bank: bank,
    cashAlt: cash,
    departmentName: null,
    departmentUuidNew: null,
    cartName: 'Cart 1',
    subStaffName: null,
    comment: null,
    items: items,
  );
}

void main() {
  group(
    'Scenario 1: Items sold at prices lower than catalog price',
    () {
      test(
        'Custom price lower than catalog price balances in all 3 reports',
        () {
          const catalogPrice = 1000.0;
          const customPrice = 800.0;
          const unitCost = 600.0;
          const expectedProfit =
              customPrice - unitCost; // 200
          const expectedMargin =
              (expectedProfit / customPrice) * 100; // 25%

          final saleLine = TempProductSaleRecord(
            createdAt: DateTime(2026, 10, 20, 10),
            productId: 1,
            productUuid: 'prod-custom-1',
            productName: 'Discounted Item',
            shopId: 1,
            staffId: 'staff-1',
            staffName: 'Staff One',
            recepitId: 1,
            receiptUuid: 'rec-custom-1',
            quantity: 1,
            revenue: customPrice,
            discountedAmount: 0,
            originalCost: catalogPrice,
            discount: null,
            costPrice: unitCost,
            customPriceSet: true,
            setTotalPrice: false,
            departmentName: null,
            departmentUuid: null,
            isProductManaged: true,
            useGroupQuantity: false,
            qttyPerGroup: 1,
            isVoid: false,
            unitsList: [],
            unitUuid: null,
            pricesList: [],
            priceUuid: null,
            widthDimension: null,
            heightDimension: null,
            quantityType: 1,
            manageSalesWastage: false,
            isPercentageWastage: false,
            wastageAmount: null,
          );

          // 1. Receipt Report
          final receipt = makeReceipt(
            uuid: 'rec-custom-1',
            cash: customPrice,
            bank: 0,
            salesTypeIndex: 1,
            items: [saleLine],
          );

          final receiptRow = ReceiptsReportRowBuilder.build(
            receipt: receipt,
            legacyLines: {},
          );

          expect(receiptRow.revenue, equals(customPrice));
          expect(receiptRow.profit, equals(expectedProfit));
          expect(
            receiptRow.lineRevenue,
            equals(customPrice),
          );
          expect(
            receiptRow.margin,
            closeTo(expectedMargin, 0.001),
          );

          // 2. Item Sales Report
          final itemSalesRow = ItemSalesRowBuilder.build(
            line: saleLine,
            parent: receiptRow,
            lineIndex: 0,
            productsByUuid: {},
            categoryNameByUuid: {},
          );

          expect(itemSalesRow.revenue, equals(customPrice));
          expect(itemSalesRow.cost, equals(unitCost));
          expect(
            itemSalesRow.profit,
            equals(expectedProfit),
          );
          expect(
            itemSalesRow.margin,
            closeTo(expectedMargin, 0.001),
          );
          expect(itemSalesRow.customPrice, isTrue);

          // 3. Invoice Report
          final invoice = makeInvoice(
            uuid: 'inv-custom-1',
            cash: customPrice,
            bank: 0,
            items: [saleLine],
          );

          final invoiceRow =
              InvoiceReportRowBuilder.buildSingle(
                invoice: invoice,
                relatedReceipts: [receipt],
                fallbackSales: [],
                customerMap: {},
              );

          expect(
            invoiceRow.invoiceTotal,
            equals(customPrice),
          );
          expect(invoiceRow.cost, equals(unitCost));
          expect(invoiceRow.profit, equals(expectedProfit));
          expect(
            invoiceRow.margin,
            closeTo(expectedMargin, 0.001),
          );
          expect(
            invoiceRow.amountPaid,
            equals(customPrice),
          );
          expect(invoiceRow.balance, equals(0));
        },
      );
    },
  );

  group('Scenario 2: Invoice Part Payments', () {
    test(
      'Prorated part payments balance revenue, profit, margin and collections across all reports',
      () {
        const invoiceTotal = 10000.0;
        const invoiceCost = 6000.0;
        const expectedFullProfit = 4000.0;
        const expectedMargin = 40.0;

        const payment1 = 4000.0;
        const ratio1 = payment1 / invoiceTotal; // 0.4
        const p1Revenue = invoiceTotal * ratio1; // 4,000
        const p1Cost = invoiceCost * ratio1; // 2,400
        const p1Profit = p1Revenue - p1Cost; // 1,600

        const payment2 = 6000.0;
        const ratio2 = payment2 / invoiceTotal; // 0.6
        const p2Revenue = invoiceTotal * ratio2; // 6,000
        const p2Cost = invoiceCost * ratio2; // 3,600
        const p2Profit = p2Revenue - p2Cost; // 2,400

        final p1Line = TempProductSaleRecord(
          createdAt: DateTime(2026, 10, 21, 10),
          productId: 1,
          productUuid: 'item-inv-1',
          productName: 'Contract Item',
          shopId: 1,
          staffId: 'staff-1',
          staffName: 'Staff One',
          recepitId: 1,
          receiptUuid: 'rec-part-1',
          quantity: 10,
          revenue: p1Revenue,
          discountedAmount: 0,
          originalCost: p1Revenue,
          discount: null,
          costPrice: p1Cost,
          customPriceSet: false,
          departmentName: null,
          departmentUuid: null,
          isProductManaged: true,
          useGroupQuantity: false,
          qttyPerGroup: 1,
          isVoid: false,
          unitsList: [],
          unitUuid: null,
          pricesList: [],
          priceUuid: null,
          widthDimension: null,
          heightDimension: null,
          quantityType: 1,
          manageSalesWastage: false,
          isPercentageWastage: false,
          wastageAmount: null,
        );

        final p2Line = TempProductSaleRecord(
          createdAt: DateTime(2026, 10, 22, 10),
          productId: 1,
          productUuid: 'item-inv-1',
          productName: 'Contract Item',
          shopId: 1,
          staffId: 'staff-1',
          staffName: 'Staff One',
          recepitId: 2,
          receiptUuid: 'rec-part-2',
          quantity: 10,
          revenue: p2Revenue,
          discountedAmount: 0,
          originalCost: p2Revenue,
          discount: null,
          costPrice: p2Cost,
          customPriceSet: false,
          departmentName: null,
          departmentUuid: null,
          isProductManaged: true,
          useGroupQuantity: false,
          qttyPerGroup: 1,
          isVoid: false,
          unitsList: [],
          unitUuid: null,
          pricesList: [],
          priceUuid: null,
          widthDimension: null,
          heightDimension: null,
          quantityType: 1,
          manageSalesWastage: false,
          isPercentageWastage: false,
          wastageAmount: null,
        );

        final rec1 = makeReceipt(
          uuid: 'rec-part-1',
          cash: 0,
          bank: payment1,
          salesTypeIndex: 2, // ReceiptType.invoicePayment
          invoiceUuid: 'inv-part-1',
          balance: invoiceTotal - payment1,
          items: [p1Line],
        );

        final rec2 = makeReceipt(
          uuid: 'rec-part-2',
          cash: payment2,
          bank: 0,
          salesTypeIndex: 2, // ReceiptType.invoicePayment
          invoiceUuid: 'inv-part-1',
          balance: 0,
          items: [p2Line],
        );

        // 1. Receipt Report checks
        final recRow1 = ReceiptsReportRowBuilder.build(
          receipt: rec1,
          legacyLines: {},
        );
        expect(recRow1.revenue, equals(payment1));
        expect(recRow1.profit, equals(p1Profit));
        expect(
          recRow1.margin,
          closeTo(expectedMargin, 0.001),
        );
        expect(recRow1.balance, equals(6000));
        expect(
          recRow1.type,
          equals(ReceiptType.invoicePayment),
        );

        final recRow2 = ReceiptsReportRowBuilder.build(
          receipt: rec2,
          legacyLines: {},
        );
        expect(recRow2.revenue, equals(payment2));
        expect(recRow2.profit, equals(p2Profit));
        expect(
          recRow2.margin,
          closeTo(expectedMargin, 0.001),
        );
        expect(recRow2.balance, equals(0));

        final receiptsPage = ReceiptsReportQuery.paginate([
          recRow1,
          recRow2,
        ], 1);
        expect(
          receiptsPage.totalRevenue,
          equals(invoiceTotal),
        );
        expect(
          receiptsPage.totalProfit,
          equals(expectedFullProfit),
        );
        expect(
          receiptsPage.totalMargin,
          closeTo(expectedMargin, 0.001),
        );

        // 2. Item Sales Report checks
        final itemRow1 = ItemSalesRowBuilder.build(
          line: p1Line,
          parent: recRow1,
          lineIndex: 0,
          productsByUuid: {},
          categoryNameByUuid: {},
        );
        expect(itemRow1.revenue, equals(p1Revenue));
        expect(itemRow1.cost, equals(p1Cost));
        expect(itemRow1.profit, equals(p1Profit));
        expect(
          itemRow1.margin,
          closeTo(expectedMargin, 0.001),
        );
        expect(itemRow1.isPartPayment, isTrue);

        final itemRow2 = ItemSalesRowBuilder.build(
          line: p2Line,
          parent: recRow2,
          lineIndex: 0,
          productsByUuid: {},
          categoryNameByUuid: {},
        );
        expect(itemRow2.revenue, equals(p2Revenue));
        expect(itemRow2.cost, equals(p2Cost));
        expect(itemRow2.profit, equals(p2Profit));
        expect(
          itemRow2.margin,
          closeTo(expectedMargin, 0.001),
        );

        final itemSalesPage = ItemSalesQuery.paginate([
          itemRow1,
          itemRow2,
        ], 1);
        expect(
          itemSalesPage.totalRevenue,
          equals(invoiceTotal),
        );
        expect(
          itemSalesPage.totalCost,
          equals(invoiceCost),
        );
        expect(
          itemSalesPage.totalProfit,
          equals(expectedFullProfit),
        );
        expect(
          itemSalesPage.totalMargin,
          closeTo(expectedMargin, 0.001),
        );

        // 3. Invoice Report checks
        final fullInvoiceLine = TempProductSaleRecord(
          createdAt: DateTime(2026, 10, 20, 10),
          productId: 1,
          productUuid: 'item-inv-1',
          productName: 'Contract Item',
          shopId: 1,
          staffId: 'staff-1',
          staffName: 'Staff One',
          recepitId: 0,
          quantity: 10,
          revenue: invoiceTotal,
          discountedAmount: 0,
          originalCost: invoiceTotal,
          discount: null,
          costPrice: invoiceCost,
          customPriceSet: false,
          departmentName: null,
          departmentUuid: null,
          isProductManaged: true,
          useGroupQuantity: false,
          qttyPerGroup: 1,
          isVoid: false,
          unitsList: [],
          unitUuid: null,
          pricesList: [],
          priceUuid: null,
          widthDimension: null,
          heightDimension: null,
          quantityType: 1,
          manageSalesWastage: false,
          isPercentageWastage: false,
          wastageAmount: null,
        );

        final invoice = makeInvoice(
          uuid: 'inv-part-1',
          cash: 6000,
          bank: 4000,
          items: [fullInvoiceLine],
        );

        final invRowAfterP1 =
            InvoiceReportRowBuilder.buildSingle(
              invoice: invoice,
              relatedReceipts: [rec1],
              fallbackSales: [],
              customerMap: {},
            );
        expect(
          invRowAfterP1.invoiceTotal,
          equals(invoiceTotal),
        );
        expect(invRowAfterP1.amountPaid, equals(payment1));
        expect(invRowAfterP1.balance, equals(6000));
        expect(invRowAfterP1.status, equals(1)); // Partial
        expect(invRowAfterP1.cost, equals(invoiceCost));
        expect(
          invRowAfterP1.profit,
          equals(expectedFullProfit),
        );
        expect(
          invRowAfterP1.margin,
          closeTo(expectedMargin, 0.001),
        );

        final invRowAfterP2 =
            InvoiceReportRowBuilder.buildSingle(
              invoice: invoice,
              relatedReceipts: [rec1, rec2],
              fallbackSales: [],
              customerMap: {},
            );
        expect(
          invRowAfterP2.amountPaid,
          equals(invoiceTotal),
        );
        expect(invRowAfterP2.balance, equals(0));
        expect(invRowAfterP2.status, equals(2)); // Paid
        expect(
          invRowAfterP2.profit,
          equals(expectedFullProfit),
        );
        expect(
          invRowAfterP2.margin,
          closeTo(expectedMargin, 0.001),
        );
      },
    );
  });

  group(
    'Scenario 3: Part Delivers (Order Delivery receipts)',
    () {
      test(
        'Delivered lines record revenue, cost, and profit accurately',
        () {
          const deliveredQty = 2.0;
          const unitDeliveredPrice = 5000.0;
          const unitDeliveredCost = 3000.0;
          const deliveredRevenue =
              deliveredQty * unitDeliveredPrice; // 10,000
          const deliveredCost =
              deliveredQty * unitDeliveredCost; // 6,000
          const expectedProfit =
              deliveredRevenue - deliveredCost; // 4,000
          const expectedMargin =
              (expectedProfit / deliveredRevenue) *
              100; // 40%

          final deliveryLine = TempProductSaleRecord(
            createdAt: DateTime(2026, 10, 22, 14),
            productId: 2,
            productUuid: 'order-item-1',
            productName: 'Delivered Item',
            shopId: 1,
            staffId: 'staff-1',
            staffName: 'Staff One',
            recepitId: 1,
            receiptUuid: 'rec-deliv-1',
            quantity: deliveredQty,
            revenue: deliveredRevenue,
            discountedAmount: 0,
            originalCost: deliveredRevenue,
            discount: null,
            costPrice: deliveredCost,
            customPriceSet: false,
            departmentName: null,
            departmentUuid: null,
            isProductManaged: true,
            useGroupQuantity: false,
            qttyPerGroup: 1,
            isVoid: false,
            unitsList: [],
            unitUuid: null,
            pricesList: [],
            priceUuid: null,
            widthDimension: null,
            heightDimension: null,
            quantityType: 1,
            manageSalesWastage: false,
            isPercentageWastage: false,
            wastageAmount: null,
          );

          final deliveryReceipt = makeReceipt(
            uuid: 'rec-deliv-1',
            cash: deliveredRevenue,
            bank: 0,
            salesTypeIndex: 3, // ReceiptType.orderDelivery
            orderUuid: 'order-123',
            balance: 5000,
            items: [deliveryLine],
          );

          final receiptRow = ReceiptsReportRowBuilder.build(
            receipt: deliveryReceipt,
            legacyLines: {},
          );

          expect(
            receiptRow.type,
            equals(ReceiptType.orderDelivery),
          );
          expect(
            receiptRow.revenue,
            equals(deliveredRevenue),
          );
          expect(receiptRow.profit, equals(expectedProfit));
          expect(
            receiptRow.lineRevenue,
            equals(deliveredRevenue),
          );
          expect(
            receiptRow.margin,
            closeTo(expectedMargin, 0.001),
          );
          expect(receiptRow.balance, equals(5000));

          final itemRow = ItemSalesRowBuilder.build(
            line: deliveryLine,
            parent: receiptRow,
            lineIndex: 0,
            productsByUuid: {},
            categoryNameByUuid: {},
          );

          expect(
            itemRow.type,
            equals(ReceiptType.orderDelivery),
          );
          expect(itemRow.quantity, equals(deliveredQty));
          expect(itemRow.revenue, equals(deliveredRevenue));
          expect(itemRow.cost, equals(deliveredCost));
          expect(itemRow.profit, equals(expectedProfit));
          expect(
            itemRow.margin,
            closeTo(expectedMargin, 0.001),
          );
        },
      );
    },
  );

  group(
    'Scenario 4: 2D items sold with custom dimensions lower than full dimensions',
    () {
      test(
        'Proportional area cost and revenue scaling balances in all 3 reports',
        () {
          const customWidth = 1.5;
          const customHeight = 1.0;
          const cutArea =
              customWidth * customHeight; // 1.5 m²
          const pricePerSqm = 10000.0;
          const costPerSqm = 6000.0;
          const cutRevenue =
              pricePerSqm * cutArea; // 15,000
          const cutCost = costPerSqm * cutArea; // 9,000
          const expectedProfit =
              cutRevenue - cutCost; // 6,000
          const expectedMargin =
              (expectedProfit / cutRevenue) * 100; // 40%

          final pieceUnit = ProductUnitsClass(
            uuid: 'unit-piece',
            staffUuid: null,
            createdAt: DateTime.utc(2026),
            staffName: null,
            conversion: 1,
            name: 'Slab',
            isPrimary: true,
            productUuid: 'slab-prod-1',
            dimensionType: ProductUnitsClass.sheetUnit,
          );

          final pieceLine = TempProductSaleRecord(
            createdAt: DateTime(2026, 10, 23, 11),
            productId: 3,
            productUuid: 'slab-prod-1',
            productName: 'Granite Slab Cut',
            shopId: 1,
            staffId: 'staff-1',
            staffName: 'Staff One',
            recepitId: 1,
            receiptUuid: 'rec-2d-1',
            quantity: 1,
            revenue: cutRevenue,
            discountedAmount: 0,
            originalCost: cutRevenue,
            discount: null,
            costPrice: cutCost,
            customPriceSet: false,
            departmentName: null,
            departmentUuid: null,
            isProductManaged: true,
            useGroupQuantity: false,
            qttyPerGroup: 1,
            isVoid: false,
            unitsList: [pieceUnit],
            unitUuid: 'unit-piece',
            pricesList: [
              ProductPricesClass(
                uuid: 'price-1',
                staffUuid: 'staff-1',
                createdAt: DateTime.utc(2026),
                staffName: 'Staff One',
                priceValue: pricePerSqm,
                name: 'Default Price',
                isPrimary: true,
                itemUuid: 'slab-prod-1',
              ),
            ],
            priceUuid: 'price-1',
            widthDimension: customWidth,
            heightDimension: customHeight,
            dimensionUnit: 'm',
            dimensionUnitConversion: 1,
            quantityType: 2, // 2D Dimensional item
            manageSalesWastage: false,
            isPercentageWastage: false,
            wastageAmount: null,
          );

          final receipt = makeReceipt(
            uuid: 'rec-2d-1',
            cash: 0,
            bank: cutRevenue,
            salesTypeIndex: 1,
            items: [pieceLine],
          );

          final receiptRow = ReceiptsReportRowBuilder.build(
            receipt: receipt,
            legacyLines: {},
          );

          expect(receiptRow.revenue, equals(cutRevenue));
          expect(receiptRow.profit, equals(expectedProfit));
          expect(
            receiptRow.lineRevenue,
            equals(cutRevenue),
          );
          expect(
            receiptRow.margin,
            closeTo(expectedMargin, 0.001),
          );

          final itemRow = ItemSalesRowBuilder.build(
            line: pieceLine,
            parent: receiptRow,
            lineIndex: 0,
            productsByUuid: {},
            categoryNameByUuid: {},
          );

          expect(itemRow.revenue, equals(cutRevenue));
          expect(itemRow.cost, equals(cutCost));
          expect(itemRow.profit, equals(expectedProfit));
          expect(
            itemRow.margin,
            closeTo(expectedMargin, 0.001),
          );
          expect(
            itemRow.baseQuantity,
            equals(cutArea),
          ); // 1.5 M²

          final invoice = makeInvoice(
            uuid: 'inv-2d-1',
            cash: 0,
            bank: cutRevenue,
            items: [pieceLine],
          );

          final invoiceRow =
              InvoiceReportRowBuilder.buildSingle(
                invoice: invoice,
                relatedReceipts: [receipt],
                fallbackSales: [],
                customerMap: {},
              );

          expect(
            invoiceRow.invoiceTotal,
            equals(cutRevenue),
          );
          expect(invoiceRow.cost, equals(cutCost));
          expect(invoiceRow.profit, equals(expectedProfit));
          expect(
            invoiceRow.margin,
            closeTo(expectedMargin, 0.001),
          );
          expect(invoiceRow.totalItems, equals(cutArea));
        },
      );
    },
  );
}
