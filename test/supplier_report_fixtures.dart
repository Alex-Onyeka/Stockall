import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:stockall/classes/temp_item_purchase_record/temp_item_purchase_record.dart';
import 'package:stockall/classes/temp_purchase/temp_purchase.dart';
import 'package:stockall/classes/temp_suppliers/suppliers_class.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/class/purchase_report_table_logic.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/components/purchase_report_table_view.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/supplier_report/supplier_report_table/class/supplier_report_table_logic.dart';
import 'package:stockall/pages/report/supplier_report/supplier_report_table/components/supplier_report_table_view.dart';
import 'package:stockall/providers/theme_provider.dart';

import 'purchase_report_fixtures.dart';

export 'purchase_report_fixtures.dart';

// Shared by the Supplier Report tests, on top of the Purchase
// Report fixtures.

SuppliersClass supplier(
  String uuid, {
  String name = 'Supplier',
  String? phone,
  String? email,
  String? address,
  String? city,
  String? state,
  String? country,
  String? departmentId,
}) {
  return SuppliersClass(
    uuid: uuid,
    createdAt: DateTime(2026, 1, 1),
    shopId: 1,
    name: name,
    phone: phone,
    email: email,
    address: address,
    city: city,
    state: state,
    country: country,
    departmentId: departmentId,
    departmentName: departmentId,
  );
}

/// A purchase line with a name (the purchase fixture's `line`
/// always names it "Item").
TempItemPurchaseRecord namedLine({
  required String purchaseId,
  String? itemId = 'product-a',
  String? storageItemId,
  String? itemName = 'Item A',
  double? quantity = 1,
  double? total = 100,
  String? unitUuid = 'piece',
}) {
  final base = line(
    purchaseId: purchaseId,
    itemId: itemId,
    storageItemId: storageItemId,
    quantity: quantity,
    total: total,
    unitUuid: unitUuid,
  );
  base.itemName = itemName;
  return base;
}

/// Purchase of supplier [supplierId] on 2026-10-[day], noon.
TempPurchase bought(
  int n, {
  required String? supplierId,
  String? supplierName,
  int day = 17,
  double total = 100,
  double paid = 0,
  List<TempItemPurchaseRecord>? items,
  bool noItems = false,
  bool isCustomPriceSet = false,
}) {
  return purchase(
    uuid: uuidN(n),
    createdAt: DateTime(2026, 10, day, 12),
    supplierId: supplierId,
    supplierName: supplierName,
    total: total,
    payments: paid == 0 ? [] : [payment(paid, uuid: 'pay-$n')],
    items: items,
    noItems: noItems,
    isCustomPriceSet: isCustomPriceSet,
  );
}

/// Supplier rows over all time, departments off.
List<SupplierReportRow> supplierRows({
  required List<SuppliersClass> suppliers,
  List<SuppliersClass>? allSuppliers,
  required List<TempPurchase> purchases,
  ReceiptsReportPeriod period = const ReceiptsReportPeriod.allTime(),
}) {
  return SupplierReportRowBuilder.build(
    suppliers: suppliers,
    allSuppliers: allSuppliers ?? suppliers,
    purchaseRows: rows(purchases),
    period: period,
    departmentsEnabled: false,
    closingTime: midnight,
  );
}

SupplierReportRow rowOf(
  List<SupplierReportRow> rows,
  String key,
) => rows.singleWhere((r) => r.key == key);

/// Purchase table totals for [filters] in [period], as the
/// Purchase Report computes them.
PurchaseReportPage purchaseTable(
  List<TempPurchase> purchases, {
  PurchaseReportFilters? filters,
  ReceiptsReportPeriod period = const ReceiptsReportPeriod.allTime(),
}) {
  return PurchaseReportQuery.paginate(
    PurchaseReportQuery.filterAndSort(
      rows: rows(purchases),
      period: period,
      filters: filters ?? PurchaseReportFilters(),
      sortField: PurchasesSortField.createdAt,
      ascending: false,
      departmentsEnabled: false,
      closingTime: midnight,
    ),
    1,
  );
}

/// One `openAnalysis` call of a [fakeSupplierEnv].
typedef OpenedAnalysis = ({
  String key,
  SupplierReportRow row,
  ReceiptsReportPeriod period,
});

/// One `openTable` call of a [fakeSupplierEnv].
typedef OpenedTable = ({
  PurchaseReportFilters filters,
  ReceiptsReportPeriod period,
});

/// The supplier screens without providers. [purchases] and
/// [suppliers] are read on every rebuild, so a test (or a hook)
/// can change them; the signature reflects their sizes and
/// totals, so a change is picked up.
///
/// Without [opened] and [onOpenAnalysis] the table pushes the
/// real Supplier Analysis page, with this env.
SupplierReportEnv fakeSupplierEnv({
  required List<TempPurchase> purchases,
  required List<SuppliersClass> suppliers,
  bool departmentsEnabled = false,
  bool canPickDate = true,
  bool canViewAllDepartments = true,
  String? currentDepartmentUuid,
  List<OpenedAnalysis>? opened,
  void Function(SupplierReportRow row)? onOpenAnalysis,
  List<TempPurchase>? openedPurchases,
  void Function(TempPurchase purchase)? onOpenPurchase,
  List<OpenedTable>? openedTables,
}) {
  final purchaseEnv = PurchaseReportEnv(
    departmentsEnabled: () => departmentsEnabled,
    canPickDate: () => canPickDate,
    purchases: () => purchases,
    legacyLines: () => const [],
    supplierNames: () => const {},
    pendingDeletedUuids: () => const {},
    load: (context, {required refreshFromStore}) async {},
    signature: () => 'fixed',
    listen: (_) {},
    money: (_, v) => 'N$v',
    openPurchase: (context, purchase) async {
      openedPurchases?.add(purchase);
      onOpenPurchase?.call(purchase);
    },
    openTable:
        openedTables == null
            ? null
            : (context, filters, period) async {
              openedTables.add((filters: filters, period: period));
            },
  );
  return SupplierReportEnv(
    purchaseEnv: purchaseEnv,
    suppliers: () => suppliers,
    canViewAllDepartments: () => canViewAllDepartments,
    currentDepartmentUuid: () => currentDepartmentUuid,
    signature: () {
      final paid = purchases.fold<double>(
        0,
        (s, p) => s + PurchaseReportClassifier.paidAmount(
          p.purchasePayments,
        ),
      );
      return '${purchases.length}|$paid|${suppliers.length}';
    },
    openAnalysis:
        opened == null && onOpenAnalysis == null
            ? null
            : (context, row, period) async {
              opened?.add((key: row.key, row: row, period: period));
              onOpenAnalysis?.call(row);
            },
  );
}

/// Pumps [child] at desktop (1800 x 1000) or mobile (500 x 900)
/// size. Below mobileScreen (650) report toolbars sit behind
/// "View", which is opened unless [openToolbar] is false.
Future<void> pumpReport(
  WidgetTester tester, {
  required bool isDesktop,
  required Widget child,
  bool openToolbar = true,
}) async {
  tester.view.physicalSize =
      isDesktop ? const Size(1800, 1000) : const Size(500, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ChangeNotifierProvider<ThemeProvider>(
      create: (_) => ThemeProvider(),
      child: MaterialApp(home: child),
    ),
  );
  await tester.pumpAndSettle();
  if (!isDesktop && openToolbar) {
    await tester.tap(find.text('View'));
    await tester.pumpAndSettle();
  }
}
