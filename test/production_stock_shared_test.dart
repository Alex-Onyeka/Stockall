import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/temp_production_folder/temp_materials_item_history/material_item_history_event_class.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_item_history/production_item_history_event_class.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_items/production_item.dart';
import 'package:stockall/pages/report/production_report/shared/class/production_report_access.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/production_stock_model.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

import 'production_report_fixtures.dart';

const six = TimeOfDay(hour: 6, minute: 0);
final day2 = ReceiptsReportPeriod.day(DateTime(2026, 10, 2));
final day3 = ReceiptsReportPeriod.day(DateTime(2026, 10, 3));

ProductionStockEntry entry(String uuid) =>
    stockEntries().firstWhere((e) => e.uuid == uuid);

ProductionStockItem donut() =>
    stockItems().firstWhere((i) => i.uuid == 'donut');

ProductionStockEntry produced({
  required String? event,
  String title = 'x',
  String? destination,
  String? desc,
}) => ProductionStockEntry.fromProducedHistory(
  stockRecord(
    uuid: 'e',
    title: title,
    event: event,
    createdAt: oct(2),
    destination: destination,
    desc: desc,
  ),
);

ProductionStockEntry used({required String? event, String? destination}) =>
    ProductionStockEntry.fromMaterialHistory(
      materialHistory(
        title: 'x',
        event: event,
        createdAt: oct(2),
        destination: destination,
      ),
    );

void main() {
  group('item adapters, both kinds', () {
    test('a produced item: primary unit, stock and cost', () {
      final d = donut();
      expect(d.kind, ProductionStockKind.producedItem);
      expect(d.primaryUnit, 'Pcs');
      expect(d.primaryQty, 15);
      expect(d.primaryCost, 200);
      expect(d.categoryUuids, [catPastry]);
      expect(d.conversionOf('Box'), 12);
      expect(d.conversionOf('pcs'), 1);
      expect(d.conversionOf('Tray'), isNull);
    });

    test('a material: Alex\'s flour, one bag left', () {
      final f = ProductionStockItem.fromMaterial(AlexExample().flour);
      expect(f.kind, ProductionStockKind.material);
      expect(f.primaryUnit, 'Bag');
      expect(f.primaryQty, 1);
      expect(f.primaryCost, AlexExample.bagCost);
    });

    test('a legacy group unit converts', () {
      final bread = ProductionStockItem.fromProducedItem(
        ProductionItem(
          uuid: 'bread',
          name: 'Bread',
          unit: 'Pcs',
          costPrice: 10,
          shopId: testShopId,
          departmentName: null,
          departmentUuid: null,
          isManaged: true,
          groupUnit: 'Crate',
          qttyPerGroup: 20,
          categories: null,
          useGroupUnit: true,
          unitsList: null,
          categoryUuid: catDrinks,
        ),
      );
      expect(bread.primaryUnit, 'Pcs');
      expect(bread.conversionOf('Crate'), 20);
      expect(bread.conversionOf('Pcs'), 1);
      expect(bread.categoryUuids, [catDrinks]);
    });

    test('unmanaged: no stock', () {
      final juice = stockItems().firstWhere((i) => i.uuid == 'juice-base');
      expect(juice.primaryQty, isNull);
      expect(juice.primaryUnit, 'Litre');
    });
  });

  group('movement kinds', () {
    test('produced items, every event', () {
      expect(
        produced(
          event: ProductionItemHistoryEventClass.productionCreated,
        ).movement,
        ProductionMovementKind.produced,
      );
      expect(
        produced(
          event: ProductionItemHistoryEventClass.productionDeleted,
        ).movement,
        ProductionMovementKind.productionDeleted,
      );
      expect(
        produced(
          event: ProductionItemHistoryEventClass.transferedOut,
          destination: ProductionItemHistoryEventClass.productDestination,
        ).movement,
        ProductionMovementKind.transferredToSales,
      );
      expect(
        produced(
          event: ProductionItemHistoryEventClass.transferedOut,
          destination: ProductionItemHistoryEventClass.branchStoreDestination,
        ).movement,
        ProductionMovementKind.transferredToBranch,
      );
      expect(
        produced(event: ProductionItemHistoryEventClass.transferedIn).movement,
        ProductionMovementKind.transferredIn,
      );
      expect(
        produced(
          event: ProductionItemHistoryEventClass.quantityUpdatedIncrease,
        ).movement,
        ProductionMovementKind.adjustedUp,
      );
      expect(
        produced(
          event: ProductionItemHistoryEventClass.quantityUpdatedDecrease,
        ).movement,
        ProductionMovementKind.adjustedDown,
      );
      expect(
        produced(event: ProductionItemHistoryEventClass.itemCreated).movement,
        ProductionMovementKind.created,
      );
      expect(
        produced(event: ProductionItemHistoryEventClass.itemDeleted).movement,
        ProductionMovementKind.deleted,
      );
      expect(
        produced(event: 'something_new').movement,
        ProductionMovementKind.other,
      );
    });

    test('legacy records through eventOf, and the branch fallback', () {
      // No event: the title decides.
      expect(
        entry('ch-1').event,
        ProductionItemHistoryEventClass.productionCreated,
      );
      expect(entry('ch-1').movement, ProductionMovementKind.produced);
      // No destination: "Shop Name:" in the description means a branch.
      expect(
        entry('ch-2').movement,
        ProductionMovementKind.transferredToBranch,
      );
      expect(
        produced(event: null, title: 'Transferred Out').movement,
        ProductionMovementKind.transferredToSales,
      );
    });

    test('materials, every event', () {
      expect(
        used(event: MaterialItemHistoryEventClass.usageCreated).movement,
        ProductionMovementKind.used,
      );
      // Legacy productions wrote production_created on the material.
      expect(
        used(event: MaterialItemHistoryEventClass.productionCreated).movement,
        ProductionMovementKind.used,
      );
      expect(
        used(event: MaterialItemHistoryEventClass.usageDeleted).movement,
        ProductionMovementKind.restored,
      );
      expect(
        used(event: MaterialItemHistoryEventClass.productionDeleted).movement,
        ProductionMovementKind.restored,
      );
      expect(
        used(
          event: MaterialItemHistoryEventClass.transferedOut,
          destination: MaterialItemHistoryEventClass.departmentDestination,
        ).movement,
        ProductionMovementKind.transferredToDepartment,
      );
      expect(
        used(
          event: MaterialItemHistoryEventClass.transferedOut,
          destination: MaterialItemHistoryEventClass.branchStoreDestination,
        ).movement,
        ProductionMovementKind.transferredToBranch,
      );
      expect(
        used(event: MaterialItemHistoryEventClass.transferedIn).movement,
        ProductionMovementKind.transferredIn,
      );
      final legacy = ProductionStockEntry.fromMaterialHistory(
        materialHistory(title: 'Material Used', event: null, createdAt: oct(2)),
      );
      expect(legacy.movement, ProductionMovementKind.used);
    });

    test('additions and reductions', () {
      expect(ProductionMovementKind.produced.isAddition, isTrue);
      expect(ProductionMovementKind.restored.isAddition, isTrue);
      expect(ProductionMovementKind.transferredToSales.isReduction, isTrue);
      expect(ProductionMovementKind.used.isReduction, isTrue);
      expect(ProductionMovementKind.created.isQuantityEvent, isFalse);
    });

    test('event labels', () {
      expect(productionStockEventLabel(entry('ph-1')), 'Produced');
      expect(
        productionStockEventLabel(produced(event: 'some_event')),
        'Some Event',
      );
      expect(productionStockPlaceLabel('branch_store'), 'Branch Store');
      expect(productionStockPlaceLabel('not_set'), '—');
    });
  });

  group('normaliser', () {
    test('old/new difference in the primary unit', () {
      expect(ProductionStockNormaliser.quantity(entry('ph-1'), donut()), 30);
      expect(ProductionStockNormaliser.quantity(entry('ph-2'), donut()), 15);
    });

    test('an old primary unit: the change converted from its unit', () {
      // +2 Box, written when the primary unit was "Dozen": 24 Pcs.
      expect(ProductionStockNormaliser.quantity(entry('ph-3'), donut()), 24);
    });

    test('an unknown unit can\'t be converted', () {
      expect(
        ProductionStockNormaliser.quantity(entry('ph-4'), donut()),
        isNull,
      );
    });

    test('no stock moved, and a deleted item', () {
      expect(
        ProductionStockNormaliser.quantity(
          produced(event: ProductionItemHistoryEventClass.itemCreated),
          donut(),
        ),
        0,
      );
      expect(ProductionStockNormaliser.quantity(entry('mh-gone'), null), 12);
    });

    test('totals count unconverted records apart', () {
      final t = ProductionMovementTotals();
      t.add(ProductionMovementKind.produced, 30);
      t.add(ProductionMovementKind.transferredToSales, 15);
      t.add(ProductionMovementKind.adjustedUp, null);
      t.add(ProductionMovementKind.created, 0);
      expect(t.additions, 30);
      expect(t.reductions, 15);
      expect(t.net, 15);
      expect(t.netProduced, 30);
      expect(t.notNormalised, 1);
      expect(t.movementCount, 3);
      expect(t.eventCount, 4);
    });
  });

  group('balances', () {
    List<ProductionStockEntry> donutEntries() =>
        stockEntries().where((e) => e.itemUuid == 'donut').toList();

    ProductionStockBalance balance(
      ReceiptsReportPeriod p, {
      ProductionStockItem? item,
    }) => ProductionStockMovementCalculator.balance(
      item: item ?? donut(),
      entries: donutEntries(),
      period: p,
      closingTime: six,
    );

    test("Alex's donuts on 2 Oct: 0 → 15", () {
      final b = balance(day2);
      expect(b.opening, 0);
      expect(b.closing, 15);
      expect(b.change, 15);
      final t = ProductionStockMovementCalculator.totals(
        item: donut(),
        entries: donutEntries(),
        period: day2,
        closingTime: six,
      );
      expect(t.of(ProductionMovementKind.produced), 30);
      expect(t.of(ProductionMovementKind.transferredToSales), 15);
      expect(t.net, 15);
    });

    test('records in another primary unit are skipped for the balance', () {
      final b = balance(day3);
      expect(b.opening, 15);
      expect(b.closing, 15);
    });

    test('after the last record and all time', () {
      final later = balance(ReceiptsReportPeriod.day(DateTime(2026, 10, 9)));
      expect(later.opening, 15);
      expect(later.closing, 15);
      final all = balance(const ReceiptsReportPeriod.allTime());
      expect(all.opening, 0);
      expect(all.closing, 15);
    });

    test('unmanaged: no balance; created in the period: opens at 0', () {
      final juice = stockItems().firstWhere((i) => i.uuid == 'juice-base');
      expect(balance(day2, item: juice).opening, isNull);
      final fresh = ProductionStockItem.fromProducedItem(
        producedItem(uuid: 'fresh', quantity: 4, createdAt: oct(2, 8)),
      );
      final b = ProductionStockMovementCalculator.balance(
        item: fresh,
        entries: const [],
        period: day2,
        closingTime: six,
      );
      expect(b.opening, 0);
      expect(b.closing, 0);
      final before = ProductionStockMovementCalculator.balance(
        item: fresh,
        entries: const [],
        period: day3,
        closingTime: six,
      );
      expect(before.opening, 4);
    });

    test('materials: one bag of flour used on 2 Oct', () {
      final alex = AlexExample();
      final flour = ProductionStockItem.fromMaterial(alex.flour);
      final entries = [
        for (final h in alex.flourHistory)
          ProductionStockEntry.fromMaterialHistory(h),
      ];
      final b = ProductionStockMovementCalculator.balance(
        item: flour,
        entries: entries,
        period: day2,
        closingTime: six,
      );
      expect(b.opening, 2);
      expect(b.closing, 1);
      final t = ProductionStockMovementCalculator.totals(
        item: flour,
        entries: entries,
        period: day2,
        closingTime: six,
      );
      expect(t.of(ProductionMovementKind.used), 1);
    });
  });

  group('scope', () {
    List<String> scoped({
      required bool departments,
      required bool viewAll,
      String? current,
    }) => [
      for (final i in ProductionReportAccess.scopeStock(
        records: stockItems(),
        departmentOf: (i) => i.departmentUuid,
        departmentsEnabled: departments,
        canViewAllDepartments: viewAll,
        currentDepartmentUuid: current,
      ))
        i.uuid,
    ];

    test('the produced-items list rule', () {
      expect(scoped(departments: false, viewAll: false), hasLength(3));
      expect(scoped(departments: true, viewAll: true), hasLength(3));
      // Items with no department stay visible.
      expect(scoped(departments: true, viewAll: false, current: deptBakery), [
        'donut',
        'juice-base',
      ]);
      expect(scoped(departments: true, viewAll: true, current: deptKitchen), [
        'juice-base',
        'cake',
      ]);
    });
  });

  test('notes', () {
    final kind = ProductionStockKind.producedItem;
    expect(
      productionStockNotes(
        kind: kind,
        page: ProductionStockReportPage.items,
        period: const ReceiptsReportPeriod.allTime(),
        historyAllowed: true,
        notNormalised: 1,
      ),
      [
        'All time covers the history loaded on this device.',
        "1 history record couldn't be converted to the produced item's unit "
            'and is counted without a quantity.',
      ],
    );
    expect(
      productionStockNotes(
        kind: kind,
        page: ProductionStockReportPage.items,
        period: day2,
        historyAllowed: false,
      ),
      ['Period movement needs access to item history.'],
    );
    expect(
      productionStockNotes(
        kind: kind,
        page: ProductionStockReportPage.analysis,
        period: day2,
        historyAllowed: true,
      ).single,
      contains('approximate'),
    );
  });

  test('quantities by unit are never added across units', () {
    expect(
      productionQuantitiesByUnit({'Pcs': 45, 'Kg': 3, 'Litre': 0}, (v) => v.toStringAsFixed(0)),
      '3 Kg, 45 Pcs',
    );
    expect(productionQuantitiesByUnit({}, (v) => v.toStringAsFixed(0)), '0');
  });
}
