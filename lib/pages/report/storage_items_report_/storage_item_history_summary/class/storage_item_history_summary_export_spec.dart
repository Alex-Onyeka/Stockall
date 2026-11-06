// Export spec of the Storage Item History Summary: its headline and
// movement-category cards, the movement leaders, the breakdowns (top 5
// of each, as on screen) and the full filtered, sorted item table. The
// donut isn't exported. Quantities stay in each item's primary unit and
// are never added across units, so the only totals are counts. No
// splits: the screen has no Department filter.

import 'package:flutter/material.dart' show DateTimeRange;
import 'package:stockall/classes/temp_storage_product/temp_storage_products.dart';
import 'package:stockall/constants/calculations.dart' show formatDateTime, formatLargeNumberDouble;
import 'package:stockall/pages/report/components/export/report_export_format.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/storage_items_report_/storage_item_history_report/class/storage_item_history_export_spec.dart'
    show storageHistoryNotes;
import 'package:stockall/pages/report/storage_items_report_/storage_item_history_summary/class/storage_item_history_summary_logic.dart';
import 'package:stockall/pages/report/storage_items_report_/storage_report_main/class/storage_report_export_spec.dart'
    show storageSizeLabel;

const String _dash = '—';

/// The notes the summary shows under its header. The view draws these
/// and the export carries them, so they always match.
List<String> storageHistorySummaryNotes({
  required StorageHistoryPeriod period,
  required StorageHistorySummaryStats stats,
}) {
  final n = stats.notNormalisedCount;
  return [
    'Quantities are in each storage item\'s primary unit and are never '
        'added across units.',
    if (n > 0)
      '$n record${n == 1 ? '' : 's'} could not be converted to the item\'s '
          'primary unit and ${n == 1 ? 'is' : 'are'} left out of the quantities.',
    ...storageHistoryNotes(allTime: period == StorageHistoryPeriod.allTime),
  ];
}

/// "+5 Bags, -2 Sheets", as the Net Change card shows it.
String storageSignedQuantitiesByUnit(Map<String, double> m) {
  final entries = m.entries.where((e) => e.value != 0).toList()
    ..sort((a, b) => a.key.toLowerCase().compareTo(b.key.toLowerCase()));
  if (entries.isEmpty) return '0';
  return entries
      .map((e) => '${e.value > 0 ? '+' : ''}${formatLargeNumberDouble(e.value)} ${e.key}')
      .join(', ');
}

/// The period selector's text.
String storageHistoryPeriodLabel(StorageHistoryPeriod period, DateTimeRange? custom) {
  if (period == StorageHistoryPeriod.custom && custom != null) {
    return '${formatDateTime(custom.start)} - ${formatDateTime(custom.end)}';
  }
  return period.label;
}

const Map<StorageHistorySummarySortField, String> storageSummarySortLabels = {
  StorageHistorySummarySortField.rowIndex: 'No.',
  StorageHistorySummarySortField.itemName: 'Storage Item',
  StorageHistorySummarySortField.primaryUnit: 'Primary Unit',
  StorageHistorySummarySortField.openingStock: 'Opening Stock',
  StorageHistorySummarySortField.closingStock: 'Closing Stock',
  StorageHistorySummarySortField.currentQuantity: 'Current Quantity',
  StorageHistorySummarySortField.transferredOut: 'Transferred Out',
  StorageHistorySummarySortField.returned: 'Returned',
  StorageHistorySummarySortField.stockedIn: 'Stocked In',
  StorageHistorySummarySortField.purchased: 'Purchased',
  StorageHistorySummarySortField.purchaseDeleted: 'Purchase Deleted',
  StorageHistorySummarySortField.adjustedUp: 'Adjusted Up',
  StorageHistorySummarySortField.adjustedDown: 'Adjusted Down',
  StorageHistorySummarySortField.totalAdditions: 'Total In',
  StorageHistorySummarySortField.totalReductions: 'Total Out',
  StorageHistorySummarySortField.netQuantityChange: 'Net Change',
  StorageHistorySummarySortField.movementCount: 'Movements',
};

/// Item uuid → " (4 x 2)" for every 2D sheet storage item with a size.
Map<String, String> storageSizeLabels(List<TempStorageProducts> products) {
  final out = <String, String>{};
  for (final p in products) {
    final id = p.uuid;
    if (id == null || id.isEmpty) continue;
    final size = storageSizeLabel(p);
    if (size != null && size.isNotEmpty) out[id] = size;
  }
  return out;
}

ExportTableSection<StorageHistorySummaryRow> storageSummaryItemSection({
  required List<StorageHistorySummaryRow> rows,
  required ExportFormatter f,
  Map<String, String> sizeLabels = const {},
}) {
  final number = Map<StorageHistorySummaryRow, int>.identity();
  for (var i = 0; i < rows.length; i++) {
    number[rows[i]] = i + 1;
  }
  String unit(StorageHistorySummaryRow r) => '${r.primaryUnit}${sizeLabels[r.uuid] ?? ''}';
  String text(StorageHistorySummaryRow r, double v, [String sign = '']) =>
      '$sign${f.quantity(v)} ${unit(r)}';

  ExportColumn<StorageHistorySummaryRow> balance(
    String id,
    String label,
    double? Function(StorageHistorySummaryRow) pick,
  ) => ExportColumn(
    id: id,
    label: label,
    format: ExportFormat.quantity,
    value: pick,
    display: (r) {
      final v = pick(r);
      return v == null ? _dash : text(r, v);
    },
    width: 1.2,
  );

  // A movement: "+5 Bags" / "-5 Bags", "—" when 0. Excel stores the
  // signed number.
  ExportColumn<StorageHistorySummaryRow> movement(
    String id,
    String label,
    double Function(StorageHistorySummaryRow) pick, {
    required bool inflow,
  }) => ExportColumn(
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
      return text(r, v, inflow ? '+' : '-');
    },
  );

  return ExportTableSection<StorageHistorySummaryRow>(
    title: 'Storage Item Summary',
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
        label: 'Storage Item',
        value: (r) {
          if (!r.exists) return '${r.name} (Deleted storage item)';
          if (r.currentName != null) return '${r.name} (now: ${r.currentName})';
          return r.name;
        },
        width: 2,
      ),
      ExportColumn(id: 'unit', label: 'Primary Unit', value: unit, inPdf: false),
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
          return text(r, v, v > 0 ? '+' : '');
        },
        width: 1.2,
      ),
      movement('transferredOut', 'Transferred Out', (r) => r.transferredOut, inflow: false),
      movement('returned', 'Returned', (r) => r.returned, inflow: true),
      movement('stockedIn', 'Stocked In', (r) => r.stockedIn, inflow: true),
      movement('purchased', 'Purchased', (r) => r.purchased, inflow: true),
      movement('purchaseDeleted', 'Purchase Deleted', (r) => r.purchaseDeleted, inflow: false),
      movement('adjustedUp', 'Adjusted Up', (r) => r.adjustedUp, inflow: true),
      movement('adjustedDown', 'Adjusted Down', (r) => r.adjustedDown, inflow: false),
      movement('totalIn', 'Total In', (r) => r.totalAdditions, inflow: true),
      movement('totalOut', 'Total Out', (r) => r.totalReductions, inflow: false),
      ExportColumn(
        id: 'movements',
        label: 'Movements',
        format: ExportFormat.integer,
        value: (r) => r.movementCount,
        width: 0.8,
      ),
    ],
    // Export-only totals: counts. Quantities are in each item's own unit,
    // so they aren't summed.
    totalsFor: (rs) => {
      'name': '${f.integer(rs.length)} ${rs.length == 1 ? 'item' : 'items'}',
      'movements': rs.fold<int>(0, (s, r) => s + r.movementCount),
    },
    // As the Items history summary: 58mm 15 / 16 characters, 80mm
    // 12 / 16 / 18, so "3 Sheets (4 x 2)" stays on one line.
    roll: const RollLayout(
      cols58: ['name', 'closing'],
      cols80: ['name', 'opening', 'closing'],
      flex58: [1, 1],
      flex80: [4, 5, 5],
    ),
    emptyMessage: 'No storage items match the selected filters.',
  );
}

ExportTableSection<StorageHistorySummaryRow> _moversSection({
  required String title,
  required List<StorageHistorySummaryRow> rows,
  required bool inflow,
}) {
  final rank = Map<StorageHistorySummaryRow, int>.identity();
  for (var i = 0; i < rows.length; i++) {
    rank[rows[i]] = i + 1;
  }
  return ExportTableSection<StorageHistorySummaryRow>(
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
      ExportColumn(id: 'name', label: 'Storage Item', value: (r) => r.name, width: 2.5),
      ExportColumn(id: 'unit', label: 'Primary Unit', value: (r) => r.primaryUnit),
      ExportColumn(
        id: 'value',
        label: inflow ? 'Stock Additions' : 'Stock Reductions',
        format: ExportFormat.quantity,
        value: (r) => inflow ? r.totalAdditions : -r.totalReductions,
        display: (r) => '${inflow ? '+' : '-'}'
            '${r.quantityText(inflow ? r.totalAdditions : r.totalReductions)}',
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

ExportTableSection<StorageHistoryBreakdownEntry> _breakdownSection({
  required String title,
  required List<StorageHistoryBreakdownEntry> entries,
  bool showInflow = true,
  bool showOutflow = true,
}) {
  final top = entries.take(5).toList();
  final rank = Map<StorageHistoryBreakdownEntry, int>.identity();
  for (var i = 0; i < top.length; i++) {
    rank[top[i]] = i + 1;
  }
  return ExportTableSection<StorageHistoryBreakdownEntry>(
    title: title,
    rows: top,
    columns: [
      ExportColumn(
        id: 'rank',
        label: 'Rank',
        format: ExportFormat.integer,
        value: (e) => rank[e],
        width: 0.5,
      ),
      ExportColumn(id: 'name', label: 'Name', value: (e) => e.label, width: 2),
      ExportColumn(
        id: 'records',
        label: 'Records',
        format: ExportFormat.integer,
        value: (e) => e.count,
        width: 0.7,
      ),
      if (showInflow)
        ExportColumn(
          id: 'in',
          label: 'In',
          value: (e) => e.inflow.isEmpty ? _dash : formatQuantitiesByUnit(e.inflow),
          width: 1.5,
        ),
      if (showOutflow)
        ExportColumn(
          id: 'out',
          label: 'Out',
          value: (e) => e.outflow.isEmpty ? _dash : formatQuantitiesByUnit(e.outflow),
          width: 1.5,
        ),
    ],
    roll: RollLayout(
      cols58: ['name', showOutflow ? 'out' : 'in'],
      cols80: ['name', 'records', showOutflow ? 'out' : 'in'],
      flex58: const [1, 1],
      flex80: const [3, 1, 3],
    ),
    emptyMessage: 'Nothing recorded',
  );
}

/// [allRows] are every item of the period (the headline figures and
/// leaders); [rows] the filtered, sorted table.
ReportExportSpec storageHistorySummaryExportSpec({
  required StorageHistorySummaryStats stats,
  required StorageHistoryBreakdowns breakdowns,
  required List<StorageHistorySummaryRow> allRows,
  required List<StorageHistorySummaryRow> rows,
  required StorageHistorySummaryFilters filters,
  required StorageHistorySummarySortField sortField,
  required bool ascending,
  required StorageHistoryPeriod period,
  required DateTimeRange? customRange,
  required DateTimeRange resolvedRange,
  required bool departmentsEnabled,
  required String currency,
  Map<String, String> sizeLabels = const {},
}) {
  final f = ExportFormatter(currency: currency);
  final s = stats;
  ExportMetric text(String label, String value, {String? note}) =>
      ExportMetric(label: label, value: value, format: ExportFormat.text, note: note);
  String qty(StorageMovementKind k) => formatQuantitiesByUnit(s.quantityByUnit(k));
  final search = filters.search.trim();

  return ReportExportSpec(
    reportName: 'Storage History Summary',
    fileSlug: 'storage_history_summary',
    period: ExportPeriod(
      label: storageHistoryPeriodLabel(period, customRange),
      start: period == StorageHistoryPeriod.allTime ? null : resolvedRange.start,
      end: period == StorageHistoryPeriod.allTime ? null : resolvedRange.end,
    ),
    filters: [
      if (search.isNotEmpty) ExportFilter('Search', search),
      if (filters.movementFilter != StorageHistoryMovementFilter.all)
        ExportFilter('Movement', filters.movementFilter.label),
    ],
    sortedBy: '${storageSummarySortLabels[sortField] ?? sortField.name} '
        '(${ascending ? 'ascending' : 'descending'})',
    notes: storageHistorySummaryNotes(period: period, stats: stats),
    sections: [
      ExportSummarySection(
        title: 'Statistics',
        metrics: [
          text(
            'Net Change',
            storageSignedQuantitiesByUnit(s.netChangeByUnit),
            note: 'Additions minus Reductions',
          ),
          text(
            'Total Stock Additions',
            formatQuantitiesByUnit(s.additionsByUnit),
            note: 'Returns, Stock In, Purchases, Adjusted Up',
          ),
          text(
            'Total Stock Reductions',
            formatQuantitiesByUnit(s.reductionsByUnit),
            note: 'Transfers Out, Purchases Deleted, Adjusted Down',
          ),
          text(
            'Items With Movement',
            '${s.itemsWithMovementCount} of ${s.totalDistinctItems}',
            note: '${s.totalHistoryEvents} Recorded History Events',
          ),
        ],
      ),
      ExportSummarySection(
        title: 'Movement Categories',
        metrics: [
          text('Transferred Out To Sales', qty(StorageMovementKind.transferredOut)),
          text('Returned From Sales', qty(StorageMovementKind.returned)),
          text('Stocked In', qty(StorageMovementKind.stockIn)),
          text('Purchased', qty(StorageMovementKind.purchase)),
          text('Purchase Deleted', qty(StorageMovementKind.purchaseDeleted)),
          text('Restocked (Net)', formatQuantitiesByUnit(s.restockedByUnit)),
          text('Adjusted Up', qty(StorageMovementKind.adjustedUp)),
          text('Adjusted Down', qty(StorageMovementKind.adjustedDown)),
          ExportMetric(
            label: 'Items Created',
            value: s.countOf(StorageMovementKind.created),
            format: ExportFormat.integer,
          ),
          ExportMetric(
            label: 'Items Deleted',
            value: s.countOf(StorageMovementKind.deleted),
            format: ExportFormat.integer,
          ),
        ],
      ),
      _moversSection(
        title: 'Top Inflow Items',
        rows: StorageHistorySummaryBuilder.getTopInflowItems(allRows),
        inflow: true,
      ),
      _moversSection(
        title: 'Top Outflow Items',
        rows: StorageHistorySummaryBuilder.getTopOutflowItems(allRows),
        inflow: false,
      ),
      _breakdownSection(
        title: 'Sales Items Supplied',
        entries: breakdowns.salesItemsSupplied,
        showInflow: false,
      ),
      _breakdownSection(
        title: 'Sales Items Returning',
        entries: breakdowns.salesItemsReturning,
        showOutflow: false,
      ),
      if (departmentsEnabled)
        _breakdownSection(title: 'Departments', entries: breakdowns.departments),
      _breakdownSection(title: 'Storekeepers', entries: breakdowns.storekeepers),
      _breakdownSection(title: 'Other Staff', entries: breakdowns.otherStaff),
      storageSummaryItemSection(rows: rows, f: f, sizeLabels: sizeLabels),
    ],
  );
}
