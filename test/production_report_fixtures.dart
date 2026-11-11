// Builders for the Production Report tests, and Alex's example:
// two bags of flour, one used to produce 30 donuts, 15 donuts
// transferred to sales.

import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_item_history/item_history.dart';
import 'package:stockall/classes/temp_item_history/item_history_event_class.dart';
import 'package:stockall/classes/temp_product_class/units_class/product_units_class.dart';
import 'package:stockall/classes/temp_production_folder/temp_material_class/material_class.dart';
import 'package:stockall/classes/temp_production_folder/temp_materials_item_history/material_item_history_event_class.dart';
import 'package:stockall/classes/temp_production_folder/temp_materials_item_history/materials_item_history.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_item_history/production_item_history.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_item_history/production_item_history_event_class.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_items/production_item.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_materials_usage/production_materials_usage.dart';
import 'package:stockall/classes/temp_production_folder/temp_productions/production_record.dart';
import 'package:stockall/classes/temp_production_folder/temp_productions/production_record_materials.dart';
import 'package:stockall/pages/report/production_report/production_records_table/class/production_records_table_logic.dart';
import 'package:stockall/pages/report/production_report/production_records_table/components/production_records_table_view.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/production_stock_model.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/stock_history_logic.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/stock_items_logic.dart';
import 'package:stockall/pages/report/production_report/stock_shared/components/production_stock_env.dart';
import 'package:stockall/pages/report/production_report/usage_records_table/class/usage_records_table_logic.dart';
import 'package:stockall/pages/report/production_report/usage_records_table/components/usage_records_table_view.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

const int testShopId = 1;

const String staffAda = 'staff-ada';
const String staffBen = 'staff-ben';
const String deptBakery = 'dept-bakery';
const String deptKitchen = 'dept-kitchen';

/// Local time in October 2026.
DateTime oct(int day, [int hour = 9, int minute = 0]) =>
    DateTime(2026, 10, day, hour, minute);

ProductUnitsClass prodUnit(
  String uuid,
  String name, {
  double conversion = 1,
  bool isPrimary = true,
  String productUuid = 'item',
}) {
  return ProductUnitsClass(
    uuid: uuid,
    staffUuid: null,
    createdAt: DateTime.utc(2026),
    staffName: null,
    conversion: conversion,
    name: name,
    isPrimary: isPrimary,
    productUuid: productUuid,
  );
}

List<ProductUnitsClass> flourUnits() => [
  prodUnit('flour-bag', 'Bag', productUuid: 'flour'),
];

/// Pieces, with a 12-piece box.
List<ProductUnitsClass> donutUnits() => [
  prodUnit('donut-pcs', 'Pcs', productUuid: 'donut'),
  prodUnit(
    'donut-box',
    'Box',
    conversion: 12,
    isPrimary: false,
    productUuid: 'donut',
  ),
];

MaterialClass material({
  String uuid = 'flour',
  String name = 'Flour',
  double? quantity,
  double costPrice = 0,
  List<ProductUnitsClass>? units,
  String unit = 'Bag',
  String? departmentUuid,
  String? departmentName,
  double? lowQtty,
  bool isManaged = true,
  List<String> categories = const [],
  DateTime? createdAt,
  DateTime? expiryDate,
}) {
  return MaterialClass(
    uuid: uuid,
    name: name,
    quantity: quantity,
    unit: unit,
    costPrice: costPrice,
    shopId: testShopId,
    departmentName: departmentName,
    departmentUuid: departmentUuid,
    lowQtty: lowQtty,
    isManaged: isManaged,
    groupUnit: null,
    qttyPerGroup: null,
    categories: categories,
    useGroupUnit: false,
    unitsList: units,
    createdAt: createdAt,
    expiryDate: expiryDate,
  );
}

ProductionItem producedItem({
  String uuid = 'donut',
  String name = 'Donut',
  double? quantity,
  double costPrice = 0,
  List<ProductUnitsClass>? units,
  String unit = 'Pcs',
  String? departmentUuid,
  String? departmentName,
  bool isManaged = true,
  List<String> categories = const [],
  DateTime? createdAt,
  DateTime? expiryDate,
}) {
  return ProductionItem(
    uuid: uuid,
    name: name,
    quantity: quantity,
    unit: unit,
    costPrice: costPrice,
    shopId: testShopId,
    departmentName: departmentName,
    departmentUuid: departmentUuid,
    isManaged: isManaged,
    groupUnit: null,
    qttyPerGroup: null,
    categories: categories,
    useGroupUnit: false,
    unitsList: units,
    createdAt: createdAt,
    expiryDate: expiryDate,
  );
}

ProductionRecordMaterials materialLine({
  String uuid = 'line-1',
  String materialUuid = 'flour',
  String materialName = 'Flour',
  required double quantity,
  required String? unitUuid,
  required List<ProductUnitsClass>? units,
  double? totalCost,
  double? customCost,
  double? originalCostPerItem,
  String? productionRecordId,
  bool? isManaged = true,
  bool? isGroup = false,
  double? qttyPerGroup,
  String? groupUnit,
  String? unit = 'Bag',
}) {
  return ProductionRecordMaterials(
    uuid: uuid,
    productionRecordId: productionRecordId,
    quantity: quantity,
    materialName: materialName,
    materialUuid: materialUuid,
    isGroup: isGroup,
    qttyPerGroup: qttyPerGroup,
    totalCost: totalCost,
    createdAt: null,
    departmentName: null,
    departmentUuid: null,
    staffName: null,
    staffUuid: null,
    productionRecordName: null,
    unit: unit,
    customCost: customCost,
    customUnit: null,
    groupUnit: groupUnit,
    originalCostPerItem: originalCostPerItem,
    originalUseGroupQuantity: false,
    isManaged: isManaged,
    unitUuid: unitUuid,
    unitsList: units,
  );
}

ProductionRecord productionRecord({
  String uuid = 'prod-1',
  required DateTime createdAt,
  String? itemUuid = 'donut',
  String? salesItemUuid,
  String itemName = 'Donut',
  required double quantity,
  String? unitUuid = 'donut-pcs',
  List<ProductUnitsClass>? units,
  String? unit = 'Pcs',
  bool? useGroupQuantity = false,
  double? qttyPerGroup,
  String? groupUnit,
  List<ProductionRecordMaterials> materials = const [],
  double? totalCost,
  double? customCost,
  int? selectedCostPriceOption = 2,
  String? staffId = staffAda,
  String? staffName = 'Ada',
  String? departmentId = deptBakery,
  String? departmentName = 'Bakery',
  String? comment,
}) {
  return ProductionRecord(
    uuid: uuid,
    createdAt: createdAt,
    shopId: testShopId,
    staffId: staffId,
    staffName: staffName,
    departmentId: departmentId,
    departmentName: departmentName,
    materials: materials,
    itemName: itemName,
    itemUuid: itemUuid,
    salesItemUuid: salesItemUuid,
    quantity: quantity,
    unit: unit,
    qttyPerGroup: qttyPerGroup,
    totalCost: totalCost,
    customCost: customCost,
    comment: comment,
    selectedCostPriceOption: selectedCostPriceOption,
    originalCostPerItem: null,
    originalUseGroupQuantity: false,
    useGroupQuantity: useGroupQuantity,
    groupUnit: groupUnit,
    unitUuid: unitUuid,
    unitsList: units,
  );
}

ProductionMaterialsUsage usageRecord({
  String uuid = 'usage-1',
  required DateTime createdAt,
  String materialUuid = 'flour',
  String materialName = 'Flour',
  required double quantity,
  String? unitUuid = 'flour-bag',
  List<ProductUnitsClass>? units,
  double? totalCost,
  double? customCost,
  double? originalCostPerItem,
  String? productionRecordUuid,
  String? staffUuid = staffAda,
  String? staffName = 'Ada',
  String? departmentUuid = deptBakery,
  String? departmentName = 'Bakery',
  bool? isManaged = true,
}) {
  return ProductionMaterialsUsage(
    uuid: uuid,
    shopId: testShopId,
    quantity: quantity,
    materialName: materialName,
    materialUuid: materialUuid,
    isGroup: false,
    totalCost: totalCost,
    createdAt: createdAt,
    departmentName: departmentName,
    departmentUuid: departmentUuid,
    staffName: staffName,
    staffUuid: staffUuid,
    unit: 'Bag',
    customCost: customCost,
    updatedAt: null,
    customUnit: null,
    groupUnit: null,
    originalCostPerItem: originalCostPerItem,
    originalUseGroupQuantity: false,
    selectedCostInt: 1,
    isManaged: isManaged,
    unitUuid: unitUuid,
    unitsList: units,
    productionRecordUuid: productionRecordUuid,
  );
}

MaterialsItemHistory materialHistory({
  String uuid = 'mh',
  required String title,
  required String? event,
  DateTime? createdAt,
  String? itemUuid = 'flour',
  String? itemName = 'Flour',
  double? quantityChange,
  String? oldValue,
  String? newValue,
  bool? isIncreased,
  String? source,
  String? destination,
  String? unit = 'Bag',
  String? primaryUnit = 'Bag',
  String? staffId = staffAda,
  String? departmentUuid = deptBakery,
}) {
  return MaterialsItemHistory(
    uuid: uuid,
    createdAt: createdAt,
    shopId: testShopId,
    title: title,
    itemName: itemName,
    itemUuid: itemUuid,
    staffId: staffId,
    staffName: staffId == null ? null : 'Ada',
    departmentUuid: departmentUuid,
    departmentName: departmentUuid == null ? null : 'Bakery',
    newValue: newValue,
    oldValue: oldValue,
    quantityChange: quantityChange,
    desc: null,
    isIncreased: isIncreased,
    unit: unit,
    primaryUnit: primaryUnit,
    event: event,
    isManaged: true,
    source: source,
    destination: destination,
  );
}

ProductionItemHistory producedHistory({
  String uuid = 'ph',
  required String title,
  required String? event,
  DateTime? createdAt,
  String? itemUuid = 'donut',
  String? itemName = 'Donut',
  double? quantityChange,
  String? oldValue,
  String? newValue,
  bool? isIncreased,
  String? source,
  String? destination,
  String? unit = 'Pcs',
  String? primaryUnit = 'Pcs',
  String? staffId = staffAda,
  String? departmentUuid = deptBakery,
}) {
  return ProductionItemHistory(
    uuid: uuid,
    createdAt: createdAt,
    shopId: testShopId,
    title: title,
    itemName: itemName,
    itemUuid: itemUuid,
    staffId: staffId,
    staffName: staffId == null ? null : 'Ada',
    departmentUuid: departmentUuid,
    departmentName: departmentUuid == null ? null : 'Bakery',
    newValue: newValue,
    oldValue: oldValue,
    quantityChange: quantityChange,
    desc: null,
    isIncreased: isIncreased,
    unit: unit,
    primaryUnit: primaryUnit,
    event: event,
    isManaged: true,
    source: source,
    destination: destination,
  );
}

/// Alex's example, as the app saves it.
///
/// - Flour: 2 bags bought in (manual increase), ₦5,000 a bag.
/// - Production prod-1 uses 1 bag to make 30 donuts. The cost comes
///   from the materials (option 2), so it is ₦5,000. The production
///   writes a linked usage record and a "Material Used" history row.
/// - 15 donuts are transferred to the sales item "Donut (Sales)".
class AlexExample {
  static const double bagCost = 5000;

  final MaterialClass flour;
  final ProductionItem donut;
  final ProductionRecord record;
  final ProductionMaterialsUsage usage;
  final List<MaterialsItemHistory> flourHistory;
  final List<ProductionItemHistory> donutHistory;
  final List<ItemHistory> salesHistory;

  AlexExample._({
    required this.flour,
    required this.donut,
    required this.record,
    required this.usage,
    required this.flourHistory,
    required this.donutHistory,
    required this.salesHistory,
  });

  factory AlexExample() {
    final record = productionRecord(
      uuid: 'prod-1',
      createdAt: oct(2, 10),
      quantity: 30,
      unitUuid: 'donut-pcs',
      units: donutUnits(),
      totalCost: bagCost,
      selectedCostPriceOption: 2,
      materials: [
        materialLine(
          uuid: 'line-1',
          quantity: 1,
          unitUuid: 'flour-bag',
          units: flourUnits(),
          totalCost: bagCost,
          originalCostPerItem: bagCost,
          productionRecordId: 'prod-1',
        ),
      ],
    );
    return AlexExample._(
      flour: material(
        quantity: 1,
        costPrice: bagCost,
        units: flourUnits(),
        departmentUuid: deptBakery,
        departmentName: 'Bakery',
        createdAt: oct(1, 8),
      ),
      donut: producedItem(
        quantity: 15,
        costPrice: 200,
        units: donutUnits(),
        departmentUuid: deptBakery,
        departmentName: 'Bakery',
        createdAt: oct(1, 8),
      ),
      record: record,
      usage: usageRecord(
        uuid: 'usage-1',
        createdAt: oct(2, 10),
        quantity: 1,
        units: flourUnits(),
        totalCost: bagCost,
        originalCostPerItem: bagCost,
        productionRecordUuid: 'prod-1',
      ),
      flourHistory: [
        materialHistory(
          uuid: 'mh-1',
          title: 'Item Quantity Increased',
          event: MaterialItemHistoryEventClass.quantityUpdatedIncrease,
          createdAt: oct(1, 9),
          quantityChange: 2,
          oldValue: '0',
          newValue: '2',
          isIncreased: true,
          source: MaterialItemHistoryEventClass.unKnownSource,
        ),
        materialHistory(
          uuid: 'mh-2',
          title: 'Material Used',
          event: MaterialItemHistoryEventClass.usageCreated,
          createdAt: oct(2, 10),
          quantityChange: -1,
          oldValue: '2.0',
          newValue: '1.0',
          isIncreased: false,
          source: MaterialItemHistoryEventClass.materialSource,
          destination:
              MaterialItemHistoryEventClass.materialUsageDestination,
        ),
      ],
      donutHistory: [
        producedHistory(
          uuid: 'ph-1',
          title: 'Item Produced',
          event: ProductionItemHistoryEventClass.productionCreated,
          createdAt: oct(2, 10),
          quantityChange: 30,
          oldValue: '0.0',
          newValue: '30.0',
          isIncreased: true,
          source: ProductionItemHistoryEventClass.productionSource,
          destination:
              ProductionItemHistoryEventClass.productionItemDestination,
        ),
        producedHistory(
          uuid: 'ph-2',
          title: 'Transfered Out',
          event: ProductionItemHistoryEventClass.transferedOut,
          createdAt: oct(2, 14),
          quantityChange: -15,
          oldValue: '30',
          newValue: '15',
          isIncreased: false,
          source: ProductionItemHistoryEventClass.productionItemSource,
          destination: ProductionItemHistoryEventClass.productDestination,
        ),
      ],
      salesHistory: [
        ItemHistory(
          uuid: 'sh-1',
          createdAt: oct(2, 14),
          shopId: testShopId,
          title: 'Transfered In',
          itemName: 'Donut (Sales)',
          itemUuid: 'donut-sales',
          staffId: staffAda,
          staffName: 'Ada',
          departmentUuid: deptBakery,
          departmentName: 'Bakery',
          newValue: '15',
          oldValue: '0',
          quantityChange: 15,
          desc: null,
          isIncreased: true,
          unit: 'Pcs',
          primaryUnit: 'Pcs',
          event: ItemHistoryEventClass.transferedIn,
          isManaged: true,
          source: ItemHistoryEventClass.productionSource,
          destination: ItemHistoryEventClass.productDestination,
        ),
      ],
    );
  }
}

/// Four records across two departments and two staff, plus one with
/// no department, for the scope tests.
///
/// | uuid   | department | staff |
/// |--------|------------|-------|
/// | prod-1 | bakery     | ada   |
/// | prod-2 | bakery     | ben   |
/// | prod-3 | kitchen    | ada   |
/// | prod-4 | (none)     | ben   |
List<ProductionRecord> scopeRecords() => [
  productionRecord(
    uuid: 'prod-1',
    createdAt: oct(2, 10),
    quantity: 30,
    departmentId: deptBakery,
    staffId: staffAda,
  ),
  productionRecord(
    uuid: 'prod-2',
    createdAt: oct(3, 10),
    quantity: 10,
    departmentId: deptBakery,
    staffId: staffBen,
  ),
  productionRecord(
    uuid: 'prod-3',
    createdAt: oct(4, 10),
    quantity: 5,
    departmentId: deptKitchen,
    staffId: staffAda,
  ),
  productionRecord(
    uuid: 'prod-4',
    createdAt: oct(5, 10),
    quantity: 1,
    departmentId: null,
    departmentName: null,
    staffId: staffBen,
  ),
];

/// The same layout as [scopeRecords], for usage records.
List<ProductionMaterialsUsage> scopeUsages() => [
  usageRecord(
    uuid: 'usage-1',
    createdAt: oct(2, 10),
    quantity: 1,
    departmentUuid: deptBakery,
    staffUuid: staffAda,
  ),
  usageRecord(
    uuid: 'usage-2',
    createdAt: oct(3, 10),
    quantity: 1,
    departmentUuid: deptBakery,
    staffUuid: staffBen,
  ),
  usageRecord(
    uuid: 'usage-3',
    createdAt: oct(4, 10),
    quantity: 1,
    departmentUuid: deptKitchen,
    staffUuid: staffAda,
  ),
  usageRecord(
    uuid: 'usage-4',
    createdAt: oct(5, 10),
    quantity: 1,
    departmentUuid: null,
    departmentName: null,
    staffUuid: staffBen,
  ),
];

List<ProductUnitsClass> sugarUnits() => [
  prodUnit('sugar-kg', 'Kg', productUuid: 'sugar'),
];

/// Three records on 2 Oct 2026, used by the table and summary tests:
///
/// - prod-1: Alex's run. 30 Pcs of donuts from 1 bag of flour
///   (₦5,000), cost from the materials. Ada, Bakery.
/// - prod-2: 3 Box (36 Pcs) of donuts from 1 bag of flour and 2 Kg of
///   sugar (₦800), the item's cost ₦7,200. Ben, Bakery.
/// - prod-3: 10 Litre of juice into the sales item, no materials, a
///   custom cost of ₦1,200. No staff, no department.
List<ProductionRecord> sampleRecords() => [
  AlexExample().record,
  productionRecord(
    uuid: 'prod-2',
    createdAt: oct(2, 12),
    quantity: 3,
    unitUuid: 'donut-box',
    units: donutUnits(),
    totalCost: 7200,
    selectedCostPriceOption: 1,
    staffId: staffBen,
    staffName: 'Ben',
    comment: 'Big order',
    materials: [
      materialLine(
        uuid: 'line-2a',
        quantity: 1,
        unitUuid: 'flour-bag',
        units: flourUnits(),
        totalCost: 5000,
        originalCostPerItem: 5000,
      ),
      materialLine(
        uuid: 'line-2b',
        materialUuid: 'sugar',
        materialName: 'Sugar',
        quantity: 2,
        unitUuid: 'sugar-kg',
        units: sugarUnits(),
        unit: 'Kg',
        totalCost: 800,
        originalCostPerItem: 400,
      ),
    ],
  ),
  productionRecord(
    uuid: 'prod-3',
    createdAt: oct(2, 15),
    itemUuid: null,
    salesItemUuid: 'juice',
    itemName: 'Juice',
    quantity: 10,
    unitUuid: null,
    units: null,
    unit: 'Litre',
    totalCost: 1000,
    customCost: 1200,
    selectedCostPriceOption: 3,
    staffId: null,
    staffName: null,
    departmentId: null,
    departmentName: null,
  ),
];

/// A uuid long enough for a "#…" display id, distinct per [n].
String recordUuidN(int n) =>
    'pr-${n.toString().padLeft(12, '0')}-0000';

/// [n] one-hour-apart donut runs from 1 Oct 2026 00:00, costs
/// 100 + i.
List<ProductionRecord> manyRecords(int n) => [
  for (var i = 1; i <= n; i++)
    productionRecord(
      uuid: recordUuidN(i),
      createdAt: DateTime(2026, 10, 1).add(Duration(hours: i)),
      quantity: i.toDouble(),
      units: donutUnits(),
      totalCost: 100.0 + i,
      materials: [
        materialLine(
          uuid: 'l-$i',
          quantity: 1,
          unitUuid: 'flour-bag',
          units: flourUnits(),
          totalCost: 50,
        ),
      ],
    ),
];

/// Rows of [records] as the report builds them.
List<ProductionRecordRow> recordRows(
  List<ProductionRecord> records, {
  bool manageProductionItems = true,
}) => ProductionRecordRowBuilder.buildAll(
  records: records,
  manageProductionItems: manageProductionItems,
);

/// The report screens without providers: data and permissions come
/// from here, as `ProductionRecordsEnv.live` reads them in the app.
/// [records] is read on every rebuild, so a test (or [onOpen]) can
/// change it.
ProductionRecordsEnv fakeRecordsEnv({
  required List<ProductionRecord> records,
  bool departmentsEnabled = false,
  bool canSeeCost = true,
  bool canSeeQuantity = true,
  bool manageProductionItems = true,
  List<ProductionRecord>? opened,
  void Function(ProductionRecord record)? onOpen,
  Future<void> Function(
    BuildContext context,
    ProductionRecordsFilters filters,
    ReceiptsReportPeriod period,
  )?
  openTable,
}) {
  return ProductionRecordsEnv(
    departmentsEnabled: () => departmentsEnabled,
    canPickDate: () => true,
    canSeeCost: () => canSeeCost,
    canSeeQuantity: () => canSeeQuantity,
    manageProductionItems: () => manageProductionItems,
    records: () => records,
    pendingDeletedUuids: () => const {},
    load: (context, {required refreshFromStore}) async {},
    signature: () => 'fixed',
    listen: (_) {},
    money: (_, v) => 'N$v',
    openRecord: (context, record) async {
      opened?.add(record);
      onOpen?.call(record);
    },
    openTable: openTable,
  );
}

// ---------------------------------------------------------------
// Usage records (Phase 2)
// ---------------------------------------------------------------

/// Usage records on 2 Oct 2026, linked to [sampleRecords] where they
/// came from a production:
///
/// - usage-1: Alex's run (prod-1), 1 Bag of flour, ₦5,000. Ada, Bakery.
/// - usage-2: prod-2, 1 Bag of flour, ₦5,000. Ben, Bakery.
/// - usage-3: prod-2, 2 Kg of sugar, ₦800. Ben, Bakery.
/// - usage-4: manual, 0.5 Kg of sugar, ₦200. No staff, no department,
///   not managed.
/// - usage-5: manual, 0.25 Bag of flour, ₦1,250. Ben, Kitchen.
///
/// Total ₦12,250: production ₦10,800 (3), manual ₦1,450 (2).
List<ProductionMaterialsUsage> sampleUsages() => [
  AlexExample().usage,
  usageRecord(
    uuid: 'usage-2',
    createdAt: oct(2, 12),
    quantity: 1,
    units: flourUnits(),
    totalCost: 5000,
    originalCostPerItem: 5000,
    productionRecordUuid: 'prod-2',
    staffUuid: staffBen,
    staffName: 'Ben',
  ),
  usageRecord(
    uuid: 'usage-3',
    createdAt: oct(2, 12),
    materialUuid: 'sugar',
    materialName: 'Sugar',
    quantity: 2,
    unitUuid: 'sugar-kg',
    units: sugarUnits(),
    totalCost: 800,
    originalCostPerItem: 400,
    productionRecordUuid: 'prod-2',
    staffUuid: staffBen,
    staffName: 'Ben',
  ),
  usageRecord(
    uuid: 'usage-4',
    createdAt: oct(2, 14),
    materialUuid: 'sugar',
    materialName: 'Sugar',
    quantity: 0.5,
    unitUuid: 'sugar-kg',
    units: sugarUnits(),
    totalCost: 200,
    originalCostPerItem: 400,
    staffUuid: null,
    staffName: null,
    departmentUuid: null,
    departmentName: null,
    isManaged: false,
  ),
  usageRecord(
    uuid: 'usage-5',
    createdAt: oct(2, 16),
    quantity: 0.25,
    units: flourUnits(),
    totalCost: 1250,
    originalCostPerItem: 5000,
    staffUuid: staffBen,
    staffName: 'Ben',
    departmentUuid: deptKitchen,
    departmentName: 'Kitchen',
  ),
];

/// A production saved before usage records existed: 1 Bag of flour
/// into 30 donuts on 2 Oct 2026 08:00, with no usage record.
ProductionRecord legacyRecord({DateTime? createdAt}) => productionRecord(
  uuid: 'prod-L',
  createdAt: createdAt ?? oct(2, 8),
  quantity: 30,
  units: donutUnits(),
  totalCost: 5000,
  selectedCostPriceOption: 2,
  materials: [
    materialLine(
      uuid: 'line-L',
      quantity: 1,
      unitUuid: 'flour-bag',
      units: flourUnits(),
      totalCost: 5000,
      originalCostPerItem: 5000,
    ),
  ],
);

/// A uuid long enough for a "#…" display id, distinct per [n].
String usageUuidN(int n) => 'us-${n.toString().padLeft(12, '0')}-0000';

/// [n] one-hour-apart manual flour usages from 1 Oct 2026 00:00:
/// quantity i Bag, cost 100 + i.
List<ProductionMaterialsUsage> manyUsages(int n) => [
  for (var i = 1; i <= n; i++)
    usageRecord(
      uuid: usageUuidN(i),
      createdAt: DateTime(2026, 10, 1).add(Duration(hours: i)),
      quantity: i.toDouble(),
      units: flourUnits(),
      totalCost: 100.0 + i,
      originalCostPerItem: 50,
    ),
];

/// Rows of [usages] as the report builds them, with [records] (default
/// [sampleRecords]) loaded for the production names.
List<UsageRecordRow> usageRows(
  List<ProductionMaterialsUsage> usages, {
  List<ProductionRecord>? records,
}) => UsageRecordRowBuilder.buildAll(
  usages: usages,
  recordRows: recordRows(records ?? sampleRecords()),
);

/// The usage report screens without providers, as
/// `UsageRecordsEnv.live` reads them in the app. [usages] and
/// [records] are read on every rebuild, so a test (or [onOpenUsage])
/// can change them.
UsageRecordsEnv fakeUsageEnv({
  required List<ProductionMaterialsUsage> usages,
  List<ProductionRecord>? records,
  bool departmentsEnabled = false,
  bool canSeeCost = true,
  bool canSeeQuantity = true,
  List<String>? openedProductions,
  List<ProductionMaterialsUsage>? openedUsages,
  void Function(ProductionMaterialsUsage usage)? onOpenUsage,
  Future<void> Function(
    BuildContext context,
    UsageRecordsFilters filters,
    ReceiptsReportPeriod period,
  )?
  openTable,
}) {
  final loaded = records ?? sampleRecords();
  return UsageRecordsEnv(
    departmentsEnabled: () => departmentsEnabled,
    canPickDate: () => true,
    canSeeCost: () => canSeeCost,
    canSeeQuantity: () => canSeeQuantity,
    manageProductionItems: () => true,
    usages: () => usages,
    records: () => loaded,
    pendingDeletedUuids: () => const {},
    pendingDeletedRecordUuids: () => const {},
    load: (context, {required refreshFromStore}) async {},
    signature: () => 'fixed',
    listen: (_) {},
    money: (_, v) => 'N$v',
    openProduction: (context, uuid) async => openedProductions?.add(uuid),
    openUsage: (context, usage) async {
      openedUsages?.add(usage);
      onOpenUsage?.call(usage);
    },
    openTable: openTable,
  );
}

// ---------------------------------------------------------------
// Produced items and the stock pages (Phase 3)
// ---------------------------------------------------------------

const String catPastry = 'cat-pastry';
const String catDrinks = 'cat-drinks';

/// Category uuid → name ("cat-deleted" isn't here: a deleted
/// category).
Map<String, String> sampleCategories() => {
  catPastry: 'Pastry',
  catDrinks: 'Drinks',
};

/// The business "now" of the stock tests: 4 Oct 2026, noon.
final stockNow = DateTime(2026, 10, 4, 12);

/// Three produced items:
///
/// - donut: Alex's 15 Pcs (12-piece Box), ₦200 a piece, Bakery,
///   Pastry, expires 20 Oct.
/// - juice-base: 10 Litre, unmanaged, ₦50, no department, no category.
/// - cake: 0 Pcs (out of stock), ₦1,000, Kitchen, Pastry and a deleted
///   category, expired 1 Oct.
List<ProductionItem> sampleProducedItems() => [
  producedItem(
    quantity: 15,
    costPrice: 200,
    units: donutUnits(),
    departmentUuid: deptBakery,
    departmentName: 'Bakery',
    categories: const [catPastry],
    createdAt: oct(1, 8),
    expiryDate: DateTime(2026, 10, 20),
  ),
  producedItem(
    uuid: 'juice-base',
    name: 'Juice Base',
    quantity: 10,
    costPrice: 50,
    unit: 'Litre',
    isManaged: false,
    createdAt: oct(1, 8),
  ),
  producedItem(
    uuid: 'cake',
    name: 'Cake',
    quantity: 0,
    costPrice: 1000,
    units: [prodUnit('cake-pcs', 'Pcs', productUuid: 'cake')],
    departmentUuid: deptKitchen,
    departmentName: 'Kitchen',
    categories: const [catPastry, 'cat-deleted'],
    createdAt: oct(1, 8),
    expiryDate: DateTime(2026, 10, 1),
  ),
];

/// A produced-item history record with every field settable.
ProductionItemHistory stockRecord({
  required String uuid,
  required String title,
  String? event,
  required DateTime createdAt,
  String? itemUuid = 'donut',
  String? itemName = 'Donut',
  double? quantityChange,
  String? oldValue,
  String? newValue,
  bool? isIncreased,
  String? source,
  String? destination,
  String? unit = 'Pcs',
  String? primaryUnit = 'Pcs',
  String? staffId = staffAda,
  String? staffName = 'Ada',
  String? departmentUuid = deptBakery,
  String? departmentName = 'Bakery',
  String? desc,
  bool? isManaged = true,
}) {
  return ProductionItemHistory(
    uuid: uuid,
    createdAt: createdAt,
    shopId: testShopId,
    title: title,
    itemName: itemName,
    itemUuid: itemUuid,
    staffId: staffId,
    staffName: staffName,
    departmentUuid: departmentUuid,
    departmentName: departmentName,
    newValue: newValue,
    oldValue: oldValue,
    quantityChange: quantityChange,
    desc: desc,
    isIncreased: isIncreased,
    unit: unit,
    primaryUnit: primaryUnit,
    event: event,
    isManaged: isManaged,
    source: source,
    destination: destination,
  );
}

/// The history behind [sampleProducedItems]. On 2 Oct 2026:
///
/// - donut (Alex): +30 produced (0 → 30), −15 to sales (30 → 15).
/// - cake (Kitchen): +5 produced by a legacy record with no event
///   (0 → 5), −2 to a branch by a legacy record with no destination
///   ("Shop Name:" in its description, 5 → 3), −3 by hand (3 → 0, no
///   staff, no department).
/// - muffin, since deleted: +12 produced (0 → 12).
///
/// On 3 Oct: donut +2 Box produced, written when its primary unit was
/// "Dozen" (24 Pcs), and +1 "Tray" by hand that can't be converted.
List<ProductionItemHistory> sampleProducedHistory() => [
  ...AlexExample().donutHistory,
  stockRecord(
    uuid: 'ch-1',
    title: 'Item Produced',
    createdAt: oct(2, 9),
    itemUuid: 'cake',
    itemName: 'Cake',
    quantityChange: 5,
    oldValue: '0',
    newValue: '5',
    isIncreased: true,
    departmentUuid: deptKitchen,
    departmentName: 'Kitchen',
    staffId: staffBen,
    staffName: 'Ben',
  ),
  stockRecord(
    uuid: 'ch-2',
    title: 'Transfered Out',
    createdAt: oct(2, 11),
    itemUuid: 'cake',
    itemName: 'Cake',
    quantityChange: -2,
    oldValue: '5',
    newValue: '3',
    isIncreased: false,
    desc:
        'Production Item Quantity Transfered To - Item Name: Cake, '
        'Shop Name: Lekki.',
    departmentUuid: deptKitchen,
    departmentName: 'Kitchen',
    staffId: staffBen,
    staffName: 'Ben',
  ),
  stockRecord(
    uuid: 'ch-3',
    title: 'Item Quantity Reduced',
    event: ProductionItemHistoryEventClass.quantityUpdatedDecrease,
    createdAt: oct(2, 12),
    itemUuid: 'cake',
    itemName: 'Cake',
    quantityChange: 3,
    oldValue: '3',
    newValue: '0',
    isIncreased: false,
    source: ProductionItemHistoryEventClass.manualSource,
    staffId: null,
    staffName: null,
    departmentUuid: null,
    departmentName: null,
  ),
  stockRecord(
    uuid: 'mh-gone',
    title: 'Item Produced',
    event: ProductionItemHistoryEventClass.productionCreated,
    createdAt: oct(2, 13),
    itemUuid: 'muffin',
    itemName: 'Muffin',
    quantityChange: 12,
    oldValue: '0',
    newValue: '12',
    isIncreased: true,
  ),
  stockRecord(
    uuid: 'ph-3',
    title: 'Item Produced',
    event: ProductionItemHistoryEventClass.productionCreated,
    createdAt: oct(3, 10),
    quantityChange: 2,
    unit: 'Box',
    primaryUnit: 'Dozen',
    oldValue: '1.25',
    newValue: '3.25',
    isIncreased: true,
  ),
  stockRecord(
    uuid: 'ph-4',
    title: 'Item Quantity Increased',
    event: ProductionItemHistoryEventClass.quantityUpdatedIncrease,
    createdAt: oct(3, 12),
    quantityChange: 1,
    unit: 'Tray',
    oldValue: null,
    newValue: null,
    isIncreased: true,
  ),
];

List<ProductionStockItem> stockItems([List<ProductionItem>? items]) => [
  for (final p in items ?? sampleProducedItems())
    ProductionStockItem.fromProducedItem(p),
];

List<ProductionStockEntry> stockEntries([List<ProductionItemHistory>? h]) => [
  for (final x in h ?? sampleProducedHistory())
    ProductionStockEntry.fromProducedHistory(x),
];

/// [n] managed produced items "Item 001"… with n − i Pcs at ₦10 each,
/// for the paging tests.
List<ProductionItem> manyProducedItems(int n) => [
  for (var i = 1; i <= n; i++)
    producedItem(
      uuid: 'item-${i.toString().padLeft(3, '0')}',
      name: 'Item ${i.toString().padLeft(3, '0')}',
      quantity: (n - i).toDouble(),
      costPrice: 10,
      createdAt: oct(1, 8),
    ),
];

/// The stock pages without providers, as `ProductionStockEnv.live`
/// reads them in the app. [items] and [history] are read on every
/// rebuild.
ProductionStockEnv fakeStockEnv({
  ProductionStockKind kind = ProductionStockKind.producedItem,
  List<ProductionItem>? items,
  List<ProductionItemHistory>? history,
  List<MaterialClass>? materials,
  List<MaterialsItemHistory>? materialHistory,
  List<ProductionMaterialsUsage>? usages,
  List<ProductionRecord>? records,
  bool departmentsEnabled = false,
  bool canSeeCost = true,
  bool canSeeQuantity = true,
  bool historyAllowed = true,
  List<String>? openedItems,
  void Function(String uuid)? onOpenItem,
  Future<void> Function(
    BuildContext context,
    ProductionStockFilters filters,
    ReceiptsReportPeriod period,
  )?
  openTable,
  Future<void> Function(
    BuildContext context,
    ProductionHistoryFilters filters,
    ReceiptsReportPeriod period,
  )?
  openHistory,
}) {
  final i = items ?? sampleProducedItems();
  final h = history ?? sampleProducedHistory();
  final m = materials ?? sampleMaterials();
  final mh = materialHistory ?? sampleMaterialHistory();
  final material = kind == ProductionStockKind.material;
  return ProductionStockEnv(
    kind: kind,
    departmentsEnabled: () => departmentsEnabled,
    canPickDate: () => true,
    canSeeCost: () => canSeeCost,
    canSeeQuantity: () => canSeeQuantity,
    historyAllowed: () => historyAllowed,
    items: () => material ? materialItems(m) : stockItems(i),
    entries:
        () =>
            !historyAllowed
                ? const []
                : material
                ? materialEntries(mh)
                : stockEntries(h),
    records:
        () => recordRows(
          records ?? (material ? materialRecords() : sampleRecords()),
        ),
    usages: () => material ? usageRows(usages ?? sampleUsages()) : const [],
    categoryNames: sampleCategories,
    load: (context, {required refreshFromStore}) async {},
    signature: () => 'fixed',
    listen: (_) {},
    money: (_, v) => 'N$v',
    openItem: (context, uuid) async {
      openedItems?.add(uuid);
      onOpenItem?.call(uuid);
    },
    openTable: openTable ?? (_, _, _) async {},
    openHistory: openHistory ?? (_, _, _) async {},
  );
}

// ---------------------------------------------------------------
// Materials (Phase 4)
// ---------------------------------------------------------------

/// Three materials:
///
/// - flour: Alex's 1 Bag left, ₦5,000 a bag, low at 1 (so Low), Bakery,
///   Pastry.
/// - sugar: 9 Kg at ₦400, low at 2, Kitchen, Drinks.
/// - yeast: out of stock, ₦100 a pack, expired 1 Oct, no department or
///   category, unused in October.
List<MaterialClass> sampleMaterials() => [
  material(
    quantity: 1,
    costPrice: AlexExample.bagCost,
    units: flourUnits(),
    departmentUuid: deptBakery,
    departmentName: 'Bakery',
    lowQtty: 1,
    categories: const [catPastry],
    createdAt: oct(1, 8),
  ),
  material(
    uuid: 'sugar',
    name: 'Sugar',
    quantity: 9,
    costPrice: 400,
    units: sugarUnits(),
    unit: 'Kg',
    departmentUuid: deptKitchen,
    departmentName: 'Kitchen',
    lowQtty: 2,
    categories: const [catDrinks],
    createdAt: oct(1, 8),
  ),
  material(
    uuid: 'yeast',
    name: 'Yeast',
    quantity: 0,
    costPrice: 100,
    units: [prodUnit('yeast-pack', 'Pack', productUuid: 'yeast')],
    unit: 'Pack',
    createdAt: oct(1, 8),
    expiryDate: DateTime(2026, 10, 1),
  ),
];

/// The history behind [sampleMaterials]:
///
/// - flour (Alex): +2 on 1 Oct (0 → 2), 1 Bag used on 2 Oct (2 → 1).
/// - yeast: 1 Pack used by a legacy production on 1 Oct, written with
///   no event ("Material Used in Production", 1 → 0).
/// - sugar (Kitchen) on 2 Oct: 2 Kg used by prod-2 (12.5 → 10.5), 2 Kg
///   moved to another department (10.5 → 8.5), 0.5 Kg used by hand
///   (8.5 → 8); on 3 Oct +1 Kg by hand (8 → 9).
List<MaterialsItemHistory> sampleMaterialHistory() => [
  ...AlexExample().flourHistory,
  materialHistory(
    uuid: 'yh-1',
    title: 'Material Used in Production',
    event: null,
    createdAt: oct(1, 9),
    itemUuid: 'yeast',
    itemName: 'Yeast',
    quantityChange: -1,
    oldValue: '1',
    newValue: '0',
    isIncreased: false,
    unit: 'Pack',
    primaryUnit: 'Pack',
    departmentUuid: null,
  ),
  for (final (uuid, title, event, hour, change, from, to, destination) in [
    (
      'sh-1',
      'Material Used',
      MaterialItemHistoryEventClass.usageCreated,
      12,
      -2.0,
      '12.5',
      '10.5',
      null,
    ),
    (
      'sh-2',
      'Transfered Out',
      MaterialItemHistoryEventClass.transferedOut,
      13,
      -2.0,
      '10.5',
      '8.5',
      MaterialItemHistoryEventClass.departmentDestination,
    ),
    (
      'sh-3',
      'Material Used',
      MaterialItemHistoryEventClass.usageCreated,
      14,
      -0.5,
      '8.5',
      '8',
      null,
    ),
  ])
    materialHistory(
      uuid: uuid,
      title: title,
      event: event,
      createdAt: oct(2, hour),
      itemUuid: 'sugar',
      itemName: 'Sugar',
      quantityChange: change,
      oldValue: from,
      newValue: to,
      isIncreased: false,
      destination: destination,
      unit: 'Kg',
      primaryUnit: 'Kg',
      departmentUuid: deptKitchen,
    ),
  materialHistory(
    uuid: 'sh-4',
    title: 'Item Quantity Increased',
    event: MaterialItemHistoryEventClass.quantityUpdatedIncrease,
    createdAt: oct(3, 10),
    itemUuid: 'sugar',
    itemName: 'Sugar',
    quantityChange: 1,
    oldValue: '8',
    newValue: '9',
    isIncreased: true,
    unit: 'Kg',
    primaryUnit: 'Kg',
    departmentUuid: deptKitchen,
  ),
];

List<ProductionStockItem> materialItems([List<MaterialClass>? materials]) => [
  for (final m in materials ?? sampleMaterials())
    ProductionStockItem.fromMaterial(m),
];

List<ProductionStockEntry> materialEntries([List<MaterialsItemHistory>? h]) => [
  for (final x in h ?? sampleMaterialHistory())
    ProductionStockEntry.fromMaterialHistory(x),
];

/// [n] managed materials "Material 001"… with n − i Bags at ₦10 each.
List<MaterialClass> manyMaterials(int n) => [
  for (var i = 1; i <= n; i++)
    material(
      uuid: 'mat-${i.toString().padLeft(3, '0')}',
      name: 'Material ${i.toString().padLeft(3, '0')}',
      quantity: (n - i).toDouble(),
      costPrice: 10,
      createdAt: oct(1, 8),
    ),
];

/// The production records of the material pages: [sampleRecords] and
/// the legacy prod-L (flour, no usage record).
List<ProductionRecord> materialRecords() => [...sampleRecords(), legacyRecord()];
