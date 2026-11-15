import 'package:flutter/material.dart' show TimeOfDay;
import 'package:stockall/classes/temp_item_purchase_record/temp_item_purchase_record.dart';
import 'package:stockall/classes/temp_purchase/temp_purchase.dart';
import 'package:stockall/pages/report/components/report_pager.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/class/purchase_lines.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/class/purchase_report_table_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

const int purchaseItemReportPageSize = purchaseReportPageSize;

enum PurchaseItemTypeFilter { all, sales, storage }

extension PurchaseItemTypeFilterLabel on PurchaseItemTypeFilter {
  String get label {
    switch (this) {
      case PurchaseItemTypeFilter.all:
        return 'All Items';
      case PurchaseItemTypeFilter.sales:
        return 'Sales Items';
      case PurchaseItemTypeFilter.storage:
        return 'Storage Items';
    }
  }
}

enum PurchaseItemSortField {
  item,
  purchaseId,
  supplier,
  staff,
  createdAt,
  quantity,
  unitCost,
  total,
}

class PurchaseItemRow {
  final TempItemPurchaseRecord line;
  final PurchaseReportRow parent;
  final String itemName;
  final String? itemKey;
  final bool isStorageItem;
  final double quantity;
  final String unit;
  final double unitCost;
  final double originalPrice;
  final double? customPrice;
  final double lineTotal;
  final String? globalSupplierKey;
  final String globalSupplierLabel;
  final String? itemSupplierKey;
  final String? itemSupplierName;
  final String? globalTrackingNumber;
  final String? itemTrackingNumber;

  PurchaseItemRow({
    required this.line,
    required this.parent,
    required this.itemName,
    required this.itemKey,
    required this.isStorageItem,
    required this.quantity,
    required this.unit,
    required this.unitCost,
    required this.originalPrice,
    required this.customPrice,
    required this.lineTotal,
    required this.globalSupplierKey,
    required this.globalSupplierLabel,
    required this.itemSupplierKey,
    required this.itemSupplierName,
    required this.globalTrackingNumber,
    required this.itemTrackingNumber,
  });

  DateTime get createdAt => parent.createdAt;
  String get purchaseDisplayId => parent.displayId;
  String? get staffKey => parent.staffKey;
  String get staffLabel => parent.staffLabel;
  String? get departmentKey => parent.departmentKey;
  String get departmentLabel => parent.departmentLabel;
  String get channelKey => parent.channelKey;
  String get channelLabel => parent.channelLabel;
  PurchaseStatus get status => parent.status;

  String get itemTypeLabel => isStorageItem ? 'Storage Item' : 'Sales Item';
  String get itemSupplierLabel => itemSupplierName ?? '—';
  String? get effectiveSupplierKey => itemSupplierKey ?? globalSupplierKey;
  String get effectiveSupplierLabel =>
      itemSupplierName ?? globalSupplierLabel;

  String get globalTrackingLabel => globalTrackingNumber ?? '—';
  String get itemTrackingLabel => itemTrackingNumber ?? '—';
  String get effectiveTrackingLabel =>
      itemTrackingNumber ?? globalTrackingNumber ?? '—';

  String get customPriceLabel =>
      customPrice != null ? 'Yes' : 'No';
}

class PurchaseItemRowBuilder {
  static String? _name(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  static List<PurchaseItemRow> buildAll({
    required List<TempPurchase> purchases,
    List<TempItemPurchaseRecord> legacyLines = const [],
    Map<String, String> supplierNames = const {},
    Set<String> pendingDeletedUuids = const {},
  }) {
    final legacy = PurchaseLines.legacyLinesByPurchase(legacyLines);
    final rows = <PurchaseItemRow>[];
    for (final purchase in purchases) {
      if (pendingDeletedUuids.contains(purchase.uuid)) continue;
      final PurchaseReportRow parent;
      try {
        parent = PurchaseReportRowBuilder.build(
          purchase: purchase,
          legacyLines: legacy,
          supplierNames: supplierNames,
        );
      } catch (_) {
        continue;
      }
      final (:lines, source: _) = PurchaseLines.linesFor(purchase, legacy);
      if (lines == null || lines.isEmpty) continue;

      for (final line in lines) {
        final isStorage =
            line.storageItemId != null && line.storageItemId!.trim().isNotEmpty;
        final qty = line.quantity ?? 0;
        final total = PurchaseLines.lineTotal(line);
        final unitName =
            PurchaseLines.lineUnit(line)?.name ??
            _name(line.unit) ??
            'Unit(s)';
        final origPrice = line.originalPrice ?? 0;
        final uCost =
            qty > 0
                ? total / qty
                : (line.customPrice ?? origPrice);

        final globalSupKey =
            _name(line.globalSupplierId) ?? parent.supplierKey;
        final globalSupName =
            _name(line.globalSupplierName) ??
            (globalSupKey != null ? _name(supplierNames[globalSupKey]) : null) ??
            parent.supplierName;
        final globalSupLabel =
            globalSupKey == null
                ? purchasesNoSupplierLabel
                : (globalSupName ?? 'Not Set');

        // Legacy lines copied purchase.supplierId into line.supplierId
        // without globalSupplierId.
        final isLegacyGlobalCopy =
            line.globalSupplierId == null &&
            line.supplierName == null &&
            line.supplierId == purchase.supplierId;
        final itemSupKey =
            isLegacyGlobalCopy ? null : _name(line.supplierId);
        final itemSupName =
            itemSupKey == null
                ? null
                : (_name(line.supplierName) ??
                    _name(supplierNames[itemSupKey]) ??
                    'Not Set');

        final globalTracking =
            _name(line.globalTrackingNumber) ?? parent.trackingNumber;
        final itemTracking = _name(line.trackingNumber);

        rows.add(
          PurchaseItemRow(
            line: line,
            parent: parent,
            itemName: _name(line.itemName) ?? 'Unknown Item',
            itemKey: PurchaseLines.productKey(line),
            isStorageItem: isStorage,
            quantity: qty,
            unit: unitName,
            unitCost: uCost,
            originalPrice: origPrice,
            customPrice: line.customPrice,
            lineTotal: total,
            globalSupplierKey: globalSupKey,
            globalSupplierLabel: globalSupLabel,
            itemSupplierKey: itemSupKey,
            itemSupplierName: itemSupName,
            globalTrackingNumber: globalTracking,
            itemTrackingNumber: itemTracking,
          ),
        );
      }
    }
    return rows;
  }
}

class PurchaseItemFilters {
  String search;
  String? itemKey;
  String? supplierKey;
  String? staffKey;
  String? departmentKey;
  String? channelKey;
  PurchaseStatus? status;
  PurchaseItemTypeFilter itemType;
  double? totalMin;
  double? totalMax;

  PurchaseItemFilters({
    this.search = '',
    this.itemKey,
    this.supplierKey,
    this.staffKey,
    this.departmentKey,
    this.channelKey,
    this.status,
    this.itemType = PurchaseItemTypeFilter.all,
    this.totalMin,
    this.totalMax,
  });

  PurchaseItemFilters copy() => PurchaseItemFilters(
    search: search,
    itemKey: itemKey,
    supplierKey: supplierKey,
    staffKey: staffKey,
    departmentKey: departmentKey,
    channelKey: channelKey,
    status: status,
    itemType: itemType,
    totalMin: totalMin,
    totalMax: totalMax,
  );

  String? get totalRangeError =>
      PurchaseReportFilters.rangeError(totalMin, totalMax);

  bool get totalRangeActive =>
      (totalMin != null || totalMax != null) && totalRangeError == null;

  int get activeFilterCount =>
      (itemKey != null ? 1 : 0) +
      (supplierKey != null ? 1 : 0) +
      (staffKey != null ? 1 : 0) +
      (departmentKey != null ? 1 : 0) +
      (channelKey != null ? 1 : 0) +
      (status != null ? 1 : 0) +
      (itemType != PurchaseItemTypeFilter.all ? 1 : 0) +
      (totalRangeActive ? 1 : 0);

  void clearAll() {
    search = '';
    itemKey = null;
    supplierKey = null;
    staffKey = null;
    departmentKey = null;
    channelKey = null;
    status = null;
    itemType = PurchaseItemTypeFilter.all;
    totalMin = null;
    totalMax = null;
  }

  static bool keyMatches(String? selected, String? rowKey) {
    if (selected == null) return true;
    if (selected == purchaseReportNoneKey) return rowKey == null;
    return rowKey == selected;
  }

  bool matchesSearch(
    PurchaseItemRow r, {
    required bool departmentsEnabled,
  }) {
    final q = search.trim().toLowerCase();
    if (q.isEmpty) return true;
    bool has(String? s) => s != null && s.toLowerCase().contains(q);
    return has(r.itemName) ||
        has(r.purchaseDisplayId) ||
        has(r.globalSupplierLabel) ||
        has(r.itemSupplierName) ||
        has(r.globalTrackingNumber) ||
        has(r.itemTrackingNumber) ||
        has(r.staffLabel) ||
        has(r.unit) ||
        (departmentsEnabled && has(r.departmentLabel));
  }

  bool matches(
    PurchaseItemRow r, {
    required bool departmentsEnabled,
  }) {
    if (!matchesSearch(r, departmentsEnabled: departmentsEnabled)) {
      return false;
    }
    if (!keyMatches(itemKey, r.itemKey)) return false;
    if (!keyMatches(supplierKey, r.effectiveSupplierKey)) return false;
    if (!keyMatches(staffKey, r.staffKey)) return false;
    if (departmentsEnabled &&
        !keyMatches(departmentKey, r.departmentKey)) {
      return false;
    }
    if (channelKey != null && r.channelKey != channelKey) return false;
    if (status != null && r.status != status) return false;
    if (itemType == PurchaseItemTypeFilter.sales && r.isStorageItem) {
      return false;
    }
    if (itemType == PurchaseItemTypeFilter.storage && !r.isStorageItem) {
      return false;
    }
    if (totalRangeActive &&
        !ReceiptsReportFilters.inRange(r.lineTotal, totalMin, totalMax)) {
      return false;
    }
    return true;
  }
}

class PurchaseItemReportTotals {
  final int lineCount;
  final int distinctItems;
  final int purchaseCount;
  final double totalQuantity;
  final double totalSpend;

  const PurchaseItemReportTotals({
    required this.lineCount,
    required this.distinctItems,
    required this.purchaseCount,
    required this.totalQuantity,
    required this.totalSpend,
  });
}

class PurchaseItemPage {
  final int page;
  final int totalPages;
  final int totalCount;
  final int firstIndex;
  final int lastIndex;
  final List<PurchaseItemRow> rows;

  const PurchaseItemPage({
    required this.page,
    required this.totalPages,
    required this.totalCount,
    required this.firstIndex,
    required this.lastIndex,
    required this.rows,
  });
}

class PurchaseItemFilterBuilder {
  static List<PurchaseItemRow> inPeriod(
    List<PurchaseItemRow> rows,
    ReceiptsReportPeriod period, {
    TimeOfDay? closingTime,
  }) {
    if (period.isAllTime) return rows;
    return rows
        .where(
          (r) => period.contains(r.createdAt, closingTime: closingTime),
        )
        .toList();
  }

  static List<PurchaseItemRow> filter(
    List<PurchaseItemRow> rows,
    PurchaseItemFilters filters, {
    required bool departmentsEnabled,
  }) {
    return rows
        .where(
          (r) => filters.matches(r, departmentsEnabled: departmentsEnabled),
        )
        .toList();
  }

  static List<PurchaseItemRow> sort(
    List<PurchaseItemRow> rows,
    PurchaseItemSortField field,
    bool ascending,
  ) {
    final out = List<PurchaseItemRow>.from(rows);
    int cmpText(String a, String b) =>
        a.toLowerCase().compareTo(b.toLowerCase());
    out.sort((a, b) {
      int cmp;
      switch (field) {
        case PurchaseItemSortField.item:
          cmp = cmpText(a.itemName, b.itemName);
          break;
        case PurchaseItemSortField.purchaseId:
          cmp = cmpText(a.purchaseDisplayId, b.purchaseDisplayId);
          break;
        case PurchaseItemSortField.supplier:
          cmp = cmpText(a.effectiveSupplierLabel, b.effectiveSupplierLabel);
          break;
        case PurchaseItemSortField.staff:
          cmp = cmpText(a.staffLabel, b.staffLabel);
          break;
        case PurchaseItemSortField.createdAt:
          cmp = a.createdAt.compareTo(b.createdAt);
          break;
        case PurchaseItemSortField.quantity:
          cmp = a.quantity.compareTo(b.quantity);
          break;
        case PurchaseItemSortField.unitCost:
          cmp = a.unitCost.compareTo(b.unitCost);
          break;
        case PurchaseItemSortField.total:
          cmp = a.lineTotal.compareTo(b.lineTotal);
          break;
      }
      if (cmp == 0) {
        cmp = a.createdAt.compareTo(b.createdAt);
      }
      return ascending ? cmp : -cmp;
    });
    return out;
  }

  static PurchaseItemReportTotals totals(List<PurchaseItemRow> rows) {
    final itemKeys = <String>{};
    final purchaseIds = <String>{};
    double qty = 0;
    double spend = 0;
    for (final r in rows) {
      if (r.itemKey != null) itemKeys.add(r.itemKey!);
      purchaseIds.add(r.parent.uuid);
      qty += r.quantity;
      spend += r.lineTotal;
    }
    return PurchaseItemReportTotals(
      lineCount: rows.length,
      distinctItems: itemKeys.length,
      purchaseCount: purchaseIds.length,
      totalQuantity: qty,
      totalSpend: spend,
    );
  }

  static List<PurchaseFilterOption> items(List<PurchaseItemRow> rows) =>
      _groupOptions(
        rows,
        keyOf: (r) => r.itemKey,
        labelOf: (r) => r.itemName,
        noneLabel: 'Unknown Item',
      );

  static List<PurchaseFilterOption> suppliers(List<PurchaseItemRow> rows) =>
      _groupOptions(
        rows,
        keyOf: (r) => r.effectiveSupplierKey,
        labelOf: (r) => r.effectiveSupplierLabel,
        noneLabel: purchasesNoSupplierLabel,
      );

  static List<PurchaseFilterOption> staff(List<PurchaseItemRow> rows) =>
      _groupOptions(
        rows,
        keyOf: (r) => r.staffKey,
        labelOf: (r) => r.staffLabel,
        noneLabel: purchasesNoStaffLabel,
      );

  static List<PurchaseFilterOption> departments(List<PurchaseItemRow> rows) =>
      _groupOptions(
        rows,
        keyOf: (r) => r.departmentKey,
        labelOf: (r) => r.departmentLabel,
        noneLabel: 'No Department',
      );

  static List<PurchaseFilterOption> _groupOptions(
    List<PurchaseItemRow> rows, {
    required String? Function(PurchaseItemRow) keyOf,
    required String Function(PurchaseItemRow) labelOf,
    required String noneLabel,
  }) {
    final labels = <String, String>{};
    for (final r in rows) {
      final k = keyOf(r) ?? purchaseReportNoneKey;
      labels.putIfAbsent(k, () => k == purchaseReportNoneKey ? noneLabel : labelOf(r));
    }
    final out =
        labels.entries
            .map(
              (e) => PurchaseFilterOption(
                e.key,
                e.value,
              ),
            )
            .toList()
          ..sort((a, b) {
            if (a.key == purchaseReportNoneKey) return 1;
            if (b.key == purchaseReportNoneKey) return -1;
            return a.label.toLowerCase().compareTo(b.label.toLowerCase());
          });
    return out;
  }

  static PurchaseItemPage paginate(
    List<PurchaseItemRow> rows,
    int page, {
    int pageSize = purchaseItemReportPageSize,
  }) {
    final b = reportPageBounds(rows.length, page, pageSize: pageSize);
    return PurchaseItemPage(
      page: b.page,
      totalPages: b.pages,
      totalCount: rows.length,
      firstIndex: rows.isEmpty ? 0 : b.start + 1,
      lastIndex: b.end,
      rows: rows.sublist(b.start, b.end),
    );
  }
}

class PurchaseItemGroupRow {
  final String? itemKey;
  final String itemName;
  final bool isStorageItem;
  final String unit;
  final int lineCount;
  final int purchaseCount;
  final double quantity;
  final double totalSpend;

  const PurchaseItemGroupRow({
    required this.itemKey,
    required this.itemName,
    required this.isStorageItem,
    required this.unit,
    required this.lineCount,
    required this.purchaseCount,
    required this.quantity,
    required this.totalSpend,
  });

  String get itemTypeLabel => isStorageItem ? 'Storage Item' : 'Sales Item';
  double get averageUnitCost => quantity == 0 ? 0 : totalSpend / quantity;
}

class PurchaseItemGroupPage {
  final int page;
  final int totalPages;
  final int totalCount;
  final int firstIndex;
  final int lastIndex;
  final List<PurchaseItemGroupRow> rows;
  final int totalLines;
  final double totalQuantity;
  final double totalSpend;

  const PurchaseItemGroupPage({
    required this.page,
    required this.totalPages,
    required this.totalCount,
    required this.firstIndex,
    required this.lastIndex,
    required this.rows,
    required this.totalLines,
    required this.totalQuantity,
    required this.totalSpend,
  });
}

class PurchaseItemGrouping {
  static List<PurchaseItemGroupRow> build(
    List<PurchaseItemRow> rows, {
    PurchaseItemSortField sortField = PurchaseItemSortField.total,
    bool ascending = false,
  }) {
    final byKey = <String, List<PurchaseItemRow>>{};
    for (final r in rows) {
      final k = '${r.itemKey ?? r.itemName}|${r.isStorageItem}|${r.unit}';
      (byKey[k] ??= []).add(r);
    }
    final out = <PurchaseItemGroupRow>[];
    for (final group in byKey.values) {
      final first = group.first;
      final purchaseIds = <String>{};
      double qty = 0;
      double spend = 0;
      for (final r in group) {
        purchaseIds.add(r.parent.uuid);
        qty += r.quantity;
        spend += r.lineTotal;
      }
      out.add(
        PurchaseItemGroupRow(
          itemKey: first.itemKey,
          itemName: first.itemName,
          isStorageItem: first.isStorageItem,
          unit: first.unit,
          lineCount: group.length,
          purchaseCount: purchaseIds.length,
          quantity: qty,
          totalSpend: spend,
        ),
      );
    }

    out.sort((a, b) {
      int cmp;
      switch (sortField) {
        case PurchaseItemSortField.item:
          cmp = a.itemName.toLowerCase().compareTo(b.itemName.toLowerCase());
          break;
        case PurchaseItemSortField.quantity:
          cmp = a.quantity.compareTo(b.quantity);
          break;
        case PurchaseItemSortField.unitCost:
          cmp = a.averageUnitCost.compareTo(b.averageUnitCost);
          break;
        case PurchaseItemSortField.total:
        case PurchaseItemSortField.purchaseId:
        case PurchaseItemSortField.supplier:
        case PurchaseItemSortField.staff:
        case PurchaseItemSortField.createdAt:
          cmp = a.totalSpend.compareTo(b.totalSpend);
          break;
      }
      if (cmp == 0) {
        cmp = a.itemName.toLowerCase().compareTo(b.itemName.toLowerCase());
      }
      return ascending ? cmp : -cmp;
    });
    return out;
  }

  static PurchaseItemGroupPage paginate(
    List<PurchaseItemGroupRow> rows,
    int page, {
    int pageSize = purchaseItemReportPageSize,
  }) {
    final b = reportPageBounds(rows.length, page, pageSize: pageSize);
    int lines = 0;
    double qty = 0;
    double spend = 0;
    for (final r in rows) {
      lines += r.lineCount;
      qty += r.quantity;
      spend += r.totalSpend;
    }
    return PurchaseItemGroupPage(
      page: b.page,
      totalPages: b.pages,
      totalCount: rows.length,
      firstIndex: rows.isEmpty ? 0 : b.start + 1,
      lastIndex: b.end,
      rows: rows.sublist(b.start, b.end),
      totalLines: lines,
      totalQuantity: qty,
      totalSpend: spend,
    );
  }
}
