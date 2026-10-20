import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/temp_item_history/item_history.dart';
import 'package:stockall/classes/temp_item_history/item_history_event_class.dart';
import 'package:stockall/pages/report/items_report_/item_history_report/class/item_history_report_logic.dart';

void main() {
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
  }) {
    return ItemHistory(
      uuid: uuid ?? 'test-uuid-1',
      createdAt:
          createdAt ?? DateTime(2026, 10, 15, 10, 30),
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
    );
  }

  group('ItemHistoryReportFilters and Query Tests', () {
    test(
      'All 21 fields accounted for and readable on model',
      () {
        final h = makeRecord(
          uuid: 'u-1',
          createdAt: DateTime(2026, 1, 1),
          shopId: 10,
          title: 'Title 1',
          itemName: 'Item 1',
          itemUuid: 'item-uuid-1',
          newValue: '100',
          oldValue: '90',
          staffId: 'staff-1',
          staffName: 'Staff One',
          departmentName: 'Dept 1',
          departmentUuid: 'dept-uuid-1',
          quantityChange: 10.0,
          desc: 'Desc 1',
          isIncreased: true,
          unit: 'Pcs',
          primaryUnit: 'Box',
          event: 'sale',
          isManaged: true,
          source: 'receipt',
          destination: 'product',
        );

        expect(h.uuid, 'u-1');
        expect(h.createdAt, DateTime(2026, 1, 1));
        expect(h.shopId, 10);
        expect(h.title, 'Title 1');
        expect(h.itemName, 'Item 1');
        expect(h.itemUuid, 'item-uuid-1');
        expect(h.newValue, '100');
        expect(h.oldValue, '90');
        expect(h.staffId, 'staff-1');
        expect(h.staffName, 'Staff One');
        expect(h.departmentName, 'Dept 1');
        expect(h.departmentUuid, 'dept-uuid-1');
        expect(h.quantityChange, 10.0);
        expect(h.desc, 'Desc 1');
        expect(h.isIncreased, true);
        expect(h.unit, 'Pcs');
        expect(h.primaryUnit, 'Box');
        expect(h.event, 'sale');
        expect(h.isManaged, true);
        expect(h.source, 'receipt');
        expect(h.destination, 'product');
      },
    );

    test(
      'Search filters case-insensitively across multiple fields',
      () {
        final h1 = makeRecord(
          title: 'Price Adjusted',
          itemName: 'Widget A',
        );
        final h2 = makeRecord(
          desc: 'Special invoice created',
          staffName: 'Alice',
        );
        final h3 = makeRecord(
          source: 'warehouse_store',
          departmentName: 'Electronics',
        );
        final h4 = makeRecord(
          oldValue: '450.00',
          newValue: '500.00',
        );

        final filters = ItemHistoryReportFilters();

        filters.search = 'widget';
        expect(
          filters.matches(h1, departmentsEnabled: true),
          isTrue,
        );
        expect(
          filters.matches(h2, departmentsEnabled: true),
          isFalse,
        );

        filters.search = 'alice';
        expect(
          filters.matches(h2, departmentsEnabled: true),
          isTrue,
        );

        filters.search = 'ELECTRONICS';
        expect(
          filters.matches(h3, departmentsEnabled: true),
          isTrue,
        );

        filters.search = '450.00';
        expect(
          filters.matches(h4, departmentsEnabled: true),
          isTrue,
        );

        filters.search = 'nonexistent';
        expect(
          filters.matches(h1, departmentsEnabled: true),
          isFalse,
        );
      },
    );

    test('Filter by itemUuid', () {
      final h1 = makeRecord(
        itemUuid: 'item-1',
        itemName: 'Apple',
      );
      final h2 = makeRecord(
        itemUuid: 'item-2',
        itemName: 'Banana',
      );
      final filters =
          ItemHistoryReportFilters()..itemUuid = 'item-1';

      final result = ItemHistoryReportQuery.filterAndSort(
        rows: [h1, h2],
        filters: filters,
        sortField: ItemHistorySortField.createdAt,
        ascending: false,
        departmentsEnabled: false,
      );

      expect(result.length, 1);
      expect(result.first.itemUuid, 'item-1');
    });

    test('Filter by event', () {
      final h1 = makeRecord(
        event: ItemHistoryEventClass.sold,
      );
      final h2 = makeRecord(
        event: ItemHistoryEventClass.returnEvent,
      );
      final filters =
          ItemHistoryReportFilters()
            ..event = ItemHistoryEventClass.sold;

      final result = ItemHistoryReportQuery.filterAndSort(
        rows: [h1, h2],
        filters: filters,
        sortField: ItemHistorySortField.createdAt,
        ascending: false,
        departmentsEnabled: false,
      );

      expect(result.length, 1);
      expect(
        result.first.event,
        ItemHistoryEventClass.sold,
      );
    });

    test('Filter by creator (staffId)', () {
      final h1 = makeRecord(
        staffId: 'staff-a',
        staffName: 'Alice',
      );
      final h2 = makeRecord(
        staffId: 'staff-b',
        staffName: 'Bob',
      );
      final filters =
          ItemHistoryReportFilters()..staffId = 'staff-b';

      final result = ItemHistoryReportQuery.filterAndSort(
        rows: [h1, h2],
        filters: filters,
        sortField: ItemHistorySortField.createdAt,
        ascending: false,
        departmentsEnabled: false,
      );

      expect(result.length, 1);
      expect(result.first.staffId, 'staff-b');
    });

    test('Filter by source and destination', () {
      final h1 = makeRecord(
        source: 'receipt',
        destination: 'storage',
      );
      final h2 = makeRecord(
        source: 'manual',
        destination: 'product',
      );
      final filters =
          ItemHistoryReportFilters()
            ..source = 'receipt'
            ..destination = 'storage';

      final result = ItemHistoryReportQuery.filterAndSort(
        rows: [h1, h2],
        filters: filters,
        sortField: ItemHistorySortField.createdAt,
        ascending: false,
        departmentsEnabled: false,
      );

      expect(result.length, 1);
      expect(result.first.source, 'receipt');
      expect(result.first.destination, 'storage');
    });

    test(
      'Filter by department and unassigned department key',
      () {
        final h1 = makeRecord(
          departmentUuid: 'dept-1',
          departmentName: 'Dept 1',
        );
        final h2 = makeRecord(
          departmentUuid: null,
          departmentName: null,
        );
        final h3 = makeRecord(
          departmentUuid: 'dept-2',
          departmentName: 'Dept 2',
        );

        final filters1 =
            ItemHistoryReportFilters()
              ..departmentUuid = 'dept-1';
        final res1 = ItemHistoryReportQuery.filterAndSort(
          rows: [h1, h2, h3],
          filters: filters1,
          sortField: ItemHistorySortField.createdAt,
          ascending: false,
          departmentsEnabled: true,
        );
        expect(res1.length, 1);
        expect(res1.first.departmentUuid, 'dept-1');

        final filtersNone =
            ItemHistoryReportFilters()
              ..departmentUuid = itemHistoryReportNoneKey;
        final resNone =
            ItemHistoryReportQuery.filterAndSort(
              rows: [h1, h2, h3],
              filters: filtersNone,
              sortField: ItemHistorySortField.createdAt,
              ascending: false,
              departmentsEnabled: true,
            );
        expect(resNone.length, 1);
        expect(resNone.first.departmentUuid, isNull);
      },
    );

    test('Filter by isManaged', () {
      final h1 = makeRecord(isManaged: true);
      final h2 = makeRecord(isManaged: false);
      final h3 = makeRecord(isManaged: null);

      final filtersManaged =
          ItemHistoryReportFilters()..isManaged = true;
      final resManaged =
          ItemHistoryReportQuery.filterAndSort(
            rows: [h1, h2, h3],
            filters: filtersManaged,
            sortField: ItemHistorySortField.createdAt,
            ascending: false,
            departmentsEnabled: false,
          );
      expect(resManaged.length, 1);
      expect(resManaged.first.isManaged, isTrue);

      final filtersUnmanaged =
          ItemHistoryReportFilters()..isManaged = false;
      final resUnmanaged =
          ItemHistoryReportQuery.filterAndSort(
            rows: [h1, h2, h3],
            filters: filtersUnmanaged,
            sortField: ItemHistorySortField.createdAt,
            ascending: false,
            departmentsEnabled: false,
          );
      expect(resUnmanaged.length, 1);
      expect(resUnmanaged.first.isManaged, isFalse);
    });

    test('Sorting by quantityChange and null-safety', () {
      final h1 = makeRecord(uuid: '1', quantityChange: 5.0);
      final h2 = makeRecord(uuid: '2', quantityChange: 0.0);
      final h3 = makeRecord(
        uuid: '3',
        quantityChange: null,
      );
      final h4 = makeRecord(
        uuid: '4',
        quantityChange: 20.0,
      );

      final sortedAsc =
          ItemHistoryReportQuery.filterAndSort(
            rows: [h1, h2, h3, h4],
            filters: ItemHistoryReportFilters(),
            sortField: ItemHistorySortField.quantityChange,
            ascending: true,
            departmentsEnabled: false,
          );

      // In ascending sort: 0.0, 5.0, 20.0, and null at the bottom
      expect(sortedAsc.map((r) => r.uuid).toList(), [
        '2',
        '1',
        '4',
        '3',
      ]);

      final sortedDesc =
          ItemHistoryReportQuery.filterAndSort(
            rows: [h1, h2, h3, h4],
            filters: ItemHistoryReportFilters(),
            sortField: ItemHistorySortField.quantityChange,
            ascending: false,
            departmentsEnabled: false,
          );

      // In descending sort: 20.0, 5.0, 0.0, and null still at the bottom
      expect(sortedDesc.map((r) => r.uuid).toList(), [
        '4',
        '1',
        '2',
        '3',
      ]);
    });

    test(
      'Sorting by oldValue numeric vs string handling',
      () {
        final h1 = makeRecord(uuid: '1', oldValue: '1,000');
        final h2 = makeRecord(uuid: '2', oldValue: '200');
        final h3 = makeRecord(
          uuid: '3',
          oldValue: 'Text Value',
        );
        final h4 = makeRecord(uuid: '4', oldValue: null);

        final sortedAsc =
            ItemHistoryReportQuery.filterAndSort(
              rows: [h1, h2, h3, h4],
              filters: ItemHistoryReportFilters(),
              sortField: ItemHistorySortField.oldValue,
              ascending: true,
              departmentsEnabled: false,
            );

        // Null should be at the bottom
        expect(sortedAsc.last.uuid, '4');
      },
    );

    test('Pagination and continuous indexing', () {
      final items = List.generate(
        250,
        (i) => makeRecord(
          uuid: 'uuid-$i',
          itemName: 'Item ${i.toString().padLeft(3, '0')}',
        ),
      );

      final page1 = ItemHistoryReportQuery.paginate(
        items,
        1,
      );
      expect(page1.page, 1);
      expect(page1.totalPages, 3);
      expect(page1.totalCount, 250);
      expect(page1.rows.length, 100);
      expect(page1.firstIndex, 1);
      expect(page1.lastIndex, 100);

      final page2 = ItemHistoryReportQuery.paginate(
        items,
        2,
      );
      expect(page2.page, 2);
      expect(page2.rows.length, 100);
      expect(page2.firstIndex, 101);
      expect(page2.lastIndex, 200);

      final page3 = ItemHistoryReportQuery.paginate(
        items,
        3,
      );
      expect(page3.page, 3);
      expect(page3.rows.length, 50);
      expect(page3.firstIndex, 201);
      expect(page3.lastIndex, 250);

      // Clamping page beyond totalPages
      final pageClamped = ItemHistoryReportQuery.paginate(
        items,
        10,
      );
      expect(pageClamped.page, 3);

      // Empty results
      final pageEmpty = ItemHistoryReportQuery.paginate(
        [],
        1,
      );
      expect(pageEmpty.page, 1);
      expect(pageEmpty.totalPages, 1);
      expect(pageEmpty.totalCount, 0);
      expect(pageEmpty.rows, isEmpty);
      expect(pageEmpty.firstIndex, 0);
      expect(pageEmpty.lastIndex, 0);
    });

    test('Event and Source formatting helpers', () {
      expect(
        ItemHistoryReportQuery.formatEventName('sale'),
        'Sale',
      );
      expect(
        ItemHistoryReportQuery.formatEventName('return'),
        'Return',
      );
      expect(
        ItemHistoryReportQuery.formatEventName(
          'quantity_increase',
        ),
        'Quantity Increase',
      );
      expect(
        ItemHistoryReportQuery.formatEventName(
          'custom_unknown_event',
        ),
        'Custom Unknown Event',
      );

      expect(
        ItemHistoryReportQuery.formatSourceOrDestination(
          'branch_store',
        ),
        'Branch Store',
      );
      expect(
        ItemHistoryReportQuery.formatSourceOrDestination(
          '',
        ),
        '—',
      );
    });

    test('Filter by QuantityDirectionFilter', () {
      final hIncrease = makeRecord(
        uuid: 'inc',
        quantityChange: 5.0,
        isIncreased: true,
      );
      final hDecrease = makeRecord(
        uuid: 'dec',
        quantityChange: 3.0,
        isIncreased: false,
      );
      final hZero = makeRecord(
        uuid: 'zero',
        quantityChange: 0.0,
        isIncreased: null,
      );

      final filtersInc =
          ItemHistoryReportFilters()
            ..quantityDirection =
                QuantityDirectionFilter.increase;
      final resInc = ItemHistoryReportQuery.filterAndSort(
        rows: [hIncrease, hDecrease, hZero],
        filters: filtersInc,
        sortField: ItemHistorySortField.createdAt,
        ascending: false,
        departmentsEnabled: false,
      );
      expect(resInc.length, 1);
      expect(resInc.first.uuid, 'inc');

      final filtersDec =
          ItemHistoryReportFilters()
            ..quantityDirection =
                QuantityDirectionFilter.decrease;
      final resDec = ItemHistoryReportQuery.filterAndSort(
        rows: [hIncrease, hDecrease, hZero],
        filters: filtersDec,
        sortField: ItemHistorySortField.createdAt,
        ascending: false,
        departmentsEnabled: false,
      );
      expect(resDec.length, 1);
      expect(resDec.first.uuid, 'dec');

      final filtersZero =
          ItemHistoryReportFilters()
            ..quantityDirection =
                QuantityDirectionFilter.zeroChange;
      final resZero = ItemHistoryReportQuery.filterAndSort(
        rows: [hIncrease, hDecrease, hZero],
        filters: filtersZero,
        sortField: ItemHistorySortField.createdAt,
        ascending: false,
        departmentsEnabled: false,
      );
      expect(resZero.length, 1);
      expect(resZero.first.uuid, 'zero');
    });
  });
}
