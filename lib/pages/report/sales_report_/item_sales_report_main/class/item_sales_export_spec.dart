// Export spec of the Item Sales table: the line rows (the full filtered
// and sorted list, not the page) with the columns of
// ItemSalesColumnInfo.visible, or the "Group by item" table when it is
// on. Totals are the screen's own (ItemSalesPage): void lines are never
// counted, and the quantity total only shows with one known unit and no
// invoice part payments.

import 'package:stockall/constants/calculations.dart' show formatDimension;
import 'package:stockall/pages/report/components/export/report_export_format.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/export/report_export_splits.dart';
import 'package:stockall/pages/report/sales_report_/item_sales_report_main/class/item_sales_report_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_export_spec.dart'
    show receiptsExportFilters;
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/components/receipts_report_filter_widgets.dart';

const String _dash = '—';

/// The notes the Item Sales table shows under its toolbar. The view
/// draws these and the export carries them, so they always match.
List<String> itemSalesNotes({
  required ReceiptsReportPeriod period,
  required bool cartDiscountInView,
  required int profitExcluded,
  required int quantityExcluded,
  required bool groupByItem,
  required int groupQuantityExcluded,
}) {
  return [
    if (period.isAllTime)
      'All time covers the receipts loaded on this device.',
    if (cartDiscountInView)
      'Cart discounts on a receipt are not included in its '
          'item revenue.',
    if (profitExcluded > 0)
      '$profitExcluded item record${profitExcluded == 1 ? ' is' : 's are'} '
          'left out of the profit range: missing cost price.',
    if (quantityExcluded > 0)
      '$quantityExcluded item record${quantityExcluded == 1 ? ' is' : 's are'} '
          'left out of the quantity range: invoice part '
          'payment or unknown unit.',
    if (groupByItem && groupQuantityExcluded > 0)
      '$groupQuantityExcluded invoice part-payment '
          'line${groupQuantityExcluded == 1 ? ' is' : 's are'} '
          'not in Total Quantity: they repeat the invoice\'s '
          'full quantity.',
  ];
}

/// Any line in [rows] with a cart discount (the screen's rule).
bool itemSalesCartDiscountInView(List<ItemSalesRow> rows) => rows.any(
  (r) =>
      r.parent.receipt.generalDiscount != null ||
      r.parent.receipt.fixedDiscount != null,
);

const Map<ItemSalesSortField, String> itemSalesSortLabels = {
  ItemSalesSortField.item: 'Item',
  ItemSalesSortField.category: 'Category',
  ItemSalesSortField.receiptId: 'Receipt ID',
  ItemSalesSortField.staff: 'Staff',
  ItemSalesSortField.customer: 'Customer',
  ItemSalesSortField.createdAt: 'Date',
  ItemSalesSortField.quantity: 'Quantity',
  ItemSalesSortField.sellingPrice: 'Selling Price',
  ItemSalesSortField.cost: 'Cost Price',
  ItemSalesSortField.revenue: 'Revenue',
  ItemSalesSortField.profit: 'Profit/Loss',
  ItemSalesSortField.margin: 'Margin (%)',
};

String itemSalesSortLabel(ItemSalesSortField field, bool ascending) =>
    '${itemSalesSortLabels[field] ?? field.name} '
    '(${ascending ? 'ascending' : 'descending'})';

/// The group table sorts by item, quantity, profit or margin; anything
/// else sorts by revenue (`ItemSalesGrouping.sort`).
String itemSalesGroupSortLabel(ItemSalesSortField field, bool ascending) {
  final label = switch (field) {
    ItemSalesSortField.item => ItemSalesGroupColumn.item.label,
    ItemSalesSortField.quantity => ItemSalesGroupColumn.quantity.label,
    ItemSalesSortField.profit => ItemSalesGroupColumn.profit.label,
    ItemSalesSortField.margin => ItemSalesGroupColumn.margin.label,
    _ => ItemSalesGroupColumn.revenue.label,
  };
  return '$label (${ascending ? 'ascending' : 'descending'})';
}

/// The filters with their values: the `ItemSalesFilterChips` wording,
/// then the receipt chips, as the screen lists them.
List<ExportFilter> itemSalesExportFilters({
  required ItemSalesFilters filters,
  required List<ReceiptsFilterOption> categoryOptions,
  required List<ReceiptsFilterOption> itemOptions,
  required ReceiptsFilterChoices choices,
  required bool departmentsEnabled,
  required bool subStaffEnabled,
  required bool profitVisible,
  required ExportFormatter f,
  String? lockedItemName,
}) {
  String yesNo(bool v) => v ? 'Yes' : 'No';
  String number(double? v) => v == null ? 'Any' : formatDimension(v);
  final out = <ExportFilter>[];
  if (filters.categoryKey != null) {
    out.add(ExportFilter(
      'Category',
      ReceiptsFilterChoices.labelFor(categoryOptions, filters.categoryKey!, 'Category'),
    ));
  }
  if (lockedItemName != null) {
    out.add(ExportFilter('Item', lockedItemName));
  } else if (filters.productKey != null) {
    out.add(ExportFilter(
      'Item',
      ReceiptsFilterChoices.labelFor(itemOptions, filters.productKey!, 'Item'),
    ));
  }
  if (filters.voidFilter != ItemSalesVoidFilter.notVoid) {
    out.add(ExportFilter('Void', filters.voidFilter.label));
  }
  if (filters.customPrice != null) {
    out.add(ExportFilter('Custom Price', yesNo(filters.customPrice!)));
  }
  if (filters.wholesale != null) {
    out.add(ExportFilter('Wholesale Price', yesNo(filters.wholesale!)));
  }
  if (filters.quantitySet) {
    out.add(ExportFilter(
      'Quantity',
      '${number(filters.quantityMin)} - ${number(filters.quantityMax)}',
    ));
  }
  return [
    ...out,
    ...receiptsExportFilters(
      filters: filters.receipt,
      choices: choices,
      departmentsEnabled: departmentsEnabled,
      subStaffEnabled: subStaffEnabled,
      profitVisible: profitVisible,
      f: f,
    ),
  ];
}

/// The screen's totals row (ItemSalesPage) by column id.
Map<String, Object?> itemSalesTotals(
  List<ItemSalesRow> rows, {
  required bool canSeeCost,
  required ExportFormatter f,
}) {
  final page = ItemSalesQuery.paginate(rows, 1);
  final m = page.totalMargin;
  final q = page.totalQuantity;
  return {
    'item': '${f.integer(rows.length)} item record${rows.length == 1 ? '' : 's'}',
    if (q != null)
      'quantity': '${formatDimension(q)} ${page.totalQuantityUnit ?? ''}'.trim(),
    'discount': page.totalDiscount,
    'grossValue': page.totalGrossValue,
    if (canSeeCost) ...{
      'costPrice': page.totalCost,
      'profit': page.totalProfit,
      if (m != null) 'margin': m,
    },
    'revenue': page.totalRevenue,
  };
}

ExportColumn<ItemSalesRow> _column(
  ItemSalesColumn c,
  ExportFormatter f, {
  required bool voidInPdf,
}) {
  String yesNo(bool? v) => v == null ? _dash : (v ? 'Yes' : 'No');
  String money(double? v) => v == null ? _dash : f.money(v);
  final id = c.name;
  final label = c.label;
  switch (c) {
    case ItemSalesColumn.item:
      return ExportColumn(id: id, label: label, value: (r) => r.itemLabel, width: 2);
    case ItemSalesColumn.quantity:
      return ExportColumn(
        id: id,
        label: label,
        format: ExportFormat.quantity,
        value: (r) => r.quantity,
        display: (r) => formatDimension(r.quantity),
        width: 0.8,
      );
    case ItemSalesColumn.unit:
      return ExportColumn(
        id: id,
        label: label,
        value: (r) => r.unitName,
        display: (r) => r.unitName ?? _dash,
      );
    case ItemSalesColumn.revenue:
      return ExportColumn(
        id: id,
        label: label,
        format: ExportFormat.money,
        value: (r) => r.revenue,
        width: 1.3,
      );
    case ItemSalesColumn.profit:
      return ExportColumn(
        id: id,
        label: label,
        format: ExportFormat.money,
        value: (r) => r.profit,
        width: 1.3,
      );
    case ItemSalesColumn.margin:
      return ExportColumn(
        id: id,
        label: label,
        format: ExportFormat.percent,
        value: (r) => r.margin,
        display: (r) => r.margin == null ? 'N/A' : f.percent(r.margin!),
        width: 0.9,
      );
    case ItemSalesColumn.date:
      return ExportColumn(
        id: id,
        label: label,
        format: ExportFormat.date,
        value: (r) => r.createdAt,
      );
    case ItemSalesColumn.time:
      return ExportColumn(
        id: id,
        label: label,
        format: ExportFormat.time,
        value: (r) => r.createdAt,
      );
    case ItemSalesColumn.recordId:
      // The full id (the screen shows the first 8 characters).
      return ExportColumn(
        id: id,
        label: label,
        value: (r) => r.recordId,
        display: (r) => r.recordId ?? _dash,
        inPdf: false,
      );
    case ItemSalesColumn.category:
      return ExportColumn(id: id, label: label, value: (r) => r.categoryLabel, width: 1.4);
    case ItemSalesColumn.receiptId:
      return ExportColumn(id: id, label: label, value: (r) => r.receiptId, width: 1.3);
    case ItemSalesColumn.staff:
      return ExportColumn(id: id, label: label, value: (r) => r.parent.staffLabel, width: 1.2);
    case ItemSalesColumn.subStaff:
      return ExportColumn(
        id: id,
        label: label,
        value: (r) => r.parent.subStaffLabel,
        width: 1.2,
      );
    case ItemSalesColumn.customer:
      return ExportColumn(
        id: id,
        label: label,
        value: (r) => r.parent.customerLabel,
        width: 1.3,
      );
    case ItemSalesColumn.sellingPrice:
      return ExportColumn(
        id: id,
        label: label,
        format: ExportFormat.money,
        value: (r) => r.sellingPrice,
        display: (r) => money(r.sellingPrice),
        inPdf: false,
      );
    case ItemSalesColumn.discount:
      return ExportColumn(
        id: id,
        label: label,
        format: ExportFormat.money,
        value: (r) => r.discount,
        display: (r) {
          final v = r.discount;
          if (v == null) return _dash;
          final pct = r.discountPercent;
          return pct == null ? f.money(v) : '${f.money(v)} (${f.percent(pct)})';
        },
        width: 1.2,
      );
    case ItemSalesColumn.grossValue:
      return ExportColumn(
        id: id,
        label: label,
        format: ExportFormat.money,
        value: (r) => r.grossValue,
        display: (r) => money(r.grossValue),
        inPdf: false,
      );
    case ItemSalesColumn.costPrice:
      return ExportColumn(
        id: id,
        label: label,
        format: ExportFormat.money,
        value: (r) => r.cost,
        display: (r) => r.cost == null ? 'N/A' : f.money(r.cost!),
        width: 1.2,
      );
    case ItemSalesColumn.department:
      return ExportColumn(
        id: id,
        label: label,
        value: (r) => r.parent.departmentLabel,
        width: 1.2,
      );
    case ItemSalesColumn.customPrice:
      return ExportColumn(
        id: id,
        label: label,
        value: (r) => r.customTotal ? 'Yes (total)' : yesNo(r.customPrice),
        inPdf: false,
      );
    case ItemSalesColumn.wholesale:
      return ExportColumn(
        id: id,
        label: label,
        value: (r) => yesNo(r.wholesale),
        inPdf: false,
      );
    case ItemSalesColumn.managed:
      return ExportColumn(
        id: id,
        label: label,
        value: (r) => yesNo(r.managed),
        inPdf: false,
      );
    case ItemSalesColumn.type:
      return ExportColumn(id: id, label: label, value: (r) => r.type.label, width: 1.2);
    case ItemSalesColumn.voidStatus:
      return ExportColumn(
        id: id,
        label: label,
        value: (r) => r.isVoid ? 'VOID' : 'No',
        width: 0.6,
        inPdf: voidInPdf,
      );
    case ItemSalesColumn.wastage:
      return ExportColumn(
        id: id,
        label: label,
        format: ExportFormat.quantity,
        value: (r) => (r.wastage ?? 0) > 0 ? r.wastage : null,
        display: (r) {
          final w = r.wastage;
          if (w == null || w <= 0) return _dash;
          return '${formatDimension(w)} ${r.unitName ?? ''}'.trim();
        },
        inPdf: false,
      );
  }
}

ExportTableSection<ItemSalesRow> itemSalesTableSection({
  required List<ItemSalesRow> rows,
  required ExportFormatter f,
  required bool canSeeCost,
  required bool departmentsEnabled,
  required bool subStaffEnabled,
  required ItemSalesVoidFilter voidFilter,
}) {
  final categoryNames = <String, String>{};
  for (final r in rows) {
    for (var i = 0; i < r.categoryUuids.length && i < r.categoryNames.length; i++) {
      categoryNames.putIfAbsent(r.categoryUuids[i], () => r.categoryNames[i]);
    }
  }
  final visible = ItemSalesColumnInfo.visible(
    departmentsEnabled: departmentsEnabled,
    subStaffEnabled: subStaffEnabled,
    costVisible: canSeeCost,
  );
  return ExportTableSection<ItemSalesRow>(
    title: 'Item Sales',
    rows: rows,
    columns: [
      for (final c in visible)
        _column(c, f, voidInPdf: voidFilter != ItemSalesVoidFilter.notVoid),
      // Roll-only: "Cola ×2" for the 58mm roll.
      ExportColumn(
        id: 'itemQty',
        label: 'Item',
        value: (r) => '${r.itemLabel} ×${formatDimension(r.quantity)}',
        inPdf: false,
        inExcel: false,
      ),
    ],
    totalsFor: (rs) => itemSalesTotals(rs, canSeeCost: canSeeCost, f: f),
    splits: [
      categorySplit<ItemSalesRow>(
        categoryIds: (r) => r.productExists ? r.categoryUuids : const [],
        names: categoryNames,
      ),
      if (departmentsEnabled)
        fieldSplit<ItemSalesRow>(
          id: 'department',
          label: 'Department',
          noneLabel: 'No Department',
          rows: rows,
          key: (r) => r.parent.departmentKey,
          name: (r) => r.parent.departmentName,
        ),
      staffSplit<ItemSalesRow>(
        rows: rows,
        staffId: (r) => r.parent.staffKey,
        staffName: (r) => r.parent.staffName,
      ),
      channelSplit<ItemSalesRow>(channel: (r) => r.parent.channel.label),
    ],
    // 58mm: 15 / 16 characters, 80mm: 20 / 7 / 19, so "₦1,250,000.00"
    // and "1,250" stay on one line.
    roll: const RollLayout(
      cols58: ['itemQty', 'revenue'],
      cols80: ['item', 'quantity', 'revenue'],
      sub80: ['receiptId', 'time'],
      flex58: [1, 1],
      flex80: [5, 2, 4],
    ),
    emptyMessage: 'No item record matches the selected period and filters.',
  );
}

ExportTableSection<ItemSalesGroupRow> itemSalesGroupSection({
  required List<ItemSalesGroupRow> groups,
  required ExportFormatter f,
  required bool canSeeCost,
}) {
  ExportColumn<ItemSalesGroupRow> column(ItemSalesGroupColumn c) {
    final id = c.name;
    final label = c.label;
    switch (c) {
      case ItemSalesGroupColumn.item:
        return ExportColumn(id: id, label: label, value: (g) => g.itemLabel, width: 2.2);
      case ItemSalesGroupColumn.quantity:
        return ExportColumn(
          id: id,
          label: label,
          format: ExportFormat.quantity,
          value: (g) => g.quantityUnknown ? null : g.quantity,
          display: (g) => g.quantityUnknown ? _dash : formatDimension(g.quantity),
        );
      case ItemSalesGroupColumn.unit:
        return ExportColumn(
          id: id,
          label: label,
          value: (g) => g.unitName,
          display: (g) => g.unitName ?? _dash,
        );
      case ItemSalesGroupColumn.revenue:
        return ExportColumn(
          id: id,
          label: label,
          format: ExportFormat.money,
          value: (g) => g.revenue,
          width: 1.3,
        );
      case ItemSalesGroupColumn.profit:
        return ExportColumn(
          id: id,
          label: label,
          format: ExportFormat.money,
          value: (g) => g.profit,
          width: 1.3,
        );
      case ItemSalesGroupColumn.margin:
        return ExportColumn(
          id: id,
          label: label,
          format: ExportFormat.percent,
          value: (g) => g.margin,
          display: (g) => g.margin == null ? 'N/A' : f.percent(g.margin!),
        );
    }
  }

  return ExportTableSection<ItemSalesGroupRow>(
    title: 'Item Sales by Item',
    rows: groups,
    columns: [
      for (final c in ItemSalesGroupColumnInfo.visible(costVisible: canSeeCost))
        column(c),
    ],
    // The grouped screen has no totals row.
    roll: const RollLayout(
      cols58: ['item', 'revenue'],
      cols80: ['item', 'quantity', 'revenue'],
      flex58: [1, 1],
      flex80: [5, 2, 4],
    ),
    emptyMessage: 'No item record matches the selected period and filters.',
  );
}

/// [rows] is the full filtered and sorted line list; [groups] the full
/// sorted group list (used when [groupByItem]).
ReportExportSpec itemSalesExportSpec({
  required List<ItemSalesRow> rows,
  required List<ItemSalesGroupRow> groups,
  required bool groupByItem,
  required ItemSalesFilters filters,
  required List<ReceiptsFilterOption> categoryOptions,
  required List<ReceiptsFilterOption> itemOptions,
  required ReceiptsFilterChoices choices,
  required ReceiptsReportPeriod period,
  required ItemSalesSortField sortField,
  required bool ascending,
  required ItemSalesSortField groupSortField,
  required bool groupAscending,
  required List<String> notes,
  required String currency,
  required bool canSeeCost,
  required bool departmentsEnabled,
  required bool subStaffEnabled,
  String? lockedItemName,
}) {
  final f = ExportFormatter(currency: currency);
  return ReportExportSpec(
    reportName: 'Item Sales Report',
    fileSlug: 'item_sales_report',
    period: ExportPeriod(
      label: receiptsPeriodLabel(period),
      start: period.start,
      end: period.end,
    ),
    filters: itemSalesExportFilters(
      filters: filters,
      categoryOptions: categoryOptions,
      itemOptions: itemOptions,
      choices: choices,
      departmentsEnabled: departmentsEnabled,
      subStaffEnabled: subStaffEnabled,
      profitVisible: canSeeCost,
      f: f,
      lockedItemName: lockedItemName,
    ),
    sortedBy: groupByItem
        ? itemSalesGroupSortLabel(groupSortField, groupAscending)
        : itemSalesSortLabel(sortField, ascending),
    groupedBy: groupByItem ? 'Item' : null,
    notes: notes,
    sections: [
      if (groupByItem)
        itemSalesGroupSection(groups: groups, f: f, canSeeCost: canSeeCost)
      else
        itemSalesTableSection(
          rows: rows,
          f: f,
          canSeeCost: canSeeCost,
          departmentsEnabled: departmentsEnabled,
          subStaffEnabled: subStaffEnabled,
          voidFilter: filters.voidFilter,
        ),
    ],
  );
}
