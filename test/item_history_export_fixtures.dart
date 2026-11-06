// Fixtures for the Item History / History Summary / Stock Movements /
// Analysis export tests. Same shapes as `makeRecord` in
// item_history_report_test.dart and `cocaCola` / `history` in
// item_history_summary_test.dart (those helpers live inside their test
// files, so they can't be imported).

import 'package:stockall/classes/temp_item_history/item_history.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_product_class/units_class/product_units_class.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';

const categoryNames = {'c-drinks': 'Drinks', 'c-bakery': 'Bakery'};
const departmentNames = {'d-front': 'Front Shop', 'd-back': 'Back Store'};

final testCtx = ExportContext(
  shopName: 'Mama Put Stores',
  currencySymbol: '₦',
  generatedBy: 'Ada Obi',
  generatedAt: DateTime(2026, 11, 4, 14, 5),
);

ItemHistory makeRecord({
  String? uuid,
  DateTime? createdAt,
  int shopId = 1,
  String title = 'Test History',
  String? itemName,
  String? itemUuid,
  String? newValue,
  String? oldValue,
  String? staffId,
  String? staffName,
  String? departmentName,
  String? departmentUuid,
  double? quantityChange,
  String? desc,
  bool? isIncreased,
  String? unit,
  String? primaryUnit,
  String? event,
  bool? isManaged,
  String? source,
  String? destination,
  String? supplierName,
  String? trackingNumber,
}) {
  return ItemHistory(
    uuid: uuid ?? 'test-uuid-1',
    createdAt: createdAt ?? DateTime(2026, 10, 15, 10, 30),
    shopId: shopId,
    title: title,
    itemName: itemName,
    itemUuid: itemUuid,
    newValue: newValue,
    oldValue: oldValue,
    staffId: staffId,
    staffName: staffName,
    departmentName: departmentName,
    departmentUuid: departmentUuid,
    quantityChange: quantityChange,
    desc: desc,
    isIncreased: isIncreased,
    unit: unit,
    primaryUnit: primaryUnit,
    event: event,
    isManaged: isManaged,
    source: source,
    destination: destination,
    supplierName: supplierName,
    trackingNumber: trackingNumber,
  );
}

/// A product like `cocaCola()` in item_history_summary_test.dart, with
/// optional categories, department and 2D sheet size.
TempProductClass makeProduct({
  required String uuid,
  required String name,
  String unit = 'Bottle(s)',
  double? quantity = 5,
  double sellingPrice = 100,
  double costPrice = 60,
  List<String> categories = const [],
  String? departmentUuid,
  bool twoD = false,
  double? width,
  double? height,
  String? dimensionUnit,
  DateTime? createdAt,
}) {
  return TempProductClass(
    uuid: uuid,
    name: name,
    unit: unit,
    isRefundable: false,
    costPrice: costPrice,
    sellingPrice: sellingPrice,
    shopId: 1,
    setCustomPrice: false,
    departmentName: departmentNames[departmentUuid],
    departmentUuid: departmentUuid,
    isManaged: quantity != null,
    groupUnit: null,
    qttyPerGroup: null,
    wholeSalePrice: null,
    storageUuid: null,
    categories: categories,
    useGroupUnit: false,
    quantityType: twoD ? 2 : 1,
    unitsList: [
      ProductUnitsClass(
        uuid: 'unit-$uuid',
        staffUuid: null,
        createdAt: DateTime.utc(2026),
        staffName: null,
        conversion: 1,
        name: unit,
        isPrimary: true,
        productUuid: uuid,
        dimensionType: twoD ? ProductUnitsClass.sheetUnit : null,
      ),
    ],
    pricesList: null,
    widthDimension: width,
    heightDimension: height,
    dimensionUnit: dimensionUnit,
    manageSalesWastage: null,
    quantity: quantity,
    createdAt: createdAt ?? DateTime(2026, 9, 1),
  );
}

/// A sheet item, 4 x 2, counted in Sheets.
TempProductClass sheetProduct({double quantity = 3}) => makeProduct(
  uuid: 'sheet',
  name: 'Acrylic Sheet',
  unit: 'Sheets',
  quantity: quantity,
  categories: const ['c-bakery'],
  departmentUuid: 'd-back',
  twoD: true,
  width: 4,
  height: 2,
);

// ---------------------------------------------------------------------
// History Summary / Stock Movements sample (same shape as `history` in
// item_history_summary_test.dart)
// ---------------------------------------------------------------------

ItemHistory movement({
  required String uuid,
  required String itemUuid,
  required String itemName,
  required String event,
  required String oldValue,
  required String newValue,
  required double quantityChange,
  required bool? isIncreased,
  String unit = 'Bottle(s)',
  DateTime? createdAt,
}) {
  return ItemHistory(
    uuid: uuid,
    createdAt: createdAt ?? DateTime(2026, 9, 29, 12),
    shopId: 1,
    title: 'History $uuid',
    itemName: itemName,
    itemUuid: itemUuid,
    oldValue: oldValue,
    newValue: newValue,
    quantityChange: quantityChange,
    desc: null,
    isIncreased: isIncreased,
    unit: unit,
    primaryUnit: unit,
    event: event,
    isManaged: true,
    source: null,
  );
}

/// Coke (Drinks, Front Shop) sells 5; the sheet (Bakery, Back Store,
/// 4 x 2) is bought 3; Meat Pie (Drinks + Bakery) produces 2; Juice has
/// no category, department or movement.
final summaryProducts = [
  makeProduct(
    uuid: 'coke',
    name: 'Coke',
    quantity: 5,
    categories: const ['c-drinks'],
    departmentUuid: 'd-front',
  ),
  sheetProduct(),
  makeProduct(
    uuid: 'pie',
    name: 'Meat Pie',
    unit: 'Pcs',
    quantity: 7,
    categories: const ['c-drinks', 'c-bakery'],
  ),
  makeProduct(uuid: 'juice', name: 'Juice', quantity: 4),
];

final summaryHistories = [
  movement(
    uuid: 'sale',
    itemUuid: 'coke',
    itemName: 'Coke',
    event: 'sale',
    oldValue: '10.0',
    newValue: '5.0',
    quantityChange: -5,
    isIncreased: false,
  ),
  movement(
    uuid: 'buy',
    itemUuid: 'sheet',
    itemName: 'Acrylic Sheet',
    event: 'purchase',
    oldValue: '0',
    newValue: '3',
    quantityChange: 3,
    isIncreased: true,
    unit: 'Sheets',
  ),
  movement(
    uuid: 'bake',
    itemUuid: 'pie',
    itemName: 'Meat Pie',
    event: 'produced',
    oldValue: '5',
    newValue: '7',
    quantityChange: 2,
    isIncreased: true,
    unit: 'Pcs',
  ),
];

final summaryNow = DateTime(2026, 10, 22, 12);
