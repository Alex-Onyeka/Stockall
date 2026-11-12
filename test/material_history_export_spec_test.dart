import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/temp_production_folder/temp_materials_item_history/material_item_history_event_class.dart';
import 'package:stockall/pages/report/components/export/report_export_format.dart';
import 'package:stockall/pages/report/components/export/report_export_resolve.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/export/report_roll_builder.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/production_stock_model.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/stock_history_export_spec.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/stock_history_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/services/printing/escpos_builder.dart' show fontBDots;

import 'item_history_export_fixtures.dart' show testCtx;
import 'material_history_logic_test.dart' show materialHistoryRows, materialHistoryQuery, day2;
import 'production_report_fixtures.dart';

final sample = materialHistoryQuery(materialHistoryRows());

ReportExportSpec specFor(
  List<ProductionHistoryRow> rows, {
  bool departmentsEnabled = false,
  bool canSeeQuantity = true,
  ReceiptsReportPeriod? period,
}) => productionHistoryExportSpec(
  kind: ProductionStockKind.material,
  rows: rows,
  state: ProductionHistoryTableState(),
  choices: ProductionHistoryFilterChoices.fromRows(rows),
  categoryNames: sampleCategories(),
  period: period ?? day2,
  currency: '₦',
  departmentsEnabled: departmentsEnabled,
  canSeeQuantity: canSeeQuantity,
);

ResolvedTable tableOf(ReportExportSpec spec) => resolveExport(spec, testCtx).tables.single;

void main() {
  test('150 records: every row, in the screen order', () {
    final rows = ProductionHistoryRowBuilder.buildAll(
      entries: materialEntries([
        for (var i = 1; i <= 150; i++)
          materialHistory(
            uuid: 'r-$i',
            title: 'Material Used',
            event: MaterialItemHistoryEventClass.usageCreated,
            createdAt: DateTime(2026, 10, 1).add(Duration(hours: i)),
            quantityChange: -i.toDouble(),
            oldValue: '$i',
            newValue: '0',
          ),
      ]),
      items: materialItems(),
      categoryNames: sampleCategories(),
    );
    final sorted = materialHistoryQuery(
      rows,
      period: const ReceiptsReportPeriod.allTime(),
      sortField: ProductionHistorySortField.change,
      ascending: true,
    );
    final t = tableOf(specFor(sorted, period: const ReceiptsReportPeriod.allTime()));
    expect(t.rows, hasLength(150));
    expect([for (final r in t.rows) r[t.indexOf('change')].raw], [
      for (final r in sorted) r.primaryChange,
    ]);
  });

  test('cells, masking and totals', () {
    final t = tableOf(specFor(sample));
    expect(t.columns.first.label, 'Date');
    expect([for (final c in t.columns) c.label], contains('Material'));
    final flour = t.rows.firstWhere((r) => r[t.indexOf('item')].text == 'Flour');
    expect(flour[t.indexOf('event')].text, 'Used');
    expect(flour[t.indexOf('change')].text, '-1 Bag');
    expect(t.totals![t.indexOf('date')].text, '4 records');
    final masked = tableOf(specFor(sample, canSeeQuantity: false));
    expect(masked.rows.first[masked.indexOf('change')].text, '****');
  });

  test('splits: Category, Department and Staff', () {
    final f = ExportFormatter(currency: '₦');
    final spec = specFor(sample, departmentsEnabled: true);
    expect(spec.splitOptions.map((s) => s.id), ['category', 'department', 'staff']);
    // Flour's records are Bakery's, sugar's Kitchen's.
    expect(resolveGroups(spec.tables.single, 'department', f), hasLength(2));
  });

  test('the note and the roll', () {
    final spec = specFor(sample);
    expect(spec.notes.single, contains("can't tell production use from manual use"));
    for (final paper in RollPaper.values) {
      final out = renderRollEscPos(buildRollLines(spec, testCtx, paper: paper), paper).preview;
      final lines = out.split('\n');
      expect(lines.any((l) => l.startsWith('Flour') && l.endsWith('-1 Bag')), isTrue);
      expect(lines.every((l) => l.length <= paper.dots ~/ fontBDots), isTrue);
    }
  });
}
