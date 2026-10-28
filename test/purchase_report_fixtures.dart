import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_item_purchase_record/temp_item_purchase_record.dart';
import 'package:stockall/classes/temp_product_class/units_class/product_units_class.dart';
import 'package:stockall/classes/temp_purchase/purchase_payments.dart';
import 'package:stockall/classes/temp_purchase/temp_purchase.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/class/purchase_report_table_logic.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/components/purchase_report_table_view.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

// Shared by the Purchase Report table and summary tests. Every line
// has a unitsList, so no unit lookup reaches the user provider.

const midnight = TimeOfDay(hour: 0, minute: 0);

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

final ProductUnitsClass pieceUnit = testUnit('piece');
final ProductUnitsClass caseUnit = testUnit(
  'case',
  conversion: 12,
  isPrimary: false,
);

TempItemPurchaseRecord line({
  String uuid = 'line-1',
  String? purchaseId = 'p-000000000001',
  String? itemId = 'product-a',
  String? storageItemId,
  double? quantity = 1,
  double? total = 100,
  String? unitUuid = 'piece',
  List<ProductUnitsClass>? units,
}) {
  return TempItemPurchaseRecord(
    uuid: uuid,
    createdAt: DateTime(2026, 10, 17, 12),
    shopId: 1,
    staffId: 'staff-a',
    itemId: itemId,
    storageItemId: storageItemId,
    purchaseId: purchaseId,
    itemName: 'Item',
    quantity: quantity,
    total: total,
    originalPrice: total,
    customPrice: null,
    isGroup: false,
    qttyPerGroup: null,
    unit: unitUuid,
    unitsList: units ?? [pieceUnit, caseUnit],
    unitUuid: unitUuid,
  );
}

PurchasePayments payment(
  double amount, {
  String method = 'Cash',
  String uuid = 'pay-1',
}) {
  return PurchasePayments(
    uuid: uuid,
    purchaseId: 'p-000000000001',
    createdAt: DateTime(2026, 10, 17, 12),
    amount: amount,
    userId: 'staff-a',
    paymentMethod: method,
    staffName: 'Ada',
  );
}

TempPurchase purchase({
  String? uuid = 'p-000000000001',
  DateTime? createdAt,
  double? total = 100,
  List<PurchasePayments>? payments,
  String? staffId = 'staff-a',
  String? staffName = 'Ada',
  String? supplierId = 'sup-a',
  String? supplierName = 'Acme',
  String? departmentUuid,
  String? departmentName,
  bool isCustomPriceSet = false,
  List<TempItemPurchaseRecord>? items,
  bool noItems = false,
}) {
  return TempPurchase(
    uuid: uuid,
    createdAt: createdAt ?? DateTime(2026, 10, 17, 12),
    shopId: 1,
    staffId: staffId,
    staffName: staffName,
    supplierId: supplierId,
    supplierName: supplierName,
    departmentUuid: departmentUuid,
    departmentName: departmentName,
    total: total,
    isCustomPriceSet: isCustomPriceSet,
    purchasePayments: payments ?? [],
    updatedAt: null,
    items:
        noItems
            ? null
            : items ?? [line(total: total, purchaseId: uuid)],
  );
}

PurchaseReportRow row(
  TempPurchase p, {
  Map<String, String> supplierNames = const {},
}) {
  return PurchaseReportRowBuilder.build(
    purchase: p,
    legacyLines: const {},
    supplierNames: supplierNames,
  );
}

List<PurchaseReportRow> rows(List<TempPurchase> purchases) =>
    PurchaseReportRowBuilder.buildAll(purchases: purchases);

/// Uuid with 12 digits, so the display id is stable.
String uuidN(int n) =>
    'p-${n.toString().padLeft(12, '0')}';

/// The report screens without providers: data and permissions
/// come from here, as `PurchaseReportEnv.live` reads them in the
/// app. [purchases] is read on every rebuild, so a test (or
/// [onOpen]) can change it.
PurchaseReportEnv fakeEnv({
  required List<TempPurchase> purchases,
  bool departmentsEnabled = false,
  List<TempPurchase>? opened,
  void Function(TempPurchase purchase)? onOpen,
  Future<void> Function(
    BuildContext context,
    PurchaseReportFilters filters,
    ReceiptsReportPeriod period,
  )?
  openTable,
}) {
  return PurchaseReportEnv(
    departmentsEnabled: () => departmentsEnabled,
    canPickDate: () => true,
    purchases: () => purchases,
    legacyLines: () => const [],
    supplierNames: () => const {},
    pendingDeletedUuids: () => const {},
    load: (context, {required refreshFromStore}) async {},
    signature: () => 'fixed',
    listen: (_) {},
    money: (_, v) => 'N$v',
    openPurchase: (context, purchase) async {
      opened?.add(purchase);
      onOpen?.call(purchase);
    },
    openTable: openTable,
  );
}
