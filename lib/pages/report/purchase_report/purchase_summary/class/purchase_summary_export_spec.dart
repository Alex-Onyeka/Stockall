// Export spec of the Purchase Summary page: its statistic cards, the top
// and least suppliers and the breakdown tables (suppliers, staff,
// departments, status, channel). Charts aren't exported. Every input is
// the screen's own PurchaseSummaryResult.

import 'package:stockall/pages/report/components/export/report_export_format.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/class/purchase_report_export_spec.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/class/purchase_report_table_logic.dart';
import 'package:stockall/pages/report/purchase_report/purchase_summary/class/purchase_summary_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/components/receipts_report_filter_widgets.dart'
    show receiptsPeriodLabel;

const String _dash = '—';

ExportTableSection<PurchaseSummaryGroup> _ranking(
  String title,
  List<PurchaseSummaryGroup> groups,
) {
  final no = Map<PurchaseSummaryGroup, int>.identity();
  for (var i = 0; i < groups.length; i++) {
    no[groups[i]] = i + 1;
  }
  return ExportTableSection<PurchaseSummaryGroup>(
    title: title,
    rows: groups,
    columns: [
      ExportColumn(
        id: 'no',
        label: 'No.',
        format: ExportFormat.integer,
        value: (g) => no[g],
        width: 0.5,
      ),
      ExportColumn(id: 'name', label: 'Supplier', value: (g) => g.label, width: 2),
      ExportColumn(
        id: 'purchases',
        label: 'Purchases',
        format: ExportFormat.integer,
        value: (g) => g.purchaseCount,
        width: 0.8,
      ),
      ExportColumn(
        id: 'paid',
        label: 'Paid',
        format: ExportFormat.money,
        value: (g) => g.paid,
        width: 1.2,
      ),
      ExportColumn(
        id: 'spend',
        label: 'Spend',
        format: ExportFormat.money,
        value: (g) => g.spend,
        width: 1.2,
      ),
    ],
    roll: const RollLayout(
      cols58: ['name', 'spend'],
      cols80: ['no', 'name', 'spend'],
      flex58: [1, 1],
      flex80: [1, 4, 4],
    ),
    emptyMessage: 'No supplier in this period.',
  );
}

ExportTableSection<PurchaseBreakdownRow> _breakdown(
  PurchaseBreakdownTab tab,
  List<PurchaseBreakdownRow> rows,
  ExportFormatter f,
) {
  return ExportTableSection<PurchaseBreakdownRow>(
    title: tab.label,
    rows: rows,
    columns: [
      ExportColumn(id: 'name', label: tab.label, value: (r) => r.label, width: 2),
      ExportColumn(
        id: 'purchases',
        label: 'Purchases',
        format: ExportFormat.integer,
        value: (r) => r.count,
        width: 0.8,
      ),
      ExportColumn(
        id: 'spend',
        label: 'Spend',
        format: ExportFormat.money,
        value: (r) => r.spend,
        width: 1.2,
      ),
      ExportColumn(
        id: 'paid',
        label: 'Paid',
        format: ExportFormat.money,
        value: (r) => r.paid,
        width: 1.2,
      ),
      ExportColumn(
        id: 'balance',
        label: 'Balance',
        format: ExportFormat.money,
        value: (r) => r.balance,
        width: 1.2,
      ),
      if (tab.isGroupTab)
        ExportColumn(
          id: 'lastDate',
          label: 'Last purchase',
          format: ExportFormat.date,
          value: (r) => r.lastDate,
          display: (r) => r.lastDate == null ? _dash : f.date(r.lastDate!),
        ),
      ExportColumn(
        id: 'share',
        label: 'Share',
        format: ExportFormat.percent,
        value: (r) => r.share,
        display: (r) => r.share == null ? _dash : f.percent(r.share!),
        width: 0.8,
      ),
    ],
    // 58mm: 15 / 16 characters, 80mm: 23 / 5 / 18.
    roll: const RollLayout(
      cols58: ['name', 'spend'],
      cols80: ['name', 'purchases', 'spend'],
      flex58: [1, 1],
      flex80: [4, 1, 3],
    ),
    emptyMessage: 'No purchases in this period.',
  );
}

/// [tabs] are the breakdown tabs the screen offers. [activeTab] is
/// sorted by [sortField] / [ascending], as on screen; the others keep
/// their built order, as they show when opened.
ReportExportSpec purchaseSummaryExportSpec({
  required PurchaseSummaryResult result,
  required ReceiptsReportPeriod period,
  required List<PurchaseBreakdownTab> tabs,
  required PurchaseBreakdownTab activeTab,
  required PurchaseBreakdownSortField? sortField,
  required bool ascending,
  required String currency,
}) {
  final f = ExportFormatter(currency: currency);
  final s = result.stats;

  ExportMetric count(String label, int v, {String? note}) => ExportMetric(
    label: label,
    value: v,
    format: ExportFormat.integer,
    note: note,
  );

  return ReportExportSpec(
    reportName: 'Purchase Summary',
    fileSlug: 'purchase_summary',
    period: ExportPeriod(
      label: receiptsPeriodLabel(period),
      start: period.start,
      end: period.end,
    ),
    notes: purchaseReportNotes(period: period),
    sections: [
      ExportSummarySection(
        title: 'Statistics',
        metrics: [
          count('Total Purchases', s.totalPurchases, note: 'Purchases in this period'),
          ExportMetric(
            label: 'Total Spend',
            value: s.totalSpend,
            note: 'Total of the purchases',
          ),
          ExportMetric(label: 'Total Paid', value: s.totalPaid, note: 'Paid to suppliers'),
          ExportMetric(
            label: 'Outstanding Balance',
            value: s.totalOutstanding,
            note: 'Still owed to suppliers',
          ),
          ExportMetric(
            label: 'Average Purchase Value',
            value: s.averagePurchaseValue,
            note: 'Spend per purchase',
          ),
          ExportMetric(
            label: 'Items Purchased',
            value: s.totalItems,
            format: ExportFormat.quantity,
            note: s.itemsUnknownCount > 0
                ? '${s.itemsUnknownCount} without line data'
                : 'In the units bought',
          ),
          count(
            'Suppliers Used',
            s.distinctSuppliers,
            note: s.noSupplierPurchases > 0
                ? '+${s.noSupplierPurchases} with no supplier'
                : 'Distinct suppliers',
          ),
          count(
            'Staff Involved',
            s.distinctStaff,
            note: s.noStaffPurchases > 0
                ? '+${s.noStaffPurchases} with no staff'
                : 'Distinct staff',
          ),
          for (final st in PurchaseStatus.values)
            count(
              st.label,
              s.statusCount(st),
              note: 'Purchases ${st.label.toLowerCase()}',
            ),
          if (s.overpaidCount > 0)
            count('Overpaid', s.overpaidCount, note: 'Paid more than the total'),
        ],
      ),
      _ranking('Top 3 Suppliers', result.topSuppliers),
      _ranking('Least 3 Suppliers', result.leastSuppliers),
      for (final tab in tabs)
        _breakdown(
          tab,
          PurchaseSummaryBuilder.sortBreakdown(
            PurchaseSummaryBuilder.breakdown(result, tab),
            field: tab == activeTab ? sortField : null,
            ascending: ascending,
          ),
          f,
        ),
    ],
  );
}
