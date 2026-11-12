// Export spec of the stock history summary (I4 / M4): the headline
// cards over every item of the period, then the filtered and sorted
// rows. Splits: Category and Department.

import 'package:stockall/pages/report/components/export/report_export_format.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/export/report_export_splits.dart';
import 'package:stockall/pages/report/general_report/class/general_report_export_spec.dart'
    show generalReportChangeText;
import 'package:stockall/pages/report/production_report/stock_shared/class/production_stock_model.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/stock_analysis_logic.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/stock_history_summary_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/components/receipts_report_filter_widgets.dart'
    show receiptsPeriodLabel;

const String _masked = '****';

/// A card as an export metric: money and counts as numbers, quantities
/// and masked values as their text. The note is the change against the
/// previous period, else the subtitle.
ExportMetric productionStockCardMetric(ProductionStockCard c, ExportFormatter f) {
  final change = c.change;
  final note =
      change == null || c.masked
          ? c.subtitle
          : generalReportChangeText(
            change,
            c.kind == ProductionStockCardKind.money ? f.money : f.quantity,
          );
  if (c.masked) {
    return ExportMetric(label: c.title, value: _masked, format: ExportFormat.text, note: note);
  }
  switch (c.kind) {
    case ProductionStockCardKind.count:
      return ExportMetric(
        label: c.title,
        value: (c.amount ?? 0).round(),
        format: ExportFormat.integer,
        note: note,
      );
    case ProductionStockCardKind.money:
      return ExportMetric(
        label: c.title,
        value: c.amount ?? 0,
        format: ExportFormat.money,
        note: note,
      );
    case ProductionStockCardKind.percent:
      return ExportMetric(
        label: c.title,
        value: c.amount,
        format: ExportFormat.percent,
        note: note,
      );
    case ProductionStockCardKind.quantities:
      return ExportMetric(
        label: c.title,
        value: c.valueText(f.money, f.quantity),
        format: ExportFormat.text,
        note: note,
      );
  }
}

String productionHistorySummarySortLabel(ProductionHistorySummarySort s) {
  final label = switch (s.field) {
    ProductionHistorySummarySortField.name => 'Name',
    ProductionHistorySummarySortField.opening => 'Opening',
    ProductionHistorySummarySortField.closing => 'Closing',
    ProductionHistorySummarySortField.movement => s.movement?.label ?? 'Movement',
    ProductionHistorySummarySortField.netProduced => 'Net Produced',
    ProductionHistorySummarySortField.created => 'Created',
    ProductionHistorySummarySortField.deleted => 'Deleted',
    ProductionHistorySummarySortField.additions => 'Additions',
    ProductionHistorySummarySortField.reductions => 'Reductions',
    ProductionHistorySummarySortField.net => 'Net',
    ProductionHistorySummarySortField.events => 'Records',
  };
  return '$label (${s.ascending ? 'ascending' : 'descending'})';
}

ExportTableSection<ProductionHistorySummaryRow> productionHistorySummarySection({
  required ProductionStockKind kind,
  required List<ProductionHistorySummaryRow> rows,
  required Map<String, String> categoryNames,
  required ExportFormatter f,
  required bool departmentsEnabled,
  required bool canSeeQuantity,
}) {
  ExportColumn<ProductionHistorySummaryRow> qty(
    String id,
    String label,
    double? Function(ProductionHistorySummaryRow r) pick, {
    bool signed = false,
    bool inPdf = true,
  }) {
    double? value(ProductionHistorySummaryRow r) =>
        canSeeQuantity ? pick(r) : null;
    return ExportColumn<ProductionHistorySummaryRow>(
      id: id,
      label: label,
      format: ExportFormat.quantity,
      value: value,
      inPdf: inPdf,
      display: (r) {
        if (!canSeeQuantity) return _masked;
        final v = value(r);
        if (v == null) return '—';
        return signed && v > 0 ? '+${f.quantity(v)}' : f.quantity(v);
      },
    );
  }

  final produced = kind == ProductionStockKind.producedItem;
  final mainId = productionMainMovement(kind).name;
  final departmentNames = <String, String>{
    for (final r in rows)
      if (r.departmentKey != null) r.departmentKey!: r.departmentLabel,
  };
  int events(List<ProductionHistorySummaryRow> rs) =>
      rs.fold(0, (s, r) => s + r.events);
  return ExportTableSection<ProductionHistorySummaryRow>(
    title: '${kind.singular} History Summary',
    rows: rows,
    columns: [
      ExportColumn(id: 'name', label: kind.singular, value: (r) => r.name, width: 2),
      ExportColumn(id: 'unit', label: 'Primary Unit', value: (r) => r.primaryUnit),
      qty('opening', 'Opening', (r) => r.balance.opening),
      for (final m in productionSummaryMovementColumns(kind)) ...[
        qty(m.name, m.label, (r) => r.of(m)),
        if (produced && m == ProductionMovementKind.productionDeleted)
          qty('netProduced', 'Net Produced', (r) => r.netProduced),
      ],
      ExportColumn(
        id: 'created',
        label: 'Created',
        format: ExportFormat.integer,
        value: (r) => r.created,
        width: 0.7,
      ),
      ExportColumn(
        id: 'deleted',
        label: 'Deleted',
        format: ExportFormat.integer,
        value: (r) => r.deleted,
        width: 0.7,
      ),
      qty('additions', 'Additions', (r) => r.additions),
      qty('reductions', 'Reductions', (r) => r.reductions),
      qty('net', 'Net', (r) => r.net, signed: true),
      qty('closing', 'Closing', (r) => r.balance.closing),
      ExportColumn(
        id: 'events',
        label: 'Records',
        format: ExportFormat.integer,
        value: (r) => r.events,
        width: 0.7,
      ),
    ],
    totals: {
      'name': '${f.integer(rows.length)} ${kind.countNoun}',
      'events': events(rows),
    },
    totalsFor:
        (rs) => {
          'name': '${f.integer(rs.length)} ${kind.countNoun}',
          'events': events(rs),
        },
    splits: [
      categorySplit<ProductionHistorySummaryRow>(
        categoryIds: (r) => r.categoryKeys,
        names: categoryNames,
      ),
      if (departmentsEnabled)
        departmentSplit<ProductionHistorySummaryRow>(
          departmentId: (r) => r.departmentKey,
          names: departmentNames,
        ),
    ],
    // 58mm: name · net. 80mm: name · produced (used) · net.
    roll: RollLayout(
      cols58: const ['name', 'net'],
      cols80: ['name', mainId, 'net'],
      flex58: const [3, 2],
      flex80: const [20, 14, 14],
    ),
    emptyMessage: 'No ${kind.singular.toLowerCase()} matches the selected filters.',
  );
}

/// [allRows] are every row of the period (for the cards); [rows] the
/// filtered and sorted ones.
ReportExportSpec productionHistorySummaryExportSpec({
  required ProductionStockKind kind,
  required List<ProductionHistorySummaryRow> allRows,
  required List<ProductionHistorySummaryRow> rows,
  required ProductionHistorySummaryState state,
  required Map<String, String> categoryNames,
  required ReceiptsReportPeriod period,
  required String currency,
  required bool departmentsEnabled,
  required bool canSeeQuantity,
}) {
  final f = ExportFormatter(currency: currency);
  final stats = ProductionHistorySummaryStats.fromRows(allRows);
  final search = state.filters.search.trim();
  return ReportExportSpec(
    reportName: '${kind.singular} History Summary',
    fileSlug: '${kind.slug}_history_summary',
    period: ExportPeriod(
      label: receiptsPeriodLabel(period),
      start: period.start,
      end: period.end,
    ),
    filters: [
      if (search.isNotEmpty) ExportFilter('Search', search),
      if (state.filters.movement != ProductionHistoryMovementFilter.all)
        ExportFilter('Movement', state.filters.movement.label),
    ],
    sortedBy: productionHistorySummarySortLabel(state.sort),
    notes: productionStockNotes(
      kind: kind,
      page: ProductionStockReportPage.historySummary,
      period: period,
      historyAllowed: true,
      notNormalised: stats.notNormalised,
    ),
    sections: [
      ExportSummarySection(
        title: 'Statistics',
        metrics: [
          for (final c in productionHistorySummaryCards(
            stats,
            kind: kind,
            canSeeQuantity: canSeeQuantity,
          ))
            productionStockCardMetric(c, f),
        ],
      ),
      productionHistorySummarySection(
        kind: kind,
        rows: rows,
        categoryNames: categoryNames,
        f: f,
        departmentsEnabled: departmentsEnabled,
        canSeeQuantity: canSeeQuantity,
      ),
    ],
  );
}
