import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_item_history/production_item_history_event_class.dart';
import 'package:stockall/pages/report/components/export/report_export_format.dart';
import 'package:stockall/pages/report/components/export/report_export_resolve.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/export/report_roll_builder.dart';
import 'package:stockall/pages/report/production_report/production_records_table/class/production_records_table_logic.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/production_stock_model.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/stock_history_export_spec.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/stock_history_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/services/printing/escpos_builder.dart' show fontBDots;

import 'item_history_export_fixtures.dart' show testCtx;
import 'produced_item_history_logic_test.dart' show historyRows, historyQuery, day2;
import 'production_report_fixtures.dart';

final sample = historyQuery(historyRows());

ReportExportSpec specFor(
  List<ProductionHistoryRow> rows, {
  ProductionHistoryFilters? filters,
  ReceiptsReportPeriod? period,
  bool departmentsEnabled = false,
  bool canSeeQuantity = true,
}) => productionHistoryExportSpec(
  kind: ProductionStockKind.producedItem,
  rows: rows,
  state: ProductionHistoryTableState(filters: filters),
  choices: ProductionHistoryFilterChoices.fromRows(rows),
  categoryNames: sampleCategories(),
  period: period ?? day2,
  currency: '₦',
  departmentsEnabled: departmentsEnabled,
  canSeeQuantity: canSeeQuantity,
);

ResolvedTable tableOf(ReportExportSpec spec) =>
    resolveExport(spec, testCtx).tables.single;

/// 150 donut records, one an hour from 1 Oct 2026.
List<ProductionHistoryRow> manyRecords() => ProductionHistoryRowBuilder.buildAll(
  entries: stockEntries([
    for (var i = 1; i <= 150; i++)
      stockRecord(
        uuid: 'r-$i',
        title: 'Item Quantity Increased',
        event: ProductionItemHistoryEventClass.quantityUpdatedIncrease,
        createdAt: DateTime(2026, 10, 1).add(Duration(hours: i)),
        quantityChange: i.toDouble(),
        oldValue: '0',
        newValue: '$i',
        isIncreased: true,
      ),
  ]),
  items: stockItems(),
  categoryNames: sampleCategories(),
);

void main() {
  test('150 records: every row, in the screen order', () {
    final sorted = historyQuery(
      manyRecords(),
      period: const ReceiptsReportPeriod.allTime(),
      sortField: ProductionHistorySortField.change,
    );
    final t = tableOf(specFor(sorted));
    expect(t.rows, hasLength(150));
    expect([for (final r in t.rows) r[t.indexOf('change')].raw], [
      for (final r in sorted) r.primaryChange,
    ]);
  });

  group('columns and cells', () {
    test('the screen columns; title, unit, description, managed in Excel', () {
      final t = tableOf(specFor(sample));
      expect([for (final c in t.columns) if (c.inPdf) c.label], [
        'Date',
        'Time',
        'Produced Item',
        'Event',
        'Change',
        'Old → New',
        'Source',
        'Destination',
        'Staff',
      ]);
      expect([for (final c in t.columns) if (!c.inPdf && c.inExcel) c.id], [
        'title',
        'unit',
        'description',
        'managed',
      ]);
      final withDept = tableOf(specFor(sample, departmentsEnabled: true));
      expect([for (final c in withDept.columns) c.id], contains('department'));
    });

    test('change and balance; masked without the permission', () {
      final t = tableOf(specFor(sample));
      final transfer = t.rows.firstWhere((r) => r[t.indexOf('event')].text == 'Transferred to Sales');
      expect(transfer[t.indexOf('change')].text, '-15 Pcs');
      expect(transfer[t.indexOf('change')].raw, -15);
      expect(transfer[t.indexOf('balance')].text, '30 → 15');
      final masked = tableOf(specFor(sample, canSeeQuantity: false));
      expect(masked.rows.first[masked.indexOf('change')].text, '****');
      expect(masked.rows.first[masked.indexOf('balance')].text, '****');
    });

    test('totals: the records', () {
      final t = tableOf(specFor(sample));
      expect(t.totals![t.indexOf('date')].text, '6 records');
    });
  });

  group('splits', () {
    final f = ExportFormatter(currency: '₦');
    List<String> names(ReportExportSpec spec, String id) => [
      for (final g in resolveGroups(spec.tables.single, id, f)) g.name,
    ];

    test('Category, Department (when on) and Staff', () {
      final spec = specFor(sample, departmentsEnabled: true);
      expect(spec.splitOptions.map((s) => s.id), ['category', 'department', 'staff']);
      // The deleted muffin has no category.
      expect(names(spec, 'category'), ['Pastry', 'No Category']);
      expect(names(spec, 'department'), ['Bakery', 'Kitchen', 'No Department']);
      expect(names(spec, 'staff'), ['Ada', 'Ben', 'No Staff']);
      expect(specFor(sample).splitOptions.map((s) => s.id), ['category', 'staff']);
    });
  });

  test('filters and notes', () {
    final filters = ProductionHistoryFilters(
      itemKey: 'cake',
      eventKey: ProductionItemHistoryEventClass.productionCreated,
      direction: ProductionHistoryDirection.increase,
      staffKey: productionReportNoneKey,
      managed: true,
    );
    final spec = specFor(sample, filters: filters);
    expect([for (final x in spec.filters) '${x.label}: ${x.value}'], [
      'Produced Item: Cake',
      'Event: Produced',
      'Direction: Increase',
      'Staff: $productionNoStaffLabel',
      'Managed: Managed',
    ]);
    expect(spec.sortedBy, 'Date (descending)');
    expect(specFor(sample).notes, isEmpty);
    final all = historyQuery(historyRows(), period: const ReceiptsReportPeriod.allTime());
    expect(specFor(all, period: const ReceiptsReportPeriod.allTime()).notes, [
      'All time covers the history loaded on this device.',
      "1 history record couldn't be converted to the produced item's unit "
          'and is counted without a quantity.',
    ]);
  });

  test('roll at 58 and 80mm: the change on the item line, within the paper', () {
    for (final paper in RollPaper.values) {
      final out = renderRollEscPos(
        buildRollLines(specFor(sample), testCtx, paper: paper),
        paper,
      ).preview;
      final lines = out.split('\n');
      expect(
        lines.any((l) => l.startsWith('Donut') && l.endsWith('-15 Pcs')),
        isTrue,
        reason: paper.name,
      );
      expect(
        lines.skipWhile((l) => !l.startsWith('---')).every(
          (l) => l.length <= (paper == RollPaper.mm58 ? 32 : 48),
        ),
        isTrue,
        reason: paper.name,
      );
      expect(lines.every((l) => l.length <= paper.dots ~/ fontBDots), isTrue);
    }
  });
}
