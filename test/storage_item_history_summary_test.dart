import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/temp_product_class/units_class/product_units_class.dart';
import 'package:stockall/classes/temp_storage_item_history/storage_item_history.dart';
import 'package:stockall/classes/temp_storage_item_history/storage_item_history_event_class.dart';
import 'package:stockall/classes/temp_storage_product/temp_storage_products.dart';
import 'package:stockall/pages/report/storage_items_report_/storage_item_history_report/class/storage_item_history_report_logic.dart';
import 'package:stockall/pages/report/storage_items_report_/storage_item_history_summary/class/storage_item_history_summary_logic.dart';
import 'package:stockall/pages/report/storage_items_report_/storage_item_history_summary/storage_item_history_summary_page.dart';

ProductUnitsClass unit(
  String name, {
  double conversion = 1,
  int? dimensionType,
  bool isPrimary = true,
}) {
  return ProductUnitsClass(
    uuid: name,
    staffUuid: null,
    createdAt: DateTime.utc(2026),
    staffName: null,
    conversion: conversion,
    name: name,
    isPrimary: isPrimary,
    productUuid: 'storage',
    dimensionType: dimensionType,
  );
}

TempStorageProducts storageItem({
  required String uuid,
  required String name,
  required double? quantity,
  required List<ProductUnitsClass> units,
  int quantityType = 1,
  double? width,
  double? height,
  DateTime? createdAt,
}) {
  return TempStorageProducts(
    uuid: uuid,
    shopId: 1,
    name: name,
    quantity: quantity,
    costPrice: null,
    sellingPrice: null,
    useGroupUnit: false,
    unitsList: units,
    quantityType: quantityType,
    widthDimension: width,
    heightDimension: height,
    createdAt: createdAt ?? DateTime(2026, 10, 1),
  );
}

StorageItemHistory record({
  required String uuid,
  required String storageItemUuid,
  required String event,
  required DateTime createdAt,
  String storageItemName = 'Flour Store',
  String? oldValue,
  String? newValue,
  double? quantityChange,
  String? storageUnit,
  String? storagePrimaryUnit,
  bool? isIncreased,
  String? storageStaffId = 'keeper-1',
  String? storageStaffName = 'Ada Keeper',
  String? salesItemUuid,
  String? salesItemName,
  String? salesDepartmentUuid,
  String? salesDepartmentName,
  String? salesStaffUuid,
  String? salesStaffName,
}) {
  return StorageItemHistory(
    uuid: uuid,
    createdAt: createdAt,
    shopId: 1,
    title: event,
    storageItemName: storageItemName,
    storageItemUuid: storageItemUuid,
    storageItemOldValue: oldValue,
    storageItemNewValue: newValue,
    storageStaffId: storageStaffId,
    storageStaffName: storageStaffName,
    quantityChange: quantityChange,
    desc: null,
    isIncreased: isIncreased,
    storageUnit: storageUnit,
    storagePrimaryUnit: storagePrimaryUnit,
    salesItemUuid: salesItemUuid,
    salesItemName: salesItemName,
    salesDepartmentUuid: salesDepartmentUuid,
    salesDepartmentName: salesDepartmentName,
    salesStaffUuid: salesStaffUuid,
    salesStaffName: salesStaffName,
    event: event,
    source: null,
  );
}

DateTime oct(int day, int hour, [int minute = 0]) =>
    DateTime(2026, 10, day, hour, minute);

void main() {
  final businessNow = DateTime(2026, 10, 20, 16);

  // 1D, primary Pcs, plus a 12-piece carton. Renamed since its history.
  final flour = storageItem(
    uuid: 'flour',
    name: 'Flour Store 50kg',
    quantity: 15,
    units: [
      unit('Pcs'),
      unit('Carton', conversion: 12, isPrimary: false),
    ],
  );
  // 2D, 2 x 3 sheets, with an area unit.
  final glass = storageItem(
    uuid: 'glass',
    name: 'Glass Store',
    quantity: 2.5,
    quantityType: 2,
    width: 2,
    height: 3,
    units: [
      unit('sheet', dimensionType: ProductUnitsClass.sheetUnit),
      unit(
        'sqm',
        dimensionType: ProductUnitsClass.areaUnit,
        isPrimary: false,
      ),
    ],
  );
  final salt = storageItem(
    uuid: 'salt',
    name: 'Salt Store',
    quantity: 0,
    units: [unit('Kg')],
  );
  final rice = storageItem(
    uuid: 'rice',
    name: 'Rice Store',
    quantity: 8,
    units: [unit('Bags')],
  );
  final storageProducts = [flour, glass, salt, rice];

  // Every writer shape found on main.
  final histories = <StorageItemHistory>[
    // Created: '0' -> '0', unit 'Not Set', no primary unit.
    record(
      uuid: 'f-created',
      storageItemUuid: 'flour',
      event: 'created',
      createdAt: oct(18, 9),
      oldValue: '0',
      newValue: '0',
      quantityChange: 0,
      storageUnit: 'Not Set',
    ),
    // Manual stock-in, yesterday.
    record(
      uuid: 'f-in',
      storageItemUuid: 'flour',
      event: 'stock_in',
      createdAt: oct(19, 10),
      oldValue: '0',
      newValue: '20',
      quantityChange: 20,
      storageUnit: 'Pcs',
      storagePrimaryUnit: 'Pcs',
      isIncreased: true,
    ),
    // Transfer to a sales item.
    record(
      uuid: 'f-out',
      storageItemUuid: 'flour',
      event: 'stock_out',
      createdAt: oct(20, 10),
      oldValue: '20',
      newValue: '15',
      quantityChange: -5,
      storageUnit: 'Pcs',
      storagePrimaryUnit: 'Pcs',
      isIncreased: false,
      salesItemUuid: 'bread',
      salesItemName: 'Bread',
      salesDepartmentUuid: 'bakery',
      salesDepartmentName: 'Bakery',
      salesStaffUuid: 'other-1',
      salesStaffName: 'Bola Baker',
    ),
    // Return: storageUnit holds the sales unit name.
    record(
      uuid: 'f-return',
      storageItemUuid: 'flour',
      event: 'return',
      createdAt: oct(20, 11),
      oldValue: '15',
      newValue: '17',
      quantityChange: 2,
      storageUnit: 'Loaf',
      storagePrimaryUnit: 'Pcs',
      isIncreased: true,
      salesItemUuid: 'cake',
      salesItemName: 'Cake',
      salesDepartmentUuid: 'pastry',
      salesDepartmentName: 'Pastry',
    ),
    // Purchase: unsigned quantity in the purchase unit.
    record(
      uuid: 'f-purchase',
      storageItemUuid: 'flour',
      event: 'purchase',
      createdAt: oct(20, 12),
      oldValue: '17',
      newValue: '29',
      quantityChange: 1,
      storageUnit: 'Carton',
      storagePrimaryUnit: 'Pcs',
      isIncreased: true,
    ),
    // Purchase deleted: unsigned, and the storekeeper id is missing.
    record(
      uuid: 'f-purchase-deleted',
      storageItemUuid: 'flour',
      event: 'purchase_deleted',
      createdAt: oct(20, 13),
      oldValue: '29',
      newValue: '17',
      quantityChange: 1,
      storageUnit: 'Carton',
      storagePrimaryUnit: 'Pcs',
      isIncreased: false,
      storageStaffId: null,
    ),
    // Update (decrease).
    record(
      uuid: 'f-decrease',
      storageItemUuid: 'flour',
      event: 'quantity_decrease',
      createdAt: oct(20, 14),
      oldValue: '17',
      newValue: '15',
      quantityChange: -2,
      storageUnit: 'Pcs',
      storagePrimaryUnit: 'Pcs',
      isIncreased: false,
    ),
    // 2D stock-in in sheets.
    record(
      uuid: 'g-in',
      storageItemUuid: 'glass',
      storageItemName: 'Glass Store',
      event: 'stock_in',
      createdAt: oct(20, 9),
      oldValue: '0',
      newValue: '4',
      quantityChange: 4,
      storageUnit: 'sheet',
      storagePrimaryUnit: 'sheet',
      isIncreased: true,
    ),
    // 2D transfer recorded under an old primary unit name; falls back to
    // quantityChange in sqm (9 sqm = 1.5 sheets of 6 sqm).
    record(
      uuid: 'g-out',
      storageItemUuid: 'glass',
      storageItemName: 'Glass Store',
      event: 'stock_out',
      createdAt: oct(20, 10, 30),
      oldValue: '4',
      newValue: '2.5',
      quantityChange: -9,
      storageUnit: 'sqm',
      storagePrimaryUnit: 'Old Sheet',
      isIncreased: false,
      salesItemUuid: 'mirror',
      salesItemName: 'Mirror',
      salesDepartmentUuid: 'bakery',
      salesDepartmentName: 'Bakery',
      salesStaffName: 'Bola Baker',
    ),
    // Duplicated: the value is the sales item's quantity, not storage.
    record(
      uuid: 's-duplicated',
      storageItemUuid: 'salt',
      storageItemName: 'Salt Store',
      event: 'duplicated',
      createdAt: oct(20, 8),
      oldValue: '50',
      newValue: '50',
      quantityChange: 0,
      storageUnit: 'Kg',
      storagePrimaryUnit: 'Kg',
    ),
    // Cannot be normalised: unknown primary unit and unknown unit.
    record(
      uuid: 's-increase',
      storageItemUuid: 'salt',
      storageItemName: 'Salt Store',
      event: 'quantity_increase',
      createdAt: oct(20, 9),
      oldValue: '0',
      newValue: '3',
      quantityChange: 3,
      storageUnit: 'Sacks',
      storagePrimaryUnit: 'Sacks',
      isIncreased: true,
    ),
    // A deleted storage item: stock-in, then delete (raw quantity).
    record(
      uuid: 'o-in',
      storageItemUuid: 'old',
      storageItemName: 'Old Syrup',
      event: 'stock_in',
      createdAt: oct(20, 8),
      oldValue: '0',
      newValue: '6',
      quantityChange: 6,
      storageUnit: 'Bottles',
      storagePrimaryUnit: 'Bottles',
      isIncreased: true,
    ),
    record(
      uuid: 'o-deleted',
      storageItemUuid: 'old',
      storageItemName: 'Old Syrup',
      event: 'deleted',
      createdAt: oct(20, 9),
      oldValue: '6',
      newValue: '6',
      quantityChange: 0,
    ),
  ];

  StorageItemHistory byId(String id) =>
      histories.firstWhere((h) => h.uuid == id);

  final contexts = StorageHistorySummaryBuilder.unitContexts(
    storageProducts: storageProducts,
    histories: histories,
  );

  group('Event mapping', () {
    test('every storage event maps to a movement', () {
      expect(storageMovementKindOf('stock_in'), StorageMovementKind.stockIn);
      expect(
        storageMovementKindOf('stock_out'),
        StorageMovementKind.transferredOut,
      );
      expect(storageMovementKindOf('return'), StorageMovementKind.returned);
      expect(storageMovementKindOf('purchase'), StorageMovementKind.purchase);
      expect(
        storageMovementKindOf('purchase_deleted'),
        StorageMovementKind.purchaseDeleted,
      );
      expect(
        storageMovementKindOf('quantity_increase'),
        StorageMovementKind.adjustedUp,
      );
      expect(
        storageMovementKindOf('quantity_decrease'),
        StorageMovementKind.adjustedDown,
      );
      expect(
        storageMovementKindOf('transfered_out'),
        StorageMovementKind.transferredOut,
      );
      expect(
        storageMovementKindOf('transfered_in'),
        StorageMovementKind.stockIn,
      );
      expect(storageMovementKindOf('created'), StorageMovementKind.created);
      expect(storageMovementKindOf('deleted'), StorageMovementKind.deleted);
      expect(
        storageMovementKindOf('duplicated'),
        StorageMovementKind.duplicated,
      );
      expect(storageMovementKindOf(null), StorageMovementKind.other);
      expect(StorageMovementKind.created.isQuantityEvent, isFalse);
      expect(StorageMovementKind.purchaseDeleted.isReduction, isTrue);
      expect(StorageMovementKind.returned.isAddition, isTrue);
    });
  });

  group('Normaliser', () {
    double? q(String id) {
      final h = byId(id);
      return StorageMovementNormaliser.quantity(h, contexts[h.storageItemUuid]!);
    }

    test('uses the storage old/new difference in the primary unit', () {
      expect(q('f-in'), 20);
      expect(q('f-out'), 5);
      // The sales unit in storageUnit is ignored when old/new apply.
      expect(q('f-return'), 2);
      // The unsigned carton quantity is ignored: 12 pieces.
      expect(q('f-purchase'), 12);
      expect(q('f-purchase-deleted'), 12);
      expect(q('f-decrease'), 2);
      expect(q('g-in'), 4);
    });

    test('ignores thousand separators', () {
      final h = record(
        uuid: 'commas',
        storageItemUuid: 'flour',
        event: 'stock_in',
        createdAt: oct(20, 9),
        oldValue: '1,000',
        newValue: '1,250.5',
        storagePrimaryUnit: 'Pcs',
      );
      expect(StorageMovementNormaliser.quantity(h, contexts['flour']!), 250.5);
    });

    test('falls back to quantityChange in a storage unit', () {
      // 2D: 9 sqm out of 6 sqm sheets.
      expect(q('g-out'), closeTo(1.5, 1e-9));

      // 1D: renamed primary unit, 2 cartons = 24 pieces.
      final h = record(
        uuid: 'renamed',
        storageItemUuid: 'flour',
        event: 'stock_out',
        createdAt: oct(20, 9),
        oldValue: '40',
        newValue: '16',
        quantityChange: -2,
        storageUnit: 'carton ',
        storagePrimaryUnit: 'Pieces',
      );
      expect(StorageMovementNormaliser.quantity(h, contexts['flour']!), 24);
    });

    test('returns null instead of guessing', () {
      expect(q('s-increase'), isNull);

      // A return under an old primary unit, with the sales unit name.
      final h = record(
        uuid: 'sales-unit',
        storageItemUuid: 'flour',
        event: 'return',
        createdAt: oct(20, 9),
        oldValue: '1',
        newValue: '3',
        quantityChange: 2,
        storageUnit: 'Loaf',
        storagePrimaryUnit: 'Pieces',
      );
      expect(StorageMovementNormaliser.quantity(h, contexts['flour']!), isNull);

      // A deleted item has no units to convert with.
      final orphan = record(
        uuid: 'orphan',
        storageItemUuid: 'old',
        event: 'stock_out',
        createdAt: oct(20, 9),
        oldValue: '6',
        newValue: '2',
        quantityChange: -4,
        storageUnit: 'Bottles',
        storagePrimaryUnit: 'Crates',
      );
      expect(
        StorageMovementNormaliser.quantity(orphan, contexts['old']!),
        isNull,
      );
    });

    test('created, deleted and duplicated move nothing', () {
      expect(q('f-created'), 0);
      expect(q('o-deleted'), 0);
      expect(q('s-duplicated'), 0);
    });

    test('deleted items take their unit from history', () {
      final ctx = contexts['old']!;
      expect(ctx.storage, isNull);
      expect(ctx.primaryUnitName, 'Bottles');
      expect(q('o-in'), 6);
    });

    test('items without units fall back like the storage report', () {
      final bare = TempStorageProducts(
        uuid: 'bare',
        shopId: 1,
        name: 'Bare',
        unit: 'Litres',
        costPrice: null,
        sellingPrice: null,
        useGroupUnit: false,
        unitsList: [],
      );
      final ctx = StorageUnitContext.fromStorage(bare);
      expect(ctx.primaryUnitName, 'Litres');
    });
  });

  group('Totals', () {
    test('additions, reductions, net, restocked and counts', () {
      final t = StorageMovementTotals()
        ..add(StorageMovementKind.stockIn, 10)
        ..add(StorageMovementKind.purchase, 5)
        ..add(StorageMovementKind.purchaseDeleted, 3)
        ..add(StorageMovementKind.transferredOut, 4)
        ..add(StorageMovementKind.returned, 1)
        ..add(StorageMovementKind.adjustedUp, null)
        ..add(StorageMovementKind.created, 0);
      expect(t.additions, 16);
      expect(t.reductions, 7);
      expect(t.netChange, 9);
      expect(t.restocked, 12);
      expect(t.movementCount, 6);
      expect(t.eventCount, 7);
      expect(t.notNormalised, 1);
      expect(t.hasMovement, isTrue);
      expect(StorageMovementTotals().hasMovement, isFalse);
    });

    test('formatQuantitiesByUnit never mixes units', () {
      expect(formatQuantitiesByUnit({}), '0');
      expect(
        formatQuantitiesByUnit({'sheet': 1.5, 'Pcs': 5, 'Kg': 0}),
        '5.0 Pcs, 1.5 sheet',
      );
    });
  });

  group('Summary and rows', () {
    final today = StorageHistorySummaryBuilder.buildSummaryAndRows(
      storageProducts: storageProducts,
      salesProducts: const [],
      histories: histories,
      period: StorageHistoryPeriod.today,
      businessNow: businessNow,
    );

    test('overall totals are kept per unit', () {
      final s = today.stats;
      expect(s.byUnit.keys.toSet(), {'Pcs', 'sheet', 'Kg', 'Bottles'});
      final out = s.quantityByUnit(StorageMovementKind.transferredOut);
      expect(out['Pcs'], 5);
      expect(out['sheet'], closeTo(1.5, 1e-9));
      expect(s.quantityByUnit(StorageMovementKind.stockIn), {
        'sheet': 4,
        'Bottles': 6,
      });
      expect(s.quantityByUnit(StorageMovementKind.returned), {'Pcs': 2});
      expect(s.restockedByUnit, {'sheet': 4, 'Bottles': 6});
      expect(s.additionsByUnit['Pcs'], 14);
      expect(s.reductionsByUnit['Pcs'], 19);
      expect(s.netChangeByUnit['Pcs'], -5);
    });

    test('counts, including records that cannot be normalised', () {
      final s = today.stats;
      expect(s.totalHistoryEvents, 11);
      expect(s.countOf(StorageMovementKind.transferredOut), 2);
      expect(s.countOf(StorageMovementKind.stockIn), 2);
      expect(s.countOf(StorageMovementKind.deleted), 1);
      expect(s.countOf(StorageMovementKind.duplicated), 1);
      expect(s.countOf(StorageMovementKind.created), 0);
      expect(s.movementCount, 9);
      expect(s.notNormalisedCount, 1);
      expect(s.itemsWithMovementCount, 4);
      expect(s.itemsWithHistoryCount, 4);
      expect(s.totalDistinctItems, 5);
    });

    test('rows cover current items and deleted items with history', () {
      final rows = {for (final r in today.rows) r.uuid: r};
      expect(rows.keys.toSet(), {'flour', 'glass', 'salt', 'rice', 'old'});
      expect(
        today.rows.map((r) => r.index).toList(),
        [1, 2, 3, 4, 5],
      );

      final f = rows['flour']!;
      expect(f.name, 'Flour Store');
      expect(f.currentName, 'Flour Store 50kg');
      expect(f.exists, isTrue);
      expect(f.primaryUnit, 'Pcs');
      expect(f.openingStock, 20);
      expect(f.closingStock, 15);
      expect(f.currentQuantity, 15);
      expect(f.transferredOut, 5);
      expect(f.returned, 2);
      expect(f.purchased, 12);
      expect(f.purchaseDeleted, 12);
      expect(f.adjustedDown, 2);
      expect(f.stockedIn, 0);
      expect(f.restocked, 0);
      expect(f.netQuantityChange, -5);
      expect(f.movementCount, 5);
      expect(f.netQuantityChangeText, '-5.0 Pcs');

      final o = rows['old']!;
      expect(o.exists, isFalse);
      expect(o.name, 'Old Syrup');
      expect(o.currentName, isNull);
      expect(o.primaryUnit, 'Bottles');
      expect(o.openingStock, isNull);
      expect(o.quantityText(o.openingStock), '—');

      final salt = rows['salt']!;
      expect(salt.notNormalised, 1);
      expect(salt.hasAnyMovement, isTrue);
      expect(salt.netQuantityChange, 0);

      expect(rows['rice']!.hasAnyMovement, isFalse);
    });

    test('all time includes earlier days', () {
      final all = StorageHistorySummaryBuilder.buildSummaryAndRows(
        storageProducts: storageProducts,
        salesProducts: const [],
        histories: histories,
        period: StorageHistoryPeriod.allTime,
        businessNow: businessNow,
      );
      final f = all.rows.firstWhere((r) => r.uuid == 'flour');
      expect(f.stockedIn, 20);
      expect(f.netQuantityChange, 15);
      expect(f.openingStock, 0);
      expect(f.closingStock, 15);
      expect(all.stats.countOf(StorageMovementKind.created), 1);
    });

    test('a deleted item outside the period gets no row', () {
      final yesterday = StorageHistorySummaryBuilder.buildSummaryAndRows(
        storageProducts: storageProducts,
        salesProducts: const [],
        histories: histories,
        period: StorageHistoryPeriod.custom,
        customRange: DateTimeRange(
          start: DateTime(2026, 10, 19),
          end: DateTime(2026, 10, 19),
        ),
        businessNow: businessNow,
      );
      expect(
        yesterday.rows.map((r) => r.uuid).toSet(),
        {'flour', 'glass', 'salt', 'rice'},
      );
      expect(yesterday.stats.quantityByUnit(StorageMovementKind.stockIn), {
        'Pcs': 20,
      });
    });

    test('filters, sorting, pagination and top movers', () {
      List<String> run(
        StorageHistorySummaryFilters f, {
        StorageHistorySummarySortField sort =
            StorageHistorySummarySortField.itemName,
        bool asc = true,
      }) =>
          StorageHistorySummaryBuilder.filterAndSortRows(
            rows: today.rows,
            filters: f,
            sortField: sort,
            ascending: asc,
          ).map((r) => r.uuid).toList();

      final f = StorageHistorySummaryFilters();
      f.movementFilter = StorageHistoryMovementFilter.hasMovement;
      expect(run(f).toSet(), {'flour', 'glass', 'salt', 'old'});
      f.movementFilter = StorageHistoryMovementFilter.inflowOnly;
      expect(run(f).toSet(), {'flour', 'glass', 'old'});
      f.movementFilter = StorageHistoryMovementFilter.outflowOnly;
      expect(run(f).toSet(), {'flour', 'glass'});
      f.movementFilter = StorageHistoryMovementFilter.noChange;
      expect(run(f).toSet(), {'salt', 'rice'});

      f.clearAll();
      f.search = '50kg';
      expect(run(f), ['flour']);
      f.clearAll();

      expect(
        run(
          f,
          sort: StorageHistorySummarySortField.transferredOut,
          asc: false,
        ),
        ['flour', 'glass', 'old', 'rice', 'salt'],
      );

      final page = StorageHistorySummaryBuilder.paginate(today.rows, 4);
      expect(page.page, 1);
      expect(page.totalPages, 1);
      expect(page.lastIndex, 5);

      expect(
        StorageHistorySummaryBuilder.getTopInflowItems(today.rows)
            .map((r) => r.uuid)
            .toList(),
        ['flour', 'old', 'glass'],
      );
      expect(
        StorageHistorySummaryBuilder.getTopOutflowItems(today.rows)
            .map((r) => r.uuid)
            .toList(),
        ['flour', 'glass'],
      );
    });
  });

  group('Breakdowns', () {
    final b = StorageHistorySummaryBuilder.buildBreakdowns(
      storageProducts: storageProducts,
      histories: histories,
      period: StorageHistoryPeriod.today,
      businessNow: businessNow,
    );

    test('sales items supplied and returning', () {
      expect(b.salesItemsSupplied.map((e) => e.label).toList(), [
        'Bread',
        'Mirror',
      ]);
      expect(b.salesItemsSupplied.first.outflow, {'Pcs': 5});
      expect(b.salesItemsReturning.single.label, 'Cake');
      expect(b.salesItemsReturning.single.inflow, {'Pcs': 2});
    });

    test('sales departments of transfers and returns', () {
      expect(b.departments.map((e) => e.key).toList(), ['bakery', 'pastry']);
      final bakery = b.departments.first;
      expect(bakery.count, 2);
      expect(bakery.outflow['Pcs'], 5);
      expect(bakery.outflow['sheet'], closeTo(1.5, 1e-9));
      expect(b.departments.last.inflow, {'Pcs': 2});
    });

    test('storekeepers by id with name fallback, and other staff', () {
      expect(b.storekeepers.map((e) => e.key).toList(), [
        'keeper-1',
        '${storageHistoryStaffNamePrefix}ada keeper',
      ]);
      expect(b.storekeepers.first.count, 8);
      expect(b.storekeepers.last.outflow, {'Pcs': 12});

      expect(b.otherStaff.map((e) => e.key).toSet(), {
        'other-1',
        '${storageHistoryStaffNamePrefix}bola baker',
      });
      expect(b.otherStaff.every((e) => e.label == 'Bola Baker'), isTrue);
    });
  });

  group('Periods', () {
    test('business-day windows', () {
      final range = StorageHistorySummaryBuilder.resolveDateRange(
        period: StorageHistoryPeriod.thisWeek,
        businessNow: businessNow,
      );
      expect(range.start, DateTime(2026, 10, 19));
      expect(range.end, DateTime(2026, 10, 20));

      final month = StorageHistorySummaryBuilder.resolveDateRange(
        period: StorageHistoryPeriod.thisMonth,
        businessNow: businessNow,
      );
      expect(month.start, DateTime(2026, 10, 1));

      final day = DateTimeRange(
        start: DateTime(2026, 10, 20),
        end: DateTime(2026, 10, 20),
      );
      bool inDay(DateTime? t) => StorageHistorySummaryBuilder.isInPeriod(
            record(
              uuid: 'x',
              storageItemUuid: 'flour',
              event: 'stock_in',
              createdAt: t ?? DateTime(2026),
            )..createdAt = t,
            period: StorageHistoryPeriod.custom,
            range: day,
          );
      expect(inDay(oct(20, 0)), isTrue);
      expect(inDay(oct(20, 23, 59)), isTrue);
      expect(inDay(oct(21, 0)), isFalse);
      expect(inDay(null), isFalse);
      expect(
        StorageHistorySummaryBuilder.isInPeriod(
          byId('f-created'),
          period: StorageHistoryPeriod.allTime,
          range: day,
        ),
        isTrue,
      );
    });
  });

  group('Legacy records without an event', () {
    StorageItemHistory legacy({
      required String uuid,
      required String title,
      required String? event,
      required DateTime createdAt,
      required String oldValue,
      required String newValue,
      bool? isIncreased,
    }) {
      return StorageItemHistory(
        uuid: uuid,
        createdAt: createdAt,
        shopId: 1,
        title: title,
        storageItemName: 'Water Store',
        storageItemUuid: 'water',
        storageItemNewValue: newValue,
        storageItemOldValue: oldValue,
        quantityChange: null,
        desc: null,
        isIncreased: isIncreased,
        storagePrimaryUnit: 'Pcs',
        event: event,
        source: null,
      );
    }

    test('eventOf infers the event of legacy titles', () {
      StorageItemHistory bare(String title, {bool? isIncreased}) => legacy(
        uuid: title,
        title: title,
        event: null,
        createdAt: oct(1, 9),
        oldValue: '0',
        newValue: '0',
        isIncreased: isIncreased,
      );
      final cases = <String, String?>{
        'Stock In From Purchase': StorageItemHistoryEventClass.purchase,
        'Purchase Deleted': StorageItemHistoryEventClass.purchaseDeleted,
        'Return Item': StorageItemHistoryEventClass.returnEvent,
        'Stock In': StorageItemHistoryEventClass.stockIn,
        'Stock Out': StorageItemHistoryEventClass.stockOut,
        'Item Created': StorageItemHistoryEventClass.itemCreated,
        'Item Deleted': StorageItemHistoryEventClass.itemDeleted,
        'Price Updated': null,
      };
      cases.forEach((title, expected) {
        expect(
          StorageItemHistoryEventClass.eventOf(bare(title)),
          expected,
          reason: title,
        );
      });
      expect(
        StorageItemHistoryEventClass.eventOf(
          bare('Stock Updated', isIncreased: true),
        ),
        StorageItemHistoryEventClass.quantityUpdatedIncrease,
      );
      expect(
        StorageItemHistoryEventClass.eventOf(
          bare('Stock Updated', isIncreased: false),
        ),
        StorageItemHistoryEventClass.quantityUpdatedDecrease,
      );
      expect(
        StorageItemHistoryEventClass.eventOf(bare('Stock Updated')),
        isNull,
      );
      final tagged = bare('Stock In')..event = 'stock_out';
      expect(StorageItemHistoryEventClass.eventOf(tagged), 'stock_out');
    });

    test('legacy records give the same summary as tagged ones', () {
      final water = storageItem(
        uuid: 'water',
        name: 'Water Store',
        quantity: 8,
        units: [unit('Pcs')],
        createdAt: DateTime(2026, 9, 1),
      );

      List<StorageItemHistory> build({required bool tagged}) => [
        legacy(
          uuid: 'in',
          title: 'Stock In',
          event: tagged ? StorageItemHistoryEventClass.stockIn : null,
          createdAt: DateTime(2026, 9, 28, 10),
          oldValue: '0',
          newValue: '10',
          isIncreased: true,
        ),
        legacy(
          uuid: 'out',
          title: 'Stock Out',
          event: tagged ? StorageItemHistoryEventClass.stockOut : null,
          createdAt: DateTime(2026, 9, 29, 10),
          oldValue: '10',
          newValue: '6',
          isIncreased: false,
        ),
        legacy(
          uuid: 'up',
          title: 'Stock Updated',
          event:
              tagged
                  ? StorageItemHistoryEventClass.quantityUpdatedIncrease
                  : null,
          createdAt: DateTime(2026, 9, 30, 10),
          oldValue: '6',
          newValue: '8',
          isIncreased: true,
        ),
      ];

      for (final tagged in [false, true]) {
        final res = StorageHistorySummaryBuilder.buildSummaryAndRows(
          storageProducts: [water],
          salesProducts: const [],
          histories: build(tagged: tagged),
          period: StorageHistoryPeriod.allTime,
          businessNow: businessNow,
        );
        final r = res.rows.firstWhere((r) => r.uuid == 'water');
        final s = res.stats;
        final reason = 'tagged: $tagged';
        expect(r.openingStock, 0, reason: reason);
        expect(r.closingStock, 8, reason: reason);
        expect(r.netQuantityChange, 8, reason: reason);
        expect(
          s.quantityByUnit(StorageMovementKind.stockIn),
          {'Pcs': 10},
          reason: reason,
        );
        expect(
          s.quantityByUnit(StorageMovementKind.transferredOut),
          {'Pcs': 4},
          reason: reason,
        );
        expect(
          s.quantityByUnit(StorageMovementKind.adjustedUp),
          {'Pcs': 2},
          reason: reason,
        );
      }
    });
  });

  test('Page constructor', () {
    const page = StorageItemHistorySummaryPage();
    expect(page, isA<StorageItemHistorySummaryPage>());
  });
}
