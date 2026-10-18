import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_product_class/units_class/product_units_class.dart';
import 'package:stockall/classes/temp_product_slaes_record/temp_product_sale_record.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/pages/report/receipts_report_main/class/receipts_report_main_logic.dart';

/// Page size, same as the Receipts Report.
const int itemSalesReportPageSize = receiptsReportPageSize;

/// Category filter key for lines whose item is no longer in the
/// shop (or has no product id), so their category is unknown.
const String itemSalesDeletedItemKey = '__deleted_item__';

const String itemSalesNoCategoryLabel = 'No Category';
const String itemSalesDeletedItemLabel =
    'Unknown (deleted item)';

/// Which void state the table shows. Void lines were removed
/// from the cart, so they are hidden unless asked for.
enum ItemSalesVoidFilter { notVoid, voidOnly, all }

extension ItemSalesVoidFilterLabel on ItemSalesVoidFilter {
  String get label {
    switch (this) {
      case ItemSalesVoidFilter.notVoid:
        return 'Not void';
      case ItemSalesVoidFilter.voidOnly:
        return 'Void';
      case ItemSalesVoidFilter.all:
        return 'All';
    }
  }
}

enum ItemSalesSortField {
  item,
  category,
  receiptId,
  staff,
  customer,
  createdAt,
  quantity,
  sellingPrice,
  cost,
  revenue,
  profit,
  margin,
}

/// Table columns in display order. Kept here so an export can
/// use the same order, labels and visibility.
enum ItemSalesColumn {
  recordId,
  item,
  category,
  receiptId,
  staff,
  subStaff,
  customer,
  date,
  time,
  quantity,
  unit,
  sellingPrice,
  discount,
  grossValue,
  costPrice,
  department,
  customPrice,
  wholesale,
  managed,
  type,
  voidStatus,
  wastage,
  revenue,
  profit,
  margin,
}

extension ItemSalesColumnInfo on ItemSalesColumn {
  String get label {
    switch (this) {
      case ItemSalesColumn.recordId:
        return 'Record ID';
      case ItemSalesColumn.item:
        return 'Item';
      case ItemSalesColumn.category:
        return 'Category';
      case ItemSalesColumn.receiptId:
        return 'Receipt ID';
      case ItemSalesColumn.staff:
        return 'Staff';
      case ItemSalesColumn.subStaff:
        return 'Sub-Staff';
      case ItemSalesColumn.customer:
        return 'Customer';
      case ItemSalesColumn.date:
        return 'Date';
      case ItemSalesColumn.time:
        return 'Time';
      case ItemSalesColumn.quantity:
        return 'Quantity';
      case ItemSalesColumn.unit:
        return 'Unit';
      case ItemSalesColumn.sellingPrice:
        return 'Selling Price';
      case ItemSalesColumn.discount:
        return 'Discount';
      case ItemSalesColumn.grossValue:
        return 'Gross Value';
      case ItemSalesColumn.costPrice:
        return 'Cost Price';
      case ItemSalesColumn.department:
        return 'Department';
      case ItemSalesColumn.customPrice:
        return 'Custom Price';
      case ItemSalesColumn.wholesale:
        return 'Wholesale Price';
      case ItemSalesColumn.managed:
        return 'Managed';
      case ItemSalesColumn.type:
        return 'Type';
      case ItemSalesColumn.voidStatus:
        return 'Void';
      case ItemSalesColumn.wastage:
        return 'Wastage';
      case ItemSalesColumn.revenue:
        return 'Revenue';
      case ItemSalesColumn.profit:
        return 'Profit/Loss';
      case ItemSalesColumn.margin:
        return 'Margin (%)';
    }
  }

  ItemSalesSortField? get sort {
    switch (this) {
      case ItemSalesColumn.item:
        return ItemSalesSortField.item;
      case ItemSalesColumn.category:
        return ItemSalesSortField.category;
      case ItemSalesColumn.receiptId:
        return ItemSalesSortField.receiptId;
      case ItemSalesColumn.staff:
        return ItemSalesSortField.staff;
      case ItemSalesColumn.customer:
        return ItemSalesSortField.customer;
      case ItemSalesColumn.date:
      case ItemSalesColumn.time:
        return ItemSalesSortField.createdAt;
      case ItemSalesColumn.quantity:
        return ItemSalesSortField.quantity;
      case ItemSalesColumn.sellingPrice:
        return ItemSalesSortField.sellingPrice;
      case ItemSalesColumn.costPrice:
        return ItemSalesSortField.cost;
      case ItemSalesColumn.revenue:
        return ItemSalesSortField.revenue;
      case ItemSalesColumn.profit:
        return ItemSalesSortField.profit;
      case ItemSalesColumn.margin:
        return ItemSalesSortField.margin;
      default:
        return null;
    }
  }

  /// Cost data, hidden without the Manage Cost Price permission.
  bool get needsCost =>
      this == ItemSalesColumn.costPrice ||
      this == ItemSalesColumn.profit ||
      this == ItemSalesColumn.margin;

  static List<ItemSalesColumn> visible({
    required bool departmentsEnabled,
    required bool subStaffEnabled,
    required bool costVisible,
  }) {
    return ItemSalesColumn.values.where((c) {
      if (c == ItemSalesColumn.subStaff) return subStaffEnabled;
      if (c == ItemSalesColumn.department) {
        return departmentsEnabled;
      }
      if (c.needsCost) return costVisible;
      return true;
    }).toList();
  }
}

/// Category rule of the Items Report
/// (`ItemsReportRowBuilder.build` in items_report_main_logic.dart):
/// `categories` plus the older single `categoryUuid`, keeping only
/// categories that still exist, in that order.
class ItemSalesCategories {
  static ({List<String> uuids, List<String> names}) known({
    required TempProductClass product,
    required Map<String, String> nameByUuid,
  }) {
    final ids = <String>{
      ...?product.categories,
      if (product.categoryUuid != null) product.categoryUuid!,
    }..removeWhere((e) => e.isEmpty);
    final uuids = <String>[];
    final names = <String>[];
    for (final id in ids) {
      final n = nameByUuid[id];
      if (n != null) {
        uuids.add(id);
        names.add(n);
      }
    }
    return (uuids: uuids, names: names);
  }
}

/// One table row: one sale line. Every value is calculated once,
/// when the row is built. `null` means unknown or not applicable
/// (shown as "—"). Values are raw (no currency formatting) so an
/// export can reuse them.
class ItemSalesRow {
  final TempProductSaleRecord line;

  /// The receipt the line belongs to, as the Receipts Report
  /// builds it: type, ID, staff, customer, department.
  final ReceiptsReportRow parent;

  /// Position in the receipt, for a stable order.
  final int lineIndex;

  /// Persisted id: product_sales' record id on old lines, else the
  /// line uuid. Null when the line has neither.
  final String? recordId;

  /// `productUuid`, null when missing.
  final String? productKey;
  final String? itemName;

  /// The product is still in the shop's item list.
  final bool productExists;

  /// Current categories of the item (sale lines store none).
  final List<String> categoryUuids;
  final List<String> categoryNames;

  /// Sale quantity, in the sale unit, without wastage.
  final double quantity;
  final String? unitName;

  /// Quantity in the item's base unit (area for 2D). Null when the
  /// unit can no longer be resolved.
  final double? baseQuantity;

  /// Price per sale unit, before discount.
  final double? sellingPrice;

  /// Line discount amount and, when it was a percentage, the rate.
  final double? discount;
  final double? discountPercent;

  /// Selling value before the line discount (`originalCost`).
  final double? grossValue;

  /// Line cost. Null when missing or 0.
  final double? cost;

  final bool customPrice;

  /// The custom price was a line total.
  final bool customTotal;
  final bool? wholesale;
  final bool? managed;
  final bool isVoid;

  /// Wastage in the sale unit: 0 without wastage, null when it
  /// cannot be worked out.
  final double? wastage;

  /// Wastage as entered, e.g. "10%" or "0.3 m²".
  final String? wastageSetting;

  /// Line revenue (VAT included, cart discount not).
  final double revenue;

  /// revenue - cost, missing cost counted as 0.
  final double profit;

  /// The cost was missing, so it counted as 0.
  final bool costMissing;

  /// profit / revenue * 100. Null when revenue is not above 0.
  final double? margin;

  ItemSalesRow({
    required this.line,
    required this.parent,
    required this.lineIndex,
    required this.recordId,
    required this.productKey,
    required this.itemName,
    required this.productExists,
    required this.categoryUuids,
    required this.categoryNames,
    required this.quantity,
    required this.unitName,
    required this.baseQuantity,
    required this.sellingPrice,
    required this.discount,
    required this.discountPercent,
    required this.grossValue,
    required this.cost,
    required this.customPrice,
    required this.customTotal,
    required this.wholesale,
    required this.managed,
    required this.isVoid,
    required this.wastage,
    required this.wastageSetting,
    required this.revenue,
    required this.profit,
    required this.costMissing,
    required this.margin,
  });

  ReceiptType get type => parent.type;
  DateTime get createdAt => parent.createdAt;
  String get receiptId => parent.displayId;
  String get receiptUuid => parent.uuid;

  /// Each part payment repeats the invoice's full quantities with
  /// prorated amounts.
  bool get isPartPayment =>
      type == ReceiptType.invoicePayment;

  /// Short form of [recordId] for the table.
  String? get recordLabel {
    final id = recordId;
    if (id == null) return null;
    return id.length > 8 ? '${id.substring(0, 8)}…' : id;
  }

  String get itemLabel => itemName ?? 'Not Set';

  /// The category names, "No Category", or "Unknown (deleted
  /// item)" when the item is no longer in the shop.
  String get categoryLabel {
    if (!productExists) return itemSalesDeletedItemLabel;
    if (categoryNames.isEmpty) return itemSalesNoCategoryLabel;
    return categoryNames.join(', ');
  }
}

/// Builds [ItemSalesRow]s. No receipt or line is modified.
class ItemSalesRowBuilder {
  static String? _text(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static ProductUnitsClass? _unit(
    TempProductSaleRecord line,
    String? uuid,
  ) {
    if (uuid == null) return null;
    for (final unit in line.unitsList ?? <ProductUnitsClass>[]) {
      if (unit.uuid == uuid) return unit;
    }
    return null;
  }

  /// The line's own unit methods can run without making
  /// placeholder units (which need the signed-in user): the sale
  /// unit is in the list, and no group unit has to be added.
  static bool unitsResolvable(TempProductSaleRecord line) {
    final units = line.unitsList;
    if (units == null || units.isEmpty) return false;
    if (_unit(line, line.unitUuid) == null) return false;
    if (line.useGroupQuantity == true &&
        units.every((u) => u.isPrimary)) {
      return false;
    }
    return true;
  }

  /// Name of the sale unit as stored on the line, plus the cut
  /// size for 2D pieces (as `getUnit()` shows it). Falls back to
  /// the recorded `unit` text.
  static String? unitName(TempProductSaleRecord line) {
    final unit = _unit(line, line.unitUuid);
    if (unit != null) {
      final name = unit.name == 'Others' ? 'Unit(s)' : unit.name;
      final sized =
          line.quantityType == 2 &&
          unit.dimensionType != ProductUnitsClass.areaUnit;
      return sized
          ? '$name${formatDimensionsLabel(line.widthDimension, line.heightDimension)}'
          : name;
    }
    final stored = _text(line.unit);
    if (stored == null) return null;
    return stored == 'Others' ? 'Unit(s)' : stored;
  }

  /// `getActualQuantity()` when it is safe to call. Lines without
  /// a unit list use the same rule as `getSelectedUnit`: groups of
  /// `qttyPerGroup` for group sales, else the base unit.
  static double? baseQuantity(TempProductSaleRecord line) {
    if (unitsResolvable(line)) {
      try {
        final q = line.getActualQuantity();
        return q.isFinite ? q : null;
      } catch (_) {
        return null;
      }
    }
    final units = line.unitsList;
    if (units != null && units.isNotEmpty) return null;
    if (line.quantityType == 2) return null;
    final conversion =
        line.useGroupQuantity == true
            ? (line.qttyPerGroup ?? 1)
            : 1.0;
    if (conversion <= 0) return null;
    return line.quantity * conversion;
  }

  /// `wastageInSaleUnit()`: 0 when the line has no wastage, null
  /// when it has some but its units cannot be resolved. Wastage is
  /// already inside the line's amounts, so it is only shown.
  static double? wastage(TempProductSaleRecord line) {
    if (line.quantityType != 2 ||
        line.manageSalesWastage != true) {
      return 0;
    }
    final amount = line.wastageAmount;
    if (amount == null || !amount.isFinite || amount <= 0) {
      return 0;
    }
    if (!unitsResolvable(line)) return null;
    try {
      final w = line.wastageInSaleUnit();
      if (!w.isFinite) return null;
      return w <= 1e-9 ? 0 : w;
    } catch (_) {
      return null;
    }
  }

  /// Wastage as it was entered. A fixed amount without a stored
  /// unit is in the base (area) unit, as `wastageAreaPerUnit` reads
  /// it.
  static String? wastageSetting(TempProductSaleRecord line) {
    if (line.quantityType != 2 ||
        line.manageSalesWastage != true) {
      return null;
    }
    final amount = line.wastageAmount;
    if (amount == null || !amount.isFinite || amount <= 0) {
      return null;
    }
    if (line.isPercentageWastage == true) {
      return '${formatDimension(amount)}%';
    }
    ProductUnitsClass? unit = _unit(line, line.wastageUnitUuid);
    if (unit == null) {
      for (final u in line.unitsList ?? <ProductUnitsClass>[]) {
        if (u.isPrimary) {
          unit = u;
          break;
        }
      }
    }
    return unit == null
        ? formatDimension(amount)
        : '${formatDimension(amount)} ${unit.name}';
  }

  /// Gross value per sale unit, as the receipt's "per 1" price:
  /// `originalCost / priceQuantity()`. Custom totals divide by the
  /// sale quantity, other lines by the quantity with wastage.
  /// Null on part payments (prorated amounts, full quantities).
  static double? sellingPrice(
    TempProductSaleRecord line, {
    required bool partPayment,
    required double? wastage,
  }) {
    if (partPayment) return null;
    final gross = line.originalCost;
    if (gross == null || wastage == null) return null;
    final customTotal =
        line.customPriceSet && line.setTotalPrice == true;
    final qty =
        customTotal ? line.quantity : line.quantity + wastage;
    if (!(qty > 0)) return null;
    final price = gross / qty;
    return price.isFinite ? price : null;
  }

  /// The rate, when the discount amount is that percentage of the
  /// gross value. `discount` keeps the item's own rate even when a
  /// fixed discount was applied, so the amount decides.
  static double? discountPercent(TempProductSaleRecord line) {
    final rate = line.discount;
    final amount = line.discountedAmount;
    final gross = line.originalCost;
    if (rate == null || rate <= 0) return null;
    if (amount == null || gross == null) return null;
    final expected = gross * rate / 100;
    return (amount - expected).abs() < 0.01 ? rate : null;
  }

  static String? recordId(
    TempProductSaleRecord line,
    ReceiptLineSource source,
  ) {
    if (source == ReceiptLineSource.legacy &&
        line.productRecordId != null) {
      return '${line.productRecordId}';
    }
    return _text(line.uuid) ??
        line.productRecordId?.toString();
  }

  static ItemSalesRow build({
    required TempProductSaleRecord line,
    required ReceiptsReportRow parent,
    required int lineIndex,
    required Map<String, TempProductClass> productsByUuid,
    required Map<String, String> categoryNameByUuid,
  }) {
    final productKey = _text(line.productUuid);
    final product =
        productKey == null ? null : productsByUuid[productKey];
    final categories =
        product == null
            ? (uuids: const <String>[], names: const <String>[])
            : ItemSalesCategories.known(
              product: product,
              nameByUuid: categoryNameByUuid,
            );

    final partPayment =
        parent.type == ReceiptType.invoicePayment;
    final wastageValue = wastage(line);
    final cost =
        (line.costPrice ?? 0) > 0 ? line.costPrice : null;
    // As the Receipts Report: revenue - cost, missing cost as 0.
    final profit = line.revenue - (line.costPrice ?? 0);
    final margin =
        line.revenue > 0
            ? (profit / line.revenue) * 100
            : null;

    return ItemSalesRow(
      line: line,
      parent: parent,
      lineIndex: lineIndex,
      recordId: recordId(line, parent.lineSource),
      productKey: productKey,
      itemName: _text(line.productName),
      productExists: product != null,
      categoryUuids: categories.uuids,
      categoryNames: categories.names,
      quantity: line.quantity,
      unitName: unitName(line),
      baseQuantity: baseQuantity(line),
      sellingPrice: sellingPrice(
        line,
        partPayment: partPayment,
        wastage: wastageValue,
      ),
      discount: line.discountedAmount,
      discountPercent: discountPercent(line),
      grossValue: line.originalCost,
      cost: cost,
      customPrice: line.customPriceSet,
      customTotal:
          line.customPriceSet && line.setTotalPrice == true,
      wholesale: line.useWholeSalePrice,
      managed: line.isProductManaged,
      isVoid: line.isVoid == true,
      wastage: wastageValue,
      wastageSetting: wastageSetting(line),
      revenue: line.revenue,
      profit: profit,
      costMissing: cost == null,
      margin: margin,
    );
  }

  /// One row per line of each receipt, void lines included.
  /// [receipts] should already be scoped with
  /// [ReceiptsReportAccess.scope].
  static List<ItemSalesRow> buildAll({
    required List<TempMainReceipt> receipts,
    required List<TempProductSaleRecord> legacySales,
    required Map<String, TempProductClass> productsByUuid,
    required Map<String, String> categoryNameByUuid,
  }) {
    final legacy =
        ReceiptsReportRowBuilder.legacyLinesByReceipt(
          legacySales,
        );
    final rows = <ItemSalesRow>[];
    for (final receipt in receipts) {
      ReceiptsReportRow parent;
      List<TempProductSaleRecord>? lines;
      try {
        parent = ReceiptsReportRowBuilder.build(
          receipt: receipt,
          legacyLines: legacy,
        );
        lines =
            ReceiptsReportRowBuilder.linesFor(
              receipt,
              legacy,
            ).lines;
      } catch (_) {
        // A single malformed receipt must never break the report.
        continue;
      }
      if (lines == null) continue;
      for (var i = 0; i < lines.length; i++) {
        try {
          rows.add(
            build(
              line: lines[i],
              parent: parent,
              lineIndex: i,
              productsByUuid: productsByUuid,
              categoryNameByUuid: categoryNameByUuid,
            ),
          );
        } catch (_) {
          // Nor a single malformed line.
        }
      }
    }
    return rows;
  }
}

/// All user-selectable filters, combined with AND. The receipt
/// filters (staff, customer, sub-staff, department, channel, type)
/// and the revenue / profit ranges are kept in [receipt], so the
/// Receipts Report's fields and chips can edit them; here the
/// ranges apply to the line's revenue and profit.
class ItemSalesFilters {
  final ReceiptsReportFilters receipt;

  /// Category uuid, [receiptsReportNoneKey] for no category, or
  /// [itemSalesDeletedItemKey] for deleted items.
  String? categoryKey;

  /// Product uuid, or [receiptsReportNoneKey] for lines without
  /// one.
  String? productKey;
  ItemSalesVoidFilter voidFilter;
  bool? customPrice;
  bool? wholesale;
  double? quantityMin;
  double? quantityMax;

  ItemSalesFilters({
    ReceiptsReportFilters? receipt,
    this.categoryKey,
    this.productKey,
    this.voidFilter = ItemSalesVoidFilter.notVoid,
    this.customPrice,
    this.wholesale,
    this.quantityMin,
    this.quantityMax,
  }) : receipt = receipt ?? ReceiptsReportFilters();

  ItemSalesFilters copy() => ItemSalesFilters(
    receipt: receipt.copy(),
    categoryKey: categoryKey,
    productKey: productKey,
    voidFilter: voidFilter,
    customPrice: customPrice,
    wholesale: wholesale,
    quantityMin: quantityMin,
    quantityMax: quantityMax,
  );

  String get search => receipt.search;
  set search(String value) => receipt.search = value;

  String? get quantityRangeError =>
      ReceiptsReportFilters.rangeError(
        quantityMin,
        quantityMax,
      );

  bool get quantitySet =>
      quantityMin != null || quantityMax != null;

  /// Quantities of different items are in different units, so
  /// the range needs one item.
  bool get quantityNeedsItem =>
      quantitySet &&
      (productKey == null ||
          productKey == receiptsReportNoneKey);

  /// Set, valid and with one item selected.
  bool get quantityRangeActive =>
      quantitySet &&
      quantityRangeError == null &&
      !quantityNeedsItem;

  int get activeCount =>
      receipt.activeCount +
      (categoryKey != null ? 1 : 0) +
      (productKey != null ? 1 : 0) +
      (voidFilter != ItemSalesVoidFilter.notVoid ? 1 : 0) +
      (customPrice != null ? 1 : 0) +
      (wholesale != null ? 1 : 0) +
      (quantitySet ? 1 : 0);

  bool get hasAnything =>
      activeCount > 0 || search.trim().isNotEmpty;

  void clearAll() {
    receipt.clearAll();
    _clearOwn();
  }

  void clearFiltersOnly() {
    receipt.clearFiltersOnly();
    _clearOwn();
  }

  void _clearOwn() {
    categoryKey = null;
    productKey = null;
    voidFilter = ItemSalesVoidFilter.notVoid;
    customPrice = null;
    wholesale = null;
    quantityMin = null;
    quantityMax = null;
  }

  /// Sets the category and clears an item that has no line in it,
  /// so the two never contradict each other.
  void setCategory(String? key, List<ItemSalesRow> rows) {
    categoryKey = key;
    final selected = productKey;
    if (key == null || selected == null) return;
    final fits = rows.any(
      (r) =>
          ReceiptsReportFilters.keyMatches(
            selected,
            r.productKey,
          ) &&
          matchesCategory(r),
    );
    if (!fits) productKey = null;
  }

  bool matchesCategory(ItemSalesRow r) {
    final key = categoryKey;
    if (key == null) return true;
    if (key == itemSalesDeletedItemKey) return !r.productExists;
    if (key == receiptsReportNoneKey) {
      return r.productExists && r.categoryUuids.isEmpty;
    }
    return r.categoryUuids.contains(key);
  }

  bool matchesVoid(ItemSalesRow r) {
    switch (voidFilter) {
      case ItemSalesVoidFilter.notVoid:
        return !r.isVoid;
      case ItemSalesVoidFilter.voidOnly:
        return r.isVoid;
      case ItemSalesVoidFilter.all:
        return true;
    }
  }

  bool matchesSearch(
    ItemSalesRow r, {
    required bool departmentsEnabled,
  }) {
    final q = search.trim().toLowerCase();
    if (q.isEmpty) return true;
    bool has(String? s) =>
        s != null && s.toLowerCase().contains(q);
    return has(r.itemName) ||
        has(r.productKey) ||
        has(r.receiptId) ||
        has(r.recordId) ||
        has(r.parent.staffName) ||
        has(r.parent.customerName) ||
        r.categoryNames.any(has) ||
        (departmentsEnabled && has(r.parent.departmentName));
  }

  /// [subStaffEnabled] / [departmentsEnabled] / [profitVisible]
  /// switch off the filters that are hidden in the UI. With
  /// [ignoreProfit] / [ignoreQuantity] that range is skipped.
  bool matches(
    ItemSalesRow r, {
    required bool departmentsEnabled,
    required bool subStaffEnabled,
    required bool profitVisible,
    bool ignoreProfit = false,
    bool ignoreQuantity = false,
  }) {
    if (!matchesVoid(r)) return false;
    if (!matchesSearch(
      r,
      departmentsEnabled: departmentsEnabled,
    )) {
      return false;
    }
    final p = r.parent;
    if (!ReceiptsReportFilters.keyMatches(
      receipt.staffKey,
      p.staffKey,
    )) {
      return false;
    }
    if (!ReceiptsReportFilters.keyMatches(
      receipt.customerKey,
      p.customerKey,
    )) {
      return false;
    }
    if (subStaffEnabled &&
        !ReceiptsReportFilters.keyMatches(
          receipt.subStaffKey,
          p.subStaffKey,
        )) {
      return false;
    }
    if (departmentsEnabled &&
        !ReceiptsReportFilters.keyMatches(
          receipt.departmentKey,
          p.departmentKey,
        )) {
      return false;
    }
    if (receipt.channel != null &&
        p.channel != receipt.channel) {
      return false;
    }
    if (receipt.type != null && p.type != receipt.type) {
      return false;
    }
    if (!matchesCategory(r)) return false;
    if (!ReceiptsReportFilters.keyMatches(
      productKey,
      r.productKey,
    )) {
      return false;
    }
    if (customPrice != null &&
        r.customPrice != customPrice) {
      return false;
    }
    // Unknown (null) matches neither Yes nor No.
    if (wholesale != null && r.wholesale != wholesale) {
      return false;
    }

    if (!ignoreProfit &&
        profitVisible &&
        receipt.profitRangeActive) {
      // Incomplete profit is never treated as known.
      if (r.costMissing) return false;
      if (!ReceiptsReportFilters.inRange(
        r.profit,
        receipt.profitMin,
        receipt.profitMax,
      )) {
        return false;
      }
    }

    if (receipt.revenueRangeActive &&
        !ReceiptsReportFilters.inRange(
          r.revenue,
          receipt.revenueMin,
          receipt.revenueMax,
        )) {
      return false;
    }

    if (!ignoreQuantity && quantityRangeActive) {
      // Part payments repeat the invoice quantities.
      final q = r.baseQuantity;
      if (q == null || r.isPartPayment) return false;
      if (!ReceiptsReportFilters.inRange(
        q,
        quantityMin,
        quantityMax,
      )) {
        return false;
      }
    }
    return true;
  }
}

/// Item and category choices.
class ItemSalesOptions {
  /// Items sold in [rows], or in [categoryKey] when set, keyed by
  /// product uuid with the most recent name. Items sharing a name
  /// get the start of their uuid so they can be told apart.
  static List<ReceiptsFilterOption> items(
    List<ItemSalesRow> rows, {
    ItemSalesFilters? categoryOf,
  }) {
    final newestFirst =
        rows
            .where(
              (r) => categoryOf?.matchesCategory(r) ?? true,
            )
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final labels = <String, String>{};
    var hasNone = false;
    for (final r in newestFirst) {
      final k = r.productKey;
      if (k == null) {
        hasNone = true;
        continue;
      }
      labels.putIfAbsent(k, () => r.itemLabel);
    }
    final nameCount = <String, int>{};
    for (final label in labels.values) {
      final n = label.toLowerCase();
      nameCount[n] = (nameCount[n] ?? 0) + 1;
    }
    final options =
        labels.entries.map((e) {
            final shared =
                (nameCount[e.value.toLowerCase()] ?? 0) > 1;
            final short =
                e.key.length > 8
                    ? e.key.substring(0, 8)
                    : e.key;
            return ReceiptsFilterOption(
              e.key,
              shared ? '${e.value} ($short)' : e.value,
            );
          }).toList()
          ..sort((a, b) {
            final c = a.label.toLowerCase().compareTo(
              b.label.toLowerCase(),
            );
            return c != 0 ? c : a.key.compareTo(b.key);
          });
    if (hasNone) {
      options.add(
        const ReceiptsFilterOption(
          receiptsReportNoneKey,
          'No item ID',
        ),
      );
    }
    return options;
  }

  /// The shop's categories, plus "No Category" and "Unknown
  /// (deleted item)" when a row needs them.
  static List<ReceiptsFilterOption> categories(
    Map<String, String> nameByUuid,
    List<ItemSalesRow> rows,
  ) {
    final options =
        nameByUuid.entries
            .map((e) => ReceiptsFilterOption(e.key, e.value))
            .toList()
          ..sort((a, b) {
            final c = a.label.toLowerCase().compareTo(
              b.label.toLowerCase(),
            );
            return c != 0 ? c : a.key.compareTo(b.key);
          });
    if (rows.any(
      (r) => r.productExists && r.categoryUuids.isEmpty,
    )) {
      options.add(
        const ReceiptsFilterOption(
          receiptsReportNoneKey,
          itemSalesNoCategoryLabel,
        ),
      );
    }
    if (rows.any((r) => !r.productExists)) {
      options.add(
        const ReceiptsFilterOption(
          itemSalesDeletedItemKey,
          itemSalesDeletedItemLabel,
        ),
      );
    }
    return options;
  }
}

/// Result of [ItemSalesQuery.paginate].
class ItemSalesPage {
  final List<ItemSalesRow> rows;
  final int totalCount;
  final int page; // 1-based, already clamped
  final int totalPages;

  const ItemSalesPage({
    required this.rows,
    required this.totalCount,
    required this.page,
    required this.totalPages,
  });

  int get firstIndex =>
      totalCount == 0
          ? 0
          : (page - 1) * itemSalesReportPageSize + 1;
  int get lastIndex =>
      firstIndex == 0 ? 0 : firstIndex + rows.length - 1;
}

class ItemSalesQuery {
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

  static bool _visible(
    ItemSalesRow r, {
    required ReceiptsReportPeriod period,
    required ItemSalesFilters filters,
    required bool departmentsEnabled,
    required bool subStaffEnabled,
    required bool profitVisible,
    TimeOfDay? closingTime,
    bool ignoreProfit = false,
    bool ignoreQuantity = false,
  }) {
    return period.contains(
          r.createdAt,
          closingTime: closingTime,
        ) &&
        filters.matches(
          r,
          departmentsEnabled: departmentsEnabled,
          subStaffEnabled: subStaffEnabled,
          profitVisible: profitVisible,
          ignoreProfit: ignoreProfit,
          ignoreQuantity: ignoreQuantity,
        );
  }

  /// Rows in [period], then search and filters, then sorted. The
  /// whole set is sorted before pagination.
  static List<ItemSalesRow> filterAndSort({
    required List<ItemSalesRow> rows,
    required ReceiptsReportPeriod period,
    required ItemSalesFilters filters,
    required ItemSalesSortField sortField,
    required bool ascending,
    required bool departmentsEnabled,
    required bool subStaffEnabled,
    required bool profitVisible,
    TimeOfDay? closingTime,
  }) {
    final out =
        rows
            .where(
              (r) => _visible(
                r,
                period: period,
                filters: filters,
                departmentsEnabled: departmentsEnabled,
                subStaffEnabled: subStaffEnabled,
                profitVisible: profitVisible,
                closingTime: closingTime,
              ),
            )
            .toList();

    int compare(ItemSalesRow a, ItemSalesRow b) {
      int c;
      switch (sortField) {
        case ItemSalesSortField.item:
          c = _cmp(
            a.itemName?.toLowerCase(),
            b.itemName?.toLowerCase(),
            ascending,
          );
          break;
        case ItemSalesSortField.category:
          c = _cmp(
            a.categoryNames.isEmpty
                ? null
                : a.categoryNames.join(', ').toLowerCase(),
            b.categoryNames.isEmpty
                ? null
                : b.categoryNames.join(', ').toLowerCase(),
            ascending,
          );
          break;
        case ItemSalesSortField.receiptId:
          c = _cmp(
            a.receiptId.toLowerCase(),
            b.receiptId.toLowerCase(),
            ascending,
          );
          break;
        case ItemSalesSortField.staff:
          c = _cmp(
            a.parent.staffName?.toLowerCase(),
            b.parent.staffName?.toLowerCase(),
            ascending,
          );
          break;
        case ItemSalesSortField.customer:
          c = _cmp(
            a.parent.customerName?.toLowerCase(),
            b.parent.customerName?.toLowerCase(),
            ascending,
          );
          break;
        case ItemSalesSortField.createdAt:
          c = _cmp(a.createdAt, b.createdAt, ascending);
          break;
        case ItemSalesSortField.quantity:
          c = _cmp(a.quantity, b.quantity, ascending);
          break;
        case ItemSalesSortField.sellingPrice:
          c = _cmp(a.sellingPrice, b.sellingPrice, ascending);
          break;
        case ItemSalesSortField.cost:
          c = _cmp(a.cost, b.cost, ascending);
          break;
        case ItemSalesSortField.revenue:
          c = _cmp(a.revenue, b.revenue, ascending);
          break;
        case ItemSalesSortField.profit:
          c = _cmp(a.profit, b.profit, ascending);
          break;
        case ItemSalesSortField.margin:
          c = _cmp(a.margin, b.margin, ascending);
          break;
      }
      if (c != 0) return c;
      // Deterministic tie-breakers keep pagination stable.
      final t = b.createdAt.compareTo(a.createdAt);
      if (t != 0) return t;
      final u = a.receiptUuid.compareTo(b.receiptUuid);
      return u != 0 ? u : a.lineIndex.compareTo(b.lineIndex);
    }

    out.sort(compare);
    return out;
  }

  /// Rows the profit range left out only because a cost is
  /// missing. 0 when the range is not set.
  static int profitExcludedCount({
    required List<ItemSalesRow> rows,
    required ReceiptsReportPeriod period,
    required ItemSalesFilters filters,
    required bool departmentsEnabled,
    required bool subStaffEnabled,
    required bool profitVisible,
    TimeOfDay? closingTime,
  }) {
    if (!profitVisible || !filters.receipt.profitRangeActive) {
      return 0;
    }
    return rows
        .where(
          (r) =>
              r.costMissing &&
              _visible(
                r,
                period: period,
                filters: filters,
                departmentsEnabled: departmentsEnabled,
                subStaffEnabled: subStaffEnabled,
                profitVisible: profitVisible,
                closingTime: closingTime,
                ignoreProfit: true,
              ),
        )
        .length;
  }

  /// Rows the quantity range left out only because their quantity
  /// is a part payment's or cannot be converted. 0 when the range
  /// is not active.
  static int quantityExcludedCount({
    required List<ItemSalesRow> rows,
    required ReceiptsReportPeriod period,
    required ItemSalesFilters filters,
    required bool departmentsEnabled,
    required bool subStaffEnabled,
    required bool profitVisible,
    TimeOfDay? closingTime,
  }) {
    if (!filters.quantityRangeActive) return 0;
    return rows
        .where(
          (r) =>
              (r.baseQuantity == null || r.isPartPayment) &&
              _visible(
                r,
                period: period,
                filters: filters,
                departmentsEnabled: departmentsEnabled,
                subStaffEnabled: subStaffEnabled,
                profitVisible: profitVisible,
                closingTime: closingTime,
                ignoreQuantity: true,
              ),
        )
        .length;
  }

  static ItemSalesPage paginate(
    List<ItemSalesRow> sorted,
    int requestedPage,
  ) {
    final total = sorted.length;
    final pages =
        total == 0
            ? 1
            : (total / itemSalesReportPageSize).ceil();
    final page = requestedPage.clamp(1, pages);
    final start = (page - 1) * itemSalesReportPageSize;
    final end =
        (start + itemSalesReportPageSize) > total
            ? total
            : start + itemSalesReportPageSize;
    return ItemSalesPage(
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
