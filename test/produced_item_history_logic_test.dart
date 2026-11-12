import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_item_history/production_item_history_event_class.dart';
import 'package:stockall/pages/report/production_report/production_records_table/class/production_records_table_logic.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/production_stock_model.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/stock_history_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

import 'production_report_fixtures.dart';

const six = TimeOfDay(hour: 6, minute: 0);
final day2 = ReceiptsReportPeriod.day(DateTime(2026, 10, 2));

List<ProductionHistoryRow> historyRows() => ProductionHistoryRowBuilder.buildAll(
  entries: stockEntries(),
  items: stockItems(),
  categoryNames: sampleCategories(),
);

List<ProductionHistoryRow> historyQuery(
  List<ProductionHistoryRow> rows, {
  ReceiptsReportPeriod? period,
  ProductionHistoryFilters? filters,
  ProductionHistorySortField sortField = ProductionHistorySortField.date,
  bool ascending = false,
  bool departmentsEnabled = true,
  bool canSeeQuantity = true,
}) => ProductionHistoryQuery.filterAndSort(
  rows: rows,
  period: period ?? day2,
  filters: filters ?? ProductionHistoryFilters(),
  sortField: sortField,
  ascending: ascending,
  departmentsEnabled: departmentsEnabled,
  canSeeQuantity: canSeeQuantity,
  closingTime: six,
);

List<String> uuids(List<ProductionHistoryRow> rows) => [for (final r in rows) r.uuid];

ProductionHistoryRow rowOf(String uuid) =>
    historyRows().firstWhere((r) => r.uuid == uuid);

String n(num v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : '$v';

void main() {
  test('the day, newest first', () {
    expect(uuids(historyQuery(historyRows())), [
      'ph-2',
      'mh-gone',
      'ch-3',
      'ch-2',
      'ph-1',
      'ch-1',
    ]);
  });

  group('rows', () {
    test("Alex's transfer to sales: −15 Pcs, 30 → 15", () {
      final r = rowOf('ph-2');
      expect(r.eventLabel, 'Transferred to Sales');
      expect(r.primaryChange, -15);
      expect(r.direction, ProductionHistoryDirection.decrease);
      expect(productionHistoryChangeText(r, n), '-15 Pcs');
      expect(productionHistoryBalanceText(r, n), '30 → 15');
      expect(r.sourceLabel, 'Production Item');
      expect(r.destinationLabel, 'Product');
      expect(r.categoryKeys, [catPastry]);
    });

    test('a record in another unit shows both', () {
      expect(productionHistoryChangeText(rowOf('ph-3'), n), '+2 Box (24 Pcs)');
      // Not convertible: the recorded unit only.
      final tray = rowOf('ph-4');
      expect(tray.primaryChange, isNull);
      expect(productionHistoryChangeText(tray, n), '+1 Tray');
    });

    test('a legacy record and a deleted item', () {
      final legacy = rowOf('ch-1');
      expect(legacy.eventLabel, 'Produced');
      expect(legacy.primaryChange, 5);
      final gone = rowOf('mh-gone');
      expect(gone.item, isNull);
      expect(gone.itemName, 'Muffin');
      expect(gone.categoryKeys, isEmpty);
    });

    test('records that move nothing have no change', () {
      final created = ProductionHistoryRowBuilder.build(
        ProductionStockEntryFixture.created(),
        item: null,
        categoryNames: const {},
      );
      expect(created.direction, ProductionHistoryDirection.zero);
      expect(productionHistoryChangeText(created, n), '—');
    });
  });

  group('filters', () {
    final rows = historyRows();
    List<String> f(ProductionHistoryFilters filters, {bool departments = true}) =>
        uuids(historyQuery(rows, filters: filters, departmentsEnabled: departments))
          ..sort();

    test('item, event and direction', () {
      expect(f(ProductionHistoryFilters(itemKey: 'cake')), ['ch-1', 'ch-2', 'ch-3']);
      expect(
        f(ProductionHistoryFilters(eventKey: ProductionItemHistoryEventClass.productionCreated)),
        ['ch-1', 'mh-gone', 'ph-1'],
      );
      expect(
        f(ProductionHistoryFilters(direction: ProductionHistoryDirection.decrease)),
        ['ch-2', 'ch-3', 'ph-2'],
      );
    });

    test('source and destination', () {
      expect(f(ProductionHistoryFilters(source: 'manual')), ['ch-3']);
      expect(f(ProductionHistoryFilters(destination: 'product')), ['ph-2']);
    });

    test('staff and department, with the none keys', () {
      expect(f(ProductionHistoryFilters(staffKey: staffBen)), ['ch-1', 'ch-2']);
      expect(f(ProductionHistoryFilters(staffKey: productionReportNoneKey)), ['ch-3']);
      expect(
        f(ProductionHistoryFilters(departmentKey: productionReportNoneKey)),
        ['ch-3'],
      );
      expect(
        f(ProductionHistoryFilters(departmentKey: deptKitchen), departments: false),
        hasLength(6),
      );
    });

    test('managed and search (description included)', () {
      expect(f(ProductionHistoryFilters(managed: false)), isEmpty);
      expect(f(ProductionHistoryFilters(search: 'lekki')), ['ch-2']);
    });

    test('choices: staff and department none last', () {
      final c = ProductionHistoryFilterChoices.fromRows(rows);
      expect(c.staff.last.key, productionReportNoneKey);
      expect(c.departments.last.label, productionNoDepartmentLabel);
      expect([for (final o in c.items) o.label], ['Cake', 'Donut', 'Muffin']);
    });
  });

  group('sort and totals', () {
    test('by change, smallest first; ignored without the permission', () {
      final rows = historyRows();
      expect(
        uuids(
          historyQuery(
            rows,
            sortField: ProductionHistorySortField.change,
            ascending: true,
          ),
        ),
        ['ph-2', 'ch-3', 'ch-2', 'ch-1', 'mh-gone', 'ph-1'],
      );
      expect(
        uuids(
          historyQuery(
            rows,
            sortField: ProductionHistorySortField.change,
            canSeeQuantity: false,
          ),
        ).first,
        'ph-2',
      );
    });

    test('increases and decreases over every row', () {
      final p = ProductionHistoryQuery.paginate(historyQuery(historyRows()), 1);
      expect(p.totalCount, 6);
      expect(p.increases, 3);
      expect(p.decreases, 3);
    });

    test('Reset All', () {
      final s = ProductionHistoryTableState(
        filters: ProductionHistoryFilters(itemKey: 'cake', search: 'x'),
        sortField: ProductionHistorySortField.item,
      );
      expect(s.filters.activeCount, 1);
      s.resetAll();
      expect(s.filters.hasAnything, isFalse);
      expect(s.sortField, ProductionHistorySortField.item);
    });
  });
}

/// A record that moves no stock.
class ProductionStockEntryFixture {
  static ProductionStockEntry created() => stockEntries([
    stockRecord(
      uuid: 'c',
      title: 'Item Created',
      event: ProductionItemHistoryEventClass.itemCreated,
      createdAt: oct(2),
      quantityChange: 0,
      oldValue: '0',
      newValue: '0',
    ),
  ]).single;
}
