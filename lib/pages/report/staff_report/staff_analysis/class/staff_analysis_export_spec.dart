// Export spec of the Staff Analysis page: contact details, the KPI cards
// (same gates as the screen) and each section's most recent records, as
// the screen shows them (5 each).

import 'package:stockall/pages/report/components/export/report_export_format.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/customer_report/customer_analysis/class/customer_analysis_export_spec.dart'
    show exportDateMetric, exportTextMetric, recentRecordsSection;
import 'package:stockall/pages/report/invoice_report/invoice_report_table/class/invoice_report_export_spec.dart'
    show invoiceStatusLabel;
import 'package:stockall/pages/report/order_report/order_report_table/class/order_report_table_logic.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/class/purchase_report_table_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/staff_report/staff_analysis/class/staff_analysis_logic.dart';
import 'package:stockall/pages/report/staff_report/staff_report_table/class/staff_report_export_spec.dart';
import 'package:stockall/pages/report/staff_report/staff_report_table/class/staff_report_table_logic.dart';

const String _dash = '—';

String _count(int n, String noun) => '$n $noun${n == 1 ? '' : 's'}';

/// [analysis] is the screen's `StaffAnalysis` for [period].
ReportExportSpec staffAnalysisExportSpec({
  required StaffAnalysis analysis,
  required ReceiptsReportPeriod period,
  required String currency,
}) {
  final f = ExportFormatter(currency: currency);
  final a = analysis;
  final s = a.summary;
  ExportMetric money(String label, double v, String note) =>
      ExportMetric(label: label, value: v, note: note);

  return ReportExportSpec(
    reportName: 'Staff Analysis',
    fileSlug: 'staff_analysis',
    period: staffExportPeriod(period),
    filters: [ExportFilter('Staff', s.name)],
    notes: staffReportNotes(period: period),
    sections: [
      ExportSummarySection(
        title: 'Contact Details',
        metrics: [
          exportTextMetric('Role', s.isFormer ? null : s.roleLabel),
          exportTextMetric('Phone', s.phone),
          exportTextMetric('Email', s.email),
          if (s.isFormer) exportTextMetric('Status', staffReportFormerRoleLabel),
        ],
      ),
      ExportSummarySection(
        title: 'Statistics',
        metrics: [
          money('Receipt Sales', s.receiptSales, _count(s.receiptCount, 'receipt')),
          money('Invoice Sales', s.invoiceSales, _count(s.invoiceCount, 'invoice')),
          if (a.showOrders) money('Orders', s.orderTotal, _count(s.orderCount, 'order')),
          if (a.showPurchases)
            money('Purchases', s.purchaseTotal, _count(s.purchaseCount, 'purchase')),
          if (a.showExpenses)
            money('Expenses', s.expenseTotal, _count(s.expenseCount, 'expense')),
          exportDateMetric('First Activity', s.firstActivity, note: 'Any record in this period'),
          exportDateMetric('Last Activity', s.lastActivity, note: 'Any record in this period'),
        ],
      ),
      recentRecordsSection<ReceiptsReportRow>(
        title: 'Receipts',
        total: s.receiptCount,
        rows: a.recentReceipts,
        record: (r) => r.displayId,
        date: (r) => r.createdAt,
        detail: (r) => r.type.label,
        amount: (r) => r.revenue,
        f: f,
        emptyMessage: 'No receipts in this period.',
      ),
      recentRecordsSection(
        title: 'Invoices',
        total: s.invoiceCount,
        rows: a.recentInvoices,
        record: (r) => r.displayId,
        date: (r) => r.createdAt.toLocal(),
        detail: (r) => invoiceStatusLabel(r.status),
        amount: (r) => r.invoiceTotal,
        balance: (r) => r.balance,
        f: f,
        emptyMessage: 'No invoices in this period.',
      ),
      if (a.showOrders)
        recentRecordsSection<OrderReportRow>(
          title: 'Orders',
          total: s.orderCount,
          rows: a.recentOrders,
          record: (r) => r.displayId,
          date: (r) => r.createdAt,
          detail: (r) => r.status?.label ?? 'Unknown',
          amount: (r) => r.total,
          balance: (r) => r.balance,
          f: f,
          emptyMessage: 'No orders in this period.',
        ),
      if (a.showPurchases)
        recentRecordsSection<PurchaseReportRow>(
          title: 'Purchases',
          total: s.purchaseCount,
          rows: a.recentPurchases,
          record: (r) => r.displayId,
          date: (r) => r.createdAt,
          detail: (r) => r.supplierLabel,
          amount: (r) => r.total,
          balance: (r) => r.balance,
          f: f,
          emptyMessage: 'No purchases in this period.',
        ),
      if (a.showExpenses)
        recentRecordsSection<StaffExpenseRow>(
          title: 'Expenses',
          total: s.expenseCount,
          rows: a.recentExpenses,
          record: (r) => r.title,
          date: (r) => r.createdAt,
          detail: (r) => r.description ?? _dash,
          amount: (r) => r.amount,
          f: f,
          emptyMessage: 'No expenses in this period.',
        ),
    ],
  );
}
