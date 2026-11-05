// Export spec of the Item-Level Stock Movements page: the per-item
// movement table over the full filtered and sorted list (not the
// 100-row page), with the period, filters and sort shown on screen.

import 'package:flutter/material.dart' show DateTimeRange;
import 'package:stockall/pages/report/components/export/report_export_format.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/items_report_/item_history_summary/class/item_history_summary_export_spec.dart';
import 'package:stockall/pages/report/items_report_/item_history_summary/class/item_history_summary_logic.dart';

ReportExportSpec itemStockMovementsExportSpec({
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
  return ReportExportSpec(
    reportName: 'Item-Level Stock Movements',
    fileSlug: 'item_stock_movements',
    period: stockMovementsPeriod(period, range, f),
    filters: stockMovementsExportFilters(
      filters: filters,
      departmentsEnabled: departmentsEnabled,
      categoryNames: categoryNames,
      departmentNames: departmentNames,
    ),
    sortedBy: stockMovementsSortLabel(sortField, ascending),
    sections: [
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
