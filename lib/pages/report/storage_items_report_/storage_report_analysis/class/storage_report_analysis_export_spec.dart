// Export spec of the Storage Report Analysis page: its KPI cards, stock
// status, the most / least active items for the chosen metric, the
// distribution tables and the newly created items, as the screen shows
// them. Charts aren't exported; no splits.

import 'package:flutter/material.dart' show DateTimeRange;
import 'package:stockall/pages/report/components/export/report_export_format.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/storage_items_report_/storage_item_history_summary/class/storage_item_history_summary_export_spec.dart'
    show storageHistoryPeriodLabel;
import 'package:stockall/pages/report/storage_items_report_/storage_item_history_summary/class/storage_item_history_summary_logic.dart';
import 'package:stockall/pages/report/storage_items_report_/storage_report_analysis/class/storage_report_analysis_logic.dart';
import 'package:stockall/pages/report/storage_items_report_/storage_report_main/class/storage_report_export_spec.dart'
    show storageUnitLabel;
import 'package:stockall/pages/report/storage_items_report_/storage_report_main/class/storage_report_main_logic.dart';

const String _dash = '—';

/// The notes the analysis shows in its cards: the idle-items line of
/// the performance card and, with the Department distribution, its
/// footnote. The view draws these and the export carries them.
String storageAnalysisIdleNote(
  List<StoragePerformanceRecord> records,
  List<StoragePerformanceRecord> idle,
) => records.isEmpty
    ? 'No storage items yet.'
    : '${idle.length} of ${records.length} storage item${records.length == 1 ? '' : 's'} '
        'had no stock movement in this period. '
        'Quantities are in each item\'s primary unit.';

const String storageAnalysisDepartmentFootnote =
    'A storage item that supplies several departments counts in each, so '
    'shares can add up to more than 100%.';

List<String> storageAnalysisNotes({
  required List<StoragePerformanceRecord> records,
  required List<StoragePerformanceRecord> idle,
  required bool departmentsShown,
}) => [
  storageAnalysisIdleNote(records, idle),
  if (departmentsShown) storageAnalysisDepartmentFootnote,
];

/// "3 Sheets (4 x 2)" / "Out of Stock", as the Newly Created list shows
/// stock.
String storageStockText(StorageReportRow r, ExportFormatter f) {
  final q = r.quantity ?? 0;
  if (q <= 0) return 'Out of Stock';
  return '${f.quantity(q)} ${storageUnitLabel(r)}';
}

ExportTableSection<StoragePerformanceRecord> _ranking(
  String title,
  List<StoragePerformanceRecord> rows,
  StoragePerformanceMetric metric,
  ExportFormatter f,
) {
  final rank = Map<StoragePerformanceRecord, int>.identity();
  for (var i = 0; i < rows.length; i++) {
    rank[rows[i]] = i + 1;
  }
  return ExportTableSection<StoragePerformanceRecord>(
    title: '$title (${metric.label})',
    rows: rows,
    columns: [
      ExportColumn(
        id: 'rank',
        label: 'Rank',
        format: ExportFormat.integer,
        value: (r) => rank[r],
        width: 0.5,
      ),
      ExportColumn(id: 'name', label: 'Storage Item', value: (r) => r.name, width: 2),
      ExportColumn(
        id: 'inStorage',
        label: 'In storage',
        format: ExportFormat.quantity,
        value: (r) => r.currentQuantity,
        display: (r) => r.currentQuantity == null
            ? _dash
            : '${f.quantity(r.currentQuantity!)} ${r.primaryUnit}',
        width: 1.3,
      ),
      ExportColumn(
        id: 'value',
        label: metric.label,
        format: ExportFormat.quantity,
        value: (r) => r.valueForMetric(metric),
        display: (r) => r.formattedMetricValue(metric),
        width: 1.3,
      ),
    ],
    roll: const RollLayout(
      cols58: ['name', 'value'],
      cols80: ['rank', 'name', 'value'],
      flex58: [1, 1],
      flex80: [1, 4, 4],
    ),
    emptyMessage: 'No storage items',
  );
}

ExportTableSection<StorageDistributionItem> _distribution(
  String title,
  String label,
  List<StorageDistributionItem> rows,
  ExportFormatter f,
) {
  return ExportTableSection<StorageDistributionItem>(
    title: title,
    rows: rows,
    columns: [
      ExportColumn(
        id: 'no',
        label: 'No.',
        format: ExportFormat.integer,
        value: (d) => d.index,
        width: 0.5,
      ),
      ExportColumn(id: 'name', label: label, value: (d) => d.label, width: 2),
      ExportColumn(
        id: 'items',
        label: 'Items',
        format: ExportFormat.integer,
        value: (d) => d.itemCount,
        width: 0.7,
      ),
      // One decimal, as the screen shows it.
      ExportColumn(
        id: 'share',
        label: 'Share',
        format: ExportFormat.percent,
        value: (d) => d.percentage,
        display: (d) => '${d.percentage.toStringAsFixed(1)}%',
        width: 0.8,
      ),
    ],
    roll: const RollLayout(
      cols58: ['name', 'items'],
      cols80: ['name', 'items', 'share'],
      flex58: [3, 1],
      flex80: [4, 1, 1],
    ),
    emptyMessage: 'No storage items',
  );
}

/// Every input is the screen's own (`StorageReportAnalysisBuilder`).
ReportExportSpec storageAnalysisExportSpec({
  required StorageReportAnalysisSummary summary,
  required List<StoragePerformanceRecord> records,
  required List<StoragePerformanceRecord> best3,
  required List<StoragePerformanceRecord> least3,
  required List<StoragePerformanceRecord> idle,
  required StoragePerformanceMetric metric,
  required List<StorageDistributionItem> departmentDist,
  required List<StorageDistributionItem> typeDist,
  required List<StorageReportRow> recentItems,
  required StorageHistoryPeriod period,
  required DateTimeRange? customRange,
  required DateTimeRange resolvedRange,
  required bool canSeeCost,
  required bool departmentsEnabled,
  required String currency,
}) {
  final f = ExportFormatter(currency: currency);
  final s = summary;
  final total = s.totalDistinctItems;
  String pct(int n) => '${(total > 0 ? n / total * 100 : 0.0).toStringAsFixed(0)}%';
  ExportMetric count(String label, int v, {String? note}) => ExportMetric(
    label: label,
    value: v,
    format: ExportFormat.integer,
    note: note,
  );
  ExportMetric text(String label, String v, {String? note}) =>
      ExportMetric(label: label, value: v, format: ExportFormat.text, note: note);
  final noCost = s.itemsWithoutCostCount;

  return ReportExportSpec(
    reportName: 'Storage Analysis',
    fileSlug: 'storage_analysis',
    period: ExportPeriod(
      label: storageHistoryPeriodLabel(period, customRange),
      start: period == StorageHistoryPeriod.allTime ? null : resolvedRange.start,
      end: period == StorageHistoryPeriod.allTime ? null : resolvedRange.end,
    ),
    notes: storageAnalysisNotes(
      records: records,
      idle: idle,
      departmentsShown: departmentsEnabled,
    ),
    sections: [
      ExportSummarySection(
        title: 'Statistics',
        metrics: [
          canSeeCost
              ? ExportMetric(
                label: 'Stock Cost Value',
                value: s.totalStockCostValue,
                note: noCost > 0
                    ? '$noCost item${noCost == 1 ? ' has' : 's have'} no cost price'
                    : 'Total Storage Cost',
              )
              : text('Stock Cost Value', 'Restricted', note: 'Permission Required'),
          text(
            'Storage Items',
            '${f.integer(total)} Items',
            note: '${s.oneDimensionalCount} Simple • ${s.twoDimensionalCount} 2-Dimensional',
          ),
          text(
            'Linked To Sales Items',
            '${s.linkedCount} of $total',
            note: '${s.linkedSalesItemsCount} Sales Item'
                '${s.linkedSalesItemsCount == 1 ? '' : 's'} Supplied',
          ),
          text(
            'Stock In Storage',
            s.singleUnitFormattedQuantity ?? '${s.stockByPrimaryUnit.length} Units',
            note: 'In each item\'s primary unit',
          ),
        ],
      ),
      ExportSummarySection(
        title: 'Stock Status',
        metrics: [
          count('In Stock', s.inStockCount, note: pct(s.inStockCount)),
          count('Out of Stock', s.outOfStockCount, note: pct(s.outOfStockCount)),
          count('Simple', s.oneDimensionalCount),
          count('2-Dimensional', s.twoDimensionalCount),
        ],
      ),
      _ranking('Most Active 3', best3, metric, f),
      _ranking('Least Active 3', least3, metric, f),
      if (departmentsEnabled)
        _distribution('Department Distribution', 'Department', departmentDist, f),
      _distribution('Quantity Type Distribution', 'Quantity Type', typeDist, f),
      ExportTableSection<StorageReportRow>(
        title: 'Newly Created Items',
        rows: recentItems,
        columns: [
          ExportColumn(id: 'name', label: 'Storage Item', value: (r) => r.name, width: 2),
          ExportColumn(
            id: 'created',
            label: 'Created',
            format: ExportFormat.date,
            value: (r) => r.createdAt,
            display: (r) => r.createdAt == null ? 'Date not set' : f.date(r.createdAt!),
          ),
          ExportColumn(id: 'type', label: 'Quantity Type', value: (r) => r.quantityTypeLabel),
          ExportColumn(
            id: 'stock',
            label: 'Stock',
            format: ExportFormat.quantity,
            value: (r) => r.quantity,
            display: (r) => storageStockText(r, f),
            width: 1.4,
          ),
        ],
        // 58mm: 15 / 16 characters, 80mm: 15 / 15 / 18, so
        // "3 Sheets (4 x 2)" stays on one line.
        roll: const RollLayout(
          cols58: ['name', 'stock'],
          cols80: ['name', 'created', 'stock'],
          flex58: [1, 1],
          flex80: [5, 5, 6],
        ),
        emptyMessage: 'No storage items created yet',
      ),
    ],
  );
}
