import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/pages/report/components/export/report_export_format.dart';
import 'package:stockall/pages/report/components/export/report_export_resolve.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/export/report_export_splits.dart';

import 'report_export_fixtures.dart';

void main() {
  final f = ExportFormatter(currency: '₦');

  ResolvedTable onlyTable(ResolvedExport r) => r.tables.single;

  List<String> column(ResolvedTable t, String id) => [
    for (final row in t.rows) row[t.indexOf(id)].text,
  ];

  group('cells', () {
    test('keeps the typed value and the formatted text', () {
      final t = onlyTable(resolveExport(itemsSpec(sampleItems), testContext));
      final coke = t.rows.first;
      expect(coke[t.indexOf('price')].raw, 125);
      expect(coke[t.indexOf('price')].text, '₦125.00');
      expect(coke[t.indexOf('margin')].text, '20%');
      expect(coke[t.indexOf('created')].text, 'Oct 1, 2026');
      expect(coke[t.indexOf('createdTime')].text, '09:30 AM');
    });

    test('display overrides the text but keeps the raw value', () {
      final t = onlyTable(resolveExport(itemsSpec(sampleItems), testContext));
      expect(column(t, 'qty'), [
        '12 Bottles',
        '2.5 Trays',
        '3 Sheets (4 x 2)',
        'Not managed',
      ]);
      expect(t.rows[2][t.indexOf('qty')].raw, 3);
      expect(t.rows[3][t.indexOf('qty')].raw, isNull);
    });

    test('null values give empty text', () {
      final t = onlyTable(resolveExport(itemsSpec(sampleItems), testContext));
      final service = t.rows.last;
      expect(service[t.indexOf('total')].text, '');
      expect(service[t.indexOf('created')].text, '');
    });

    test('negative money keeps its sign before the currency', () {
      final t = onlyTable(resolveExport(itemsSpec(sampleItems), testContext));
      expect(t.rows[2][t.indexOf('total')].text, '-₦1,500.00');
      expect(t.rows[2][t.indexOf('margin')].text, '-3.46%');
    });

    test('columns carry alignment, width and PDF visibility', () {
      final t = onlyTable(resolveExport(itemsSpec(sampleItems), testContext));
      expect(t.columns[t.indexOf('name')].align, ExportAlign.left);
      expect(t.columns[t.indexOf('total')].align, ExportAlign.right);
      expect(t.columns[t.indexOf('name')].width, 3);
      expect(t.columns[t.indexOf('createdTime')].inPdf, isFalse);
      expect(t.pdfColumnIndexes, isNot(contains(t.indexOf('createdTime'))));
      expect(t.hasExcelOnlyColumns, isTrue);
    });

    test('rows keep the spec order (the screen sort)', () {
      final t = onlyTable(resolveExport(itemsSpec(sampleItems), testContext));
      expect(column(t, 'name'), [
        'Coke',
        'Meat Pie',
        'Roofing Sheet',
        'Service Charge',
      ]);
    });
  });

  group('totals', () {
    test('the screen totals win over totalsFor for the full table', () {
      final spec = ReportExportSpec(
        reportName: 'Items Report',
        fileSlug: 'items',
        sections: [
          itemsSection(
            sampleItems,
            totals: {'name': 'All items', 'total': 99999},
          ),
        ],
      );
      final t = onlyTable(resolveExport(spec, testContext));
      expect(t.totals![t.indexOf('name')].text, 'All items');
      expect(t.totals![t.indexOf('total')].text, '₦99,999.00');
      expect(t.totals![t.indexOf('price')].text, '');
    });

    test('without screen totals, totalsFor runs over every row', () {
      final t = onlyTable(resolveExport(itemsSpec(sampleItems), testContext));
      expect(t.totals![t.indexOf('name')].text, '4 items');
      // 1500 + 2500 - 1500 + 0
      expect(t.totals![t.indexOf('total')].raw, 2500);
      expect(t.totals![t.indexOf('total')].text, '₦2,500.00');
    });

    test('no totals when the table has neither', () {
      final section = ExportTableSection<TItem>(
        title: 'Items',
        rows: sampleItems,
        columns: [
          ExportColumn<TItem>(id: 'name', label: 'Name', value: (r) => r.name),
        ],
        roll: const RollLayout(cols58: ['name'], cols80: ['name']),
      );
      final t = resolveTable(section, f);
      expect(t.totals, isNull);
    });

    test('each split group gets its own totals', () {
      final t = itemsSection(sampleItems);
      final groups = resolveGroups(t, 'category', f);
      final drinks = groups.firstWhere((g) => g.name == 'Drinks');
      // Coke 1500 + Meat Pie 2500
      expect(drinks.table.totals![0].text, '2 items');
      expect(drinks.table.totals![drinks.table.indexOf('total')].raw, 4000);
      final bakery = groups.firstWhere((g) => g.name == 'Bakery');
      expect(bakery.table.totals![bakery.table.indexOf('total')].raw, 2500);
    });
  });

  group('splits', () {
    test('a row in two categories appears in both groups', () {
      final groups = resolveGroups(itemsSection(sampleItems), 'category', f);
      final byName = {
        for (final g in groups) g.name: column(g.table, 'name'),
      };
      expect(byName['Drinks'], ['Coke', 'Meat Pie']);
      expect(byName['Bakery'], ['Meat Pie']);
    });

    test('groups sort by name and "No X" comes last', () {
      final groups = resolveGroups(itemsSection(sampleItems), 'category', f);
      expect(groups.map((g) => g.name), [
        'Bakery',
        'Drinks',
        'No Category',
      ]);
      expect(groups.last.isNone, isTrue);
    });

    test('unknown (deleted) category ids count as none', () {
      final groups = resolveGroups(itemsSection(sampleItems), 'category', f);
      expect(column(groups.last.table, 'name'), [
        'Roofing Sheet',
        'Service Charge',
      ]);
    });

    test('empty groups are skipped', () {
      final groups = resolveGroups(itemsSection(sampleItems), 'category', f);
      expect(groups.map((g) => g.name), isNot(contains('Empty Category')));
    });

    test('department split', () {
      final groups = resolveGroups(
        itemsSection(sampleItems),
        'department',
        f,
      );
      expect(groups.map((g) => g.name), [
        'Back Store',
        'Front Shop',
        'No Department',
      ]);
    });

    test('no "No X" group when every row has a key', () {
      final groups = resolveGroups(
        itemsSection(sampleItems.take(2).toList()),
        'category',
        f,
      );
      expect(groups.any((g) => g.isNone), isFalse);
    });

    test('an unknown split id is an error', () {
      expect(
        () => resolveGroups(itemsSection(sampleItems), 'supplier', f),
        throwsArgumentError,
      );
    });

    test('field splits take names from the rows', () {
      final split = fieldSplit<TItem>(
        id: 'unit',
        label: 'Unit',
        noneLabel: 'No Unit',
        rows: sampleItems,
        key: (r) => r.unit.toLowerCase(),
        name: (r) => r.unit,
      );
      expect(split.keys(sampleItems.first), ['bottles']);
      expect(split.name('bottles'), 'Bottles');
      expect(split.name('missing'), 'missing');
    });

    test('label splits treat blanks as none', () {
      final split = channelSplit<TItem>(
        channel: (r) => r.dept == null ? '  ' : 'Cash',
      );
      expect(split.keys(sampleItems.first), ['Cash']);
      expect(split.keys(sampleItems.last), isEmpty);
    });

    test('splitOptions lists the main table splits', () {
      expect(
        itemsSpec(sampleItems).splitOptions.map((s) => s.label),
        ['Category', 'Department'],
      );
    });
  });

  group('workbook sheets', () {
    test('no split gives one sheet named after the report', () {
      final wb = resolveWorkbook(itemsSpec(sampleItems), testContext);
      expect(wb.sheets.map((s) => s.name), ['Items Report']);
      expect(wb.splitLabel, isNull);
    });

    test('a split gives "All" first, then one sheet per group', () {
      final wb = resolveWorkbook(
        itemsSpec(sampleItems),
        testContext,
        splitId: 'category',
      );
      expect(wb.sheets.map((s) => s.name), [
        'All',
        'Bakery',
        'Drinks',
        'No Category',
      ]);
      expect(wb.splitLabel, 'Category');
      final all = wb.sheets.first.sections.whereType<ResolvedTable>().single;
      expect(all.rows.length, 4);
      expect(wb.sheets[2].groupName, 'Drinks');
    });

    test('group sheets hold only the split table', () {
      final summary = ExportSummarySection(
        title: 'Overview',
        metrics: const [ExportMetric(label: 'Stock value', value: 4000)],
      );
      final wb = resolveWorkbook(
        itemsSpec(sampleItems, extraSections: [summary]),
        testContext,
        splitId: 'department',
      );
      expect(wb.sheets.first.sections.length, 2);
      for (final s in wb.sheets.skip(1)) {
        expect(s.sections.single, isA<ResolvedTable>());
      }
    });

    test('more than 100 groups is refused; exactly 100 is fine', () {
      List<TItem> rows(int n) => [
        for (var i = 0; i < n; i++)
          TItem(id: '$i', name: 'Item $i', qty: 1, price: 1, total: 1, dept: 'd$i'),
      ];
      ReportExportSpec spec(int n) => ReportExportSpec(
        reportName: 'Items',
        fileSlug: 'items',
        sections: [
          ExportTableSection<TItem>(
            title: 'Items',
            rows: rows(n),
            columns: [
              ExportColumn<TItem>(id: 'name', label: 'Name', value: (r) => r.name),
            ],
            splits: [
              fieldSplit<TItem>(
                id: 'dept',
                label: 'Dept',
                noneLabel: 'No Dept',
                rows: rows(n),
                key: (r) => r.dept,
                name: (r) => r.dept,
              ),
            ],
            roll: const RollLayout(cols58: ['name'], cols80: ['name']),
          ),
        ],
      );

      expect(splitGroupCount(spec(101), 'dept'), 101);
      expect(
        () => resolveWorkbook(spec(101), testContext, splitId: 'dept'),
        throwsA(
          isA<ExportTooManySheets>()
              .having((e) => e.groups, 'groups', 101)
              .having((e) => e.limit, 'limit', 100),
        ),
      );
      final ok = resolveWorkbook(spec(100), testContext, splitId: 'dept');
      expect(ok.sheets.length, 101);
    });
  });

  group('sheet names', () {
    test('strips characters Excel rejects', () {
      expect(sanitizeSheetName('Snacks/Treats: [Hot]*?\\', {}), 'Snacks Treats Hot');
    });

    test('keeps at most 31 characters', () {
      final name = sanitizeSheetName('A' * 40, {});
      expect(name.length, 31);
    });

    test('duplicates differ only by case get a number', () {
      final used = <String>{};
      expect(sanitizeSheetName('Drinks', used), 'Drinks');
      expect(sanitizeSheetName('drinks', used), 'drinks (2)');
      expect(sanitizeSheetName('DRINKS', used), 'DRINKS (3)');
    });

    test('numbered long names still fit in 31 characters', () {
      final used = <String>{};
      final first = sanitizeSheetName('B' * 40, used);
      final second = sanitizeSheetName('B' * 40, used);
      expect(first.length, 31);
      expect(second.length, lessThanOrEqualTo(31));
      expect(second, endsWith(' (2)'));
    });

    test('blank, reserved and quoted names', () {
      final used = <String>{};
      expect(sanitizeSheetName('   ', used), 'Unnamed');
      expect(sanitizeSheetName('/*', used), 'Unnamed (2)');
      expect(sanitizeSheetName('History', used), 'History Records');
      expect(sanitizeSheetName("'Quoted'", used), 'Quoted');
    });

    test('a group named "All" does not clash with the All sheet', () {
      final spec = ReportExportSpec(
        reportName: 'Items',
        fileSlug: 'items',
        sections: [
          ExportTableSection<TItem>(
            title: 'Items',
            rows: sampleItems,
            columns: [
              ExportColumn<TItem>(id: 'name', label: 'Name', value: (r) => r.name),
            ],
            splits: [
              labelSplit<TItem>(
                id: 'x',
                label: 'X',
                noneLabel: 'None',
                value: (r) => 'all',
              ),
            ],
            roll: const RollLayout(cols58: ['name'], cols80: ['name']),
          ),
        ],
      );
      final wb = resolveWorkbook(spec, testContext, splitId: 'x');
      expect(wb.sheets.map((s) => s.name), ['All', 'all (2)']);
    });
  });

  group('empty data', () {
    test('the table resolves with no rows and zero totals', () {
      final t = onlyTable(resolveExport(itemsSpec(const []), testContext));
      expect(t.isEmpty, isTrue);
      expect(t.totals![0].text, '0 items');
      expect(t.emptyMessage, isNotEmpty);
    });

    test('a split of no rows gives just the All sheet', () {
      final wb = resolveWorkbook(
        itemsSpec(const []),
        testContext,
        splitId: 'category',
      );
      expect(wb.sheets.map((s) => s.name), ['All']);
    });

    test('record count', () {
      expect(resolveExport(itemsSpec(const []), testContext).meta.recordCount, 0);
      expect(resolveExport(itemsSpec(sampleItems), testContext).meta.recordCount, 4);
    });
  });

  group('meta', () {
    test('filters text, or None', () {
      final m = resolveExport(itemsSpec(sampleItems), testContext).meta;
      expect(m.filtersText, 'Stock level: In Stock; Search: co');
      const empty = ReportExportSpec(reportName: 'X', fileSlug: 'x', sections: []);
      expect(resolveMeta(empty, testContext).filtersText, 'None');
    });

    test('summary metrics format by type and keep notes', () {
      final s = resolveSummary(
        ExportSummarySection(
          title: 'Money In',
          metrics: const [
            ExportMetric(
              label: 'Total Revenue',
              value: 1500000000,
              note: '+12.5% vs previous period',
            ),
            ExportMetric(label: 'Receipts', value: 42, format: ExportFormat.integer),
          ],
        ),
        f,
      );
      expect(s.metrics.first.text, '₦1,500,000,000.00');
      expect(s.metrics.last.text, '42');
      expect(s.hasNotes, isTrue);
    });
  });
}
