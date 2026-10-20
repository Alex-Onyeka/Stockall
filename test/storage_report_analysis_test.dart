import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/temp_departments_class/department_class.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_product_class/units_class/product_units_class.dart';
import 'package:stockall/classes/temp_storage_item_history/storage_item_history.dart';
import 'package:stockall/classes/temp_storage_product/temp_storage_products.dart';
import 'package:stockall/pages/report/storage_items_report_/storage_item_history_summary/class/storage_item_history_summary_logic.dart';
import 'package:stockall/pages/report/storage_items_report_/storage_report_analysis/class/storage_report_analysis_logic.dart';
import 'package:stockall/pages/report/storage_items_report_/storage_report_analysis/storage_report_analysis_page.dart';
import 'package:stockall/pages/report/storage_items_report_/storage_report_main/class/storage_report_main_logic.dart';

ProductUnitsClass unit(String name, {int? dimensionType}) {
  return ProductUnitsClass(
    uuid: name,
    staffUuid: null,
    createdAt: DateTime.utc(2026),
    staffName: null,
    conversion: 1,
    name: name,
    isPrimary: true,
    productUuid: 'storage',
    dimensionType: dimensionType,
  );
}

TempStorageProducts storageItem({
  required String uuid,
  required String name,
  required double? quantity,
  required double? costPrice,
  required String unitName,
  DateTime? createdAt,
  bool twoD = false,
}) {
  return TempStorageProducts(
    uuid: uuid,
    shopId: 1,
    name: name,
    quantity: quantity,
    costPrice: costPrice,
    sellingPrice: null,
    useGroupUnit: false,
    unitsList: [
      unit(
        unitName,
        dimensionType: twoD ? ProductUnitsClass.sheetUnit : null,
      ),
    ],
    createdAt: createdAt,
    quantityType: twoD ? 2 : 1,
    widthDimension: twoD ? 2 : null,
    heightDimension: twoD ? 3 : null,
  );
}

TempProductClass salesItem({
  required String uuid,
  required double quantity,
  required String storageUuid,
  String? departmentUuid,
  String? departmentName,
  bool twoD = false,
}) {
  return TempProductClass(
    uuid: uuid,
    name: 'Sales $uuid',
    shopId: 1,
    unit: 'Pieces',
    isRefundable: false,
    costPrice: 0,
    sellingPrice: 0,
    quantity: quantity,
    setCustomPrice: false,
    departmentName: departmentName,
    departmentUuid: departmentUuid,
    isManaged: true,
    groupUnit: null,
    qttyPerGroup: null,
    wholeSalePrice: null,
    storageUuid: storageUuid,
    categories: [],
    useGroupUnit: false,
    unitsList: [],
    pricesList: [],
    quantityType: twoD ? 2 : 1,
    widthDimension: twoD ? 1 : null,
    heightDimension: twoD ? 2 : null,
    manageSalesWastage: false,
  );
}

StorageItemHistory record({
  required String storageItemUuid,
  required String event,
  required DateTime createdAt,
  required String oldValue,
  required String newValue,
  required String unitName,
}) {
  return StorageItemHistory(
    uuid: '$storageItemUuid-$event-${createdAt.toIso8601String()}',
    createdAt: createdAt,
    shopId: 1,
    title: event,
    storageItemUuid: storageItemUuid,
    storageItemOldValue: oldValue,
    storageItemNewValue: newValue,
    storagePrimaryUnit: unitName,
    storageUnit: unitName,
    quantityChange: null,
    desc: null,
    isIncreased: null,
    event: event,
    source: null,
  );
}

void main() {
  final businessNow = DateTime(2026, 10, 20, 16);
  DateTime today(int hour) => DateTime(2026, 10, 20, hour);

  final storageProducts = [
    storageItem(
      uuid: 'flour',
      name: 'Flour Store',
      quantity: 30,
      costPrice: 10,
      unitName: 'Pcs',
      createdAt: DateTime(2026, 10, 15),
    ),
    storageItem(
      uuid: 'sugar',
      name: 'Sugar Store',
      quantity: 0,
      costPrice: null,
      unitName: 'Kg',
      createdAt: DateTime(2026, 10, 18),
    ),
    storageItem(
      uuid: 'glass',
      name: 'Glass Store',
      quantity: 4,
      costPrice: 50,
      unitName: 'sheet',
      createdAt: DateTime(2026, 10, 19),
      twoD: true,
    ),
    storageItem(
      uuid: 'salt',
      name: 'Salt Store',
      quantity: 12,
      costPrice: 2,
      unitName: 'Kg',
      createdAt: DateTime(2026, 10, 10),
    ),
    storageItem(
      uuid: 'rice',
      name: 'Rice Store',
      quantity: null,
      costPrice: 5,
      unitName: 'Bags',
    ),
  ];

  final salesProducts = [
    salesItem(
      uuid: 'bread',
      quantity: 5,
      storageUuid: 'flour',
      departmentUuid: 'bakery',
      departmentName: 'Bakery',
    ),
    salesItem(
      uuid: 'cake',
      quantity: 3,
      storageUuid: 'flour',
      departmentUuid: 'pastry',
      departmentName: 'Pastry',
    ),
    salesItem(uuid: 'tea', quantity: 2, storageUuid: 'sugar'),
    salesItem(
      uuid: 'mirror',
      quantity: 3,
      storageUuid: 'glass',
      departmentUuid: 'bakery',
      departmentName: 'Bakery',
      twoD: true,
    ),
  ];

  final rows = StorageReportRowBuilder.buildAll(
    storageProducts: storageProducts,
    salesProducts: salesProducts,
  );

  final histories = [
    record(
      storageItemUuid: 'salt',
      event: 'stock_in',
      createdAt: DateTime(2026, 10, 19, 9),
      oldValue: '0',
      newValue: '12',
      unitName: 'Kg',
    ),
    record(
      storageItemUuid: 'flour',
      event: 'stock_out',
      createdAt: today(9),
      oldValue: '30',
      newValue: '25',
      unitName: 'Pcs',
    ),
    record(
      storageItemUuid: 'flour',
      event: 'stock_out',
      createdAt: today(10),
      oldValue: '25',
      newValue: '22',
      unitName: 'Pcs',
    ),
    record(
      storageItemUuid: 'flour',
      event: 'return',
      createdAt: today(11),
      oldValue: '22',
      newValue: '24',
      unitName: 'Pcs',
    ),
    record(
      storageItemUuid: 'flour',
      event: 'stock_in',
      createdAt: today(12),
      oldValue: '24',
      newValue: '30',
      unitName: 'Pcs',
    ),
    record(
      storageItemUuid: 'flour',
      event: 'purchase',
      createdAt: today(13),
      oldValue: '30',
      newValue: '42',
      unitName: 'Pcs',
    ),
    record(
      storageItemUuid: 'flour',
      event: 'purchase_deleted',
      createdAt: today(14),
      oldValue: '42',
      newValue: '30',
      unitName: 'Pcs',
    ),
    record(
      storageItemUuid: 'glass',
      event: 'stock_out',
      createdAt: today(9),
      oldValue: '6',
      newValue: '4',
      unitName: 'sheet',
    ),
    record(
      storageItemUuid: 'sugar',
      event: 'created',
      createdAt: today(8),
      oldValue: '0',
      newValue: '0',
      unitName: 'Kg',
    ),
    // A deleted storage item: not part of the analysis.
    record(
      storageItemUuid: 'old',
      event: 'stock_out',
      createdAt: today(9),
      oldValue: '9',
      newValue: '1',
      unitName: 'Bottles',
    ),
  ];

  group('Summary', () {
    test('stock position, cost value and links', () {
      final s = StorageReportAnalysisBuilder.buildSummary(rows);
      expect(s.totalDistinctItems, 5);
      expect(s.inStockCount, 3);
      expect(s.outOfStockCount, 2);
      expect(s.totalStockCostValue, 524);
      expect(s.itemsWithoutCostCount, 1);
      expect(s.oneDimensionalCount, 4);
      expect(s.twoDimensionalCount, 1);
      expect(s.linkedCount, 3);
      expect(s.unlinkedCount, 2);
      expect(s.linkedSalesItemsCount, 4);
      expect(s.stockByPrimaryUnit, {'Pcs': 30, 'sheet': 4, 'Kg': 12});
      expect(s.hasSingleCompatibleUnit, isFalse);
      expect(s.singleUnitFormattedQuantity, isNull);
      // 2D: 3 sales sheets of 2 sqm = 1 storage sheet of 6 sqm.
      expect(s.quantityInSalesByUnit, {'Pcs': 8, 'Kg': 2, 'sheet': 1});
    });

    test('single unit and empty reports', () {
      final single = StorageReportAnalysisBuilder.buildSummary(
        rows.where((r) => r.uuid == 'flour').toList(),
      );
      expect(single.singleUnitFormattedQuantity, '30.0 Pcs');

      final empty = StorageReportAnalysisBuilder.buildSummary([]);
      expect(empty.totalDistinctItems, 0);
      expect(empty.totalStockCostValue, 0);
      expect(empty.singleUnitFormattedQuantity, '0');
    });
  });

  group('Performance', () {
    List<StoragePerformanceRecord> perf(StorageHistoryPeriod period) =>
        StorageReportAnalysisBuilder.computePerformance(
          rows: rows,
          storageProducts: storageProducts,
          histories: histories,
          period: period,
          businessNow: businessNow,
        );

    test('movements per item for the period', () {
      final records = {for (final r in perf(StorageHistoryPeriod.today)) r.uuid: r};
      expect(records.keys.toSet(), {'flour', 'sugar', 'glass', 'salt', 'rice'});

      final f = records['flour']!;
      expect(f.transferredOut, 8);
      expect(f.returnedFromSales, 2);
      // 6 stocked in + 12 purchased - 12 purchase deleted.
      expect(f.restocked, 6);
      expect(f.movementCount, 6);
      expect(f.formattedMetricValue(StoragePerformanceMetric.transferredOut), '8.0 Pcs');
      expect(f.formattedMetricValue(StoragePerformanceMetric.movementCount), '6 movements');

      final g = records['glass']!;
      expect(g.transferredOut, 2);
      expect(g.formattedMetricValue(StoragePerformanceMetric.movementCount), '1 movement');

      // Created only: no movement.
      expect(records['sugar']!.isIdle, isTrue);
      expect(records['salt']!.isIdle, isTrue);

      final allTime = {for (final r in perf(StorageHistoryPeriod.allTime)) r.uuid: r};
      expect(allTime['salt']!.restocked, 12);
    });

    test('best, least and idle items', () {
      final records = perf(StorageHistoryPeriod.today);
      List<String> names(List<StoragePerformanceRecord> list) =>
          list.map((r) => r.uuid).toList();

      expect(
        names(StorageReportAnalysisBuilder.getBest3(
          records: records,
          metric: StoragePerformanceMetric.transferredOut,
        )),
        ['flour', 'glass', 'rice'],
      );
      expect(
        names(StorageReportAnalysisBuilder.getLeast3(
          records: records,
          metric: StoragePerformanceMetric.transferredOut,
        )),
        ['rice', 'salt', 'sugar'],
      );
      expect(
        names(StorageReportAnalysisBuilder.getBest3(
          records: records,
          metric: StoragePerformanceMetric.restocked,
        )),
        ['flour', 'glass', 'rice'],
      );
      expect(
        names(StorageReportAnalysisBuilder.getBest3(
          records: records,
          metric: StoragePerformanceMetric.movementCount,
        )),
        ['flour', 'glass', 'rice'],
      );
      expect(
        names(StorageReportAnalysisBuilder.getIdleItems(records)),
        ['rice', 'salt', 'sugar'],
      );
      expect(
        StorageReportAnalysisBuilder.getBest3(
          records: const [],
          metric: StoragePerformanceMetric.restocked,
        ),
        isEmpty,
      );
    });
  });

  group('Distributions', () {
    final departments = [
      DepartmentClass(
        uuid: 'bakery',
        createdAt: DateTime(2026),
        shopId: 1,
        name: 'Bakery',
      ),
      DepartmentClass(
        uuid: 'pastry',
        createdAt: DateTime(2026),
        shopId: 1,
        name: 'Pastry Shop',
      ),
    ];

    test('departments supplied, with no-department and unlinked buckets', () {
      final list = StorageReportAnalysisBuilder.computeDepartmentDistribution(
        rows: rows,
        departments: departments,
      );
      expect(list.map((e) => e.label).toList(), [
        'Bakery',
        'Pastry Shop',
        'No Department',
        'Unlinked',
      ]);
      expect(list.map((e) => e.itemCount).toList(), [2, 1, 1, 2]);
      expect(list.map((e) => e.percentage).toList(), [40, 20, 20, 40]);
      expect(list.map((e) => e.index).toList(), [1, 2, 3, 4]);
      expect(list.last.key, storageAnalysisUnlinkedKey);
    });

    test('unknown departments use the sales item department name', () {
      final list = StorageReportAnalysisBuilder.computeDepartmentDistribution(
        rows: rows,
        departments: [departments.first],
      );
      expect(list.map((e) => e.label), contains('Pastry'));
    });

    test('empty report still shows the unlinked bucket', () {
      final list = StorageReportAnalysisBuilder.computeDepartmentDistribution(
        rows: const [],
        departments: departments,
      );
      expect(list.single.label, 'Unlinked');
      expect(list.single.percentage, 0);
    });

    test('quantity types', () {
      final list =
          StorageReportAnalysisBuilder.computeQuantityTypeDistribution(rows);
      expect(list.map((e) => e.itemCount).toList(), [4, 1]);
      expect(list.map((e) => e.percentage).toList(), [80, 20]);
    });

    test('newly created items, newest first', () {
      final list = StorageReportAnalysisBuilder.getNewlyCreatedItems(rows);
      expect(list.map((r) => r.uuid).toList(), [
        'glass',
        'sugar',
        'flour',
        'salt',
        'rice',
      ]);
      expect(
        StorageReportAnalysisBuilder.getNewlyCreatedItems(rows, limit: 2).length,
        2,
      );
    });
  });

  test('Page constructor', () {
    const page = StorageReportAnalysisPage();
    expect(page, isA<StorageReportAnalysisPage>());
  });
}
