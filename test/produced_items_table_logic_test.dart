import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_item_history/production_item_history.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_item_history/production_item_history_event_class.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_items/production_item.dart';
import 'package:stockall/pages/report/production_report/production_records_table/class/production_records_table_logic.dart';
import 'package:stockall/pages/report/production_report/shared/class/production_report_access.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/production_stock_model.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/stock_items_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

import 'production_report_fixtures.dart';

const six = TimeOfDay(hour: 6, minute: 0);
final day2 = ReceiptsReportPeriod.day(DateTime(2026, 10, 2));
final day3 = ReceiptsReportPeriod.day(DateTime(2026, 10, 3));

/// The table's rows for [period], as the view builds them.
List<ProductionStockRow> stockRows({
  ReceiptsReportPeriod? period,
  bool historyAllowed = true,
  List<ProductionItem>? items,
  List<ProductionItemHistory>? history,
}) => ProductionStockRowBuilder.buildAll(
  items: stockItems(items),
  entries: stockEntries(history),
  categoryNames: sampleCategories(),
  period: period ?? day2,
  businessNow: stockNow,
  historyAllowed: historyAllowed,
  closingTime: six,
);

List<ProductionStockRow> stockQuery(
  List<ProductionStockRow> rows, {
  ProductionStockFilters? filters,
  ProductionStockSort sort = ProductionStockSort.byName,
  bool departmentsEnabled = true,
  bool canSeeCost = true,
  bool canSeeQuantity = true,
}) => ProductionStockQuery.filterAndSort(
  rows: rows,
  filters: filters ?? ProductionStockFilters(),
  sort: sort,
  departmentsEnabled: departmentsEnabled,
  canSeeCost: canSeeCost,
  canSeeQuantity: canSeeQuantity,
);

List<String> uuids(List<ProductionStockRow> rows) => [for (final r in rows) r.uuid];

ProductionStockRow rowOf(List<ProductionStockRow> rows, String uuid) =>
    rows.firstWhere((r) => r.uuid == uuid);

void main() {
  group('rows', () {
    final rows = stockRows();

    test('stock, cost, value, categories and expiry', () {
      final d = rowOf(rows, 'donut');
      expect(d.quantity, 15);
      expect(d.primaryUnit, 'Pcs');
      expect(d.costPrice, 200);
      expect(d.stockValue, 3000);
      expect(d.categoryNames, ['Pastry']);
      expect(d.isExpired, isFalse);
      expect(d.stockLevel, ProductionStockLevel.inStock);
      final cake = rowOf(rows, 'cake');
      // The deleted category is left out.
      expect(cake.categoryKeys, [catPastry]);
      expect(cake.isExpired, isTrue);
      expect(cake.stockLevel, ProductionStockLevel.out);
    });

    test('an unmanaged item has no stock or value', () {
      final j = rowOf(rows, 'juice-base');
      expect(j.quantity, isNull);
      expect(j.stockValue, isNull);
      expect(j.stockLevel, isNull);
      expect(j.categoryLabel, 'No Category');
      expect(j.departmentLabel, productionNoDepartmentLabel);
    });
  });

  group('period movement', () {
    test("Alex's donuts: +30 produced, −15 to sales, closing 15", () {
      final d = rowOf(stockRows(), 'donut');
      expect(d.balance.opening, 0);
      expect(d.movement.of(ProductionMovementKind.produced), 30);
      expect(d.movement.of(ProductionMovementKind.transferredToSales), 15);
      expect(d.movement.net, 15);
      expect(d.balance.closing, 15);
    });

    test('legacy records: produced, to a branch, and by hand', () {
      final c = rowOf(stockRows(), 'cake');
      expect(c.movement.of(ProductionMovementKind.produced), 5);
      expect(c.movement.of(ProductionMovementKind.transferredToBranch), 2);
      expect(c.movement.of(ProductionMovementKind.adjustedDown), 3);
      expect(c.balance.opening, 0);
      expect(c.balance.closing, 0);
    });

    test('3 Oct: a Box record converted; one record not converted', () {
      final rows = stockRows(period: day3);
      final d = rowOf(rows, 'donut');
      expect(d.movement.of(ProductionMovementKind.produced), 24);
      expect(d.movement.notNormalised, 1);
      expect(productionStockNotNormalised(rows), 1);
    });

    test('the business day runs from the closing time', () {
      final rows = stockRows(
        history: [
          ...sampleProducedHistory(),
          stockRecord(
            uuid: 'late',
            title: 'Item Quantity Increased',
            event: ProductionItemHistoryEventClass.quantityUpdatedIncrease,
            createdAt: oct(3, 3),
            quantityChange: 2,
            oldValue: '15',
            newValue: '17',
            isIncreased: true,
          ),
        ],
      );
      // 03:00 on 3 Oct still belongs to 2 Oct.
      final d = rowOf(rows, 'donut');
      expect(d.movement.of(ProductionMovementKind.adjustedUp), 2);
      expect(d.balance.closing, 17);
    });

    test('without history access: no movement', () {
      final d = rowOf(stockRows(historyAllowed: false), 'donut');
      expect(d.movement.hasMovement, isFalse);
      expect(d.balance.opening, isNull);
    });

    test('history scope: the Kitchen sees its records and unassigned ones', () {
      final scoped = ProductionReportAccess.scopeStock(
        records: stockEntries(),
        departmentOf: (e) => e.departmentUuid,
        departmentsEnabled: true,
        canViewAllDepartments: false,
        currentDepartmentUuid: deptKitchen,
      );
      expect([for (final e in scoped) e.uuid], ['ch-1', 'ch-2', 'ch-3']);
    });
  });

  group('filters', () {
    final rows = stockRows();
    List<String> f(
      ProductionStockFilters filters, {
      bool departments = true,
      bool cost = true,
      bool qty = true,
    }) =>
        uuids(
          stockQuery(
            rows,
            filters: filters,
            departmentsEnabled: departments,
            canSeeCost: cost,
            canSeeQuantity: qty,
          ),
        )..sort();

    test('search, item, category and the none category', () {
      expect(f(ProductionStockFilters(search: 'pas')), ['cake', 'donut']);
      expect(f(ProductionStockFilters(itemKey: 'cake')), ['cake']);
      expect(f(ProductionStockFilters(categoryKey: catPastry)), ['cake', 'donut']);
      expect(
        f(ProductionStockFilters(categoryKey: productionReportNoneKey)),
        ['juice-base'],
      );
    });

    test('department, with none; ignored with departments off', () {
      expect(f(ProductionStockFilters(departmentKey: deptKitchen)), ['cake']);
      expect(
        f(ProductionStockFilters(departmentKey: productionReportNoneKey)),
        ['juice-base'],
      );
      expect(
        f(ProductionStockFilters(departmentKey: deptKitchen), departments: false),
        hasLength(3),
      );
    });

    test('stock level and managed', () {
      expect(f(ProductionStockFilters(stockLevel: ProductionStockLevel.out)), ['cake']);
      expect(f(ProductionStockFilters(stockLevel: ProductionStockLevel.out), qty: false), hasLength(3));
      expect(f(ProductionStockFilters(managed: false)), ['juice-base']);
    });

    test('cost and stock ranges need their permissions', () {
      final cost = ProductionStockFilters(costMin: 100, costMax: 500);
      expect(f(cost), ['donut']);
      expect(f(cost, cost: false), hasLength(3));
      final qty = ProductionStockFilters(quantityMin: 10, quantityMax: 20);
      // The unmanaged item has no stock to compare.
      expect(f(qty), ['donut']);
      expect(f(qty, qty: false), hasLength(3));
    });

    test('expiry range', () {
      final e = ProductionStockFilters(
        expiryStart: DateTime(2026, 10, 1),
        expiryEnd: DateTime(2026, 10, 10),
      );
      expect(f(e), ['cake']);
      final bad = ProductionStockFilters(
        expiryStart: DateTime(2026, 10, 10),
        expiryEnd: DateTime(2026, 10, 1),
      );
      expect(bad.expiryRangeError, isNotNull);
      expect(f(bad), hasLength(3));
    });

    test('choices, with none last', () {
      final c = ProductionStockFilterChoices.fromRows(rows);
      expect([for (final o in c.categories) o.label], ['Pastry', 'No Category']);
      expect([for (final o in c.departments) o.label], [
        'Bakery',
        'Kitchen',
        productionNoDepartmentLabel,
      ]);
      expect([for (final o in c.items) o.label], ['Cake', 'Donut', 'Juice Base']);
    });

    test('activeCount and Reset All keeps the sort', () {
      final state = ProductionStockTableState(
        filters: ProductionStockFilters(
          search: 'x',
          categoryKey: catPastry,
          managed: true,
          costMin: 1,
        ),
        sort: const ProductionStockSort(ProductionStockSortField.quantity),
        page: 3,
      );
      expect(state.filters.activeCount, 3);
      state.resetAll();
      expect(state.filters.hasAnything, isFalse);
      expect(state.sort.field, ProductionStockSortField.quantity);
      expect(state.page, 1);
    });
  });

  group('sort', () {
    final rows = stockRows();

    test('stock, nulls last', () {
      expect(
        uuids(
          stockQuery(
            rows,
            sort: const ProductionStockSort(ProductionStockSortField.quantity),
          ),
        ),
        ['cake', 'donut', 'juice-base'],
      );
    });

    test('a movement column, largest first', () {
      expect(
        uuids(
          stockQuery(
            rows,
            sort: const ProductionStockSort(
              ProductionStockSortField.movement,
              movement: ProductionMovementKind.produced,
              ascending: false,
            ),
          ),
        ).first,
        'donut',
      );
    });

    test('a hidden column sorts by name', () {
      final s = const ProductionStockSort(
        ProductionStockSortField.stockValue,
        ascending: false,
      );
      expect(uuids(stockQuery(rows, sort: s, canSeeCost: false)), [
        'cake',
        'donut',
        'juice-base',
      ]);
    });

    test('stock value needs the quantity permission too', () {
      const s = ProductionStockSort(
        ProductionStockSortField.stockValue,
        ascending: false,
      );
      // An unmanaged item has no value: it sinks.
      expect(uuids(stockQuery(rows, sort: s)), ['donut', 'cake', 'juice-base']);
      // Cost × quantity would give away the hidden stock: by name.
      expect(uuids(stockQuery(rows, sort: s, canSeeQuantity: false)), [
        'cake',
        'donut',
        'juice-base',
      ]);
    });
  });

  test('totals cover every page; no quantity sums', () {
    final rows = stockQuery(
      stockRows(items: manyProducedItems(150), history: const []),
    );
    final p2 = ProductionStockQuery.paginate(rows, 2);
    expect(p2.rows, hasLength(50));
    expect(p2.firstIndex, 101);
    expect(p2.totalCount, 150);
    expect(p2.managedCount, 150);
    // Σ (150 − i) × ₦10, i = 1…150.
    expect(p2.totalStockValue, 10 * (149 * 150 / 2));
  });
}
