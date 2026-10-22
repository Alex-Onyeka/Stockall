import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_product_class/units_class/product_units_class.dart';
import 'package:stockall/classes/temp_storage_item_history/storage_item_history.dart';
import 'package:stockall/classes/temp_storage_item_history/storage_item_history_event_class.dart';
import 'package:stockall/classes/temp_storage_product/temp_storage_products.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/pages/report/storage_items_report_/storage_item_history_report/class/storage_item_history_report_logic.dart';
import 'package:stockall/pages/report/storage_items_report_/storage_report_main/class/storage_report_main_logic.dart';

const int storageHistorySummaryPageSize = 50;

enum StorageHistoryPeriod {
  today,
  thisWeek,
  thisMonth,
  allTime,
  custom,
}

extension StorageHistoryPeriodExt on StorageHistoryPeriod {
  String get label {
    switch (this) {
      case StorageHistoryPeriod.today:
        return 'Today';
      case StorageHistoryPeriod.thisWeek:
        return 'This Week';
      case StorageHistoryPeriod.thisMonth:
        return 'This Month';
      case StorageHistoryPeriod.allTime:
        return 'All Time';
      case StorageHistoryPeriod.custom:
        return 'Custom Range';
    }
  }
}

/// What a storage history record did to the storage stock.
enum StorageMovementKind {
  /// Manual stock-in (no sales item).
  stockIn,
  purchase,
  purchaseDeleted,

  /// Stock returned from a sales item into storage.
  returned,

  /// Stock moved out of storage into a sales item.
  transferredOut,
  adjustedUp,
  adjustedDown,
  created,
  deleted,
  duplicated,
  other,
}

extension StorageMovementKindExt on StorageMovementKind {
  String get label {
    switch (this) {
      case StorageMovementKind.stockIn:
        return 'Stocked In';
      case StorageMovementKind.purchase:
        return 'Purchased';
      case StorageMovementKind.purchaseDeleted:
        return 'Purchase Deleted';
      case StorageMovementKind.returned:
        return 'Returned From Sales';
      case StorageMovementKind.transferredOut:
        return 'Transferred Out To Sales';
      case StorageMovementKind.adjustedUp:
        return 'Adjusted Up';
      case StorageMovementKind.adjustedDown:
        return 'Adjusted Down';
      case StorageMovementKind.created:
        return 'Created';
      case StorageMovementKind.deleted:
        return 'Deleted';
      case StorageMovementKind.duplicated:
        return 'Duplicated';
      case StorageMovementKind.other:
        return 'Other';
    }
  }

  bool get isAddition =>
      this == StorageMovementKind.stockIn ||
      this == StorageMovementKind.purchase ||
      this == StorageMovementKind.returned ||
      this == StorageMovementKind.adjustedUp;

  bool get isReduction =>
      this == StorageMovementKind.transferredOut ||
      this == StorageMovementKind.purchaseDeleted ||
      this == StorageMovementKind.adjustedDown;

  /// Events that move stock. Created, deleted and duplicated records
  /// carry no usable quantity and only count as events.
  bool get isQuantityEvent => isAddition || isReduction;
}

/// Maps a StorageItemHistory event to its movement. Storage never writes
/// `transfered_in`/`transfered_out`; if they appear they are read as a
/// stock-in and a transfer to sales.
StorageMovementKind storageMovementKindOf(String? event) {
  if (event == StorageItemHistoryEventClass.stockIn ||
      event == StorageItemHistoryEventClass.transferedIn) {
    return StorageMovementKind.stockIn;
  }
  if (event == StorageItemHistoryEventClass.stockOut ||
      event == StorageItemHistoryEventClass.transferedOut) {
    return StorageMovementKind.transferredOut;
  }
  if (event == StorageItemHistoryEventClass.returnEvent) {
    return StorageMovementKind.returned;
  }
  if (event == StorageItemHistoryEventClass.purchase) {
    return StorageMovementKind.purchase;
  }
  if (event == StorageItemHistoryEventClass.purchaseDeleted) {
    return StorageMovementKind.purchaseDeleted;
  }
  if (event == StorageItemHistoryEventClass.quantityUpdatedIncrease) {
    return StorageMovementKind.adjustedUp;
  }
  if (event == StorageItemHistoryEventClass.quantityUpdatedDecrease) {
    return StorageMovementKind.adjustedDown;
  }
  if (event == StorageItemHistoryEventClass.itemCreated) {
    return StorageMovementKind.created;
  }
  if (event == StorageItemHistoryEventClass.itemDeleted) {
    return StorageMovementKind.deleted;
  }
  if (event == StorageItemHistoryEventClass.itemDuplicated) {
    return StorageMovementKind.duplicated;
  }
  return StorageMovementKind.other;
}

String? _clean(String? s) {
  final t = s?.trim();
  return (t == null || t.isEmpty) ? null : t;
}

/// "12 Pcs, 3.5 Kg"; quantities in different units are never added up.
String formatQuantitiesByUnit(Map<String, double> byUnit) {
  final entries = byUnit.entries.where((e) => e.value != 0).toList()
    ..sort((a, b) => a.key.toLowerCase().compareTo(b.key.toLowerCase()));
  if (entries.isEmpty) return '0';
  return entries
      .map((e) => '${formatLargeNumberDouble(e.value)} ${e.key}')
      .join(', ');
}

/// Units of one storage item. A deleted item has no [storage]; its unit
/// name is taken from its latest history record.
class StorageUnitContext {
  final String uuid;
  final TempStorageProducts? storage;
  final ProductUnitsClass? primaryUnit;
  final List<ProductUnitsClass> units;
  final String primaryUnitName;

  const StorageUnitContext({
    required this.uuid,
    required this.storage,
    required this.primaryUnit,
    required this.units,
    required this.primaryUnitName,
  });

  factory StorageUnitContext.fromStorage(TempStorageProducts storage) {
    ProductUnitsClass primary;
    List<ProductUnitsClass> units;
    try {
      primary = storage.getPrimaryUnit();
      units = storage.getUnitsList();
    } catch (_) {
      // Same fallback as StorageReportRowBuilder (no signed-in user).
      primary = ProductUnitsClass(
        uuid: '${storage.uuid ?? ''}_primary_unit',
        staffUuid: '',
        createdAt: DateTime.now(),
        staffName: '',
        conversion: 1,
        name:
            storage.unit == 'Others'
                ? 'Unit(s)'
                : storage.unit ?? 'Unit(s)',
        isPrimary: true,
        productUuid: storage.uuid ?? '',
        dimensionType:
            storage.quantityType == 2
                ? ProductUnitsClass.sheetUnit
                : null,
      );
      units = (storage.unitsList?.isNotEmpty ?? false)
          ? storage.unitsList!
          : [primary];
    }
    return StorageUnitContext(
      uuid: storage.uuid ?? '',
      storage: storage,
      primaryUnit: primary,
      units: units,
      primaryUnitName: primary.name,
    );
  }

  factory StorageUnitContext.fromHistory(
    String uuid,
    List<StorageItemHistory> histories,
  ) {
    String? unitName;
    DateTime? latest;
    for (final h in histories) {
      final pu = _clean(h.storagePrimaryUnit);
      if (pu == null) continue;
      final t = h.createdAt;
      if (unitName == null ||
          (t != null && (latest == null || t.isAfter(latest)))) {
        unitName = pu;
        latest = t;
      }
    }
    return StorageUnitContext(
      uuid: uuid,
      storage: null,
      primaryUnit: null,
      units: const [],
      primaryUnitName: unitName ?? 'Unit(s)',
    );
  }
}

/// Converts the quantity moved by a record to the storage item's primary
/// unit, tolerating the inconsistent ways records are written.
class StorageMovementNormaliser {
  static double? parse(String? v) {
    if (v == null) return null;
    return double.tryParse(v.replaceAll(',', '').trim());
  }

  /// Quantity moved by [h] in the primary unit of [ctx]: 0 for events
  /// that move no stock, null when the record cannot be normalised.
  ///
  /// 1. The storage old/new difference, when it is recorded in the item's
  ///    current primary unit (or the record has no primary unit).
  /// 2. Otherwise |quantityChange|, converted from [StorageItemHistory.storageUnit]
  ///    when that names one of the storage item's units. Return records
  ///    can hold a sales unit name there; those are not converted.
  static double? quantity(StorageItemHistory h, StorageUnitContext ctx) {
    final kind = storageMovementKindOf(StorageItemHistoryEventClass.eventOf(h));
    if (!kind.isQuantityEvent) return 0;

    final oldV = parse(h.storageItemOldValue);
    final newV = parse(h.storageItemNewValue);
    final recordedUnit = _clean(h.storagePrimaryUnit)?.toLowerCase();
    final primaryName = ctx.primaryUnitName.trim().toLowerCase();
    if (oldV != null &&
        newV != null &&
        (recordedUnit == null || recordedUnit == primaryName)) {
      return (newV - oldV).abs();
    }

    final qc = h.quantityChange;
    if (qc == null) return null;
    if (qc == 0) return 0;
    final storage = ctx.storage;
    final primary = ctx.primaryUnit;
    final unitName = _clean(h.storageUnit)?.toLowerCase();
    if (storage == null || primary == null || unitName == null) {
      return null;
    }
    final matches = ctx.units.where(
      (u) => u.name.trim().toLowerCase() == unitName,
    );
    if (matches.isEmpty) return null;
    final converted = storage.unitFromActual(
      primary,
      storage.actualFromUnit(matches.first, qc.abs()),
    );
    return converted.isFinite ? converted : null;
  }
}

/// Movement quantities and event counts. Quantities are in a single
/// primary unit: one instance per item, or per unit for overall totals.
class StorageMovementTotals {
  final Map<StorageMovementKind, double> quantities = {};
  final Map<StorageMovementKind, int> counts = {};
  int notNormalised = 0;

  void add(StorageMovementKind kind, double? quantity) {
    counts[kind] = (counts[kind] ?? 0) + 1;
    if (!kind.isQuantityEvent) return;
    if (quantity == null) {
      notNormalised++;
    } else {
      quantities[kind] = (quantities[kind] ?? 0) + quantity;
    }
  }

  double of(StorageMovementKind kind) => quantities[kind] ?? 0;
  int countOf(StorageMovementKind kind) => counts[kind] ?? 0;

  double get additions => quantities.entries
      .where((e) => e.key.isAddition)
      .fold(0.0, (s, e) => s + e.value);

  double get reductions => quantities.entries
      .where((e) => e.key.isReduction)
      .fold(0.0, (s, e) => s + e.value);

  double get netChange => additions - reductions;

  /// Stock-in plus purchases, net of deleted purchases.
  double get restocked =>
      of(StorageMovementKind.stockIn) +
      of(StorageMovementKind.purchase) -
      of(StorageMovementKind.purchaseDeleted);

  /// Number of records that moved stock.
  int get movementCount => counts.entries
      .where((e) => e.key.isQuantityEvent)
      .fold(0, (s, e) => s + e.value);

  int get eventCount => counts.values.fold(0, (s, c) => s + c);

  bool get hasMovement => movementCount > 0;
}

/// Overall statistics for the selected period.
class StorageHistorySummaryStats {
  /// Primary unit name -> totals in that unit.
  final Map<String, StorageMovementTotals> byUnit;
  final Map<StorageMovementKind, int> countByKind;
  final int totalHistoryEvents;
  final int notNormalisedCount;
  final int itemsWithMovementCount;
  final int itemsWithHistoryCount;
  final int totalDistinctItems;

  const StorageHistorySummaryStats({
    required this.byUnit,
    required this.countByKind,
    required this.totalHistoryEvents,
    required this.notNormalisedCount,
    required this.itemsWithMovementCount,
    required this.itemsWithHistoryCount,
    required this.totalDistinctItems,
  });

  static const empty = StorageHistorySummaryStats(
    byUnit: {},
    countByKind: {},
    totalHistoryEvents: 0,
    notNormalisedCount: 0,
    itemsWithMovementCount: 0,
    itemsWithHistoryCount: 0,
    totalDistinctItems: 0,
  );

  Map<String, double> _map(double Function(StorageMovementTotals) f) {
    final out = <String, double>{};
    for (final e in byUnit.entries) {
      final v = f(e.value);
      if (v != 0) out[e.key] = v;
    }
    return out;
  }

  Map<String, double> quantityByUnit(StorageMovementKind kind) =>
      _map((t) => t.of(kind));
  Map<String, double> get additionsByUnit => _map((t) => t.additions);
  Map<String, double> get reductionsByUnit => _map((t) => t.reductions);
  Map<String, double> get netChangeByUnit => _map((t) => t.netChange);
  Map<String, double> get restockedByUnit => _map((t) => t.restocked);

  int countOf(StorageMovementKind kind) => countByKind[kind] ?? 0;

  int get movementCount => countByKind.entries
      .where((e) => e.key.isQuantityEvent)
      .fold(0, (s, e) => s + e.value);
}

/// One storage item in the item-level summary table.
class StorageHistorySummaryRow {
  int index;
  final String uuid;

  /// Name from the item's latest history record, else its current name.
  final String name;

  /// Current name when the item exists under a different name.
  final String? currentName;
  final bool exists;
  final String primaryUnit;
  final double? openingStock;
  final double? closingStock;
  final double? currentQuantity;
  final StorageMovementTotals totals;

  StorageHistorySummaryRow({
    required this.index,
    required this.uuid,
    required this.name,
    required this.currentName,
    required this.exists,
    required this.primaryUnit,
    required this.openingStock,
    required this.closingStock,
    required this.currentQuantity,
    required this.totals,
  });

  double get transferredOut => totals.of(StorageMovementKind.transferredOut);
  double get returned => totals.of(StorageMovementKind.returned);
  double get stockedIn => totals.of(StorageMovementKind.stockIn);
  double get purchased => totals.of(StorageMovementKind.purchase);
  double get purchaseDeleted =>
      totals.of(StorageMovementKind.purchaseDeleted);
  double get adjustedUp => totals.of(StorageMovementKind.adjustedUp);
  double get adjustedDown => totals.of(StorageMovementKind.adjustedDown);
  double get totalAdditions => totals.additions;
  double get totalReductions => totals.reductions;
  double get netQuantityChange => totals.netChange;
  double get restocked => totals.restocked;
  int get movementCount => totals.movementCount;
  int get notNormalised => totals.notNormalised;
  bool get hasAnyMovement => totals.hasMovement;

  String quantityText(double? v) =>
      v == null ? '—' : '${formatLargeNumberDouble(v)} $primaryUnit';

  String get netQuantityChangeText {
    final v = netQuantityChange;
    final sign = v > 0 ? '+' : '';
    return '$sign${formatLargeNumberDouble(v)} $primaryUnit';
  }
}

/// Totals for one sales item, department or staff member.
class StorageHistoryBreakdownEntry {
  final String key;
  final String label;
  int count = 0;

  /// Primary unit name -> quantity moved into storage.
  final Map<String, double> inflow = {};

  /// Primary unit name -> quantity moved out of storage.
  final Map<String, double> outflow = {};

  StorageHistoryBreakdownEntry({required this.key, required this.label});
}

class StorageHistoryBreakdowns {
  /// Sales items that received stock from storage.
  final List<StorageHistoryBreakdownEntry> salesItemsSupplied;

  /// Sales items that returned stock to storage.
  final List<StorageHistoryBreakdownEntry> salesItemsReturning;

  /// Sales departments of transfers and returns.
  final List<StorageHistoryBreakdownEntry> departments;
  final List<StorageHistoryBreakdownEntry> storekeepers;
  final List<StorageHistoryBreakdownEntry> otherStaff;

  const StorageHistoryBreakdowns({
    required this.salesItemsSupplied,
    required this.salesItemsReturning,
    required this.departments,
    required this.storekeepers,
    required this.otherStaff,
  });

  static const empty = StorageHistoryBreakdowns(
    salesItemsSupplied: [],
    salesItemsReturning: [],
    departments: [],
    storekeepers: [],
    otherStaff: [],
  );
}

enum StorageHistoryMovementFilter {
  all,
  hasMovement,
  inflowOnly,
  outflowOnly,
  noChange,
}

extension StorageHistoryMovementFilterExt on StorageHistoryMovementFilter {
  String get label {
    switch (this) {
      case StorageHistoryMovementFilter.all:
        return 'All Items';
      case StorageHistoryMovementFilter.hasMovement:
        return 'With Movement';
      case StorageHistoryMovementFilter.inflowOnly:
        return 'Inflow Only';
      case StorageHistoryMovementFilter.outflowOnly:
        return 'Outflow Only';
      case StorageHistoryMovementFilter.noChange:
        return 'Zero Change';
    }
  }
}

enum StorageHistorySummarySortField {
  rowIndex,
  itemName,
  primaryUnit,
  openingStock,
  closingStock,
  currentQuantity,
  transferredOut,
  returned,
  stockedIn,
  purchased,
  purchaseDeleted,
  adjustedUp,
  adjustedDown,
  totalAdditions,
  totalReductions,
  netQuantityChange,
  movementCount,
}

class StorageHistorySummaryFilters {
  String search = '';
  StorageHistoryMovementFilter movementFilter =
      StorageHistoryMovementFilter.all;

  bool get hasAnything =>
      search.trim().isNotEmpty ||
      movementFilter != StorageHistoryMovementFilter.all;

  void clearAll() {
    search = '';
    movementFilter = StorageHistoryMovementFilter.all;
  }

  bool matches(StorageHistorySummaryRow row) {
    final q = search.trim().toLowerCase();
    if (q.isNotEmpty &&
        !row.name.toLowerCase().contains(q) &&
        !(row.currentName?.toLowerCase().contains(q) ?? false) &&
        !row.primaryUnit.toLowerCase().contains(q)) {
      return false;
    }

    switch (movementFilter) {
      case StorageHistoryMovementFilter.all:
        break;
      case StorageHistoryMovementFilter.hasMovement:
        if (!row.hasAnyMovement) return false;
        break;
      case StorageHistoryMovementFilter.inflowOnly:
        if (row.totalAdditions <= 0) return false;
        break;
      case StorageHistoryMovementFilter.outflowOnly:
        if (row.totalReductions <= 0) return false;
        break;
      case StorageHistoryMovementFilter.noChange:
        if (row.netQuantityChange != 0) return false;
        break;
    }
    return true;
  }
}

class StorageHistorySummaryPageResult {
  final List<StorageHistorySummaryRow> rows;
  final int totalCount;
  final int page;
  final int totalPages;

  const StorageHistorySummaryPageResult({
    required this.rows,
    required this.totalCount,
    required this.page,
    required this.totalPages,
  });

  int get firstIndex =>
      totalCount == 0 ? 0 : (page - 1) * storageHistorySummaryPageSize + 1;
  int get lastIndex =>
      firstIndex == 0 ? 0 : firstIndex + rows.length - 1;
}

/// Calculation engine for the Storage Item History Summary. Also used by
/// the Storage Report Analysis for its period performance.
class StorageHistorySummaryBuilder {
  static DateTimeRange resolveDateRange({
    required StorageHistoryPeriod period,
    required DateTime businessNow,
    DateTimeRange? customRange,
  }) {
    final today = DateTime(
      businessNow.year,
      businessNow.month,
      businessNow.day,
    );
    switch (period) {
      case StorageHistoryPeriod.today:
        return DateTimeRange(start: today, end: today);
      case StorageHistoryPeriod.thisWeek:
        // Week starting Monday
        final startOfWeek = today.subtract(
          Duration(days: today.weekday - 1),
        );
        return DateTimeRange(start: startOfWeek, end: today);
      case StorageHistoryPeriod.thisMonth:
        return DateTimeRange(
          start: DateTime(today.year, today.month, 1),
          end: today,
        );
      case StorageHistoryPeriod.allTime:
        return DateTimeRange(
          start: DateTime(2000, 1, 1),
          end: DateTime(2100, 1, 1),
        );
      case StorageHistoryPeriod.custom:
        return customRange ?? DateTimeRange(start: today, end: today);
    }
  }

  /// Business-day window check; All Time accepts every dated record.
  static bool isInPeriod(
    StorageItemHistory h, {
    required StorageHistoryPeriod period,
    required DateTimeRange range,
  }) {
    if (h.createdAt == null) return false;
    if (period == StorageHistoryPeriod.allTime) return true;
    return isDateTimeInBusinessWindow(
      dateTime: h.createdAt,
      rangeStartDate: range.start,
      rangeEndDate: range.end,
    );
  }

  /// Unit contexts for current storage items, plus deleted items that
  /// still have history.
  static Map<String, StorageUnitContext> unitContexts({
    required List<TempStorageProducts> storageProducts,
    required List<StorageItemHistory> histories,
  }) {
    final out = <String, StorageUnitContext>{};
    for (final s in storageProducts) {
      final id = s.uuid;
      if (id == null || id.isEmpty) continue;
      out[id] = StorageUnitContext.fromStorage(s);
    }
    final orphans = <String, List<StorageItemHistory>>{};
    for (final h in histories) {
      final id = h.storageItemUuid;
      if (id == null || id.isEmpty || out.containsKey(id)) continue;
      (orphans[id] ??= []).add(h);
    }
    for (final e in orphans.entries) {
      out[e.key] = StorageUnitContext.fromHistory(e.key, e.value);
    }
    return out;
  }

  /// Movement totals per storage item uuid. Records without a storage
  /// item uuid are skipped.
  static Map<String, StorageMovementTotals> aggregateByItem({
    required List<StorageItemHistory> histories,
    required Map<String, StorageUnitContext> contexts,
  }) {
    final out = <String, StorageMovementTotals>{};
    for (final h in histories) {
      final id = h.storageItemUuid;
      final ctx = id == null ? null : contexts[id];
      if (ctx == null) continue;
      (out[id!] ??= StorageMovementTotals()).add(
        storageMovementKindOf(StorageItemHistoryEventClass.eventOf(h)),
        StorageMovementNormaliser.quantity(h, ctx),
      );
    }
    return out;
  }

  static String? _latestName(List<StorageItemHistory> histories) {
    String? name;
    DateTime? latest;
    for (final h in histories) {
      final n = _clean(h.storageItemName);
      if (n == null) continue;
      final t = h.createdAt;
      if (name == null ||
          (t != null && (latest == null || t.isAfter(latest)))) {
        name = n;
        latest = t;
      }
    }
    return name;
  }

  /// Builds the overall statistics and the item-level rows.
  ///
  /// [histories] must already be scoped to the shop and department
  /// (see [scopeStorageItemHistories]). Rows cover every current storage
  /// item, plus deleted items with history in the period.
  static ({
    StorageHistorySummaryStats stats,
    List<StorageHistorySummaryRow> rows,
  })
  buildSummaryAndRows({
    required List<TempStorageProducts> storageProducts,
    required List<TempProductClass> salesProducts,
    required List<StorageItemHistory> histories,
    required StorageHistoryPeriod period,
    required DateTime businessNow,
    DateTimeRange? customRange,
  }) {
    final range = resolveDateRange(
      period: period,
      businessNow: businessNow,
      customRange: customRange,
    );
    final contexts = unitContexts(
      storageProducts: storageProducts,
      histories: histories,
    );

    final allByItem = <String, List<StorageItemHistory>>{};
    for (final h in histories) {
      final id = h.storageItemUuid;
      if (id == null || id.isEmpty) continue;
      (allByItem[id] ??= []).add(h);
    }

    final inPeriod = histories
        .where((h) => isInPeriod(h, period: period, range: range))
        .toList();
    final totalsByItem = aggregateByItem(
      histories: inPeriod,
      contexts: contexts,
    );

    final reportRows = {
      for (final r in StorageReportRowBuilder.buildAll(
        storageProducts: storageProducts,
        salesProducts: salesProducts,
      ))
        r.uuid: r,
    };

    final startCutoff = period == StorageHistoryPeriod.allTime
        ? DateTime(2000, 1, 1)
        : fourAm(range.start);
    final endCutoff = period == StorageHistoryPeriod.allTime
        ? DateTime(2100, 1, 1)
        : fourAmNextDay(range.end);

    final rows = <StorageHistorySummaryRow>[];
    final ids = <String>{
      ...reportRows.keys.where((id) => id.isNotEmpty),
      ...totalsByItem.keys,
    };
    for (final id in ids) {
      final ctx = contexts[id];
      if (ctx == null) continue;
      final reportRow = reportRows[id];
      final snapshot = _latestName(allByItem[id] ?? const []);
      final current = reportRow?.name;

      StorageStockMovement? movement;
      if (reportRow != null) {
        movement = StorageStockMovementCalculator.calculate(
          row: reportRow,
          histories: allByItem[id] ?? const [],
          startCutoff: startCutoff,
          endCutoff: endCutoff,
        );
      }

      rows.add(
        StorageHistorySummaryRow(
          index: 0,
          uuid: id,
          name: snapshot ?? current ?? 'Unknown Item',
          currentName:
              snapshot == null
                  ? null
                  : currentNameIfDifferent(
                    snapshotName: snapshot,
                    currentName: current,
                  ),
          exists: reportRow != null,
          primaryUnit: reportRow?.primaryUnit ?? ctx.primaryUnitName,
          openingStock: movement?.opening,
          closingStock: movement?.closing,
          currentQuantity: reportRow?.quantity,
          totals: totalsByItem[id] ?? StorageMovementTotals(),
        ),
      );
    }

    rows.sort((a, b) {
      final c = a.name.toLowerCase().compareTo(b.name.toLowerCase());
      return c != 0 ? c : a.uuid.compareTo(b.uuid);
    });
    for (var i = 0; i < rows.length; i++) {
      rows[i].index = i + 1;
    }

    final byUnit = <String, StorageMovementTotals>{};
    final countByKind = <StorageMovementKind, int>{};
    int notNormalised = 0;
    for (final h in inPeriod) {
      final id = h.storageItemUuid;
      final ctx = id == null ? null : contexts[id];
      if (ctx == null) continue;
      final kind = storageMovementKindOf(
        StorageItemHistoryEventClass.eventOf(h),
      );
      final qty = StorageMovementNormaliser.quantity(h, ctx);
      final unit = reportRows[id]?.primaryUnit ?? ctx.primaryUnitName;
      (byUnit[unit] ??= StorageMovementTotals()).add(kind, qty);
      countByKind[kind] = (countByKind[kind] ?? 0) + 1;
      if (kind.isQuantityEvent && qty == null) notNormalised++;
    }

    final stats = StorageHistorySummaryStats(
      byUnit: byUnit,
      countByKind: countByKind,
      totalHistoryEvents: countByKind.values.fold(0, (s, c) => s + c),
      notNormalisedCount: notNormalised,
      itemsWithMovementCount:
          totalsByItem.values.where((t) => t.hasMovement).length,
      itemsWithHistoryCount: totalsByItem.length,
      totalDistinctItems: rows.length,
    );

    return (stats: stats, rows: rows);
  }

  /// Breakdowns by sales item, sales department and staff for the
  /// period. Entries are ordered by record count, then label.
  static StorageHistoryBreakdowns buildBreakdowns({
    required List<TempStorageProducts> storageProducts,
    required List<StorageItemHistory> histories,
    required StorageHistoryPeriod period,
    required DateTime businessNow,
    DateTimeRange? customRange,
  }) {
    final range = resolveDateRange(
      period: period,
      businessNow: businessNow,
      customRange: customRange,
    );
    final contexts = unitContexts(
      storageProducts: storageProducts,
      histories: histories,
    );

    final supplied = <String, StorageHistoryBreakdownEntry>{};
    final returning = <String, StorageHistoryBreakdownEntry>{};
    final departments = <String, StorageHistoryBreakdownEntry>{};
    final storekeepers = <String, StorageHistoryBreakdownEntry>{};
    final otherStaff = <String, StorageHistoryBreakdownEntry>{};

    void addTo(
      Map<String, StorageHistoryBreakdownEntry> map,
      String key,
      String label,
      StorageMovementKind kind,
      double? qty,
      String unit,
    ) {
      final entry = map[key] ??= StorageHistoryBreakdownEntry(
        key: key,
        label: label,
      );
      entry.count++;
      if (qty == null || qty == 0) return;
      final target = kind.isAddition ? entry.inflow : entry.outflow;
      target[unit] = (target[unit] ?? 0) + qty;
    }

    for (final h in histories) {
      if (!isInPeriod(h, period: period, range: range)) continue;
      final kind = storageMovementKindOf(
        StorageItemHistoryEventClass.eventOf(h),
      );
      if (!kind.isQuantityEvent) continue;
      final id = h.storageItemUuid;
      final ctx = id == null ? null : contexts[id];
      if (ctx == null) continue;
      final qty = StorageMovementNormaliser.quantity(h, ctx);
      final unit = ctx.primaryUnitName;

      final isTransfer = kind == StorageMovementKind.transferredOut ||
          kind == StorageMovementKind.returned;
      final salesId = _clean(h.salesItemUuid);
      if (isTransfer && salesId != null) {
        final label = _clean(h.salesItemName) ?? 'Unknown Item';
        addTo(
          kind == StorageMovementKind.transferredOut ? supplied : returning,
          salesId,
          label,
          kind,
          qty,
          unit,
        );
      }
      if (isTransfer) {
        addTo(
          departments,
          _clean(h.salesDepartmentUuid) ?? storageItemHistoryReportNoneKey,
          _clean(h.salesDepartmentName) ?? 'No Department',
          kind,
          qty,
          unit,
        );
      }

      final keeper = StorageHistoryStaff.storekeeperKey(h);
      if (keeper != null) {
        addTo(
          storekeepers,
          keeper,
          _clean(h.storageStaffName) ?? 'Unknown Staff',
          kind,
          qty,
          unit,
        );
      }
      final other = StorageHistoryStaff.otherStaffKey(h);
      if (other != null) {
        addTo(
          otherStaff,
          other,
          _clean(h.salesStaffName) ?? 'Unknown Staff',
          kind,
          qty,
          unit,
        );
      }
    }

    List<StorageHistoryBreakdownEntry> sorted(
      Map<String, StorageHistoryBreakdownEntry> map,
    ) =>
        map.values.toList()
          ..sort((a, b) {
            final c = b.count.compareTo(a.count);
            if (c != 0) return c;
            return a.label.toLowerCase().compareTo(b.label.toLowerCase());
          });

    return StorageHistoryBreakdowns(
      salesItemsSupplied: sorted(supplied),
      salesItemsReturning: sorted(returning),
      departments: sorted(departments),
      storekeepers: sorted(storekeepers),
      otherStaff: sorted(otherStaff),
    );
  }

  static List<StorageHistorySummaryRow> filterAndSortRows({
    required List<StorageHistorySummaryRow> rows,
    required StorageHistorySummaryFilters filters,
    required StorageHistorySummarySortField sortField,
    required bool ascending,
  }) {
    final filtered = rows.where(filters.matches).toList();

    int cmp<T extends Comparable>(T? a, T? b) {
      if (a == null && b == null) return 0;
      if (a == null) return 1;
      if (b == null) return -1;
      final c = a.compareTo(b);
      return ascending ? c : -c;
    }

    filtered.sort((a, b) {
      int c;
      switch (sortField) {
        case StorageHistorySummarySortField.rowIndex:
          c = cmp(a.index, b.index);
          break;
        case StorageHistorySummarySortField.itemName:
          c = cmp(a.name.toLowerCase(), b.name.toLowerCase());
          break;
        case StorageHistorySummarySortField.primaryUnit:
          c = cmp(a.primaryUnit.toLowerCase(), b.primaryUnit.toLowerCase());
          break;
        case StorageHistorySummarySortField.openingStock:
          c = cmp(a.openingStock, b.openingStock);
          break;
        case StorageHistorySummarySortField.closingStock:
          c = cmp(a.closingStock, b.closingStock);
          break;
        case StorageHistorySummarySortField.currentQuantity:
          c = cmp(a.currentQuantity, b.currentQuantity);
          break;
        case StorageHistorySummarySortField.transferredOut:
          c = cmp(a.transferredOut, b.transferredOut);
          break;
        case StorageHistorySummarySortField.returned:
          c = cmp(a.returned, b.returned);
          break;
        case StorageHistorySummarySortField.stockedIn:
          c = cmp(a.stockedIn, b.stockedIn);
          break;
        case StorageHistorySummarySortField.purchased:
          c = cmp(a.purchased, b.purchased);
          break;
        case StorageHistorySummarySortField.purchaseDeleted:
          c = cmp(a.purchaseDeleted, b.purchaseDeleted);
          break;
        case StorageHistorySummarySortField.adjustedUp:
          c = cmp(a.adjustedUp, b.adjustedUp);
          break;
        case StorageHistorySummarySortField.adjustedDown:
          c = cmp(a.adjustedDown, b.adjustedDown);
          break;
        case StorageHistorySummarySortField.totalAdditions:
          c = cmp(a.totalAdditions, b.totalAdditions);
          break;
        case StorageHistorySummarySortField.totalReductions:
          c = cmp(a.totalReductions, b.totalReductions);
          break;
        case StorageHistorySummarySortField.netQuantityChange:
          c = cmp(a.netQuantityChange, b.netQuantityChange);
          break;
        case StorageHistorySummarySortField.movementCount:
          c = cmp(a.movementCount, b.movementCount);
          break;
      }
      if (c != 0) return c;
      final n = a.name.toLowerCase().compareTo(b.name.toLowerCase());
      return n != 0 ? n : a.uuid.compareTo(b.uuid);
    });
    return filtered;
  }

  static StorageHistorySummaryPageResult paginate(
    List<StorageHistorySummaryRow> sorted,
    int requestedPage,
  ) {
    final total = sorted.length;
    final pages =
        total == 0 ? 1 : (total / storageHistorySummaryPageSize).ceil();
    final page = requestedPage.clamp(1, pages);
    final start = (page - 1) * storageHistorySummaryPageSize;
    final end = (start + storageHistorySummaryPageSize) > total
        ? total
        : start + storageHistorySummaryPageSize;
    return StorageHistorySummaryPageResult(
      rows: total == 0 ? const [] : sorted.sublist(start, end),
      totalCount: total,
      page: page,
      totalPages: pages,
    );
  }

  /// Top 3 items by stock added (inflow leaders).
  static List<StorageHistorySummaryRow> getTopInflowItems(
    List<StorageHistorySummaryRow> rows,
  ) {
    final withInflow = rows.where((r) => r.totalAdditions > 0).toList()
      ..sort((a, b) => b.totalAdditions.compareTo(a.totalAdditions));
    return withInflow.take(3).toList();
  }

  /// Top 3 items by stock removed (outflow leaders).
  static List<StorageHistorySummaryRow> getTopOutflowItems(
    List<StorageHistorySummaryRow> rows,
  ) {
    final withOutflow = rows.where((r) => r.totalReductions > 0).toList()
      ..sort((a, b) => b.totalReductions.compareTo(a.totalReductions));
    return withOutflow.take(3).toList();
  }
}
