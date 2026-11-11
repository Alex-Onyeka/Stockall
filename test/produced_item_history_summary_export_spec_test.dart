import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/pages/report/components/export/report_export_format.dart';
import 'package:stockall/pages/report/components/export/report_export_resolve.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/export/report_roll_builder.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/production_stock_model.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/stock_history_summary_export_spec.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/stock_history_summary_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/services/printing/escpos_builder.dart' show fontBDots;

import 'item_history_export_fixtures.dart' show testCtx;
import 'produced_item_history_summary_logic_test.dart' show summaryRows, day2;
import 'production_report_fixtures.dart';

final all = summaryRows();

ReportExportSpec specFor({
  List<ProductionHistorySummaryRow>? allRows,
  ProductionHistorySummaryFilters? filters,
  ReceiptsReportPeriod? period,
  bool departmentsEnabled = false,
  bool canSeeQuantity = true,
}) {
  final state = ProductionHistorySummaryState(filters: filters);
  final everything = allRows ?? all;
  return productionHistorySummaryExportSpec(
    kind: ProductionStockKind.producedItem,
    allRows: everything,
    rows: ProductionHistorySummaryBuilder.filterAndSort(
      rows: everything,
      filters: state.filters,
      sort: state.sort,
      canSeeQuantity: canSeeQuantity,
    ),
    state: state,
    categoryNames: sampleCategories(),
    period: period ?? day2,
    currency: '₦',
    departmentsEnabled: departmentsEnabled,
    canSeeQuantity: canSeeQuantity,
  );
}

ResolvedTable tableOf(ReportExportSpec spec) => resolveExport(spec, testCtx).tables.single;

ResolvedSummary statsOf(ReportExportSpec spec) =>
    resolveExport(spec, testCtx).sections.whereType<ResolvedSummary>().single;

void main() {
  test('150 items: every row, in the screen order', () {
    final many = ProductionHistorySummaryBuilder.build(
      kind: ProductionStockKind.producedItem,
      items: [
        for (final p in manyProducedItems(150)) ProductionStockItem.fromProducedItem(p),
      ],
      entries: const [],
      categoryNames: const {},
      period: day2,
    );
    final t = tableOf(specFor(allRows: many));
    expect(t.rows, hasLength(150));
    expect(t.rows.first[0].text, 'Item 001');
    expect(t.rows.last[0].text, 'Item 150');
  });

  group('statistics', () {
    test('every item of the period, whatever the filters', () {
      final s = statsOf(
        specFor(
          filters: ProductionHistorySummaryFilters(
            movement: ProductionHistoryMovementFilter.outflowOnly,
          ),
        ),
      );
      expect([for (final m in s.metrics) m.label], [
        'Produced Items With Movement',
        'Produced',
        'Transferred to Sales',
        'Net Change',
        'History Records',
      ]);
      expect(s.metrics[0].raw, 3);
      expect(s.metrics[0].note, 'of 4 items');
      expect(s.metrics[1].raw, '47 Pcs');
      expect(s.metrics[2].raw, '15 Pcs');
      expect(s.metrics[4].raw, 6);
    });

    test('masked without the quantity permission', () {
      final s = statsOf(specFor(canSeeQuantity: false));
      expect(s.metrics[1].raw, '****');
      expect(s.metrics[0].raw, 3);
    });
  });

  group('table', () {
    test('the screen columns, net produced after production deleted', () {
      final t = tableOf(specFor());
      expect([for (final c in t.columns) c.label], [
        'Produced Item',
        'Primary Unit',
        'Opening',
        'Produced',
        'Production Deleted',
        'Net Produced',
        'Transferred to Sales',
        'Transferred to Branch',
        'Transferred In',
        'Manual Increase',
        'Manual Decrease',
        'Created',
        'Deleted',
        'Additions',
        'Reductions',
        'Net',
        'Closing',
        'Records',
      ]);
    });

    test("Alex's donuts and the filtered rows", () {
      final spec = specFor(
        filters: ProductionHistorySummaryFilters(
          movement: ProductionHistoryMovementFilter.outflowOnly,
        ),
      );
      final t = tableOf(spec);
      expect([for (final r in t.rows) r[0].text], ['Cake', 'Donut']);
      final donut = t.rows.last;
      expect(donut[t.indexOf('produced')].raw, 30);
      expect(donut[t.indexOf('transferredToSales')].raw, 15);
      expect(donut[t.indexOf('net')].text, '+15');
      expect(donut[t.indexOf('closing')].raw, 15);
      expect(t.totals![t.indexOf('name')].text, '2 items');
      expect(t.totals![t.indexOf('events')].raw, 5);
      expect([for (final x in spec.filters) '${x.label}: ${x.value}'], [
        'Movement: Outflow Only',
      ]);
    });

    test('masked quantities', () {
      final t = tableOf(specFor(canSeeQuantity: false));
      final donut = t.rows.firstWhere((r) => r[0].text == 'Donut');
      expect(donut[t.indexOf('produced')].text, '****');
      expect(donut[t.indexOf('events')].raw, 2);
    });
  });

  test('splits: Category; Department with departments on', () {
    final f = ExportFormatter(currency: '₦');
    List<String> names(ReportExportSpec spec, String id) => [
      for (final g in resolveGroups(spec.tables.last, id, f)) g.name,
    ];
    expect(specFor().splitOptions.map((s) => s.id), ['category']);
    final withDept = specFor(departmentsEnabled: true);
    expect(withDept.splitOptions.map((s) => s.id), ['category', 'department']);
    expect(names(withDept, 'category'), ['Pastry', 'No Category']);
    expect(names(withDept, 'department'), ['Bakery', 'Kitchen', 'No Department']);
  });

  test('notes and roll', () {
    expect(
      specFor(period: const ReceiptsReportPeriod.allTime()).notes.first,
      'All time covers the history loaded on this device.',
    );
    for (final paper in RollPaper.values) {
      final out = renderRollEscPos(
        buildRollLines(specFor(), testCtx, paper: paper),
        paper,
      ).preview;
      final lines = out.split('\n');
      expect(lines.any((l) => l.startsWith('Donut') && l.endsWith('+15')), isTrue);
      expect(lines.every((l) => l.length <= paper.dots ~/ fontBDots), isTrue);
    }
  });
}

