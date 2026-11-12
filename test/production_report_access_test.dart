import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/pages/report/production_report/class/production_report_hub_logic.dart';
import 'package:stockall/pages/report/production_report/shared/class/production_report_access.dart';

import 'production_report_fixtures.dart';

void main() {
  group('ProductionReportAccess.scopeRecords', () {
    List<String> scoped({
      required bool departmentsEnabled,
      bool canViewAllDepartments = true,
      String? currentDepartmentUuid,
      bool canViewAllTransactions = true,
      String? currentUserId = staffAda,
    }) {
      return ProductionReportAccess.scopeRecords(
        records: scopeRecords(),
        departmentsEnabled: departmentsEnabled,
        canViewAllDepartments: canViewAllDepartments,
        currentDepartmentUuid: currentDepartmentUuid,
        canViewAllTransactions: canViewAllTransactions,
        currentUserId: currentUserId,
      ).map((r) => r.uuid!).toList();
    }

    test('departments off: everything, or only own records', () {
      expect(scoped(departmentsEnabled: false), [
        'prod-1',
        'prod-2',
        'prod-3',
        'prod-4',
      ]);
      // A current department is ignored when departments are off.
      expect(
        scoped(departmentsEnabled: false, currentDepartmentUuid: deptBakery),
        ['prod-1', 'prod-2', 'prod-3', 'prod-4'],
      );
      expect(
        scoped(departmentsEnabled: false, canViewAllTransactions: false),
        ['prod-1', 'prod-3'],
      );
    });

    test('departments on, all departments, no current department: all', () {
      expect(scoped(departmentsEnabled: true), [
        'prod-1',
        'prod-2',
        'prod-3',
        'prod-4',
      ]);
    });

    test('departments on with a current department: that department', () {
      expect(
        scoped(departmentsEnabled: true, currentDepartmentUuid: deptBakery),
        ['prod-1', 'prod-2'],
      );
      expect(
        scoped(
          departmentsEnabled: true,
          canViewAllDepartments: false,
          currentDepartmentUuid: deptKitchen,
        ),
        ['prod-3'],
      );
    });

    test('departments on, not all departments, no current department: '
        'only records without a department', () {
      expect(
        scoped(departmentsEnabled: true, canViewAllDepartments: false),
        ['prod-4'],
      );
    });

    test('department and own-records restrictions combine', () {
      expect(
        scoped(
          departmentsEnabled: true,
          currentDepartmentUuid: deptBakery,
          canViewAllTransactions: false,
        ),
        ['prod-1'],
      );
      expect(
        scoped(
          departmentsEnabled: true,
          currentDepartmentUuid: deptBakery,
          canViewAllTransactions: false,
          currentUserId: staffBen,
        ),
        ['prod-2'],
      );
    });

    test('no signed-in user without all transactions sees nothing', () {
      expect(
        scoped(
          departmentsEnabled: false,
          canViewAllTransactions: false,
          currentUserId: null,
        ),
        isEmpty,
      );
    });
  });

  group('ProductionReportAccess.scopeUsages', () {
    test('uses the usage department and staff fields', () {
      List<String> scoped({
        required bool departmentsEnabled,
        String? currentDepartmentUuid,
        bool canViewAllTransactions = true,
      }) => ProductionReportAccess.scopeUsages(
        usages: scopeUsages(),
        departmentsEnabled: departmentsEnabled,
        canViewAllDepartments: true,
        currentDepartmentUuid: currentDepartmentUuid,
        canViewAllTransactions: canViewAllTransactions,
        currentUserId: staffAda,
      ).map((u) => u.uuid).toList();

      expect(scoped(departmentsEnabled: false), [
        'usage-1',
        'usage-2',
        'usage-3',
        'usage-4',
      ]);
      expect(
        scoped(departmentsEnabled: true, currentDepartmentUuid: deptBakery),
        ['usage-1', 'usage-2'],
      );
      expect(
        scoped(departmentsEnabled: false, canViewAllTransactions: false),
        ['usage-1', 'usage-3'],
      );
      expect(
        scoped(
          departmentsEnabled: true,
          currentDepartmentUuid: deptKitchen,
          canViewAllTransactions: false,
        ),
        ['usage-3'],
      );
    });
  });

  group("Alex's example: units and costs", () {
    final example = AlexExample();

    test('production record cost figures', () {
      final r = example.record;
      expect(ProductionReportCosts.materialCost(r), 5000);
      expect(ProductionReportCosts.recordedCost(r), 5000);
      expect(ProductionReportCosts.costVariance(r), 0);
      expect(
        ProductionReportCosts.costPerUnitProduced(r),
        closeTo(166.67, 0.01),
      );
      expect(
        ProductionReportCosts.costSource(r),
        ProductionCostSource.materials,
      );
      expect(
        ProductionReportCosts.outputType(r, manageProductionItems: false),
        ProductionOutputType.producedItem,
      );
    });

    test('quantities in primary units', () {
      expect(ProductionReportUnits.recordPrimaryQty(example.record), 30);
      expect(
        ProductionReportUnits.materialLinePrimaryQty(
          example.record.materials.single,
        ),
        1,
      );
      expect(ProductionReportUnits.usagePrimaryQty(example.usage), 1);
      expect(
        ProductionReportUnits.stockPrimaryQty(
          example.flour.quantity,
          example.flour.unitsList,
        ),
        1,
      );
      expect(
        ProductionReportUnits.stockPrimaryQty(
          example.donut.quantity,
          example.donut.unitsList,
        ),
        15,
      );
      expect(
        ProductionReportUnits.primaryUnitName(
          example.donut.unitsList,
          unit: example.donut.unit,
        ),
        'Pcs',
      );
    });

    test('the usage is linked to the production and costs one bag', () {
      expect(ProductionReportCosts.isProductionUsage(example.usage), isTrue);
      expect(example.usage.productionRecordUuid, example.record.uuid);
      expect(ProductionReportCosts.usageCost(example.usage), 5000);
      expect(ProductionReportCosts.usageUnitCost(example.usage), 5000);
    });

    test('stock values at cost', () {
      expect(
        ProductionReportCosts.stockValue(
          example.flour.quantity,
          example.flour.costPrice,
        ),
        5000,
      );
      expect(
        ProductionReportCosts.stockValue(
          example.donut.quantity,
          example.donut.costPrice,
        ),
        3000,
      );
    });

    test('history and sales sides of the example', () {
      expect(
        example.flourHistory.map((h) => h.quantityChange).toList(),
        [2, -1],
      );
      expect(
        example.donutHistory.map((h) => h.quantityChange).toList(),
        [30, -15],
      );
      expect(example.salesHistory.single.quantityChange, 15);
      expect(example.salesHistory.single.source, 'production');
    });
  });

  group('ProductionReportUnits', () {
    test('a record in boxes converts to pieces', () {
      final r = productionRecord(
        createdAt: oct(3),
        quantity: 3,
        unitUuid: 'donut-box',
        units: donutUnits(),
        totalCost: 7200,
      );
      expect(ProductionReportUnits.recordPrimaryQty(r), 36);
      expect(ProductionReportCosts.costPerUnitProduced(r), 200);
    });

    test('a primary unit bigger than the base unit', () {
      final units = [prodUnit('dozen', 'Dozen', conversion: 12)];
      expect(ProductionReportUnits.primaryConversion(units), 12);
      expect(ProductionReportUnits.stockPrimaryQty(24, units), 2);
      expect(ProductionReportUnits.primaryCostPrice(10, units), 120);
      expect(ProductionReportCosts.stockValue(24, 10), 240);
    });

    test('legacy records with no unit snapshot use the group fields', () {
      final r = productionRecord(
        createdAt: oct(3),
        quantity: 2,
        unitUuid: null,
        units: null,
        useGroupQuantity: true,
        qttyPerGroup: 12,
        groupUnit: 'Box',
        unit: 'Pcs',
        totalCost: 4800,
      );
      expect(ProductionReportUnits.primaryConversion(null), 1);
      expect(ProductionReportUnits.recordPrimaryQty(r), 24);
      expect(ProductionReportCosts.costPerUnitProduced(r), 200);
    });

    test('legacy primary unit names', () {
      expect(ProductionReportUnits.primaryUnitName(null, unit: 'Kg'), 'Kg');
      expect(
        ProductionReportUnits.primaryUnitName(null, unit: 'Others'),
        'Unit(s)',
      );
      expect(ProductionReportUnits.primaryUnitName(null, unit: null), 'Unit(s)');
      expect(ProductionReportUnits.primaryUnitName([], unit: '  '), 'Unit(s)');
    });

    test('missing stock counts as zero', () {
      expect(ProductionReportUnits.stockPrimaryQty(null, flourUnits()), 0);
      expect(ProductionReportCosts.stockValue(null, 5000), 0);
    });
  });

  group('ProductionReportCosts', () {
    test('a saved custom cost wins whatever option was selected', () {
      final r = productionRecord(
        createdAt: oct(3),
        quantity: 30,
        units: donutUnits(),
        totalCost: 5000,
        customCost: 6000,
        selectedCostPriceOption: 2,
        materials: AlexExample().record.materials,
      );
      expect(ProductionReportCosts.recordedCost(r), 6000);
      expect(ProductionReportCosts.materialCost(r), 5000);
      expect(ProductionReportCosts.costVariance(r), 1000);
      expect(
        ProductionReportCosts.costSource(r),
        ProductionCostSource.custom,
      );
    });

    test('cost source from the selected option', () {
      ProductionCostSource source(int? option) => ProductionReportCosts
          .costSource(
            productionRecord(
              createdAt: oct(3),
              quantity: 1,
              selectedCostPriceOption: option,
            ),
          );
      expect(source(1), ProductionCostSource.itemCost);
      expect(source(2), ProductionCostSource.materials);
      expect(source(null), ProductionCostSource.unknown);
      expect(source(3), ProductionCostSource.unknown);
    });

    test('material cost uses each line custom cost when set', () {
      final r = productionRecord(
        createdAt: oct(3),
        quantity: 10,
        materials: [
          materialLine(
            uuid: 'a',
            quantity: 1,
            unitUuid: 'flour-bag',
            units: flourUnits(),
            totalCost: 5000,
            customCost: 4500,
          ),
          materialLine(
            uuid: 'b',
            materialUuid: 'sugar',
            materialName: 'Sugar',
            quantity: 2,
            unitUuid: null,
            units: null,
            totalCost: 800,
          ),
        ],
        totalCost: 5300,
      );
      expect(ProductionReportCosts.materialCost(r), 5300);
    });

    test('nothing produced has no cost per unit', () {
      final r = productionRecord(createdAt: oct(3), quantity: 0, totalCost: 100);
      expect(ProductionReportCosts.costPerUnitProduced(r), isNull);
    });

    test('usage cost prefers the custom cost', () {
      final u = usageRecord(
        createdAt: oct(3),
        quantity: 1,
        totalCost: 5000,
        customCost: 4000,
      );
      expect(ProductionReportCosts.usageCost(u), 4000);
    });

    test('manual usages are not production usages', () {
      expect(
        ProductionReportCosts.isProductionUsage(
          usageRecord(createdAt: oct(3), quantity: 1),
        ),
        isFalse,
      );
      expect(
        ProductionReportCosts.isProductionUsage(
          usageRecord(
            createdAt: oct(3),
            quantity: 1,
            productionRecordUuid: '  ',
          ),
        ),
        isFalse,
      );
    });

    test('output type from the record ids, else the shop setting', () {
      ProductionOutputType type({
        String? itemUuid,
        String? salesItemUuid,
        required bool manage,
      }) => ProductionReportCosts.outputType(
        productionRecord(
          createdAt: oct(3),
          quantity: 1,
          itemUuid: itemUuid,
          salesItemUuid: salesItemUuid,
        ),
        manageProductionItems: manage,
      );
      expect(
        type(salesItemUuid: 'cola', manage: true),
        ProductionOutputType.salesItem,
      );
      expect(
        type(itemUuid: 'donut', manage: false),
        ProductionOutputType.producedItem,
      );
      expect(type(manage: true), ProductionOutputType.producedItem);
      expect(type(manage: false), ProductionOutputType.salesItem);
      expect(
        type(itemUuid: 'donut', salesItemUuid: 'cola', manage: false),
        ProductionOutputType.salesItem,
      );
    });
  });

  group('ProductionReportHub', () {
    List<ProductionReportPageId> ids(List<ProductionReportGroup> groups) => [
      for (final g in groups) ...g.entries.map((e) => e.id),
    ];

    test('every page is listed once', () {
      final all = ids(ProductionReportHub.allGroups);
      expect(all.toSet(), ProductionReportPageId.values.toSet());
      expect(all.length, ProductionReportPageId.values.length);
    });

    test('everything allowed: four groups in the brief order, 12 pages', () {
      final groups = ProductionReportHub.groups(
        historyAllowed: true,
        producedItemsEnabled: true,
      );
      expect(groups.map((g) => g.id).toList(), [
        ProductionReportGroupId.materials,
        ProductionReportGroupId.materialUsage,
        ProductionReportGroupId.producedItems,
        ProductionReportGroupId.productionRecords,
      ]);
      expect(ids(groups).length, 12);
      expect(groups.map((g) => g.entries.length).toList(), [4, 2, 4, 2]);
    });

    test('without history access the history pages are left out', () {
      final groups = ProductionReportHub.groups(
        historyAllowed: false,
        producedItemsEnabled: true,
      );
      final listed = ids(groups);
      expect(listed.length, 8);
      expect(
        listed,
        isNot(
          anyOf(
            contains(ProductionReportPageId.materialHistoryTable),
            contains(ProductionReportPageId.materialHistorySummary),
            contains(ProductionReportPageId.producedItemHistoryTable),
            contains(ProductionReportPageId.producedItemHistorySummary),
          ),
        ),
      );
      expect(
        groups.expand((g) => g.entries).any((e) => e.isHistory),
        isFalse,
      );
    });

    test('without production items the Produced Items group is hidden', () {
      final groups = ProductionReportHub.groups(
        historyAllowed: true,
        producedItemsEnabled: false,
      );
      expect(groups.map((g) => g.id).toList(), [
        ProductionReportGroupId.materials,
        ProductionReportGroupId.materialUsage,
        ProductionReportGroupId.productionRecords,
      ]);
      expect(ids(groups).length, 8);
    });

    test('the four history pages are the only history entries', () {
      final history =
          ProductionReportHub.allGroups
              .expand((g) => g.entries)
              .where((e) => e.isHistory)
              .map((e) => e.id)
              .toSet();
      expect(history, {
        ProductionReportPageId.materialHistoryTable,
        ProductionReportPageId.materialHistorySummary,
        ProductionReportPageId.producedItemHistoryTable,
        ProductionReportPageId.producedItemHistorySummary,
      });
    });

    test('the tile needs the setting, the plan and the permission', () {
      for (final setting in [true, false]) {
        for (final plan in [true, false]) {
          for (final permission in [true, false]) {
            expect(
              ProductionReportHub.tileVisible(
                manageProductions: setting,
                planAllowsProductions: plan,
                canViewProductions: permission,
              ),
              setting && plan && permission,
              reason: 'setting $setting, plan $plan, permission $permission',
            );
          }
        }
      }
    });

    test('categories show Production Items Report only when enabled', () {
      final enabled = ProductionReportHub.categories(
        producedItemsEnabled: true,
      );
      expect(enabled.map((c) => c.id).toList(), [
        ProductionReportCategoryId.materials,
        ProductionReportCategoryId.productionRecords,
        ProductionReportCategoryId.productionItems,
      ]);

      final disabled = ProductionReportHub.categories(
        producedItemsEnabled: false,
      );
      expect(disabled.map((c) => c.id).toList(), [
        ProductionReportCategoryId.materials,
        ProductionReportCategoryId.productionRecords,
      ]);
    });

    test('groupsForCategory splits materials, production records and items', () {
      final cats = ProductionReportHub.categories(
        producedItemsEnabled: true,
      );
      final materialsGroups = ProductionReportHub.groupsForCategory(
        category: cats[0],
        historyAllowed: true,
        producedItemsEnabled: true,
      );
      expect(materialsGroups.map((g) => g.id).toList(), [
        ProductionReportGroupId.materials,
        ProductionReportGroupId.materialUsage,
      ]);

      final recordsGroups = ProductionReportHub.groupsForCategory(
        category: cats[1],
        historyAllowed: true,
        producedItemsEnabled: true,
      );
      expect(recordsGroups.map((g) => g.id).toList(), [
        ProductionReportGroupId.productionRecords,
      ]);

      final itemsGroups = ProductionReportHub.groupsForCategory(
        category: cats[2],
        historyAllowed: true,
        producedItemsEnabled: true,
      );
      expect(itemsGroups.map((g) => g.id).toList(), [
        ProductionReportGroupId.producedItems,
      ]);
    });
  });
}
