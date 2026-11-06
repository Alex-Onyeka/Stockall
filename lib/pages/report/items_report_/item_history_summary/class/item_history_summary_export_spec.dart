// Export specs of the Item History Summary page and the Item-Level
// Stock Movements page. Both show the same per-item movement table, so
// the table is built once here. Rows are the full filtered and sorted
// list (the summary screen shows the top 10, Stock Movements a 100-row
// page).

import 'package:flutter/material.dart' show DateTimeRange;
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/constants/calculations.dart' show stripDimensionLabel;
import 'package:stockall/pages/report/components/export/report_export_format.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/export/report_export_splits.dart';
import 'package:stockall/pages/report/items_report_/item_history_summary/class/item_history_summary_logic.dart';
import 'package:stockall/pages/report/items_report_/items_report_main/class/items_report_export_spec.dart'
    show itemsExportSizeLabel;

const String _dash = '—';

/// Item uuid → " (4 x 2)" for every 2D sheet item with a size.
Map<String, String> stockMovementsSizeLabels(List<TempProductClass> products) {
  final out = <String, String>{};
  for (final p in products) {
    final id = p.uuid;
    if (id == null || id.isEmpty) continue;
    final size = itemsExportSizeLabel(p);
    if (size != null && size.isNotEmpty) out[id] = size;
  }
  return out;
}

/// Column label of each sort field, as on the screen.
const Map<ItemHistorySummarySortField, String> stockMovementsSortLabels = {
  ItemHistorySummarySortField.rowIndex: 'No.',
  ItemHistorySummarySortField.itemName: 'Item Name',
  ItemHistorySummarySortField.openingStock: 'Opening Stock',
  ItemHistorySummarySortField.closingStock: 'Closing Stock',
  ItemHistorySummarySortField.currentQuantity: 'Current Quantity',
  ItemHistorySummarySortField.netQuantityChange: 'Net Change',
  ItemHistorySummarySortField.sold: 'Sold',
  ItemHistorySummarySortField.returnedReceipt: 'Returned (Sales)',
  ItemHistorySummarySortField.returned: 'Returned (Sales)',
  ItemHistorySummarySortField.purchased: 'Purchased',
  ItemHistorySummarySortField.returnedPurchase: 'Returned (Purchase)',
  ItemHistorySummarySortField.transferredIn: 'Transfered In',
  ItemHistorySummarySortField.transferredOut: 'Transfered Out',
  ItemHistorySummarySortField.produced: 'Production',
  ItemHistorySummarySortField.productionDeleted: 'Production Deleted',
  ItemHistorySummarySortField.delivered: 'Delivered',
  ItemHistorySummarySortField.created: 'Created',
  ItemHistorySummarySortField.deleted: 'Deleted',
  ItemHistorySummarySortField.stockInUpdated: 'Stock In (Updated)',
  ItemHistorySummarySortField.stockOutUpdated: 'Stock Out (Updated)',
};

String stockMovementsSortLabel(
  ItemHistorySummarySortField field,
  bool ascending,
) =>
    '${stockMovementsSortLabels[field] ?? field.name} '
    '(${ascending ? 'ascending' : 'descending'})';

/// "This Month (Nov 1, 2026 - Nov 5, 2026)", "All Time", or the custom
/// range. [range] is the resolved range of the period.
String stockMovementsPeriodLabel(
  ItemHistoryPeriod period,
  DateTimeRange range,
  ExportFormatter f,
) {
  if (period == ItemHistoryPeriod.allTime) return period.label;
  final s = range.start;
  final e = range.end;
  final same = s.year == e.year && s.month == e.month && s.day == e.day;
  final dates = same ? f.date(s) : '${f.date(s)} - ${f.date(e)}';
  if (period == ItemHistoryPeriod.custom) return dates;
  return '${period.label} ($dates)';
}

ExportPeriod stockMovementsPeriod(
  ItemHistoryPeriod period,
  DateTimeRange range,
  ExportFormatter f,
) {
  final all = period == ItemHistoryPeriod.allTime;
  return ExportPeriod(
    label: stockMovementsPeriodLabel(period, range, f),
    start: all ? null : range.start,
    end: all ? null : range.end,
  );
}

/// The table filters with their values, worded like the Stock Movements
/// chips.
List<ExportFilter> stockMovementsExportFilters({
  required ItemHistorySummaryFilters filters,
  required bool departmentsEnabled,
  Map<String, String> categoryNames = const {},
  Map<String, String> departmentNames = const {},
}) {
  final out = <ExportFilter>[];
  final search = filters.search.trim();
  if (search.isNotEmpty) out.add(ExportFilter('Search', '"$search"'));
  if (filters.movementFilter != ItemHistoryMovementFilter.all) {
    out.add(ExportFilter('Movement', filters.movementFilter.label));
  }
  if (filters.categoryKey != null) {
    out.add(ExportFilter(
      'Category',
      filters.categoryKey == itemHistorySummaryNoneKey
          ? 'Uncategorized'
          : categoryNames[filters.categoryKey] ?? 'Category',
    ));
  }
  if (departmentsEnabled && filters.departmentKey != null) {
    out.add(ExportFilter(
      'Department',
      filters.departmentKey == itemHistorySummaryNoneKey
          ? 'Unassigned'
          : departmentNames[filters.departmentKey] ?? 'Department',
    ));
  }
  return out;
}

/// "-5 Bottles", "+3 Sheets (4 x 2)". [sign] is '+', '-' or ''.
String _qtyText(
  ItemHistorySummaryRow r,
  num v,
  ExportFormatter f,
  String sign,
  String? size,
) {
  final hasSize = size != null && size.isNotEmpty;
  final unit = hasSize
      ? '${stripDimensionLabel(r.primaryUnit.trim())}$size'
      : r.primaryUnit.trim();
  final n = '$sign${f.quantity(v.abs())}';
  return unit.isEmpty ? n : '$n $unit';
}

/// The per-item movement table of both pages. [sizeLabels] maps a 2D
/// sheet item's uuid to its " (4 x 2)".
ExportTableSection<ItemHistorySummaryRow> itemStockMovementsSection({
  required List<ItemHistorySummaryRow> rows,
  required ExportFormatter f,
  required bool manageProductions,
  required bool departmentsEnabled,
  Map<String, String> categoryNames = const {},
  Map<String, String> departmentNames = const {},
  Map<String, String> sizeLabels = const {},
  String title = 'Item Stock Movements',
}) {
  final number = Map<ItemHistorySummaryRow, int>.identity();
  for (var i = 0; i < rows.length; i++) {
    number[rows[i]] = i + 1;
  }
  String? size(ItemHistorySummaryRow r) => sizeLabels[r.uuid];

  // A balance: the number, or "—" when there is none.
  ExportColumn<ItemHistorySummaryRow> balance(
    String id,
    String label,
    double? Function(ItemHistorySummaryRow r) pick,
  ) {
    return ExportColumn<ItemHistorySummaryRow>(
      id: id,
      label: label,
      format: ExportFormat.quantity,
      value: pick,
      display: (r) {
        final v = pick(r);
        return v == null ? _dash : _qtyText(r, v, f, '', size(r));
      },
      width: 1.2,
    );
  }

  // A movement: "+5 Bottles" / "-5 Bottles", "—" when 0. Excel stores
  // the signed number (0 when none).
  ExportColumn<ItemHistorySummaryRow> movement(
    String id,
    String label,
    double Function(ItemHistorySummaryRow r) pick, {
    required bool inflow,
  }) {
    return ExportColumn<ItemHistorySummaryRow>(
      id: id,
      label: label,
      format: ExportFormat.quantity,
      value: (r) {
        final v = pick(r);
        if (v == 0) return 0;
        return inflow ? v.abs() : -v.abs();
      },
      display: (r) {
        final v = pick(r);
        if (v <= 0) return _dash;
        return _qtyText(r, v, f, inflow ? '+' : '-', size(r));
      },
    );
  }

  return ExportTableSection<ItemHistorySummaryRow>(
    title: title,
    rows: rows,
    columns: [
      ExportColumn(
        id: 'no',
        label: 'No.',
        format: ExportFormat.integer,
        value: (r) => number[r],
        width: 0.5,
      ),
      ExportColumn(
        id: 'name',
        label: 'Item Name',
        value: (r) => r.name,
        width: 2,
      ),
      ExportColumn(
        id: 'unit',
        label: 'Primary Unit',
        value: (r) => r.primaryUnit.trim(),
        inPdf: false,
      ),
      balance('opening', 'Opening Stock', (r) => r.openingStock),
      balance('closing', 'Closing Stock', (r) => r.closingStock),
      balance('current', 'Current Quantity', (r) => r.currentQuantity),
      ExportColumn(
        id: 'net',
        label: 'Net Change',
        format: ExportFormat.quantity,
        value: (r) => r.netQuantityChange,
        display: (r) {
          final v = r.netQuantityChange;
          final sign = v > 0 ? '+' : (v < 0 ? '-' : '');
          return _qtyText(r, v, f, sign, size(r));
        },
        width: 1.2,
      ),
      movement('sold', 'Sold', (r) => r.sold, inflow: false),
      movement(
        'returnedSales',
        'Returned (Sales)',
        (r) => r.returnedReceipt,
        inflow: true,
      ),
      movement('purchased', 'Purchased', (r) => r.purchased, inflow: true),
      movement(
        'returnedPurchase',
        'Returned (Purchase)',
        (r) => r.returnedPurchase,
        inflow: false,
      ),
      movement(
        'transferIn',
        'Transfered In',
        (r) => r.transferredIn,
        inflow: true,
      ),
      movement(
        'transferOut',
        'Transfered Out',
        (r) => r.transferredOut,
        inflow: false,
      ),
      movement(
        'stockIn',
        'Stock In (Updated)',
        (r) => r.quantityIncreased,
        inflow: true,
      ),
      movement(
        'stockOut',
        'Stock Out (Updated)',
        (r) => r.quantityDecreased,
        inflow: false,
      ),
      if (manageProductions) ...[
        movement('produced', 'Production', (r) => r.produced, inflow: true),
        movement(
          'productionDeleted',
          'Production Deleted',
          (r) => r.productionDeleted,
          inflow: false,
        ),
      ],
      movement('delivered', 'Delivered', (r) => r.delivered, inflow: false),
    ],
    // Export-only total: the item count. Quantities are in each item's
    // own unit, so they aren't summed.
    totalsFor: (rs) => {
      'name': '${f.integer(rs.length)} ${rs.length == 1 ? 'item' : 'items'}',
    },
    splits: [
      categorySplit<ItemHistorySummaryRow>(
        categoryIds: (r) => r.categoryUuids,
        names: categoryNames,
      ),
      if (departmentsEnabled)
        departmentSplit<ItemHistorySummaryRow>(
          departmentId: (r) => r.departmentUuid,
          names: departmentNames,
        ),
    ],
    // 58mm: 15 / 16 characters, 80mm: 12 / 16 / 18, so
    // "3 Sheets (4 x 2)" stays on one line.
    roll: const RollLayout(
      cols58: ['name', 'closing'],
      cols80: ['name', 'opening', 'closing'],
      flex58: [1, 1],
      flex80: [4, 5, 5],
    ),
    emptyMessage: 'No inventory items match the selected filters.',
  );
}

/// Top Inflow / Top Outflow items, as the summary screen lists them.
ExportTableSection<ItemHistorySummaryRow> _moversSection({
  required String title,
  required List<ItemHistorySummaryRow> rows,
  required bool inflow,
}) {
  final rank = Map<ItemHistorySummaryRow, int>.identity();
  for (var i = 0; i < rows.length; i++) {
    rank[rows[i]] = i + 1;
  }
  return ExportTableSection<ItemHistorySummaryRow>(
    title: title,
    rows: rows,
    columns: [
      ExportColumn(
        id: 'rank',
        label: 'Rank',
        format: ExportFormat.integer,
        value: (r) => rank[r],
        width: 0.5,
      ),
      ExportColumn(
        id: 'name',
        label: 'Item Name',
        value: (r) => r.name,
        width: 2.5,
      ),
      ExportColumn(
        id: 'unit',
        label: 'Primary Unit',
        value: (r) => r.primaryUnit.trim(),
      ),
      ExportColumn(
        id: 'value',
        label: inflow ? 'Stock Additions' : 'Stock Reductions',
        format: ExportFormat.quantity,
        value: (r) => inflow ? r.totalAdditions : -r.totalReductions,
        display: (r) =>
            inflow ? r.totalAdditionsText : r.totalReductionsText,
        width: 1.5,
      ),
    ],
    roll: const RollLayout(
      cols58: ['name', 'value'],
      cols80: ['rank', 'name', 'value'],
      flex58: [1, 1],
      flex80: [1, 4, 4],
    ),
    emptyMessage: 'No movement recorded.',
  );
}

/// The Item History Summary page: its headline figures (over every item
/// in the period, as on screen), Top Inflow / Outflow, and the full
/// filtered and sorted item table.
ReportExportSpec itemHistorySummaryExportSpec({
  required ItemHistorySummaryStats stats,
  required List<ItemHistorySummaryRow> allRows,
  required List<ItemHistorySummaryRow> rows,
  required ItemHistorySummaryFilters filters,
  required ItemHistorySummarySortField sortField,
  required bool ascending,
  required ItemHistoryPeriod period,
  required DateTimeRange range,
  required String currency,
  required bool manageProductions,
  required bool departmentsEnabled,
  Map<String, String> categoryNames = const {},
  Map<String, String> departmentNames = const {},
  Map<String, String> sizeLabels = const {},
}) {
  final f = ExportFormatter(currency: currency);
  ExportMetric qty(String label, num v) =>
      ExportMetric(label: label, value: v, format: ExportFormat.quantity);

  return ReportExportSpec(
    reportName: 'Item History Summary',
    fileSlug: 'item_history_summary',
    period: stockMovementsPeriod(period, range, f),
    filters: stockMovementsExportFilters(
      filters: filters,
      departmentsEnabled: departmentsEnabled,
      categoryNames: categoryNames,
      departmentNames: departmentNames,
    ),
    sortedBy: stockMovementsSortLabel(sortField, ascending),
    sections: [
      ExportSummarySection(
        title: 'Stock Movements & Analysis',
        metrics: [
          ExportMetric(
            label: 'Net Change',
            value: stats.netQuantityChange,
            format: ExportFormat.quantity,
            note: 'Additions minus Reductions',
          ),
          ExportMetric(
            label: 'Total Stock Additions',
            value: stats.totalStockAdditions,
            format: ExportFormat.quantity,
            note: 'Transfers, Purchases, Created, Produced',
          ),
          ExportMetric(
            label: 'Total Stock Reductions',
            value: stats.totalStockReductions == 0
                ? 0
                : -stats.totalStockReductions,
            format: ExportFormat.quantity,
          ),
          ExportMetric(
            label: 'Items With Movement',
            value:
                '${stats.itemsWithMovementCount} of ${stats.totalDistinctItems}',
            format: ExportFormat.text,
            note: '${stats.totalHistoryEvents} Recorded History Events',
          ),
        ],
      ),
      ExportSummarySection(
        title: 'Movement Breakdown',
        metrics: [
          qty('Transferred In', stats.totalTransferredIn),
          qty('Transferred Out', stats.totalTransferredOut),
          qty('Total In (Updated)', stats.totalQuantityIncreased),
          qty('Total Out (Updated)', stats.totalQuantityDecreased),
          if (manageProductions) ...[
            qty('Production', stats.totalProduced),
            qty('Production Deleted', stats.totalProductionDeleted),
          ],
          qty('Total Sold', stats.totalSold),
          qty('Total Returned', stats.totalReturned),
          qty('Total Purchased', stats.totalPurchased),
          qty('Delivered (Order)', stats.totalDelivered),
        ],
      ),
      _moversSection(
        title: 'Top Inflow Items',
        rows: ItemHistorySummaryBuilder.getTopInflowItems(allRows),
        inflow: true,
      ),
      _moversSection(
        title: 'Top Outflow Items',
        rows: ItemHistorySummaryBuilder.getTopOutflowItems(allRows),
        inflow: false,
      ),
      itemStockMovementsSection(
        rows: rows,
        f: f,
        manageProductions: manageProductions,
        departmentsEnabled: departmentsEnabled,
        categoryNames: categoryNames,
        departmentNames: departmentNames,
        sizeLabels: sizeLabels,
      ),
    ],
  );
}
