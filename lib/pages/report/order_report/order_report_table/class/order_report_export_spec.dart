// Export spec of the Order Report table, grouping-aware: the order rows
// (the full filtered and sorted list, not the page) when Group by is
// off, or the group table the user sees when it is on. Totals are the
// screen's own (OrderReportTotals).

import 'package:stockall/pages/report/components/export/report_export_format.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/export/report_export_splits.dart';
import 'package:stockall/pages/report/components/report_group_by.dart';
import 'package:stockall/pages/report/order_report/order_report_table/class/order_report_table_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/components/receipts_report_filter_widgets.dart'
    show receiptsPeriodLabel;

const String _dash = '—';

/// The notes the Order table and Order summary show under their
/// toolbar. The views draw these and the export carries them, so they
/// always match.
List<String> orderReportNotes({required ReceiptsReportPeriod period}) => [
  if (period.isAllTime) 'All time covers the orders loaded on this device.',
];

/// The Notes column: why an order's quantities need a second look.
String orderRowNote(OrderReportRow r) {
  if (r.recordsDisagree) return 'Records disagree';
  if (r.delivery.receiptLinesUnavailable) return 'Receipt lines unavailable';
  return _dash;
}

/// "Est. ₦x" until every counted order is Fully Delivered, "N/A"
/// without a cost, as the Profit/Loss cells show it.
String orderProfitText(double? profit, bool estimate, ExportFormatter f) {
  if (profit == null) return 'N/A';
  return estimate ? 'Est. ${f.money(profit)}' : f.money(profit);
}

const Map<OrderSortField, String> orderSortLabels = {
  OrderSortField.id: 'ID',
  OrderSortField.createdAt: 'Date',
  OrderSortField.staff: 'Staff',
  OrderSortField.subStaff: 'Sub-Staff',
  OrderSortField.customer: 'Customer',
  OrderSortField.department: 'Department',
  OrderSortField.items: 'Items',
  OrderSortField.delivered: 'Delivered',
  OrderSortField.status: 'Status',
  OrderSortField.channel: 'Channel',
  OrderSortField.total: 'Total',
  OrderSortField.deliveredValue: 'Delivered Value',
  OrderSortField.undeliveredValue: 'Undelivered Value',
  OrderSortField.paid: 'Paid',
  OrderSortField.balance: 'Balance',
  OrderSortField.cost: 'Cost',
  OrderSortField.profit: 'Profit/Loss',
  OrderSortField.margin: 'Margin (%)',
};

String _dir(bool ascending) => ascending ? 'ascending' : 'descending';

String orderSortLabel(OrderSortField field, bool ascending) =>
    '${orderSortLabels[field] ?? field.name} (${_dir(ascending)})';

String orderGroupSortLabel(
  OrderGroupSortField field,
  bool ascending,
  ReportGroupBy groupBy,
) {
  final label = switch (field) {
    OrderGroupSortField.name => groupBy.label,
    OrderGroupSortField.count => 'Orders',
    OrderGroupSortField.total => 'Total',
    OrderGroupSortField.deliveredValue => 'Delivered Value',
    OrderGroupSortField.undeliveredValue => 'Undelivered Value',
    OrderGroupSortField.paid => 'Paid',
    OrderGroupSortField.balance => 'Balance',
  };
  return '$label (${_dir(ascending)})';
}

/// The table's filters with their values, worded and ordered like its
/// chips (search first, as the search box shows it).
List<ExportFilter> orderExportFilters({
  required OrderReportFilters filters,
  required List<OrderReportFilterOption> staffOptions,
  required List<OrderReportFilterOption> customerOptions,
  required List<OrderReportFilterOption> subStaffOptions,
  required List<OrderReportFilterOption> departmentOptions,
  required bool departmentsEnabled,
  required bool subStaffEnabled,
  required bool profitVisible,
  required ExportFormatter f,
}) {
  String range(double? min, double? max) =>
      '${min != null ? f.money(min) : 'Any'} - ${max != null ? f.money(max) : 'Any'}';
  final out = <ExportFilter>[];
  void key(String title, String? k, List<OrderReportFilterOption> options) {
    if (k == null) return;
    out.add(ExportFilter(title, OrderReportOptions.labelFor(options, k, title)));
  }

  void rangeOf(String title, double? min, double? max) {
    if (min == null && max == null) return;
    out.add(ExportFilter(title, range(min, max)));
  }

  final search = filters.search.trim();
  if (search.isNotEmpty) out.add(ExportFilter('Search', search));
  if (filters.deliveryStatus != null) {
    out.add(ExportFilter('Status', filters.deliveryStatus!.label));
  }
  if (filters.recordsDisagree) out.add(const ExportFilter('Records', 'Records disagree only'));
  if (filters.channel != null) out.add(ExportFilter('Channel', filters.channel!.label));
  key('Staff', filters.staffKey, staffOptions);
  key('Customer', filters.customerKey, customerOptions);
  if (subStaffEnabled) key('Sub-Staff', filters.subStaffKey, subStaffOptions);
  if (departmentsEnabled) key('Department', filters.departmentKey, departmentOptions);
  rangeOf('Total', filters.totalMin, filters.totalMax);
  rangeOf('Paid', filters.paidMin, filters.paidMax);
  rangeOf('Balance', filters.balanceMin, filters.balanceMax);
  if (profitVisible) rangeOf('Profit/Loss', filters.profitMin, filters.profitMax);
  return out;
}

/// The screen's totals row (OrderReportTotals) by column id.
Map<String, Object?> orderTotals(
  List<OrderReportRow> rows, {
  required bool canSeeCost,
  required ExportFormatter f,
}) {
  final t = OrderReportQuery.paginate(rows, 1).totals;
  return {
    'id': '${f.integer(t.count)} ${t.count == 1 ? 'order' : 'orders'}',
    'total': t.total,
    'deliveredValue': t.deliveredValue,
    'undeliveredValue': t.undeliveredValue,
    'paid': t.paid,
    'balance': t.balance,
    if (canSeeCost) ...{
      'cost': t.cost ?? 'N/A',
      'profit': t.profit == null || t.profitIsEstimate
          ? orderProfitText(t.profit, t.profitIsEstimate, f)
          : t.profit,
    },
  };
}

ExportTableSection<OrderReportRow> orderTableSection({
  required List<OrderReportRow> rows,
  required ExportFormatter f,
  required bool canSeeCost,
  required bool departmentsEnabled,
  required bool subStaffEnabled,
}) {
  String items(double? v) => v == null ? _dash : f.quantity(v);
  String value(double? v) => v == null ? _dash : f.money(v);

  return ExportTableSection<OrderReportRow>(
    title: 'Orders',
    rows: rows,
    columns: [
      ExportColumn(id: 'id', label: 'ID', value: (r) => r.displayId, width: 1.4),
      ExportColumn(id: 'staff', label: 'Staff', value: (r) => r.staffLabel, width: 1.2),
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
        width: 1.3,
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
        inPdf: false,
      ),
      if (departmentsEnabled)
        ExportColumn(
          id: 'department',
          label: 'Department',
          value: (r) => r.departmentLabel,
          width: 1.2,
        ),
      ExportColumn(
        id: 'status',
        label: 'Status',
        value: (r) => r.status?.label ?? _dash,
        width: 1.3,
      ),
      ExportColumn(
        id: 'items',
        label: 'Items',
        format: ExportFormat.quantity,
        value: (r) => r.delivery.orderedItems,
        display: (r) => items(r.delivery.orderedItems),
        width: 0.7,
      ),
      ExportColumn(
        id: 'delivered',
        label: 'Delivered',
        format: ExportFormat.quantity,
        value: (r) => r.delivery.deliveredItems,
        display: (r) => items(r.delivery.deliveredItems),
        width: 0.8,
      ),
      ExportColumn(id: 'channel', label: 'Channel', value: (r) => r.channel.label),
      ExportColumn(
        id: 'discount',
        label: 'Discount',
        format: ExportFormat.money,
        value: (r) => r.discountAmount,
        display: (r) {
          if (r.discountAmount <= 0) return _dash;
          final pct = r.order.generalDiscount;
          final showPct = (r.order.fixedDiscount ?? 0) <= 0 && pct != null;
          return showPct
              ? '${f.money(r.discountAmount)} (${f.percent(pct)})'
              : f.money(r.discountAmount);
        },
        inPdf: false,
      ),
      ExportColumn(
        id: 'vat',
        label: 'VAT',
        format: ExportFormat.money,
        value: (r) => r.vatAmount,
        display: (r) => r.vatAmount <= 0 ? _dash : f.money(r.vatAmount),
        inPdf: false,
      ),
      ExportColumn(
        id: 'total',
        label: 'Total',
        format: ExportFormat.money,
        value: (r) => r.total,
        width: 1.3,
      ),
      ExportColumn(
        id: 'deliveredValue',
        label: 'Delivered Value',
        format: ExportFormat.money,
        value: (r) => r.deliveredValue,
        display: (r) => value(r.deliveredValue),
        width: 1.3,
      ),
      ExportColumn(
        id: 'undeliveredValue',
        label: 'Undelivered Value',
        format: ExportFormat.money,
        value: (r) => r.undeliveredValue,
        display: (r) => value(r.undeliveredValue),
        width: 1.3,
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
      if (canSeeCost) ...[
        ExportColumn(
          id: 'cost',
          label: 'Cost',
          format: ExportFormat.money,
          value: (r) => r.cost,
          display: (r) => r.cost == null ? 'N/A' : f.money(r.cost!),
          inPdf: false,
        ),
        ExportColumn(
          id: 'profit',
          label: 'Profit/Loss',
          format: ExportFormat.money,
          value: (r) => r.profit,
          display: (r) => orderProfitText(r.profit, r.profitIsEstimate, f),
          width: 1.4,
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
          id: 'estimate',
          label: 'Est. Profit',
          value: (r) => r.profit == null ? _dash : (r.profitIsEstimate ? 'Yes' : 'No'),
          inPdf: false,
        ),
      ],
      ExportColumn(id: 'notes', label: 'Notes', value: orderRowNote, width: 1.4),
      ExportColumn(
        id: 'comment',
        label: 'Comment',
        value: (r) => r.comment,
        display: (r) => r.comment ?? _dash,
        inPdf: false,
      ),
    ],
    totalsFor: (rs) => orderTotals(rs, canSeeCost: canSeeCost, f: f),
    splits: [
      staffSplit<OrderReportRow>(
        rows: rows,
        staffId: (r) => r.staffKey,
        staffName: (r) => r.staffName,
      ),
      channelSplit<OrderReportRow>(channel: (r) => r.channel.label),
      labelSplit<OrderReportRow>(
        id: 'deliveryStatus',
        label: 'Delivery Status',
        noneLabel: 'No Status',
        value: (r) => r.status?.label,
      ),
      if (departmentsEnabled)
        fieldSplit<OrderReportRow>(
          id: 'department',
          label: 'Department',
          noneLabel: 'No Department',
          rows: rows,
          key: (r) => r.departmentKey,
          name: (r) => r.departmentName,
        ),
      customerSplit<OrderReportRow>(
        rows: rows,
        customerId: (r) => r.customerKey,
        customerName: (r) => r.customerName,
      ),
    ],
    // 58mm: 15 / 16 characters. 80mm: 14 / 13 / 19 after the gaps, so
    // "#0000000000001", "₦1,250,000.00" and "Partially Delivered"
    // stay on one line.
    roll: const RollLayout(
      cols58: ['id', 'total'],
      cols80: ['id', 'total', 'status'],
      sub80: ['customer', 'date'],
      flex58: [1, 1],
      flex80: [15, 14, 19],
    ),
    emptyMessage: 'No order matches the selected period and filters.',
  );
}

ExportTableSection<OrderReportGroupRow> orderGroupSection({
  required List<OrderReportGroupRow> groups,
  required List<OrderReportRow> rows,
  required ReportGroupBy groupBy,
  required ExportFormatter f,
  required bool canSeeCost,
}) {
  final t = OrderReportGrouping.paginate(groups, rows, 1).totals;
  return ExportTableSection<OrderReportGroupRow>(
    title: 'Orders by ${groupBy.label}',
    rows: groups,
    columns: [
      ExportColumn(id: 'name', label: groupBy.label, value: (g) => g.label, width: 2),
      ExportColumn(
        id: 'orders',
        label: 'Orders',
        format: ExportFormat.integer,
        value: (g) => g.count,
        width: 0.8,
      ),
      ExportColumn(
        id: 'total',
        label: 'Total',
        format: ExportFormat.money,
        value: (g) => g.total,
        width: 1.2,
      ),
      ExportColumn(
        id: 'deliveredValue',
        label: 'Delivered Value',
        format: ExportFormat.money,
        value: (g) => g.deliveredValue,
        width: 1.2,
      ),
      ExportColumn(
        id: 'undeliveredValue',
        label: 'Undelivered Value',
        format: ExportFormat.money,
        value: (g) => g.undeliveredValue,
        width: 1.2,
      ),
      ExportColumn(
        id: 'paid',
        label: 'Paid',
        format: ExportFormat.money,
        value: (g) => g.paid,
      ),
      ExportColumn(
        id: 'balance',
        label: 'Balance',
        format: ExportFormat.money,
        value: (g) => g.balance,
      ),
      if (canSeeCost)
        ExportColumn(
          id: 'profit',
          label: 'Profit/Loss',
          format: ExportFormat.money,
          value: (g) => g.profit,
          display: (g) => orderProfitText(g.profit, g.profitIsEstimate, f),
          width: 1.4,
        ),
    ],
    // The screen's OrderReportGroupPage totals, which need the rows.
    totals: {
      'name': '${f.integer(groups.length)} ${groupBy.pagerLabel}',
      'orders': t.count,
      'total': t.total,
      'deliveredValue': t.deliveredValue,
      'undeliveredValue': t.undeliveredValue,
      'paid': t.paid,
      'balance': t.balance,
      if (canSeeCost)
        'profit': t.profit == null || t.profitIsEstimate
            ? orderProfitText(t.profit, t.profitIsEstimate, f)
            : t.profit,
    },
    // 58mm: 15 / 16 characters, 80mm: 23 / 5 / 18.
    roll: const RollLayout(
      cols58: ['name', 'total'],
      cols80: ['name', 'orders', 'total'],
      flex58: [1, 1],
      flex80: [4, 1, 3],
    ),
    emptyMessage: 'No order matches the selected period and filters.',
  );
}

/// [rows] is the full filtered and sorted order list; [groups] the
/// full sorted group list (used when [groupBy] is not off).
ReportExportSpec orderReportExportSpec({
  required List<OrderReportRow> rows,
  required List<OrderReportGroupRow> groups,
  required ReportGroupBy groupBy,
  required OrderReportFilters filters,
  required List<OrderReportFilterOption> staffOptions,
  required List<OrderReportFilterOption> customerOptions,
  required List<OrderReportFilterOption> subStaffOptions,
  required List<OrderReportFilterOption> departmentOptions,
  required ReceiptsReportPeriod period,
  required OrderSortField sortField,
  required bool ascending,
  required OrderGroupSortField groupSortField,
  required bool groupAscending,
  required String currency,
  required bool canSeeCost,
  required bool departmentsEnabled,
  required bool subStaffEnabled,
}) {
  final f = ExportFormatter(currency: currency);
  final grouped = groupBy != ReportGroupBy.off;
  return ReportExportSpec(
    reportName: 'Order Report',
    fileSlug: 'order_report',
    period: ExportPeriod(
      label: receiptsPeriodLabel(period),
      start: period.start,
      end: period.end,
    ),
    filters: orderExportFilters(
      filters: filters,
      staffOptions: staffOptions,
      customerOptions: customerOptions,
      subStaffOptions: subStaffOptions,
      departmentOptions: departmentOptions,
      departmentsEnabled: departmentsEnabled,
      subStaffEnabled: subStaffEnabled,
      profitVisible: canSeeCost,
      f: f,
    ),
    sortedBy: grouped
        ? orderGroupSortLabel(groupSortField, groupAscending, groupBy)
        : orderSortLabel(sortField, ascending),
    groupedBy: grouped ? groupBy.label : null,
    notes: orderReportNotes(period: period),
    sections: [
      if (grouped)
        orderGroupSection(
          groups: groups,
          rows: rows,
          groupBy: groupBy,
          f: f,
          canSeeCost: canSeeCost,
        )
      else
        orderTableSection(
          rows: rows,
          f: f,
          canSeeCost: canSeeCost,
          departmentsEnabled: departmentsEnabled,
          subStaffEnabled: subStaffEnabled,
        ),
    ],
  );
}
