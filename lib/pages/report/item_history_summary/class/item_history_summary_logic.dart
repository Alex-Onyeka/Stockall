import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_item_history/item_history.dart';
import 'package:stockall/classes/temp_item_history/item_history_event_class.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/constants/calculations.dart';

const int itemHistorySummaryPageSize = 50;
const String itemHistorySummaryNoneKey = '__none__';

enum ItemHistoryPeriod {
  today,
  thisWeek,
  thisMonth,
  allTime,
  custom,
}

extension ItemHistoryPeriodExt on ItemHistoryPeriod {
  String get label {
    switch (this) {
      case ItemHistoryPeriod.today:
        return 'Today';
      case ItemHistoryPeriod.thisWeek:
        return 'This Week';
      case ItemHistoryPeriod.thisMonth:
        return 'This Month';
      case ItemHistoryPeriod.allTime:
        return 'All Time';
      case ItemHistoryPeriod.custom:
        return 'Custom Range';
    }
  }
}

enum ItemHistoryMovementFilter {
  all,
  hasMovement,
  inflowOnly,
  outflowOnly,
  noChange,
}

extension ItemHistoryMovementFilterExt on ItemHistoryMovementFilter {
  String get label {
    switch (this) {
      case ItemHistoryMovementFilter.all:
        return 'All Items';
      case ItemHistoryMovementFilter.hasMovement:
        return 'With Movement';
      case ItemHistoryMovementFilter.inflowOnly:
        return 'Inflow Only';
      case ItemHistoryMovementFilter.outflowOnly:
        return 'Outflow Only';
      case ItemHistoryMovementFilter.noChange:
        return 'Zero Change';
    }
  }
}

enum ItemHistorySummarySortField {
  rowIndex,
  itemName,
  openingStock,
  closingStock,
  currentQuantity,
  transferredIn,
  transferredOut,
  produced,
  productionDeleted,
  sold,
  returned,
  purchased,
  delivered,
  created,
  deleted,
  netQuantityChange,
}

/// Aggregated movement statistics according to Section 6.3.
class ItemHistorySummaryStats {
  final double totalTransferredIn;
  final double totalTransferredOut;
  final double totalCreated;
  final double totalDeleted;
  final double totalProduced;
  final double totalProductionDeleted;
  final double totalSold;
  final double totalReturned;
  final double totalPurchased;
  final double totalDelivered;
  final double totalQuantityIncreased;
  final double totalQuantityDecreased;

  final double totalStockAdditions;
  final double totalStockReductions;
  final double netQuantityChange;

  final int totalHistoryEvents;
  final int itemsWithMovementCount;
  final int totalDistinctItems;

  /// Quantity additions grouped by primary unit (e.g. {'Pcs': 120, 'Kg': 45}).
  final Map<String, double> additionsByPrimaryUnit;
  final Map<String, double> reductionsByPrimaryUnit;

  const ItemHistorySummaryStats({
    required this.totalTransferredIn,
    required this.totalTransferredOut,
    required this.totalCreated,
    required this.totalDeleted,
    required this.totalProduced,
    required this.totalProductionDeleted,
    required this.totalSold,
    required this.totalReturned,
    required this.totalPurchased,
    required this.totalDelivered,
    required this.totalQuantityIncreased,
    required this.totalQuantityDecreased,
    required this.totalStockAdditions,
    required this.totalStockReductions,
    required this.netQuantityChange,
    required this.totalHistoryEvents,
    required this.itemsWithMovementCount,
    required this.totalDistinctItems,
    required this.additionsByPrimaryUnit,
    required this.reductionsByPrimaryUnit,
  });

  static const empty = ItemHistorySummaryStats(
    totalTransferredIn: 0,
    totalTransferredOut: 0,
    totalCreated: 0,
    totalDeleted: 0,
    totalProduced: 0,
    totalProductionDeleted: 0,
    totalSold: 0,
    totalReturned: 0,
    totalPurchased: 0,
    totalDelivered: 0,
    totalQuantityIncreased: 0,
    totalQuantityDecreased: 0,
    totalStockAdditions: 0,
    totalStockReductions: 0,
    netQuantityChange: 0,
    totalHistoryEvents: 0,
    itemsWithMovementCount: 0,
    totalDistinctItems: 0,
    additionsByPrimaryUnit: {},
    reductionsByPrimaryUnit: {},
  );
}

/// Represents an aggregated row in the Item-Level History Summary Table (Section 6.4).
class ItemHistorySummaryRow {
  int index;
  final String uuid;
  final String name;
  final String primaryUnit;
  final double? openingStock;
  final double? closingStock;
  final double currentQuantity;
  final double transferredIn;
  final double transferredOut;
  final double produced;
  final double productionDeleted;
  final double sold;
  final double returned;
  final double purchased;
  final double delivered;
  final double created;
  final double deleted;
  final double quantityIncreased;
  final double quantityDecreased;
  final double totalAdditions;
  final double totalReductions;
  final double netQuantityChange;
  final bool isManaged;
  final List<String> categoryUuids;
  final String? departmentUuid;
  final DateTime? createdAt;

  ItemHistorySummaryRow({
    required this.index,
    required this.uuid,
    required this.name,
    required this.primaryUnit,
    required this.openingStock,
    required this.closingStock,
    required this.currentQuantity,
    required this.transferredIn,
    required this.transferredOut,
    required this.produced,
    required this.productionDeleted,
    required this.sold,
    required this.returned,
    required this.purchased,
    required this.delivered,
    required this.created,
    required this.deleted,
    required this.quantityIncreased,
    required this.quantityDecreased,
    required this.totalAdditions,
    required this.totalReductions,
    required this.netQuantityChange,
    required this.isManaged,
    required this.categoryUuids,
    required this.departmentUuid,
    required this.createdAt,
  });

  bool get hasAnyMovement =>
      transferredIn != 0 ||
      transferredOut != 0 ||
      produced != 0 ||
      productionDeleted != 0 ||
      sold != 0 ||
      returned != 0 ||
      purchased != 0 ||
      delivered != 0 ||
      created != 0 ||
      deleted != 0 ||
      quantityIncreased != 0 ||
      quantityDecreased != 0;
}

class ItemHistorySummaryFilters {
  String search = '';
  String? categoryKey;
  String? departmentKey;
  ItemHistoryMovementFilter movementFilter = ItemHistoryMovementFilter.all;

  bool get hasAnything =>
      search.trim().isNotEmpty ||
      categoryKey != null ||
      departmentKey != null ||
      movementFilter != ItemHistoryMovementFilter.all;

  void clearAll() {
    search = '';
    categoryKey = null;
    departmentKey = null;
    movementFilter = ItemHistoryMovementFilter.all;
  }

  bool matches(
    ItemHistorySummaryRow row, {
    required bool departmentsEnabled,
  }) {
    if (search.trim().isNotEmpty) {
      final q = search.trim().toLowerCase();
      if (!row.name.toLowerCase().contains(q) &&
          !row.primaryUnit.toLowerCase().contains(q)) {
        return false;
      }
    }

    if (categoryKey != null) {
      if (categoryKey == itemHistorySummaryNoneKey) {
        if (row.categoryUuids.isNotEmpty) {
          return false;
        }
      } else {
        if (!row.categoryUuids.contains(categoryKey)) {
          return false;
        }
      }
    }

    if (departmentsEnabled && departmentKey != null) {
      if (departmentKey == itemHistorySummaryNoneKey) {
        if (row.departmentUuid != null &&
            row.departmentUuid!.isNotEmpty) {
          return false;
        }
      } else {
        if (row.departmentUuid != departmentKey) {
          return false;
        }
      }
    }

    switch (movementFilter) {
      case ItemHistoryMovementFilter.all:
        break;
      case ItemHistoryMovementFilter.hasMovement:
        if (!row.hasAnyMovement) {
          return false;
        }
        break;
      case ItemHistoryMovementFilter.inflowOnly:
        if (row.totalAdditions <= 0) {
          return false;
        }
        break;
      case ItemHistoryMovementFilter.outflowOnly:
        if (row.totalReductions <= 0) {
          return false;
        }
        break;
      case ItemHistoryMovementFilter.noChange:
        if (row.netQuantityChange != 0) {
          return false;
        }
        break;
    }

    return true;
  }
}

class ItemHistorySummaryPageResult {
  final List<ItemHistorySummaryRow> rows;
  final int totalCount;
  final int page;
  final int totalPages;

  const ItemHistorySummaryPageResult({
    required this.rows,
    required this.totalCount,
    required this.page,
    required this.totalPages,
  });

  int get firstIndex =>
      totalCount == 0 ? 0 : (page - 1) * itemHistorySummaryPageSize + 1;
  int get lastIndex =>
      firstIndex == 0 ? 0 : firstIndex + rows.length - 1;
}

/// Calculation engine for Item History Summary and Analysis.
class ItemHistorySummaryBuilder {
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
    ItemHistoryEventClass.itemDuplicated,
    ItemHistoryEventClass.itemDeleted,
    ItemHistoryEventClass.quantityUpdatedIncrease,
    ItemHistoryEventClass.quantityUpdatedDecrease,
  };

  static double? _parseNum(String? v) {
    if (v == null) return null;
    return double.tryParse(v.replaceAll(',', '').trim());
  }

  static DateTime _alignCutoff(DateTime dt, DateTime cutoff) {
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

  /// Date cutoff resolver for the specified period.
  static DateTimeRange resolveDateRange({
    required ItemHistoryPeriod period,
    required DateTime businessNow,
    DateTimeRange? customRange,
  }) {
    final today = DateTime(businessNow.year, businessNow.month, businessNow.day);
    switch (period) {
      case ItemHistoryPeriod.today:
        return DateTimeRange(start: today, end: today);
      case ItemHistoryPeriod.thisWeek:
        final weekday = today.weekday;
        final startOfWeek = today.subtract(Duration(days: weekday - 1));
        return DateTimeRange(start: startOfWeek, end: today);
      case ItemHistoryPeriod.thisMonth:
        final startOfMonth = DateTime(today.year, today.month, 1);
        return DateTimeRange(start: startOfMonth, end: today);
      case ItemHistoryPeriod.allTime:
        return DateTimeRange(
          start: DateTime(2000, 1, 1),
          end: DateTime(2100, 1, 1),
        );
      case ItemHistoryPeriod.custom:
        return customRange ?? DateTimeRange(start: today, end: today);
    }
  }

  /// Computes the normalized delta quantity for [h] expressed in the item's primary unit.
  static double getDeltaQuantity(
    ItemHistory h, {
    required TempProductClass product,
    required bool isAddition,
  }) {
    final oldV = _parseNum(h.oldValue);
    final newV = _parseNum(h.newValue);

    // In Stockall, oldValue and newValue are already formatted in the item's primary unit
    if (oldV != null && newV != null) {
      if (h.event == ItemHistoryEventClass.itemDeleted) {
        return oldV.abs();
      }
      final diff = (newV - oldV).abs();
      if (diff > 0.00001) {
        return diff;
      }
    }

    // Fallback: use quantityChange normalized via product unit conversion if available
    if (h.quantityChange != null && h.quantityChange != 0) {
      final rawQty = h.quantityChange!.abs();
      if (h.unit != null && h.unit!.isNotEmpty) {
        try {
          final unitObj = product.getUnitsList().firstWhere(
            (u) => u.name.trim().toLowerCase() == h.unit!.trim().toLowerCase(),
            orElse: () => product.getPrimaryUnit(),
          );
          return unitObj.getQuantityEquivDivided(
            index: 1,
            newQuantity: rawQty,
            product: product,
          );
        } catch (_) {
          return rawQty;
        }
      }
      return rawQty;
    }

    return 0.0;
  }

  /// Builds Summary Statistics and item-level summary rows.
  static ({
    ItemHistorySummaryStats stats,
    List<ItemHistorySummaryRow> rows,
  }) buildSummaryAndRows({
    required List<TempProductClass> products,
    required List<ItemHistory> histories,
    required ItemHistoryPeriod period,
    required DateTime businessNow,
    required bool manageProductions,
    DateTimeRange? customRange,
  }) {
    final range = resolveDateRange(
      period: period,
      businessNow: businessNow,
      customRange: customRange,
    );

    final startCutoff = period == ItemHistoryPeriod.allTime
        ? DateTime(2000, 1, 1)
        : fourAm(range.start);
    final endCutoff = period == ItemHistoryPeriod.allTime
        ? DateTime(2100, 1, 1)
        : fourAmNextDay(range.end);

    // Group history records by product uuid (and name fallback)
    final Map<String, List<ItemHistory>> historyByProductUuid = {};
    final Map<String, List<ItemHistory>> historyByProductName = {};

    for (final h in histories) {
      if (h.createdAt == null) {
        continue;
      }
      final u = h.itemUuid;
      if (u != null && u.isNotEmpty) {
        (historyByProductUuid[u] ??= []).add(h);
      }
      final nameKey = (h.itemName ?? '').trim().toLowerCase();
      if (nameKey.isNotEmpty) {
        (historyByProductName[nameKey] ??= []).add(h);
      }
    }

    double totalTransferredIn = 0;
    double totalTransferredOut = 0;
    double totalCreated = 0;
    double totalDeleted = 0;
    double totalProduced = 0;
    double totalProductionDeleted = 0;
    double totalSold = 0;
    double totalReturned = 0;
    double totalPurchased = 0;
    double totalDelivered = 0;
    double totalQuantityIncreased = 0;
    double totalQuantityDecreased = 0;

    int totalEventsInPeriod = 0;
    int itemsWithMovementCount = 0;

    final Map<String, double> additionsByUnit = {};
    final Map<String, double> reductionsByUnit = {};

    final List<ItemHistorySummaryRow> rows = [];
    int rowIndex = 1;

    for (final product in products) {
      final pUuid = product.uuid ?? '';
      final pName = product.name;
      final primaryUnit = product.getPrimaryUnit().name;

      List<ItemHistory> itemEvents =
          historyByProductUuid[pUuid] ??
          historyByProductName[pName.trim().toLowerCase()] ??
          [];

      // Filter to stock events with compatible primary unit
      final usable = itemEvents.where((h) {
        if (h.createdAt == null) {
          return false;
        }
        if (h.event == null || !_stockEvents.contains(h.event)) {
          return false;
        }
        final pu = h.primaryUnit;
        if (pu != null &&
            pu.trim().isNotEmpty &&
            pu.trim().toLowerCase() != primaryUnit.trim().toLowerCase()) {
          return false;
        }
        return true;
      }).toList()..sort((a, b) => a.createdAt!.compareTo(b.createdAt!));

      // 1) Opening Stock: balance immediately before startCutoff
      double? openingStock;
      bool openingFound = false;

      for (final h in usable) {
        final start = _alignCutoff(h.createdAt!, startCutoff);
        if (!h.createdAt!.isBefore(start)) {
          openingStock = _parseNum(h.oldValue);
          openingFound = true;
          break;
        }
      }

      if (!openingFound) {
        if (usable.isNotEmpty) {
          // If all events were before the period, the opening stock is the latest balance
          openingStock = _parseNum(usable.last.newValue);
        } else {
          // No history events at all
          final created = product.createdAt;
          final start = created != null
              ? _alignCutoff(created, startCutoff)
              : startCutoff;
          if (created != null && !created.isBefore(start)) {
            openingStock = 0;
          } else {
            openingStock = product.getActualQuantity() ?? product.quantity?.toDouble() ?? 0;
          }
        }
      }

      // 2) Stock movements strictly within the selected reporting period
      double transferredIn = 0;
      double transferredOut = 0;
      double produced = 0;
      double productionDeleted = 0;
      double sold = 0;
      double returned = 0;
      double purchased = 0;
      double delivered = 0;
      double created = 0;
      double deleted = 0;
      double quantityIncreased = 0;
      double quantityDecreased = 0;

      final inRangeEvents = usable.where((h) {
        final start = _alignCutoff(h.createdAt!, startCutoff);
        final end = _alignCutoff(h.createdAt!, endCutoff);
        return !h.createdAt!.isBefore(start) && !h.createdAt!.isAfter(end);
      }).toList();

      for (final h in inRangeEvents) {
        final ev = h.event;
        totalEventsInPeriod++;

        if (ev == ItemHistoryEventClass.transferedIn) {
          final delta = getDeltaQuantity(h, product: product, isAddition: true);
          transferredIn += delta;
        } else if (ev == ItemHistoryEventClass.transferedOut) {
          final delta = getDeltaQuantity(h, product: product, isAddition: false);
          transferredOut += delta;
        } else if (ev == ItemHistoryEventClass.itemCreated ||
            ev == ItemHistoryEventClass.itemDuplicated) {
          // Section 6.3.2: Only establish stock addition if initial stock was given
          final delta = getDeltaQuantity(h, product: product, isAddition: true);
          if (delta > 0) {
            created += delta;
          }
        } else if (ev == ItemHistoryEventClass.itemDeleted) {
          final delta = getDeltaQuantity(h, product: product, isAddition: false);
          deleted += delta;
        } else if (ev == ItemHistoryEventClass.produced) {
          if (manageProductions) {
            final delta = getDeltaQuantity(h, product: product, isAddition: true);
            produced += delta;
          }
        } else if (ev == ItemHistoryEventClass.productionDeleted) {
          if (manageProductions) {
            final delta = getDeltaQuantity(h, product: product, isAddition: false);
            productionDeleted += delta;
          }
        } else if (ev == ItemHistoryEventClass.sold) {
          final delta = getDeltaQuantity(h, product: product, isAddition: false);
          sold += delta;
        } else if (ev == ItemHistoryEventClass.returnEvent) {
          final delta = getDeltaQuantity(h, product: product, isAddition: true);
          returned += delta;
        } else if (ev == ItemHistoryEventClass.purchase) {
          final delta = getDeltaQuantity(h, product: product, isAddition: true);
          purchased += delta;
        } else if (ev == ItemHistoryEventClass.delivered) {
          final delta = getDeltaQuantity(h, product: product, isAddition: false);
          delivered += delta;
        } else if (ev == ItemHistoryEventClass.quantityUpdatedIncrease) {
          final delta = getDeltaQuantity(h, product: product, isAddition: true);
          quantityIncreased += delta;
        } else if (ev == ItemHistoryEventClass.quantityUpdatedDecrease) {
          final delta = getDeltaQuantity(h, product: product, isAddition: false);
          quantityDecreased += delta;
        }
      }

      final itemAdditions = transferredIn +
          created +
          produced +
          returned +
          purchased +
          quantityIncreased;

      final itemReductions = transferredOut +
          deleted +
          productionDeleted +
          sold +
          delivered +
          quantityDecreased;

      final netChange = itemAdditions - itemReductions;

      // 3) Closing Stock:
      // If there are events in range, closing stock is the newValue of the last event.
      // Otherwise, it reconciles as openingStock + netChange (= openingStock).
      double? closingStock;
      if (inRangeEvents.isNotEmpty) {
        closingStock = _parseNum(inRangeEvents.last.newValue);
      } else {
        closingStock = openingStock;
      }

      // Current quantity is the live authoritative inventory quantity
      final currentQuantity = product.getActualQuantity() ??
          product.quantity?.toDouble() ??
          0.0;

      final row = ItemHistorySummaryRow(
        index: rowIndex++,
        uuid: pUuid,
        name: pName,
        primaryUnit: primaryUnit,
        openingStock: openingStock,
        closingStock: closingStock,
        currentQuantity: currentQuantity,
        transferredIn: transferredIn,
        transferredOut: transferredOut,
        produced: produced,
        productionDeleted: productionDeleted,
        sold: sold,
        returned: returned,
        purchased: purchased,
        delivered: delivered,
        created: created,
        deleted: deleted,
        quantityIncreased: quantityIncreased,
        quantityDecreased: quantityDecreased,
        totalAdditions: itemAdditions,
        totalReductions: itemReductions,
        netQuantityChange: netChange,
        isManaged: product.isManaged,
        categoryUuids: <String>{
          ...?product.categories,
          if (product.categoryUuid != null) product.categoryUuid!,
        }.toList(),
        departmentUuid: product.departmentUuid,
        createdAt: product.createdAt,
      );

      if (row.hasAnyMovement) {
        itemsWithMovementCount++;
      }

      // Add to global totals
      totalTransferredIn += transferredIn;
      totalTransferredOut += transferredOut;
      totalCreated += created;
      totalDeleted += deleted;
      totalProduced += produced;
      totalProductionDeleted += productionDeleted;
      totalSold += sold;
      totalReturned += returned;
      totalPurchased += purchased;
      totalDelivered += delivered;
      totalQuantityIncreased += quantityIncreased;
      totalQuantityDecreased += quantityDecreased;

      if (itemAdditions > 0) {
        additionsByUnit[primaryUnit] =
            (additionsByUnit[primaryUnit] ?? 0) + itemAdditions;
      }
      if (itemReductions > 0) {
        reductionsByUnit[primaryUnit] =
            (reductionsByUnit[primaryUnit] ?? 0) + itemReductions;
      }

      rows.add(row);
    }

    final globalAdditions = totalTransferredIn +
        totalCreated +
        totalProduced +
        totalReturned +
        totalPurchased +
        totalQuantityIncreased;

    final globalReductions = totalTransferredOut +
        totalDeleted +
        totalProductionDeleted +
        totalSold +
        totalDelivered +
        totalQuantityDecreased;

    final globalNetChange = globalAdditions - globalReductions;

    final stats = ItemHistorySummaryStats(
      totalTransferredIn: totalTransferredIn,
      totalTransferredOut: totalTransferredOut,
      totalCreated: totalCreated,
      totalDeleted: totalDeleted,
      totalProduced: totalProduced,
      totalProductionDeleted: totalProductionDeleted,
      totalSold: totalSold,
      totalReturned: totalReturned,
      totalPurchased: totalPurchased,
      totalDelivered: totalDelivered,
      totalQuantityIncreased: totalQuantityIncreased,
      totalQuantityDecreased: totalQuantityDecreased,
      totalStockAdditions: globalAdditions,
      totalStockReductions: globalReductions,
      netQuantityChange: globalNetChange,
      totalHistoryEvents: totalEventsInPeriod,
      itemsWithMovementCount: itemsWithMovementCount,
      totalDistinctItems: products.length,
      additionsByPrimaryUnit: additionsByUnit,
      reductionsByPrimaryUnit: reductionsByUnit,
    );

    return (stats: stats, rows: rows);
  }

  /// Filters and sorts rows.
  static List<ItemHistorySummaryRow> filterAndSortRows({
    required List<ItemHistorySummaryRow> rows,
    required ItemHistorySummaryFilters filters,
    required ItemHistorySummarySortField sortField,
    required bool ascending,
    required bool departmentsEnabled,
  }) {
    final filtered = rows
        .where((r) => filters.matches(r, departmentsEnabled: departmentsEnabled))
        .toList();

    int cmp<T extends Comparable>(T? a, T? b, bool asc) {
      if (a == null && b == null) return 0;
      if (a == null) return 1;
      if (b == null) return -1;
      final c = a.compareTo(b);
      return asc ? c : -c;
    }

    filtered.sort((a, b) {
      int c;
      switch (sortField) {
        case ItemHistorySummarySortField.rowIndex:
          c = cmp(a.index, b.index, ascending);
          break;
        case ItemHistorySummarySortField.itemName:
          c = cmp(a.name.toLowerCase(), b.name.toLowerCase(), ascending);
          break;
        case ItemHistorySummarySortField.openingStock:
          c = cmp(a.openingStock, b.openingStock, ascending);
          break;
        case ItemHistorySummarySortField.closingStock:
          c = cmp(a.closingStock, b.closingStock, ascending);
          break;
        case ItemHistorySummarySortField.currentQuantity:
          c = cmp(a.currentQuantity, b.currentQuantity, ascending);
          break;
        case ItemHistorySummarySortField.transferredIn:
          c = cmp(a.transferredIn, b.transferredIn, ascending);
          break;
        case ItemHistorySummarySortField.transferredOut:
          c = cmp(a.transferredOut, b.transferredOut, ascending);
          break;
        case ItemHistorySummarySortField.produced:
          c = cmp(a.produced, b.produced, ascending);
          break;
        case ItemHistorySummarySortField.productionDeleted:
          c = cmp(a.productionDeleted, b.productionDeleted, ascending);
          break;
        case ItemHistorySummarySortField.sold:
          c = cmp(a.sold, b.sold, ascending);
          break;
        case ItemHistorySummarySortField.returned:
          c = cmp(a.returned, b.returned, ascending);
          break;
        case ItemHistorySummarySortField.purchased:
          c = cmp(a.purchased, b.purchased, ascending);
          break;
        case ItemHistorySummarySortField.delivered:
          c = cmp(a.delivered, b.delivered, ascending);
          break;
        case ItemHistorySummarySortField.created:
          c = cmp(a.created, b.created, ascending);
          break;
        case ItemHistorySummarySortField.deleted:
          c = cmp(a.deleted, b.deleted, ascending);
          break;
        case ItemHistorySummarySortField.netQuantityChange:
          c = cmp(a.netQuantityChange, b.netQuantityChange, ascending);
          break;
      }
      if (c != 0) return c;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    return filtered;
  }

  /// Paginates rows.
  static ItemHistorySummaryPageResult paginate(
    List<ItemHistorySummaryRow> sorted,
    int requestedPage,
  ) {
    final total = sorted.length;
    final pages =
        total == 0 ? 1 : (total / itemHistorySummaryPageSize).ceil();
    final page = requestedPage.clamp(1, pages);
    final start = (page - 1) * itemHistorySummaryPageSize;
    final end = (start + itemHistorySummaryPageSize) > total
        ? total
        : start + itemHistorySummaryPageSize;

    return ItemHistorySummaryPageResult(
      rows: total == 0 ? const [] : sorted.sublist(start, end),
      totalCount: total,
      page: page,
      totalPages: pages,
    );
  }

  /// Top 3 items by stock addition (inflow leaders).
  static List<ItemHistorySummaryRow> getTopInflowItems(
    List<ItemHistorySummaryRow> rows,
  ) {
    final withInflow = rows.where((r) => r.totalAdditions > 0).toList();
    withInflow.sort((a, b) => b.totalAdditions.compareTo(a.totalAdditions));
    return withInflow.take(3).toList();
  }

  /// Top 3 items by stock reduction / sales turnover (outflow leaders).
  static List<ItemHistorySummaryRow> getTopOutflowItems(
    List<ItemHistorySummaryRow> rows,
  ) {
    final withOutflow = rows.where((r) => r.totalReductions > 0).toList();
    withOutflow.sort((a, b) => b.totalReductions.compareTo(a.totalReductions));
    return withOutflow.take(3).toList();
  }
}
