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

extension ItemHistoryMovementFilterExt
    on ItemHistoryMovementFilter {
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
  netQuantityChange,
  sold,
  returnedReceipt,
  purchased,
  returnedPurchase,
  transferredIn,
  transferredOut,
  produced,
  productionDeleted,
  delivered,
  created,
  deleted,
  returned,
  stockInUpdated,
  stockOutUpdated,
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
  final double totalReturnedReceipt;
  final double totalReturnedPurchase;
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

  double get totalReturned => totalReturnedReceipt;

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
    required this.totalReturnedReceipt,
    this.totalReturnedPurchase = 0,
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
    totalReturnedReceipt: 0,
    totalReturnedPurchase: 0,
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
  final double returnedReceipt;
  final double purchased;
  final double returnedPurchase;
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

  double get returned => returnedReceipt;

  double get stockInUpdated => quantityIncreased;
  double get stockOutUpdated => quantityDecreased;
  String get stockInUpdatedText => quantityIncreasedText;
  String get stockInUpdatedDisplay =>
      quantityIncreasedDisplay;
  String get stockOutUpdatedText => quantityDecreasedText;
  String get stockOutUpdatedDisplay =>
      quantityDecreasedDisplay;

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
    required this.returnedReceipt,
    required this.purchased,
    this.returnedPurchase = 0,
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
      returnedReceipt != 0 ||
      purchased != 0 ||
      returnedPurchase != 0 ||
      delivered != 0 ||
      created != 0 ||
      deleted != 0 ||
      quantityIncreased != 0 ||
      quantityDecreased != 0;

  String get unitSuffix =>
      primaryUnit.trim().isNotEmpty ? ' $primaryUnit' : '';

  String formatQuantity(
    double? value, {
    bool showSign = false,
    bool isNegative = false,
  }) {
    if (value == null) return '—';
    final formatted = formatLargeNumberDouble(value.abs());
    if (showSign) {
      if (isNegative && value > 0) {
        return '-$formatted$unitSuffix';
      } else if (!isNegative && value > 0) {
        return '+$formatted$unitSuffix';
      }
    }
    return '$formatted$unitSuffix';
  }

  String get openingStockText =>
      openingStock != null
          ? '${formatLargeNumberDouble(openingStock!)}$unitSuffix'
          : '—';
  String get openingStockDisplay => openingStockText;

  String get closingStockText =>
      closingStock != null
          ? '${formatLargeNumberDouble(closingStock!)}$unitSuffix'
          : '—';
  String get closingStockDisplay => closingStockText;

  String get currentQuantityText =>
      '${formatLargeNumberDouble(currentQuantity)}$unitSuffix';
  String get currentQuantityDisplay => currentQuantityText;

  String get netQuantityChangeText {
    if (netQuantityChange == 0) return '0$unitSuffix';
    final sign = netQuantityChange > 0 ? '+' : '-';
    return '$sign${formatLargeNumberDouble(netQuantityChange.abs())}$unitSuffix';
  }

  String get netQuantityChangeDisplay =>
      netQuantityChangeText;

  String get soldText =>
      sold > 0
          ? '-${formatLargeNumberDouble(sold)}$unitSuffix'
          : '—';
  String get soldDisplay => soldText;

  String get returnedReceiptText =>
      returnedReceipt > 0
          ? '+${formatLargeNumberDouble(returnedReceipt)}$unitSuffix'
          : '—';
  String get returnedReceiptDisplay => returnedReceiptText;

  String get purchasedText =>
      purchased > 0
          ? '+${formatLargeNumberDouble(purchased)}$unitSuffix'
          : '—';
  String get purchasedDisplay => purchasedText;

  String get returnedPurchaseText =>
      returnedPurchase > 0
          ? '-${formatLargeNumberDouble(returnedPurchase)}$unitSuffix'
          : '—';
  String get returnedPurchaseDisplay =>
      returnedPurchaseText;

  String get transferredInText =>
      transferredIn > 0
          ? '+${formatLargeNumberDouble(transferredIn)}$unitSuffix'
          : '—';
  String get transferredInDisplay => transferredInText;

  String get transferredOutText =>
      transferredOut > 0
          ? '-${formatLargeNumberDouble(transferredOut)}$unitSuffix'
          : '—';
  String get transferredOutDisplay => transferredOutText;

  String get producedText =>
      produced > 0
          ? '+${formatLargeNumberDouble(produced)}$unitSuffix'
          : '—';
  String get producedDisplay => producedText;

  String get productionDeletedText =>
      productionDeleted > 0
          ? '-${formatLargeNumberDouble(productionDeleted)}$unitSuffix'
          : '—';
  String get productionDeletedDisplay =>
      productionDeletedText;

  String get deliveredText =>
      delivered > 0
          ? '-${formatLargeNumberDouble(delivered)}$unitSuffix'
          : '—';
  String get deliveredDisplay => deliveredText;

  String get createdText =>
      created > 0
          ? '+${formatLargeNumberDouble(created)}$unitSuffix'
          : '—';
  String get createdDisplay => createdText;

  String get deletedText =>
      deleted > 0
          ? '-${formatLargeNumberDouble(deleted)}$unitSuffix'
          : '—';
  String get deletedDisplay => deletedText;

  String get quantityIncreasedText =>
      quantityIncreased > 0
          ? '+${formatLargeNumberDouble(quantityIncreased)}$unitSuffix'
          : '—';
  String get quantityIncreasedDisplay =>
      quantityIncreasedText;

  String get quantityDecreasedText =>
      quantityDecreased > 0
          ? '-${formatLargeNumberDouble(quantityDecreased)}$unitSuffix'
          : '—';
  String get quantityDecreasedDisplay =>
      quantityDecreasedText;

  String get totalAdditionsText =>
      '+${formatLargeNumberDouble(totalAdditions)}$unitSuffix';
  String get totalAdditionsDisplay => totalAdditionsText;

  String get totalReductionsText =>
      '-${formatLargeNumberDouble(totalReductions)}$unitSuffix';
  String get totalReductionsDisplay => totalReductionsText;
}

class ItemHistorySummaryFilters {
  String search = '';
  String? categoryKey;
  String? departmentKey;
  ItemHistoryMovementFilter movementFilter =
      ItemHistoryMovementFilter.all;

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
  final int pageSize;

  const ItemHistorySummaryPageResult({
    required this.rows,
    required this.totalCount,
    required this.page,
    required this.totalPages,
    this.pageSize = itemHistorySummaryPageSize,
  });

  int get firstIndex =>
      totalCount == 0 ? 0 : (page - 1) * pageSize + 1;
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

  /// Date cutoff resolver for the specified period.
  static DateTimeRange resolveDateRange({
    required ItemHistoryPeriod period,
    required DateTime businessNow,
    DateTimeRange? customRange,
  }) {
    final today = DateTime(
      businessNow.year,
      businessNow.month,
      businessNow.day,
    );
    switch (period) {
      case ItemHistoryPeriod.today:
        return DateTimeRange(start: today, end: today);
      case ItemHistoryPeriod.thisWeek:
        final weekday = today.weekday;
        final startOfWeek = today.subtract(
          Duration(days: weekday - 1),
        );
        return DateTimeRange(
          start: startOfWeek,
          end: today,
        );
      case ItemHistoryPeriod.thisMonth:
        final startOfMonth = DateTime(
          today.year,
          today.month,
          1,
        );
        return DateTimeRange(
          start: startOfMonth,
          end: today,
        );
      case ItemHistoryPeriod.allTime:
        return DateTimeRange(
          start: DateTime(2000, 1, 1),
          end: DateTime(2100, 1, 1),
        );
      case ItemHistoryPeriod.custom:
        return customRange ??
            DateTimeRange(start: today, end: today);
    }
  }

  /// Computes the normalized delta quantity for [h] expressed in the item's primary unit.
  static double getDeltaQuantity(
    ItemHistory h, {
    required TempProductClass product,
    required bool isAddition,
  }) {
    // 1) First check: if oldValue and newValue are present, their difference
    // represents the change in the recorded unit balance.
    final oldV = _parseNum(h.oldValue);
    final newV = _parseNum(h.newValue);

    if (oldV != null && newV != null) {
      if (ItemHistoryEventClass.eventOf(h) ==
          ItemHistoryEventClass.itemDeleted) {
        return oldV.abs();
      }
      final diff = (newV - oldV).abs();
      if (diff > 0.00001) {
        // If history has primaryUnit matching product's primary unit, diff is already in primary unit.
        final pu = h.primaryUnit;
        final productPrimary =
            product
                .getPrimaryUnit()
                .name
                .trim()
                .toLowerCase();
        if (pu == null ||
            pu.trim().isEmpty ||
            pu.trim().toLowerCase() == productPrimary) {
          return diff;
        }
      }
    }

    // 2) Fallback or explicit conversion via quantityChange and unit
    if (h.quantityChange != null && h.quantityChange != 0) {
      final rawQty = h.quantityChange!.abs();
      final unitName = h.unit?.trim();
      if (unitName != null && unitName.isNotEmpty) {
        try {
          final unitList = product.getUnitsList();
          final matchingUnit = unitList.firstWhere(
            (u) =>
                u.name.trim().toLowerCase() ==
                    unitName.toLowerCase() ||
                unitName.toLowerCase().startsWith(
                  u.name.trim().toLowerCase(),
                ),
            orElse: () => product.getPrimaryUnit(),
          );

          if (matchingUnit.isPrimary) {
            return rawQty;
          }

          // Convert to primary unit:
          // For dimensional sheets (2D): getQuantityEquivMultiplied converts sheets to area
          // For standard items: getQuantityEquivMultiplied converts secondary unit count to primary base count
          final converted = matchingUnit
              .getQuantityEquivMultiplied(
                index: 1,
                newQuantity: rawQty,
                product: product,
              );
          if (converted > 0) return converted;
        } catch (_) {}
      }
      return rawQty;
    }

    // 3) Fallback to diff between oldV and newV even if unit tag differs
    if (oldV != null && newV != null) {
      final diff = (newV - oldV).abs();
      if (diff > 0.00001) return diff;
    }

    return 0.0;
  }

  /// Builds Summary Statistics and item-level summary rows.
  static ({
    ItemHistorySummaryStats stats,
    List<ItemHistorySummaryRow> rows,
  })
  buildSummaryAndRows({
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

    final startCutoff =
        period == ItemHistoryPeriod.allTime
            ? DateTime(2000, 1, 1)
            : fourAm(range.start);
    final endCutoff =
        period == ItemHistoryPeriod.allTime
            ? DateTime(2100, 1, 1)
            : fourAmNextDay(range.end);

    // Group history records by product uuid (and name fallback)
    final Map<String, List<ItemHistory>>
    historyByProductUuid = {};
    final Map<String, List<ItemHistory>>
    historyByProductName = {};

    for (final h in histories) {
      if (h.createdAt == null) {
        continue;
      }
      final u = h.itemUuid;
      if (u != null && u.isNotEmpty) {
        (historyByProductUuid[u] ??= []).add(h);
      }
      final nameKey =
          (h.itemName ?? '').trim().toLowerCase();
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
    double totalReturnedReceipt = 0;
    double totalReturnedPurchase = 0;
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

      final byUuid =
          pUuid.isNotEmpty
              ? (historyByProductUuid[pUuid] ?? [])
              : <ItemHistory>[];
      final byName =
          historyByProductName[pName
              .trim()
              .toLowerCase()] ??
          [];

      // Combine by uuid and name without duplicate histories
      final seenUuids = <String>{};
      final List<ItemHistory> combinedEvents = [];
      for (final h in [...byUuid, ...byName]) {
        final key =
            h.uuid ??
            '${h.createdAt?.millisecondsSinceEpoch}_${h.event}_${h.oldValue}_${h.newValue}';
        if (seenUuids.add(key)) {
          combinedEvents.add(h);
        }
      }

      // Filter to valid stock events
      final usable =
          combinedEvents.where((h) {
              if (h.createdAt == null) {
                return false;
              }
              final ev = ItemHistoryEventClass.eventOf(h);
              if (ev == null || !_stockEvents.contains(ev)) {
                return false;
              }
              return true;
            }).toList()
            ..sort(
              (a, b) =>
                  a.createdAt!.compareTo(b.createdAt!),
            );

      // 1) Opening Stock: balance immediately before startCutoff
      double? openingStock;
      bool openingFound = false;

      for (final h in usable) {
        final start = _alignCutoff(
          h.createdAt!,
          startCutoff,
        );
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
          final start =
              created != null
                  ? _alignCutoff(created, startCutoff)
                  : startCutoff;
          if (created != null && !created.isBefore(start)) {
            openingStock = 0;
          } else {
            final qtyDivided = product
                .getPrimaryUnit()
                .getQuantityEquivDivided(
                  index: 1,
                  product: product,
                );
            openingStock =
                qtyDivided.isFinite ? qtyDivided : 0.0;
          }
        }
      }

      // 2) Stock movements strictly within the selected reporting period
      double transferredIn = 0;
      double transferredOut = 0;
      double produced = 0;
      double productionDeleted = 0;
      double sold = 0;
      double returnedReceipt = 0;
      double purchased = 0;
      double returnedPurchase = 0;
      double delivered = 0;
      double created = 0;
      double deleted = 0;
      double quantityIncreased = 0;
      double quantityDecreased = 0;

      final inRangeEvents =
          usable.where((h) {
            final start = _alignCutoff(
              h.createdAt!,
              startCutoff,
            );
            final end = _alignCutoff(
              h.createdAt!,
              endCutoff,
            );
            return !h.createdAt!.isBefore(start) &&
                !h.createdAt!.isAfter(end);
          }).toList();

      for (final h in inRangeEvents) {
        final ev = ItemHistoryEventClass.eventOf(h);
        totalEventsInPeriod++;

        if (ev == ItemHistoryEventClass.transferedIn) {
          final delta = getDeltaQuantity(
            h,
            product: product,
            isAddition: true,
          );
          transferredIn += delta;
        } else if (ev ==
            ItemHistoryEventClass.transferedOut) {
          final delta = getDeltaQuantity(
            h,
            product: product,
            isAddition: false,
          );
          transferredOut += delta;
        } else if (ev ==
                ItemHistoryEventClass.itemCreated ||
            ev == ItemHistoryEventClass.itemDuplicated) {
          // Section 6.3.2: Only establish stock addition if initial stock was given
          final delta = getDeltaQuantity(
            h,
            product: product,
            isAddition: true,
          );
          if (delta > 0) {
            created += delta;
          }
        } else if (ev ==
            ItemHistoryEventClass.itemDeleted) {
          final delta = getDeltaQuantity(
            h,
            product: product,
            isAddition: false,
          );
          deleted += delta;
        } else if (ev == ItemHistoryEventClass.produced) {
          if (manageProductions) {
            final delta = getDeltaQuantity(
              h,
              product: product,
              isAddition: true,
            );
            produced += delta;
          }
        } else if (ev ==
            ItemHistoryEventClass.productionDeleted) {
          if (manageProductions) {
            final delta = getDeltaQuantity(
              h,
              product: product,
              isAddition: false,
            );
            productionDeleted += delta;
          }
        } else if (ev == ItemHistoryEventClass.sold) {
          final delta = getDeltaQuantity(
            h,
            product: product,
            isAddition: false,
          );
          sold += delta;
        } else if (ev ==
            ItemHistoryEventClass.returnEvent) {
          final isPurchaseReturn =
              (h.destination ==
                  ItemHistoryEventClass
                      .purchaseDestination) ||
              (h.source ==
                  ItemHistoryEventClass.purchaseSource) ||
              (h.isIncreased == false) ||
              ((h.desc?.toLowerCase().contains(
                    'purchase',
                  )) ??
                  false) ||
              h.title.toLowerCase().contains('purchase');

          if (isPurchaseReturn) {
            final delta = getDeltaQuantity(
              h,
              product: product,
              isAddition: false,
            );
            returnedPurchase += delta;
          } else {
            final delta = getDeltaQuantity(
              h,
              product: product,
              isAddition: true,
            );
            returnedReceipt += delta;
          }
        } else if (ev == ItemHistoryEventClass.purchase) {
          final delta = getDeltaQuantity(
            h,
            product: product,
            isAddition: true,
          );
          purchased += delta;
        } else if (ev == ItemHistoryEventClass.delivered) {
          final delta = getDeltaQuantity(
            h,
            product: product,
            isAddition: false,
          );
          delivered += delta;
        } else if (ev ==
                ItemHistoryEventClass
                    .quantityUpdatedIncrease ||
            (h.isIncreased == true &&
                h.title.toLowerCase().contains(
                  'quantity increased',
                ))) {
          final delta = getDeltaQuantity(
            h,
            product: product,
            isAddition: true,
          );
          quantityIncreased += delta;
        } else if (ev ==
                ItemHistoryEventClass
                    .quantityUpdatedDecrease ||
            (h.isIncreased == false &&
                h.title.toLowerCase().contains(
                  'quantity reduced',
                ))) {
          final delta = getDeltaQuantity(
            h,
            product: product,
            isAddition: false,
          );
          quantityDecreased += delta;
        }
      }

      final itemAdditions =
          transferredIn +
          created +
          produced +
          returnedReceipt +
          purchased +
          quantityIncreased;

      final itemReductions =
          transferredOut +
          deleted +
          productionDeleted +
          sold +
          returnedPurchase +
          delivered +
          quantityDecreased;

      final netChange = itemAdditions - itemReductions;

      // 3) Closing Stock:
      // If there are events in range, closing stock is the newValue of the last event.
      // Otherwise, it reconciles as openingStock + netChange (= openingStock).
      double? closingStock;
      if (inRangeEvents.isNotEmpty) {
        closingStock = _parseNum(
          inRangeEvents.last.newValue,
        );
      } else {
        closingStock = openingStock;
      }

      // Current quantity is gotten from the actual product primary quantity divided,
      // reflecting the live current stock level in the item's primary unit.
      final primaryUnitObj = product.getPrimaryUnit();
      double currentQuantity = primaryUnitObj
          .getQuantityEquivDivided(
            index: 1,
            product: product,
          );
      if (!currentQuantity.isFinite) {
        currentQuantity = 0.0;
      }

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
        returnedReceipt: returnedReceipt,
        purchased: purchased,
        returnedPurchase: returnedPurchase,
        delivered: delivered,
        created: created,
        deleted: deleted,
        quantityIncreased: quantityIncreased,
        quantityDecreased: quantityDecreased,
        totalAdditions: itemAdditions,
        totalReductions: itemReductions,
        netQuantityChange: netChange,
        isManaged: product.isManaged,
        categoryUuids:
            <String>{
              ...?product.categories,
              if (product.categoryUuid != null)
                product.categoryUuid!,
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
      totalReturnedReceipt += returnedReceipt;
      totalReturnedPurchase += returnedPurchase;
      totalPurchased += purchased;
      totalDelivered += delivered;
      totalQuantityIncreased += quantityIncreased;
      totalQuantityDecreased += quantityDecreased;

      if (itemAdditions > 0) {
        additionsByUnit[primaryUnit] =
            (additionsByUnit[primaryUnit] ?? 0) +
            itemAdditions;
      }
      if (itemReductions > 0) {
        reductionsByUnit[primaryUnit] =
            (reductionsByUnit[primaryUnit] ?? 0) +
            itemReductions;
      }

      rows.add(row);
    }

    final globalAdditions =
        totalTransferredIn +
        totalCreated +
        totalProduced +
        totalReturnedReceipt +
        totalPurchased +
        totalQuantityIncreased;

    final globalReductions =
        totalTransferredOut +
        totalDeleted +
        totalProductionDeleted +
        totalSold +
        totalReturnedPurchase +
        totalDelivered +
        totalQuantityDecreased;

    final globalNetChange =
        globalAdditions - globalReductions;

    final stats = ItemHistorySummaryStats(
      totalTransferredIn: totalTransferredIn,
      totalTransferredOut: totalTransferredOut,
      totalCreated: totalCreated,
      totalDeleted: totalDeleted,
      totalProduced: totalProduced,
      totalProductionDeleted: totalProductionDeleted,
      totalSold: totalSold,
      totalReturnedReceipt: totalReturnedReceipt,
      totalReturnedPurchase: totalReturnedPurchase,
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
    final filtered =
        rows
            .where(
              (r) => filters.matches(
                r,
                departmentsEnabled: departmentsEnabled,
              ),
            )
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
          c = cmp(
            a.name.toLowerCase(),
            b.name.toLowerCase(),
            ascending,
          );
          break;
        case ItemHistorySummarySortField.openingStock:
          c = cmp(
            a.openingStock,
            b.openingStock,
            ascending,
          );
          break;
        case ItemHistorySummarySortField.closingStock:
          c = cmp(
            a.closingStock,
            b.closingStock,
            ascending,
          );
          break;
        case ItemHistorySummarySortField.currentQuantity:
          c = cmp(
            a.currentQuantity,
            b.currentQuantity,
            ascending,
          );
          break;
        case ItemHistorySummarySortField.transferredIn:
          c = cmp(
            a.transferredIn,
            b.transferredIn,
            ascending,
          );
          break;
        case ItemHistorySummarySortField.transferredOut:
          c = cmp(
            a.transferredOut,
            b.transferredOut,
            ascending,
          );
          break;
        case ItemHistorySummarySortField.produced:
          c = cmp(a.produced, b.produced, ascending);
          break;
        case ItemHistorySummarySortField.productionDeleted:
          c = cmp(
            a.productionDeleted,
            b.productionDeleted,
            ascending,
          );
          break;
        case ItemHistorySummarySortField.sold:
          c = cmp(a.sold, b.sold, ascending);
          break;
        case ItemHistorySummarySortField.returnedReceipt:
        case ItemHistorySummarySortField.returned:
          c = cmp(
            a.returnedReceipt,
            b.returnedReceipt,
            ascending,
          );
          break;
        case ItemHistorySummarySortField.purchased:
          c = cmp(a.purchased, b.purchased, ascending);
          break;
        case ItemHistorySummarySortField.returnedPurchase:
          c = cmp(
            a.returnedPurchase,
            b.returnedPurchase,
            ascending,
          );
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
        case ItemHistorySummarySortField.stockInUpdated:
          c = cmp(
            a.quantityIncreased,
            b.quantityIncreased,
            ascending,
          );
          break;
        case ItemHistorySummarySortField.stockOutUpdated:
          c = cmp(
            a.quantityDecreased,
            b.quantityDecreased,
            ascending,
          );
          break;
        case ItemHistorySummarySortField.netQuantityChange:
          c = cmp(
            a.netQuantityChange,
            b.netQuantityChange,
            ascending,
          );
          break;
      }
      if (c != 0) return c;
      return a.name.toLowerCase().compareTo(
        b.name.toLowerCase(),
      );
    });

    return filtered;
  }

  /// Paginates rows.
  static ItemHistorySummaryPageResult paginate(
    List<ItemHistorySummaryRow> sorted,
    int requestedPage, {
    int pageSize = itemHistorySummaryPageSize,
  }) {
    final total = sorted.length;
    final pages =
        total == 0 ? 1 : (total / pageSize).ceil();
    final page = requestedPage.clamp(1, pages);
    final start = (page - 1) * pageSize;
    final end =
        (start + pageSize) > total
            ? total
            : start + pageSize;

    return ItemHistorySummaryPageResult(
      rows:
          total == 0
              ? const []
              : sorted.sublist(start, end),
      totalCount: total,
      page: page,
      totalPages: pages,
      pageSize: pageSize,
    );
  }

  /// Top 3 items by stock addition (inflow leaders).
  static List<ItemHistorySummaryRow> getTopInflowItems(
    List<ItemHistorySummaryRow> rows,
  ) {
    final withInflow =
        rows.where((r) => r.totalAdditions > 0).toList();
    withInflow.sort(
      (a, b) =>
          b.totalAdditions.compareTo(a.totalAdditions),
    );
    return withInflow.take(3).toList();
  }

  /// Top 3 items by stock reduction / sales turnover (outflow leaders).
  static List<ItemHistorySummaryRow> getTopOutflowItems(
    List<ItemHistorySummaryRow> rows,
  ) {
    final withOutflow =
        rows.where((r) => r.totalReductions > 0).toList();
    withOutflow.sort(
      (a, b) =>
          b.totalReductions.compareTo(a.totalReductions),
    );
    return withOutflow.take(3).toList();
  }
}
