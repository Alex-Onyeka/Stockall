import 'package:stockall/pages/report/components/export/report_export_format.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/purchase_report/purchase_item_analysis/class/purchase_item_analysis_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/components/receipts_report_filter_widgets.dart'
    show receiptsPeriodLabel;

ReportExportSpec buildPurchaseItemAnalysisExportSpec({
  required PurchaseItemAnalysisResult result,
  required PurchaseItemAnalysisTab tab,
  required List<PurchaseItemBreakdownRow> rows,
  required ReceiptsReportPeriod period,
  required ExportFormatter f,
}) {
  final s = result.stats;
  return ReportExportSpec(
    reportName: 'Purchase Item Analysis — ${tab.label}',
    fileSlug: 'purchase_item_analysis_${tab.name}',
    period: ExportPeriod(
      label: receiptsPeriodLabel(period),
      start: period.start,
      end: period.end,
    ),
    sections: [
      ExportSummarySection(
        title: 'Summary',
        metrics: [
          ExportMetric(
            label: 'Lines',
            value: s.lineCount,
            format: ExportFormat.integer,
          ),
          ExportMetric(
            label: 'Distinct Items',
            value: s.distinctItems,
            format: ExportFormat.integer,
          ),
          ExportMetric(
            label: 'Purchases',
            value: s.purchaseCount,
            format: ExportFormat.integer,
          ),
          ExportMetric(
            label: 'Total Qty',
            value: s.totalQuantity,
            format: ExportFormat.quantity,
          ),
          ExportMetric(
            label: 'Total Spend',
            value: s.totalSpend,
            format: ExportFormat.money,
          ),
          ExportMetric(
            label: 'Avg Unit Cost',
            value: s.averageUnitCost,
            format: ExportFormat.money,
          ),
        ],
      ),
      ExportTableSection<PurchaseItemBreakdownRow>(
        title: 'Breakdown by ${tab.label}',
        rows: rows,
        columns: [
          ExportColumn(
            id: 'name',
            label: tab.label,
            value: (r) => r.label,
            width: 1.8,
          ),
          ExportColumn(
            id: 'lines',
            label: 'Lines',
            format: ExportFormat.integer,
            value: (r) => r.lineCount,
          ),
          ExportColumn(
            id: 'purchases',
            label: 'Purchases',
            format: ExportFormat.integer,
            value: (r) => r.purchaseCount,
          ),
          ExportColumn(
            id: 'qty',
            label: 'Qty',
            format: ExportFormat.quantity,
            value: (r) => r.quantity,
          ),
          ExportColumn(
            id: 'avgCost',
            label: 'Avg Unit Cost',
            format: ExportFormat.money,
            value: (r) => r.averageUnitCost,
          ),
          ExportColumn(
            id: 'spend',
            label: 'Total Spend',
            format: ExportFormat.money,
            value: (r) => r.spend,
          ),
          ExportColumn(
            id: 'share',
            label: 'Share',
            format: ExportFormat.percent,
            value: (r) => r.spendShare ?? 0,
          ),
        ],
        totalsFor: (rs) {
          int lines = 0;
          double qty = 0;
          double spend = 0;
          for (final r in rs) {
            lines += r.lineCount;
            qty += r.quantity;
            spend += r.spend;
          }
          return {
            'name': '${f.integer(rs.length)} groups',
            'lines': lines,
            'qty': qty,
            'spend': spend,
          };
        },
        roll: const RollLayout(
          cols58: ['name', 'spend'],
          cols80: ['name', 'qty', 'spend'],
          flex58: [2, 1],
          flex80: [3, 1, 2],
        ),
        emptyMessage: 'No purchase item analysis data for this period.',
      ),
    ],
  );
}
