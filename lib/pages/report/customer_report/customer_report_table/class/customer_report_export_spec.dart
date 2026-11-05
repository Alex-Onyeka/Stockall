// Export spec of the Customer Report table: every filtered, sorted
// customer (not just the page), with the screen's column gates and its
// own totals (CustomerReportTotals). No splits.

import 'package:stockall/pages/report/components/export/report_export_format.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/customer_report/customer_report_table/class/customer_report_table_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/components/receipts_report_filter_widgets.dart'
    show receiptsPeriodLabel;

const String _dash = '—';

/// The notes the customer pages (table, analysis, ledger tables) show
/// under their toolbar. The views draw these and the exports carry
/// them, so they always match.
List<String> customerReportNotes({required ReceiptsReportPeriod period}) => [
  if (period.isAllTime) 'All time covers the data loaded on this device.',
];

/// The info box's period, as the period button words it.
ExportPeriod customerExportPeriod(ReceiptsReportPeriod period) => ExportPeriod(
  label: receiptsPeriodLabel(period),
  start: period.start,
  end: period.end,
);

const Map<CustomerReportSortField, String> customerSortLabels = {
  CustomerReportSortField.name: 'Name',
  CustomerReportSortField.phone: 'Phone',
  CustomerReportSortField.location: 'Address',
  CustomerReportSortField.accountBalance: 'Account Balance',
  CustomerReportSortField.rewardEarnings: 'Reward Earnings',
  CustomerReportSortField.totalBalance: 'Total Balance',
  CustomerReportSortField.receiptPurchases: 'Receipt Purchases',
  CustomerReportSortField.invoicePurchases: 'Invoice Purchases',
  CustomerReportSortField.revenue: 'Revenue',
  CustomerReportSortField.credit: 'Credit',
};

/// The sort the table actually uses (a hidden column falls back to
/// name), with its direction.
String customerSortLabel(
  CustomerReportSortField field,
  bool ascending,
  CustomerReportAccess access,
) {
  final used = CustomerReportQuery.visibleSort(field, access);
  return '${customerSortLabels[used] ?? used.name} '
      '(${ascending ? 'ascending' : 'descending'})';
}

/// The table's filters with their values, worded like its chips.
List<ExportFilter> customerExportFilters({
  required CustomerReportFilters filters,
  required List<CustomerReportFilterOption> countryOptions,
  required List<CustomerReportFilterOption> stateOptions,
  required CustomerReportAccess access,
}) {
  String labelOf(List<CustomerReportFilterOption> options, String key) {
    for (final o in options) {
      if (o.key == key) return o.label;
    }
    return key;
  }

  final out = <ExportFilter>[];
  final search = filters.search.trim();
  if (search.isNotEmpty) out.add(ExportFilter('Search', search));
  final country = filters.countryKey;
  if (country != null) out.add(ExportFilter('Country', labelOf(countryOptions, country)));
  final state = filters.stateKey;
  if (state != null) out.add(ExportFilter('State', labelOf(stateOptions, state)));
  if (filters.hasCredit) out.add(const ExportFilter('Credit', 'Has credit'));
  if (access.showAccount && filters.hasAccountBalance) {
    out.add(const ExportFilter('Account', 'Has account balance'));
  }
  return out;
}

/// The screen's totals row (CustomerReportTotals) by column id.
Map<String, Object?> customerTotals(
  List<CustomerReportRow> rows, {
  required CustomerReportAccess access,
  required ExportFormatter f,
}) {
  final t = CustomerReportQuery.paginate(rows, 1).totals;
  return {
    'name': '${f.integer(t.count)} ${t.count == 1 ? 'customer' : 'customers'}',
    if (access.showAccount) 'accountBalance': t.accountBalance,
    if (access.showReward) 'rewardEarnings': t.rewardEarnings,
    if (access.showTotalBalance) 'totalBalance': t.totalBalance,
    'receiptPurchases': t.receiptPurchases,
    'invoicePurchases': t.invoicePurchases,
    'revenue': t.revenue,
    'credit': t.credit,
  };
}

ExportTableSection<CustomerReportRow> customerTableSection({
  required List<CustomerReportRow> rows,
  required CustomerReportAccess access,
  required ExportFormatter f,
}) {
  ExportColumn<CustomerReportRow> money(
    String id,
    String label,
    double Function(CustomerReportRow) v,
  ) => ExportColumn(
    id: id,
    label: label,
    format: ExportFormat.money,
    value: v,
    width: 1.2,
  );

  return ExportTableSection<CustomerReportRow>(
    title: 'Customers',
    rows: rows,
    columns: [
      ExportColumn(id: 'name', label: 'Name', value: (r) => r.name, width: 1.6),
      ExportColumn(id: 'phone', label: 'Phone', value: (r) => r.phone ?? _dash, width: 1.2),
      ExportColumn(
        id: 'address',
        label: 'Address',
        value: (r) => r.locationLabel ?? _dash,
        width: 2,
      ),
      if (access.showAccount)
        money('accountBalance', 'Account Balance', (r) => r.accountBalance),
      if (access.showReward)
        money('rewardEarnings', 'Reward Earnings', (r) => r.rewardEarnings),
      if (access.showTotalBalance)
        money('totalBalance', 'Total Balance', (r) => r.totalBalance),
      money('receiptPurchases', 'Receipt Purchases', (r) => r.receiptPurchases),
      money('invoicePurchases', 'Invoice Purchases', (r) => r.invoicePurchases),
      money('revenue', 'Revenue', (r) => r.revenue),
      money('credit', 'Credit', (r) => r.credit),
    ],
    totalsFor: (rs) => customerTotals(rs, access: access, f: f),
    // 58mm: 15 / 16 characters, 80mm: 19 / 13 / 14, so "₦1,250,000.00"
    // stays on one line.
    roll: const RollLayout(
      cols58: ['name', 'revenue'],
      cols80: ['name', 'revenue', 'credit'],
      flex58: [1, 1],
      flex80: [20, 14, 14],
    ),
    emptyMessage: 'No customer matches your search and filters.',
  );
}

/// [rows] is the full filtered and sorted list.
ReportExportSpec customerReportExportSpec({
  required List<CustomerReportRow> rows,
  required CustomerReportFilters filters,
  required List<CustomerReportFilterOption> countryOptions,
  required List<CustomerReportFilterOption> stateOptions,
  required CustomerReportSortField sortField,
  required bool ascending,
  required CustomerReportAccess access,
  required ReceiptsReportPeriod period,
  required String currency,
}) {
  final f = ExportFormatter(currency: currency);
  return ReportExportSpec(
    reportName: 'Customer Report',
    fileSlug: 'customer_report',
    period: customerExportPeriod(period),
    filters: customerExportFilters(
      filters: filters,
      countryOptions: countryOptions,
      stateOptions: stateOptions,
      access: access,
    ),
    sortedBy: customerSortLabel(sortField, ascending, access),
    notes: customerReportNotes(period: period),
    sections: [customerTableSection(rows: rows, access: access, f: f)],
  );
}
