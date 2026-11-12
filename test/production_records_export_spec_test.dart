import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/pages/report/components/export/report_export_format.dart';
import 'package:stockall/pages/report/components/export/report_export_resolve.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/export/report_pdf_builder.dart';
import 'package:stockall/pages/report/components/export/report_roll_builder.dart';
import 'package:stockall/pages/report/production_report/production_records_table/class/production_records_export_spec.dart';
import 'package:stockall/pages/report/production_report/production_records_table/class/production_records_table_logic.dart';
import 'package:stockall/pages/report/production_report/production_records_table/components/production_records_filter_widgets.dart';
import 'package:stockall/pages/report/production_report/shared/class/production_report_access.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/services/printing/escpos_builder.dart' show fontBDots;

import 'item_history_export_fixtures.dart' show testCtx;
import 'production_records_table_logic_test.dart' show query;
import 'production_report_fixtures.dart';

final sample = query(recordRows(sampleRecords()));

/// The spec the table builds for [rows] (already the screen query).
ReportExportSpec specFor(
  List<ProductionRecordRow> rows, {
  ProductionGroupBy groupBy = ProductionGroupBy.off,
  ProductionRecordsFilters? filters,
  ReceiptsReportPeriod period = const ReceiptsReportPeriod.allTime(),
  bool departmentsEnabled = false,
  bool canSeeCost = true,
  bool canSeeQuantity = true,
}) {
  final state = ProductionRecordsTableState(filters: filters, groupBy: groupBy);
  final groups = ProductionGrouping.sort(
    ProductionGrouping.build(rows, groupBy),
    field: state.groupSortField,
    ascending: state.groupAscending,
  );
  return productionRecordsExportSpec(
    rows: rows,
    groups: groups,
    periodRows: rows,
    state: state,
    choices: ProductionRecordsFilterChoices.fromRows(rows),
    period: period,
    currency: '₦',
    departmentsEnabled: departmentsEnabled,
    canSeeCost: canSeeCost,
    canSeeQuantity: canSeeQuantity,
  );
}

ResolvedTable tableOf(ReportExportSpec spec) =>
    resolveExport(spec, testCtx).tables.single;

ResolvedCell cellOf(ReportExportSpec spec, String uuid, String columnId) {
  final t = tableOf(spec);
  final r = t.rows.firstWhere((r) => r[t.indexOf('id')].text == '#$uuid');
  return r[t.indexOf(columnId)];
}

/// Column ids the A4 PDF shows.
List<String> pdfIds(ResolvedTable t) => [
  for (final c in t.columns)
    if (c.inPdf) c.id,
];

void main() {
  group('rows are the screen query, every page', () {
    test('150 records: every row, in the screen order', () {
      final sorted = query(
        recordRows(manyRecords(150)),
        sortField: ProductionRecordsSortField.recordedCost,
      );
      final t = tableOf(specFor(sorted));
      expect(t.rows, hasLength(150));
      expect([for (final r in t.rows) r[t.indexOf('id')].text], [
        for (final r in sorted) r.displayId,
      ]);
    });
  });

  group('columns follow the screen', () {
    test('every column; Unit and Comment in Excel only', () {
      final t = tableOf(specFor(sample));
      expect([for (final c in t.columns) if (c.inPdf) c.label], [
        'ID',
        'Date',
        'Time',
        'Output',
        'Type',
        'Quantity',
        'Materials',
        'Lines',
        'Staff',
        'Material Cost',
        'Recorded Cost',
        'Cost Source',
        'Variance',
        'Cost / Unit',
      ]);
      expect([for (final c in t.columns) if (!c.inPdf && c.inExcel) c.id], [
        'unit',
        'comment',
      ]);
    });

    test('Department only with departments on', () {
      final t = tableOf(specFor(sample, departmentsEnabled: true));
      final ids = pdfIds(t);
      expect(ids.indexOf('department'), ids.indexOf('staff') - 1);
      expect(pdfIds(tableOf(specFor(sample))), isNot(contains('department')));
    });

    test('no cost permission: no cost columns', () {
      final ids = pdfIds(tableOf(specFor(sample, canSeeCost: false)));
      for (final id in [
        'materialCost',
        'recordedCost',
        'costSource',
        'variance',
        'costPerUnit',
      ]) {
        expect(ids, isNot(contains(id)));
      }
      expect(ids, contains('quantity'));
    });

    test('no quantity permission: no quantity or cost per unit', () {
      final t = tableOf(specFor(sample, canSeeQuantity: false));
      final all = [for (final c in t.columns) c.id];
      for (final id in ['quantity', 'unit', 'qtyRoll', 'costPerUnit']) {
        expect(all, isNot(contains(id)));
      }
      expect(all, contains('recordedCost'));
    });
  });

  group('cells', () {
    final spec = specFor(sample);
    test('quantity in the recorded unit, the primary one stored', () {
      expect(cellOf(spec, 'prod-2', 'quantity').text, '3 Box (36 Pcs)');
      expect(cellOf(spec, 'prod-2', 'quantity').raw, 36);
      expect(cellOf(spec, 'prod-2', 'unit').text, 'Pcs');
      expect(cellOf(spec, 'prod-1', 'quantity').text, '30 Pcs');
    });

    test('costs, cost source and comment', () {
      expect(cellOf(spec, 'prod-1', 'materialCost').text, '₦5,000.00');
      expect(cellOf(spec, 'prod-1', 'costPerUnit').text, '₦166.67');
      expect(cellOf(spec, 'prod-2', 'costSource').text, 'Item Cost');
      expect(cellOf(spec, 'prod-2', 'variance').raw, 1400);
      expect(cellOf(spec, 'prod-3', 'costSource').text, 'Custom');
      expect(cellOf(spec, 'prod-3', 'materials').text, productionNoMaterialsLabel);
      expect(cellOf(spec, 'prod-2', 'materials').text, 'Flour, Sugar');
      expect(cellOf(spec, 'prod-2', 'comment').text, 'Big order');
      expect(cellOf(spec, 'prod-3', 'staff').text, 'Not Set');
    });
  });

  group('totals', () {
    test('equal the ProductionRecordsPage totals the screen shows', () {
      final page = ProductionRecordsQuery.paginate(sample, 1);
      final t = tableOf(specFor(sample));
      ResolvedCell total(String id) => t.totals![t.indexOf(id)];
      expect(total('id').text, '3 records');
      expect(total('materialCost').raw, page.totalMaterialCost);
      expect(total('recordedCost').raw, page.totalRecordedCost);
      expect(total('variance').raw, page.totalVariance);
      // Mixed items: no quantity total.
      expect(total('quantity').text, '—');
      expect(total('costPerUnit').text, '—');
    });

    test('one output item selected: its quantity and cost per unit', () {
      final f = ProductionRecordsFilters(outputKey: 'donut');
      final rows = query(recordRows(sampleRecords()), filters: f);
      final t = tableOf(specFor(rows, filters: f));
      expect(t.totals![t.indexOf('quantity')].raw, 66);
      expect(
        t.totals![t.indexOf('costPerUnit')].raw as double,
        closeTo(12200 / 66, 1e-9),
      );
    });
  });

  group('grouped', () {
    test('by Material: the group table, distinct records, no recorded cost', () {
      final spec = specFor(sample, groupBy: ProductionGroupBy.material);
      final t = tableOf(spec);
      expect([for (final c in t.columns) c.label], [
        'Material',
        'Records',
        'Qty Used',
        'Material Cost',
      ]);
      expect(t.rows.last[0].text, productionNoMaterialsLabel);
      expect(t.totals![t.indexOf('records')].raw, 3);
      expect(t.totals![t.indexOf('materialCost')].raw, 10800);
      expect(spec.groupedBy, 'Material');
      expect(spec.sortedBy, 'Records (descending)');
      expect(spec.splitOptions, isEmpty);
    });

    test('by Output Item: quantity and cost per unit', () {
      final t = tableOf(specFor(sample, groupBy: ProductionGroupBy.outputItem));
      expect([for (final c in t.columns) c.label], [
        'Output Item',
        'Records',
        'Qty Produced',
        'Material Cost',
        'Recorded Cost',
        'Variance',
        'Cost / Unit',
      ]);
      final donut = t.rows.firstWhere((r) => r[0].text == 'Donut');
      expect(donut[t.indexOf('quantity')].text, '66 Pcs');
      expect(t.totals![t.indexOf('recordedCost')].raw, 13400);
    });
  });

  group('splits', () {
    final f = ExportFormatter(currency: '₦');
    List<String> names(ReportExportSpec spec, String id) => [
      for (final g in resolveGroups(spec.tables.single, id, f)) g.name,
    ];

    test('Output item and Staff; Department with departments on', () {
      final spec = specFor(sample);
      expect(spec.splitOptions.map((s) => s.id), ['output', 'staff']);
      expect(names(spec, 'output'), ['Donut', 'Juice']);
      expect(names(spec, 'staff'), ['Ada', 'Ben', 'No Staff']);

      final withDept = specFor(sample, departmentsEnabled: true);
      expect(withDept.splitOptions.map((s) => s.id), [
        'output',
        'staff',
        'department',
      ]);
      expect(names(withDept, 'department'), ['Bakery', 'No Department']);
    });

    test('a split sheet of one output item totals its quantity', () {
      final section = specFor(sample).tables.single as ExportTableSection<ProductionRecordRow>;
      final donuts = sample.where((r) => r.outputKey == 'donut').toList();
      final totals = section.totalsFor!(donuts);
      expect(totals['quantity'], 66);
    });
  });

  group('info box and notes', () {
    test('filters worded like the chips', () {
      final filters = ProductionRecordsFilters(
        search: 'flour',
        outputKey: 'donut',
        materialKey: productionReportNoneKey,
        staffKey: staffBen,
        costSource: ProductionCostSource.custom,
        quantityMin: 10,
        costMax: 500,
      );
      final spec = specFor(sample, filters: filters);
      expect([for (final x in spec.filters) '${x.label}: ${x.value}'], [
        'Search: flour',
        'Output Item: Donut',
        'Material: No materials',
        'Staff: Ben',
        'Cost Source: Custom',
        'Quantity: 10 - Any',
        'Recorded Cost: Any - ₦500.00',
      ]);
      expect(specFor(sample).sortedBy, 'Date (descending)');
      // Cost filters stay out without the cost permission.
      final hidden = specFor(sample, filters: filters, canSeeCost: false);
      expect(
        [for (final x in hidden.filters) x.label],
        isNot(contains('Cost Source')),
      );
    });

    test('the notes are the screen notes', () {
      final all = specFor(sample);
      expect(all.notes, [
        'All time covers the production records loaded on this device.',
        '1 record uses a custom cost; Variance shows the difference from '
            'the materials.',
      ]);
      final day = specFor(
        sample,
        period: ReceiptsReportPeriod.day(DateTime(2026, 10, 2)),
      );
      expect(day.notes, hasLength(1));
      expect(day.period!.label, 'Oct 2, 2026');
      final info = {
        for (final e in reportPdfInfoEntries(resolveExport(all, testCtx)))
          e.$1: e.$2,
      };
      expect(info['Notes'], contains('All time covers'));
    });
  });

  group('roll', () {
    String preview(ReportExportSpec spec, RollPaper paper) => renderRollEscPos(
      buildRollLines(spec, testCtx, paper: paper),
      paper,
    ).preview;

    // The table body (after the header's notes, which print in the
    // small font and may be wider) fits the paper's normal width.
    bool fits(String out, int width) => out
        .split('\n')
        .skipWhile((l) => !l.startsWith('---'))
        .every((l) => l.length <= width);

    test('58mm: Output · Recorded Cost, ID | date underneath', () {
      final out = preview(specFor(sample), RollPaper.mm58);
      final lines = out.split('\n');
      final i = lines.indexWhere(
        (l) => l.startsWith('Donut') && l.endsWith('N7,200.00'),
      );
      expect(i, greaterThan(0));
      expect(lines[i + 1].trim(), '#prod-2 | Oct 2, 2026');
      expect(fits(out, 32), isTrue);
      expect(
        lines.every((l) => l.length <= RollPaper.mm58.dots ~/ fontBDots),
        isTrue,
      );
    });

    test('80mm: Output · Qty · Recorded Cost, on one line', () {
      final out = preview(specFor(sample), RollPaper.mm80);
      final line = out
          .split('\n')
          .firstWhere((l) => l.startsWith('Donut') && l.endsWith('N7,200.00'));
      expect(line, contains('36 Pcs'));
      expect(fits(out, 48), isTrue);
    });

    test('without cost: the quantity; grouped: name and cost', () {
      final noCost = preview(specFor(sample, canSeeCost: false), RollPaper.mm58);
      expect(noCost, contains('36 Pcs'));
      expect(noCost, isNot(contains('N7,200.00')));
      final grouped = preview(
        specFor(sample, groupBy: ProductionGroupBy.staff),
        RollPaper.mm80,
      );
      expect(
        grouped.split('\n').any((l) => l.startsWith('Ben') && l.endsWith('N7,200.00')),
        isTrue,
      );
      expect(fits(grouped, 48), isTrue);
    });
  });
}
