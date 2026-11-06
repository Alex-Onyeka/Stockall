// Export spec of the Invoice Summary page: its statistic cards, the
// creditor rankings and the breakdown tables (customers, staff,
// departments, sub-staff, statuses). Charts aren't exported. Every input
// is the screen's own InvoiceSummaryResult.

import 'package:flutter/material.dart' show DateTimeRange;
import 'package:stockall/constants/calculations.dart' show formatDateTime;
import 'package:stockall/pages/report/components/export/report_export_format.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/invoice_report/invoice_summary/class/invoice_summary_logic.dart';

const String _dash = '—';

/// The Customer table's search, as the screen applies it. The view
/// and the export both call this.
List<CustomerInvoiceSummary> invoiceSummaryCustomers(
  List<CustomerInvoiceSummary> all,
  String search,
) {
  if (search.isEmpty) return all;
  final q = search.toLowerCase();
  return all.where((c) => c.customerName.toLowerCase().contains(q)).toList();
}

/// The period selector's text.
String invoiceSummaryPeriodLabel(
  InvoiceSummaryPeriod period,
  DateTimeRange? customRange,
) {
  if (period == InvoiceSummaryPeriod.custom && customRange != null) {
    return '${formatDateTime(customRange.start)} - ${formatDateTime(customRange.end)}';
  }
  return period.label;
}

/// Status as the status table's badge shows it.
String _statusLabel(InvoicePaymentStatusSummary s) => switch (s.statusCode) {
  2 => 'Paid',
  1 => 'Partial',
  0 => 'Unpaid',
  _ => s.statusName,
};

const RollLayout _tableRoll = RollLayout(
  cols58: ['name', 'total'],
  cols80: ['no', 'name', 'total'],
  flex58: [1, 1],
  flex80: [1, 4, 4],
);

ExportColumn<T> _no<T>(List<T> rows) {
  final no = Map<T, int>.identity();
  for (var i = 0; i < rows.length; i++) {
    no[rows[i]] = i + 1;
  }
  return ExportColumn<T>(
    id: 'no',
    label: '#',
    format: ExportFormat.integer,
    value: (r) => no[r],
    width: 0.5,
  );
}

ExportColumn<T> _money<T>(
  ExportFormatter f,
  String id,
  String label,
  double? Function(T) v,
) {
  return ExportColumn<T>(
    id: id,
    label: label,
    format: ExportFormat.money,
    value: v,
    display: (r) {
      final x = v(r);
      return x == null ? _dash : f.money(x);
    },
    width: 1.2,
  );
}

ExportColumn<T> _count<T>(String label, int Function(T) v) => ExportColumn<T>(
  id: 'invoices',
  label: label,
  format: ExportFormat.integer,
  value: v,
  width: 0.8,
);

ExportColumn<T> _percent<T>(String label, double Function(T) v) =>
    ExportColumn<T>(
      id: 'share',
      label: label,
      format: ExportFormat.percent,
      value: v,
      width: 0.9,
    );

ExportColumn<T> _date<T>(
  ExportFormatter f,
  String id,
  String label,
  DateTime? Function(T) v,
) {
  return ExportColumn<T>(
    id: id,
    label: label,
    format: ExportFormat.date,
    value: v,
    display: (r) {
      final x = v(r);
      return x == null ? _dash : f.date(x);
    },
  );
}

ExportTableSection<CustomerInvoiceSummary> _creditors(
  ExportFormatter f,
  String title,
  List<CustomerInvoiceSummary> list,
) {
  return ExportTableSection<CustomerInvoiceSummary>(
    title: title,
    rows: list,
    columns: [
      _no(list),
      ExportColumn(id: 'name', label: 'Customer', value: (c) => c.customerName, width: 2),
      _count('Invoices', (c) => c.invoiceCount),
      _money(f, 'total', 'Total Value', (c) => c.totalInvoiceValue),
      _money(f, 'paid', 'Paid', (c) => c.amountPaid),
      _money(f, 'balance', 'Outstanding Balance', (c) => c.outstandingBalance),
    ],
    roll: const RollLayout(
      cols58: ['name', 'balance'],
      cols80: ['no', 'name', 'balance'],
      flex58: [1, 1],
      flex80: [1, 4, 4],
    ),
    emptyMessage: 'No creditors with outstanding balances found.',
  );
}

/// [customers] is the Customer table as shown (its search applied, see
/// [invoiceSummaryCustomers]).
ReportExportSpec invoiceSummaryExportSpec({
  required InvoiceSummaryResult result,
  required List<CustomerInvoiceSummary> customers,
  required String customerSearch,
  required InvoiceSummaryPeriod period,
  required DateTimeRange? customRange,
  required DateTimeRange resolvedRange,
  required String currency,
  required bool canSeeCost,
  required bool departmentsEnabled,
  required bool bulkSaleEnabled,
}) {
  final f = ExportFormatter(currency: currency);
  final s = result.stats;
  const empty = 'No records found.';
  final search = customerSearch.trim();

  ExportMetric count(String label, int v, {String? note}) => ExportMetric(
    label: label,
    value: v,
    format: ExportFormat.integer,
    note: note,
  );

  return ReportExportSpec(
    reportName: 'Invoice Summary',
    fileSlug: 'invoice_summary',
    period: ExportPeriod(
      label: invoiceSummaryPeriodLabel(period, customRange),
      start: period == InvoiceSummaryPeriod.allTime ? null : resolvedRange.start,
      end: period == InvoiceSummaryPeriod.allTime ? null : resolvedRange.end,
    ),
    filters: [if (search.isNotEmpty) ExportFilter('Customer search', search)],
    sections: [
      ExportSummarySection(
        title: 'Statistics',
        metrics: [
          ExportMetric(
            label: 'Total Invoice Value',
            value: s.totalInvoiceValue,
            note: '${s.totalInvoices} Qualifying Invoices',
          ),
          count(
            'Total Invoices',
            s.totalInvoices,
            note: '${s.fullyPaidInvoices} Paid • ${s.partiallyPaidInvoices} '
                'Partial • ${s.unpaidInvoices} Unpaid',
          ),
          ExportMetric(
            label: 'Total Amount Paid',
            value: s.totalAmountPaid,
            note: 'Collections in Period: ${f.money(s.totalCollectionsInPeriod)}',
          ),
          ExportMetric(
            label: 'Total Outstanding Balance',
            value: s.totalOutstandingBalance,
            note: 'Customer Balance Owed',
          ),
          count('Fully Paid Invoices', s.fullyPaidInvoices),
          count('Partially Paid Invoices', s.partiallyPaidInvoices),
          count('Unpaid Invoices', s.unpaidInvoices),
          if (s.unresolvedInvoices > 0)
            count('Unresolved Statuses', s.unresolvedInvoices),
          count('Total Customers', s.totalCustomers),
          count('Total Staff Involved', s.totalStaffInvolved),
        ],
      ),
      _creditors(f, 'Top Creditors', result.topCreditors),
      _creditors(f, 'Least Creditors', result.leastCreditors),
      ExportTableSection<CustomerInvoiceSummary>(
        title: 'Customer Summary',
        rows: customers,
        columns: [
          _no(customers),
          ExportColumn(id: 'name', label: 'Customer', value: (c) => c.customerName, width: 2),
          _count('Invoices', (c) => c.invoiceCount),
          _money(f, 'total', 'Total Value', (c) => c.totalInvoiceValue),
          _money(f, 'paid', 'Amount Paid', (c) => c.amountPaid),
          _money(f, 'balance', 'Balance', (c) => c.outstandingBalance),
          if (canSeeCost) _money(f, 'profit', 'Profit/Loss', (c) => c.totalProfit),
          _money(f, 'average', 'Avg Value', (c) => c.averageInvoiceValue),
          _date(f, 'lastInvoice', 'Last Invoice', (c) => c.lastInvoiceDate),
          _date(f, 'lastPayment', 'Last Payment', (c) => c.lastPaymentDate),
        ],
        roll: _tableRoll,
        emptyMessage: empty,
      ),
      ExportTableSection<StaffInvoiceSummary>(
        title: 'Staff Summary',
        rows: result.allStaffSummaries,
        columns: [
          _no(result.allStaffSummaries),
          ExportColumn(id: 'name', label: 'Staff Member', value: (g) => g.staffName, width: 2),
          _count('Invoices', (g) => g.invoiceCount),
          _money(f, 'total', 'Total Value', (g) => g.totalInvoiceValue),
          _money(f, 'paid', 'Collected', (g) => g.amountPaid),
          _money(f, 'balance', 'Balance', (g) => g.outstandingBalance),
          if (canSeeCost) _money(f, 'profit', 'Profit/Loss', (g) => g.totalProfit),
          _money(f, 'average', 'Avg Value', (g) => g.averageInvoiceValue),
          _percent('% of Value', (g) => g.percentageOfTotalValue),
        ],
        roll: _tableRoll,
        emptyMessage: empty,
      ),
      if (departmentsEnabled)
        ExportTableSection<DepartmentInvoiceSummary>(
          title: 'Department Summary',
          rows: result.departmentSummaries,
          columns: [
            _no(result.departmentSummaries),
            ExportColumn(
              id: 'name',
              label: 'Department',
              value: (g) => g.departmentName,
              width: 2,
            ),
            _count('Invoices', (g) => g.invoiceCount),
            _money(f, 'total', 'Total Value', (g) => g.totalInvoiceValue),
            _money(f, 'paid', 'Amount Paid', (g) => g.amountPaid),
            _money(f, 'balance', 'Balance', (g) => g.outstandingBalance),
            if (canSeeCost) _money(f, 'profit', 'Profit/Loss', (g) => g.totalProfit),
            _money(f, 'average', 'Avg Value', (g) => g.averageInvoiceValue),
            _percent('% of Value', (g) => g.percentageOfInvoiceValue),
          ],
          roll: _tableRoll,
          emptyMessage: empty,
        ),
      if (bulkSaleEnabled)
        ExportTableSection<SubStaffInvoiceSummary>(
          title: 'Sub-Staff Summary',
          rows: result.subStaffSummaries,
          columns: [
            _no(result.subStaffSummaries),
            ExportColumn(
              id: 'name',
              label: 'Sub-Staff Member',
              value: (g) => g.subStaffName,
              width: 2,
            ),
            _count('Invoices', (g) => g.invoiceCount),
            _money(f, 'total', 'Total Value', (g) => g.totalInvoiceValue),
            _money(f, 'paid', 'Amount Paid', (g) => g.amountPaid),
            _money(f, 'balance', 'Balance', (g) => g.outstandingBalance),
            if (canSeeCost) _money(f, 'profit', 'Profit/Loss', (g) => g.totalProfit),
          ],
          roll: _tableRoll,
          emptyMessage: empty,
        ),
      ExportTableSection<InvoicePaymentStatusSummary>(
        title: 'Invoice Status Summary',
        rows: result.statusSummaries,
        columns: [
          _no(result.statusSummaries),
          ExportColumn(id: 'name', label: 'Invoice Status', value: _statusLabel, width: 2),
          _count('Invoices', (g) => g.invoiceCount),
          _money(f, 'total', 'Total Value', (g) => g.totalInvoiceValue),
          _money(f, 'paid', 'Amount Paid', (g) => g.amountPaid),
          _money(f, 'balance', 'Balance', (g) => g.outstandingBalance),
          _percent('% of Invoices', (g) => g.percentageOfInvoices),
        ],
        roll: _tableRoll,
        emptyMessage: empty,
      ),
    ],
  );
}
