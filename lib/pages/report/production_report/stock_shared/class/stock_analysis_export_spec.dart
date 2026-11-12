// Export spec of the stock analysis (I2 / M2): the headline cards and
// one table per tab the screen offers, the active one sorted like the
// screen. No splits.

import 'package:stockall/pages/report/components/export/report_export_format.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/production_report/production_summary/class/production_summary_logic.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/production_stock_model.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/stock_analysis_logic.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/stock_history_summary_export_spec.dart'
    show productionStockCardMetric;
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/components/receipts_report_filter_widgets.dart'
    show receiptsPeriodLabel;

const String _dash = '—';

ExportFormat _format(ProductionBreakdownKind k) {
  switch (k) {
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

/// The cell text of [c], as the screen shows it.
String productionStockAnalysisCellText(
  ProductionStockAnalysisRow r,
  ProductionStockAnalysisColumn c,
  String Function(num) money,
  String Function(num) number,
  String Function(num) percent, [
  String Function(DateTime)? date,
]) {
  final v = r.valueOf(c.field);
  if (v == null) return _dash;
  final unit = r.unitOf(c.field);
  String withUnit(String s) => unit == null ? s : '$s $unit';
  switch (c.kind) {
    case ProductionBreakdownKind.text:
      return v as String;
    case ProductionBreakdownKind.count:
      return number(v as num);
    case ProductionBreakdownKind.quantity:
    case ProductionBreakdownKind.ratio:
      return withUnit(number(v as num));
    case ProductionBreakdownKind.money:
      return money(v as num);
    case ProductionBreakdownKind.date:
      if (v is! DateTime) return '$v';
      return date == null ? v.toString() : date(v);
    case ProductionBreakdownKind.percent:
      return percent(v as num);
  }
}

RollLayout _roll(List<String> ids) {
  final value = [
    'main',
    'out',
    'net',
    'usedTotal',
    'usageCost',
    'stockValue',
    'recordedCostPerUnit',
    'lastUnitCost',
    'stock',
  ].firstWhere(ids.contains, orElse: () => ids.length > 1 ? ids[1] : 'name');
  return RollLayout(
    cols58: ['name', value],
    cols80: ['name', value],
    flex58: const [1, 1],
    flex80: const [3, 2],
  );
}

ExportTableSection<ProductionStockAnalysisRow> productionStockAnalysisSection(
  ProductionStockAnalysisTab tab,
  List<ProductionStockAnalysisRow> rows,
  ExportFormatter f, {
  required ProductionStockKind kind,
  required bool canSeeCost,
  bool canSeeQuantity = true,
}) {
  final cols = productionStockAnalysisColumns(
    tab,
    kind: kind,
    canSeeCost: canSeeCost,
    canSeeQuantity: canSeeQuantity,
  );
  return ExportTableSection<ProductionStockAnalysisRow>(
    title: productionStockAnalysisTabLabel(tab, kind),
    rows: rows,
    columns: [
      for (final c in cols)
        ExportColumn<ProductionStockAnalysisRow>(
          id: c.field.name,
          label: c.label,
          format: _format(c.kind),
          value: (r) => r.valueOf(c.field),
          display:
              (r) => productionStockAnalysisCellText(
                r,
                c,
                f.money,
                f.quantity,
                f.percent,
                f.date,
              ),
          width: c.width / 100,
        ),
    ],
    roll: _roll([for (final c in cols) c.field.name]),
    emptyMessage: 'Nothing to show for this period.',
  );
}

ReportExportSpec productionStockAnalysisExportSpec({
  required ProductionStockAnalysis analysis,
  required ReceiptsReportPeriod period,
  required List<ProductionStockAnalysisTab> tabs,
  required ProductionStockAnalysisTab activeTab,
  required ProductionStockAnalysisField? sortField,
  required bool ascending,
  required String currency,
  required bool canSeeCost,
  required bool canSeeQuantity,
  required bool historyAllowed,
}) {
  final f = ExportFormatter(currency: currency);
  final kind = analysis.kind;
  return ReportExportSpec(
    reportName: '${kind.plural} Analysis',
    fileSlug: '${kind.slug}_analysis',
    period: ExportPeriod(
      label: receiptsPeriodLabel(period),
      start: period.start,
      end: period.end,
    ),
    notes: productionStockNotes(
      kind: kind,
      page: ProductionStockReportPage.analysis,
      period: period,
      historyAllowed: historyAllowed,
      notNormalised: analysis.notNormalised,
    ),
    sections: [
      ExportSummarySection(
        title: 'Statistics',
        metrics: [
          for (final c in productionStockAnalysisCards(
            analysis,
            canSeeCost: canSeeCost,
            canSeeQuantity: canSeeQuantity,
            historyAllowed: historyAllowed,
          ))
            productionStockCardMetric(c, f),
        ],
      ),
      for (final tab in tabs)
        productionStockAnalysisSection(
          tab,
          ProductionStockAnalysisBuilder.sortTab(
            analysis.tabs[tab] ?? const [],
            field: tab == activeTab ? sortField : null,
            ascending: ascending,
          ),
          f,
          kind: kind,
          canSeeCost: canSeeCost,
          canSeeQuantity: canSeeQuantity,
        ),
    ],
  );
}
