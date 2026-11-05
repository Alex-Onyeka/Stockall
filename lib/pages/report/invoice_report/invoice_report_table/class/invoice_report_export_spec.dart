// Export spec of the Invoice Report table, grouping-aware: the invoice
// rows (the full filtered and sorted list, not the page) when Group by
// is off, or the group table the user sees when it is on. Totals are
// the screen's own (InvoiceReportPageResult / InvoiceReportGroupPage).

import 'package:flutter/material.dart' show DateTimeRange;
import 'package:stockall/constants/calculations.dart' show formatDateTime;
import 'package:stockall/pages/report/components/export/report_export_format.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/export/report_export_splits.dart';
import 'package:stockall/pages/report/components/report_group_by.dart';
import 'package:stockall/pages/report/invoice_report/invoice_report_table/class/invoice_report_table_logic.dart';

const String _dash = '—';

/// The date pill's text (the view's `_rangeLabel`).
String invoicePeriodLabel(DateTimeRange? range) {
  if (range == null) return 'All Time';
  final s = range.start;
  final e = range.end;
  final same = s.year == e.year && s.month == e.month && s.day == e.day;
  return same
      ? formatDateTime(s)
      : '${formatDateTime(s)} - ${formatDateTime(e)}';
}

/// Status as the Status column shows it.
String invoiceStatusLabel(int status) => switch (status) {
  0 => 'Unpaid',
  1 => 'Partial',
  2 => 'Paid',
  _ => 'N/A',
};

const Map<InvoiceSortField, String> invoiceSortLabels = {
  InvoiceSortField.id: 'ID',
  InvoiceSortField.staff: 'Staff',
  InvoiceSortField.subStaff: 'Sub-Staff',
  InvoiceSortField.customer: 'Customer',
  InvoiceSortField.createdAt: 'Date',
  InvoiceSortField.discount: 'Discount',
  InvoiceSortField.vat: 'VAT',
  InvoiceSortField.items: 'Items',
  InvoiceSortField.department: 'Department',
  InvoiceSortField.channel: 'Channel',
  InvoiceSortField.total: 'Invoice Total',
  InvoiceSortField.amountPaid: 'Amount Paid',
  InvoiceSortField.balance: 'Balance',
  InvoiceSortField.cost: 'Cost',
  InvoiceSortField.profit: 'Profit/Loss',
  InvoiceSortField.margin: 'Margin (%)',
  InvoiceSortField.status: 'Status',
};

String _dir(bool ascending) => ascending ? 'ascending' : 'descending';

String invoiceSortLabel(InvoiceSortField field, bool ascending) =>
    '${invoiceSortLabels[field] ?? field.name} (${_dir(ascending)})';

String invoiceGroupSortLabel(
  InvoiceGroupSortField field,
  bool ascending,
  ReportGroupBy groupBy,
) {
  final label = switch (field) {
    InvoiceGroupSortField.name => groupBy.label,
    InvoiceGroupSortField.count => 'Invoices',
    InvoiceGroupSortField.total => 'Invoice Total',
    InvoiceGroupSortField.paid => 'Amount Paid',
    InvoiceGroupSortField.balance => 'Balance',
  };
  return '$label (${_dir(ascending)})';
}

/// The table's filters with their values, worded like its chips. Names
/// come from [baseRows] (every loaded invoice), as the chips look them
/// up; [departmentNames] is the department list by uuid.
List<ExportFilter> invoiceExportFilters({
  required InvoiceReportFilters filters,
  required List<InvoiceReportRow> baseRows,
  required Map<String, String> departmentNames,
  required bool departmentsEnabled,
  required bool bulkSaleEnabled,
  required ExportFormatter f,
}) {
  String range(double? min, double? max) =>
      '${min != null ? f.money(min) : 'Any'} - ${max != null ? f.money(max) : 'Any'}';
  String? nameOf(bool Function(InvoiceReportRow) match, String Function(InvoiceReportRow) name) {
    for (final r in baseRows) {
      if (match(r)) return name(r);
    }
    return null;
  }

  final out = <ExportFilter>[];
  final search = filters.search.trim();
  if (search.isNotEmpty) out.add(ExportFilter('Search', search));
  final staff = filters.staffId;
  if (staff != null) {
    out.add(ExportFilter(
      'Staff',
      nameOf((r) => r.invoice.staffId == staff, (r) => r.staffName) ?? staff,
    ));
  }
  final customer = filters.customerUuid;
  if (customer != null) {
    out.add(ExportFilter(
      'Customer',
      nameOf((r) => r.invoice.customerUuid == customer, (r) => r.customerName) ??
          customer,
    ));
  }
  if (filters.paymentStatus != InvoicePaymentStatusFilter.all) {
    out.add(ExportFilter('Status', switch (filters.paymentStatus) {
      InvoicePaymentStatusFilter.unpaid => 'Unpaid',
      InvoicePaymentStatusFilter.partial => 'Partially Paid',
      InvoicePaymentStatusFilter.paid => 'Paid',
      InvoicePaymentStatusFilter.all => 'All Statuses',
    }));
  }
  if (filters.paymentChannel != InvoicePaymentChannelFilter.all) {
    out.add(ExportFilter('Channel', switch (filters.paymentChannel) {
      InvoicePaymentChannelFilter.cash => 'Cash',
      InvoicePaymentChannelFilter.bank => 'Bank',
      InvoicePaymentChannelFilter.split => 'Split',
      InvoicePaymentChannelFilter.unpaid => 'Unpaid',
      InvoicePaymentChannelFilter.all => 'All',
    }));
  }
  final subStaff = filters.subStaffUuid;
  if (bulkSaleEnabled && subStaff != null) {
    out.add(ExportFilter(
      'Sub-Staff',
      nameOf((r) => r.invoice.subStaffUuid == subStaff, (r) => r.subStaffName) ??
          subStaff,
    ));
  }
  final dept = filters.departmentKey;
  if (departmentsEnabled && dept != null) {
    out.add(ExportFilter(
      'Department',
      dept == invoiceReportNoDepartmentKey
          ? 'No Department'
          : departmentNames[dept] ?? dept,
    ));
  }
  if (filters.totalMin != null || filters.totalMax != null) {
    out.add(ExportFilter('Total', range(filters.totalMin, filters.totalMax)));
  }
  if (filters.paidMin != null || filters.paidMax != null) {
    out.add(ExportFilter('Paid', range(filters.paidMin, filters.paidMax)));
  }
  if (filters.balanceMin != null || filters.balanceMax != null) {
    out.add(ExportFilter('Balance', range(filters.balanceMin, filters.balanceMax)));
  }
  return out;
}

/// The screen's totals row (InvoiceReportPageResult) by column id.
Map<String, Object?> invoiceTotals(
  List<InvoiceReportRow> rows, {
  required ExportFormatter f,
}) {
  final page = InvoiceReportQuery.paginate(rows, 1);
  return {
    'id': '${f.integer(rows.length)} ${rows.length == 1 ? 'invoice' : 'invoices'}',
    'total': page.totalRevenue,
    'paid': page.totalAmountPaid,
    'balance': page.totalBalance,
  };
}

String? _text(String? v) {
  final t = v?.trim();
  return t == null || t.isEmpty ? null : t;
}

ExportTableSection<InvoiceReportRow> invoiceTableSection({
  required List<InvoiceReportRow> rows,
  required ExportFormatter f,
  required bool departmentsEnabled,
  required bool bulkSaleEnabled,
}) {
  String orNa(double? v) => v == null ? 'N/A' : f.money(v);

  return ExportTableSection<InvoiceReportRow>(
    title: 'Invoices',
    rows: rows,
    columns: [
      ExportColumn(id: 'id', label: 'ID', value: (r) => r.displayId, width: 1.4),
      ExportColumn(id: 'staff', label: 'Staff', value: (r) => r.staffName, width: 1.3),
      if (bulkSaleEnabled)
        ExportColumn(
          id: 'subStaff',
          label: 'Sub-Staff',
          value: (r) => r.subStaffName,
          width: 1.2,
        ),
      ExportColumn(
        id: 'customer',
        label: 'Customer',
        value: (r) => r.customerName,
        width: 1.4,
      ),
      ExportColumn(
        id: 'date',
        label: 'Date',
        format: ExportFormat.date,
        value: (r) => r.createdAt,
      ),
      ExportColumn(
        id: 'time',
        label: 'Time',
        format: ExportFormat.time,
        value: (r) => r.createdAt,
      ),
      ExportColumn(
        id: 'discount',
        label: 'Discount',
        format: ExportFormat.money,
        value: (r) => r.discountAmount,
        display: (r) {
          final fixed = r.invoice.fixedDiscount;
          final pct = r.invoice.generalDiscount;
          if (fixed != null && fixed > 0) return f.money(fixed);
          if (pct != null && pct > 0) {
            return '${f.percent(pct)} (${f.money(r.discountAmount)})';
          }
          return _dash;
        },
        width: 1.3,
      ),
      ExportColumn(
        id: 'vat',
        label: 'VAT',
        format: ExportFormat.money,
        value: (r) => r.vatAmount,
        display: (r) {
          final rate = r.invoice.vat;
          if (rate == null || rate <= 0) return _dash;
          return '[${f.percent(rate)}] ${f.money(r.vatAmount)}';
        },
        width: 1.3,
      ),
      ExportColumn(
        id: 'items',
        label: 'Items',
        format: ExportFormat.quantity,
        value: (r) => r.totalItems,
        display: (r) => r.totalItems == null ? 'N/A' : f.quantity(r.totalItems!),
        width: 0.7,
      ),
      if (departmentsEnabled)
        ExportColumn(
          id: 'department',
          label: 'Department',
          value: (r) => r.departmentName,
          width: 1.2,
        ),
      ExportColumn(
        id: 'comment',
        label: 'Comment',
        value: (r) => r.comment,
        inPdf: false,
      ),
      ExportColumn(
        id: 'total',
        label: 'Invoice Total',
        format: ExportFormat.money,
        value: (r) => r.invoiceTotal,
        display: (r) => orNa(r.invoiceTotal),
        width: 1.3,
      ),
      ExportColumn(
        id: 'paid',
        label: 'Amount Paid',
        format: ExportFormat.money,
        value: (r) => r.amountPaid,
        width: 1.3,
      ),
      ExportColumn(
        id: 'balance',
        label: 'Balance',
        format: ExportFormat.money,
        value: (r) => r.balance,
        display: (r) => orNa(r.balance),
        width: 1.3,
      ),
      ExportColumn(
        id: 'status',
        label: 'Status',
        value: (r) => invoiceStatusLabel(r.status),
        width: 0.8,
      ),
    ],
    totalsFor: (rs) => invoiceTotals(rs, f: f),
    splits: [
      staffSplit<InvoiceReportRow>(
        rows: rows,
        staffId: (r) => _text(r.invoice.staffId),
        staffName: (r) => _text(r.invoice.staffName),
      ),
      channelSplit<InvoiceReportRow>(channel: (r) => r.paymentChannel),
      statusSplit<InvoiceReportRow>(
        status: (r) => r.status < 0 ? null : invoiceStatusLabel(r.status),
      ),
      if (departmentsEnabled)
        fieldSplit<InvoiceReportRow>(
          id: 'department',
          label: 'Department',
          noneLabel: 'No Department',
          rows: rows,
          key: (r) => _text(r.departmentKey),
          name: (r) => _text(r.invoice.departmentName),
        ),
      customerSplit<InvoiceReportRow>(
        rows: rows,
        customerId: (r) => _text(r.invoice.customerUuid),
        customerName: (r) => r.customerName,
      ),
    ],
    // 58mm: 15 / 16 characters, 80mm: 15 / 15 / 16, so "#0000000000001"
    // and "₦1,250,000.00" stay on one line.
    roll: const RollLayout(
      cols58: ['id', 'total'],
      cols80: ['id', 'total', 'balance'],
      sub80: ['customer', 'date'],
      flex58: [1, 1],
      flex80: [1, 1, 1],
    ),
    emptyMessage: 'No invoice matches the selected period and filters.',
  );
}

ExportTableSection<InvoiceReportGroupRow> invoiceGroupSection({
  required List<InvoiceReportGroupRow> groups,
  required ReportGroupBy groupBy,
  required ExportFormatter f,
}) {
  return ExportTableSection<InvoiceReportGroupRow>(
    title: 'Invoices by ${groupBy.label}',
    rows: groups,
    columns: [
      ExportColumn(id: 'name', label: groupBy.label, value: (g) => g.label, width: 2),
      ExportColumn(
        id: 'invoices',
        label: 'Invoices',
        format: ExportFormat.integer,
        value: (g) => g.count,
        width: 0.8,
      ),
      ExportColumn(
        id: 'total',
        label: 'Invoice Total',
        format: ExportFormat.money,
        value: (g) => g.total,
        width: 1.2,
      ),
      ExportColumn(
        id: 'paid',
        label: 'Amount Paid',
        format: ExportFormat.money,
        value: (g) => g.paid,
        width: 1.2,
      ),
      ExportColumn(
        id: 'balance',
        label: 'Balance',
        format: ExportFormat.money,
        value: (g) => g.balance,
        width: 1.2,
      ),
    ],
    // The screen's InvoiceReportGroupPage totals.
    totalsFor: (gs) {
      final page = InvoiceReportGrouping.paginate(gs, 1);
      return {
        'name': '${f.integer(gs.length)} ${groupBy.pagerLabel}',
        'invoices': page.totalInvoices,
        'total': page.totalRevenue,
        'paid': page.totalAmountPaid,
        'balance': page.totalBalance,
      };
    },
    // 58mm: 15 / 16 characters, 80mm: 23 / 5 / 18.
    roll: const RollLayout(
      cols58: ['name', 'total'],
      cols80: ['name', 'invoices', 'total'],
      flex58: [1, 1],
      flex80: [4, 1, 3],
    ),
    emptyMessage: 'No invoice matches the selected period and filters.',
  );
}

/// [rows] is the full filtered and sorted invoice list; [groups] the
/// full sorted group list (used when [groupBy] is not off). [baseRows]
/// are every loaded invoice, for the filter names.
ReportExportSpec invoiceReportExportSpec({
  required List<InvoiceReportRow> rows,
  required List<InvoiceReportGroupRow> groups,
  required List<InvoiceReportRow> baseRows,
  required ReportGroupBy groupBy,
  required InvoiceReportFilters filters,
  required Map<String, String> departmentNames,
  required InvoiceSortField sortField,
  required bool ascending,
  required InvoiceGroupSortField groupSortField,
  required bool groupAscending,
  required String currency,
  required bool departmentsEnabled,
  required bool bulkSaleEnabled,
}) {
  final f = ExportFormatter(currency: currency);
  final grouped = groupBy != ReportGroupBy.off;
  final range = filters.dateRange;
  return ReportExportSpec(
    reportName: 'Invoice Report',
    fileSlug: 'invoice_report',
    period: ExportPeriod(
      label: invoicePeriodLabel(range),
      start: range?.start,
      end: range?.end,
    ),
    filters: invoiceExportFilters(
      filters: filters,
      baseRows: baseRows,
      departmentNames: departmentNames,
      departmentsEnabled: departmentsEnabled,
      bulkSaleEnabled: bulkSaleEnabled,
      f: f,
    ),
    sortedBy: grouped
        ? invoiceGroupSortLabel(groupSortField, groupAscending, groupBy)
        : invoiceSortLabel(sortField, ascending),
    groupedBy: grouped ? groupBy.label : null,
    sections: [
      if (grouped)
        invoiceGroupSection(groups: groups, groupBy: groupBy, f: f)
      else
        invoiceTableSection(
          rows: rows,
          f: f,
          departmentsEnabled: departmentsEnabled,
          bulkSaleEnabled: bulkSaleEnabled,
        ),
    ],
  );
}
