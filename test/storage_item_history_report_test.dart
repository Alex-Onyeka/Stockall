import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/temp_storage_item_history/storage_item_history.dart';
import 'package:stockall/classes/temp_storage_item_history/storage_item_history_event_class.dart';
import 'package:stockall/pages/report/items_report_/item_history_report/class/item_history_report_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/storage_items_report_/storage_item_history_report/class/storage_item_history_report_logic.dart';
import 'package:stockall/pages/report/storage_items_report_/storage_item_history_report/storage_item_history_report_page.dart';

void main() {
  StorageItemHistory makeRecord({
    String uuid = 'h-1',
    DateTime? createdAt,
    int shopId = 1,
    String title = 'Stock Out',
    String? storageItemName = 'Flour Store',
    String? storageItemUuid = 'storage-1',
    String? storageOld = '20',
    String? storageNew = '15',
    String? storageStaffId = 'keeper-1',
    String? storageStaffName = 'Ada Keeper',
    double? quantityChange = -5,
    String? desc,
    bool? isIncreased = false,
    String? storageUnit = 'Bags',
    String? storagePrimaryUnit = 'Bags',
    String? salesStaffName,
    String? salesStaffUuid,
    String? salesDepartmentUuid,
    String? salesDepartmentName,
    String? salesOld,
    String? salesNew,
    String? salesItemUuid,
    String? salesItemName,
    String? salesUnit,
    String? salesPrimaryUnit,
    String? event = 'stock_out',
    String? source = 'storage',
    String? destination = 'product',
  }) {
    return StorageItemHistory(
      uuid: uuid,
      createdAt: createdAt ?? DateTime(2026, 10, 20, 10),
      shopId: shopId,
      title: title,
      storageItemName: storageItemName,
      storageItemUuid: storageItemUuid,
      storageItemOldValue: storageOld,
      storageItemNewValue: storageNew,
      storageStaffId: storageStaffId,
      storageStaffName: storageStaffName,
      quantityChange: quantityChange,
      desc: desc,
      isIncreased: isIncreased,
      storageUnit: storageUnit,
      storagePrimaryUnit: storagePrimaryUnit,
      salesStaffName: salesStaffName,
      salesStaffUuid: salesStaffUuid,
      salesDepartmentUuid: salesDepartmentUuid,
      salesDepartmentName: salesDepartmentName,
      salesItemOldValue: salesOld,
      salesItemNewValue: salesNew,
      salesItemUuid: salesItemUuid,
      salesItemName: salesItemName,
      salesUnit: salesUnit,
      salesPrimaryUnit: salesPrimaryUnit,
      event: event,
      source: source,
      destination: destination,
    );
  }

  // One record per writer shape found on main.
  final transfer = makeRecord(
    uuid: 'transfer',
    desc: 'Stock Out',
    salesItemUuid: 'sales-bread',
    salesItemName: 'Bread',
    salesDepartmentUuid: 'dept-bakery',
    salesDepartmentName: 'Bakery',
    salesStaffUuid: 'other-1',
    salesStaffName: 'Bola Baker',
    salesOld: '2',
    salesNew: '7',
    salesUnit: 'Bags',
    salesPrimaryUnit: 'Loaf',
  );
  final returned = makeRecord(
    uuid: 'return',
    title: 'Return Item',
    event: 'return',
    source: 'product',
    destination: 'storage',
    storageOld: '15',
    storageNew: '17',
    quantityChange: 2,
    isIncreased: true,
    // Returns store the sales unit name as storageUnit.
    storageUnit: 'Loaf',
    salesItemUuid: 'sales-cake',
    salesItemName: 'Cake',
    salesDepartmentUuid: 'dept-pastry',
    salesDepartmentName: 'Pastry',
    createdAt: DateTime(2026, 10, 20, 11),
  );
  final stockIn = makeRecord(
    uuid: 'stock-in',
    title: 'Stock In',
    event: 'stock_in',
    source: 'manual',
    destination: 'storage',
    storageOld: '0',
    storageNew: '20',
    quantityChange: 20,
    isIncreased: true,
    desc: 'Delivered by supplier',
    salesStaffName: 'Chidi Driver',
    createdAt: DateTime(2026, 10, 19, 9),
  );
  final purchaseDeleted = makeRecord(
    uuid: 'purchase-deleted',
    title: 'Purchase Deleted',
    event: 'purchase_deleted',
    source: 'storage',
    destination: 'purchase',
    storageOld: '17',
    storageNew: '14',
    // Purchases store an unsigned quantity.
    quantityChange: 3,
    isIncreased: false,
    storageStaffId: null,
    storageStaffName: 'Ada Keeper',
    createdAt: DateTime(2026, 10, 21, 9),
  );
  final created = makeRecord(
    uuid: 'created',
    title: 'Item Created',
    event: 'created',
    source: 'manual',
    destination: 'storage',
    storageOld: '0',
    storageNew: '0',
    quantityChange: 0,
    isIncreased: true,
    storageUnit: 'Not Set',
    storagePrimaryUnit: null,
    storageItemUuid: 'storage-2',
    storageItemName: 'Sugar Store',
    storageStaffId: 'keeper-2',
    storageStaffName: 'Emeka Keeper',
    createdAt: DateTime(2026, 10, 18, 9),
  );
  final all = [transfer, returned, stockIn, purchaseDeleted, created];

  List<StorageItemHistory> run(
    StorageItemHistoryReportFilters f, {
    bool departmentsEnabled = true,
  }) {
    return StorageItemHistoryReportQuery.filterAndSort(
      rows: all,
      filters: f,
      sortField: StorageItemHistorySortField.createdAt,
      ascending: false,
      departmentsEnabled: departmentsEnabled,
    );
  }

  Set<String?> ids(List<StorageItemHistory> rows) =>
      rows.map((h) => h.uuid).toSet();

  group('Search', () {
    test('covers both items, department, both staff and event label', () {
      final f = StorageItemHistoryReportFilters();
      for (final entry in {
        'flour': {'transfer', 'return', 'stock-in', 'purchase-deleted'},
        'bread': {'transfer'},
        'cake': {'return'},
        'bakery': {'transfer'},
        'ada': {'transfer', 'return', 'stock-in', 'purchase-deleted'},
        'bola': {'transfer'},
        'chidi': {'stock-in'},
        'stock out': {'transfer'},
        'purchase deleted': {'purchase-deleted'},
        'supplier': {'stock-in'},
        'loaf': {'transfer', 'return'},
      }.entries) {
        f.search = entry.key;
        expect(ids(run(f)), entry.value, reason: entry.key);
      }
    });
  });

  group('Filters', () {
    test('storage item and sales item, with a no-sales-item bucket', () {
      final f = StorageItemHistoryReportFilters()..storageItemUuid = 'storage-2';
      expect(ids(run(f)), {'created'});

      f.storageItemUuid = null;
      f.salesItemUuid = 'sales-bread';
      expect(ids(run(f)), {'transfer'});

      f.salesItemUuid = storageItemHistoryReportNoneKey;
      expect(ids(run(f)), {'stock-in', 'purchase-deleted', 'created'});
    });

    test('department uses the sales department and is ignored when off', () {
      final f = StorageItemHistoryReportFilters()
        ..departmentUuid = 'dept-pastry';
      expect(ids(run(f)), {'return'});
      expect(run(f, departmentsEnabled: false).length, all.length);

      f.departmentUuid = storageItemHistoryReportNoneKey;
      expect(ids(run(f)), {'stock-in', 'purchase-deleted', 'created'});
    });

    test('storekeeper by id, falling back to the name when id is null', () {
      final f = StorageItemHistoryReportFilters()..storekeeperKey = 'keeper-1';
      expect(ids(run(f)), {'transfer', 'return', 'stock-in'});

      f.storekeeperKey = StorageHistoryStaff.storekeeperKey(purchaseDeleted);
      expect(f.storekeeperKey, '${storageHistoryStaffNamePrefix}ada keeper');
      expect(ids(run(f)), {'purchase-deleted'});
    });

    test('other staff by uuid, by name, and none', () {
      final f = StorageItemHistoryReportFilters()..otherStaffKey = 'other-1';
      expect(ids(run(f)), {'transfer'});

      f.otherStaffKey = StorageHistoryStaff.otherStaffKey(stockIn);
      expect(ids(run(f)), {'stock-in'});

      f.otherStaffKey = storageItemHistoryReportNoneKey;
      expect(ids(run(f)), {'return', 'purchase-deleted', 'created'});
    });

    test('event, source and destination', () {
      final f = StorageItemHistoryReportFilters()
        ..event = StorageItemHistoryEventClass.returnEvent;
      expect(ids(run(f)), {'return'});

      f.event = null;
      f.source = 'manual';
      expect(ids(run(f)), {'stock-in', 'created'});

      f.destination = 'storage';
      expect(ids(run(f)), {'stock-in', 'created'});
      f.destination = 'product';
      expect(run(f), isEmpty);
    });

    test('date range uses business days, both ends inclusive', () {
      final f = StorageItemHistoryReportFilters()
        ..dateRange = DateTimeRange(
          start: DateTime(2026, 10, 19),
          end: DateTime(2026, 10, 20),
        );
      expect(ids(run(f)), {'transfer', 'return', 'stock-in'});

      f.dateRange = DateTimeRange(
        start: DateTime(2026, 10, 21),
        end: DateTime(2026, 10, 21),
      );
      expect(ids(run(f)), {'purchase-deleted'});
    });

    test('quantity direction tolerates unsigned purchase quantities', () {
      final f = StorageItemHistoryReportFilters()
        ..quantityDirection = QuantityDirectionFilter.decrease;
      expect(ids(run(f)), {'transfer', 'purchase-deleted'});

      f.quantityDirection = QuantityDirectionFilter.increase;
      expect(ids(run(f)), {'return', 'stock-in'});

      f.quantityDirection = QuantityDirectionFilter.zeroChange;
      expect(ids(run(f)), {'created'});
    });

    test('activeCount and clearAll leave the date alone', () {
      final range = DateTimeRange(
        start: DateTime(2026, 10, 20),
        end: DateTime(2026, 10, 20),
      );
      final f = StorageItemHistoryReportFilters()
        ..dateRange = range
        ..event = 'return'
        ..otherStaffKey = 'other-1';
      expect(f.activeCount, 2);
      expect(f.hasAnything, isTrue);

      f.clearAll();
      expect(f.activeCount, 0);
      expect(f.hasAnything, isFalse);
      expect(f.dateRange, range);
    });
  });

  group('Department scoping', () {
    final otherShop = makeRecord(uuid: 'other-shop', shopId: 2);
    final source = [...all, otherShop];

    List<StorageItemHistory> scope({
      bool departmentsEnabled = true,
      bool canViewAll = false,
      String? current = 'dept-bakery',
    }) {
      return scopeStorageItemHistories(
        all: source,
        shopId: 1,
        departmentsEnabled: departmentsEnabled,
        canViewAllDepartments: canViewAll,
        currentDepartmentUuid: current,
      );
    }

    test('always limited to the shop', () {
      expect(ids(scope(canViewAll: true)), ids(all));
      expect(ids(scope(departmentsEnabled: false)), ids(all));
    });

    test('by sales department; rows without one stay visible', () {
      expect(
        ids(scope()),
        {'transfer', 'stock-in', 'purchase-deleted', 'created'},
      );
      expect(
        ids(scope(current: null)),
        {'stock-in', 'purchase-deleted', 'created'},
      );
    });
  });

  test('currentNameIfDifferent', () {
    expect(
      currentNameIfDifferent(snapshotName: 'Flour', currentName: ' flour '),
      isNull,
    );
    expect(
      currentNameIfDifferent(snapshotName: 'Flour', currentName: 'Flour 50kg'),
      'Flour 50kg',
    );
    expect(
      currentNameIfDifferent(snapshotName: 'Flour', currentName: null),
      isNull,
    );
    expect(
      currentNameIfDifferent(snapshotName: null, currentName: 'Flour'),
      'Flour',
    );
  });

  group('Sorting', () {
    test('default is newest first', () {
      final rows = run(StorageItemHistoryReportFilters());
      expect(rows.map((h) => h.uuid).toList(), [
        'purchase-deleted',
        'return',
        'transfer',
        'stock-in',
        'created',
      ]);
    });

    test('other staff: nulls sink in both directions', () {
      for (final asc in [true, false]) {
        final rows = StorageItemHistoryReportQuery.filterAndSort(
          rows: all,
          filters: StorageItemHistoryReportFilters(),
          sortField: StorageItemHistorySortField.otherStaffName,
          ascending: asc,
          departmentsEnabled: true,
        );
        final names = rows.map((h) => h.salesStaffName).toList();
        expect(names.take(2).toSet(), {'Bola Baker', 'Chidi Driver'});
        expect(names.skip(2).every((n) => n == null), isTrue);
      }
    });

    test('storage values sort numerically, ignoring commas', () {
      final a = makeRecord(uuid: 'a', storageOld: '1,200');
      final b = makeRecord(uuid: 'b', storageOld: '900');
      final c = makeRecord(uuid: 'c', storageOld: null);
      final rows = StorageItemHistoryReportQuery.filterAndSort(
        rows: [a, b, c],
        filters: StorageItemHistoryReportFilters(),
        sortField: StorageItemHistorySortField.storageOldValue,
        ascending: true,
        departmentsEnabled: true,
      );
      expect(rows.map((h) => h.uuid).toList(), ['b', 'a', 'c']);
    });

    test('unit sort ignores the Not Set placeholder', () {
      final rows = StorageItemHistoryReportQuery.filterAndSort(
        rows: all,
        filters: StorageItemHistoryReportFilters(),
        sortField: StorageItemHistorySortField.unit,
        ascending: true,
        departmentsEnabled: true,
      );
      expect(rows.last.uuid, 'created');
    });
  });

  test('Pagination', () {
    final many = List.generate(
      250,
      (i) => makeRecord(
        uuid: 'r$i',
        createdAt: DateTime(2026, 10, 20).add(Duration(minutes: i)),
      ),
    );
    final first = StorageItemHistoryReportQuery.paginate(many, 1);
    expect(first.totalPages, 3);
    expect(first.rows.length, 100);
    expect(first.firstIndex, 1);
    expect(first.lastIndex, 100);

    final last = StorageItemHistoryReportQuery.paginate(many, 9);
    expect(last.page, 3);
    expect(last.rows.length, 50);
    expect(last.firstIndex, 201);
    expect(last.lastIndex, 250);

    final empty = StorageItemHistoryReportQuery.paginate([], 1);
    expect(empty.totalPages, 1);
    expect(empty.firstIndex, 0);
    expect(empty.lastIndex, 0);
  });

  test('Formatting helpers', () {
    expect(StorageItemHistoryReportQuery.formatEventName('stock_out'), 'Stock Out');
    expect(StorageItemHistoryReportQuery.formatEventName('return'), 'Return');
    expect(
      StorageItemHistoryReportQuery.formatEventName('purchase_deleted'),
      'Purchase Deleted',
    );
    expect(
      StorageItemHistoryReportQuery.formatEventName('some_new_event'),
      'Some New Event',
    );
    expect(
      StorageItemHistoryReportQuery.formatSourceOrDestination('not_set'),
      'Not Set',
    );
    expect(
      StorageItemHistoryReportQuery.formatSourceOrDestination('branch_store'),
      'Branch Store',
    );
    expect(StorageItemHistoryReportQuery.quantityChangeUnit(created), isNull);
    expect(StorageItemHistoryReportQuery.quantityChangeUnit(returned), 'Loaf');
    expect(storageItemHistoryKnownEvents, contains('stock_in'));
  });

  test('Page constructor', () {
    const page = StorageItemHistoryReportPage();
    expect(page.initialStorageItemUuid, isNull);
    expect(page.initialPeriod, isNull);

    const filtered = StorageItemHistoryReportPage(
      initialStorageItemUuid: 'storage-1',
      initialPeriod: ReceiptsReportPeriod.allTime(),
    );
    expect(filtered.initialStorageItemUuid, 'storage-1');
    expect(filtered.initialPeriod!.isAllTime, isTrue);
  });
}
