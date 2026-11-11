// The history table of the Produced Items and Materials pages (I3 /
// M3): one row per history record in the period. Pure Dart.

import 'package:flutter/material.dart' show TimeOfDay;
import 'package:stockall/pages/report/components/report_pager.dart';
import 'package:stockall/pages/report/production_report/production_records_table/class/production_records_table_logic.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/production_stock_model.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

const int productionHistoryPageSize = 100;

/// Which way a record moved the stock.
enum ProductionHistoryDirection { increase, decrease, zero }

extension ProductionHistoryDirectionLabel on ProductionHistoryDirection {
  String get label {
    switch (this) {
      case ProductionHistoryDirection.increase:
        return 'Increase';
      case ProductionHistoryDirection.decrease:
        return 'Decrease';
      case ProductionHistoryDirection.zero:
        return 'No Change';
    }
  }
}

/// One history row, with the item it belongs to when it still exists.
class ProductionHistoryRow {
  final ProductionStockEntry entry;
  final ProductionStockItem? item;
  final String itemName;
  final String eventLabel;

  /// The quantity moved, in the item's primary unit, signed by the
  /// direction. Null when the record can't be converted.
  final double? primaryChange;
  final String primaryUnit;
  final ProductionHistoryDirection direction;

  /// The item's categories that still exist.
  final List<String> categoryKeys;

  ProductionHistoryRow({
    required this.entry,
    required this.item,
    required this.itemName,
    required this.eventLabel,
    required this.primaryChange,
    required this.primaryUnit,
    required this.direction,
    required this.categoryKeys,
  });

  String get uuid => entry.uuid;
  DateTime get createdAt => entry.createdAt!;
  String? get itemKey => entry.itemUuid;
  String? get eventKey => entry.event;
  String? get staffKey => entry.staffId;
  String? get staffName => entry.staffName;
  String? get departmentKey => entry.departmentUuid;
  String? get departmentName => entry.departmentName;
  String get staffLabel => staffName ?? 'Not Set';
  String get departmentLabel =>
      departmentKey == null
          ? productionNoDepartmentLabel
          : departmentName ?? productionNoDepartmentLabel;
  String get sourceLabel => productionStockPlaceLabel(entry.source);
  String get destinationLabel => productionStockPlaceLabel(entry.destination);
  bool get isManaged => entry.isManaged ?? item?.isManaged ?? true;
}

class ProductionHistoryRowBuilder {
  static ProductionHistoryDirection direction(ProductionStockEntry e) {
    final o = e.oldPrimary;
    final n = e.newPrimary;
    if (o != null && n != null) {
      final d = n - o;
      if (d.abs() < 1e-9) return ProductionHistoryDirection.zero;
      return d > 0
          ? ProductionHistoryDirection.increase
          : ProductionHistoryDirection.decrease;
    }
    final qc = e.quantityChange;
    if (qc == 0) return ProductionHistoryDirection.zero;
    if (e.isIncreased == true) return ProductionHistoryDirection.increase;
    if (e.isIncreased == false) return ProductionHistoryDirection.decrease;
    if (qc != null) {
      return qc > 0
          ? ProductionHistoryDirection.increase
          : ProductionHistoryDirection.decrease;
    }
    return ProductionHistoryDirection.zero;
  }

  static ProductionHistoryRow build(
    ProductionStockEntry e, {
    required ProductionStockItem? item,
    required Map<String, String> categoryNames,
  }) {
    final dir = direction(e);
    final q = ProductionStockNormaliser.quantity(e, item);
    final moves = e.movement.isQuantityEvent;
    return ProductionHistoryRow(
      entry: e,
      item: item,
      itemName: item?.name ?? e.itemName ?? 'Not Set',
      eventLabel: productionStockEventLabel(e),
      primaryChange:
          !moves
              ? 0
              : q == null
              ? null
              : dir == ProductionHistoryDirection.decrease
              ? -q
              : q,
      primaryUnit: item?.primaryUnit ?? e.primaryUnit ?? e.unit ?? 'Unit(s)',
      direction: moves ? dir : ProductionHistoryDirection.zero,
      categoryKeys: [
        for (final id in item?.categoryUuids ?? const <String>[])
          if (categoryNames.containsKey(id)) id,
      ],
    );
  }

  /// Records without a date are left out.
  static List<ProductionHistoryRow> buildAll({
    required List<ProductionStockEntry> entries,
    required List<ProductionStockItem> items,
    required Map<String, String> categoryNames,
  }) {
    final byUuid = {for (final i in items) i.uuid: i};
    final rows = <ProductionHistoryRow>[];
    for (final e in entries) {
      if (e.createdAt == null) continue;
      try {
        rows.add(
          build(e, item: byUuid[e.itemUuid], categoryNames: categoryNames),
        );
      } catch (_) {
        // A single malformed record must never break the report.
      }
    }
    return rows;
  }
}

/// All filters, combined with AND. Staff and department keys can be
/// [productionReportNoneKey].
class ProductionHistoryFilters {
  String search;
  String? itemKey;

  /// A raw event ("production_created") from `eventOf`.
  String? eventKey;
  ProductionHistoryDirection? direction;
  String? source;
  String? destination;
  String? staffKey;
  String? departmentKey;
  bool? managed;

  ProductionHistoryFilters({
    this.search = '',
    this.itemKey,
    this.eventKey,
    this.direction,
    this.source,
    this.destination,
    this.staffKey,
    this.departmentKey,
    this.managed,
  });

  ProductionHistoryFilters copy() => ProductionHistoryFilters(
    search: search,
    itemKey: itemKey,
    eventKey: eventKey,
    direction: direction,
    source: source,
    destination: destination,
    staffKey: staffKey,
    departmentKey: departmentKey,
    managed: managed,
  );

  int get activeCount =>
      (itemKey != null ? 1 : 0) +
      (eventKey != null ? 1 : 0) +
      (direction != null ? 1 : 0) +
      (source != null ? 1 : 0) +
      (destination != null ? 1 : 0) +
      (staffKey != null ? 1 : 0) +
      (departmentKey != null ? 1 : 0) +
      (managed != null ? 1 : 0);

  bool get hasAnything => activeCount > 0 || search.trim().isNotEmpty;

  void clearAll() {
    search = '';
    itemKey = null;
    eventKey = null;
    direction = null;
    source = null;
    destination = null;
    staffKey = null;
    departmentKey = null;
    managed = null;
  }

  bool matches(ProductionHistoryRow r, {required bool departmentsEnabled}) {
    final q = search.trim().toLowerCase();
    if (q.isNotEmpty) {
      bool has(String? s) => s != null && s.toLowerCase().contains(q);
      final e = r.entry;
      if (!has(r.itemName) &&
          !has(e.title) &&
          !has(r.eventLabel) &&
          !has(r.staffName) &&
          !(departmentsEnabled && has(r.departmentName)) &&
          !has(e.desc) &&
          !has(r.sourceLabel) &&
          !has(r.destinationLabel)) {
        return false;
      }
    }
    if (itemKey != null && r.itemKey != itemKey) return false;
    if (eventKey != null && r.eventKey != eventKey) return false;
    if (direction != null && r.direction != direction) return false;
    if (source != null && r.entry.source != source) return false;
    if (destination != null && r.entry.destination != destination) return false;
    if (!ProductionRecordsFilters.keyMatches(staffKey, r.staffKey)) return false;
    if (departmentsEnabled &&
        !ProductionRecordsFilters.keyMatches(departmentKey, r.departmentKey)) {
      return false;
    }
    if (managed != null && r.isManaged != managed) return false;
    return true;
  }
}

/// Filter choices from the rows; staff and department get a none
/// choice when a row has none.
class ProductionHistoryFilterChoices {
  final List<ProductionFilterOption> items;
  final List<ProductionFilterOption> events;
  final List<ProductionFilterOption> sources;
  final List<ProductionFilterOption> destinations;
  final List<ProductionFilterOption> staff;
  final List<ProductionFilterOption> departments;

  const ProductionHistoryFilterChoices({
    required this.items,
    required this.events,
    required this.sources,
    required this.destinations,
    required this.staff,
    required this.departments,
  });

  static const empty = ProductionHistoryFilterChoices(
    items: [],
    events: [],
    sources: [],
    destinations: [],
    staff: [],
    departments: [],
  );

  factory ProductionHistoryFilterChoices.fromRows(
    List<ProductionHistoryRow> rows,
  ) {
    final newest = List<ProductionHistoryRow>.from(rows)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final items = <String, String>{};
    final events = <String, String>{};
    final sources = <String, String>{};
    final destinations = <String, String>{};
    final staff = <String, String>{};
    final departments = <String, String>{};
    var noStaff = false;
    var noDepartment = false;
    for (final r in newest) {
      if (r.itemKey != null) items.putIfAbsent(r.itemKey!, () => r.itemName);
      if (r.eventKey != null) events.putIfAbsent(r.eventKey!, () => r.eventLabel);
      final s = r.entry.source;
      if (s != null) sources.putIfAbsent(s, () => r.sourceLabel);
      final d = r.entry.destination;
      if (d != null) destinations.putIfAbsent(d, () => r.destinationLabel);
      if (r.staffKey == null) {
        noStaff = true;
      } else {
        staff.putIfAbsent(r.staffKey!, () => r.staffLabel);
      }
      if (r.departmentKey == null) {
        noDepartment = true;
      } else {
        departments.putIfAbsent(r.departmentKey!, () => r.departmentLabel);
      }
    }
    List<ProductionFilterOption> sorted(
      Map<String, String> m, [
      String? noneLabel,
    ]) {
      final out =
          m.entries.map((e) => ProductionFilterOption(e.key, e.value)).toList()
            ..sort((a, b) {
              final c = a.label.toLowerCase().compareTo(b.label.toLowerCase());
              return c != 0 ? c : a.key.compareTo(b.key);
            });
      if (noneLabel != null) {
        out.add(ProductionFilterOption(productionReportNoneKey, noneLabel));
      }
      return out;
    }

    return ProductionHistoryFilterChoices(
      items: sorted(items),
      events: sorted(events),
      sources: sorted(sources),
      destinations: sorted(destinations),
      staff: sorted(staff, noStaff ? productionNoStaffLabel : null),
      departments: sorted(
        departments,
        noDepartment ? productionNoDepartmentLabel : null,
      ),
    );
  }
}

enum ProductionHistorySortField { date, item, event, change, staff, department }

/// Result of [ProductionHistoryQuery.paginate].
class ProductionHistoryPage {
  final List<ProductionHistoryRow> rows;
  final int totalCount;
  final int page;
  final int totalPages;

  /// Records that increased / decreased the stock, over every row.
  final int increases;
  final int decreases;

  const ProductionHistoryPage({
    required this.rows,
    required this.totalCount,
    required this.page,
    required this.totalPages,
    this.increases = 0,
    this.decreases = 0,
  });

  int get firstIndex =>
      totalCount == 0 ? 0 : (page - 1) * productionHistoryPageSize + 1;
  int get lastIndex => firstIndex == 0 ? 0 : firstIndex + rows.length - 1;
}

class ProductionHistoryQuery {
  /// Rows in [period], filtered and sorted. The change sort is ignored
  /// without [canSeeQuantity].
  static List<ProductionHistoryRow> filterAndSort({
    required List<ProductionHistoryRow> rows,
    required ReceiptsReportPeriod period,
    required ProductionHistoryFilters filters,
    required ProductionHistorySortField sortField,
    required bool ascending,
    required bool departmentsEnabled,
    required bool canSeeQuantity,
    TimeOfDay? closingTime,
  }) {
    final cmp = ProductionRecordsQuery.cmp;
    final out =
        rows
            .where(
              (r) =>
                  period.contains(r.createdAt, closingTime: closingTime) &&
                  filters.matches(r, departmentsEnabled: departmentsEnabled),
            )
            .toList();
    final field =
        sortField == ProductionHistorySortField.change && !canSeeQuantity
            ? ProductionHistorySortField.date
            : sortField;
    out.sort((a, b) {
      int c;
      switch (field) {
        case ProductionHistorySortField.date:
          c = cmp(a.createdAt, b.createdAt, ascending);
          break;
        case ProductionHistorySortField.item:
          c = cmp(a.itemName.toLowerCase(), b.itemName.toLowerCase(), ascending);
          break;
        case ProductionHistorySortField.event:
          c = cmp(a.eventLabel.toLowerCase(), b.eventLabel.toLowerCase(), ascending);
          break;
        case ProductionHistorySortField.change:
          c = cmp(a.primaryChange, b.primaryChange, ascending);
          break;
        case ProductionHistorySortField.staff:
          c = cmp(a.staffName?.toLowerCase(), b.staffName?.toLowerCase(), ascending);
          break;
        case ProductionHistorySortField.department:
          c = cmp(
            a.departmentKey == null ? null : a.departmentLabel.toLowerCase(),
            b.departmentKey == null ? null : b.departmentLabel.toLowerCase(),
            ascending,
          );
          break;
      }
      if (c != 0) return c;
      final t = b.createdAt.compareTo(a.createdAt);
      return t != 0 ? t : a.uuid.compareTo(b.uuid);
    });
    return out;
  }

  static ProductionHistoryPage paginate(
    List<ProductionHistoryRow> sorted,
    int requestedPage,
  ) {
    final b = reportPageBounds(
      sorted.length,
      requestedPage,
      pageSize: productionHistoryPageSize,
    );
    var up = 0;
    var down = 0;
    for (final r in sorted) {
      if (r.direction == ProductionHistoryDirection.increase) up++;
      if (r.direction == ProductionHistoryDirection.decrease) down++;
    }
    return ProductionHistoryPage(
      rows: sorted.isEmpty ? const [] : sorted.sublist(b.start, b.end),
      totalCount: sorted.length,
      page: b.page,
      totalPages: b.pages,
      increases: up,
      decreases: down,
    );
  }
}

/// Filters, sort and page of the history table.
class ProductionHistoryTableState {
  final ProductionHistoryFilters filters;
  ProductionHistorySortField sortField;
  bool ascending;
  int page;

  ProductionHistoryTableState({
    ProductionHistoryFilters? filters,
    this.sortField = ProductionHistorySortField.date,
    this.ascending = false,
    this.page = 1,
  }) : filters = filters ?? ProductionHistoryFilters();

  void resetAll() {
    filters.clearAll();
    page = 1;
  }
}

/// The Change cell: "+3 Box (36 Pcs)", "-15 Pcs", or "—" when nothing
/// moved. [number] formats the values.
String productionHistoryChangeText(
  ProductionHistoryRow r,
  String Function(num v) number,
) {
  if (!r.entry.movement.isQuantityEvent) return '—';
  final sign = r.direction == ProductionHistoryDirection.decrease ? '-' : '+';
  final qc = r.entry.quantityChange?.abs();
  final unit = r.entry.unit;
  final p = r.primaryChange?.abs();
  final primary = p == null ? null : '${number(p)} ${r.primaryUnit}';
  if (qc != null && unit != null && unit.toLowerCase() != r.primaryUnit.toLowerCase()) {
    final recorded = '$sign${number(qc)} $unit';
    return primary == null ? recorded : '$recorded ($primary)';
  }
  if (primary != null) return '$sign$primary';
  if (qc != null) return '$sign${number(qc)} ${unit ?? r.primaryUnit}';
  return '—';
}

/// "30 → 15", in the primary unit.
String productionHistoryBalanceText(
  ProductionHistoryRow r,
  String Function(num v) number,
) {
  final o = r.entry.oldPrimary;
  final n = r.entry.newPrimary;
  if (o == null && n == null) return '—';
  String t(double? v) => v == null ? '—' : number(v);
  return '${t(o)} → ${t(n)}';
}
