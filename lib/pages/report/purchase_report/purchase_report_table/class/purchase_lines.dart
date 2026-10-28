import 'package:stockall/classes/temp_item_purchase_record/temp_item_purchase_record.dart';
import 'package:stockall/classes/temp_product_class/units_class/product_units_class.dart';
import 'package:stockall/classes/temp_purchase/temp_purchase.dart';

// Per-line rules for purchase reports. Shared by the Purchase
// Report and, later, the Item Purchase Report. Never calls
// `getItems()` / `getUnitsList()`: those read the providers and
// create placeholder units.

/// Where a purchase's lines came from.
enum PurchaseLineSource {
  /// `purchase.items`.
  embedded,

  /// item_purchase_records rows matched by purchase uuid
  /// (purchases saved before `items` existed).
  legacy,

  /// No line data: line-based values are unknown, not zero.
  none,
}

class PurchaseLines {
  /// item_purchase_records lines grouped by purchase uuid, built
  /// once instead of scanning every line per purchase.
  static Map<String, List<TempItemPurchaseRecord>>
  legacyLinesByPurchase(
    List<TempItemPurchaseRecord> records,
  ) {
    final map = <String, List<TempItemPurchaseRecord>>{};
    for (final line in records) {
      final uuid = line.purchaseId;
      if (uuid == null || uuid.isEmpty) continue;
      (map[uuid] ??= []).add(line);
    }
    return map;
  }

  /// The purchase's lines: `items`, else its legacy rows. Null
  /// lines when there are neither.
  static ({
    List<TempItemPurchaseRecord>? lines,
    PurchaseLineSource source,
  })
  linesFor(
    TempPurchase purchase,
    Map<String, List<TempItemPurchaseRecord>> legacyLines,
  ) {
    final embedded = purchase.items;
    if (embedded != null && embedded.isNotEmpty) {
      return (
        lines: embedded,
        source: PurchaseLineSource.embedded,
      );
    }
    final legacy = legacyLines[purchase.uuid];
    if (legacy != null && legacy.isNotEmpty) {
      return (
        lines: legacy,
        source: PurchaseLineSource.legacy,
      );
    }
    return (lines: null, source: PurchaseLineSource.none);
  }

  /// Unit the line was bought in, as the receipts report finds a
  /// sale unit: by `unitUuid`, else the primary unit. Null without
  /// a units list.
  static ProductUnitsClass? lineUnit(
    TempItemPurchaseRecord line,
  ) {
    final units = line.unitsList;
    if (units == null || units.isEmpty) return null;
    for (final unit in units) {
      if (unit.uuid == line.unitUuid) return unit;
    }
    for (final unit in units) {
      if (unit.isPrimary) return unit;
    }
    return null;
  }

  /// Quantity in the unit bought, not converted to primary units
  /// (the receipts report's Items rule). A 2D line bought in an
  /// area unit is one item: its quantity is an area, not pieces.
  static double lineItemCount(TempItemPurchaseRecord line) {
    if (lineUnit(line)?.dimensionType ==
        ProductUnitsClass.areaUnit) {
      return 1;
    }
    return line.quantity ?? 0;
  }

  static double lineTotal(TempItemPurchaseRecord line) =>
      line.total ?? 0;

  /// Product or storage item the line restocked.
  static String? productKey(TempItemPurchaseRecord line) {
    final id = line.itemId ?? line.storageItemId;
    return (id == null || id.trim().isEmpty) ? null : id;
  }
}
