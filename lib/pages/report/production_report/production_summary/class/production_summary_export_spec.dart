// Export spec of the Production Summary page: its statistic cards (with
// the change against the previous period as each card's note) and one
// table per breakdown tab the screen offers. Charts aren't exported. No
// splits. Every input is the screen's own ProductionSummaryResult and
// column list.

import 'package:stockall/pages/report/components/export/report_export_format.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/general_report/class/general_report_export_spec.dart'
    show generalReportChangeText;
import 'package:stockall/pages/report/production_report/production_records_table/class/production_records_table_logic.dart';
import 'package:stockall/pages/report/production_report/production_summary/class/production_summary_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/components/receipts_report_filter_widgets.dart'
    show receiptsPeriodLabel;

const String _dash = '—';

/// A card's note: its change against the previous period, or its
/// subtitle without one. Counts change by a count, not money.
String productionCardNote(ProductionSummaryCard c, ExportFormatter f) {
  final change = c.change;
  if (change == null) return c.subtitle;
  return generalReportChangeText(change, c.isMoney ? f.money : f.integer);
}

ExportFormat _format(ProductionBreakdownKind kind) {
  switch (kind) {
    case ProductionBreakdownKind.text:
      return ExportFormat.text;
    case ProductionBreakdownKind.count:
      return ExportFormat.integer;
    case ProductionBreakdownKind.quantity:
    case ProductionBreakdownKind.ratio:
      return ExportFormat.quantity;
    case ProductionBreakdownKind.money:
      return ExportFormat.money;
    case ProductionBreakdownKind.date:
      return ExportFormat.date;
    case ProductionBreakdownKind.percent:
      return ExportFormat.percent;
  }
}

/// The cell text of [field], as the screen shows it.
String productionBreakdownCellText(
  ProductionBreakdownRow r,
  ProductionBreakdownColumn c,
  ExportFormatter f,
) {
  final v = r.valueOf(c.field);
  if (v == null) return _dash;
  final unit = r.unitOf(c.field);
  String withUnit(String s) => unit == null ? s : '$s $unit';
  switch (c.kind) {
    case ProductionBreakdownKind.text:
      return v as String;
    case ProductionBreakdownKind.count:
      return f.integer(v as num);
    case ProductionBreakdownKind.quantity:
      return withUnit(f.quantity(v as num));
    case ProductionBreakdownKind.ratio:
      return withUnit(productionRatioText((v as num).toDouble(), f.number));
    case ProductionBreakdownKind.money:
      return f.money(v as num);
    case ProductionBreakdownKind.date:
      return f.date(v as DateTime);
    case ProductionBreakdownKind.percent:
      return f.percent(v as num);
  }
}

RollLayout _roll(ProductionBreakdownTab tab, List<String> ids) {
  if (tab == ProductionBreakdownTab.yield) {
    // Output · ratio, the material underneath (58mm); all three on
    // 80mm.
    return const RollLayout(
      cols58: ['name', 'ratio'],
      cols80: ['name', 'sublabel', 'ratio'],
      sub58: ['sublabel'],
      flex58: [1, 1],
      flex80: [3, 3, 4],
    );
  }
  // The money column when the cost permission shows one, else the count.
  final value = [
    'recordedCost',
    'materialCost',
  ].firstWhere(ids.contains, orElse: () => 'count');
  // 58mm: 15 / 16 characters, 80mm: 23 / 5 / 18.
  return RollLayout(
    cols58: ['name', value],
    cols80: value == 'count' ? ['name', 'count'] : ['name', 'count', value],
    flex58: const [1, 1],
    flex80: value == 'count' ? const [3, 1] : const [4, 1, 3],
  );
}

ExportTableSection<ProductionBreakdownRow> productionBreakdownSection(
  ProductionBreakdownTab tab,
  List<ProductionBreakdownRow> rows,
  ExportFormatter f, {
  required bool canSeeCost,
  required bool canSeeQuantity,
}) {
  final cols = productionBreakdownColumns(
    tab,
    canSeeCost: canSeeCost,
    canSeeQuantity: canSeeQuantity,
  );
  final ids = [for (final c in cols) c.field.name];
  return ExportTableSection<ProductionBreakdownRow>(
    title: tab.label,
    rows: rows,
    columns: [
      for (final c in cols)
        ExportColumn<ProductionBreakdownRow>(
          id: c.field.name,
          label: c.label,
          format: _format(c.kind),
          value: (r) => r.valueOf(c.field),
          display: (r) => productionBreakdownCellText(r, c, f),
          width: c.width / 100,
        ),
    ],
    roll: _roll(tab, ids),
    emptyMessage: 'No production records in this period.',
  );
}

/// [tabs] are the breakdown tabs the screen offers. [activeTab] is
/// sorted by [sortField] / [ascending], as on screen; the others keep
/// their built order, as they show when opened.
ReportExportSpec productionSummaryExportSpec({
  required ProductionSummaryResult result,
  required ReceiptsReportPeriod period,
  required List<ProductionBreakdownTab> tabs,
  required ProductionBreakdownTab activeTab,
  required ProductionBreakdownField? sortField,
  required bool ascending,
  required String currency,
  required bool canSeeCost,
  required bool canSeeQuantity,
}) {
  final f = ExportFormatter(currency: currency);
  return ReportExportSpec(
    reportName: 'Production Summary',
    fileSlug: 'production_summary',
    period: ExportPeriod(
      label: receiptsPeriodLabel(period),
      start: period.start,
      end: period.end,
    ),
    notes: productionRecordsNotes(
      period: period,
      rows: result.rows,
      canSeeCost: canSeeCost,
    ),
    sections: [
      ExportSummarySection(
        title: 'Statistics',
        metrics: [
          for (final c in productionSummaryCards(result, canSeeCost: canSeeCost))
            ExportMetric(
              label: c.title,
              value: c.isMoney ? c.value : c.value.round(),
              format: c.isMoney ? ExportFormat.money : ExportFormat.integer,
              note: productionCardNote(c, f),
            ),
        ],
      ),
      for (final tab in tabs)
        productionBreakdownSection(
          tab,
          ProductionSummaryBuilder.sortBreakdown(
            ProductionSummaryBuilder.breakdown(result, tab),
            field: tab == activeTab ? sortField : null,
            ascending: ascending,
          ),
          f,
          canSeeCost: canSeeCost,
          canSeeQuantity: canSeeQuantity,
        ),
    ],
  );
}
