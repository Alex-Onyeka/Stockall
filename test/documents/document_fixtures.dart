import 'dart:io';
import 'dart:typed_data';

import 'package:stockall/classes/payment_entry/payment_entry.dart';
import 'package:stockall/classes/temp_invoices/temp_invoices.dart';
import 'package:stockall/classes/temp_item_purchase_record/temp_item_purchase_record.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/classes/temp_orders/order_items.dart';
import 'package:stockall/classes/temp_orders/orders.dart';
import 'package:stockall/classes/temp_product_class/units_class/product_units_class.dart';
import 'package:stockall/classes/temp_product_slaes_record/temp_product_sale_record.dart';
import 'package:stockall/classes/temp_purchase/purchase_payments.dart';
import 'package:stockall/classes/temp_purchase/temp_purchase.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/services/documents/document_model.dart';
import 'package:stockall/services/documents/pdf_document_kit.dart';

// Records as the app saves them, built in memory. Every line has its
// units list, so the unit helpers never need the signed-in user.

final DateTime soldAt = DateTime(2026, 10, 10, 14, 30);

final DocFormat naira = DocFormat(currency: '₦');

// uuids with 12+ digits, so the ticket number is an EAN-13.
const String receiptUuid = '11112222-3333-4444-5555-666677778888';
const String invoiceUuid = '21112222-3333-4444-5555-666677778888';
const String orderUuid = '31112222-3333-4444-5555-666677778888';
const String purchaseUuid = '41112222-3333-4444-5555-666677778888';

ProductUnitsClass unit(
  String uuid,
  String name, {
  double conversion = 1,
  bool primary = false,
  int? dimensionType,
  String productUuid = 'product-1',
}) => ProductUnitsClass(
  uuid: uuid,
  staffUuid: null,
  createdAt: DateTime.utc(2026),
  staffName: null,
  conversion: conversion,
  name: name,
  isPrimary: primary,
  productUuid: productUuid,
  dimensionType: dimensionType,
);

// Soda: sold by the Each or by the Crate of 12.
final ProductUnitsClass each = unit('u-each', 'Each', primary: true);
final ProductUnitsClass crate = unit('u-crate', 'Crate', conversion: 12);

// Glass: stocked in M², sold in sheets cut to size or by the M².
final ProductUnitsClass squareMetre = unit(
  'u-m2',
  'M²',
  primary: true,
  dimensionType: ProductUnitsClass.areaUnit,
  productUuid: 'glass',
);
final ProductUnitsClass sheet = unit(
  'u-sheet',
  'Sheet',
  dimensionType: ProductUnitsClass.sheetUnit,
  productUuid: 'glass',
);

TempProductSaleRecord saleLine({
  required String name,
  required double quantity,
  required double originalCost,
  List<ProductUnitsClass>? units,
  String? unitUuid,
  double? discount,
  double? discountedAmount,
  double? fixedDiscount,
  int quantityType = 1,
  double? width,
  double? height,
  String? dimensionUnit,
  bool? manageSalesWastage,
  bool? isPercentageWastage,
  double? wastageAmount,
  String? unitName,
  bool customPriceSet = false,
  bool? setTotalPrice,
}) => TempProductSaleRecord(
  createdAt: soldAt,
  productId: 1,
  productName: name,
  shopId: 7,
  staffId: 'staff-1',
  staffName: 'Ada',
  recepitId: 1,
  quantity: quantity,
  revenue: originalCost - (discountedAmount ?? 0),
  discountedAmount: discountedAmount,
  originalCost: originalCost,
  discount: discount,
  fixedDiscount: fixedDiscount,
  customPriceSet: customPriceSet,
  setTotalPrice: setTotalPrice,
  departmentName: null,
  departmentUuid: null,
  isProductManaged: true,
  useGroupQuantity: false,
  qttyPerGroup: null,
  isVoid: false,
  unitsList: units,
  unitUuid: unitUuid,
  pricesList: null,
  priceUuid: null,
  widthDimension: width,
  heightDimension: height,
  dimensionUnit: dimensionUnit,
  dimensionUnitConversion: dimensionUnit == null ? null : 1,
  quantityType: quantityType,
  manageSalesWastage: manageSalesWastage,
  isPercentageWastage: isPercentageWastage,
  wastageAmount: wastageAmount,
  unit: unitName,
  uuid: 'line-$name',
  productUuid: 'product-$name',
);

// 2 Crates of soda at ₦6,000 a crate.
TempProductSaleRecord sodaCrates({
  double? discount,
  double? discountedAmount,
  double? fixedDiscount,
}) => saleLine(
  name: 'Soda',
  quantity: 2,
  originalCost: 12000,
  units: [each, crate],
  unitUuid: 'u-crate',
  discount: discount,
  discountedAmount: discountedAmount,
  fixedDiscount: fixedDiscount,
);

// 2 sheets cut at 2m x 1.5m (6 M²) with 10% wastage (0.6 M²), at
// ₦1,000 per M²: 6.6 M², ₦6,600.
TempProductSaleRecord glassSheets() => saleLine(
  name: 'Glass',
  quantity: 2,
  originalCost: 6600,
  units: [squareMetre, sheet],
  unitUuid: 'u-sheet',
  quantityType: 2,
  width: 2,
  height: 1.5,
  dimensionUnit: 'Meter(s)',
  manageSalesWastage: true,
  isPercentageWastage: true,
  wastageAmount: 10,
);

// 4 M² of glass sold by the area, no wastage: ₦4,000.
TempProductSaleRecord glassByArea() => saleLine(
  name: 'Glass offcut',
  quantity: 4,
  originalCost: 4000,
  units: [squareMetre, sheet],
  unitUuid: 'u-m2',
  quantityType: 2,
);

TempMainReceipt receiptOf({
  double cash = 0,
  double bank = 0,
  double account = 0,
  double? originalCost,
  double? vat,
  double? generalDiscount,
  double? fixedDiscount,
  String? customerName,
  String? subStaffName,
  String? cartName,
  String? departmentName,
  String? comment,
  String? barcode,
  String? uuid = receiptUuid,
  String? invoiceUuid,
  String? orderUuid,
  DateTime? createdAt,
  String staffName = 'Ada',
  double? balance,
  int salesTypeIndex = 1,
}) => TempMainReceipt(
  createdAt: createdAt ?? soldAt,
  shopId: 7,
  staffId: 'staff-1',
  staffName: staffName,
  paymentMethod: PaymentBreakdown.fromAmounts(
    cash: cash,
    bank: bank,
    account: account,
  ).label,
  bank: bank,
  cashAlt: cash,
  customerAccount: account,
  departmentName: departmentName,
  isInvoice: false,
  departmentUuidNew: null,
  cartName: cartName,
  subStaffName: subStaffName,
  comment: comment,
  salesTypeIndex: salesTypeIndex,
  customerName: customerName,
  customerUuid: customerName == null ? null : 'customer-1',
  originalCost: originalCost,
  vat: vat,
  generalDiscount: generalDiscount,
  fixedDiscount: fixedDiscount,
  barcode: barcode,
  uuid: uuid,
  invoiceUuid: invoiceUuid,
  orderUuid: orderUuid,
  balance: balance,
);

TempInvoice invoiceOf({
  required double total,
  required double originalCost,
  double? vat,
  double? generalDiscount,
  double? fixedDiscount,
  String? customerName = 'Bola Stores',
}) => TempInvoice(
  createdAt: soldAt,
  shopId: 7,
  staffId: 'staff-1',
  staffName: 'Ada',
  paymentMethod: 'Cash',
  bank: 0,
  cashAlt: total,
  departmentName: 'Front shop',
  departmentUuidNew: null,
  cartName: null,
  subStaffName: null,
  comment: 'Deliver to the back gate',
  customerName: customerName,
  customerUuid: 'customer-1',
  originalCost: originalCost,
  vat: vat,
  generalDiscount: generalDiscount,
  fixedDiscount: fixedDiscount,
  uuid: invoiceUuid,
);

OrderItems orderLine({
  required String name,
  required double quantity,
  required double? remaining,
  required double originalCostPerBase,
  required List<ProductUnitsClass> units,
  required String unitUuid,
  double? discountedAmount,
  int quantityType = 1,
  double? width,
  double? height,
  bool? manageSalesWastage,
  bool? isPercentageWastage,
  double? wastageAmount,
}) => OrderItems(
  uuid: 'order-line-$name',
  orderId: orderUuid,
  productName: name,
  productUuid: 'product-$name',
  createdAt: soldAt,
  staffName: 'Ada',
  staffId: 'staff-1',
  costPrice: null,
  customerName: 'Bola Stores',
  customerUuid: 'customer-1',
  departmentName: null,
  departmentUuid: null,
  qttyPerGroup: null,
  quantity: quantity,
  revenue: originalCostPerBase,
  unit: null,
  useGroupQuantity: false,
  useWholeSalePrice: false,
  groupUnit: null,
  addToStock: false,
  customPriceSet: false,
  discount: null,
  discountedAmount: discountedAmount,
  fixedDiscount: null,
  isProductManaged: true,
  originalCost: originalCostPerBase,
  setTotalPrice: false,
  remainingQuantity: remaining,
  originalUseGroupQuantity: false,
  tempUseGroupQuantity: false,
  unitsList: units,
  unitUuid: unitUuid,
  pricesList: null,
  priceUuid: null,
  widthDimension: width,
  heightDimension: height,
  dimensionUnit: width == null ? null : 'Meter(s)',
  dimensionUnitConversion: width == null ? null : 1,
  quantityType: quantityType,
  manageSalesWastage: manageSalesWastage,
  isPercentageWastage: isPercentageWastage,
  wastageAmount: wastageAmount,
);

Orders orderOf({
  required List<OrderItems> items,
  required double total,
  required double originalCost,
  double? vat,
  double? generalDiscount,
  double? fixedDiscount,
}) => Orders(
  createdAt: soldAt,
  shopId: 7,
  staffName: 'Ada',
  customerName: 'Bola Stores',
  orderItems: items,
  updatedAt: soldAt,
  barcode: null,
  vat: vat,
  comment: null,
  originalCost: originalCost,
  balance: total,
  cartName: 'Table 4',
  fixedDiscount: fixedDiscount,
  generalDiscount: generalDiscount,
  subStaffName: null,
  subStaffUuid: null,
  uuid: orderUuid,
  total: total,
  departmentName: 'Kitchen',
);

TempItemPurchaseRecord purchaseLine({
  required String name,
  required double quantity,
  required double total,
  List<ProductUnitsClass>? units,
  String? unitUuid,
  String? unitName,
  double? width,
  double? height,
}) => TempItemPurchaseRecord(
  createdAt: soldAt,
  shopId: 7,
  staffId: 'staff-1',
  quantity: quantity,
  total: total,
  itemName: name,
  itemId: 'product-$name',
  purchaseId: purchaseUuid,
  originalPrice: null,
  customPrice: null,
  storageItemId: null,
  isGroup: false,
  qttyPerGroup: null,
  unit: unitName,
  unitsList: units,
  unitUuid: unitUuid,
  widthDimension: width,
  heightDimension: height,
);

PurchasePayments purchasePayment(
  double amount,
  String method,
  DateTime at,
) => PurchasePayments(
  uuid: 'pay-$amount',
  purchaseId: purchaseUuid,
  createdAt: at,
  amount: amount,
  userId: 'staff-1',
  paymentMethod: method,
  staffName: 'Chidi',
);

TempPurchase purchaseOf({
  required double total,
  required List<PurchasePayments> payments,
  String? supplierName = 'Delta Wholesale',
}) => TempPurchase(
  createdAt: soldAt,
  shopId: 7,
  staffName: 'Chidi',
  supplierName: supplierName,
  isCustomPriceSet: false,
  purchasePayments: payments,
  updatedAt: soldAt,
  uuid: purchaseUuid,
  total: total,
  departmentName: 'Store room',
);

TempShopClass shopOf({
  String name = 'Mama Put Supermarket',
  String currency = '₦',
  String? email = 'hello@mamaput.ng',
  String? phone = '0803 123 4567',
  String? address = '12 Allen Avenue, Ikeja, Lagos',
  bool showPhone = true,
  bool showAddress = true,
  String? bottomText,
}) => TempShopClass(
  createdAt: DateTime.utc(2026),
  userId: 'owner-1',
  name: name,
  currency: currency,
  isVerified: true,
  manageInventoryStorage: false,
  wholeSale: false,
  manageDepartments: false,
  printSalesDocket: false,
  closeSaleTimeString: null,
  trackCart: false,
  accessPin: null,
  manageProductions: false,
  manageProductionsStorage: false,
  manageProductionItems: false,
  customerPercentageReward: null,
  manageCustomerReward: false,
  manageCustomerAccount: false,
  email: email,
  phoneNumber: phone,
  shopAddress: address,
  showPhone: showPhone,
  showAddress: showAddress,
  bottomText: bottomText,
);

// The bundled app fonts, read from disk as the app reads them from
// its assets.
DocFonts appFonts() => DocFonts.fromBytes(
  _bytes('assets/fonts/PlusJakartaSans-Regular.ttf'),
  _bytes('assets/fonts/PlusJakartaSans-Bold.ttf'),
);

ByteData _bytes(String path) =>
    ByteData.sublistView(File(path).readAsBytesSync());
