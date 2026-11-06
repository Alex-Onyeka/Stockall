// Turns a ReportExportSpec into plain rows of typed, formatted cells.
// The PDF, Excel and roll builders render only these, so the rules
// (formatting, totals, sheet split, grouping) are written and tested once.

import 'package:stockall/pages/report/components/export/report_export_format.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';

/// Excel takes at most this many split sheets (plus "All") before the
/// caller has to ask the user.
const int reportExportMaxSplitSheets = 100;

class ResolvedColumn {
  final String id;
  final String label;
  final ExportFormat format;
  final ExportAlign align;
  final double width;
  final bool inPdf;
  final bool inExcel;

  const ResolvedColumn({
    required this.id,
    required this.label,
    required this.format,
    required this.align,
    required this.width,
    required this.inPdf,
    this.inExcel = true,
  });
}

class ResolvedCell {
  /// The typed value (num, DateTime, String or null).
  final Object? raw;

  /// What a reader sees.
  final String text;

  const ResolvedCell(this.raw, this.text);

  static const empty = ResolvedCell(null, '');
}

abstract class ResolvedSection {
  String get title;
}

class ResolvedTable extends ResolvedSection {
  @override
  final String title;
  final List<ResolvedColumn> columns;
  final List<List<ResolvedCell>> rows;

  /// One cell per column, or null when the table has no totals.
  final List<ResolvedCell>? totals;
  final String totalsLabel;
  final String emptyMessage;
  final RollLayout roll;

  ResolvedTable({
    required this.title,
    required this.columns,
    required this.rows,
    required this.totals,
    required this.totalsLabel,
    required this.emptyMessage,
    required this.roll,
  });

  bool get isEmpty => rows.isEmpty;

  int indexOf(String columnId) =>
      columns.indexWhere((c) => c.id == columnId);

  List<int> get pdfColumnIndexes => [
    for (var i = 0; i < columns.length; i++)
      if (columns[i].inPdf) i,
  ];

  List<int> get excelColumnIndexes => [
    for (var i = 0; i < columns.length; i++)
      if (columns[i].inExcel) i,
  ];

  /// Columns left out of the PDF but in Excel (roll-only ones don't
  /// count).
  bool get hasExcelOnlyColumns =>
      columns.any((c) => !c.inPdf && c.inExcel);
}

class ResolvedMetric {
  final String label;
  final Object? raw;
  final ExportFormat format;
  final String text;
  final String? note;

  const ResolvedMetric({
    required this.label,
    required this.raw,
    required this.format,
    required this.text,
    this.note,
  });
}

class ResolvedSummary extends ResolvedSection {
  @override
  final String title;
  final List<ResolvedMetric> metrics;

  ResolvedSummary({required this.title, required this.metrics});

  bool get hasNotes => metrics.any((m) => (m.note ?? '').isNotEmpty);
}

/// Header details shared by every output.
class ResolvedMeta {
  final String reportName;
  final String? periodLabel;
  final List<ExportFilter> filters;
  final String? sortedBy;
  final String? groupedBy;
  final List<String> notes;
  final int recordCount;
  final ExportContext context;

  const ResolvedMeta({
    required this.reportName,
    required this.periodLabel,
    required this.filters,
    required this.sortedBy,
    required this.groupedBy,
    this.notes = const [],
    required this.recordCount,
    required this.context,
  });

  String get filtersText => filters.isEmpty
      ? 'None'
      : filters.map((f) => '${f.label}: ${f.value}').join('; ');
}

class ResolvedExport {
  final ResolvedMeta meta;
  final List<ResolvedSection> sections;

  const ResolvedExport({required this.meta, required this.sections});

  Iterable<ResolvedTable> get tables => sections.whereType<ResolvedTable>();

  bool get hasExcelOnlyColumns => tables.any((t) => t.hasExcelOnlyColumns);
}

class ResolvedSheet {
  final String name;

  /// The group shown on this sheet ("Drinks"), null on "All".
  final String? groupName;
  final List<ResolvedSection> sections;

  const ResolvedSheet({
    required this.name,
    required this.groupName,
    required this.sections,
  });
}

class ResolvedWorkbook {
  final ResolvedMeta meta;
  final String? splitLabel;
  final List<ResolvedSheet> sheets;

  const ResolvedWorkbook({
    required this.meta,
    required this.splitLabel,
    required this.sheets,
  });
}

/// One group of a split table: its rows and their own totals.
class ResolvedGroup {
  final String key;
  final String name;
  final bool isNone;
  final ResolvedTable table;

  const ResolvedGroup({
    required this.key,
    required this.name,
    required this.isNone,
    required this.table,
  });
}

class ExportTooManySheets implements Exception {
  final int groups;
  final int limit;

  const ExportTooManySheets(this.groups, this.limit);

  @override
  String toString() =>
      'ExportTooManySheets: $groups groups, limit $limit';
}

// ---------------------------------------------------------------------
// Resolving
// ---------------------------------------------------------------------

ResolvedMeta resolveMeta(ReportExportSpec spec, ExportContext ctx) {
  return ResolvedMeta(
    reportName: spec.reportName,
    periodLabel: spec.period?.label,
    filters: spec.filters,
    sortedBy: spec.sortedBy,
    groupedBy: spec.groupedBy,
    notes: [
      for (final n in spec.notes)
        if (n.trim().isNotEmpty) n.trim(),
    ],
    recordCount: spec.recordCount,
    context: ctx,
  );
}

/// Every section with all its rows (the PDF and the unsplit workbook).
ResolvedExport resolveExport(ReportExportSpec spec, ExportContext ctx) {
  final f = ExportFormatter(currency: ctx.currencySymbol);
  return ResolvedExport(
    meta: resolveMeta(spec, ctx),
    sections: [for (final s in spec.sections) _resolveSection(s, f)],
  );
}

ResolvedSection _resolveSection(ExportSection s, ExportFormatter f) {
  if (s is ExportTableSection) {
    return resolveTable(s, f);
  }
  if (s is ExportSummarySection) {
    return resolveSummary(s, f);
  }
  throw ArgumentError('Unknown export section ${s.runtimeType}');
}

ResolvedSummary resolveSummary(ExportSummarySection s, ExportFormatter f) {
  return ResolvedSummary(
    title: s.title,
    metrics: [
      for (final m in s.metrics)
        ResolvedMetric(
          label: m.label,
          raw: m.value,
          format: m.format,
          text: f.format(m.value, m.format),
          note: m.note,
        ),
    ],
  );
}

/// [rows] narrows the table to a subset (a split sheet or roll section);
/// its totals then come from `totalsFor`. Without [rows] the table keeps
/// every row and the screen's totals.
ResolvedTable resolveTable(
  ExportTableSection<dynamic> t,
  ExportFormatter f, {
  List<Object?>? rows,
  String? title,
}) {
  final columns = [
    for (final c in t.columns)
      ResolvedColumn(
        id: c.id,
        label: c.label,
        format: c.format,
        align: c.effectiveAlign,
        width: c.width <= 0 ? 1 : c.width,
        inPdf: c.inPdf,
        inExcel: c.inExcel,
      ),
  ];

  final source = rows ?? t.erasedRows;
  final resolvedRows = <List<ResolvedCell>>[];
  for (final row in source) {
    resolvedRows.add([
      for (final c in t.columns) _cell(t, c, row, f),
    ]);
  }

  final totalsMap = rows == null ? t.fullTotals : t.totalsOf(rows);
  List<ResolvedCell>? totals;
  if (totalsMap != null) {
    totals = [
      for (final c in t.columns)
        totalsMap.containsKey(c.id)
            ? _totalCell(totalsMap[c.id], c.format, f)
            : ResolvedCell.empty,
    ];
  }

  return ResolvedTable(
    title: title ?? t.title,
    columns: columns,
    rows: resolvedRows,
    totals: totals,
    totalsLabel: t.totalsLabel,
    emptyMessage: t.emptyMessage,
    roll: t.roll,
  );
}

ResolvedCell _cell(
  ExportTableSection<dynamic> t,
  ExportColumn<dynamic> c,
  Object? row,
  ExportFormatter f,
) {
  final raw = t.valueOf(c, row);
  final display = t.displayOf(c, row);
  final text = display ?? f.format(raw, c.format);
  return ResolvedCell(raw, text);
}

// A total can be a number for the column ("₦12,000.00") or a label
// for a text column ("12 items").
ResolvedCell _totalCell(
  Object? value,
  ExportFormat format,
  ExportFormatter f,
) {
  if (value == null) return ResolvedCell.empty;
  if (value is String) return ResolvedCell(value, value);
  return ResolvedCell(value, f.format(value, format));
}

// ---------------------------------------------------------------------
// Splits (Excel sheets, roll sections)
// ---------------------------------------------------------------------

/// The first table that offers [splitId], or null.
ExportTableSection<dynamic>? splitTable(
  ReportExportSpec spec,
  String splitId,
) {
  for (final t in spec.tables) {
    if (t.hasSplit(splitId)) return t;
  }
  return null;
}

/// Rows of [t] grouped by [splitId]. Groups are ordered by name, with the
/// "No X" group last; empty groups don't appear. A row with several keys
/// goes in each of its groups.
List<ResolvedGroup> resolveGroups(
  ExportTableSection<dynamic> t,
  String splitId,
  ExportFormatter f,
) {
  final split = t.splitById(splitId);
  if (split == null) {
    throw ArgumentError('Table "${t.title}" has no split "$splitId"');
  }

  final byKey = <String, List<Object?>>{};
  final none = <Object?>[];
  for (final row in t.erasedRows) {
    final keys = t
        .splitKeysOf(split, row)
        .map((k) => k.trim())
        .where((k) => k.isNotEmpty)
        .toSet();
    if (keys.isEmpty) {
      none.add(row);
      continue;
    }
    for (final k in keys) {
      byKey.putIfAbsent(k, () => []).add(row);
    }
  }

  final named = [
    for (final e in byKey.entries)
      (key: e.key, name: _groupName(split.name(e.key), split.noneLabel), rows: e.value),
  ]..sort((a, b) {
      final c = a.name.toLowerCase().compareTo(b.name.toLowerCase());
      return c != 0 ? c : a.key.compareTo(b.key);
    });

  return [
    for (final g in named)
      ResolvedGroup(
        key: g.key,
        name: g.name,
        isNone: false,
        table: resolveTable(t, f, rows: g.rows, title: g.name),
      ),
    if (none.isNotEmpty)
      ResolvedGroup(
        key: '',
        name: split.noneLabel,
        isNone: true,
        table: resolveTable(t, f, rows: none, title: split.noneLabel),
      ),
  ];
}

String _groupName(String name, String fallback) {
  final trimmed = name.trim();
  return trimmed.isEmpty ? fallback : trimmed;
}

/// Number of sheets a split would add (not counting "All").
int splitGroupCount(ReportExportSpec spec, String splitId) {
  final t = splitTable(spec, splitId);
  if (t == null) return 0;
  final f = ExportFormatter(currency: '');
  return resolveGroups(t, splitId, f).length;
}

/// The workbook's sheets. With no [splitId] there is one sheet with
/// every section. With a split, "All" comes first, then one sheet per
/// group holding only the split table (with that group's totals).
/// Throws [ExportTooManySheets] above [maxSheets] groups.
ResolvedWorkbook resolveWorkbook(
  ReportExportSpec spec,
  ExportContext ctx, {
  String? splitId,
  int maxSheets = reportExportMaxSplitSheets,
}) {
  final full = resolveExport(spec, ctx);
  final used = <String>{};
  final allName = sanitizeSheetName(
    splitId == null ? spec.reportName : 'All',
    used,
  );
  final allSheet = ResolvedSheet(
    name: allName,
    groupName: null,
    sections: full.sections,
  );

  if (splitId == null) {
    return ResolvedWorkbook(
      meta: full.meta,
      splitLabel: null,
      sheets: [allSheet],
    );
  }

  final t = splitTable(spec, splitId);
  if (t == null) {
    throw ArgumentError('No table offers split "$splitId"');
  }
  final f = ExportFormatter(currency: ctx.currencySymbol);
  final groups = resolveGroups(t, splitId, f);
  if (groups.length > maxSheets) {
    throw ExportTooManySheets(groups.length, maxSheets);
  }

  return ResolvedWorkbook(
    meta: full.meta,
    splitLabel: t.splitById(splitId)!.label,
    sheets: [
      allSheet,
      for (final g in groups)
        ResolvedSheet(
          name: sanitizeSheetName(g.name, used),
          groupName: g.name,
          sections: [g.table],
        ),
    ],
  );
}

/// An Excel-safe sheet name, unique (ignoring case) within [used], which
/// it updates. Strips []:*?/\, trims, keeps 31 characters, and avoids
/// blanks and the reserved name "History".
String sanitizeSheetName(String raw, Set<String> used) {
  const maxLength = 31;
  var name = raw
      .replaceAll(RegExp(r'[\[\]:*?/\\]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
  // Excel rejects a leading or trailing apostrophe.
  name = name.replaceAll(RegExp(r"^'+|'+$"), '').trim();
  if (name.isEmpty) name = 'Unnamed';
  if (name.toLowerCase() == 'history') name = 'History Records';
  if (name.length > maxLength) {
    name = name.substring(0, maxLength).trimRight();
  }

  var candidate = name;
  var n = 2;
  while (used.contains(candidate.toLowerCase())) {
    final suffix = ' ($n)';
    final base = name.length + suffix.length > maxLength
        ? name.substring(0, maxLength - suffix.length).trimRight()
        : name;
    candidate = '$base$suffix';
    n++;
  }
  used.add(candidate.toLowerCase());
  return candidate;
}
