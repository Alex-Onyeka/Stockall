import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_item_purchase_record/temp_item_purchase_record.dart';
import 'package:stockall/classes/temp_suppliers/suppliers_class.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/class/purchase_lines.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/class/purchase_report_table_logic.dart';
import 'package:stockall/pages/report/purchase_report/purchase_summary/class/purchase_summary_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_summary/class/receipts_report_summary_logic.dart';
import 'package:stockall/pages/report/supplier_report/supplier_report_table/class/supplier_report_table_logic.dart';

/// Recent purchases shown before "See all".
const int supplierRecentPurchasesCount = 5;

/// Items in "Top items".
const int supplierTopItemsCount = 5;

const String supplierUnknownItemLabel = 'Unknown item';

/// One product or storage item bought from the supplier.
class SupplierTopItem {
  /// [PurchaseLines.productKey], else the item name (lowercase,
  /// prefixed `name:`) for lines not linked to an item.
  final String key;

  /// Name on the newest line.
  String name;

  /// Purchases with this item.
  int purchaseCount = 0;

  /// Quantity in the units bought, by the purchase report's Items
  /// rule (`PurchaseLines.lineItemCount`).
  double items = 0;

  /// Sum of the line totals.
  double spend = 0;
  DateTime? lastBought;

  SupplierTopItem(this.key, this.name);
}

/// Everything the Supplier Analysis page shows for one supplier
/// and period.
class SupplierAnalysisResult {
  /// KPIs: the supplier's table row for the same period
  /// (purchases, spend, paid, balance owed, average, first and
  /// last purchase).
  final SupplierReportRow supplier;

  /// The supplier's purchases in the period, newest first: the
  /// purchase table that "See all" opens.
  final List<PurchaseReportRow> rows;
  final List<PurchaseTrendPoint> trend;

  /// Null without purchases in an all-time period.
  final ReceiptsTrendInterval? interval;

  /// Largest line spend first, at most [supplierTopItemsCount].
  final List<SupplierTopItem> topItems;

  /// Purchases without line data, left out of [topItems].
  final int purchasesWithoutLines;

  /// Purchases with a custom total, whose line totals (in
  /// [topItems]) differ from what was spent.
  final int adjustedPurchases;

  /// Newest name saved on any of the supplier's visible purchases,
  /// whatever the period. Names a deleted supplier in a period
  /// without purchases.
  final String? savedName;

  const SupplierAnalysisResult({
    required this.supplier,
    required this.rows,
    required this.trend,
    required this.interval,
    required this.topItems,
    required this.purchasesWithoutLines,
    required this.adjustedPurchases,
    this.savedName,
  });

  /// Page title: the current name, else the newest saved one.
  String get title => supplier.name ?? savedName ?? 'Not Set';

  List<PurchaseReportRow> get recent =>
      rows.take(supplierRecentPurchasesCount).toList();

  bool get hasMore => rows.length > supplierRecentPurchasesCount;

  /// Filters of the purchase table "See all" opens.
  PurchaseReportFilters get tableFilters =>
      PurchaseReportFilters(supplierKey: supplier.key);
}

class SupplierAnalysisBuilder {
  /// The analysis of supplier [supplierKey]. [purchaseRows] are
  /// the visible purchases (scope applied); [suppliers] the
  /// user's supplier scope and [allSuppliers] every loaded
  /// supplier, as for the table.
  static SupplierAnalysisResult build({
    required String supplierKey,
    required List<PurchaseReportRow> purchaseRows,
    required List<SuppliersClass> suppliers,
    List<SuppliersClass> allSuppliers = const [],
    List<TempItemPurchaseRecord> legacyLines = const [],
    required ReceiptsReportPeriod period,
    required bool departmentsEnabled,
    TimeOfDay? closingTime,
    DateTime? now,
  }) {
    final rows = SupplierReportRowBuilder.purchasesInPeriod(
      purchaseRows: purchaseRows,
      period: period,
      departmentsEnabled: departmentsEnabled,
      filters: PurchaseReportFilters(supplierKey: supplierKey),
      closingTime: closingTime,
    );

    SuppliersClass? find(List<SuppliersClass> list) {
      for (final s in list) {
        if (PurchaseReportRow.keyOf(s.uuid) == supplierKey) {
          return s;
        }
      }
      return null;
    }

    final inScope = find(suppliers);
    final supplier = SupplierReportRowBuilder.single(
      key: supplierKey,
      supplier: inScope ?? find(allSuppliers),
      inScope: inScope != null,
      supplierRows: rows,
    );

    final range = PurchaseTrendBuilder.span(
      rows: rows,
      period: period,
      now: now ?? DateTime.now(),
      closingTime: closingTime,
    );
    final items = topItems(
      rows,
      legacyLines: PurchaseLines.legacyLinesByPurchase(
        legacyLines,
      ),
    );

    return SupplierAnalysisResult(
      supplier: supplier,
      rows: rows,
      trend: PurchaseTrendBuilder.build(
        rows: rows,
        period: period,
        now: now,
        closingTime: closingTime,
      ),
      interval:
          range == null
              ? null
              : ReceiptsTrendBuilder.intervalFor(
                range.start,
                range.end,
              ),
      topItems: items.items,
      purchasesWithoutLines: items.withoutLines,
      adjustedPurchases:
          rows.where((r) => r.hasAdjustment).length,
      savedName: _savedName(purchaseRows, supplierKey),
    );
  }

  static String? _savedName(
    List<PurchaseReportRow> rows,
    String key,
  ) {
    DateTime? newest;
    String? name;
    for (final r in rows) {
      if (r.supplierKey != key || r.supplierName == null) continue;
      if (newest == null || r.createdAt.isAfter(newest)) {
        newest = r.createdAt;
        name = r.supplierName;
      }
    }
    return name;
  }

  /// Items of [rows] by line spend, largest first; ties: items,
  /// then name, then key. [limit] null returns all.
  static ({List<SupplierTopItem> items, int withoutLines})
  topItems(
    List<PurchaseReportRow> rows, {
    Map<String, List<TempItemPurchaseRecord>> legacyLines =
        const {},
    int? limit = supplierTopItemsCount,
  }) {
    final newestFirst = List<PurchaseReportRow>.from(rows)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final byKey = <String, SupplierTopItem>{};
    var withoutLines = 0;

    for (final r in newestFirst) {
      final (:lines, :source) = PurchaseLines.linesFor(
        r.purchase,
        legacyLines,
      );
      if (lines == null) {
        withoutLines++;
        continue;
      }
      final counted = <String>{};
      for (final line in lines) {
        final name = SupplierReportRow.clean(line.itemName);
        final key =
            PurchaseLines.productKey(line) ??
            'name:${(name ?? supplierUnknownItemLabel).toLowerCase()}';
        final item = byKey.putIfAbsent(
          key,
          () => SupplierTopItem(
            key,
            name ?? supplierUnknownItemLabel,
          ),
        );
        // Newest first, so only fill a name the newer ones lacked.
        if (item.name == supplierUnknownItemLabel &&
            name != null) {
          item.name = name;
        }
        if (counted.add(key)) item.purchaseCount++;
        item.items += PurchaseLines.lineItemCount(line);
        item.spend += PurchaseLines.lineTotal(line);
        item.lastBought ??= r.createdAt;
      }
    }

    final sorted =
        byKey.values.toList()..sort((a, b) {
          var c = b.spend.compareTo(a.spend);
          if (c != 0) return c;
          c = b.items.compareTo(a.items);
          if (c != 0) return c;
          c = a.name.toLowerCase().compareTo(
            b.name.toLowerCase(),
          );
          return c != 0 ? c : a.key.compareTo(b.key);
        });
    return (
      items:
          limit == null ? sorted : sorted.take(limit).toList(),
      withoutLines: withoutLines,
    );
  }
}
