// Export spec of the Items Report Analysis page: its headline figures
// and the tables under them (best / least performers, category and
// department distribution, newly created items). Charts aren't
// exported. Every input is the screen's own builder output.

import 'package:flutter/material.dart' show DateTimeRange;
import 'package:stockall/pages/report/components/export/report_export_format.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/items_report_/items_report_analysis/class/items_report_analysis_logic.dart';
import 'package:stockall/pages/report/items_report_/items_report_main/class/items_report_export_spec.dart'
    show itemsExportQuantityText;
import 'package:stockall/pages/report/items_report_/items_report_main/class/items_report_main_logic.dart';

const String _restricted = 'Restricted';

/// "Today", "This Month", or the custom range as the screen shows it.
String itemsAnalysisPeriodLabel(
  ItemAnalysisPeriod period,
  DateTimeRange? customRange,
  ExportFormatter f,
) {
  if (period == ItemAnalysisPeriod.custom && customRange != null) {
    return '${f.date(customRange.start)} - ${f.date(customRange.end)}';
  }
  return period.label;
}

Map<T, int> _ranks<T extends Object>(List<T> rows) {
  final out = Map<T, int>.identity();
  for (var i = 0; i < rows.length; i++) {
    out[rows[i]] = i + 1;
  }
  return out;
}

ExportTableSection<ItemPerformanceRecord> _performers({
  required String title,
  required List<ItemPerformanceRecord> rows,
  required ItemPerformanceMetric metric,
  required ExportFormatter f,
}) {
  final rank = _ranks(rows);
  final money = metric != ItemPerformanceMetric.unitsSold;
  return ExportTableSection<ItemPerformanceRecord>(
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
      ExportColumn(id: 'name', label: 'Item Name', value: (r) => r.name, width: 2.5),
      ExportColumn(id: 'unit', label: 'Unit', value: (r) => r.primaryUnit),
      ExportColumn(
        id: 'sell',
        label: 'Selling Price',
        format: ExportFormat.money,
        value: (r) => r.sellingPrice,
        width: 1.3,
      ),
      ExportColumn(
        id: 'value',
        label: metric.label,
        format: money ? ExportFormat.money : ExportFormat.quantity,
        value: (r) => r.valueForMetric(metric),
        display: (r) => r.formattedMetricValue(
          metric: metric,
          formatMoney: f.money,
        ).trim(),
        width: 1.4,
      ),
      ExportColumn(
        id: 'sold',
        label: 'Units Sold',
        format: ExportFormat.quantity,
        value: (r) => r.unitsSold,
      ),
    ],
    // 58mm: 15 / 16 characters, 80mm: 5 / 20 / 22, so amounts such as
    // "₦1,250,000.00" stay on one line.
    roll: const RollLayout(
      cols58: ['name', 'value'],
      cols80: ['rank', 'name', 'value'],
      flex58: [1, 1],
      flex80: [1, 4, 4],
    ),
    emptyMessage: 'No items available to rank.',
  );
}

class _Share {
  final String name;
  final int count;
  final double percentage;
  const _Share(this.name, this.count, this.percentage);
}

ExportTableSection<_Share> _distribution({
  required String title,
  required String label,
  required List<_Share> rows,
  required String emptyMessage,
}) {
  return ExportTableSection<_Share>(
    title: title,
    rows: rows,
    columns: [
      ExportColumn(id: 'name', label: label, value: (r) => r.name, width: 2.5),
      ExportColumn(
        id: 'items',
        label: 'Items',
        format: ExportFormat.integer,
        value: (r) => r.count,
      ),
      ExportColumn(
        id: 'share',
        label: 'Proportion',
        format: ExportFormat.percent,
        value: (r) => r.percentage,
      ),
    ],
    roll: const RollLayout(
      cols58: ['name', 'items'],
      cols80: ['name', 'items', 'share'],
      flex58: [3, 1],
      flex80: [4, 1, 1],
    ),
    emptyMessage: emptyMessage,
  );
}

/// The stock text of a newly created item, as on screen: "12 Pcs",
/// "3 Sheets (4 x 2)", "Unmanaged" or "Out of Stock".
String itemsAnalysisStockText(ItemsReportRow r, ExportFormatter f) {
  if (!r.isManaged) return 'Unmanaged';
  if (r.stockLevel == StockLevelFilter.inStock ||
      r.stockLevel == StockLevelFilter.lowStock) {
    return itemsExportQuantityText(r, f);
  }
  return 'Out of Stock';
}

ExportTableSection<ItemsReportRow> _newItems(
  List<ItemsReportRow> rows,
  ExportFormatter f,
) {
  return ExportTableSection<ItemsReportRow>(
    title: 'Newly Created Items',
    rows: rows,
    columns: [
      ExportColumn(id: 'name', label: 'Item Name', value: (r) => r.name, width: 2.5),
      ExportColumn(
        id: 'created',
        label: 'Created Date',
        format: ExportFormat.date,
        value: (r) => r.createdAt,
        display: (r) =>
            r.createdAt == null ? 'Date not set' : f.date(r.createdAt!),
        width: 1.3,
      ),
      ExportColumn(
        id: 'stock',
        label: 'Stock',
        format: ExportFormat.quantity,
        value: (r) => r.isManaged &&
                (r.stockLevel == StockLevelFilter.inStock ||
                    r.stockLevel == StockLevelFilter.lowStock)
            ? r.quantity
            : null,
        display: (r) => itemsAnalysisStockText(r, f),
        width: 1.4,
      ),
    ],
    roll: const RollLayout(
      cols58: ['name', 'stock'],
      cols80: ['name', 'created', 'stock'],
      flex58: [1, 1],
      flex80: [4, 3, 4],
    ),
    emptyMessage: 'No items created within the past week.',
  );
}

ReportExportSpec itemsAnalysisExportSpec({
  required ItemsReportAnalysisSummary summary,
  required List<ItemPerformanceRecord> best3,
  required List<ItemPerformanceRecord> least3,
  required ItemPerformanceMetric metric,
  required List<CategoryDistributionItem> categoryDist,
  required List<DepartmentDistributionItem> departmentDist,
  required List<ItemsReportRow> recentItems,
  required String periodLabel,
  required String currency,
  required bool canSeeCost,
  required bool departmentsEnabled,
  DateTimeRange? range,
}) {
  final f = ExportFormatter(currency: currency);
  ExportMetric count(String label, int v) =>
      ExportMetric(label: label, value: v, format: ExportFormat.integer);

  return ReportExportSpec(
    reportName: 'Items Report Analysis',
    fileSlug: 'items_analysis',
    period: ExportPeriod(
      label: periodLabel,
      start: range?.start,
      end: range?.end,
    ),
    filters: [ExportFilter('Performance metric', metric.label)],
    sections: [
      ExportSummarySection(
        title: 'Inventory Summary',
        metrics: [
          ExportMetric(
            label: 'Stock Selling Value',
            value: summary.totalStockSellingValue,
            note: 'Total Catalog Worth',
          ),
          canSeeCost
              ? ExportMetric(
                  label: 'Stock Cost Value',
                  value: summary.totalStockCostValue,
                  note: 'Total Inventory Cost',
                )
              : const ExportMetric(
                  label: 'Stock Cost Value',
                  value: _restricted,
                  format: ExportFormat.text,
                  note: 'Permission Required',
                ),
          canSeeCost
              ? ExportMetric(
                  label: 'Potential Profit',
                  value: summary.totalPotentialProfit,
                  note: 'Margin ${f.percent(summary.overallMargin)}',
                )
              : const ExportMetric(
                  label: 'Potential Profit',
                  value: _restricted,
                  format: ExportFormat.text,
                  note: 'Permission Required',
                ),
          ExportMetric(
            label: 'Available Stock Items',
            value: summary.totalDistinctItems,
            format: ExportFormat.integer,
            note:
                '${summary.managedCount} Managed • ${summary.unmanagedCount} Unmanaged',
          ),
        ],
      ),
      ExportSummarySection(
        title: 'Stock Classification',
        metrics: [
          count('In Stock', summary.inStockCount),
          count('Low in Stock', summary.lowStockCount),
          count('Out of Stock', summary.outOfStockCount),
          count('Managed', summary.managedCount),
          count('Un-Managed', summary.unmanagedCount),
        ],
      ),
      _performers(
        title: 'Best 3 Performing Items',
        rows: best3,
        metric: metric,
        f: f,
      ),
      _performers(
        title: 'Least 3 Performing Items',
        rows: least3,
        metric: metric,
        f: f,
      ),
      _distribution(
        title: 'Category Distribution',
        label: 'Category',
        rows: [
          for (final c in categoryDist)
            _Share(c.categoryName, c.itemCount, c.percentage),
        ],
        emptyMessage: 'No categories available.',
      ),
      if (departmentsEnabled)
        _distribution(
          title: 'Department Distribution',
          label: 'Department',
          rows: [
            for (final d in departmentDist)
              _Share(d.departmentName, d.itemCount, d.percentage),
          ],
          emptyMessage: 'No departments available.',
        ),
      _newItems(recentItems, f),
    ],
  );
}
