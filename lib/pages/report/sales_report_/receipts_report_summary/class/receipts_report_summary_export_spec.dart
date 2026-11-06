// Export spec of the Receipt Summary page: its statistic cards and the
// tables under them (rankings, channels, types, departments, customers,
// staff, sub-staff). Charts aren't exported. Every input is the screen's
// own builder output.

import 'package:stockall/pages/report/components/export/report_export_format.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_export_spec.dart'
    show receiptsExportFilters;
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/components/receipts_report_filter_widgets.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_summary/class/receipts_report_summary_logic.dart';

const String _dash = '—';

/// The notes the summary shows under its toolbar. The view draws these
/// and the export carries them, so they always match.
List<String> receiptsSummaryNotes({
  required ReceiptsReportPeriod period,
  required ReceiptsSummaryStats stats,
  required bool canSeeCost,
}) {
  final s = stats;
  return [
    if (period.isAllTime)
      'All time covers the receipts loaded on this device.',
    'Revenue counts every receipt type (sales, invoice '
        'payments and order deliveries); the average is per '
        'Sales receipt.',
    if (canSeeCost && (s.profitUnknownCount > 0 || s.costMissingCount > 0))
      'Profit is from ${s.profitKnownCount} of '
          '${s.totalReceipts} receipts: '
          '${s.profitUnknownCount} without item data, '
          '${s.costMissingCount} with a missing cost price '
          '(counted as 0).',
  ];
}

const RollLayout _groupRoll = RollLayout(
  cols58: ['name', 'revenue'],
  cols80: ['no', 'name', 'revenue'],
  flex58: [1, 1],
  flex80: [1, 4, 4],
);

/// A group table as the screen draws it (`_groupColumns`).
ExportTableSection<ReceiptsSummaryGroup> _groupTable({
  required String title,
  required String nameLabel,
  required List<ReceiptsSummaryGroup> groups,
  required ExportFormatter f,
  required bool canSeeCost,
  bool average = true,
  bool share = false,
  bool lastDate = false,
}) {
  final no = Map<ReceiptsSummaryGroup, int>.identity();
  for (var i = 0; i < groups.length; i++) {
    no[groups[i]] = i + 1;
  }
  return ExportTableSection<ReceiptsSummaryGroup>(
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
      ExportColumn(id: 'name', label: nameLabel, value: (g) => g.label, width: 2),
      ExportColumn(
        id: 'receipts',
        label: 'Receipts',
        format: ExportFormat.integer,
        value: (g) => g.receiptCount,
        width: 0.8,
      ),
      ExportColumn(
        id: 'revenue',
        label: 'Total Revenue',
        format: ExportFormat.money,
        value: (g) => g.revenue,
        width: 1.3,
      ),
      if (canSeeCost)
        ExportColumn(
          id: 'profit',
          label: 'Profit/Loss',
          format: ExportFormat.money,
          value: (g) => g.knownProfit,
          width: 1.3,
        ),
      if (average)
        ExportColumn(
          id: 'average',
          label: 'Avg Receipt',
          format: ExportFormat.money,
          value: (g) => g.salesCount == 0 ? null : g.average,
          display: (g) => g.salesCount == 0 ? _dash : f.money(g.average),
        ),
      if (share)
        ExportColumn(
          id: 'share',
          label: '% of Revenue',
          format: ExportFormat.percent,
          value: (g) => g.revenueShare,
          display: (g) =>
              g.revenueShare == null ? 'N/A' : f.percent(g.revenueShare!),
        ),
      if (lastDate)
        ExportColumn(
          id: 'lastDate',
          label: 'Last Purchase',
          format: ExportFormat.date,
          value: (g) => g.lastDate,
          display: (g) => g.lastDate == null ? _dash : f.date(g.lastDate!),
        ),
    ],
    roll: _groupRoll,
    emptyMessage: 'No receipt in this period.',
  );
}

/// [customers] is in the screen's Customer Summary sort; every customer
/// is exported (the screen previews 20).
ReportExportSpec receiptsSummaryExportSpec({
  required ReceiptsSummaryStats stats,
  required List<ReceiptsSummaryGroup> customers,
  required List<ReceiptsSummaryGroup> staff,
  required List<ReceiptsSummaryGroup> subStaff,
  required List<ReceiptsSummaryGroup> departments,
  required List<ReceiptsChannelSummary> channels,
  required List<ReceiptsTypeSummary> types,
  required ReceiptsReportFilters filters,
  required ReceiptsFilterChoices choices,
  required ReceiptsReportPeriod period,
  required String currency,
  required bool canSeeCost,
  required bool departmentsEnabled,
  required bool subStaffEnabled,
}) {
  final f = ExportFormatter(currency: currency);
  final s = stats;
  final unknown = s.typeCount(ReceiptType.unknown);
  ExportMetric count(String label, int v, {String? note}) => ExportMetric(
    label: label,
    value: v,
    format: ExportFormat.integer,
    note: note,
  );
  ExportMetric money(String label, double v, {String? note}) =>
      ExportMetric(label: label, value: v, note: note);

  final channelNo = <ReceiptsChannelSummary, int>{
    for (var i = 0; i < channels.length; i++) channels[i]: i + 1,
  };
  final typeNo = <ReceiptsTypeSummary, int>{
    for (var i = 0; i < types.length; i++) types[i]: i + 1,
  };

  return ReportExportSpec(
    reportName: 'Receipts Summary',
    fileSlug: 'receipts_summary',
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
    notes: receiptsSummaryNotes(
      period: period,
      stats: stats,
      canSeeCost: canSeeCost,
    ),
    sections: [
      ExportSummarySection(
        title: 'Statistics',
        metrics: [
          count(
            'Total Receipts',
            s.totalReceipts,
            note: unknown > 0 ? '$unknown of unknown type' : null,
          ),
          count('Sales Receipts', s.typeCount(ReceiptType.sales)),
          count('Invoice Payments', s.typeCount(ReceiptType.invoicePayment)),
          count('Order Deliveries', s.typeCount(ReceiptType.orderDelivery)),
          money('Total Revenue', s.totalRevenue, note: 'All receipt types'),
          if (canSeeCost)
            money(
              'Total Profit/Loss',
              s.knownProfit,
              note: 'From ${s.profitKnownCount} of ${s.totalReceipts} receipts',
            ),
          money(
            'Average Receipt Value',
            s.averageReceiptValue,
            note: 'Per Sales receipt',
          ),
          money('Total Discounts', s.totalDiscount, note: 'Sales receipts'),
          money('Total VAT', s.totalVat, note: 'Sales receipts'),
          ExportMetric(
            label: 'Total Items Sold',
            value: s.totalItems,
            format: ExportFormat.quantity,
            note: 'Invoice payments not counted',
          ),
          count(
            'Total Customers',
            s.distinctCustomers,
            note: s.walkInReceipts > 0
                ? '+ ${s.walkInReceipts} walk-in receipts'
                : null,
          ),
          count(
            'Total Staff Involved',
            s.distinctStaff,
            note: s.noStaffReceipts > 0
                ? '+ ${s.noStaffReceipts} receipts without staff'
                : null,
          ),
          for (final c in ReceiptChannel.values)
            count('${c.label} Transactions', s.channelCount(c)),
        ],
      ),
      _groupTable(
        title: 'Top 3 Customers',
        nameLabel: 'Customer',
        groups: ReceiptsSummaryBuilder.top3(customers),
        f: f,
        canSeeCost: canSeeCost,
      ),
      _groupTable(
        title: 'Least 3 Customers',
        nameLabel: 'Customer',
        groups: ReceiptsSummaryBuilder.least3(customers),
        f: f,
        canSeeCost: canSeeCost,
        average: false,
      ),
      _groupTable(
        title: 'Top 3 Staff',
        nameLabel: 'Staff',
        groups: ReceiptsSummaryBuilder.top3(staff),
        f: f,
        canSeeCost: canSeeCost,
      ),
      _groupTable(
        title: 'Least 3 Staff',
        nameLabel: 'Staff',
        groups: ReceiptsSummaryBuilder.least3(staff),
        f: f,
        canSeeCost: canSeeCost,
        average: false,
      ),
      ExportTableSection<ReceiptsChannelSummary>(
        title: 'Payment Channel Summary',
        rows: channels,
        columns: [
          ExportColumn(
            id: 'no',
            label: 'No.',
            format: ExportFormat.integer,
            value: (c) => channelNo[c],
            width: 0.5,
          ),
          ExportColumn(
            id: 'name',
            label: 'Channel',
            value: (c) => c.channel.label,
            width: 1.6,
          ),
          ExportColumn(
            id: 'receipts',
            label: 'Receipts',
            format: ExportFormat.integer,
            value: (c) => c.receiptCount,
          ),
          ExportColumn(
            id: 'revenue',
            label: 'Value',
            format: ExportFormat.money,
            value: (c) => c.value,
            width: 1.3,
          ),
          ExportColumn(
            id: 'countShare',
            label: '% of Receipts',
            format: ExportFormat.percent,
            value: (c) => c.countShare,
            display: (c) => c.countShare == null ? 'N/A' : f.percent(c.countShare!),
          ),
          ExportColumn(
            id: 'valueShare',
            label: '% of Value',
            format: ExportFormat.percent,
            value: (c) => c.valueShare,
            display: (c) => c.valueShare == null ? 'N/A' : f.percent(c.valueShare!),
          ),
        ],
        roll: _groupRoll,
      ),
      ExportSummarySection(
        title: 'Collected by Method',
        metrics: [
          money('Cash', s.collectedCash),
          money('Bank', s.collectedBank),
          money('Customer Account', s.collectedAccount),
        ],
      ),
      ExportTableSection<ReceiptsTypeSummary>(
        title: 'Transaction Type Summary',
        rows: types,
        columns: [
          ExportColumn(
            id: 'no',
            label: 'No.',
            format: ExportFormat.integer,
            value: (t) => typeNo[t],
            width: 0.5,
          ),
          ExportColumn(id: 'name', label: 'Type', value: (t) => t.type.label, width: 1.6),
          ExportColumn(
            id: 'receipts',
            label: 'Receipts',
            format: ExportFormat.integer,
            value: (t) => t.receiptCount,
          ),
          ExportColumn(
            id: 'revenue',
            label: 'Value',
            format: ExportFormat.money,
            value: (t) => t.value,
            width: 1.3,
          ),
          if (canSeeCost)
            ExportColumn(
              id: 'profit',
              label: 'Profit/Loss',
              format: ExportFormat.money,
              value: (t) => t.knownProfit,
              width: 1.3,
            ),
        ],
        roll: _groupRoll,
      ),
      if (departmentsEnabled)
        _groupTable(
          title: 'Department Summary',
          nameLabel: 'Department',
          groups: departments,
          f: f,
          canSeeCost: canSeeCost,
          share: true,
        ),
      _groupTable(
        title: 'Customer Summary',
        nameLabel: 'Customer',
        groups: customers,
        f: f,
        canSeeCost: canSeeCost,
        lastDate: true,
      ),
      _groupTable(
        title: 'Staff Summary',
        nameLabel: 'Staff',
        groups: staff,
        f: f,
        canSeeCost: canSeeCost,
        share: true,
      ),
      if (subStaffEnabled)
        _groupTable(
          title: 'Sub-Staff Summary',
          nameLabel: 'Sub-Staff',
          groups: subStaff,
          f: f,
          canSeeCost: canSeeCost,
          average: false,
        ),
    ],
  );
}
