// Export spec of the Supplier Analysis page: contact details, the KPI
// cards, the top items and the recent purchases the screen shows, with
// its notes. Charts aren't exported.

import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/class/purchase_report_export_spec.dart'
    show purchaseReportNotes;
import 'package:stockall/pages/report/purchase_report/purchase_report_table/class/purchase_report_table_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/components/receipts_report_filter_widgets.dart'
    show receiptsPeriodLabel;
import 'package:stockall/pages/report/supplier_report/supplier_analysis/class/supplier_analysis_logic.dart';
import 'package:stockall/pages/report/supplier_report/supplier_report_table/class/supplier_report_table_logic.dart';

const String _dash = '—';

String _count(int n, String noun) => '$n $noun${n == 1 ? '' : 's'}';

/// The Top Items card's footnotes. The card draws these and the export
/// carries them, so they always match.
List<String> supplierTopItemsFootnotes(SupplierAnalysisResult r) => [
  if (r.purchasesWithoutLines > 0)
    '${_count(r.purchasesWithoutLines, 'purchase')} without item details',
  if (r.adjustedPurchases > 0)
    'Some purchases have a custom total, so item spend can differ from '
        'total spend.',
];

ReportExportSpec supplierAnalysisExportSpec({
  required SupplierAnalysisResult result,
  required ReceiptsReportPeriod period,
}) {
  final s = result.supplier;
  final items = result.topItems;
  final rank = Map<SupplierTopItem, int>.identity();
  for (var i = 0; i < items.length; i++) {
    rank[items[i]] = i + 1;
  }
  final recent = result.recent;

  ExportMetric text(String label, String? v) =>
      ExportMetric(label: label, value: v ?? _dash, format: ExportFormat.text);
  ExportMetric date(String label, DateTime? v, String note) => ExportMetric(
    label: label,
    value: v ?? _dash,
    format: v == null ? ExportFormat.text : ExportFormat.date,
    note: note,
  );

  return ReportExportSpec(
    reportName: 'Supplier Analysis',
    fileSlug: 'supplier_analysis',
    period: ExportPeriod(
      label: receiptsPeriodLabel(period),
      start: period.start,
      end: period.end,
    ),
    filters: [ExportFilter('Supplier', result.title)],
    notes: [
      ...purchaseReportNotes(period: period),
      ...supplierTopItemsFootnotes(result),
    ],
    sections: [
      ExportSummarySection(
        title: 'Contact Details',
        metrics: [
          text('Phone', s.phone),
          text('Email', s.email),
          text('Address', s.fullAddress),
          if (s.isDeleted) text('Status', supplierDeletedLabel),
        ],
      ),
      ExportSummarySection(
        title: 'Statistics',
        metrics: [
          ExportMetric(
            label: 'Purchases',
            value: s.purchaseCount,
            format: ExportFormat.integer,
            note: 'Purchases in this period',
          ),
          ExportMetric(label: 'Total Spend', value: s.spend, note: 'Total of the purchases'),
          ExportMetric(label: 'Total Paid', value: s.paid, note: 'Paid to this supplier'),
          ExportMetric(
            label: 'Balance Owed',
            value: s.balance,
            note: 'Still owed to this supplier',
          ),
          ExportMetric(
            label: 'Average Purchase',
            value: s.average,
            note: 'Spend per purchase',
          ),
          date('First Purchase', s.firstPurchase, 'Earliest in this period'),
          date('Last Purchase', s.lastPurchase, 'Latest in this period'),
        ],
      ),
      ExportTableSection<SupplierTopItem>(
        title: 'Top Items',
        rows: items,
        columns: [
          ExportColumn(
            id: 'no',
            label: 'No.',
            format: ExportFormat.integer,
            value: (i) => rank[i],
            width: 0.5,
          ),
          ExportColumn(id: 'name', label: 'Item', value: (i) => i.name, width: 2),
          ExportColumn(
            id: 'purchases',
            label: 'Purchases',
            format: ExportFormat.integer,
            value: (i) => i.purchaseCount,
            width: 0.8,
          ),
          ExportColumn(
            id: 'items',
            label: 'Items',
            format: ExportFormat.quantity,
            value: (i) => i.items,
            width: 0.8,
          ),
          ExportColumn(
            id: 'spend',
            label: 'Spend',
            format: ExportFormat.money,
            value: (i) => i.spend,
            width: 1.2,
          ),
        ],
        roll: const RollLayout(
          cols58: ['name', 'spend'],
          cols80: ['no', 'name', 'spend'],
          flex58: [1, 1],
          flex80: [1, 4, 4],
        ),
        emptyMessage: 'No items in this period.',
      ),
      ExportTableSection<PurchaseReportRow>(
        title: result.rows.isEmpty
            ? 'Recent Purchases'
            : 'Recent Purchases (${recent.length} of '
                '${_count(result.rows.length, 'purchase')} in this period)',
        rows: recent,
        columns: [
          ExportColumn(id: 'id', label: 'ID', value: (p) => p.displayId, width: 1.4),
          ExportColumn(
            id: 'date',
            label: 'Date',
            format: ExportFormat.dateTime,
            value: (p) => p.createdAt,
            width: 1.6,
          ),
          ExportColumn(id: 'status', label: 'Status', value: (p) => p.status.label),
          ExportColumn(
            id: 'total',
            label: 'Total',
            format: ExportFormat.money,
            value: (p) => p.total,
            width: 1.2,
          ),
        ],
        // 58mm: 15 / 16 characters, 80mm: 15 / 15 / 16; the date goes
        // on the sub-line.
        roll: const RollLayout(
          cols58: ['id', 'total'],
          cols80: ['id', 'status', 'total'],
          sub58: ['date'],
          sub80: ['date'],
          flex58: [1, 1],
          flex80: [1, 1, 1],
        ),
        emptyMessage: 'No purchases in this period',
      ),
    ],
  );
}
