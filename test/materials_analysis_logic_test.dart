import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/temp_production_folder/temp_material_class/material_class.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_materials_usage/production_materials_usage.dart';
import 'package:stockall/classes/temp_production_folder/temp_productions/production_record.dart';
import 'package:stockall/pages/report/general_report/class/general_report_logic.dart';
import 'package:stockall/pages/report/production_report/production_records_table/class/production_records_table_logic.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/material_usage_logic.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/production_stock_model.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/stock_analysis_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

import 'materials_table_logic_test.dart' show materialRows;
import 'production_report_fixtures.dart';

const six = TimeOfDay(hour: 6, minute: 0);
final day2 = ReceiptsReportPeriod.day(DateTime(2026, 10, 2));

ProductionStockAnalysis materialAnalysis({
  ReceiptsReportPeriod? period,
  List<MaterialClass>? materials,
  List<ProductionRecord>? records,
  List<ProductionMaterialsUsage>? usages,
  bool departmentsEnabled = true,
  bool canSeeCost = true,
  bool canSeeQuantity = true,
}) {
  final p = period ?? day2;
  final previous = GeneralReportPeriods.previous(p);
  final items = materialItems(materials);
  return ProductionStockAnalysisBuilder.build(
    kind: ProductionStockKind.material,
    rows: materialRows(period: p, materials: materials, records: records, usages: usages),
    previousRows:
        previous == null
            ? null
            : materialRows(
              period: previous,
              materials: materials,
              records: records,
              usages: usages,
            ),
    records: recordRows(records ?? materialRecords()),
    period: p,
    businessNow: stockNow,
    departmentsEnabled: departmentsEnabled,
    canSeeCost: canSeeCost,
    canSeeQuantity: canSeeQuantity,
    historyAllowed: true,
    closingTime: six,
    allTimeUsage: ProductionMaterialUsageBuilder.build(
      records: recordRows(records ?? materialRecords()),
      usages: usageRows(usages ?? sampleUsages()),
      period: const ReceiptsReportPeriod.allTime(),
      items: {for (final i in items) i.uuid: i},
    ),
  );
}

String text(ProductionStockCard c) => c.valueText(
  (v) => 'N$v',
  (v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : '$v',
);

void main() {
  group('cards', () {
    final a = materialAnalysis();

    test('materials, value, low, out, expiring, used, usage cost', () {
      final cards = productionStockAnalysisCards(
        a,
        canSeeCost: true,
        canSeeQuantity: true,
        historyAllowed: true,
      );
      expect([for (final c in cards) c.id], [
        'items',
        'stockValue',
        'lowStock',
        'outOfStock',
        'expiring',
        'main',
        'usageCost',
      ]);
      String t(String id) => text(cards.firstWhere((c) => c.id == id));
      expect(t('items'), '3');
      expect(t('stockValue'), 'N8600.0');
      expect(t('lowStock'), '1');
      expect(t('outOfStock'), '1');
      expect(t('expiring'), '1');
      expect(t('main'), '3.25 Bag, 2.5 Kg');
      expect(t('usageCost'), 'N17250.0');
    });

    test('used: no comparison across units; usage cost always compares', () {
      final cards = productionStockAnalysisCards(
        a,
        canSeeCost: true,
        canSeeQuantity: true,
        historyAllowed: true,
      );
      final used = cards.firstWhere((c) => c.id == 'main');
      expect(used.change, isNull);
      expect(used.subtitle, 'Mixed units: no comparison');
      final cost = cards.firstWhere((c) => c.id == 'usageCost');
      // Nothing used the day before: an amount.
      expect(cost.change!.kind, GeneralReportChangeKind.amount);
      expect(cost.change!.value, 17250);
    });

    test('one unit: the used quantity compares with the previous day', () {
      final alex = AlexExample();
      final earlier = usageRecord(
        uuid: 'early',
        createdAt: oct(1, 10),
        quantity: 0.5,
        units: flourUnits(),
        totalCost: 2500,
        originalCostPerItem: 5000,
      );
      final one = materialAnalysis(
        materials: [alex.flour],
        records: [alex.record],
        usages: [alex.usage, earlier],
      );
      final cards = productionStockAnalysisCards(
        one,
        canSeeCost: true,
        canSeeQuantity: true,
        historyAllowed: true,
      );
      final used = cards.firstWhere((c) => c.id == 'main');
      expect(text(used), '1 Bag');
      expect(used.change!.isPercent, isTrue);
      expect(used.change!.value, 100);
      expect(cards.firstWhere((c) => c.id == 'usageCost').change!.value, 100);
    });

    test('masked and gated', () {
      final cards = productionStockAnalysisCards(
        a,
        canSeeCost: false,
        canSeeQuantity: false,
        historyAllowed: false,
      );
      expect([for (final c in cards) c.id], isNot(contains('usageCost')));
      expect(text(cards.firstWhere((c) => c.id == 'main')), '****');
      expect(text(cards.firstWhere((c) => c.id == 'lowStock')), '****');
    });
  });

  group('tabs', () {
    test('the material tabs and their gates', () {
      expect(materialAnalysis().tabs.keys, [
        ProductionStockAnalysisTab.usedQuantity,
        ProductionStockAnalysisTab.usedCost,
        ProductionStockAnalysisTab.unused,
        ProductionStockAnalysisTab.departments,
        ProductionStockAnalysisTab.categories,
        ProductionStockAnalysisTab.costChanges,
      ]);
      expect(
        materialAnalysis(canSeeCost: false, canSeeQuantity: false, departmentsEnabled: false)
            .tabs
            .keys,
        [ProductionStockAnalysisTab.unused, ProductionStockAnalysisTab.categories],
      );
    });

    test('most used by quantity and by cost', () {
      final a = materialAnalysis();
      final qty = a.tabs[ProductionStockAnalysisTab.usedQuantity]!;
      expect([for (final r in qty) r.key], ['flour', 'sugar']);
      expect(qty.first.valueOf(ProductionStockAnalysisField.usedProduction), 3);
      expect(qty.first.valueOf(ProductionStockAnalysisField.usedManual), 0.25);
      expect(qty.first.unitOf(ProductionStockAnalysisField.usedTotal), 'Bag');
      expect(qty.first.filters.itemKey, 'flour');
      final cost = a.tabs[ProductionStockAnalysisTab.usedCost]!;
      expect(cost.first.valueOf(ProductionStockAnalysisField.usageCost), 16250);
      expect(
        cost.first.valueOf(ProductionStockAnalysisField.share) as double,
        closeTo(16250 / 17250 * 100, 1e-9),
      );
    });

    test('unused in the period, with the last use ever', () {
      final unused = materialAnalysis().tabs[ProductionStockAnalysisTab.unused]!;
      expect([for (final r in unused) r.key], ['yeast']);
      expect(unused.single.valueOf(ProductionStockAnalysisField.lastUsed), isNull);
      final oct3 = materialAnalysis(
        period: ReceiptsReportPeriod.day(DateTime(2026, 10, 3)),
      ).tabs[ProductionStockAnalysisTab.unused]!;
      final flour = oct3.firstWhere((r) => r.key == 'flour');
      expect(flour.valueOf(ProductionStockAnalysisField.lastUsed), oct(2, 16));
    });

    test('cost changes from the usage records', () {
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
      );
      final rows = materialAnalysis(
        usages: [...sampleUsages(), dearer],
      ).tabs[ProductionStockAnalysisTab.costChanges]!;
      final sugar = rows.single;
      expect(sugar.valueOf(ProductionStockAnalysisField.firstUnitCost), 400);
      expect(sugar.valueOf(ProductionStockAnalysisField.lastUnitCost), 450);
      expect(sugar.valueOf(ProductionStockAnalysisField.costChangePercent), 12.5);
      expect(sugar.filters.itemKey, 'sugar');
    });

    test('distribution, with the none row last', () {
      final depts = materialAnalysis().tabs[ProductionStockAnalysisTab.departments]!;
      expect(depts.last.label, productionNoDepartmentLabel);
      expect(depts.last.filters.departmentKey, productionReportNoneKey);
    });
  });

  test('the notes say where use and cost changes come from', () {
    final notes = productionStockNotes(
      kind: ProductionStockKind.material,
      page: ProductionStockReportPage.analysis,
      period: day2,
      historyAllowed: false,
    );
    expect(notes, hasLength(2));
    expect(notes.first, contains('production records'));
    expect(notes.last, startsWith('Cost changes come from usage records'));
  });
}
