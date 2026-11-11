// The history summary of the Produced Items and Materials pages (I4 /
// M4): one row per item with its opening and closing stock and the
// movement of the period, by kind. Pure Dart.

import 'package:flutter/material.dart' show TimeOfDay;
import 'package:stockall/pages/report/components/report_pager.dart';
import 'package:stockall/pages/report/production_report/production_records_table/class/production_records_table_logic.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/production_stock_model.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/stock_analysis_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

const int productionHistorySummaryPageSize = 100;

/// The movement filter of the Items history summary.
enum ProductionHistoryMovementFilter {
  all,
  hasMovement,
  inflowOnly,
  outflowOnly,
  noChange,
}

extension ProductionHistoryMovementFilterLabel
    on ProductionHistoryMovementFilter {
  String get label {
    switch (this) {
      case ProductionHistoryMovementFilter.all:
        return 'All Items';
      case ProductionHistoryMovementFilter.hasMovement:
        return 'With Movement';
      case ProductionHistoryMovementFilter.inflowOnly:
        return 'Inflow Only';
      case ProductionHistoryMovementFilter.outflowOnly:
        return 'Outflow Only';
      case ProductionHistoryMovementFilter.noChange:
        return 'Zero Change';
    }
  }
}

/// One row: an item (or a deleted item, named from its history).
class ProductionHistorySummaryRow {
  final String key;
  final String name;

  /// Null for a deleted item.
  final ProductionStockItem? item;
  final String primaryUnit;
  final ProductionStockBalance balance;
  final ProductionMovementTotals totals;
  final List<String> categoryKeys;

  ProductionHistorySummaryRow({
    required this.key,
    required this.name,
    required this.item,
    required this.primaryUnit,
    required this.balance,
    required this.totals,
    required this.categoryKeys,
  });

  bool get exists => item != null;
  String? get departmentKey => item?.departmentUuid;
  String get departmentLabel =>
      departmentKey == null
          ? productionNoDepartmentLabel
          : item?.departmentName ?? productionNoDepartmentLabel;

  double of(ProductionMovementKind k) => totals.of(k);
  double get netProduced => totals.netProduced;
  double get additions => totals.additions;
  double get reductions => totals.reductions;
  double get net => totals.net;
  int get events => totals.eventCount;
  int get created => totals.countOf(ProductionMovementKind.created);
  int get deleted => totals.countOf(ProductionMovementKind.deleted);
  bool get hasMovement => totals.hasMovement;
}

/// Overall figures of the period, over every row (filters only narrow
/// the table, as on the Items summary). Quantities are kept per unit.
class ProductionHistorySummaryStats {
  final int totalItems;
  final int itemsWithMovement;
  final int events;
  final int notNormalised;

  /// Per movement kind: quantity by primary unit.
  final Map<ProductionMovementKind, Map<String, double>> byKind;
  final Map<String, double> additions;
  final Map<String, double> reductions;
  final Map<String, double> net;

  const ProductionHistorySummaryStats({
    required this.totalItems,
    required this.itemsWithMovement,
    required this.events,
    required this.notNormalised,
    required this.byKind,
    required this.additions,
    required this.reductions,
    required this.net,
  });

  Map<String, double> of(ProductionMovementKind k) => byKind[k] ?? const {};

  /// Net produced (produced minus production deleted), per unit.
  Map<String, double> get netProduced {
    final out = <String, double>{...of(ProductionMovementKind.produced)};
    of(ProductionMovementKind.productionDeleted).forEach(
      (u, v) => out[u] = (out[u] ?? 0) - v,
    );
    return out;
  }

  static ProductionHistorySummaryStats fromRows(
    List<ProductionHistorySummaryRow> rows,
  ) {
    final byKind = <ProductionMovementKind, Map<String, double>>{};
    final add = <String, double>{};
    final red = <String, double>{};
    final net = <String, double>{};
    var events = 0;
    var notNormalised = 0;
    var moved = 0;
    for (final r in rows) {
      events += r.events;
      notNormalised += r.totals.notNormalised;
      if (r.hasMovement) moved++;
      final u = r.primaryUnit;
      r.totals.quantities.forEach((k, v) {
        final m = byKind.putIfAbsent(k, () => {});
        m[u] = (m[u] ?? 0) + v;
      });
      add[u] = (add[u] ?? 0) + r.additions;
      red[u] = (red[u] ?? 0) + r.reductions;
      net[u] = (net[u] ?? 0) + r.net;
    }
    return ProductionHistorySummaryStats(
      totalItems: rows.length,
      itemsWithMovement: moved,
      events: events,
      notNormalised: notNormalised,
      byKind: byKind,
      additions: add,
      reductions: red,
      net: net,
    );
  }
}

class ProductionHistorySummaryFilters {
  String search;
  ProductionHistoryMovementFilter movement;

  ProductionHistorySummaryFilters({
    this.search = '',
    this.movement = ProductionHistoryMovementFilter.all,
  });

  ProductionHistorySummaryFilters copy() =>
      ProductionHistorySummaryFilters(search: search, movement: movement);

  int get activeCount =>
      movement != ProductionHistoryMovementFilter.all ? 1 : 0;

  bool get hasAnything => activeCount > 0 || search.trim().isNotEmpty;

  void clearAll() {
    search = '';
    movement = ProductionHistoryMovementFilter.all;
  }

  bool matches(ProductionHistorySummaryRow r) {
    final q = search.trim().toLowerCase();
    if (q.isNotEmpty &&
        !r.name.toLowerCase().contains(q) &&
        !r.primaryUnit.toLowerCase().contains(q)) {
      return false;
    }
    switch (movement) {
      case ProductionHistoryMovementFilter.all:
        return true;
      case ProductionHistoryMovementFilter.hasMovement:
        return r.hasMovement;
      case ProductionHistoryMovementFilter.inflowOnly:
        return r.additions > 0;
      case ProductionHistoryMovementFilter.outflowOnly:
        return r.reductions > 0;
      case ProductionHistoryMovementFilter.noChange:
        return r.net == 0;
    }
  }
}

/// A sortable column: [movement] for movement kind columns.
enum ProductionHistorySummarySortField {
  name,
  opening,
  closing,
  movement,
  netProduced,
  created,
  deleted,
  additions,
  reductions,
  net,
  events,
}

class ProductionHistorySummarySort {
  final ProductionHistorySummarySortField field;
  final ProductionMovementKind? movement;
  final bool ascending;

  const ProductionHistorySummarySort(
    this.field, {
    this.movement,
    this.ascending = true,
  });

  static const byName = ProductionHistorySummarySort(
    ProductionHistorySummarySortField.name,
  );

  bool sameColumn(ProductionHistorySummarySortField f, [ProductionMovementKind? m]) =>
      field == f && movement == m;

  /// Every field but the name and the counts shows a quantity.
  bool get isQuantity =>
      field != ProductionHistorySummarySortField.name &&
      field != ProductionHistorySummarySortField.created &&
      field != ProductionHistorySummarySortField.deleted &&
      field != ProductionHistorySummarySortField.events;
}

class ProductionHistorySummaryPage {
  final List<ProductionHistorySummaryRow> rows;
  final int totalCount;
  final int page;
  final int totalPages;
  final int totalEvents;

  const ProductionHistorySummaryPage({
    required this.rows,
    required this.totalCount,
    required this.page,
    required this.totalPages,
    this.totalEvents = 0,
  });

  int get firstIndex =>
      totalCount == 0 ? 0 : (page - 1) * productionHistorySummaryPageSize + 1;
  int get lastIndex => firstIndex == 0 ? 0 : firstIndex + rows.length - 1;
}

class ProductionHistorySummaryBuilder {
  /// An item that no longer exists, named and united from its latest
  /// record; its balance is read from the history alone.
  static ProductionStockItem _ghost(
    ProductionStockKind kind,
    String uuid,
    List<ProductionStockEntry> entries,
  ) {
    final newest = List<ProductionStockEntry>.from(entries)
      ..sort(
        (a, b) => (b.createdAt ?? DateTime(1970)).compareTo(
          a.createdAt ?? DateTime(1970),
        ),
      );
    String? name;
    String? unit;
    for (final e in newest) {
      name ??= e.itemName;
      unit ??= e.primaryUnit;
    }
    return ProductionStockItem(
      kind: kind,
      uuid: uuid,
      name: name ?? 'Deleted ${kind.singular.toLowerCase()}',
      unit: unit,
      unitsList: null,
      costPrice: 0,
      quantity: null,
      departmentUuid: null,
      departmentName: null,
      categoryUuids: const [],
      expiryDate: null,
      isManaged: true,
      createdAt: null,
    );
  }

  /// One row per existing item, plus deleted items with records in the
  /// period.
  static List<ProductionHistorySummaryRow> build({
    required ProductionStockKind kind,
    required List<ProductionStockItem> items,
    required List<ProductionStockEntry> entries,
    required Map<String, String> categoryNames,
    required ReceiptsReportPeriod period,
    TimeOfDay? closingTime,
  }) {
    final byItem = productionEntriesByItem(entries);
    final rows = <ProductionHistorySummaryRow>[];
    final seen = <String>{};

    ProductionHistorySummaryRow row(
      ProductionStockItem item,
      List<ProductionStockEntry> list, {
      required bool exists,
    }) {
      return ProductionHistorySummaryRow(
        key: item.uuid,
        name: item.name,
        item: exists ? item : null,
        primaryUnit: item.primaryUnit,
        balance: ProductionStockMovementCalculator.balance(
          item: item,
          entries: list,
          period: period,
          closingTime: closingTime,
        ),
        totals: ProductionStockMovementCalculator.totals(
          item: exists ? item : null,
          entries: list,
          period: period,
          closingTime: closingTime,
        ),
        categoryKeys: [
          for (final id in item.categoryUuids)
            if (categoryNames.containsKey(id)) id,
        ],
      );
    }

    for (final item in items) {
      if (item.uuid.isEmpty || !seen.add(item.uuid)) continue;
      rows.add(row(item, byItem[item.uuid] ?? const [], exists: true));
    }
    byItem.forEach((uuid, list) {
      if (seen.contains(uuid)) return;
      final inPeriod = list.any(
        (e) =>
            e.createdAt != null &&
            period.contains(e.createdAt!, closingTime: closingTime),
      );
      if (!inPeriod) return;
      rows.add(row(_ghost(kind, uuid, list), list, exists: false));
    });
    return rows;
  }

  static Comparable? _value(
    ProductionHistorySummaryRow r,
    ProductionHistorySummarySort s,
  ) {
    switch (s.field) {
      case ProductionHistorySummarySortField.name:
        return r.name.toLowerCase();
      case ProductionHistorySummarySortField.opening:
        return r.balance.opening;
      case ProductionHistorySummarySortField.closing:
        return r.balance.closing;
      case ProductionHistorySummarySortField.movement:
        return s.movement == null ? null : r.of(s.movement!);
      case ProductionHistorySummarySortField.netProduced:
        return r.netProduced;
      case ProductionHistorySummarySortField.created:
        return r.created;
      case ProductionHistorySummarySortField.deleted:
        return r.deleted;
      case ProductionHistorySummarySortField.additions:
        return r.additions;
      case ProductionHistorySummarySortField.reductions:
        return r.reductions;
      case ProductionHistorySummarySortField.net:
        return r.net;
      case ProductionHistorySummarySortField.events:
        return r.events;
    }
  }

  static List<ProductionHistorySummaryRow> filterAndSort({
    required List<ProductionHistorySummaryRow> rows,
    required ProductionHistorySummaryFilters filters,
    required ProductionHistorySummarySort sort,
    required bool canSeeQuantity,
  }) {
    final out = rows.where(filters.matches).toList();
    final s =
        sort.isQuantity && !canSeeQuantity
            ? ProductionHistorySummarySort.byName
            : sort;
    out.sort((a, b) {
      final c = ProductionRecordsQuery.cmp(_value(a, s), _value(b, s), s.ascending);
      if (c != 0) return c;
      final n = a.name.toLowerCase().compareTo(b.name.toLowerCase());
      return n != 0 ? n : a.key.compareTo(b.key);
    });
    return out;
  }

  static ProductionHistorySummaryPage paginate(
    List<ProductionHistorySummaryRow> sorted,
    int requestedPage,
  ) {
    final b = reportPageBounds(
      sorted.length,
      requestedPage,
      pageSize: productionHistorySummaryPageSize,
    );
    return ProductionHistorySummaryPage(
      rows: sorted.isEmpty ? const [] : sorted.sublist(b.start, b.end),
      totalCount: sorted.length,
      page: b.page,
      totalPages: b.pages,
      totalEvents: sorted.fold(0, (s, r) => s + r.events),
    );
  }
}

class ProductionHistorySummaryState {
  final ProductionHistorySummaryFilters filters;
  ProductionHistorySummarySort sort;
  int page;

  ProductionHistorySummaryState({
    ProductionHistorySummaryFilters? filters,
    this.sort = ProductionHistorySummarySort.byName,
    this.page = 1,
  }) : filters = filters ?? ProductionHistorySummaryFilters();

  void resetAll() {
    filters.clearAll();
    page = 1;
  }
}

/// The movement columns of the summary for [kind], in table order. Net
/// produced follows production deleted for produced items.
List<ProductionMovementKind> productionSummaryMovementColumns(
  ProductionStockKind kind,
) {
  if (kind == ProductionStockKind.producedItem) {
    return const [
      ProductionMovementKind.produced,
      ProductionMovementKind.productionDeleted,
      ProductionMovementKind.transferredToSales,
      ProductionMovementKind.transferredToBranch,
      ProductionMovementKind.transferredIn,
      ProductionMovementKind.adjustedUp,
      ProductionMovementKind.adjustedDown,
    ];
  }
  return const [
    ProductionMovementKind.used,
    ProductionMovementKind.restored,
    ProductionMovementKind.transferredToDepartment,
    ProductionMovementKind.transferredToBranch,
    ProductionMovementKind.transferredIn,
    ProductionMovementKind.adjustedUp,
    ProductionMovementKind.adjustedDown,
  ];
}

/// The headline cards of the summary, over every item of the period.
/// Quantities are per unit and masked without [canSeeQuantity].
List<ProductionStockCard> productionHistorySummaryCards(
  ProductionHistorySummaryStats s, {
  required ProductionStockKind kind,
  required bool canSeeQuantity,
}) {
  final main = productionMainMovement(kind);
  final out = productionOutMovement(kind);
  return [
    ProductionStockCard(
      id: 'moved',
      title: '${kind.plural} With Movement',
      kind: ProductionStockCardKind.count,
      amount: s.itemsWithMovement.toDouble(),
      subtitle: 'of ${s.totalItems} ${kind.countNoun}',
    ),
    ProductionStockCard(
      id: 'main',
      title: main.label,
      kind: ProductionStockCardKind.quantities,
      byUnit: kind == ProductionStockKind.producedItem ? s.netProduced : s.of(main),
      subtitle:
          kind == ProductionStockKind.producedItem
              ? 'Net of deleted production'
              : 'In this period',
      masked: !canSeeQuantity,
    ),
    ProductionStockCard(
      id: 'out',
      title: out.label,
      kind: ProductionStockCardKind.quantities,
      byUnit: s.of(out),
      subtitle: 'In this period',
      masked: !canSeeQuantity,
    ),
    ProductionStockCard(
      id: 'net',
      title: 'Net Change',
      kind: ProductionStockCardKind.quantities,
      byUnit: s.net,
      subtitle: 'Additions minus reductions',
      masked: !canSeeQuantity,
    ),
    ProductionStockCard(
      id: 'events',
      title: 'History Records',
      kind: ProductionStockCardKind.count,
      amount: s.events.toDouble(),
      subtitle: 'In this period',
    ),
  ];
}
