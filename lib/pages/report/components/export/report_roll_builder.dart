// Receipt-roll version of a report (58mm and 80mm). The content is built
// once as RollLines, then rendered either as ESC/POS bytes (thermal
// printers) or as a roll-sized PDF (system print dialog), so both
// outputs show the same thing.
//
// Rules:
// - 58mm: at most 2 columns (flex 3/2); 80mm: at most 3 (flex 5/2/3).
// - An optional sub-line prints small under each row.
// - Grouped prints add a heading, the group's rows and a subtotal line
//   per group.
// - Every total prints at the end, one per line, then the record count.

import 'dart:math' as math;
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:stockall/pages/report/components/export/report_document_parts.dart';
import 'package:stockall/pages/report/components/export/report_export_format.dart';
import 'package:stockall/pages/report/components/export/report_export_resolve.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/services/printing/escpos_builder.dart';

enum RollPaper { mm58, mm80 }

extension RollPaperInfo on RollPaper {
  /// Printable dots at 203 dpi, as dots58mm / dots80mm in
  /// services/printing/pdf_escpos_raster.dart.
  int get dots => this == RollPaper.mm58 ? 384 : 576;

  /// Font A characters per line.
  int get chars => dots ~/ fontADots;

  int get maxColumns => this == RollPaper.mm58 ? 2 : 3;

  List<int> flexes(int count) {
    if (count <= 1) return const [1];
    if (this == RollPaper.mm58 || count == 2) return const [3, 2];
    return const [5, 2, 3];
  }

  /// Blank lines after the content so the cut clears the last line.
  /// 80mm printers sit further from the cutter.
  int get endFeed => this == RollPaper.mm58 ? 3 : 6;

  PdfPageFormat get pdfFormat =>
      this == RollPaper.mm58 ? PdfPageFormat.roll57 : PdfPageFormat.roll80;
}

// ---------------------------------------------------------------------
// Line model
// ---------------------------------------------------------------------

abstract class RollLine {
  const RollLine();
}

class RollText extends RollLine {
  final String text;
  final ExportAlign align;
  final bool bold;

  /// Double width on ESC/POS, larger type in the PDF.
  final bool large;

  const RollText(
    this.text, {
    this.align = ExportAlign.left,
    this.bold = false,
    this.large = false,
  });
}

/// Small type (Font B), indented by [indent] characters.
class RollSmall extends RollLine {
  final String text;
  final int indent;

  const RollSmall(this.text, {this.indent = 0});
}

class RollDivider extends RollLine {
  /// Heavy dividers ("=") open the totals.
  final bool heavy;

  const RollDivider({this.heavy = false});
}

class RollCell {
  final String text;
  final int flex;
  final ExportAlign align;

  const RollCell(this.text, {this.flex = 1, this.align = ExportAlign.left});
}

class RollColumns extends RollLine {
  final List<RollCell> cells;
  final bool bold;

  const RollColumns(this.cells, {this.bold = false});
}

/// A label with its value on the right, such as a total. The value gets
/// all the room it needs; when both don't fit on one line the value goes
/// on its own line, right-aligned, so amounts never split.
class RollPair extends RollLine {
  final String label;
  final String value;
  final bool bold;

  const RollPair(this.label, this.value, {this.bold = false});
}

class RollGap extends RollLine {
  const RollGap();
}

// ---------------------------------------------------------------------
// Building the lines
// ---------------------------------------------------------------------

/// The roll content for [spec]. [groupings] lists what to print, in
/// order: null prints the tables as they are, a split id prints the
/// split table grouped by it. `[null, 'department', 'category']` gives
/// the Items "full breakdown". Splits a table doesn't offer are skipped.
List<RollLine> buildRollLines(
  ReportExportSpec spec,
  ExportContext ctx, {
  required RollPaper paper,
  List<String?> groupings = const [null],
}) {
  final f = ExportFormatter(currency: ctx.currencySymbol);
  final meta = resolveMeta(spec, ctx);
  final lines = <RollLine>[..._header(meta, paper, f), const RollDivider()];

  for (final section in spec.sections) {
    if (section is ExportSummarySection) {
      lines.addAll(_summary(resolveSummary(section, f), paper));
      continue;
    }
    if (section is! ExportTableSection) continue;

    final usable = [
      for (final g in groupings)
        if (g == null || section.hasSplit(g)) g,
    ];
    if (usable.isEmpty) usable.add(null);

    for (final g in usable) {
      if (g == null) {
        lines.addAll(_table(resolveTable(section, f), paper));
      } else {
        final split = section.splitById(g)!;
        final groups = resolveGroups(section, g, f);
        lines.addAll(
          _grouped(section, split.label, groups, paper, f),
        );
      }
    }
  }

  lines.add(RollText(
    'Records: ${f.integer(spec.recordCount)}',
    align: ExportAlign.center,
    bold: true,
  ));
  return lines;
}

List<RollLine> _header(ResolvedMeta m, RollPaper paper, ExportFormatter f) {
  final shop = m.context.shopName;
  return [
    RollText(
      shop,
      align: ExportAlign.center,
      bold: true,
      large: shop.length <= paper.chars ~/ 2,
    ),
    RollText(
      m.reportName.toUpperCase(),
      align: ExportAlign.center,
      bold: true,
    ),
    if (m.periodLabel != null)
      RollText('Period: ${m.periodLabel}', align: ExportAlign.center),
    RollText(
      'Printed: ${f.dateTime(m.context.generatedAt)}',
      align: ExportAlign.center,
    ),
    RollText('By: ${m.context.generatedBy}', align: ExportAlign.center),
    for (final filter in m.filters)
      RollText('${filter.label}: ${filter.value}'),
    if (m.sortedBy != null) RollText('Sorted by: ${m.sortedBy}'),
    if (m.groupedBy != null) RollText('Grouped by: ${m.groupedBy}'),
    // The screen's notes, small; long ones wrap.
    for (final n in m.notes) RollSmall('* $n'),
  ];
}

/// Metric and value per line; on 80mm the comparison prints small
/// underneath.
List<RollLine> _summary(ResolvedSummary s, RollPaper paper) {
  return [
    RollText(s.title.toUpperCase(), align: ExportAlign.center, bold: true),
    const RollDivider(),
    for (final m in s.metrics) ...[
      RollPair(m.label, m.text),
      if (paper == RollPaper.mm80 && (m.note ?? '').isNotEmpty)
        RollSmall(m.note!, indent: 2),
    ],
    const RollGap(),
  ];
}

/// Indexes of the compact columns for [paper], capped at its maximum.
List<int> _rollColumns(ResolvedTable t, RollPaper paper) {
  final ids = paper == RollPaper.mm58 ? t.roll.cols58 : t.roll.cols80;
  final out = <int>[];
  for (final id in ids) {
    final i = t.indexOf(id);
    if (i >= 0 && !out.contains(i)) out.add(i);
    if (out.length == paper.maxColumns) break;
  }
  if (out.isEmpty && t.columns.isNotEmpty) out.add(0);
  return out;
}

/// The spec's own column widths when they fit [count] columns, else the
/// paper defaults.
List<int> _flexes(ResolvedTable t, RollPaper paper, int count) {
  final own = paper == RollPaper.mm58 ? t.roll.flex58 : t.roll.flex80;
  if (own != null && own.length == count && own.every((f) => f > 0)) {
    return own;
  }
  return paper.flexes(count);
}

List<int> _subColumns(ResolvedTable t, RollPaper paper) {
  final ids = paper == RollPaper.mm58 ? t.roll.sub58 : t.roll.sub80;
  return [
    for (final id in ids)
      if (t.indexOf(id) >= 0) t.indexOf(id),
  ];
}

List<RollLine> _rows(ResolvedTable t, RollPaper paper) {
  final cols = _rollColumns(t, paper);
  final subs = _subColumns(t, paper);
  final flex = _flexes(t, paper, cols.length);
  final out = <RollLine>[];
  for (final row in t.rows) {
    out.add(RollColumns([
      for (var k = 0; k < cols.length; k++)
        RollCell(
          row[cols[k]].text,
          flex: flex[k],
          align: t.columns[cols[k]].align,
        ),
    ]));
    final sub = [
      for (final i in subs)
        if (row[i].text.isNotEmpty) row[i].text,
    ].join(' | ');
    if (sub.isNotEmpty) out.add(RollSmall(sub, indent: 2));
  }
  return out;
}

RollColumns _columnHeader(ResolvedTable t, RollPaper paper) {
  final cols = _rollColumns(t, paper);
  final flex = _flexes(t, paper, cols.length);
  return RollColumns([
    for (var k = 0; k < cols.length; k++)
      RollCell(
        t.columns[cols[k]].label,
        flex: flex[k],
        align: t.columns[cols[k]].align,
      ),
  ], bold: true);
}

/// "Label: value" lines for every total of [t].
List<RollLine> _totalLines(
  ResolvedTable t,
  RollPaper paper, {
  String? heading,
}) {
  final totals = t.totals;
  if (totals == null) return const [];
  final out = <RollLine>[];
  if (heading != null) {
    out.add(RollText(heading, bold: true));
  }
  for (var i = 0; i < t.columns.length; i++) {
    final cell = totals[i];
    if (cell.text.isEmpty) continue;
    final isText = cell.raw is String || cell.raw == null;
    if (isText && !t.columns[i].format.isNumeric) {
      // A text total such as "12 items". A text total under a number
      // column ("12 Bottles" for Quantity) keeps its label below.
      out.add(RollText(cell.text, bold: true));
    } else {
      out.add(RollPair(t.columns[i].label, cell.text, bold: true));
    }
  }
  return out;
}

List<RollLine> _table(ResolvedTable t, RollPaper paper) {
  final out = <RollLine>[
    RollText(t.title.toUpperCase(), align: ExportAlign.center, bold: true),
    const RollDivider(),
  ];
  if (t.isEmpty) {
    out
      ..add(RollText(t.emptyMessage, align: ExportAlign.center))
      ..add(const RollGap());
    return out;
  }
  out
    ..add(_columnHeader(t, paper))
    ..add(const RollDivider())
    ..addAll(_rows(t, paper));
  final totals = _totalLines(t, paper, heading: t.totalsLabel);
  if (totals.isNotEmpty) {
    out
      ..add(const RollDivider(heavy: true))
      ..addAll(totals);
  }
  out.add(const RollGap());
  return out;
}

List<RollLine> _grouped(
  ExportTableSection<dynamic> section,
  String splitLabel,
  List<ResolvedGroup> groups,
  RollPaper paper,
  ExportFormatter f,
) {
  final full = resolveTable(section, f);
  final out = <RollLine>[
    RollText(
      '${full.title} by $splitLabel'.toUpperCase(),
      align: ExportAlign.center,
      bold: true,
    ),
    const RollDivider(),
  ];
  if (groups.isEmpty) {
    out
      ..add(RollText(full.emptyMessage, align: ExportAlign.center))
      ..add(const RollGap());
    return out;
  }
  for (final g in groups) {
    out
      ..add(RollText(
        g.isNone
            ? g.name.toUpperCase()
            : '${splitLabel.toUpperCase()}: ${g.name.toUpperCase()}',
        bold: true,
      ))
      ..add(const RollDivider())
      ..addAll(_rows(g.table, paper))
      ..addAll(_totalLines(
        g.table,
        paper,
        heading: 'Subtotal (${f.integer(g.table.rows.length)})',
      ))
      ..add(const RollGap());
  }
  final totals = _totalLines(full, paper, heading: full.totalsLabel);
  if (totals.isNotEmpty) {
    out
      ..add(const RollDivider(heavy: true))
      ..addAll(totals)
      ..add(const RollGap());
  }
  return out;
}

// ---------------------------------------------------------------------
// ESC/POS
// ---------------------------------------------------------------------

EscAlign _escAlign(ExportAlign a) {
  switch (a) {
    case ExportAlign.left:
      return EscAlign.left;
    case ExportAlign.center:
      return EscAlign.center;
    case ExportAlign.right:
      return EscAlign.right;
  }
}

/// [lines] written to an EscPosBuilder. Its `preview` is the plain text,
/// which the tests read.
EscPosBuilder renderRollEscPos(List<RollLine> lines, RollPaper paper) {
  final b = EscPosBuilder(paperDots: paper.dots);
  for (final line in lines) {
    if (line is RollText) {
      b.text(
        line.text,
        align: _escAlign(line.align),
        bold: line.bold,
        doubleWidth: line.large,
      );
    } else if (line is RollSmall) {
      b.text(line.text, small: true, indent: line.indent);
    } else if (line is RollDivider) {
      if (line.heavy) {
        b.text('=' * b.charsPerLine());
      } else {
        b.divider();
      }
    } else if (line is RollColumns) {
      b.columns([
        for (final c in line.cells)
          EscCol(
            c.text,
            flex: c.flex,
            align: _escAlign(c.align),
            bold: line.bold,
          ),
      ]);
    } else if (line is RollPair) {
      _escPair(b, line);
    } else if (line is RollGap) {
      b.feed(1);
    }
  }
  b.feed(paper.endFeed);
  return b;
}

void _escPair(EscPosBuilder b, RollPair p) {
  final cpl = b.charsPerLine();
  final label = escPosSafe(p.label);
  final value = escPosSafe(p.value);
  if (label.length + 1 + value.length <= cpl) {
    // Flexes that sum to the line width give exact character widths;
    // the value column gets exactly its length.
    b.columns([
      EscCol(label, flex: cpl - value.length, bold: p.bold),
      EscCol(value, flex: value.length, align: EscAlign.right, bold: p.bold),
    ]);
    return;
  }
  b.text(p.label, bold: p.bold);
  b.text(p.value, align: EscAlign.right, bold: p.bold);
}

/// Byte chunks for the printer, ending with a partial cut (GS V 1).
List<Uint8List> buildRollEscPos(List<RollLine> lines, RollPaper paper) {
  final chunks = renderRollEscPos(lines, paper).build();
  return [...chunks, Uint8List.fromList(const [0x1D, 0x56, 0x01])];
}

// ---------------------------------------------------------------------
// Roll PDF (system print dialog: web, macOS, Linux)
// ---------------------------------------------------------------------

pw.TextAlign _pdfAlign(ExportAlign a) {
  switch (a) {
    case ExportAlign.left:
      return pw.TextAlign.left;
    case ExportAlign.center:
      return pw.TextAlign.center;
    case ExportAlign.right:
      return pw.TextAlign.right;
  }
}

/// [compress] is for tests that read the page content.
pw.Document buildRollPdfDocument(
  List<RollLine> lines,
  RollPaper paper, {
  required DocFonts fonts,
  DocStyle style = DocStyle.report,
  bool compress = true,
}) {
  final text = paper == RollPaper.mm58 ? 7.5 : 8.5;
  final large = paper == RollPaper.mm58 ? 11.0 : 13.0;
  final small = paper == RollPaper.mm58 ? 6.5 : 7.0;

  pw.TextStyle textStyle(double size, bool bold) => pw.TextStyle(
    font: bold ? fonts.bold : fonts.regular,
    fontSize: size,
  );

  final widgets = <pw.Widget>[];
  for (final line in lines) {
    if (line is RollText) {
      widgets.add(pw.Text(
        line.text,
        textAlign: _pdfAlign(line.align),
        style: textStyle(line.large ? large : text, line.bold || line.large),
      ));
    } else if (line is RollSmall) {
      widgets.add(pw.Padding(
        padding: pw.EdgeInsets.only(left: line.indent * 3.0),
        child: pw.Text(line.text, style: textStyle(small, false)),
      ));
    } else if (line is RollDivider) {
      widgets.add(pw.Divider(
        thickness: line.heavy ? 1.2 : 0.5,
        height: 6,
      ));
    } else if (line is RollColumns) {
      widgets.add(pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 1),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < line.cells.length; i++)
              pw.Expanded(
                flex: line.cells[i].flex,
                child: pw.Padding(
                  padding: pw.EdgeInsets.only(
                    right: i == line.cells.length - 1 ? 0 : 3,
                  ),
                  child: pw.Text(
                    line.cells[i].text,
                    textAlign: _pdfAlign(line.cells[i].align),
                    style: textStyle(text, line.bold),
                  ),
                ),
              ),
          ],
        ),
      ));
    } else if (line is RollPair) {
      widgets.add(pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 1),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Text(line.label, style: textStyle(text, line.bold)),
            ),
            pw.SizedBox(width: 4),
            pw.Text(
              line.value,
              textAlign: pw.TextAlign.right,
              style: textStyle(text, line.bold),
            ),
          ],
        ),
      ));
    } else if (line is RollGap) {
      widgets.add(pw.SizedBox(height: text));
    }
  }
  widgets.add(pw.SizedBox(height: math.max(12, paper.endFeed * 4.0)));

  final doc = pw.Document(compress: compress);
  doc.addPage(
    pw.Page(
      pageTheme: docPageTheme(
        style,
        format: paper.pdfFormat,
        margin: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      ),
      build: (_) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: widgets,
      ),
    ),
  );
  return doc;
}

Future<Uint8List> buildRollPdf(
  List<RollLine> lines,
  RollPaper paper, {
  required DocFonts fonts,
}) {
  return buildRollPdfDocument(lines, paper, fonts: fonts).save();
}
