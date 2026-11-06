// Export spec of the General Report: the three card sections (Money In,
// Money Out, Profit) as small Metric · Value · Change tables, and the
// trend as a table. Charts aren't exported. Profit figures only with
// the cost permission, as on screen.

import 'package:stockall/constants/calculations.dart' show formatLargeNumberDouble;
import 'package:stockall/pages/report/components/export/report_export_format.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/report_trend_chart.dart'
    show reportTrendBucketLabel, reportTrendIntervalLabel;
import 'package:stockall/pages/report/general_report/class/general_report_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/components/receipts_report_filter_widgets.dart'
    show receiptsPeriodLabel;

String _count(int n, String noun) => '$n $noun${n == 1 ? '' : 's'}';

/// The notes the General Report shows under its period button. The view
/// draws these and the export carries them, so they always match.
List<String> generalReportNotes(GeneralReportFigures f) {
  final costMissing = f.costMissingCount ?? 0;
  final noItems = f.noItemDataCount ?? 0;
  return [
    if (f.period.isAllTime) 'All time covers the data loaded on this device.',
    if (costMissing > 0)
      'Cost missing on ${_count(costMissing, 'receipt')}: '
          'counted as 0 in gross profit.',
    if (noItems > 0)
      '${_count(noItems, 'receipt')} '
          '${noItems == 1 ? 'has' : 'have'} no item data: left '
          'out of gross profit.',
  ];
}

/// The card's change line, "▲ 12.5% vs previous period". [money]
/// formats an amount change (the screen's or the export's own).
String generalReportChangeText(
  GeneralReportChange c,
  String Function(num) money,
) {
  final arrow = c.isUp ? '▲' : (c.isDown ? '▼' : '–');
  final value = c.isPercent
      ? '${formatLargeNumberDouble(double.parse(c.value.abs().toStringAsFixed(2)))}%'
      : money(c.value.abs());
  return '$arrow $value vs previous period';
}

/// A compact change for the roll ("+12.5%", "-₦500.00", "0%"): the
/// arrows can't print on a receipt printer.
String generalReportChangeShort(GeneralReportChange c, ExportFormatter f) {
  final sign = c.isUp ? '+' : (c.isDown ? '-' : '');
  return c.isPercent
      ? '$sign${f.percent(c.value.abs())}'
      : '$sign${f.money(c.value.abs())}';
}

/// One card of a section.
class GeneralReportMetricRow {
  final String label;
  final double value;
  final GeneralReportChange? change;

  const GeneralReportMetricRow(this.label, this.value, this.change);
}

ExportTableSection<GeneralReportMetricRow> _metricTable(
  String title,
  List<GeneralReportMetricRow> rows,
  ExportFormatter f,
) {
  return ExportTableSection<GeneralReportMetricRow>(
    title: title,
    rows: rows,
    columns: [
      ExportColumn(id: 'metric', label: 'Metric', value: (r) => r.label, width: 1.5),
      ExportColumn(
        id: 'value',
        label: 'Value',
        format: ExportFormat.money,
        value: (r) => r.value,
        width: 1.2,
      ),
      ExportColumn(
        id: 'change',
        label: 'Change',
        value: (r) => r.change == null ? '' : generalReportChangeText(r.change!, f.money),
        width: 2,
      ),
      // Roll only: the arrows don't print.
      ExportColumn(
        id: 'changeShort',
        label: 'Change',
        value: (r) => r.change == null ? '' : generalReportChangeShort(r.change!, f),
        inPdf: false,
        inExcel: false,
      ),
    ],
    // 58mm: 15 / 16 characters, 80mm: 17 / 14 / 15, so "Total Purchases",
    // "-₦1,250,000.00" and "+₦1,250,000.00" stay on one line.
    roll: const RollLayout(
      cols58: ['metric', 'value'],
      cols80: ['metric', 'value', 'changeShort'],
      flex58: [1, 1],
      flex80: [18, 15, 15],
    ),
    emptyMessage: 'Nothing recorded in this period.',
  );
}

ExportTableSection<GeneralReportTrendPoint> _trendTable(
  GeneralReportTrend trend,
  bool profitVisible,
) {
  ExportColumn<GeneralReportTrendPoint> money(
    String id,
    String label,
    double? Function(GeneralReportTrendPoint) v,
  ) => ExportColumn(id: id, label: label, format: ExportFormat.money, value: v, width: 1.2);

  return ExportTableSection<GeneralReportTrendPoint>(
    title: 'Trend (${reportTrendIntervalLabel(trend.interval)}, by business day)',
    rows: trend.points,
    columns: [
      ExportColumn(
        id: 'period',
        label: 'Period',
        value: (p) => reportTrendBucketLabel(trend.interval, p.start),
      ),
      money('revenue', 'Revenue', (p) => p.revenue),
      if (profitVisible) money('grossProfit', 'Gross profit', (p) => p.grossProfit),
      money('expenses', 'Expenses', (p) => p.expenses),
      if (profitVisible) money('netProfit', 'Net profit', (p) => p.netProfit),
    ],
    // 58mm: 15 / 16 characters, 80mm: 15 / 15 / 16.
    roll: RollLayout(
      cols58: const ['period', 'revenue'],
      cols80: ['period', 'revenue', profitVisible ? 'netProfit' : 'expenses'],
      flex58: const [1, 1],
      flex80: const [1, 1, 1],
    ),
    emptyMessage: 'No sales or expenses in this period.',
  );
}

/// [figures], [changes] and [trend] are the screen's own.
ReportExportSpec generalReportExportSpec({
  required GeneralReportFigures figures,
  required GeneralReportChanges changes,
  required GeneralReportTrend trend,
  required ReceiptsReportPeriod period,
  required String currency,
}) {
  final f = ExportFormatter(currency: currency);
  final c = changes;
  final gross = figures.profitVisible
      ? GeneralReportMetricRow('Gross Profit', figures.grossProfit!, c.grossProfit)
      : null;
  return ReportExportSpec(
    reportName: 'General Report',
    fileSlug: 'general_report',
    period: ExportPeriod(
      label: receiptsPeriodLabel(period),
      start: period.start,
      end: period.end,
    ),
    notes: generalReportNotes(figures),
    sections: [
      _metricTable('Money In', [
        GeneralReportMetricRow('Total Revenue', figures.totalRevenue, c.revenue),
        if (gross != null) gross,
      ], f),
      _metricTable('Money Out', [
        GeneralReportMetricRow('Total Purchases', figures.totalPurchases, c.purchases),
        GeneralReportMetricRow('Total Expenses', figures.totalExpenses, c.expenses),
      ], f),
      if (gross != null)
        _metricTable('Profit', [
          gross,
          GeneralReportMetricRow('Net Profit', figures.netProfit!, c.netProfit),
        ], f),
      _trendTable(trend, figures.profitVisible),
    ],
  );
}
