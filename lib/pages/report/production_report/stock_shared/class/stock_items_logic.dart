// The stock table of the Produced Items and Materials pages (I1 / M1):
// one row per item with its stock, cost, details and the movement of
// the selected period. Pure Dart.

import 'package:flutter/material.dart' show TimeOfDay;
import 'package:stockall/pages/report/components/report_pager.dart';
import 'package:stockall/pages/report/production_report/production_records_table/class/production_records_table_logic.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/material_usage_logic.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/production_stock_model.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

const int productionStockPageSize = 100;
const String productionNoCategoryLabel = 'No Category';

/// Stock level of a managed item. Produced items have no low-stock
/// level (they have no low quantity).
enum ProductionStockLevel { inStock, low, out }

extension ProductionStockLevelLabel on ProductionStockLevel {
  String get label {
    switch (this) {
      case ProductionStockLevel.inStock:
        return 'In Stock';
      case ProductionStockLevel.low:
        return 'Low Stock';
      case ProductionStockLevel.out:
        return 'Out of Stock';
    }
  }
}

/// The levels [kind] can have.
List<ProductionStockLevel> productionStockLevels(ProductionStockKind kind) => [
  ProductionStockLevel.inStock,
  if (kind == ProductionStockKind.material) ProductionStockLevel.low,
  ProductionStockLevel.out,
];

/// The movement columns of [kind], in table order.
List<ProductionMovementKind> productionMovementColumns(
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

/// One table row. Values are calculated once; null means not
/// applicable (shown as "—").
class ProductionStockRow {
  final ProductionStockItem item;
  final String primaryUnit;

  /// Stock in the primary unit; null for an unmanaged item.
  final double? quantity;

  /// Cost of one primary unit.
  final double costPrice;

  /// Stock × cost; null for an unmanaged item.
  final double? stockValue;

  /// Categories that still exist, with their names.
  final List<String> categoryKeys;
  final List<String> categoryNames;
  final bool isExpired;
  final ProductionStockLevel? stockLevel;

  /// The selected period's balances and movement (empty without
  /// history access).
  final ProductionStockBalance balance;
  final ProductionMovementTotals movement;

  /// Materials: use in the period, split between production and manual
  /// use. Null for produced items.
  final ProductionMaterialUsage? materialUsage;

  ProductionStockRow({
    required this.item,
    required this.primaryUnit,
    required this.quantity,
    required this.costPrice,
    required this.stockValue,
    required this.categoryKeys,
    required this.categoryNames,
    required this.isExpired,
    required this.stockLevel,
    required this.balance,
    required this.movement,
    this.materialUsage,
  });

  String get uuid => item.uuid;
  String get name => item.name;
  bool get isManaged => item.isManaged;
  String? get departmentKey => item.departmentUuid;
  String? get departmentName => item.departmentName;
  DateTime? get expiryDate => item.expiryDate;
  DateTime? get createdAt => item.createdAt;

  /// Materials: the low-stock quantity in the primary unit (it is kept
  /// in base units, as the materials list compares it).
  double? get lowQuantity {
    final low = item.lowQtty;
    if (low == null) return null;
    final v = low / item.primaryConversion;
    return v.isFinite ? v : null;
  }

  String get departmentLabel =>
      departmentKey == null
          ? productionNoDepartmentLabel
          : departmentName ?? productionNoDepartmentLabel;

  String get categoryLabel =>
      categoryNames.isEmpty ? productionNoCategoryLabel : categoryNames.join(', ');
}

class ProductionStockRowBuilder {
  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Expired when the expiry day is the business day or earlier, as on
  /// the Items report.
  static bool isExpired(DateTime? expiry, DateTime businessNow) {
    if (expiry == null) return false;
    return !_dateOnly(expiry).isAfter(_dateOnly(businessNow));
  }

  /// Out at zero or less; low at or below the low quantity (materials).
  static ProductionStockLevel? level(ProductionStockItem item) {
    if (!item.isManaged) return null;
    final q = item.quantity ?? 0;
    if (q <= 0) return ProductionStockLevel.out;
    final low = item.lowQtty;
    if (item.kind == ProductionStockKind.material && low != null && q <= low) {
      return ProductionStockLevel.low;
    }
    return ProductionStockLevel.inStock;
  }

  static ProductionStockRow build({
    required ProductionStockItem item,
    required List<ProductionStockEntry> entries,
    required Map<String, String> categoryNames,
    required ReceiptsReportPeriod period,
    required DateTime businessNow,
    required bool historyAllowed,
    TimeOfDay? closingTime,
    ProductionMaterialUsage? materialUsage,
  }) {
    final qty = item.primaryQty;
    final cost = item.primaryCost;
    final keys = <String>[];
    final names = <String>[];
    for (final id in item.categoryUuids) {
      final n = categoryNames[id];
      if (n != null) {
        keys.add(id);
        names.add(n);
      }
    }
    return ProductionStockRow(
      item: item,
      primaryUnit: item.primaryUnit,
      quantity: qty,
      costPrice: cost,
      stockValue: qty == null ? null : qty * cost,
      categoryKeys: keys,
      categoryNames: names,
      isExpired: isExpired(item.expiryDate, businessNow),
      stockLevel: level(item),
      balance:
          historyAllowed
              ? ProductionStockMovementCalculator.balance(
                item: item,
                entries: entries,
                period: period,
                closingTime: closingTime,
              )
              : ProductionStockBalance.none,
      movement:
          historyAllowed
              ? ProductionStockMovementCalculator.totals(
                item: item,
                entries: entries,
                period: period,
                closingTime: closingTime,
              )
              : ProductionMovementTotals(),
      materialUsage: materialUsage,
    );
  }

  /// [entries]: every scoped history record; each row reads its own.
  /// [usageByItem]: materials' use in the period (from
  /// `ProductionMaterialUsageBuilder`); null for produced items.
  static List<ProductionStockRow> buildAll({
    required List<ProductionStockItem> items,
    required List<ProductionStockEntry> entries,
    required Map<String, String> categoryNames,
    required ReceiptsReportPeriod period,
    required DateTime businessNow,
    required bool historyAllowed,
    TimeOfDay? closingTime,
    Map<String, ProductionMaterialUsage>? usageByItem,
  }) {
    final byItem = productionEntriesByItem(entries);
    final rows = <ProductionStockRow>[];
    for (final item in items) {
      if (item.uuid.isEmpty) continue;
      try {
        rows.add(
          build(
            item: item,
            entries: byItem[item.uuid] ?? const [],
            categoryNames: categoryNames,
            period: period,
            businessNow: businessNow,
            historyAllowed: historyAllowed,
            closingTime: closingTime,
            materialUsage:
                usageByItem == null
                    ? null
                    : usageByItem[item.uuid] ?? ProductionMaterialUsage(item.uuid),
          ),
        );
      } catch (_) {
        // A single malformed item must never break the report.
      }
    }
    return rows;
  }
}

/// All filters, combined with AND. Category and department keys can be
/// [productionReportNoneKey].
class ProductionStockFilters {
  String search;

  /// One item, set when another page opens the table on it.
  String? itemKey;
  String? categoryKey;
  String? departmentKey;
  ProductionStockLevel? stockLevel;
  bool? managed;

  /// Cost of one primary unit.
  double? costMin;
  double? costMax;

  /// Stock in the primary unit.
  double? quantityMin;
  double? quantityMax;
  DateTime? expiryStart;
  DateTime? expiryEnd;

  ProductionStockFilters({
    this.search = '',
    this.itemKey,
    this.categoryKey,
    this.departmentKey,
    this.stockLevel,
    this.managed,
    this.costMin,
    this.costMax,
    this.quantityMin,
    this.quantityMax,
    this.expiryStart,
    this.expiryEnd,
  });

  ProductionStockFilters copy() => ProductionStockFilters(
    search: search,
    itemKey: itemKey,
    categoryKey: categoryKey,
    departmentKey: departmentKey,
    stockLevel: stockLevel,
    managed: managed,
    costMin: costMin,
    costMax: costMax,
    quantityMin: quantityMin,
    quantityMax: quantityMax,
    expiryStart: expiryStart,
    expiryEnd: expiryEnd,
  );

  String? get costRangeError =>
      ReceiptsReportFilters.rangeError(costMin, costMax);
  String? get quantityRangeError =>
      ReceiptsReportFilters.rangeError(quantityMin, quantityMax);
  String? get expiryRangeError =>
      expiryStart != null && expiryEnd != null && expiryEnd!.isBefore(expiryStart!)
          ? 'The end is before the start'
          : null;

  int get activeCount =>
      (itemKey != null ? 1 : 0) +
      (categoryKey != null ? 1 : 0) +
      (departmentKey != null ? 1 : 0) +
      (stockLevel != null ? 1 : 0) +
      (managed != null ? 1 : 0) +
      (costMin != null || costMax != null ? 1 : 0) +
      (quantityMin != null || quantityMax != null ? 1 : 0) +
      (expiryStart != null || expiryEnd != null ? 1 : 0);

  bool get hasAnything => activeCount > 0 || search.trim().isNotEmpty;

  void clearAll() {
    search = '';
    itemKey = null;
    categoryKey = null;
    departmentKey = null;
    stockLevel = null;
    managed = null;
    costMin = null;
    costMax = null;
    quantityMin = null;
    quantityMax = null;
    expiryStart = null;
    expiryEnd = null;
  }

  /// The cost range needs [canSeeCost]; the quantity range and stock
  /// level need [canSeeQuantity] (they reveal the stock).
  bool matches(
    ProductionStockRow r, {
    required bool departmentsEnabled,
    required bool canSeeCost,
    required bool canSeeQuantity,
  }) {
    final q = search.trim().toLowerCase();
    if (q.isNotEmpty) {
      bool has(String? s) => s != null && s.toLowerCase().contains(q);
      if (!has(r.name) &&
          !r.categoryNames.any(has) &&
          !(departmentsEnabled && has(r.departmentName))) {
        return false;
      }
    }
    if (itemKey != null && r.uuid != itemKey) return false;
    if (categoryKey != null) {
      if (categoryKey == productionReportNoneKey) {
        if (r.categoryKeys.isNotEmpty) return false;
      } else if (!r.categoryKeys.contains(categoryKey)) {
        return false;
      }
    }
    if (departmentsEnabled &&
        !ProductionRecordsFilters.keyMatches(departmentKey, r.departmentKey)) {
      return false;
    }
    if (managed != null && r.isManaged != managed) return false;
    if (canSeeQuantity && stockLevel != null && r.stockLevel != stockLevel) {
      return false;
    }
    if (canSeeCost &&
        (costMin != null || costMax != null) &&
        costRangeError == null &&
        !ReceiptsReportFilters.inRange(r.costPrice, costMin, costMax)) {
      return false;
    }
    if (canSeeQuantity &&
        (quantityMin != null || quantityMax != null) &&
        quantityRangeError == null) {
      final qty = r.quantity;
      if (qty == null) return false;
      if (!ReceiptsReportFilters.inRange(qty, quantityMin, quantityMax)) {
        return false;
      }
    }
    if ((expiryStart != null || expiryEnd != null) && expiryRangeError == null) {
      final exp = r.expiryDate;
      if (exp == null) return false;
      final d = DateTime(exp.year, exp.month, exp.day);
      if (expiryStart != null &&
          d.isBefore(DateTime(expiryStart!.year, expiryStart!.month, expiryStart!.day))) {
        return false;
      }
      if (expiryEnd != null &&
          d.isAfter(DateTime(expiryEnd!.year, expiryEnd!.month, expiryEnd!.day))) {
        return false;
      }
    }
    return true;
  }
}

/// Filter choices taken from the rows, with a none choice last when a
/// row has no category / department.
class ProductionStockFilterChoices {
  final List<ProductionFilterOption> items;
  final List<ProductionFilterOption> categories;
  final List<ProductionFilterOption> departments;

  const ProductionStockFilterChoices({
    required this.items,
    required this.categories,
    required this.departments,
  });

  static const empty = ProductionStockFilterChoices(
    items: [],
    categories: [],
    departments: [],
  );

  static List<ProductionFilterOption> _sorted(
    Map<String, String> labels, {
    String? noneLabel,
  }) {
    final out =
        labels.entries.map((e) => ProductionFilterOption(e.key, e.value)).toList()
          ..sort((a, b) {
            final c = a.label.toLowerCase().compareTo(b.label.toLowerCase());
            return c != 0 ? c : a.key.compareTo(b.key);
          });
    if (noneLabel != null) {
      out.add(ProductionFilterOption(productionReportNoneKey, noneLabel));
    }
    return out;
  }

  factory ProductionStockFilterChoices.fromRows(List<ProductionStockRow> rows) {
    final items = <String, String>{};
    final categories = <String, String>{};
    final departments = <String, String>{};
    var noCategory = false;
    var noDepartment = false;
    for (final r in rows) {
      items[r.uuid] = r.name;
      if (r.categoryKeys.isEmpty) noCategory = true;
      for (var i = 0; i < r.categoryKeys.length; i++) {
        categories[r.categoryKeys[i]] = r.categoryNames[i];
      }
      if (r.departmentKey == null) {
        noDepartment = true;
      } else {
        departments[r.departmentKey!] = r.departmentLabel;
      }
    }
    return ProductionStockFilterChoices(
      items: _sorted(items),
      categories: _sorted(
        categories,
        noneLabel: noCategory ? productionNoCategoryLabel : null,
      ),
      departments: _sorted(
        departments,
        noneLabel: noDepartment ? productionNoDepartmentLabel : null,
      ),
    );
  }
}

/// A sortable column of the table. Movement columns sort by their
/// [ProductionMovementKind].
enum ProductionStockSortField {
  name,
  unit,
  quantity,
  costPrice,
  stockValue,
  department,
  category,
  expiry,
  managed,
  createdAt,
  opening,
  closing,
  movement,
  net,
  lowQuantity,
  usedInProduction,
  usedManually,
  usageCost,
}

/// The sort of the table: a field, and the movement kind for
/// [ProductionStockSortField.movement].
class ProductionStockSort {
  final ProductionStockSortField field;
  final ProductionMovementKind? movement;
  final bool ascending;

  const ProductionStockSort(this.field, {this.movement, this.ascending = true});

  static const byName = ProductionStockSort(ProductionStockSortField.name);

  bool sameColumn(ProductionStockSortField f, [ProductionMovementKind? m]) =>
      field == f && movement == m;

  /// Fields that show a quantity, ignored without the permission.
  /// Stock value is cost × quantity, so it needs both.
  bool get isQuantity =>
      field == ProductionStockSortField.quantity ||
      field == ProductionStockSortField.stockValue ||
      field == ProductionStockSortField.opening ||
      field == ProductionStockSortField.closing ||
      field == ProductionStockSortField.movement ||
      field == ProductionStockSortField.net ||
      field == ProductionStockSortField.lowQuantity ||
      field == ProductionStockSortField.usedInProduction ||
      field == ProductionStockSortField.usedManually;

  bool get isCost =>
      field == ProductionStockSortField.costPrice ||
      field == ProductionStockSortField.stockValue ||
      field == ProductionStockSortField.usageCost;
}

/// Result of [ProductionStockQuery.paginate].
class ProductionStockPage {
  final List<ProductionStockRow> rows;
  final int totalCount;
  final int page;
  final int totalPages;

  /// Totals of every filtered row: managed items and their stock value
  /// (no quantity sums: units differ).
  final int managedCount;
  final double totalStockValue;

  /// Materials: usage cost of every filtered row.
  final double totalUsageCost;

  const ProductionStockPage({
    required this.rows,
    required this.totalCount,
    required this.page,
    required this.totalPages,
    this.managedCount = 0,
    this.totalStockValue = 0,
    this.totalUsageCost = 0,
  });

  int get firstIndex =>
      totalCount == 0 ? 0 : (page - 1) * productionStockPageSize + 1;
  int get lastIndex => firstIndex == 0 ? 0 : firstIndex + rows.length - 1;
}

class ProductionStockQuery {
  static Comparable? _value(ProductionStockRow r, ProductionStockSort s) {
    switch (s.field) {
      case ProductionStockSortField.name:
        return r.name.toLowerCase();
      case ProductionStockSortField.unit:
        return r.primaryUnit.toLowerCase();
      case ProductionStockSortField.quantity:
        return r.quantity;
      case ProductionStockSortField.costPrice:
        return r.costPrice;
      case ProductionStockSortField.stockValue:
        return r.stockValue;
      case ProductionStockSortField.department:
        return r.departmentKey == null ? null : r.departmentLabel.toLowerCase();
      case ProductionStockSortField.category:
        return r.categoryNames.isEmpty ? null : r.categoryLabel.toLowerCase();
      case ProductionStockSortField.expiry:
        return r.expiryDate;
      case ProductionStockSortField.managed:
        return r.isManaged ? 1 : 0;
      case ProductionStockSortField.createdAt:
        return r.createdAt;
      case ProductionStockSortField.opening:
        return r.balance.opening;
      case ProductionStockSortField.closing:
        return r.balance.closing;
      case ProductionStockSortField.movement:
        final m = s.movement;
        return m == null ? null : r.movement.of(m);
      case ProductionStockSortField.net:
        return r.movement.net;
      case ProductionStockSortField.lowQuantity:
        return r.lowQuantity;
      case ProductionStockSortField.usedInProduction:
        return r.materialUsage?.productionQty;
      case ProductionStockSortField.usedManually:
        return r.materialUsage?.manualQty;
      case ProductionStockSortField.usageCost:
        return r.materialUsage?.totalCost;
    }
  }

  static List<ProductionStockRow> filterAndSort({
    required List<ProductionStockRow> rows,
    required ProductionStockFilters filters,
    required ProductionStockSort sort,
    required bool departmentsEnabled,
    required bool canSeeCost,
    required bool canSeeQuantity,
  }) {
    final out =
        rows
            .where(
              (r) => filters.matches(
                r,
                departmentsEnabled: departmentsEnabled,
                canSeeCost: canSeeCost,
                canSeeQuantity: canSeeQuantity,
              ),
            )
            .toList();
    final s = effectiveSort(
      sort,
      canSeeCost: canSeeCost,
      canSeeQuantity: canSeeQuantity,
    );
    out.sort((a, b) {
      final c = ProductionRecordsQuery.cmp(_value(a, s), _value(b, s), s.ascending);
      if (c != 0) return c;
      final n = a.name.toLowerCase().compareTo(b.name.toLowerCase());
      return n != 0 ? n : a.uuid.compareTo(b.uuid);
    });
    return out;
  }

  /// The sort actually used: a hidden column can't be the sort, so it
  /// falls back to the name.
  static ProductionStockSort effectiveSort(
    ProductionStockSort sort, {
    required bool canSeeCost,
    required bool canSeeQuantity,
  }) =>
      (sort.isQuantity && !canSeeQuantity) || (sort.isCost && !canSeeCost)
          ? ProductionStockSort.byName
          : sort;

  static ProductionStockPage paginate(
    List<ProductionStockRow> sorted,
    int requestedPage,
  ) {
    final b = reportPageBounds(
      sorted.length,
      requestedPage,
      pageSize: productionStockPageSize,
    );
    var managed = 0;
    double value = 0;
    double usageCost = 0;
    for (final r in sorted) {
      if (r.isManaged) managed++;
      value += r.stockValue ?? 0;
      usageCost += r.materialUsage?.totalCost ?? 0;
    }
    return ProductionStockPage(
      rows: sorted.isEmpty ? const [] : sorted.sublist(b.start, b.end),
      totalCount: sorted.length,
      page: b.page,
      totalPages: b.pages,
      managedCount: managed,
      totalStockValue: value,
      totalUsageCost: usageCost,
    );
  }
}

/// Filters, sort and page of the table.
class ProductionStockTableState {
  final ProductionStockFilters filters;
  ProductionStockSort sort;
  int page;

  ProductionStockTableState({
    ProductionStockFilters? filters,
    this.sort = ProductionStockSort.byName,
    this.page = 1,
  }) : filters = filters ?? ProductionStockFilters();

  /// Reset All: clears the search and every filter; the sort stays.
  void resetAll() {
    filters.clearAll();
    page = 1;
  }
}

/// Records of the period that couldn't be converted, over [rows].
int productionStockNotNormalised(List<ProductionStockRow> rows) =>
    rows.fold(0, (s, r) => s + r.movement.notNormalised);
