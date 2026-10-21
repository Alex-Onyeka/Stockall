import 'package:stockall/classes/temp_categories/category_class.dart';
import 'package:stockall/classes/temp_item_history/item_history.dart';
import 'package:stockall/classes/temp_item_history/item_history_event_class.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_product_class/units_class/product_units_class.dart';
import 'package:stockall/constants/calculations.dart';

/// Page size required by the report specification.
const int itemsReportPageSize = 100;

/// Keys used by the Category / Department filters for the
/// "unassigned" bucket.
const String itemsReportNoneKey = '__none__';

enum StockLevelFilter { all, inStock, lowStock, outOfStock }

enum ItemsSortField {
  name,
  createdAt,
  quantity,
  sellingPrice,
  costPrice,
  totalCostValue,
  profitPerUnit,
  expiry,
  totalSellingValue,
  profit,
  margin,
  category,
  department,
  openingStock,
  closingStock,
  stockChange,
}

/// One displayed line of the report. Every quantity / price in here is
/// already normalised to the item's PRIMARY unit.
class ItemsReportRow {
  final TempProductClass product;
  final String name;
  final String primaryUnit;

  /// Quantity expressed in the primary unit. `null` for un-managed items
  /// (their stock is not tracked, so a quantity would be meaningless).
  final double? quantity;

  /// Selling price of ONE primary unit.
  final double sellingPrice;

  /// Cost price of ONE primary unit.
  final double costPrice;

  /// quantity x sellingPrice (null when quantity is null).
  final double? totalSellingValue;
  final double? totalCostValue;

  /// Potential (unrealised) profit = totalSellingValue - totalCostValue.
  final double? profit;

  /// (sellingPrice - costPrice) / sellingPrice * 100, `null` => N/A.
  final double? margin;

  final double? discount;
  final DateTime? expiryDate;
  final bool isExpired;
  final bool isTwoDimensional;
  final bool isManaged;
  final DateTime? createdAt;
  final List<String> categoryUuids;
  final List<String> categoryNames;
  final String? departmentUuid;
  final String? departmentName;
  final StockLevelFilter stockLevel;

  ItemsReportRow({
    required this.product,
    required this.name,
    required this.primaryUnit,
    required this.quantity,
    required this.sellingPrice,
    required this.costPrice,
    required this.totalSellingValue,
    required this.totalCostValue,
    required this.profit,
    required this.margin,
    required this.discount,
    required this.expiryDate,
    required this.isExpired,
    required this.isTwoDimensional,
    required this.isManaged,
    required this.createdAt,
    required this.categoryUuids,
    required this.categoryNames,
    required this.departmentUuid,
    required this.departmentName,
    required this.stockLevel,
  });

  String get uuid => product.uuid ?? '';

  /// Profit per 1 unit of the item (sellingPrice - costPrice) in the primary unit.
  double get profitPerUnit => sellingPrice - costPrice;

  String get categoryLabel =>
      categoryNames.isEmpty
          ? 'No Category'
          : categoryNames.join(', ');

  String get departmentLabel =>
      (departmentName == null || departmentName!.isEmpty)
          ? 'No Department'
          : departmentName!;

  String get quantityTypeLabel =>
      isTwoDimensional ? '2-Dimensional' : 'Simple';
}

/// Builds [ItemsReportRow]s. No inventory record is modified.
class ItemsReportRowBuilder {
  /// Amount of BASE units (the unit `quantity` is stored in; area for
  /// 2D items) that make up ONE primary unit. Mirrors the conversion
  /// used by [TempProductClass.getItemPrice].
  static double primaryUnitFactor(TempProductClass p) {
    final unit = p.getPrimaryUnit();
    final factor =
        p.quantityType == 2 &&
                unit.dimensionType ==
                    ProductUnitsClass.sheetUnit
            ? unit.conversion * p.dimensionArea()
            : unit.conversion;
    return factor.isFinite && factor > 0 ? factor : 1;
  }

  static StockLevelFilter classify(TempProductClass p) {
    // Same thresholds as the existing item tiles / items PDF:
    // actual quantity (area for 2D items) vs the low quantity.
    final qty = p.getActualQuantity() ?? 0;
    final low = p.lowQtty ?? 0;
    if (qty <= 0) return StockLevelFilter.outOfStock;
    if (qty <= low) return StockLevelFilter.lowStock;
    return StockLevelFilter.inStock;
  }

  static DateTime _dateOnly(DateTime d) =>
      DateTime(d.year, d.month, d.day);

  /// Expired when the expiry day is today (business date) or earlier;
  /// same convention as the existing items report.
  static bool isExpired(
    DateTime? expiry,
    DateTime businessNow,
  ) {
    if (expiry == null) return false;
    return !_dateOnly(
      expiry,
    ).isAfter(_dateOnly(businessNow));
  }

  static ItemsReportRow build({
    required TempProductClass product,
    required Map<String, String> categoryNameByUuid,
    required DateTime businessNow,
  }) {
    final isManaged = product.isManaged;
    final unit = product.getPrimaryUnit();
    final factor = primaryUnitFactor(product);

    final sellingPrice = product.getItemPrice();
    final costPrice = product.costPrice * factor;

    double? quantity;
    if (isManaged) {
      quantity = unit.getQuantityEquivDivided(
        index: 1,
        product: product,
      );
      if (!quantity.isFinite) quantity = 0;
    }

    final totalSelling =
        quantity == null ? null : quantity * sellingPrice;
    final totalCost =
        quantity == null ? null : quantity * costPrice;
    final profit =
        (totalSelling == null || totalCost == null)
            ? null
            : totalSelling - totalCost;
    final margin =
        sellingPrice > 0
            ? ((sellingPrice - costPrice) / sellingPrice) *
                100
            : null;

    final uuids = <String>{
      ...?product.categories,
      if (product.categoryUuid != null)
        product.categoryUuid!,
    }..removeWhere((e) => e.isEmpty);
    final names = <String>[];
    final knownUuids = <String>[];
    for (final id in uuids) {
      final n = categoryNameByUuid[id];
      if (n != null) {
        names.add(n);
        knownUuids.add(id);
      }
    }

    return ItemsReportRow(
      product: product,
      name: product.name,
      primaryUnit: unit.name,
      quantity: quantity,
      sellingPrice: sellingPrice,
      costPrice: costPrice,
      totalSellingValue: totalSelling,
      totalCostValue: totalCost,
      profit: profit,
      margin: margin,
      discount: product.discount,
      expiryDate: product.expiryDate,
      isExpired: isExpired(product.expiryDate, businessNow),
      isTwoDimensional: product.quantityType == 2,
      isManaged: isManaged,
      createdAt: product.createdAt,
      categoryUuids: knownUuids,
      categoryNames: names,
      departmentUuid: product.departmentUuid,
      departmentName: product.departmentName,
      stockLevel: classify(product),
    );
  }

  static List<ItemsReportRow> buildAll({
    required List<TempProductClass> products,
    required List<CategoryClass> categories,
  }) {
    final map = {
      for (final c in categories) c.uuid: c.name,
    };
    final now = resolveBusinessDate(DateTime.now());
    final rows = <ItemsReportRow>[];
    for (final p in products) {
      try {
        rows.add(
          build(
            product: p,
            categoryNameByUuid: map,
            businessNow: now,
          ),
        );
      } catch (_) {
        // A single malformed item must never break the report.
      }
    }
    return rows;
  }
}

/// All user-selectable filters. Every filter is combined with AND.
class ItemsReportFilters {
  String search = '';

  /// null = all, [itemsReportNoneKey] = no category, else a uuid.
  String? categoryKey;

  /// null = all, [itemsReportNoneKey] = no department, else a uuid.
  String? departmentKey;
  double? sellingMin;
  double? sellingMax;
  double? costMin;
  double? costMax;
  double? quantityMin;
  double? quantityMax;
  StockLevelFilter stockLevel = StockLevelFilter.all;

  /// null = all, true = managed, false = un-managed.
  bool? managed;

  DateTime? expiryStart;
  DateTime? expiryEnd;

  int get activeCount =>
      (categoryKey != null ? 1 : 0) +
      (departmentKey != null ? 1 : 0) +
      (sellingMin != null || sellingMax != null ? 1 : 0) +
      (costMin != null || costMax != null ? 1 : 0) +
      (quantityMin != null || quantityMax != null ? 1 : 0) +
      (stockLevel != StockLevelFilter.all ? 1 : 0) +
      (managed != null ? 1 : 0) +
      (expiryStart != null || expiryEnd != null ? 1 : 0);

  bool get hasAnything =>
      activeCount > 0 || search.trim().isNotEmpty;

  void clearAll() {
    search = '';
    clearFiltersOnly();
  }

  void clearFiltersOnly() {
    categoryKey = null;
    departmentKey = null;
    sellingMin = null;
    sellingMax = null;
    costMin = null;
    costMax = null;
    quantityMin = null;
    quantityMax = null;
    stockLevel = StockLevelFilter.all;
    managed = null;
    expiryStart = null;
    expiryEnd = null;
  }

  bool matches(
    ItemsReportRow r, {
    required bool departmentsEnabled,
    required bool costFilterAllowed,
  }) {
    final q = search.trim().toLowerCase();
    if (q.isNotEmpty) {
      final hit =
          r.name.toLowerCase().contains(q) ||
          r.categoryLabel.toLowerCase().contains(q) ||
          (departmentsEnabled &&
              r.departmentLabel.toLowerCase().contains(q));
      if (!hit) return false;
    }

    if (categoryKey != null) {
      if (categoryKey == itemsReportNoneKey) {
        if (r.categoryUuids.isNotEmpty) return false;
      } else if (!r.categoryUuids.contains(categoryKey)) {
        return false;
      }
    }

    if (departmentsEnabled && departmentKey != null) {
      if (departmentKey == itemsReportNoneKey) {
        if (r.departmentUuid != null) return false;
      } else if (r.departmentUuid != departmentKey) {
        return false;
      }
    }

    if (sellingMin != null &&
        r.sellingPrice < sellingMin!) {
      return false;
    }
    if (sellingMax != null &&
        r.sellingPrice > sellingMax!) {
      return false;
    }

    if (costFilterAllowed) {
      if (costMin != null && r.costPrice < costMin!) {
        return false;
      }
      if (costMax != null && r.costPrice > costMax!) {
        return false;
      }
    }

    if (quantityMin != null &&
        (r.quantity == null ||
            r.quantity! < quantityMin!)) {
      return false;
    }
    if (quantityMax != null &&
        (r.quantity == null ||
            r.quantity! > quantityMax!)) {
      return false;
    }

    if (stockLevel != StockLevelFilter.all) {
      // Un-managed items have no tracked stock to classify.
      if (!r.isManaged) return false;
      if (r.stockLevel != stockLevel) return false;
    }

    if (managed != null && r.isManaged != managed)
      return false;

    if (expiryStart != null || expiryEnd != null) {
      final exp = r.expiryDate;
      if (exp == null) return false;
      if (expiryStart != null) {
        final start = DateTime(
          expiryStart!.year,
          expiryStart!.month,
          expiryStart!.day,
        );
        if (exp.isBefore(start)) return false;
      }
      if (expiryEnd != null) {
        final end = DateTime(
          expiryEnd!.year,
          expiryEnd!.month,
          expiryEnd!.day,
          23,
          59,
          59,
          999,
        );
        if (exp.isAfter(end)) return false;
      }
    }

    return true;
  }
}

/// Holds the calculated stock movement (opening, closing, change) for an item
/// over a specific date or date range.
class ItemStockMovement {
  final double? opening;
  final double? closing;

  const ItemStockMovement({
    required this.opening,
    required this.closing,
  });

  double? get change {
    if (opening == null || closing == null) return null;
    return closing! - opening!;
  }
}

/// Reconstructs the stock balance at the start and end of a reporting period
/// from the item history. Read-only.
///
/// History semantics (verified against every `ItemHistory(` creation
/// site in the app):
///  * `oldValue` / `newValue` are the item's stock balance BEFORE and
///    AFTER the event, as text (thousand separators, e.g. "1,250.5"),
///    expressed in the item's PRIMARY unit (for 2D items: via the
///    dimensional conversion of the primary unit).
///  * `quantityChange` is the delta in the unit the staff selected
///    (`unit`), NOT necessarily the primary unit, so it is never used
///    for the balance.
///  * `deleted` events carry the same balance in both values and are
///    not stock movements.
class StockMovementCalculator {
  static final Set<String> _stockEvents = {
    ItemHistoryEventClass.returnEvent,
    ItemHistoryEventClass.sold,
    ItemHistoryEventClass.delivered,
    ItemHistoryEventClass.purchase,
    ItemHistoryEventClass.transferedIn,
    ItemHistoryEventClass.transferedOut,
    ItemHistoryEventClass.produced,
    ItemHistoryEventClass.productionDeleted,
    ItemHistoryEventClass.itemCreated,
    ItemHistoryEventClass.quantityUpdatedIncrease,
    ItemHistoryEventClass.quantityUpdatedDecrease,
  };

  static double? _parse(String? v) {
    if (v == null) return null;
    return double.tryParse(v.replaceAll(',', '').trim());
  }

  /// Whether [h] is a usable stock-balance record for [row].
  static bool isApplicable(
    ItemHistory h,
    ItemsReportRow row,
  ) {
    if (h.createdAt == null) return false;
    if (h.event == null ||
        !_stockEvents.contains(h.event)) {
      return false;
    }
    if (_parse(h.oldValue) == null ||
        _parse(h.newValue) == null) {
      return false;
    }
    // Values recorded against a different primary unit than the
    // current one cannot be compared with today's balance.
    final pu = h.primaryUnit;
    if (pu != null &&
        pu.trim().isNotEmpty &&
        pu.trim().toLowerCase() !=
            row.primaryUnit.trim().toLowerCase()) {
      return false;
    }
    return true;
  }

  static DateTime _alignCutoff(
    DateTime dt,
    DateTime cutoff,
  ) {
    if (dt.isUtc == cutoff.isUtc) return cutoff;
    return dt.isUtc
        ? DateTime.utc(
          cutoff.year,
          cutoff.month,
          cutoff.day,
          cutoff.hour,
          cutoff.minute,
          cutoff.second,
          cutoff.millisecond,
          cutoff.microsecond,
        )
        : DateTime(
          cutoff.year,
          cutoff.month,
          cutoff.day,
          cutoff.hour,
          cutoff.minute,
          cutoff.second,
          cutoff.millisecond,
          cutoff.microsecond,
        );
  }

  /// Calculates opening stock, closing stock, and stock change for [row] over
  /// the date or date range `[startCutoff, endCutoff]`.
  static ItemStockMovement calculate({
    required ItemsReportRow row,
    required List<ItemHistory> histories,
    required DateTime startCutoff,
    required DateTime endCutoff,
  }) {
    if (!row.isManaged) {
      return const ItemStockMovement(
        opening: null,
        closing: null,
      );
    }

    final usable =
        histories
            .where((h) => isApplicable(h, row))
            .toList()
          ..sort(
            (a, b) => a.createdAt!.compareTo(b.createdAt!),
          );

    // 1) Opening Stock: balance immediately before startCutoff
    double? opening;
    bool openingFound = false;
    for (final h in usable) {
      final start = _alignCutoff(h.createdAt!, startCutoff);
      if (!h.createdAt!.isBefore(start)) {
        opening = _parse(h.oldValue);
        openingFound = true;
        break;
      }
    }
    if (!openingFound) {
      if (usable.isNotEmpty) {
        opening = _parse(usable.last.newValue);
      } else {
        final created = row.createdAt;
        final start =
            created != null
                ? _alignCutoff(created, startCutoff)
                : startCutoff;
        if (created != null && !created.isBefore(start)) {
          opening = 0;
        } else {
          opening = row.quantity;
        }
      }
    }

    // 2) Closing Stock: newValue of the last item history recorded in [startCutoff, endCutoff]
    double? closing;
    final inRange =
        usable.where((h) {
          final start = _alignCutoff(
            h.createdAt!,
            startCutoff,
          );
          final end = _alignCutoff(h.createdAt!, endCutoff);
          return !h.createdAt!.isBefore(start) &&
              !h.createdAt!.isAfter(end);
        }).toList();

    if (inRange.isNotEmpty) {
      closing = _parse(inRange.last.newValue);
    } else {
      // When no history records occurred in the period, stock remains at opening balance
      closing = opening;
    }

    return ItemStockMovement(
      opening: opening,
      closing: closing,
    );
  }

  /// Balance immediately before [cutoff] (the business start of the
  /// first reporting day). Kept for backward compatibility.
  static double? openingFor({
    required ItemsReportRow row,
    required List<ItemHistory> histories,
    required DateTime cutoff,
  }) {
    return calculate(
      row: row,
      histories: histories,
      startCutoff: cutoff,
      endCutoff: cutoff,
    ).opening;
  }
}

typedef OpeningStockCalculator = StockMovementCalculator;

/// Result of [ItemsReportQuery.run].
class ItemsReportPage {
  final List<ItemsReportRow> rows;
  final int totalCount;
  final int page; // 1-based, already clamped
  final int totalPages;

  const ItemsReportPage({
    required this.rows,
    required this.totalCount,
    required this.page,
    required this.totalPages,
  });

  int get firstIndex =>
      totalCount == 0
          ? 0
          : (page - 1) * itemsReportPageSize + 1;
  int get lastIndex =>
      firstIndex == 0 ? 0 : firstIndex + rows.length - 1;
}

class ItemsReportQuery {
  static int _cmp<T extends Comparable>(
    T? a,
    T? b,
    bool asc,
  ) {
    // Null values always sink to the bottom, in both directions.
    if (a == null && b == null) return 0;
    if (a == null) return 1;
    if (b == null) return -1;
    final c = a.compareTo(b);
    return asc ? c : -c;
  }

  static List<ItemsReportRow> filterAndSort({
    required List<ItemsReportRow> rows,
    required ItemsReportFilters filters,
    required ItemsSortField sortField,
    required bool ascending,
    required bool departmentsEnabled,
    required bool costFilterAllowed,
    double? Function(ItemsReportRow)? opening,
    double? Function(ItemsReportRow)? closing,
    double? Function(ItemsReportRow)? stockChange,
  }) {
    final out =
        rows
            .where(
              (r) => filters.matches(
                r,
                departmentsEnabled: departmentsEnabled,
                costFilterAllowed: costFilterAllowed,
              ),
            )
            .toList();

    int compare(ItemsReportRow a, ItemsReportRow b) {
      int c;
      switch (sortField) {
        case ItemsSortField.name:
          c = _cmp(
            a.name.toLowerCase(),
            b.name.toLowerCase(),
            ascending,
          );
          break;
        case ItemsSortField.createdAt:
          c = _cmp(a.createdAt, b.createdAt, ascending);
          break;
        case ItemsSortField.quantity:
          c = _cmp(a.quantity, b.quantity, ascending);
          break;
        case ItemsSortField.sellingPrice:
          c = _cmp(
            a.sellingPrice,
            b.sellingPrice,
            ascending,
          );
          break;
        case ItemsSortField.costPrice:
          c = _cmp(a.costPrice, b.costPrice, ascending);
          break;
        case ItemsSortField.totalCostValue:
          c = _cmp(
            a.totalCostValue,
            b.totalCostValue,
            ascending,
          );
          break;
        case ItemsSortField.profitPerUnit:
          c = _cmp(
            a.profitPerUnit,
            b.profitPerUnit,
            ascending,
          );
          break;
        case ItemsSortField.expiry:
          c = _cmp(a.expiryDate, b.expiryDate, ascending);
          break;
        case ItemsSortField.totalSellingValue:
          c = _cmp(
            a.totalSellingValue,
            b.totalSellingValue,
            ascending,
          );
          break;
        case ItemsSortField.profit:
          c = _cmp(a.profit, b.profit, ascending);
          break;
        case ItemsSortField.margin:
          c = _cmp(a.margin, b.margin, ascending);
          break;
        case ItemsSortField.category:
          c = _cmp(
            a.categoryNames.isEmpty
                ? null
                : a.categoryLabel.toLowerCase(),
            b.categoryNames.isEmpty
                ? null
                : b.categoryLabel.toLowerCase(),
            ascending,
          );
          break;
        case ItemsSortField.department:
          c = _cmp(
            a.departmentName?.toLowerCase(),
            b.departmentName?.toLowerCase(),
            ascending,
          );
          break;
        case ItemsSortField.openingStock:
          c = _cmp(
            opening?.call(a),
            opening?.call(b),
            ascending,
          );
          break;
        case ItemsSortField.closingStock:
          c = _cmp(
            closing?.call(a),
            closing?.call(b),
            ascending,
          );
          break;
        case ItemsSortField.stockChange:
          c = _cmp(
            stockChange?.call(a),
            stockChange?.call(b),
            ascending,
          );
          break;
      }
      if (c != 0) return c;
      // Deterministic tie-breakers keep pagination stable.
      final n = a.name.toLowerCase().compareTo(
        b.name.toLowerCase(),
      );
      return n != 0 ? n : a.uuid.compareTo(b.uuid);
    }

    out.sort(compare);
    return out;
  }

  static ItemsReportPage paginate(
    List<ItemsReportRow> sorted,
    int requestedPage,
  ) {
    final total = sorted.length;
    final pages =
        total == 0
            ? 1
            : (total / itemsReportPageSize).ceil();
    final page = requestedPage.clamp(1, pages);
    final start = (page - 1) * itemsReportPageSize;
    final end =
        (start + itemsReportPageSize) > total
            ? total
            : start + itemsReportPageSize;
    return ItemsReportPage(
      rows:
          total == 0
              ? const []
              : sorted.sublist(start, end),
      totalCount: total,
      page: page,
      totalPages: pages,
    );
  }
}
