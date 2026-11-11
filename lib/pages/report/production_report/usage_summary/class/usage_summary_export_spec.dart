// Export spec of the Usage Summary page: its statistic cards (with the
// change against the previous period as each card's note) and one table
// per breakdown tab the screen offers. Charts aren't exported. No
// splits. Every input is the screen's own UsageSummaryResult and
// column list.

import 'package:flutter/material.dart' show TimeOfDay;
import 'package:stockall/pages/report/components/export/report_export_format.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/production_report/production_records_table/class/production_records_table_logic.dart';
import 'package:stockall/pages/report/production_report/production_summary/class/production_summary_export_spec.dart'
    show productionCardNote;
import 'package:stockall/pages/report/production_report/production_summary/class/production_summary_logic.dart';
import 'package:stockall/pages/report/production_report/usage_records_table/class/usage_records_table_logic.dart';
import 'package:stockall/pages/report/production_report/usage_summary/class/usage_summary_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/components/receipts_report_filter_widgets.dart'
    show receiptsPeriodLabel;

const String _dash = '—';

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

/// The cell text of [c], as the screen shows it.
String usageBreakdownCellText(
  UsageBreakdownRow r,
  UsageBreakdownColumn c,
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
    case ProductionBreakdownKind.ratio:
      return withUnit(f.quantity(v as num));
    case ProductionBreakdownKind.money:
      return f.money(v as num);
    case ProductionBreakdownKind.date:
      return f.date(v as DateTime);
    case ProductionBreakdownKind.percent:
      return f.percent(v as num);
  }
}

RollLayout _roll(List<String> ids) {
  // The cost when the cost permission shows it, else the records.
  // 58mm: 15 / 16 characters, 80mm: 23 / 5 / 18.
  if (ids.contains('cost')) {
    return const RollLayout(
      cols58: ['name', 'cost'],
      cols80: ['name', 'count', 'cost'],
      flex58: [1, 1],
      flex80: [4, 1, 3],
    );
  }
  return const RollLayout(
    cols58: ['name', 'count'],
    cols80: ['name', 'count'],
    flex58: [3, 1],
    flex80: [3, 1],
  );
}

ExportTableSection<UsageBreakdownRow> usageBreakdownSection(
  UsageBreakdownTab tab,
  List<UsageBreakdownRow> rows,
  ExportFormatter f, {
  required bool canSeeCost,
  required bool canSeeQuantity,
}) {
  final cols = usageBreakdownColumns(
    tab,
    canSeeCost: canSeeCost,
    canSeeQuantity: canSeeQuantity,
  );
  return ExportTableSection<UsageBreakdownRow>(
    title: tab.label,
    rows: rows,
    columns: [
      for (final c in cols)
        ExportColumn<UsageBreakdownRow>(
          id: c.field.name,
          label: c.label,
          format: _format(c.kind),
          value: (r) => r.valueOf(c.field),
          display: (r) => usageBreakdownCellText(r, c, f),
          width: c.width / 100,
        ),
    ],
    roll: _roll([for (final c in cols) c.field.name]),
    emptyMessage: 'No usage records in this period.',
  );
}

/// [tabs] are the breakdown tabs the screen offers. [activeTab] is
/// sorted by [sortField] / [ascending], as on screen; the others keep
/// their built order. [allUsages] and [recordRows] are every loaded
/// usage and production row, for the notes.
ReportExportSpec usageSummaryExportSpec({
  required UsageSummaryResult result,
  required List<UsageRecordRow> allUsages,
  required List<ProductionRecordRow> recordRows,
  required ReceiptsReportPeriod period,
  required List<UsageBreakdownTab> tabs,
  required UsageBreakdownTab activeTab,
  required UsageBreakdownField? sortField,
  required bool ascending,
  required String currency,
  required bool canSeeCost,
  required bool canSeeQuantity,
  TimeOfDay? closingTime,
}) {
  final f = ExportFormatter(currency: currency);
  return ReportExportSpec(
    reportName: 'Usage Summary',
    fileSlug: 'usage_summary',
    period: ExportPeriod(
      label: receiptsPeriodLabel(period),
      start: period.start,
      end: period.end,
    ),
    notes: usageRecordsNotes(
      period: period,
      usages: allUsages,
      recordRows: recordRows,
      closingTime: closingTime,
    ),
    sections: [
      ExportSummarySection(
        title: 'Statistics',
        metrics: [
          for (final c in usageSummaryCards(result, canSeeCost: canSeeCost))
            ExportMetric(
              label: c.title,
              value: c.isMoney ? c.value : c.value.round(),
              format: c.isMoney ? ExportFormat.money : ExportFormat.integer,
              note: productionCardNote(c, f),
            ),
        ],
      ),
      for (final tab in tabs)
        usageBreakdownSection(
          tab,
          UsageSummaryBuilder.sortBreakdown(
            UsageSummaryBuilder.breakdown(result, tab),
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
