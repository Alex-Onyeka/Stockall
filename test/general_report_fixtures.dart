import 'package:stockall/classes/temp_expenses/temp_expenses_class.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/classes/temp_product_slaes_record/temp_product_sale_record.dart';
import 'package:stockall/classes/temp_purchase/temp_purchase.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/class/purchase_report_table_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

// General Report tests. Receipt and line builders as the receipts
// report tests (renamed so they never clash with the purchase
// fixtures' `line` / `row`); purchases come from
// purchase_report_fixtures.dart.

TempMainReceipt saleReceipt({
  String uuid = 'r-0000000000001',
  DateTime? createdAt,
  int? salesTypeIndex = 1,
  double cash = 0,
  double bank = 0,
  double? account,
  String? staffId = 'staff-a',
  String? departmentUuid,
  double? vat,
  double? originalCost,
  double? balance,
  String? invoiceUuid,
  List<TempProductSaleRecord>? items,
}) {
  return TempMainReceipt(
    uuid: uuid,
    barcode: null,
    createdAt: createdAt ?? DateTime(2026, 10, 17, 12),
    shopId: 1,
    staffId: staffId,
    staffName: 'Ada',
    customerUuid: null,
    customerName: null,
    paymentMethod: 'Cash',
    bank: bank,
    cashAlt: cash,
    customerAccount: account,
    departmentName: null,
    departmentUuidNew: departmentUuid,
    isInvoice: invoiceUuid != null,
    invoiceUuid: invoiceUuid,
    generalDiscount: null,
    fixedDiscount: null,
    vat: vat,
    originalCost: originalCost,
    balance: balance,
    subStaffUuid: null,
    subStaffName: null,
    cartName: null,
    comment: null,
    salesTypeIndex: salesTypeIndex,
    items: items,
  );
}

TempProductSaleRecord saleLine({
  double quantity = 1,
  double revenue = 0,
  double? costPrice,
  bool isVoid = false,
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
    receiptUuid: null,
    isProductManaged: true,
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
    isPercentageWastage: false,
    wastageAmount: null,
  );
}

/// [noDate] leaves `createdDate` null, as a malformed server row.
TempExpensesClass expense({
  String uuid = 'e-1',
  double amount = 10,
  DateTime? createdDate,
  bool noDate = false,
  String? userId = 'staff-a',
  String? departmentUuid,
}) {
  return TempExpensesClass(
    uuid: uuid,
    name: 'Expense $uuid',
    amount: amount,
    creator: 'Ada',
    shopId: 1,
    userId: userId,
    departmentName: null,
    departmentUuid: departmentUuid,
    createdDate:
        noDate
            ? null
            : createdDate ?? DateTime(2026, 10, 17, 12),
  );
}

List<ReceiptsReportRow> receiptRowsOf(
  List<TempMainReceipt> receipts,
) => ReceiptsReportRowBuilder.buildAll(
  receipts: receipts,
  legacySales: const [],
);

List<PurchaseReportRow> purchaseRowsOf(
  List<TempPurchase> purchases,
) => PurchaseReportRowBuilder.buildAll(purchases: purchases);

/// One shop day (17 Oct 2026) and the day before. Every kind of
/// receipt the totals must handle: a plain sale, a void line, a
/// missing cost, VAT, no item data, an invoice payment (lines
/// already scaled to the payment), an order delivery and a bank +
/// customer account split.
List<TempMainReceipt> sampleReceipts() => [
  saleReceipt(
    uuid: 'r-0000000000001',
    cash: 100,
    items: [
      saleLine(revenue: 100, costPrice: 60),
      saleLine(revenue: 40, costPrice: 10, isVoid: true),
    ],
  ),
  saleReceipt(
    uuid: 'r-0000000000002',
    bank: 50,
    items: [saleLine(revenue: 50)],
  ),
  saleReceipt(
    uuid: 'r-0000000000003',
    cash: 115,
    vat: 15,
    originalCost: 100,
    items: [saleLine(revenue: 115, costPrice: 70)],
  ),
  saleReceipt(uuid: 'r-0000000000004', cash: 30),
  saleReceipt(
    uuid: 'r-0000000000005',
    salesTypeIndex: 2,
    invoiceUuid: 'inv-1',
    cash: 300,
    originalCost: 1000,
    balance: 700,
    items: [
      saleLine(quantity: 10, revenue: 300, costPrice: 180),
    ],
  ),
  saleReceipt(
    uuid: 'r-0000000000006',
    salesTypeIndex: 3,
    cash: 80,
    items: [saleLine(revenue: 80, costPrice: 50)],
  ),
  saleReceipt(
    uuid: 'r-0000000000007',
    bank: 20,
    account: 25,
    items: [saleLine(revenue: 45, costPrice: 30)],
  ),
  saleReceipt(
    uuid: 'r-0000000000008',
    cash: 999,
    createdAt: DateTime(2026, 10, 16, 12),
    items: [saleLine(revenue: 999, costPrice: 1)],
  ),
];
