// Export spec of the Order Summary page: its statistic cards, the
// delivery status counts (Unknown included when the screen shows it),
// the top customers by undelivered value and the breakdown tables.
// Charts aren't exported. Every input is the screen's own
// OrderSummaryResult.

import 'package:stockall/pages/report/components/export/report_export_format.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/order_report/order_report_table/class/order_report_export_spec.dart';
import 'package:stockall/pages/report/order_report/order_report_table/class/order_report_table_logic.dart';
import 'package:stockall/pages/report/order_report/order_summary/class/order_summary_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/components/receipts_report_filter_widgets.dart'
    show receiptsPeriodLabel;

const String _dash = '—';

/// The Status tab's rows, as the view builds them: Fully Delivered,
/// Partially Delivered and Undelivered, always, then Unknown when some
/// orders have no status.
List<OrderReportGroupRow> orderStatusBreakdown(List<OrderReportRow> rows) {
  OrderReportGroupRow build(String key, String label, Iterable<OrderReportRow> rs) {
    final g = OrderReportGroupRow(key: key, isNone: false, name: label);
    for (final r in rs) {
      g.add(r);
    }
    return g;
  }

  final unknown = rows.where((r) => r.status == null).toList();
  return [
    for (final s in OrderDeliveryStatus.values.reversed)
      build(s.name, s.label, rows.where((r) => r.status == s)),
    if (unknown.isNotEmpty) build('unknown', 'Unknown', unknown),
  ];
}

ExportTableSection<OrderReportGroupRow> _breakdown({
  required String title,
  required String nameLabel,
  required List<OrderReportGroupRow> groups,
  required ExportFormatter f,
  required bool canSeeCost,
  required bool lastOrder,
}) {
  ExportColumn<OrderReportGroupRow> money(
    String id,
    String label,
    double Function(OrderReportGroupRow) v,
  ) => ExportColumn(
    id: id,
    label: label,
    format: ExportFormat.money,
    value: v,
    width: 1.2,
  );

  return ExportTableSection<OrderReportGroupRow>(
    title: title,
    rows: groups,
    columns: [
      ExportColumn(id: 'name', label: nameLabel, value: (g) => g.label, width: 2),
      ExportColumn(
        id: 'orders',
        label: 'Orders',
        format: ExportFormat.integer,
        value: (g) => g.count,
        width: 0.7,
      ),
      money('total', 'Total', (g) => g.total),
      money('delivered', 'Delivered', (g) => g.deliveredValue),
      money('undelivered', 'Undelivered', (g) => g.undeliveredValue),
      money('paid', 'Paid', (g) => g.paid),
      money('balance', 'Balance', (g) => g.balance),
      if (canSeeCost)
        ExportColumn(
          id: 'profit',
          label: 'Profit',
          format: ExportFormat.money,
          value: (g) => g.profit,
          display: (g) => orderProfitText(g.profit, g.profitIsEstimate, f),
          width: 1.4,
        ),
      if (lastOrder)
        ExportColumn(
          id: 'lastOrder',
          label: 'Last order',
          format: ExportFormat.date,
          value: (g) => g.lastOrderAt,
          display: (g) => g.lastOrderAt == null ? _dash : f.date(g.lastOrderAt!),
        ),
    ],
    // 58mm: 15 / 16 characters, 80mm: 23 / 5 / 18.
    roll: const RollLayout(
      cols58: ['name', 'total'],
      cols80: ['name', 'orders', 'total'],
      flex58: [1, 1],
      flex80: [4, 1, 3],
    ),
    emptyMessage: 'No orders in this period.',
  );
}

ReportExportSpec orderSummaryExportSpec({
  required OrderSummaryResult result,
  required ReceiptsReportPeriod period,
  required String currency,
  required bool canSeeCost,
  required bool departmentsEnabled,
  required bool subStaffEnabled,
}) {
  final f = ExportFormatter(currency: currency);
  final s = result.stats;
  final top = result.topUndeliveredCustomers;
  final rank = Map<OrderReportGroupRow, int>.identity();
  for (var i = 0; i < top.length; i++) {
    rank[top[i]] = i + 1;
  }

  ExportMetric count(String label, int v, {String? note}) => ExportMetric(
    label: label,
    value: v,
    format: ExportFormat.integer,
    note: note,
  );
  String share(int n) =>
      f.percent(s.orderCount > 0 ? n / s.orderCount * 100 : 0);

  return ReportExportSpec(
    reportName: 'Order Summary',
    fileSlug: 'order_summary',
    period: ExportPeriod(
      label: receiptsPeriodLabel(period),
      start: period.start,
      end: period.end,
    ),
    notes: orderReportNotes(period: period),
    sections: [
      ExportSummarySection(
        title: 'Statistics',
        metrics: [
          count(
            'Orders',
            s.orderCount,
            note: '${s.fullyDelivered} full · ${s.partiallyDelivered} partial · '
                '${s.undelivered} undelivered',
          ),
          ExportMetric(label: 'Order Value', value: s.totalValue),
          ExportMetric(label: 'Delivered Value', value: s.deliveredValue),
          ExportMetric(label: 'Undelivered Value', value: s.undeliveredValue),
          ExportMetric(label: 'Paid', value: s.paid),
          ExportMetric(label: 'Balance', value: s.balance),
          if (canSeeCost)
            ExportMetric(
              label: s.profitIsEstimate ? 'Est. Profit' : 'Profit',
              value: s.profit ?? 'N/A',
              format: s.profit == null ? ExportFormat.text : ExportFormat.money,
              note: s.margin == null
                  ? 'No cost price on the items'
                  : 'Margin ${f.percent(s.margin!)}',
            ),
          count('Records Disagree', s.recordsDisagree),
        ],
      ),
      ExportSummarySection(
        title: 'Delivery Status',
        metrics: [
          count(OrderDeliveryStatus.full.label, s.fullyDelivered,
              note: share(s.fullyDelivered)),
          count(OrderDeliveryStatus.partial.label, s.partiallyDelivered,
              note: share(s.partiallyDelivered)),
          count(OrderDeliveryStatus.undelivered.label, s.undelivered,
              note: share(s.undelivered)),
          if (s.unavailable > 0)
            count('Unknown', s.unavailable, note: share(s.unavailable)),
        ],
      ),
      ExportTableSection<OrderReportGroupRow>(
        title: 'Top Customers by Undelivered Value',
        rows: top,
        columns: [
          ExportColumn(
            id: 'no',
            label: 'No.',
            format: ExportFormat.integer,
            value: (g) => rank[g],
            width: 0.5,
          ),
          ExportColumn(id: 'name', label: 'Customer', value: (g) => g.label, width: 2),
          ExportColumn(
            id: 'orders',
            label: 'Orders',
            format: ExportFormat.integer,
            value: (g) => g.count,
            width: 0.7,
          ),
          ExportColumn(
            id: 'total',
            label: 'Total',
            format: ExportFormat.money,
            value: (g) => g.total,
            width: 1.2,
          ),
          ExportColumn(
            id: 'undelivered',
            label: 'Undelivered',
            format: ExportFormat.money,
            value: (g) => g.undeliveredValue,
            width: 1.2,
          ),
        ],
        roll: const RollLayout(
          cols58: ['name', 'undelivered'],
          cols80: ['no', 'name', 'undelivered'],
          flex58: [1, 1],
          flex80: [1, 4, 4],
        ),
        emptyMessage: 'No customer has undelivered orders.',
      ),
      _breakdown(
        title: 'Customers',
        nameLabel: 'Customers',
        groups: result.customers,
        f: f,
        canSeeCost: canSeeCost,
        lastOrder: true,
      ),
      _breakdown(
        title: 'Staff',
        nameLabel: 'Staff',
        groups: result.staff,
        f: f,
        canSeeCost: canSeeCost,
        lastOrder: true,
      ),
      if (departmentsEnabled)
        _breakdown(
          title: 'Departments',
          nameLabel: 'Departments',
          groups: result.departments,
          f: f,
          canSeeCost: canSeeCost,
          lastOrder: true,
        ),
      if (subStaffEnabled)
        _breakdown(
          title: 'Sub-Staff',
          nameLabel: 'Sub-Staff',
          groups: result.subStaff,
          f: f,
          canSeeCost: canSeeCost,
          lastOrder: true,
        ),
      _breakdown(
        title: 'Status',
        nameLabel: 'Status',
        groups: orderStatusBreakdown(result.rows),
        f: f,
        canSeeCost: canSeeCost,
        lastOrder: false,
      ),
      _breakdown(
        title: 'Channel',
        nameLabel: 'Channel',
        groups: result.channels,
        f: f,
        canSeeCost: canSeeCost,
        lastOrder: false,
      ),
    ],
  );
}
