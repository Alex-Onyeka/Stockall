import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/pages/report/components/export/report_excel_builder.dart';
import 'package:stockall/pages/report/components/export/report_export_resolve.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';

import 'report_export_fixtures.dart';

/// A minimal xlsx reader: sheet names in order, and each sheet's cells
/// as row -> column -> value (shared strings resolved).
class _Xlsx {
  final Archive archive;
  final List<String> sheetNames;
  final Map<String, Map<int, Map<int, String>>> sheets;
  final String styles;

  _Xlsx._(this.archive, this.sheetNames, this.sheets, this.styles);

  factory _Xlsx(List<int> bytes) {
    final archive = ZipDecoder().decodeBytes(bytes);
    String read(String path) => utf8.decode(archive.findFile(path)!.content);

    final workbook = read('xl/workbook.xml');
    final rels = read('xl/_rels/workbook.xml.rels');
    final relTargets = <String, String>{};
    for (final m in RegExp(r'<Relationship\b[^>]*>').allMatches(rels)) {
      final tag = m.group(0)!;
      relTargets[_attr(tag, 'Id')!] = _attr(tag, 'Target')!;
    }

    final shared = <String>[];
    final sharedFile = archive.findFile('xl/sharedStrings.xml');
    if (sharedFile != null) {
      final xml = utf8.decode(sharedFile.content);
      for (final si in RegExp(r'<si>(.*?)</si>', dotAll: true).allMatches(xml)) {
        shared.add(_unescape(
          RegExp(r'<t[^>]*>(.*?)</t>', dotAll: true)
              .allMatches(si.group(1)!)
              .map((t) => t.group(1)!)
              .join(),
        ));
      }
    }

    final names = <String>[];
    final sheets = <String, Map<int, Map<int, String>>>{};
    for (final m in RegExp(r'<sheet\b[^>]*/>').allMatches(workbook)) {
      final tag = m.group(0)!;
      final name = _unescape(_attr(tag, 'name')!);
      final target = relTargets[_attr(tag, 'r:id')!]!;
      names.add(name);
      sheets[name] = _cells(read('xl/${target.replaceFirst('/xl/', '')}'), shared);
    }
    return _Xlsx._(archive, names, sheets, read('xl/styles.xml'));
  }

  static String? _attr(String tag, String name) =>
      RegExp('\\b${RegExp.escape(name)}="([^"]*)"').firstMatch(tag)?.group(1);

  static String _unescape(String s) => s
      .replaceAll('&quot;', '"')
      .replaceAll('&apos;', "'")
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&amp;', '&');

  static int _col(String letters) =>
      letters.codeUnits.fold(0, (n, c) => n * 26 + (c - 64));

  static Map<int, Map<int, String>> _cells(String xml, List<String> shared) {
    final out = <int, Map<int, String>>{};
    final cell = RegExp(r'<c\b([^>]*?)(?:/>|>(.*?)</c>)', dotAll: true);
    for (final m in cell.allMatches(xml)) {
      final attrs = m.group(1)!;
      final ref = _attr(attrs, 'r')!;
      final parts = RegExp(r'^([A-Z]+)(\d+)$').firstMatch(ref)!;
      final body = m.group(2) ?? '';
      final v = RegExp(r'<v>(.*?)</v>', dotAll: true).firstMatch(body)?.group(1);
      final inline = RegExp(r'<t[^>]*>(.*?)</t>', dotAll: true).firstMatch(body)?.group(1);
      String? value;
      final type = _attr(attrs, 't');
      if (type == 's' && v != null) {
        value = shared[int.parse(v)];
      } else if (type == 'inlineStr' && inline != null) {
        value = _unescape(inline);
      } else if (v != null) {
        value = _unescape(v);
      }
      if (value == null) continue;
      out.putIfAbsent(int.parse(parts.group(2)!), () => {})[_col(parts.group(1)!)] = value;
    }
    return out;
  }

  /// Rows of [sheet] as lists (missing cells are '').
  List<List<String>> rows(String sheet) {
    final cells = sheets[sheet]!;
    final keys = cells.keys.toList()..sort();
    return [
      for (final r in keys)
        [
          for (var c = 1; c <= cells[r]!.keys.fold<int>(0, (m, k) => k > m ? k : m); c++)
            cells[r]![c] ?? '',
        ],
    ];
  }

  /// The row whose first cell is [first].
  List<String> rowStarting(String sheet, String first) =>
      rows(sheet).firstWhere((r) => r.isNotEmpty && r.first == first);

  /// Data rows of the first table: after the header, until the totals.
  List<List<String>> dataRows(String sheet, {String header = 'Item Name'}) {
    final all = rows(sheet);
    final start = all.indexWhere((r) => r.isNotEmpty && r.first == header);
    final out = <List<String>>[];
    for (final r in all.skip(start + 1)) {
      if (r.isEmpty || r.first.startsWith('TOTAL')) break;
      out.add(r);
    }
    return out;
  }
}

void main() {
  _Xlsx build(ReportExportSpec spec, {String? splitId}) {
    final wb = resolveWorkbook(spec, testContext, splitId: splitId);
    return _Xlsx(buildReportWorkbook(wb));
  }

  group('single sheet', () {
    final x = build(itemsSpec(sampleItems));

    test('one sheet named after the report', () {
      expect(x.sheetNames, ['Items Report']);
    });

    test('details block above the table', () {
      final firstColumn = x.rows('Items Report').map((r) => r.isEmpty ? '' : r.first).toList();
      expect(firstColumn, containsAllInOrder([
        'Mama Put Stores',
        'Items Report',
        'Period: Oct 1, 2026 - Oct 31, 2026',
        'Filters: Stock level: In Stock; Search: co',
        'Sorted by: Item Name (A-Z)',
        'Generated by Ada Obi on Nov 4, 2026 | 02:05 PM',
        'Items',
        'Item Name',
      ]));
    });

    test('header row has every visible column, Excel-only ones included', () {
      expect(x.rowStarting('Items Report', 'Item Name'), [
        'Item Name',
        'Quantity',
        'Selling Price',
        'Total Selling Value',
        'Profit Margin',
        'Created Date',
        'Created Time',
      ]);
    });

    test('numbers are stored as numbers, text overrides as text', () {
      final rows = x.dataRows('Items Report');
      expect(rows.map((r) => r.first), [
        'Coke',
        'Meat Pie',
        'Roofing Sheet',
        'Service Charge',
      ]);
      // Quantity: raw numbers; a missing quantity keeps its "Not managed".
      expect(double.parse(rows[0][1]), 12);
      expect(double.parse(rows[1][1]), 2.5);
      expect(double.parse(rows[2][1]), 3);
      expect(rows[3][1], 'Not managed');
      // Money and negatives.
      expect(double.parse(rows[0][3]), 1500);
      expect(double.parse(rows[2][3]), -1500);
      // Percent stored as a fraction.
      expect(double.parse(rows[1][4]), closeTo(0.125, 1e-9));
    });

    test('dates are stored as Excel serial numbers', () {
      final rows = x.dataRows('Items Report');
      final serial = double.parse(rows[0][5]);
      // Oct 1, 2026 is day 46296 in Excel's 1900 date system.
      expect(serial.floor(), 46296);
    });

    test('number formats: ₦ money, dates, percent', () {
      expect(x.styles, contains('&quot;₦&quot;#,##0.00;-&quot;₦&quot;#,##0.00'));
      expect(x.styles, contains('dd mmm yyyy'));
      // 0.00% is Excel's built-in format 10, so it has no numFmt entry.
      expect(x.styles, contains('numFmtId="10"'));
    });

    test('totals row: label with its text, then the totals', () {
      final totals = x.rowStarting('Items Report', 'TOTAL (4 items)');
      expect(double.parse(totals[3]), 2500);
    });
  });

  group('notes and roll-only columns', () {
    test('a "Notes:" line per note in the details block', () {
      final x = build(itemsSpec(sampleItems, notes: sampleNotes));
      final firstColumn = x.rows('Items Report').map((r) => r.isEmpty ? '' : r.first).toList();
      expect(firstColumn, containsAllInOrder([
        'Sorted by: Item Name (A-Z)',
        'Notes: ${sampleNotes[0]}',
        'Notes: ${sampleNotes[1]}',
        'Generated by Ada Obi on Nov 4, 2026 | 02:05 PM',
      ]));
      final plain = build(itemsSpec(sampleItems));
      expect(
        plain.rows('Items Report').where((r) => r.isNotEmpty && r.first.startsWith('Notes:')),
        isEmpty,
      );
    });

    test('notes are on every split sheet', () {
      final x = build(itemsSpec(sampleItems, notes: sampleNotes), splitId: 'category');
      for (final name in x.sheetNames) {
        expect(
          x.rows(name).map((r) => r.isEmpty ? '' : r.first),
          contains('Notes: ${sampleNotes[0]}'),
          reason: name,
        );
      }
    });

    test('roll-only columns are left out of Excel', () {
      final x = build(itemsSpec(sampleItems, extraColumns: [rollOnlyColumn]));
      final header = x.rowStarting('Items Report', 'Item Name');
      expect(header, isNot(contains('Item x Qty')));
      expect(header.last, 'Created Time');
      expect(x.dataRows('Items Report').first.first, 'Coke');
    });
  });

  group('split sheets', () {
    final x = build(itemsSpec(sampleItems), splitId: 'category');

    test('All first, groups by name, No Category last', () {
      expect(x.sheetNames, ['All', 'Bakery', 'Drinks', 'No Category']);
    });

    test('a row in two categories appears on both sheets, once on All', () {
      expect(x.dataRows('All').map((r) => r.first), [
        'Coke',
        'Meat Pie',
        'Roofing Sheet',
        'Service Charge',
      ]);
      expect(x.dataRows('Drinks').map((r) => r.first), ['Coke', 'Meat Pie']);
      expect(x.dataRows('Bakery').map((r) => r.first), ['Meat Pie']);
      expect(x.dataRows('No Category').map((r) => r.first), [
        'Roofing Sheet',
        'Service Charge',
      ]);
    });

    test('each sheet has its own totals', () {
      expect(double.parse(x.rowStarting('All', 'TOTAL (4 items)')[3]), 2500);
      expect(double.parse(x.rowStarting('Drinks', 'TOTAL (2 items)')[3]), 4000);
      expect(double.parse(x.rowStarting('Bakery', 'TOTAL (1 items)')[3]), 2500);
      expect(
        double.parse(x.rowStarting('No Category', 'TOTAL (2 items)')[3]),
        -1500,
      );
    });

    test('group sheets say which group they hold', () {
      final firstColumn = x.rows('Drinks').map((r) => r.isEmpty ? '' : r.first);
      expect(firstColumn, contains('Category: Drinks'));
    });

    test('empty groups get no sheet', () {
      expect(x.sheetNames, isNot(contains('Empty Category')));
    });
  });

  test('sheet names are sanitised and de-duplicated', () {
    final rows = [
      const TItem(id: '1', name: 'A', qty: 1, price: 1, total: 1, dept: 'Snacks/Treats'),
      const TItem(id: '2', name: 'B', qty: 1, price: 1, total: 1, dept: 'drinks'),
      const TItem(id: '3', name: 'C', qty: 1, price: 1, total: 1, dept: 'Drinks'),
    ];
    final spec = ReportExportSpec(
      reportName: 'Items',
      fileSlug: 'items',
      sections: [
        ExportTableSection<TItem>(
          title: 'Items',
          rows: rows,
          columns: [
            ExportColumn<TItem>(id: 'name', label: 'Item Name', value: (r) => r.name),
          ],
          splits: [
            ExportSplit<TItem>(
              id: 'x',
              label: 'Group',
              noneLabel: 'None',
              keys: (r) => [r.dept!],
              name: (k) => k,
            ),
          ],
          roll: const RollLayout(cols58: ['name'], cols80: ['name']),
        ),
      ],
    );
    final x = build(spec, splitId: 'x');
    // Equal names (ignoring case) keep a stable key order: "Drinks" < "drinks".
    expect(x.sheetNames, ['All', 'Drinks', 'drinks (2)', 'Snacks Treats']);
  });

  test('long text is stored whole (the PDF cuts it, Excel does not)', () {
    final name = 'y' * 400;
    final x = build(
      itemsSpec([TItem(id: '1', name: name, qty: 1, price: 1, total: 1)]),
    );
    final rows = x.dataRows('Items Report');
    expect(rows.single.first, name);
    expect(rows.single.first.length, 400);
  });

  test('empty data writes the message and still opens', () {
    final x = build(itemsSpec(const []));
    final firstColumn = x.rows('Items Report').map((r) => r.isEmpty ? '' : r.first);
    expect(firstColumn, contains('No records match the selected period and filters.'));
  });

  test('summary sections write metrics with values and notes', () {
    final summary = ExportSummarySection(
      title: 'Money In',
      metrics: const [
        ExportMetric(
          label: 'Total Revenue',
          value: 2500000000,
          note: '+10% vs previous period',
        ),
        ExportMetric(label: 'Receipts', value: 42, format: ExportFormat.integer),
      ],
    );
    final x = build(itemsSpec(sampleItems, extraSections: [summary]));
    final revenue = x.rowStarting('Items Report', 'Total Revenue');
    expect(double.parse(revenue[1]), 2500000000);
    expect(revenue[2], '+10% vs previous period');
    expect(double.parse(x.rowStarting('Items Report', 'Receipts')[1]), 42);
  });
}
