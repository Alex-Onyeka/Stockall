// Export spec of the Customer Analysis page: contact details, the KPI
// cards (same gates as the screen) and each section's most recent
// records, as the screen shows them (5 each).

import 'package:stockall/pages/report/components/export/report_export_format.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/customer_report/customer_account_transactions/class/customer_account_transactions_logic.dart';
import 'package:stockall/pages/report/customer_report/customer_analysis/class/customer_analysis_logic.dart';
import 'package:stockall/pages/report/customer_report/customer_report_table/class/customer_ledger_export_spec.dart'
    show customerLedgerSigned;
import 'package:stockall/pages/report/customer_report/customer_report_table/class/customer_report_export_spec.dart';
import 'package:stockall/pages/report/customer_report/customer_report_table/class/customer_report_table_logic.dart';
import 'package:stockall/pages/report/customer_report/customer_reward_earnings/class/customer_reward_earnings_logic.dart';
import 'package:stockall/pages/report/invoice_report/invoice_report_table/class/invoice_report_export_spec.dart'
    show invoiceStatusLabel;
import 'package:stockall/pages/report/order_report/order_report_table/class/order_report_table_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

const String _dash = '—';

/// A text metric, "—" when blank.
ExportMetric exportTextMetric(String label, String? value) =>
    ExportMetric(label: label, value: value ?? _dash, format: ExportFormat.text);

/// A date metric, "—" when there is none.
ExportMetric exportDateMetric(String label, DateTime? value, {String? note}) =>
    ExportMetric(
      label: label,
      value: value ?? _dash,
      format: value == null ? ExportFormat.text : ExportFormat.date,
      note: note,
    );

/// One "recent records" section of an analysis page: Record, Date
/// (date and time), Detail, Amount and, for invoices and orders,
/// Balance. [total] is the section's count in the period, shown in
/// the title ("Receipts (5 of 12 in this period)").
ExportTableSection<T> recentRecordsSection<T>({
  required String title,
  required int total,
  required List<T> rows,
  required String Function(T) record,
  required DateTime? Function(T) date,
  required String Function(T) detail,
  required double? Function(T) amount,
  required ExportFormatter f,
  required String emptyMessage,
  String Function(T)? amountText,
  double? Function(T)? balance,
}) {
  return ExportTableSection<T>(
    title: rows.isEmpty ? title : '$title (${rows.length} of $total in this period)',
    rows: rows,
    columns: [
      ExportColumn<T>(id: 'record', label: 'Record', value: record, width: 1.6),
      ExportColumn<T>(
        id: 'date',
        label: 'Date',
        format: ExportFormat.dateTime,
        value: date,
        display: (r) {
          final d = date(r);
          return d == null ? _dash : f.dateTime(d);
        },
        width: 1.6,
      ),
      ExportColumn<T>(id: 'detail', label: 'Detail', value: detail, width: 1.3),
      ExportColumn<T>(
        id: 'amount',
        label: 'Amount',
        format: ExportFormat.money,
        value: amount,
        display: (r) {
          if (amountText != null) return amountText(r);
          final v = amount(r);
          return v == null ? _dash : f.money(v);
        },
        width: 1.2,
      ),
      if (balance != null)
        ExportColumn<T>(
          id: 'balance',
          label: 'Balance',
          format: ExportFormat.money,
          value: balance,
          display: (r) {
            final v = balance(r);
            return v == null ? _dash : f.money(v);
          },
          width: 1.2,
        ),
    ],
    // The detail ("Partially Delivered") and date go on the sub-line,
    // so IDs and amounts never wrap.
    roll: const RollLayout(
      cols58: ['record', 'amount'],
      cols80: ['record', 'amount'],
      sub58: ['date', 'detail'],
      sub80: ['date', 'detail'],
      flex58: [1, 1],
      flex80: [3, 2],
    ),
    emptyMessage: emptyMessage,
  );
}

/// [analysis] is the screen's `CustomerAnalysis` for [period].
ReportExportSpec customerAnalysisExportSpec({
  required CustomerAnalysis analysis,
  required ReceiptsReportPeriod period,
  required bool showTotalBalance,
  required String currency,
}) {
  final f = ExportFormatter(currency: currency);
  final a = analysis;
  final s = a.summary;
  ExportMetric money(String label, double v, String note) =>
      ExportMetric(label: label, value: v, note: note);
  ExportMetric count(String label, int v, String note) => ExportMetric(
    label: label,
    value: v,
    format: ExportFormat.integer,
    note: note,
  );

  ExportTableSection<CustomerLedgerRow> ledger(
    String title,
    List<CustomerLedgerRow> rows,
    int total,
    String Function(CustomerLedgerRow) direction,
    String empty,
  ) => recentRecordsSection<CustomerLedgerRow>(
    title: title,
    total: total,
    rows: rows,
    record: (r) => r.title,
    date: (r) => r.createdAt,
    detail: direction,
    amount: (r) => r.signedAmount,
    amountText: (r) => customerLedgerSigned(r.signedAmount, f),
    f: f,
    emptyMessage: empty,
  );

  return ReportExportSpec(
    reportName: 'Customer Analysis',
    fileSlug: 'customer_analysis',
    period: customerExportPeriod(period),
    filters: [ExportFilter('Customer', s.name)],
    notes: customerReportNotes(period: period),
    sections: [
      ExportSummarySection(
        title: 'Contact Details',
        metrics: [
          exportTextMetric('Phone', s.phone),
          exportTextMetric('Email', s.email),
          exportTextMetric('Address', s.address),
          exportTextMetric('City', s.city),
          exportTextMetric('State', s.state),
          exportTextMetric('Country', s.country),
        ],
      ),
      ExportSummarySection(
        title: 'Statistics',
        metrics: [
          money('Receipt Purchases', s.receiptPurchases, '${s.salesReceiptCount} sales receipts'),
          money('Invoice Purchases', s.invoicePurchases, '${s.invoiceCount} invoices'),
          money('Revenue', s.revenue, 'Every receipt type, VAT included'),
          money('Credit', s.credit, 'Unpaid invoice balances'),
          if (a.showAccount) money('Account Balance', s.accountBalance, 'Current balance'),
          if (a.showReward) money('Reward Earnings', s.rewardEarnings, 'Current balance'),
          if (showTotalBalance)
            money(
              'Total Balance',
              s.totalBalance,
              a.showAccount && a.showReward
                  ? 'Account + reward'
                  : (a.showAccount ? 'Account' : 'Reward'),
            ),
          count('Receipts', s.receiptCount, 'Every receipt type'),
          count('Invoices', s.invoiceCount, 'Created in this period'),
          count('Orders', s.orderCount, 'Created in this period'),
          money('Order Total', s.orderTotal, 'After discount, with VAT'),
          money('Order Paid', s.orderPaid, 'Payments on the orders'),
          money('Order Balance', s.orderBalance, 'Still to pay on the orders'),
          exportDateMetric('First Purchase', s.firstPurchase, note: 'Sales receipt, invoice or order'),
          exportDateMetric('Last Purchase', s.lastPurchase, note: 'Sales receipt, invoice or order'),
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
      recentRecordsSection(
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
      if (a.showReward)
        ledger(
          'Reward Earnings',
          a.recentRewards,
          a.rewardTotals.count,
          CustomerRewardEarningsTable.directionLabel,
          'No reward earnings in this period.',
        ),
      if (a.showAccount)
        ledger(
          'Account Transactions',
          a.recentAccountTransactions,
          a.accountTotals.count,
          CustomerAccountTransactionsTable.directionLabel,
          'No account transactions in this period.',
        ),
    ],
  );
}
