import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_materials_usage/production_materials_usage.dart';
import 'package:stockall/classes/temp_production_folder/temp_productions/production_record.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/material_usage_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

import 'production_report_fixtures.dart';

const six = TimeOfDay(hour: 6, minute: 0);
final day2 = ReceiptsReportPeriod.day(DateTime(2026, 10, 2));

Map<String, ProductionMaterialUsage> usageOf({
  List<ProductionRecord>? records,
  List<ProductionMaterialsUsage>? usages,
  ReceiptsReportPeriod? period,
  bool withItems = true,
}) => ProductionMaterialUsageBuilder.build(
  records: recordRows(records ?? materialRecords()),
  usages: usageRows(usages ?? sampleUsages()),
  period: period ?? day2,
  items: withItems ? {for (final i in materialItems()) i.uuid: i} : const {},
  closingTime: six,
);

void main() {
  test("Alex's flour: 1 bag used in production, ₦5,000, counted once", () {
    final alex = AlexExample();
    final u = usageOf(records: [alex.record], usages: [alex.usage])['flour']!;
    expect(u.productionQty, 1);
    expect(u.productionCost, 5000);
    expect(u.productionRuns, 1);
    // usage-1 was made by prod-1: not counted again as manual use.
    expect(u.manualQty, 0);
    expect(u.manualRecords, 0);
    expect(u.totalCost, 5000);
  });

  group('the sample day', () {
    final usage = usageOf();

    test('flour: three productions (one legacy) and one manual use', () {
      final flour = usage['flour']!;
      // prod-1, prod-2 and prod-L (no usage record) each used 1 bag.
      expect(flour.productionQty, 3);
      expect(flour.productionRuns, 3);
      expect(flour.productionCost, 15000);
      // usage-5: 0.25 bag by hand.
      expect(flour.manualQty, 0.25);
      expect(flour.manualCost, 1250);
      expect(flour.totalQty, 3.25);
      expect(flour.totalCost, 16250);
      expect(flour.lastUsed, oct(2, 16));
    });

    test('sugar: prod-2 and a manual use', () {
      final sugar = usage['sugar']!;
      expect(sugar.productionQty, 2);
      expect(sugar.productionCost, 800);
      expect(sugar.manualQty, 0.5);
      expect(sugar.manualCost, 200);
    });

    test('nothing for an unused material', () {
      expect(usage.containsKey('yeast'), isFalse);
    });
  });

  test('the period follows the closing time', () {
    // prod-L at 03:00 on 3 Oct is still 2 Oct's business day.
    final late = usageOf(records: [...sampleRecords(), legacyRecord(createdAt: oct(3, 3))]);
    expect(late['flour']!.productionQty, 3);
    final oct3 = usageOf(
      records: [legacyRecord(createdAt: oct(3, 7))],
      usages: const [],
      period: ReceiptsReportPeriod.day(DateTime(2026, 10, 3)),
    );
    expect(oct3['flour']!.productionQty, 1);
  });

  test('quantities in the material\'s current unit, through base units', () {
    // 500 g of sugar, saved with a Kg of 1000 g, is 0.5 Kg.
    final grams = usageRecord(
      uuid: 'g',
      createdAt: oct(2, 9),
      materialUuid: 'sugar',
      materialName: 'Sugar',
      quantity: 500,
      unitUuid: 'sugar-g',
      units: [
        prodUnit('sugar-kg', 'Kg', conversion: 1000, productUuid: 'sugar'),
        prodUnit('sugar-g', 'g', isPrimary: false, productUuid: 'sugar'),
      ],
      totalCost: 200,
      originalCostPerItem: 0.4,
    );
    // The material's current units: Kg is 1000 base units.
    final items = {
      'sugar': materialItems([
        material(
          uuid: 'sugar',
          name: 'Sugar',
          quantity: 9000,
          units: [prodUnit('sugar-kg', 'Kg', conversion: 1000, productUuid: 'sugar')],
          unit: 'Kg',
        ),
      ]).single,
    };
    final u = ProductionMaterialUsageBuilder.build(
      records: const [],
      usages: usageRows([grams]),
      period: day2,
      items: items,
      closingTime: six,
    )['sugar']!;
    expect(u.manualQty, closeTo(0.5, 1e-9));
    expect(u.unitCosts.single.$2, closeTo(400, 1e-9));
  });

  test('cost changes: first and last usage record of the period', () {
    final dearer = usageRecord(
      uuid: 'usage-6',
      createdAt: oct(2, 17),
      materialUuid: 'sugar',
      materialName: 'Sugar',
      quantity: 1,
      unitUuid: 'sugar-kg',
      units: sugarUnits(),
      totalCost: 450,
      originalCostPerItem: 450,
      staffUuid: staffBen,
    );
    final usage = usageOf(usages: [...sampleUsages(), dearer]);
    final changes = ProductionMaterialUsageBuilder.costChanges(usage);
    final sugar = changes.single;
    expect(sugar.key, 'sugar');
    expect(sugar.first, 400);
    expect(sugar.last, 450);
    expect(sugar.change, 50);
    expect(sugar.changePercent, closeTo(12.5, 1e-9));
    expect(sugar.records, 3);
    // Flour stayed at ₦5,000 a bag.
    expect(ProductionMaterialUsageBuilder.costChanges(usageOf()), isEmpty);
  });
}
