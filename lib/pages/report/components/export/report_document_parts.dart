// A4 document building blocks: page header, title, info box, section
// band, bordered table and footer. They know nothing about reports, so
// they can later be shared with the sales-document style
// (lib/services/documents/ on feat/document-downloads). Every style value
// lives in DocStyle so the two can be unified in one place.

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class DocFonts {
  final pw.Font regular;
  final pw.Font bold;

  const DocFonts({required this.regular, required this.bold});
}

/// All sizes, colours and border widths of the A4 report style.
class DocStyle {
  // Page
  final double pageMargin;

  // Colours
  /// Painted on every page so dark-mode PDF viewers don't show a black page.
  final PdfColor pageBackground;
  final PdfColor ink;
  final PdfColor muted;
  final PdfColor border;
  final PdfColor headerFill;
  final PdfColor bandFill;
  final PdfColor bandText;
  final PdfColor totalFill;
  final PdfColor infoLabelFill;

  // Lines
  final double borderWidth;
  final double totalBorderWidth;
  final double headerRuleWidth;

  // Type sizes (pt)
  final double shopNameSize;
  final double shopDetailSize;
  final double titleSize;
  final double bandSize;
  final double infoSize;
  final double bodySize;
  final double minBodySize;
  final double footerSize;

  // Cell padding
  final double cellPadH;
  final double cellPadV;

  const DocStyle({
    this.pageMargin = 28,
    this.pageBackground = PdfColors.white,
    this.ink = const PdfColor.fromInt(0xFF1A1A1A),
    this.muted = const PdfColor.fromInt(0xFF666666),
    this.border = const PdfColor.fromInt(0xFF8A8A8A),
    this.headerFill = const PdfColor.fromInt(0xFFF2F2F2),
    this.bandFill = const PdfColor.fromInt(0xFFE7E7E7),
    this.bandText = const PdfColor.fromInt(0xFF1A1A1A),
    this.totalFill = const PdfColor.fromInt(0xFFF2F2F2),
    this.infoLabelFill = const PdfColor.fromInt(0xFFF7F7F7),
    this.borderWidth = 0.5,
    this.totalBorderWidth = 1,
    this.headerRuleWidth = 0.8,
    this.shopNameSize = 15,
    this.shopDetailSize = 7.5,
    this.titleSize = 14,
    this.bandSize = 9,
    this.infoSize = 7.5,
    this.bodySize = 7.5,
    this.minBodySize = 6.5,
    this.footerSize = 6.5,
    this.cellPadH = 4,
    this.cellPadV = 3,
  });

  /// Reports: one step smaller than the sales documents (8–10pt body).
  static const DocStyle report = DocStyle();

  /// Template 1 look: black bands with white text.
  static const DocStyle reportDarkBands = DocStyle(
    bandFill: PdfColor.fromInt(0xFF1A1A1A),
    bandText: PdfColor.fromInt(0xFFFFFFFF),
  );
}

/// A full-page box in the style's background colour, margins included.
/// Without it the page is transparent, which phone PDF viewers in dark
/// mode show as black.
pw.Widget docPageBackground(DocStyle s) {
  return pw.FullPage(
    ignoreMargins: true,
    child: pw.Container(color: s.pageBackground),
  );
}

/// Page setup shared by every document: format, margins, fonts and the
/// solid background.
pw.PageTheme docPageTheme(
  DocStyle s, {
  required PdfPageFormat format,
  required pw.EdgeInsets margin,
  pw.ThemeData? theme,
}) {
  return pw.PageTheme(
    pageFormat: format,
    margin: margin,
    theme: theme,
    buildBackground: (_) => docPageBackground(s),
  );
}

pw.TextStyle _style(
  DocFonts fonts,
  double size, {
  bool bold = false,
  PdfColor? color,
}) {
  return pw.TextStyle(
    font: bold ? fonts.bold : fonts.regular,
    fontBold: fonts.bold,
    fontSize: size,
    color: color,
  );
}

pw.TextAlign docTextAlign(pw.Alignment a) {
  if (a == pw.Alignment.centerRight || a == pw.Alignment.topRight) {
    return pw.TextAlign.right;
  }
  if (a == pw.Alignment.center || a == pw.Alignment.topCenter) {
    return pw.TextAlign.center;
  }
  return pw.TextAlign.left;
}

/// Shop name on the left, contact lines on the right, a rule below.
pw.Widget docHeader(
  DocStyle s,
  DocFonts f, {
  required String shopName,
  List<String> details = const [],
}) {
  return pw.Container(
    padding: const pw.EdgeInsets.only(bottom: 6),
    decoration: pw.BoxDecoration(
      border: pw.Border(
        bottom: pw.BorderSide(color: s.ink, width: s.headerRuleWidth),
      ),
    ),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(
          child: pw.Text(
            shopName,
            style: _style(f, s.shopNameSize, bold: true, color: s.ink),
          ),
        ),
        if (details.isNotEmpty)
          pw.Padding(
            padding: const pw.EdgeInsets.only(left: 12),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                for (final d in details)
                  pw.Text(
                    d,
                    textAlign: pw.TextAlign.right,
                    style: _style(f, s.shopDetailSize, color: s.muted),
                  ),
              ],
            ),
          ),
      ],
    ),
  );
}

pw.Widget docTitle(DocStyle s, DocFonts f, String title) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 10),
    child: pw.Center(
      child: pw.Text(
        title.toUpperCase(),
        textAlign: pw.TextAlign.center,
        style: _style(f, s.titleSize, bold: true, color: s.ink),
      ),
    ),
  );
}

/// Full-width filled band with centred bold text.
pw.Widget docBand(DocStyle s, DocFonts f, String text) {
  return pw.Container(
    width: double.infinity,
    padding: const pw.EdgeInsets.symmetric(vertical: 3, horizontal: 6),
    decoration: pw.BoxDecoration(
      color: s.bandFill,
      border: pw.Border.all(color: s.border, width: s.borderWidth),
    ),
    child: pw.Text(
      text,
      textAlign: pw.TextAlign.center,
      style: _style(f, s.bandSize, bold: true, color: s.bandText),
    ),
  );
}

/// A banded, bordered grid of label/value pairs, two pairs per line.
pw.Widget docInfoBox(
  DocStyle s,
  DocFonts f, {
  required String title,
  required List<(String, String)> entries,
}) {
  pw.Widget cell(String text, {bool label = false}) {
    return pw.Container(
      color: label ? s.infoLabelFill : null,
      padding: pw.EdgeInsets.symmetric(
        horizontal: s.cellPadH,
        vertical: s.cellPadV,
      ),
      child: pw.Text(
        text,
        style: _style(f, s.infoSize, bold: label, color: s.ink),
      ),
    );
  }

  final rows = <pw.TableRow>[];
  for (var i = 0; i < entries.length; i += 2) {
    final a = entries[i];
    final b = i + 1 < entries.length ? entries[i + 1] : ('', '');
    rows.add(
      pw.TableRow(
        children: [
          cell(a.$1, label: true),
          cell(a.$2),
          cell(b.$1, label: true),
          cell(b.$2),
        ],
      ),
    );
  }

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
    children: [
      docBand(s, f, title),
      pw.Table(
        border: pw.TableBorder.all(color: s.border, width: s.borderWidth),
        columnWidths: const {
          0: pw.FlexColumnWidth(1.1),
          1: pw.FlexColumnWidth(2),
          2: pw.FlexColumnWidth(1.1),
          3: pw.FlexColumnWidth(2),
        },
        children: rows,
      ),
    ],
  );
}

class DocTableColumn {
  final String label;
  final double flex;
  final pw.Alignment alignment;

  const DocTableColumn({
    required this.label,
    this.flex = 1,
    this.alignment = pw.Alignment.centerLeft,
  });
}

/// Bordered table. The header row repeats on every page; the totals row
/// is bold, filled and has a heavier top rule.
pw.Table docTable(
  DocStyle s,
  DocFonts f, {
  required List<DocTableColumn> columns,
  required List<List<String>> rows,
  List<String>? totals,
  double? fontSize,
}) {
  final size = fontSize ?? s.bodySize;
  final padding = pw.EdgeInsets.symmetric(
    horizontal: s.cellPadH,
    vertical: s.cellPadV,
  );

  pw.Widget cell(String text, int col, {bool bold = false}) {
    final alignment = columns[col].alignment;
    return pw.Container(
      alignment: alignment,
      padding: padding,
      child: pw.Text(
        text,
        textAlign: docTextAlign(alignment),
        style: _style(f, size, bold: bold, color: s.ink),
      ),
    );
  }

  return pw.Table(
    border: pw.TableBorder.all(color: s.border, width: s.borderWidth),
    columnWidths: {
      for (var i = 0; i < columns.length; i++)
        i: pw.FlexColumnWidth(columns[i].flex),
    },
    defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
    children: [
      pw.TableRow(
        repeat: true,
        decoration: pw.BoxDecoration(color: s.headerFill),
        children: [
          for (var i = 0; i < columns.length; i++)
            cell(columns[i].label, i, bold: true),
        ],
      ),
      for (final row in rows)
        pw.TableRow(
          children: [
            for (var i = 0; i < columns.length; i++)
              cell(i < row.length ? row[i] : '', i),
          ],
        ),
      if (totals != null)
        pw.TableRow(
          decoration: pw.BoxDecoration(
            color: s.totalFill,
            border: pw.Border(
              top: pw.BorderSide(color: s.ink, width: s.totalBorderWidth),
            ),
          ),
          children: [
            for (var i = 0; i < columns.length; i++)
              cell(i < totals.length ? totals[i] : '', i, bold: true),
          ],
        ),
    ],
  );
}

/// A bordered box with a centred message (an empty table).
pw.Widget docMessageBox(DocStyle s, DocFonts f, String message) {
  return pw.Container(
    width: double.infinity,
    padding: const pw.EdgeInsets.symmetric(vertical: 10, horizontal: 6),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: s.border, width: s.borderWidth),
    ),
    child: pw.Text(
      message,
      textAlign: pw.TextAlign.center,
      style: _style(f, s.bodySize, color: s.muted),
    ),
  );
}

/// Footer text: the generated date/time on the left and "Page x of y" on
/// the right. Nothing else (the Stockall watermark was removed on purpose).
({String left, String right}) docFooterLabels({
  required String generatedAt,
  required int page,
  required int pages,
}) {
  return (left: 'Generated: $generatedAt', right: 'Page $page of $pages');
}

pw.Widget docFooter(
  DocStyle s,
  DocFonts f,
  pw.Context context, {
  required String generatedAt,
}) {
  final labels = docFooterLabels(
    generatedAt: generatedAt,
    page: context.pageNumber,
    pages: context.pagesCount,
  );
  final style = _style(f, s.footerSize, color: s.muted);
  return pw.Container(
    margin: const pw.EdgeInsets.only(top: 8),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(labels.left, style: style),
        pw.Text(labels.right, style: style),
      ],
    ),
  );
}
