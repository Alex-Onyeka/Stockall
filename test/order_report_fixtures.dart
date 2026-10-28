import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/classes/temp_orders/order_items.dart';
import 'package:stockall/classes/temp_orders/orders.dart';
import 'package:stockall/classes/temp_product_class/units_class/product_units_class.dart';
import 'package:stockall/classes/temp_product_slaes_record/temp_product_sale_record.dart';
import 'package:stockall/pages/report/order_report/order_report_table/class/order_report_table_logic.dart';
import 'package:stockall/pages/report/order_report/order_report_table/components/order_report_table_view.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

// Shared by the Order Report table and summary tests. Every line
// has a unitsList, so no unit lookup reaches the user provider.

/// The report screens without providers: data and permissions
/// come from here, as `OrderReportTableEnv.live` reads them in the
/// app. [orders] is read on every rebuild, so a test can change it.
OrderReportTableEnv fakeEnv({
  required List<Orders> orders,
  List<TempMainReceipt> receipts = const [],
  bool canSeeCost = true,
  List<Orders>? opened,
  Future<void> Function(
    BuildContext context,
    OrderReportFilters filters,
    ReceiptsReportPeriod period,
  )?
  openTable,
}) {
  return OrderReportTableEnv(
    departmentsEnabled: () => false,
    subStaffEnabled: () => false,
    canSeeCost: () => canSeeCost,
    canPickDate: () => true,
    orders: () => orders,
    receipts: () => receipts,
    productSales: () => const [],
    load: (context, {required refreshFromStore}) async {},
    signature: () => 'fixed',
    listen: (_) {},
    money: (_, v) => 'N$v',
    openOrder: (context, order) async => opened?.add(order),
    openTable: openTable,
  );
}

ProductUnitsClass testUnit(
  String uuid, {
  double conversion = 1,
  bool isPrimary = true,
  int? dimensionType,
}) {
  return ProductUnitsClass(
    uuid: uuid,
    staffUuid: null,
    createdAt: DateTime.utc(2026),
    staffName: null,
    conversion: conversion,
    name: uuid,
    isPrimary: isPrimary,
    productUuid: 'product',
    dimensionType: dimensionType,
  );
}

final ProductUnitsClass eachUnit = testUnit('each');
final ProductUnitsClass caseUnit = testUnit(
  'case',
  conversion: 12,
  isPrimary: false,
);

OrderItems orderLine({
  String uuid = 'line-1',
  String product = 'product-a',
  double quantity = 10,
  double? remaining,
  String unitUuid = 'each',
  List<ProductUnitsClass>? units,
  double revenue = 5,
  double? costPrice = 2,
  int? quantityType,
  double? width,
  double? height,
}) {
  return OrderItems(
    uuid: uuid,
    orderId: 'order',
    productName: 'Name $product',
    productUuid: product,
    createdAt: DateTime(2026, 10, 17, 12),
    staffName: 'Staff',
    staffId: 'staff-1',
    costPrice: costPrice,
    customerName: null,
    customerUuid: null,
    departmentName: null,
    departmentUuid: null,
    qttyPerGroup: null,
    quantity: quantity,
    revenue: revenue,
    unit: 'Each',
    useGroupQuantity: false,
    useWholeSalePrice: false,
    groupUnit: null,
    addToStock: false,
    customPriceSet: false,
    discount: null,
    discountedAmount: null,
    fixedDiscount: null,
    isProductManaged: true,
    originalCost: null,
    setTotalPrice: false,
    remainingQuantity: remaining ?? quantity,
    originalUseGroupQuantity: false,
    tempUseGroupQuantity: false,
    unitsList: units ?? [eachUnit, caseUnit],
    unitUuid: unitUuid,
    pricesList: null,
    priceUuid: null,
    widthDimension: width,
    heightDimension: height,
    quantityType: quantityType,
    manageSalesWastage: null,
    isPercentageWastage: null,
    wastageAmount: null,
  );
}

Orders testOrder({
  String uuid = 'order-1',
  String? barcode,
  List<OrderItems>? lines,
  double? total,
  DateTime? createdAt,
  int shopId = 1,
  String? staffId = 'staff-1',
  String? staffName = 'Ada',
  String? customerId = 'cust-1',
  String? customerName = 'Bola',
  String? departmentUuid,
  String? departmentName,
  String? subStaffUuid,
  String? subStaffName,
  double? vat,
  double? originalCost,
  double? generalDiscount,
  double? fixedDiscount,
}) {
  final items = lines ?? [orderLine()];
  return Orders(
    uuid: uuid,
    createdAt: createdAt ?? DateTime(2026, 10, 17, 12),
    shopId: shopId,
    staffId: staffId,
    staffName: staffName,
    customerId: customerId,
    customerName: customerName,
    departmentUuid: departmentUuid,
    departmentName: departmentName,
    total:
        total ??
        items.fold<double>(0, (s, l) => s + l.getTotalRevenue()),
    orderItems: items,
    updatedAt: null,
    barcode: barcode,
    vat: vat,
    comment: null,
    originalCost: originalCost,
    balance: null,
    cartName: null,
    fixedDiscount: fixedDiscount,
    generalDiscount: generalDiscount,
    subStaffName: subStaffName,
    subStaffUuid: subStaffUuid,
  );
}

TempProductSaleRecord deliveredLine({
  String product = 'product-a',
  double quantity = 1,
  String unitUuid = 'each',
  bool isVoid = false,
  String? receiptUuid,
  int? quantityType,
  double? width,
  double? height,
}) {
  return TempProductSaleRecord(
    createdAt: DateTime(2026, 10, 17, 13),
    productId: 1,
    productName: 'Name $product',
    productUuid: product,
    shopId: 1,
    staffId: 'staff-1',
    staffName: 'Staff',
    recepitId: 0,
    receiptUuid: receiptUuid,
    quantity: quantity,
    revenue: 0,
    discountedAmount: null,
    originalCost: null,
    discount: null,
    customPriceSet: false,
    departmentName: null,
    departmentUuid: null,
    isProductManaged: true,
    useGroupQuantity: false,
    qttyPerGroup: null,
    isVoid: isVoid,
    unitsList: [eachUnit, caseUnit],
    unitUuid: unitUuid,
    pricesList: null,
    priceUuid: null,
    widthDimension: width,
    heightDimension: height,
    quantityType: quantityType,
    manageSalesWastage: null,
    isPercentageWastage: null,
    wastageAmount: null,
  );
}

TempMainReceipt deliveryReceipt({
  String uuid = 'rec-1',
  String orderUuid = 'order-1',
  double cash = 0,
  double bank = 0,
  double account = 0,
  List<TempProductSaleRecord>? items,
  int? salesTypeIndex = 3,
}) {
  return TempMainReceipt(
    uuid: uuid,
    createdAt: DateTime(2026, 10, 17, 13),
    shopId: 1,
    staffId: 'staff-1',
    staffName: 'Ada',
    paymentMethod: 'Cash',
    bank: bank,
    cashAlt: cash,
    customerAccount: account,
    departmentName: null,
    departmentUuidNew: null,
    isInvoice: true,
    orderUuid: orderUuid,
    cartName: null,
    subStaffName: null,
    comment: null,
    salesTypeIndex: salesTypeIndex,
    items: items,
  );
}
