// Export spec of the Item Sales Analysis page: its statistic cards and
// the tables under them (rankings, channels, types, categories, items,
// departments, customers, staff, sub-staff). Charts aren't exported.
// Every input is the screen's own builder output.

import 'package:stockall/pages/report/components/export/report_export_format.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/sales_report_/item_sales_analysis/class/item_sales_analysis_logic.dart';
import 'package:stockall/pages/report/sales_report_/item_sales_report_main/class/item_sales_export_spec.dart'
    show itemSalesExportFilters;
import 'package:stockall/pages/report/sales_report_/item_sales_report_main/class/item_sales_report_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/components/receipts_report_filter_widgets.dart';

const String _dash = '—';

/// The notes the analysis shows under its toolbar. The view draws
/// these and the export carries them, so they always match.
List<String> itemSalesAnalysisNotes({
  required ReceiptsReportPeriod period,
  required ItemSalesSummaryStats stats,
  required bool cartDiscountInView,
  required ItemSalesVoidFilter voidFilter,
  required bool canSeeCost,
}) {
  final s = stats;
  return [
    if (period.isAllTime)
      'All time covers the receipts loaded on this device.',
    'Revenue is item revenue (VAT included) on every receipt '
        'type: sales, invoice payments and order deliveries.',
    if (cartDiscountInView)
      'Cart discounts on a receipt are not included in its '
          'item revenue.',
    if (voidFilter != ItemSalesVoidFilter.notVoid)
      'Void lines are included in these totals.',
    if (canSeeCost && s.costMissingCount > 0)
      'Profit includes ${s.costMissingCount} of '
          '${s.totalLines} item records with a missing cost '
          'price (counted as 0).',
  ];
}

const RollLayout _groupRoll = RollLayout(
  cols58: ['name', 'revenue'],
  cols80: ['no', 'name', 'revenue'],
  flex58: [1, 1],
  flex80: [1, 4, 4],
);

/// A group table as the screen draws it (`_groupColumns`).
ExportTableSection<ItemSalesSummaryGroup> _groupTable({
  required String title,
  required String nameLabel,
  required List<ItemSalesSummaryGroup> groups,
  required ExportFormatter f,
  required bool canSeeCost,
  bool receipts = true,
  bool margin = true,
  bool share = false,
  bool lastDate = false,
}) {
  final no = Map<ItemSalesSummaryGroup, int>.identity();
  for (var i = 0; i < groups.length; i++) {
    no[groups[i]] = i + 1;
  }
  return ExportTableSection<ItemSalesSummaryGroup>(
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
        id: 'lines',
        label: 'Item Records',
        format: ExportFormat.integer,
        value: (g) => g.lineCount,
        width: 0.9,
      ),
      if (receipts)
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
          value: (g) => g.profit,
          width: 1.3,
        ),
      if (canSeeCost && margin)
        ExportColumn(
          id: 'margin',
          label: 'Margin',
          format: ExportFormat.percent,
          value: (g) => g.margin,
          display: (g) => g.margin == null ? 'N/A' : f.percent(g.margin!),
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
          label: 'Last Sold',
          format: ExportFormat.date,
          value: (g) => g.lastDate,
          display: (g) => g.lastDate == null ? _dash : f.date(g.lastDate!),
        ),
    ],
    roll: _groupRoll,
    emptyMessage: 'No item was sold in this period.',
  );
}

/// [items] and [customers] are in the screen's sort; every row is
/// exported (the screen previews a few).
ReportExportSpec itemSalesAnalysisExportSpec({
  required ItemSalesSummaryStats stats,
  required List<ItemSalesSummaryGroup> items,
  required List<ItemSalesSummaryGroup> categories,
  required List<ItemSalesSummaryGroup> customers,
  required List<ItemSalesSummaryGroup> staff,
  required List<ItemSalesSummaryGroup> subStaff,
  required List<ItemSalesSummaryGroup> departments,
  required List<ItemSalesChannelSummary> channels,
  required List<ItemSalesTypeSummary> types,
  required ItemSalesFilters filters,
  required List<ReceiptsFilterOption> categoryOptions,
  required List<ReceiptsFilterOption> itemOptions,
  required ReceiptsFilterChoices choices,
  required ReceiptsReportPeriod period,
  required List<String> notes,
  required String currency,
  required bool canSeeCost,
  required bool departmentsEnabled,
  required bool subStaffEnabled,
}) {
  final f = ExportFormatter(currency: currency);
  final s = stats;
  ExportMetric count(String label, int v, {String? note}) => ExportMetric(
    label: label,
    value: v,
    format: ExportFormat.integer,
    note: note,
  );
  ExportMetric money(String label, double v, {String? note}) =>
      ExportMetric(label: label, value: v, note: note);

  final channelNo = <ItemSalesChannelSummary, int>{
    for (var i = 0; i < channels.length; i++) channels[i]: i + 1,
  };
  final typeNo = <ItemSalesTypeSummary, int>{
    for (var i = 0; i < types.length; i++) types[i]: i + 1,
  };

  return ReportExportSpec(
    reportName: 'Item Sales Analysis',
    fileSlug: 'item_sales_analysis',
    period: ExportPeriod(
      label: receiptsPeriodLabel(period),
      start: period.start,
      end: period.end,
    ),
    filters: itemSalesExportFilters(
      filters: filters,
      categoryOptions: categoryOptions,
      itemOptions: itemOptions,
      choices: choices,
      departmentsEnabled: departmentsEnabled,
      subStaffEnabled: subStaffEnabled,
      profitVisible: canSeeCost,
      f: f,
    ),
    notes: notes,
    sections: [
      ExportSummarySection(
        title: 'Statistics',
        metrics: [
          count(
            'Item Records',
            s.totalLines,
            note: s.voidLines > 0 ? '${s.voidLines} void' : null,
          ),
          count(
            'Items Sold',
            s.distinctItems,
            note: s.noItemIdLines > 0
                ? '+ ${s.noItemIdLines} records without item ID'
                : 'Distinct items',
          ),
          count('Receipts', s.receiptCount),
          count('Categories Sold', s.distinctCategories),
          money('Total Revenue', s.totalRevenue, note: 'All receipt types'),
          if (canSeeCost) ...[
            money(
              'Total Profit/Loss',
              s.totalProfit,
              note: s.costMissingCount > 0
                  ? '${s.costMissingCount} records with a missing cost'
                  : null,
            ),
            ExportMetric(
              label: 'Profit Margin',
              value: s.margin ?? 'N/A',
              format: s.margin == null ? ExportFormat.text : ExportFormat.percent,
            ),
          ],
          money(
            'Average Item Revenue',
            s.averageLineRevenue,
            note: 'Per item record',
          ),
          money('Total Line Discounts', s.totalDiscount),
          count('Custom Price Records', s.customPriceLines),
          count('Wholesale Records', s.wholesaleLines),
          count(
            'Invoice Payment Records',
            s.typeCount(ReceiptType.invoicePayment),
            note: 'Part payments of invoices',
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
        ],
      ),
      _groupTable(
        title: 'Top 3 Items',
        nameLabel: 'Item',
        groups: ItemSalesAnalysisBuilder.top3(items),
        f: f,
        canSeeCost: canSeeCost,
        receipts: false,
      ),
      _groupTable(
        title: 'Least 3 Items',
        nameLabel: 'Item',
        groups: ItemSalesAnalysisBuilder.least3(items),
        f: f,
        canSeeCost: canSeeCost,
        receipts: false,
      ),
      _groupTable(
        title: 'Top 3 Staff',
        nameLabel: 'Staff',
        groups: ItemSalesAnalysisBuilder.top3(staff),
        f: f,
        canSeeCost: canSeeCost,
        receipts: false,
      ),
      _groupTable(
        title: 'Least 3 Staff',
        nameLabel: 'Staff',
        groups: ItemSalesAnalysisBuilder.least3(staff),
        f: f,
        canSeeCost: canSeeCost,
        receipts: false,
      ),
      ExportTableSection<ItemSalesChannelSummary>(
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
            id: 'lines',
            label: 'Item Records',
            format: ExportFormat.integer,
            value: (c) => c.lineCount,
          ),
          ExportColumn(
            id: 'revenue',
            label: 'Value',
            format: ExportFormat.money,
            value: (c) => c.value,
            width: 1.3,
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
      ExportTableSection<ItemSalesTypeSummary>(
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
            id: 'lines',
            label: 'Item Records',
            format: ExportFormat.integer,
            value: (t) => t.lineCount,
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
              value: (t) => t.profit,
              width: 1.3,
            ),
        ],
        roll: _groupRoll,
      ),
      _groupTable(
        title: 'Category Summary',
        nameLabel: 'Category',
        groups: categories,
        f: f,
        canSeeCost: canSeeCost,
        share: true,
      ),
      _groupTable(
        title: 'Item Summary',
        nameLabel: 'Item',
        groups: items,
        f: f,
        canSeeCost: canSeeCost,
        lastDate: true,
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
        ),
    ],
  );
}
