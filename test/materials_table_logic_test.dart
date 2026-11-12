import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/temp_production_folder/temp_material_class/material_class.dart';
import 'package:stockall/classes/temp_production_folder/temp_materials_item_history/materials_item_history.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_materials_usage/production_materials_usage.dart';
import 'package:stockall/classes/temp_production_folder/temp_productions/production_record.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/material_usage_logic.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/production_stock_model.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/stock_items_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

import 'production_report_fixtures.dart';

const six = TimeOfDay(hour: 6, minute: 0);
final day2 = ReceiptsReportPeriod.day(DateTime(2026, 10, 2));

/// The Materials table's rows, as the view builds them.
List<ProductionStockRow> materialRows({
  ReceiptsReportPeriod? period,
  List<MaterialClass>? materials,
  List<MaterialsItemHistory>? history,
  List<ProductionRecord>? records,
  List<ProductionMaterialsUsage>? usages,
  bool historyAllowed = true,
}) {
  final items = materialItems(materials);
  final p = period ?? day2;
  return ProductionStockRowBuilder.buildAll(
    items: items,
    entries: materialEntries(history),
    categoryNames: sampleCategories(),
    period: p,
    businessNow: stockNow,
    historyAllowed: historyAllowed,
    closingTime: six,
    usageByItem: ProductionMaterialUsageBuilder.build(
      records: recordRows(records ?? materialRecords()),
      usages: usageRows(usages ?? sampleUsages()),
      period: p,
      items: {for (final i in items) i.uuid: i},
      closingTime: six,
    ),
  );
}

List<ProductionStockRow> materialQuery(
  List<ProductionStockRow> rows, {
  ProductionStockFilters? filters,
  ProductionStockSort sort = ProductionStockSort.byName,
  bool canSeeCost = true,
  bool canSeeQuantity = true,
}) => ProductionStockQuery.filterAndSort(
  rows: rows,
  filters: filters ?? ProductionStockFilters(),
  sort: sort,
  departmentsEnabled: true,
  canSeeCost: canSeeCost,
  canSeeQuantity: canSeeQuantity,
);

ProductionStockRow rowOf(List<ProductionStockRow> rows, String uuid) =>
    rows.firstWhere((r) => r.uuid == uuid);

List<String> uuids(List<ProductionStockRow> rows) => [for (final r in rows) r.uuid];

void main() {
  test("the flour example: 2 → 1, used −1 in production, ₦5,000", () {
    final alex = AlexExample();
    final flour =
        materialRows(
          materials: [alex.flour],
          history: alex.flourHistory,
          records: [alex.record],
          usages: [alex.usage],
        ).single;
    expect(flour.balance.opening, 2);
    expect(flour.movement.of(ProductionMovementKind.used), 1);
    expect(flour.balance.closing, 1);
    expect(flour.materialUsage!.productionQty, 1);
    expect(flour.materialUsage!.manualQty, 0);
    expect(flour.materialUsage!.totalCost, 5000);
  });

  group('rows', () {
    final rows = materialRows();

    test('low stock: the low quantity in the primary unit, and the level', () {
      final flour = rowOf(rows, 'flour');
      expect(flour.lowQuantity, 1);
      expect(flour.stockLevel, ProductionStockLevel.low);
      expect(rowOf(rows, 'sugar').stockLevel, ProductionStockLevel.inStock);
      expect(rowOf(rows, 'sugar').lowQuantity, 2);
      expect(rowOf(rows, 'yeast').stockLevel, ProductionStockLevel.out);
      expect(rowOf(rows, 'yeast').lowQuantity, isNull);
      expect(productionStockLevels(ProductionStockKind.material), contains(ProductionStockLevel.low));
    });

    test('production vs manual use, never counted twice', () {
      final flour = rowOf(rows, 'flour').materialUsage!;
      // prod-1, prod-2 and the legacy prod-L; their usage records are
      // not counted again.
      expect(flour.productionQty, 3);
      expect(flour.manualQty, 0.25);
      expect(flour.totalCost, 16250);
      final yeast = rowOf(rows, 'yeast').materialUsage!;
      expect(yeast.used, isFalse);
    });

    test('history buckets: used, to a department, legacy production use', () {
      final sugar = rowOf(rows, 'sugar');
      expect(sugar.movement.of(ProductionMovementKind.used), 2.5);
      expect(sugar.movement.of(ProductionMovementKind.transferredToDepartment), 2);
      expect(sugar.balance.opening, 12.5);
      expect(sugar.balance.closing, 8);
      final oct1 = materialRows(period: ReceiptsReportPeriod.day(DateTime(2026, 10, 1)));
      // "Material Used in Production" with no event is a use.
      expect(rowOf(oct1, 'yeast').movement.of(ProductionMovementKind.used), 1);
    });
  });

  group('filters and sort', () {
    final rows = materialRows();

    test('the Low level; ignored without the quantity permission', () {
      final low = ProductionStockFilters(stockLevel: ProductionStockLevel.low);
      expect(uuids(materialQuery(rows, filters: low)), ['flour']);
      expect(materialQuery(rows, filters: low, canSeeQuantity: false), hasLength(3));
    });

    test('by usage cost, largest first; by name without cost access', () {
      const byCost = ProductionStockSort(
        ProductionStockSortField.usageCost,
        ascending: false,
      );
      expect(uuids(materialQuery(rows, sort: byCost)), ['flour', 'sugar', 'yeast']);
      expect(
        uuids(materialQuery(rows, sort: byCost, canSeeCost: false)),
        ['flour', 'sugar', 'yeast'],
      );
      const byManual = ProductionStockSort(
        ProductionStockSortField.usedManually,
        ascending: true,
      );
      expect(uuids(materialQuery(rows, sort: byManual)).first, 'yeast');
    });
  });

  test('totals over every page: stock value and usage cost', () {
    final all = materialQuery(materialRows());
    final p = ProductionStockQuery.paginate(all, 1);
    expect(p.totalStockValue, 5000 + 9 * 400);
    expect(p.totalUsageCost, 17250);
    final many = materialQuery(
      materialRows(materials: manyMaterials(150), history: const []),
    );
    final p2 = ProductionStockQuery.paginate(many, 2);
    expect(p2.rows, hasLength(50));
    expect(p2.totalCount, 150);
    expect(p2.totalStockValue, 10 * (149 * 150 / 2));
  });
}
