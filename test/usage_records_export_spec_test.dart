import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/pages/report/components/export/report_export_format.dart';
import 'package:stockall/pages/report/components/export/report_export_resolve.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/export/report_roll_builder.dart';
import 'package:stockall/pages/report/production_report/production_records_table/class/production_records_table_logic.dart';
import 'package:stockall/pages/report/production_report/usage_records_table/class/usage_records_export_spec.dart';
import 'package:stockall/pages/report/production_report/usage_records_table/class/usage_records_table_logic.dart';
import 'package:stockall/pages/report/production_report/usage_records_table/components/usage_records_filter_widgets.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/services/printing/escpos_builder.dart' show fontBDots;

import 'item_history_export_fixtures.dart' show testCtx;
import 'production_report_fixtures.dart';
import 'usage_records_table_logic_test.dart' show query, day2;

final sample = query(usageRows(sampleUsages()));

/// The spec the table builds for [rows] (already the screen query).
ReportExportSpec specFor(
  List<UsageRecordRow> rows, {
  UsageGroupBy groupBy = UsageGroupBy.off,
  UsageRecordsFilters? filters,
  ReceiptsReportPeriod period = const ReceiptsReportPeriod.allTime(),
  List<ProductionRecordRow>? records,
  bool departmentsEnabled = false,
  bool canSeeCost = true,
  bool canSeeQuantity = true,
}) {
  final state = UsageRecordsTableState(filters: filters, groupBy: groupBy);
  final groups = UsageGrouping.sort(
    UsageGrouping.build(rows, groupBy),
    field: state.groupSortField,
    ascending: state.groupAscending,
  );
  return usageRecordsExportSpec(
    rows: rows,
    groups: groups,
    allUsages: rows,
    recordRows: records ?? recordRows(sampleRecords()),
    state: state,
    choices: UsageRecordsFilterChoices.fromRows(rows),
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
  test('150 usages: every row, in the screen order', () {
    final sorted = query(
      usageRows(manyUsages(150)),
      period: const ReceiptsReportPeriod.allTime(),
      sortField: UsageRecordsSortField.cost,
      ascending: true,
    );
    final t = tableOf(specFor(sorted));
    expect(t.rows, hasLength(150));
    expect([for (final r in t.rows) r[t.indexOf('id')].text], [
      for (final r in sorted) r.displayId,
    ]);
  });

  group('columns follow the screen', () {
    test('every column; Unit in Excel only', () {
      final t = tableOf(specFor(sample));
      expect([for (final c in t.columns) if (c.inPdf) c.label], [
        'ID',
        'Date',
        'Time',
        'Material',
        'Quantity',
        'Unit Cost',
        'Cost',
        'Source',
        'Production',
        'Staff',
        'Managed',
      ]);
      expect([for (final c in t.columns) if (!c.inPdf && c.inExcel) c.id], [
        'unit',
      ]);
    });

    test('Department only with departments on', () {
      final ids = pdfIds(tableOf(specFor(sample, departmentsEnabled: true)));
      expect(ids.indexOf('department'), ids.indexOf('staff') - 1);
      expect(pdfIds(tableOf(specFor(sample))), isNot(contains('department')));
    });

    test('no cost permission: no cost columns', () {
      final ids = pdfIds(tableOf(specFor(sample, canSeeCost: false)));
      expect(ids, isNot(contains('cost')));
      expect(ids, isNot(contains('unitCost')));
      expect(ids, contains('quantity'));
    });

    test('no quantity permission: no quantity or unit cost', () {
      final t = tableOf(specFor(sample, canSeeQuantity: false));
      final all = [for (final c in t.columns) c.id];
      for (final id in ['quantity', 'unit', 'qtyRoll', 'unitCost']) {
        expect(all, isNot(contains(id)));
      }
      expect(all, contains('cost'));
    });
  });

  test('cells', () {
    final spec = specFor(sample);
    expect(cellOf(spec, 'usage-1', 'quantity').text, '1 Bag');
    expect(cellOf(spec, 'usage-1', 'quantity').raw, 1);
    expect(cellOf(spec, 'usage-3', 'unit').text, 'Kg');
    expect(cellOf(spec, 'usage-1', 'cost').text, '₦5,000.00');
    expect(cellOf(spec, 'usage-3', 'unitCost').text, '₦400.00');
    expect(cellOf(spec, 'usage-1', 'source').text, 'Production');
    expect(cellOf(spec, 'usage-1', 'production').text, 'Donut #prod-1');
    expect(cellOf(spec, 'usage-4', 'production').text, '—');
    expect(cellOf(spec, 'usage-4', 'staff').text, 'Not Set');
    expect(cellOf(spec, 'usage-4', 'managed').text, 'No');
  });

  group('totals', () {
    test('equal the UsageRecordsPage totals the screen shows', () {
      final page = UsageRecordsQuery.paginate(sample, 1);
      final t = tableOf(specFor(sample));
      ResolvedCell total(String id) => t.totals![t.indexOf(id)];
      expect(total('id').text, '5 records');
      expect(total('cost').raw, page.totalCost);
      expect(total('cost').raw, 12250);
      // Mixed materials: no quantity total.
      expect(total('quantity').text, '—');
      expect(total('unitCost').text, '—');
    });

    test('one material selected: its quantity and unit cost', () {
      final f = UsageRecordsFilters(materialKey: 'flour');
      final rows = query(usageRows(sampleUsages()), filters: f);
      final t = tableOf(specFor(rows, filters: f));
      expect(t.totals![t.indexOf('quantity')].raw, 2.25);
      expect(t.totals![t.indexOf('unitCost')].raw, 5000);
    });
  });

  group('grouped', () {
    test('by Material: quantity, cost and average unit cost', () {
      final spec = specFor(sample, groupBy: UsageGroupBy.material);
      final t = tableOf(spec);
      expect([for (final c in t.columns) c.label], [
        'Material',
        'Records',
        'Qty Used',
        'Cost',
        'Avg Unit Cost',
        'Last Used',
      ]);
      final flour = t.rows.firstWhere((r) => r[0].text == 'Flour');
      expect(flour[t.indexOf('quantity')].text, '2.25 Bag');
      expect(flour[t.indexOf('unitCost')].raw, 5000);
      expect(t.totals![t.indexOf('records')].raw, 5);
      expect(t.totals![t.indexOf('cost')].raw, 12250);
      expect(spec.groupedBy, 'Material');
      expect(spec.sortedBy, 'Records (descending)');
      expect(spec.splitOptions, isEmpty);
    });

    test('by Staff: the none row last, no quantity', () {
      final t = tableOf(specFor(sample, groupBy: UsageGroupBy.staff));
      expect([for (final c in t.columns) c.id], isNot(contains('quantity')));
      expect(t.rows.last[0].text, productionNoStaffLabel);
    });
  });

  group('splits', () {
    final f = ExportFormatter(currency: '₦');
    List<String> names(ReportExportSpec spec, String id) => [
      for (final g in resolveGroups(spec.tables.single, id, f)) g.name,
    ];

    test('Material, Source and Staff; Department with departments on', () {
      final spec = specFor(sample);
      expect(spec.splitOptions.map((s) => s.id), [
        'material',
        'source',
        'staff',
      ]);
      expect(names(spec, 'material'), ['Flour', 'Sugar']);
      expect(names(spec, 'source'), ['Manual', 'Production']);
      expect(names(spec, 'staff'), ['Ada', 'Ben', 'No Staff']);

      final withDept = specFor(sample, departmentsEnabled: true);
      expect(withDept.splitOptions.map((s) => s.id), [
        'material',
        'source',
        'staff',
        'department',
      ]);
      expect(names(withDept, 'department'), [
        'Bakery',
        'Kitchen',
        'No Department',
      ]);
    });

    test('a split sheet of one material totals its quantity', () {
      final section =
          specFor(sample).tables.single as ExportTableSection<UsageRecordRow>;
      final sugar = sample.where((r) => r.materialKey == 'sugar').toList();
      expect(section.totalsFor!(sugar)['quantity'], 2.5);
      expect(section.totalsFor!(sample)['quantity'], '—');
    });
  });

  group('info box and notes', () {
    test('filters worded like the chips', () {
      final filters = UsageRecordsFilters(
        search: 'flour',
        materialKey: 'flour',
        source: UsageSource.manual,
        staffKey: productionReportNoneKey,
        managed: true,
        quantityMin: 1,
        costMax: 500,
      );
      final spec = specFor(sample, filters: filters);
      expect([for (final x in spec.filters) '${x.label}: ${x.value}'], [
        'Search: flour',
        'Material: Flour',
        'Source: Manual',
        'Staff: No staff',
        'Managed: Managed',
        'Quantity: 1 - Any',
        'Cost: Any - ₦500.00',
      ]);
      expect(specFor(sample).sortedBy, 'Date (descending)');
      final hidden = specFor(
        sample,
        filters: filters,
        canSeeCost: false,
        canSeeQuantity: false,
      );
      expect([for (final x in hidden.filters) x.label], [
        'Search',
        'Material',
        'Source',
        'Staff',
        'Managed',
      ]);
    });

    test('the notes are the screen notes, with earlier productions', () {
      expect(specFor(sample).notes, [
        'All time covers the usage records loaded on this device.',
      ]);
      final day = specFor(
        sample,
        period: day2,
        records: recordRows([...sampleRecords(), legacyRecord()]),
      );
      expect(day.notes, [
        "1 earlier production has no usage records and isn't included. "
            'Their materials appear in the Production Records report.',
      ]);
      expect(day.period!.label, 'Oct 2, 2026');
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

    test('58mm: Material · Cost, ID | date underneath', () {
      final out = preview(specFor(sample), RollPaper.mm58);
      final lines = out.split('\n');
      final i = lines.indexWhere(
        (l) => l.startsWith('Flour') && l.endsWith('N1,250.00'),
      );
      expect(i, greaterThan(0));
      expect(lines[i + 1].trim(), '#usage-5 | Oct 2, 2026');
      expect(fits(out, 32), isTrue);
      expect(
        lines.every((l) => l.length <= RollPaper.mm58.dots ~/ fontBDots),
        isTrue,
      );
    });

    test('80mm: Material · Qty · Cost, on one line', () {
      final out = preview(specFor(sample), RollPaper.mm80);
      final line = out
          .split('\n')
          .firstWhere((l) => l.startsWith('Flour') && l.endsWith('N1,250.00'));
      expect(line, contains('0.25 Bag'));
      expect(fits(out, 48), isTrue);
    });

    test('without cost: the quantity; grouped: name and cost', () {
      final noCost = preview(specFor(sample, canSeeCost: false), RollPaper.mm58);
      expect(noCost, contains('0.25 Bag'));
      expect(noCost, isNot(contains('N1,250.00')));
      final grouped = preview(
        specFor(sample, groupBy: UsageGroupBy.material),
        RollPaper.mm80,
      );
      expect(
        grouped
            .split('\n')
            .any((l) => l.startsWith('Flour') && l.endsWith('N11,250.00')),
        isTrue,
      );
      expect(fits(grouped, 48), isTrue);
    });
  });
}
