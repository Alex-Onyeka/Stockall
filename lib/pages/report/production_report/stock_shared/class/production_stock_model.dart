// The stock module shared by the Produced Items pages and the
// Materials pages: one item adapter, one history adapter, the movement
// kinds of each, the quantity normaliser and the period balances.
//
// Pure Dart: no BuildContext and no providers.

import 'package:flutter/material.dart' show TimeOfDay;
import 'package:stockall/classes/temp_product_class/units_class/product_units_class.dart';
import 'package:stockall/classes/temp_production_folder/temp_material_class/material_class.dart';
import 'package:stockall/classes/temp_production_folder/temp_materials_item_history/material_item_history_event_class.dart';
import 'package:stockall/classes/temp_production_folder/temp_materials_item_history/materials_item_history.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_item_history/production_item_history.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_item_history/production_item_history_event_class.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_items/production_item.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/pages/report/production_report/shared/class/production_report_access.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

/// Which stock the shared pages show.
enum ProductionStockKind { material, producedItem }

extension ProductionStockKindLabel on ProductionStockKind {
  /// "Material" / "Produced Item".
  String get singular =>
      this == ProductionStockKind.material ? 'Material' : 'Produced Item';

  /// "Materials" / "Produced Items".
  String get plural =>
      this == ProductionStockKind.material ? 'Materials' : 'Produced Items';

  /// "materials" / "produced_items", for file names and keys.
  String get slug =>
      this == ProductionStockKind.material ? 'materials' : 'produced_items';

  /// "items" / "materials" in counts.
  String get countNoun =>
      this == ProductionStockKind.material ? 'materials' : 'items';
}

String? _clean(String? s) {
  final t = s?.trim();
  return (t == null || t.isEmpty) ? null : t;
}

/// A material or a produced item, read once. Quantities and cost are
/// per base unit, as stored.
class ProductionStockItem {
  final ProductionStockKind kind;
  final String uuid;
  final String name;

  /// The legacy unit name ("Others" reads as "Unit(s)").
  final String? unit;
  final List<ProductUnitsClass>? unitsList;
  final double costPrice;
  final double? quantity;
  final String? departmentUuid;
  final String? departmentName;
  final List<String> categoryUuids;
  final DateTime? expiryDate;
  final bool isManaged;
  final DateTime? createdAt;

  /// Materials only.
  final double? lowQtty;

  /// Legacy group unit, for converting old records.
  final String? groupUnit;
  final double? qttyPerGroup;

  const ProductionStockItem({
    required this.kind,
    required this.uuid,
    required this.name,
    required this.unit,
    required this.unitsList,
    required this.costPrice,
    required this.quantity,
    required this.departmentUuid,
    required this.departmentName,
    required this.categoryUuids,
    required this.expiryDate,
    required this.isManaged,
    required this.createdAt,
    this.lowQtty,
    this.groupUnit,
    this.qttyPerGroup,
  });

  static List<String> _categories(String? single, List<String>? list) => [
    ...{...?list, if (single != null) single}.where((e) => e.trim().isNotEmpty),
  ];

  factory ProductionStockItem.fromMaterial(MaterialClass m) =>
      ProductionStockItem(
        kind: ProductionStockKind.material,
        uuid: m.uuid ?? '',
        name: m.name,
        unit: m.unit,
        unitsList: m.unitsList,
        costPrice: m.costPrice,
        quantity: m.quantity,
        departmentUuid: _clean(m.departmentUuid),
        departmentName: _clean(m.departmentName),
        categoryUuids: _categories(m.categoryUuid, m.categories),
        expiryDate: m.expiryDate,
        isManaged: m.isManaged,
        createdAt: m.createdAt,
        lowQtty: m.lowQtty,
        groupUnit: m.useGroupUnit == true ? _clean(m.groupUnit) : null,
        qttyPerGroup: m.useGroupUnit == true ? m.qttyPerGroup : null,
      );

  factory ProductionStockItem.fromProducedItem(ProductionItem p) =>
      ProductionStockItem(
        kind: ProductionStockKind.producedItem,
        uuid: p.uuid ?? '',
        name: p.name,
        unit: p.unit,
        unitsList: p.unitsList,
        costPrice: p.costPrice,
        quantity: p.quantity,
        departmentUuid: _clean(p.departmentUuid),
        departmentName: _clean(p.departmentName),
        categoryUuids: _categories(p.categoryUuid, p.categories),
        expiryDate: p.expiryDate,
        isManaged: p.isManaged,
        createdAt: p.createdAt,
        groupUnit: p.useGroupUnit == true ? _clean(p.groupUnit) : null,
        qttyPerGroup: p.useGroupUnit == true ? p.qttyPerGroup : null,
      );

  /// Base units in one primary unit.
  double get primaryConversion =>
      ProductionReportUnits.primaryConversion(unitsList);

  String get primaryUnit =>
      ProductionReportUnits.primaryUnitName(unitsList, unit: unit);

  /// Stock in the primary unit; null for an unmanaged item.
  double? get primaryQty =>
      isManaged
          ? ProductionReportUnits.stockPrimaryQty(quantity, unitsList)
          : null;

  /// Cost of one primary unit.
  double get primaryCost =>
      ProductionReportUnits.primaryCostPrice(costPrice, unitsList);

  /// Base units in one [unitName], or null when the item has no unit
  /// of that name.
  double? conversionOf(String? unitName) {
    final name = _clean(unitName)?.toLowerCase();
    if (name == null) return null;
    for (final u in unitsList ?? const <ProductUnitsClass>[]) {
      if (u.name.trim().toLowerCase() == name) {
        final c = u.conversion;
        return c.isFinite && c > 0 ? c : null;
      }
    }
    final group = groupUnit?.toLowerCase();
    final perGroup = qttyPerGroup;
    if (group != null && group == name && perGroup != null && perGroup > 0) {
      return perGroup;
    }
    if ((unitsList ?? const []).isEmpty &&
        name == primaryUnit.trim().toLowerCase()) {
      return 1;
    }
    return null;
  }
}

/// One history record of a material or a produced item, read once.
/// [event] comes from `eventOf`, so legacy records are classified too.
class ProductionStockEntry {
  final ProductionStockKind kind;
  final String uuid;
  final int shopId;

  /// Local time; null when the record has no date.
  final DateTime? createdAt;
  final String? itemUuid;
  final String? itemName;
  final String title;
  final String? event;
  final String? oldValue;
  final String? newValue;

  /// In [unit], signed or not depending on the writer.
  final double? quantityChange;
  final String? unit;
  final String? primaryUnit;
  final String? source;
  final String? destination;
  final String? staffId;
  final String? staffName;
  final String? departmentUuid;
  final String? departmentName;
  final String? desc;
  final bool? isIncreased;
  final bool? isManaged;

  const ProductionStockEntry({
    required this.kind,
    required this.uuid,
    required this.shopId,
    required this.createdAt,
    required this.itemUuid,
    required this.itemName,
    required this.title,
    required this.event,
    required this.oldValue,
    required this.newValue,
    required this.quantityChange,
    required this.unit,
    required this.primaryUnit,
    required this.source,
    required this.destination,
    required this.staffId,
    required this.staffName,
    required this.departmentUuid,
    required this.departmentName,
    required this.desc,
    required this.isIncreased,
    required this.isManaged,
  });

  factory ProductionStockEntry.fromMaterialHistory(MaterialsItemHistory h) =>
      ProductionStockEntry(
        kind: ProductionStockKind.material,
        uuid: h.uuid ?? '',
        shopId: h.shopId,
        createdAt: h.createdAt?.toLocal(),
        itemUuid: _clean(h.itemUuid),
        itemName: _clean(h.itemName),
        title: h.title,
        event: MaterialItemHistoryEventClass.eventOf(h),
        oldValue: h.oldValue,
        newValue: h.newValue,
        quantityChange: h.quantityChange,
        unit: _clean(h.unit),
        primaryUnit: _clean(h.primaryUnit),
        source: _clean(h.source),
        destination: _clean(h.destination),
        staffId: _clean(h.staffId),
        staffName: _clean(h.staffName),
        departmentUuid: _clean(h.departmentUuid),
        departmentName: _clean(h.departmentName),
        desc: _clean(h.desc),
        isIncreased: h.isIncreased,
        isManaged: h.isManaged,
      );

  factory ProductionStockEntry.fromProducedHistory(ProductionItemHistory h) =>
      ProductionStockEntry(
        kind: ProductionStockKind.producedItem,
        uuid: h.uuid ?? '',
        shopId: h.shopId,
        createdAt: h.createdAt?.toLocal(),
        itemUuid: _clean(h.itemUuid),
        itemName: _clean(h.itemName),
        title: h.title,
        event: ProductionItemHistoryEventClass.eventOf(h),
        oldValue: h.oldValue,
        newValue: h.newValue,
        quantityChange: h.quantityChange,
        unit: _clean(h.unit),
        primaryUnit: _clean(h.primaryUnit),
        source: _clean(h.source),
        destination: _clean(h.destination),
        staffId: _clean(h.staffId),
        staffName: _clean(h.staffName),
        departmentUuid: _clean(h.departmentUuid),
        departmentName: _clean(h.departmentName),
        desc: _clean(h.desc),
        isIncreased: h.isIncreased,
        isManaged: h.isManaged,
      );

  /// Balance values (primary unit), parsed from "1,250.5".
  static double? parse(String? v) {
    if (v == null) return null;
    return double.tryParse(v.replaceAll(',', '').trim());
  }

  double? get oldPrimary => parse(oldValue);
  double? get newPrimary => parse(newValue);

  ProductionMovementKind get movement => productionMovementKindOf(this);
}

/// How a history record moved stock. Each kind of stock uses its own
/// subset; see [productionMovementKindOf].
enum ProductionMovementKind {
  /// Produced items: a production run added stock.
  produced,

  /// Produced items: a deleted production run took it back.
  productionDeleted,

  /// Materials: used by a production or a manual usage.
  used,

  /// Materials: a deleted usage or production gave it back.
  restored,

  /// Produced items: moved into a sales item.
  transferredToSales,

  /// Moved to another branch.
  transferredToBranch,

  /// Materials: moved to another department.
  transferredToDepartment,
  transferredIn,
  adjustedUp,
  adjustedDown,
  created,
  deleted,
  duplicated,
  other,
}

extension ProductionMovementKindX on ProductionMovementKind {
  String get label {
    switch (this) {
      case ProductionMovementKind.produced:
        return 'Produced';
      case ProductionMovementKind.productionDeleted:
        return 'Production Deleted';
      case ProductionMovementKind.used:
        return 'Used';
      case ProductionMovementKind.restored:
        return 'Restored';
      case ProductionMovementKind.transferredToSales:
        return 'Transferred to Sales';
      case ProductionMovementKind.transferredToBranch:
        return 'Transferred to Branch';
      case ProductionMovementKind.transferredToDepartment:
        return 'Transferred to Department';
      case ProductionMovementKind.transferredIn:
        return 'Transferred In';
      case ProductionMovementKind.adjustedUp:
        return 'Manual Increase';
      case ProductionMovementKind.adjustedDown:
        return 'Manual Decrease';
      case ProductionMovementKind.created:
        return 'Created';
      case ProductionMovementKind.deleted:
        return 'Deleted';
      case ProductionMovementKind.duplicated:
        return 'Duplicated';
      case ProductionMovementKind.other:
        return 'Other';
    }
  }

  bool get isAddition =>
      this == ProductionMovementKind.produced ||
      this == ProductionMovementKind.restored ||
      this == ProductionMovementKind.transferredIn ||
      this == ProductionMovementKind.adjustedUp;

  bool get isReduction =>
      this == ProductionMovementKind.productionDeleted ||
      this == ProductionMovementKind.used ||
      this == ProductionMovementKind.transferredToSales ||
      this == ProductionMovementKind.transferredToBranch ||
      this == ProductionMovementKind.transferredToDepartment ||
      this == ProductionMovementKind.adjustedDown;

  /// Records that move stock. Created, deleted and duplicated records
  /// only count as events.
  bool get isQuantityEvent => isAddition || isReduction;
}

/// The movement of [e], by its stock kind. Legacy records were already
/// classified by `eventOf`. A `transfered_out` with no destination is a
/// branch transfer when its description names a shop (the branch
/// transfer writes "Shop Name:"), else a transfer to sales (produced
/// items) or to a department (materials).
ProductionMovementKind productionMovementKindOf(ProductionStockEntry e) {
  final event = e.event;
  if (event == null) return ProductionMovementKind.other;
  bool toBranch() {
    final d = e.destination;
    if (d != null) {
      return d == ProductionItemHistoryEventClass.branchStoreDestination;
    }
    return (e.desc ?? '').contains('Shop Name:');
  }

  // Shared event names (same strings in both event classes).
  if (event == ProductionItemHistoryEventClass.transferedIn) {
    return ProductionMovementKind.transferredIn;
  }
  if (event == ProductionItemHistoryEventClass.transferedOut) {
    if (toBranch()) return ProductionMovementKind.transferredToBranch;
    return e.kind == ProductionStockKind.producedItem
        ? ProductionMovementKind.transferredToSales
        : ProductionMovementKind.transferredToDepartment;
  }
  if (event == ProductionItemHistoryEventClass.quantityUpdatedIncrease) {
    return ProductionMovementKind.adjustedUp;
  }
  if (event == ProductionItemHistoryEventClass.quantityUpdatedDecrease) {
    return ProductionMovementKind.adjustedDown;
  }
  if (event == ProductionItemHistoryEventClass.itemCreated) {
    return ProductionMovementKind.created;
  }
  if (event == ProductionItemHistoryEventClass.itemDeleted) {
    return ProductionMovementKind.deleted;
  }
  if (event == ProductionItemHistoryEventClass.itemDuplicated) {
    return ProductionMovementKind.duplicated;
  }

  if (e.kind == ProductionStockKind.producedItem) {
    if (event == ProductionItemHistoryEventClass.productionCreated) {
      return ProductionMovementKind.produced;
    }
    if (event == ProductionItemHistoryEventClass.productionDeleted) {
      return ProductionMovementKind.productionDeleted;
    }
    return ProductionMovementKind.other;
  }

  // Materials: a production (legacy) or a usage used it; deleting
  // either gives it back.
  if (event == MaterialItemHistoryEventClass.usageCreated ||
      event == MaterialItemHistoryEventClass.productionCreated) {
    return ProductionMovementKind.used;
  }
  if (event == MaterialItemHistoryEventClass.usageDeleted ||
      event == MaterialItemHistoryEventClass.productionDeleted) {
    return ProductionMovementKind.restored;
  }
  return ProductionMovementKind.other;
}

/// The event column of the history table: the movement label, or the
/// raw event when it isn't known ("—" without one).
String productionStockEventLabel(ProductionStockEntry e) {
  final kind = e.movement;
  if (kind != ProductionMovementKind.other) return kind.label;
  final raw = e.event;
  if (raw == null) return '—';
  return raw
      .split('_')
      .where((w) => w.isNotEmpty)
      .map((w) => '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}

/// "branch_store" → "Branch Store".
String productionStockPlaceLabel(String? value) {
  final v = _clean(value);
  if (v == null || v == 'not_set') return '—';
  return v
      .split('_')
      .where((w) => w.isNotEmpty)
      .map((w) => '${w[0].toUpperCase()}${w.substring(1)}')
      .join(' ');
}

/// Converts the quantity a record moved to the item's primary unit,
/// tolerating the ways records are written (as the Storage summary).
class ProductionStockNormaliser {
  /// 0 for records that move no stock; null when the record can't be
  /// converted.
  ///
  /// 1. |new − old| when the record's primary unit is the item's
  ///    current one (or either is unknown).
  /// 2. Otherwise |quantityChange|, converted from the record's unit
  ///    through the item's units.
  static double? quantity(ProductionStockEntry e, ProductionStockItem? item) {
    if (!e.movement.isQuantityEvent) return 0;
    final oldV = e.oldPrimary;
    final newV = e.newPrimary;
    final recorded = e.primaryUnit?.toLowerCase();
    final current = item?.primaryUnit.trim().toLowerCase();
    if (oldV != null &&
        newV != null &&
        (recorded == null || current == null || recorded == current)) {
      return (newV - oldV).abs();
    }
    final qc = e.quantityChange;
    if (qc == null) return null;
    if (qc == 0) return 0;
    if (item == null) return null;
    final conversion = item.conversionOf(e.unit);
    if (conversion == null) return null;
    final v = qc.abs() * conversion / item.primaryConversion;
    return v.isFinite ? v : null;
  }
}

/// Movement quantities (one item's primary unit) and record counts.
class ProductionMovementTotals {
  final Map<ProductionMovementKind, double> quantities = {};
  final Map<ProductionMovementKind, int> counts = {};
  int notNormalised = 0;

  void add(ProductionMovementKind kind, double? quantity) {
    counts[kind] = (counts[kind] ?? 0) + 1;
    if (!kind.isQuantityEvent) return;
    if (quantity == null) {
      notNormalised++;
    } else {
      quantities[kind] = (quantities[kind] ?? 0) + quantity;
    }
  }

  void addAll(ProductionMovementTotals other) {
    other.counts.forEach((k, v) => counts[k] = (counts[k] ?? 0) + v);
    other.quantities.forEach(
      (k, v) => quantities[k] = (quantities[k] ?? 0) + v,
    );
    notNormalised += other.notNormalised;
  }

  double of(ProductionMovementKind kind) => quantities[kind] ?? 0;
  int countOf(ProductionMovementKind kind) => counts[kind] ?? 0;

  double get additions => quantities.entries
      .where((e) => e.key.isAddition)
      .fold(0.0, (s, e) => s + e.value);

  double get reductions => quantities.entries
      .where((e) => e.key.isReduction)
      .fold(0.0, (s, e) => s + e.value);

  double get net => additions - reductions;

  /// Produced items: produced minus production deleted.
  double get netProduced =>
      of(ProductionMovementKind.produced) -
      of(ProductionMovementKind.productionDeleted);

  int get movementCount => counts.entries
      .where((e) => e.key.isQuantityEvent)
      .fold(0, (s, e) => s + e.value);

  int get eventCount => counts.values.fold(0, (s, c) => s + c);

  bool get hasMovement => movementCount > 0;
}

/// Opening and closing stock of one item over a period, in its primary
/// unit. Null for an unmanaged item.
class ProductionStockBalance {
  final double? opening;
  final double? closing;

  const ProductionStockBalance({required this.opening, required this.closing});

  static const none = ProductionStockBalance(opening: null, closing: null);

  double? get change =>
      opening == null || closing == null ? null : closing! - opening!;
}

/// Period window of [period]: [start, end) in local time, by the shop's
/// closing time. Null bounds for all time.
({DateTime? start, DateTime? end}) productionStockWindow(
  ReceiptsReportPeriod period, {
  TimeOfDay? closingTime,
}) {
  if (period.isAllTime) return (start: null, end: null);
  return (
    start: fourAm(period.start!, isUtc: false, customClosingTime: closingTime),
    end: fourAmNextDay(
      period.end ?? period.start!,
      isUtc: false,
      customClosingTime: closingTime,
    ),
  );
}

/// Period balances and movement buckets of one item, from its history.
/// Same balance rules as the Items report's `StockMovementCalculator`:
/// `oldValue`/`newValue` hold the balance before and after a stock
/// event, in the primary unit; records written in another primary unit
/// are skipped.
class ProductionStockMovementCalculator {
  static bool isBalanceRecord(ProductionStockEntry e, ProductionStockItem item) {
    if (e.createdAt == null) return false;
    final kind = e.movement;
    if (!kind.isQuantityEvent && kind != ProductionMovementKind.created) {
      return false;
    }
    if (e.oldPrimary == null || e.newPrimary == null) return false;
    final pu = e.primaryUnit;
    if (pu != null &&
        pu.toLowerCase() != item.primaryUnit.trim().toLowerCase()) {
      return false;
    }
    return true;
  }

  /// [entries]: this item's records, any period.
  static ProductionStockBalance balance({
    required ProductionStockItem item,
    required List<ProductionStockEntry> entries,
    required ReceiptsReportPeriod period,
    TimeOfDay? closingTime,
  }) {
    if (!item.isManaged) return ProductionStockBalance.none;
    final usable =
        entries.where((e) => isBalanceRecord(e, item)).toList()
          ..sort((a, b) => a.createdAt!.compareTo(b.createdAt!));
    final w = productionStockWindow(period, closingTime: closingTime);
    bool beforeStart(DateTime d) => w.start != null && d.isBefore(w.start!);
    bool afterEnd(DateTime d) => w.end != null && !d.isBefore(w.end!);

    // Opening: the balance just before the period starts.
    double? opening;
    final firstInOrAfter = usable.where((e) => !beforeStart(e.createdAt!));
    if (firstInOrAfter.isNotEmpty) {
      opening = firstInOrAfter.first.oldPrimary;
    } else if (usable.isNotEmpty) {
      opening = usable.last.newPrimary;
    } else {
      final created = item.createdAt;
      opening =
          created != null && w.start != null && !created.isBefore(w.start!)
              ? 0
              : item.primaryQty;
    }

    // Closing: the last balance in the period, else the opening.
    final inRange =
        usable
            .where((e) => !beforeStart(e.createdAt!) && !afterEnd(e.createdAt!))
            .toList();
    final closing = inRange.isNotEmpty ? inRange.last.newPrimary : opening;
    return ProductionStockBalance(opening: opening, closing: closing);
  }

  /// The movement of [entries] that fall in [period].
  static ProductionMovementTotals totals({
    required ProductionStockItem? item,
    required List<ProductionStockEntry> entries,
    required ReceiptsReportPeriod period,
    TimeOfDay? closingTime,
  }) {
    final t = ProductionMovementTotals();
    for (final e in entries) {
      final d = e.createdAt;
      if (d == null || !period.contains(d, closingTime: closingTime)) continue;
      t.add(e.movement, ProductionStockNormaliser.quantity(e, item));
    }
    return t;
  }
}

/// "45 Pcs, 3 Kg": quantities in different units are never added up.
String productionQuantitiesByUnit(
  Map<String, double> byUnit,
  String Function(num v) number,
) {
  final entries =
      byUnit.entries.where((e) => e.value != 0).toList()
        ..sort((a, b) => a.key.toLowerCase().compareTo(b.key.toLowerCase()));
  if (entries.isEmpty) return '0';
  return entries.map((e) => '${number(e.value)} ${e.key}').join(', ');
}

/// History records grouped by item uuid (records with no item left out).
Map<String, List<ProductionStockEntry>> productionEntriesByItem(
  Iterable<ProductionStockEntry> entries,
) {
  final out = <String, List<ProductionStockEntry>>{};
  for (final e in entries) {
    final id = e.itemUuid;
    if (id == null) continue;
    out.putIfAbsent(id, () => []).add(e);
  }
  return out;
}

/// The notes every stock page shows under its toolbar; the export
/// carries the same list.
enum ProductionStockReportPage { items, analysis, history, historySummary }

List<String> productionStockNotes({
  required ProductionStockKind kind,
  required ProductionStockReportPage page,
  required ReceiptsReportPeriod period,
  required bool historyAllowed,
  int notNormalised = 0,
}) {
  final material = kind == ProductionStockKind.material;
  final historyPage =
      page == ProductionStockReportPage.history ||
      page == ProductionStockReportPage.historySummary;
  // The materials analysis reads use from records, not the history.
  final movementPage =
      page == ProductionStockReportPage.items ||
      (page == ProductionStockReportPage.analysis && !material);
  return [
    if (period.isAllTime && (historyAllowed || !movementPage))
      'All time covers the history loaded on this device.',
    if (movementPage && !historyAllowed)
      'Period movement needs access to item history.',
    if (notNormalised > 0)
      '$notNormalised history ${notNormalised == 1 ? 'record' : 'records'} '
          "couldn't be converted to the ${kind.singular.toLowerCase()}'s unit "
          'and ${notNormalised == 1 ? 'is' : 'are'} counted without a quantity.',
    if (page == ProductionStockReportPage.analysis &&
        historyAllowed &&
        kind == ProductionStockKind.producedItem)
      "Transfer-to-sales rate is approximate: transfers aren't linked to "
          'production runs.',
    if (material && historyPage)
      "Material history can't tell production use from manual use. See the "
          'Materials Table or Analysis for that split.',
    if (material && !historyPage)
      'Use in production comes from the production records (older ones '
          'included); manual use from usage records not made by a production.',
    if (material && page == ProductionStockReportPage.analysis)
      'Cost changes come from usage records: older productions carry no '
          'unit cost.',
  ];
}
