// Export spec of the Receipts Report table, grouping-aware: the receipt
// rows (the full filtered and sorted list, not the page) when Group by
// is off, or the group table the user sees when it is on. Totals are
// the screen's own (ReceiptsReportPage / ReceiptsGroupPage).

import 'package:stockall/pages/report/components/export/report_export_format.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/export/report_export_splits.dart';
import 'package:stockall/pages/report/components/report_group_by.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/components/receipts_report_filter_widgets.dart';

const String _dash = '—';

/// The notes the Receipts table shows under its toolbar. The view draws
/// these and the export carries them, so they always match.
List<String> receiptsReportNotes({
  required ReceiptsReportPeriod period,
  required int profitExcluded,
}) {
  return [
    if (period.isAllTime)
      'All time covers the receipts loaded on this device.',
    if (profitExcluded > 0)
      '$profitExcluded receipt${profitExcluded == 1 ? ' is' : 's are'} '
          'left out of the profit range: no item data or a '
          'missing cost price.',
  ];
}

const Map<ReceiptsSortField, String> receiptsSortLabels = {
  ReceiptsSortField.createdAt: 'Date',
  ReceiptsSortField.customer: 'Customer',
  ReceiptsSortField.staff: 'Staff',
  ReceiptsSortField.revenue: 'Total Revenue',
  ReceiptsSortField.balance: 'Balance',
  ReceiptsSortField.profit: 'Profit/Loss',
  ReceiptsSortField.margin: 'Margin (%)',
  ReceiptsSortField.items: 'Items',
};

String receiptsSortLabel(ReceiptsSortField field, bool ascending) =>
    '${receiptsSortLabels[field] ?? field.name} '
    '(${ascending ? 'ascending' : 'descending'})';

String receiptsGroupSortLabel(
  ReceiptsTableGroupSortField field,
  bool ascending,
  ReportGroupBy groupBy,
) {
  final label = switch (field) {
    ReceiptsTableGroupSortField.name => groupBy.label,
    ReceiptsTableGroupSortField.count => 'Receipts',
    ReceiptsTableGroupSortField.items => 'Items',
    ReceiptsTableGroupSortField.balance => 'Balance',
    ReceiptsTableGroupSortField.revenue => 'Total Revenue',
    ReceiptsTableGroupSortField.profit => 'Profit/Loss',
    ReceiptsTableGroupSortField.margin => 'Margin (%)',
  };
  return '$label (${ascending ? 'ascending' : 'descending'})';
}

/// The receipt filters with their values, worded like
/// `ReceiptsReportFilterChips`.
List<ExportFilter> receiptsExportFilters({
  required ReceiptsReportFilters filters,
  required ReceiptsFilterChoices choices,
  required bool departmentsEnabled,
  required bool subStaffEnabled,
  required bool profitVisible,
  required ExportFormatter f,
  bool showSearch = true,
}) {
  String range(double? min, double? max) =>
      '${min != null ? f.money(min) : 'Any'} - ${max != null ? f.money(max) : 'Any'}';
  final out = <ExportFilter>[];
  void key(String title, String? k, List<ReceiptsFilterOption> options) {
    if (k == null) return;
    out.add(ExportFilter(title, ReceiptsFilterChoices.labelFor(options, k, title)));
  }

  final search = filters.search.trim();
  if (showSearch && search.isNotEmpty) out.add(ExportFilter('Search', search));
  key('Staff', filters.staffKey, choices.staff);
  key('Customer', filters.customerKey, choices.customers);
  if (subStaffEnabled) key('Sub-Staff', filters.subStaffKey, choices.subStaff);
  if (departmentsEnabled) {
    key('Department', filters.departmentKey, choices.departments);
  }
  if (filters.channel != null) {
    out.add(ExportFilter('Channel', filters.channel!.label));
  }
  if (filters.type != null) out.add(ExportFilter('Type', filters.type!.label));
  if (filters.revenueMin != null || filters.revenueMax != null) {
    out.add(ExportFilter('Revenue', range(filters.revenueMin, filters.revenueMax)));
  }
  if (profitVisible && (filters.profitMin != null || filters.profitMax != null)) {
    out.add(ExportFilter('Profit/Loss', range(filters.profitMin, filters.profitMax)));
  }
  return out;
}

/// The screen's totals row (ReceiptsReportPage) by column id.
Map<String, Object?> receiptsTotals(
  List<ReceiptsReportRow> rows, {
  required bool canSeeCost,
  required ExportFormatter f,
}) {
  final page = ReceiptsReportQuery.paginate(rows, 1);
  final m = page.totalMargin;
  return {
    'id': '${f.integer(rows.length)} ${rows.length == 1 ? 'receipt' : 'receipts'}',
    'discount': page.totalDiscount,
    'vat': page.totalVat,
    'items': page.totalItems,
    'balance': page.totalBalance,
    if (canSeeCost) 'profit': page.totalProfit,
    if (canSeeCost && m != null) 'margin': m,
    'subtotal': page.totalSubtotal,
    'revenue': page.totalRevenue,
  };
}

ExportTableSection<ReceiptsReportRow> receiptsTableSection({
  required List<ReceiptsReportRow> rows,
  required ExportFormatter f,
  required bool canSeeCost,
  required bool departmentsEnabled,
  required bool subStaffEnabled,
}) {
  String money(double? v) => v == null ? _dash : f.money(v);

  return ExportTableSection<ReceiptsReportRow>(
    title: 'Receipts',
    rows: rows,
    columns: [
      ExportColumn(id: 'id', label: 'ID', value: (r) => r.displayId, width: 1.4),
      ExportColumn(id: 'staff', label: 'Staff', value: (r) => r.staffLabel, width: 1.3),
      if (subStaffEnabled)
        ExportColumn(
          id: 'subStaff',
          label: 'Sub-Staff',
          value: (r) => r.subStaffLabel,
          width: 1.2,
        ),
      ExportColumn(
        id: 'customer',
        label: 'Customer',
        value: (r) => r.customerLabel,
        width: 1.4,
      ),
      ExportColumn(id: 'channel', label: 'Channel', value: (r) => r.channelLabel),
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
        value: (r) => r.discount,
        display: (r) {
          final v = r.discount;
          if (v == null) return _dash;
          final pct = r.receipt.generalDiscount;
          final showPct = r.receipt.fixedDiscount == null && pct != null;
          return showPct ? '${f.money(v)} (${f.percent(pct)})' : f.money(v);
        },
        width: 1.3,
      ),
      ExportColumn(
        id: 'vat',
        label: 'VAT',
        format: ExportFormat.money,
        value: (r) => r.vat,
        display: (r) => money(r.vat),
      ),
      ExportColumn(
        id: 'items',
        label: 'Items',
        format: ExportFormat.quantity,
        value: (r) => r.items,
        display: (r) => r.items == null ? _dash : f.quantity(r.items!),
        width: 0.7,
      ),
      if (departmentsEnabled)
        ExportColumn(
          id: 'department',
          label: 'Department',
          value: (r) => r.departmentLabel,
          width: 1.2,
        ),
      ExportColumn(
        id: 'comment',
        label: 'Comment',
        value: (r) => r.comment,
        display: (r) => r.comment ?? _dash,
        inPdf: false,
      ),
      ExportColumn(id: 'type', label: 'Type', value: (r) => r.type.label, width: 1.2),
      ExportColumn(
        id: 'balance',
        label: 'Balance',
        format: ExportFormat.money,
        value: (r) => r.balance,
        display: (r) => money(r.balance),
      ),
      if (canSeeCost) ...[
        ExportColumn(
          id: 'profit',
          label: 'Profit/Loss',
          format: ExportFormat.money,
          value: (r) => r.profit,
          display: (r) => r.profit == null ? 'N/A' : f.money(r.profit!),
          width: 1.2,
        ),
        ExportColumn(
          id: 'margin',
          label: 'Margin (%)',
          format: ExportFormat.percent,
          value: (r) => r.margin,
          display: (r) => r.margin == null ? 'N/A' : f.percent(r.margin!),
          width: 0.9,
        ),
        ExportColumn(
          id: 'costMissing',
          label: 'Cost Missing',
          value: (r) => r.profit == null ? _dash : (r.costMissing ? 'Yes' : 'No'),
          inPdf: false,
        ),
      ],
      ExportColumn(
        id: 'subtotal',
        label: 'Subtotal',
        format: ExportFormat.money,
        value: (r) => r.subtotal,
        display: (r) => money(r.subtotal),
        width: 1.2,
      ),
      ExportColumn(
        id: 'revenue',
        label: 'Total Revenue',
        format: ExportFormat.money,
        value: (r) => r.revenue,
        width: 1.3,
      ),
    ],
    totalsFor: (rs) => receiptsTotals(rs, canSeeCost: canSeeCost, f: f),
    splits: [
      staffSplit<ReceiptsReportRow>(
        rows: rows,
        staffId: (r) => r.staffKey,
        staffName: (r) => r.staffName,
      ),
      channelSplit<ReceiptsReportRow>(channel: (r) => r.channelLabel),
      if (departmentsEnabled)
        fieldSplit<ReceiptsReportRow>(
          id: 'department',
          label: 'Department',
          noneLabel: 'No Department',
          rows: rows,
          key: (r) => r.departmentKey,
          name: (r) => r.departmentName,
        ),
      customerSplit<ReceiptsReportRow>(
        rows: rows,
        customerId: (r) => r.customerKey,
        customerName: (r) => r.customerName,
      ),
    ],
    // 58mm: 15 / 16 characters, 80mm: 17 / 11 / 18, so
    // "#0000000000001" and "₦1,250,000.00" stay on one line.
    roll: const RollLayout(
      cols58: ['id', 'revenue'],
      cols80: ['id', 'staff', 'revenue'],
      sub80: ['date', 'channel'],
      flex58: [1, 1],
      flex80: [3, 2, 3],
    ),
    emptyMessage: 'No receipt matches the selected period and filters.',
  );
}

ExportTableSection<ReceiptsGroupRow> receiptsGroupSection({
  required List<ReceiptsGroupRow> groups,
  required ReportGroupBy groupBy,
  required ExportFormatter f,
  required bool canSeeCost,
}) {
  return ExportTableSection<ReceiptsGroupRow>(
    title: 'Receipts by ${groupBy.label}',
    rows: groups,
    columns: [
      ExportColumn(id: 'name', label: groupBy.label, value: (g) => g.label, width: 2),
      ExportColumn(
        id: 'receipts',
        label: 'Receipts',
        format: ExportFormat.integer,
        value: (g) => g.count,
        width: 0.8,
      ),
      ExportColumn(
        id: 'items',
        label: 'Items',
        format: ExportFormat.quantity,
        value: (g) => g.items,
        display: (g) => g.items == null ? _dash : f.quantity(g.items!),
        width: 0.8,
      ),
      ExportColumn(
        id: 'balance',
        label: 'Balance',
        format: ExportFormat.money,
        value: (g) => g.balance,
      ),
      ExportColumn(
        id: 'revenue',
        label: 'Total Revenue',
        format: ExportFormat.money,
        value: (g) => g.revenue,
        width: 1.2,
      ),
      if (canSeeCost) ...[
        ExportColumn(
          id: 'profit',
          label: 'Profit/Loss',
          format: ExportFormat.money,
          value: (g) => g.profitUnknown ? null : g.profit,
          display: (g) => g.profitUnknown ? 'N/A' : f.money(g.profit),
          width: 1.2,
        ),
        ExportColumn(
          id: 'margin',
          label: 'Margin (%)',
          format: ExportFormat.percent,
          value: (g) => g.margin,
          display: (g) => g.margin == null ? 'N/A' : f.percent(g.margin!),
        ),
      ],
    ],
    // The screen's ReceiptsGroupPage totals.
    totalsFor: (gs) {
      final page = ReceiptsGrouping.paginate(gs, 1);
      final m = page.totalMargin;
      return {
        'name': '${f.integer(gs.length)} ${groupBy.pagerLabel}',
        'receipts': page.totalReceipts,
        if (page.totalItems != null) 'items': page.totalItems,
        'balance': page.totalBalance,
        'revenue': page.totalRevenue,
        if (canSeeCost && page.totalProfitCount > 0) 'profit': page.totalProfit,
        if (canSeeCost && m != null) 'margin': m,
      };
    },
    // 58mm: 15 / 16 characters, 80mm: 23 / 5 / 18.
    roll: const RollLayout(
      cols58: ['name', 'revenue'],
      cols80: ['name', 'receipts', 'revenue'],
      flex58: [1, 1],
      flex80: [4, 1, 3],
    ),
    emptyMessage: 'No receipt matches the selected period and filters.',
  );
}

/// [rows] is the full filtered and sorted receipt list; [groups] the
/// full sorted group list (used when [groupBy] is not off).
ReportExportSpec receiptsReportExportSpec({
  required List<ReceiptsReportRow> rows,
  required List<ReceiptsGroupRow> groups,
  required ReportGroupBy groupBy,
  required ReceiptsReportFilters filters,
  required ReceiptsFilterChoices choices,
  required ReceiptsReportPeriod period,
  required ReceiptsSortField sortField,
  required bool ascending,
  required ReceiptsTableGroupSortField groupSortField,
  required bool groupAscending,
  required int profitExcluded,
  required String currency,
  required bool canSeeCost,
  required bool departmentsEnabled,
  required bool subStaffEnabled,
}) {
  final f = ExportFormatter(currency: currency);
  final grouped = groupBy != ReportGroupBy.off;
  return ReportExportSpec(
    reportName: 'Receipts Report',
    fileSlug: 'receipts_report',
    period: ExportPeriod(
      label: receiptsPeriodLabel(period),
      start: period.start,
      end: period.end,
    ),
    filters: receiptsExportFilters(
      filters: filters,
      choices: choices,
      departmentsEnabled: departmentsEnabled,
      subStaffEnabled: subStaffEnabled,
      profitVisible: canSeeCost,
      f: f,
    ),
    sortedBy: grouped
        ? receiptsGroupSortLabel(groupSortField, groupAscending, groupBy)
        : receiptsSortLabel(sortField, ascending),
    groupedBy: grouped ? groupBy.label : null,
    notes: receiptsReportNotes(period: period, profitExcluded: profitExcluded),
    sections: [
      if (grouped)
        receiptsGroupSection(
          groups: groups,
          groupBy: groupBy,
          f: f,
          canSeeCost: canSeeCost,
        )
      else
        receiptsTableSection(
          rows: rows,
          f: f,
          canSeeCost: canSeeCost,
          departmentsEnabled: departmentsEnabled,
          subStaffEnabled: subStaffEnabled,
        ),
    ],
  );
}
