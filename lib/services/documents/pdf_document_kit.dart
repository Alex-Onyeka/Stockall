import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:stockall/services/documents/document_sections.dart';

// Shared look of printed A4 documents: white page, the shop at the top,
// a large centred title, a bordered information box, section bands and
// thin-bordered tables. Sales documents use it; the report exports can
// draw their own DocSections with the same widgets.

class DocTheme {
  final PdfPageFormat pageFormat;
  final pw.EdgeInsets margin;
  final PdfColor ink;
  final PdfColor muted;
  final PdfColor border;
  final PdfColor darkBand;
  final PdfColor lightBand;
  final PdfColor fill;
  final double borderWidth;

  const DocTheme({
    this.pageFormat = PdfPageFormat.a4,
    this.margin = const pw.EdgeInsets.fromLTRB(40, 36, 40, 32),
    this.ink = const PdfColor.fromInt(0xFF111827),
    this.muted = const PdfColor.fromInt(0xFF6B7280),
    this.border = const PdfColor.fromInt(0xFF9CA3AF),
    this.darkBand = const PdfColor.fromInt(0xFF1F2937),
    this.lightBand = const PdfColor.fromInt(0xFFE6ECF3),
    this.fill = const PdfColor.fromInt(0xFFF3F4F6),
    this.borderWidth = 0.5,
  });

  static const DocTheme standard = DocTheme();

  pw.TableBorder get tableBorder =>
      pw.TableBorder.all(color: border, width: borderWidth);
}

// Plus Jakarta Sans, the app font. It has the Naira sign (and the other
// currency signs the app offers except the dirham, see
// pdfCurrencySymbol).
class DocFonts {
  final pw.Font regular;
  final pw.Font bold;

  DocFonts(this.regular, this.bold);

  factory DocFonts.fromBytes(ByteData regular, ByteData bold) =>
      DocFonts(pw.Font.ttf(regular), pw.Font.ttf(bold));

  static const String regularAsset =
      'assets/fonts/PlusJakartaSans-Regular.ttf';
  static const String boldAsset = 'assets/fonts/PlusJakartaSans-Bold.ttf';

  static Future<(ByteData, ByteData)>? _bytes;

  // Font bytes are read once; each document gets its own Font objects.
  static Future<DocFonts> load() async {
    _bytes ??= () async {
      return (
        await rootBundle.load(regularAsset),
        await rootBundle.load(boldAsset),
      );
    }();
    final (regular, bold) = await _bytes!;
    return DocFonts.fromBytes(regular, bold);
  }

  pw.ThemeData get theme =>
      pw.ThemeData.withFont(base: regular, bold: bold);
}

// A4 MultiPage document from sections. A slim header repeats the shop
// name and document number from page 2; every page has a footer with
// the page count.
pw.Document buildA4LayoutDocument(
  DocLayout layout, {
  required DocFonts fonts,
  DocTheme theme = DocTheme.standard,
  bool compress = true,
}) {
  final pdf = pw.Document(
    title: layout.title,
    theme: fonts.theme,
    compress: compress,
  );
  final shop =
      layout.sectionsOf<DocHeaderSection>().firstOrNull?.shop.name ?? '';
  pdf.addPage(
    pw.MultiPage(
      pageTheme: docPageTheme(
        pageFormat: theme.pageFormat,
        margin: theme.margin,
        theme: fonts.theme,
      ),
      maxPages: 500,
      header:
          (context) =>
              context.pageNumber == 1
                  ? pw.SizedBox()
                  : docContinuationHeader(shop, layout.footer.left, theme),
      footer: (context) => docPageFooter(context, layout.footer, theme),
      build: (context) => docSectionWidgets(layout.sections, theme),
    ),
  );
  return pdf;
}

// A white box over the whole page, margins included. Without it the
// page is transparent, and PDF viewers in dark mode show it black with
// the text unreadable.
pw.Widget docPaperBackground(pw.Context context) => pw.FullPage(
  ignoreMargins: true,
  child: pw.Container(color: PdfColors.white),
);

// Page settings with the white background, for A4 documents and the
// 58mm/80mm roll PDFs alike.
pw.PageTheme docPageTheme({
  required PdfPageFormat pageFormat,
  pw.EdgeInsets? margin,
  pw.ThemeData? theme,
}) => pw.PageTheme(
  pageFormat: pageFormat,
  margin: margin,
  theme: theme,
  buildBackground: docPaperBackground,
);

// The sections with the spacing between them.
List<pw.Widget> docSectionWidgets(
  List<DocSection> sections,
  DocTheme theme,
) {
  final widgets = <pw.Widget>[];
  DocSection? previous;
  for (final section in sections) {
    final gap = _gapBefore(section, previous);
    if (widgets.isNotEmpty && gap > 0) widgets.add(pw.SizedBox(height: gap));
    widgets.add(docSectionWidget(section, theme));
    previous = section;
  }
  return widgets;
}

double _gapBefore(DocSection section, DocSection? previous) {
  if (previous is DocBandSection) return 0;
  switch (section) {
    case DocTitleSection():
      return 18;
    case DocInfoBoxSection():
    case DocBandSection():
      return 16;
    case DocTotalsSection():
      return 8;
    case DocHeaderSection():
    case DocTableSection():
    case DocTextSection():
      return 10;
  }
}

pw.Widget docSectionWidget(DocSection section, DocTheme theme) {
  switch (section) {
    case DocHeaderSection(:final shop):
      return docHeader(shop, theme);
    case DocTitleSection():
      return docTitle(section, theme);
    case DocInfoBoxSection():
      return docInfoBox(section, theme);
    case DocBandSection(:final text, :final dark):
      return docBand(text, theme, dark: dark);
    case DocTableSection():
      return docTable(section, theme);
    case DocTotalsSection(:final rows, :final barcode):
      return docTotals(rows, theme, barcode: barcode);
    case DocTextSection(:final text):
      return docTextBox(text, theme);
  }
}

// Logo or name top-left, contact lines top-right, a rule underneath.
pw.Widget docHeader(DocShop shop, DocTheme theme) {
  final name = pw.Text(
    shop.name,
    style: pw.TextStyle(
      fontWeight: pw.FontWeight.bold,
      fontSize: shop.logo == null ? 18 : 12,
      color: theme.ink,
    ),
  );
  final identity =
      shop.logo == null
          ? name
          : pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.ConstrainedBox(
                constraints: pw.BoxConstraints(
                  maxWidth: 200,
                  maxHeight: shop.logoIsWide ? 40 : 64,
                ),
                child: pw.Image(
                  pw.MemoryImage(shop.logo!),
                  fit: pw.BoxFit.contain,
                  alignment: pw.Alignment.centerLeft,
                ),
              ),
              if (shop.showName) ...[pw.SizedBox(height: 6), name],
            ],
          );
  final contactStyle = pw.TextStyle(fontSize: 8.5, color: theme.muted);
  return pw.Column(
    children: [
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(flex: 5, child: identity),
          pw.SizedBox(width: 16),
          pw.Expanded(
            flex: 4,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                for (final line in shop.contactLines)
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 2),
                    child: pw.Text(
                      line,
                      style: contactStyle,
                      textAlign: pw.TextAlign.right,
                    ),
                  ),
                if (shop.reference != null)
                  pw.Text(
                    shop.reference!,
                    style: contactStyle,
                    textAlign: pw.TextAlign.right,
                  ),
              ],
            ),
          ),
        ],
      ),
      pw.SizedBox(height: 12),
      pw.Container(height: 0.8, color: theme.border),
    ],
  );
}

pw.Widget docTitle(DocTitleSection section, DocTheme theme) {
  final (fill, ink) = switch (section.badgeTone) {
    DocBadgeTone.good => (
      const PdfColor.fromInt(0xFFE7F5EC),
      const PdfColor.fromInt(0xFF166534),
    ),
    DocBadgeTone.warning => (
      const PdfColor.fromInt(0xFFFEF3C7),
      const PdfColor.fromInt(0xFF92400E),
    ),
    DocBadgeTone.alert => (
      const PdfColor.fromInt(0xFFFDE8E8),
      const PdfColor.fromInt(0xFF991B1B),
    ),
  };
  return pw.Column(
    children: [
      pw.Text(
        section.title,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(
          fontWeight: pw.FontWeight.bold,
          fontSize: 22,
          letterSpacing: 1.2,
          color: theme.ink,
        ),
      ),
      if (section.subtitle != null || section.badge != null)
        pw.SizedBox(height: 5),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          if (section.subtitle != null)
            pw.Text(
              section.subtitle!,
              style: pw.TextStyle(fontSize: 9.5, color: theme.muted),
            ),
          if (section.badge != null) ...[
            pw.SizedBox(width: 8),
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 2,
              ),
              decoration: pw.BoxDecoration(
                color: fill,
                border: pw.Border.all(color: ink, width: 0.5),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Text(
                section.badge!.toUpperCase(),
                style: pw.TextStyle(
                  fontSize: 7.5,
                  fontWeight: pw.FontWeight.bold,
                  color: ink,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ],
        ],
      ),
      if (section.note != null) ...[
        pw.SizedBox(height: 4),
        pw.Text(
          section.note!,
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
            color: theme.ink,
          ),
        ),
      ],
    ],
  );
}

pw.Widget docBand(String text, DocTheme theme, {bool dark = true}) {
  return pw.Container(
    width: double.infinity,
    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4.5),
    decoration: pw.BoxDecoration(
      color: dark ? theme.darkBand : theme.lightBand,
      border:
          dark ? null : pw.Border.all(color: theme.border, width: theme.borderWidth),
    ),
    alignment: pw.Alignment.center,
    child: pw.Text(
      text,
      style: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        fontSize: 10,
        color: dark ? PdfColors.white : theme.ink,
      ),
    ),
  );
}

// Heading band over a bordered grid of label/value pairs.
pw.Widget docInfoBox(DocInfoBoxSection section, DocTheme theme) {
  final perRow = section.columns < 1 ? 1 : section.columns;
  final rows = <pw.TableRow>[];
  for (var i = 0; i < section.fields.length; i += perRow) {
    final cells = <pw.Widget>[];
    for (var j = 0; j < perRow; j++) {
      final index = i + j;
      final field =
          index < section.fields.length ? section.fields[index] : null;
      cells
        ..add(
          pw.Container(
            color: theme.fill,
            padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: pw.Text(
              field?.label ?? '',
              style: pw.TextStyle(fontSize: 8.5, color: theme.muted),
            ),
          ),
        )
        ..add(
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: pw.Text(
              field?.value ?? '',
              style: pw.TextStyle(fontSize: 9, color: theme.ink),
            ),
          ),
        );
    }
    rows.add(pw.TableRow(children: cells));
  }
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.stretch,
    children: [
      docBand(section.heading, theme),
      pw.Table(
        border: theme.tableBorder,
        defaultVerticalAlignment: pw.TableCellVerticalAlignment.full,
        columnWidths: {
          for (var j = 0; j < perRow; j++) ...{
            2 * j: const pw.FlexColumnWidth(2),
            2 * j + 1: const pw.FlexColumnWidth(3),
          },
        },
        children: rows,
      ),
    ],
  );
}

// Bordered table with a shaded header row that repeats on each page.
pw.Widget docTable(DocTableSection section, DocTheme theme) {
  final columns = section.columns;
  pw.Widget cell(
    String text,
    DocColumn column, {
    bool header = false,
    List<String> notes = const [],
  }) {
    final align = switch (column.align) {
      DocAlign.left => pw.CrossAxisAlignment.start,
      DocAlign.center => pw.CrossAxisAlignment.center,
      DocAlign.right => pw.CrossAxisAlignment.end,
    };
    final textAlign = switch (column.align) {
      DocAlign.left => pw.TextAlign.left,
      DocAlign.center => pw.TextAlign.center,
      DocAlign.right => pw.TextAlign.right,
    };
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 4),
      child: pw.Column(
        crossAxisAlignment: align,
        children: [
          pw.Text(
            text,
            textAlign: textAlign,
            style: pw.TextStyle(
              fontSize: header ? 8.5 : 9,
              fontWeight: header ? pw.FontWeight.bold : null,
              color: theme.ink,
            ),
          ),
          for (final note in notes)
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 1.5),
              child: pw.Text(
                note,
                textAlign: textAlign,
                style: pw.TextStyle(fontSize: 7.5, color: theme.muted),
              ),
            ),
        ],
      ),
    );
  }

  final rows = section.rows.isEmpty && section.emptyText != null
      ? [
        DocRow([
          for (var i = 0; i < columns.length; i++)
            i == (columns.length > 1 ? 1 : 0) ? section.emptyText! : '',
        ]),
      ]
      : section.rows;

  return pw.Table(
    border: theme.tableBorder,
    columnWidths: {
      for (var i = 0; i < columns.length; i++)
        i: pw.FlexColumnWidth(columns[i].flex.toDouble()),
    },
    children: [
      pw.TableRow(
        repeat: true,
        decoration: pw.BoxDecoration(color: theme.fill),
        children: [
          for (final column in columns)
            cell(column.title, column, header: true),
        ],
      ),
      for (final row in rows)
        pw.TableRow(
          children: [
            for (var i = 0; i < columns.length; i++)
              cell(
                i < row.cells.length ? row.cells[i] : '',
                columns[i],
                notes: i == row.noteColumn ? row.notes : const [],
              ),
          ],
        ),
    ],
  );
}

// Totals in a bordered box on the right, the barcode on the left.
pw.Widget docTotals(
  List<DocTotalRow> rows,
  DocTheme theme, {
  String? barcode,
}) {
  return pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.end,
    children: [
      pw.Expanded(
        flex: 11,
        child:
            barcode == null
                ? pw.SizedBox()
                : pw.Align(
                  alignment: pw.Alignment.bottomLeft,
                  child: docBarcode(barcode, theme),
                ),
      ),
      pw.Expanded(
        flex: 9,
        child: pw.Table(
          border: theme.tableBorder,
          columnWidths: const {
            0: pw.FlexColumnWidth(5),
            1: pw.FlexColumnWidth(4),
          },
          children: [
            for (final row in rows)
              pw.TableRow(
                decoration:
                    row.emphasize ? pw.BoxDecoration(color: theme.fill) : null,
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    child: pw.Text(
                      row.label,
                      style: pw.TextStyle(
                        fontSize: row.emphasize ? 10 : 9,
                        fontWeight: row.emphasize ? pw.FontWeight.bold : null,
                        color: theme.ink,
                      ),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                    child: pw.Text(
                      row.value,
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                        fontSize: row.emphasize ? 10 : 9,
                        fontWeight: row.emphasize ? pw.FontWeight.bold : null,
                        color: theme.ink,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    ],
  );
}

pw.Widget docTextBox(String text, DocTheme theme) {
  return pw.Container(
    width: double.infinity,
    padding: const pw.EdgeInsets.all(8),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: theme.border, width: theme.borderWidth),
    ),
    child: pw.Text(text, style: pw.TextStyle(fontSize: 9, color: theme.ink)),
  );
}

// EAN-13 of the document number. Nothing when the number isn't a valid
// EAN-13. The digits use the document font (the barcode's own default
// is Courier, which has no Unicode support).
pw.Widget docBarcode(String data, DocTheme theme) {
  final barcode = pw.Barcode.ean13();
  if (!barcode.isValid(data)) return pw.SizedBox();
  return pw.Builder(
    builder:
        (context) => pw.BarcodeWidget(
          barcode: barcode,
          data: data,
          width: 130,
          height: 42,
          textStyle: pw.Theme.of(
            context,
          ).defaultTextStyle.copyWith(fontSize: 8, color: theme.ink),
        ),
  );
}

pw.Widget docContinuationHeader(
  String shopName,
  String documentLabel,
  DocTheme theme,
) {
  final style = pw.TextStyle(fontSize: 8, color: theme.muted);
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 10),
    child: pw.Column(
      children: [
        pw.Row(
          children: [
            pw.Expanded(
              child: pw.Text(
                shopName,
                style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  color: theme.ink,
                ),
              ),
            ),
            pw.Text(documentLabel, style: style),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Container(height: theme.borderWidth, color: theme.border),
      ],
    ),
  );
}

pw.Widget docPageFooter(pw.Context context, DocFooter footer, DocTheme theme) {
  final style = pw.TextStyle(fontSize: 7.5, color: theme.muted);
  return pw.Padding(
    padding: const pw.EdgeInsets.only(top: 10),
    child: pw.Column(
      children: [
        pw.Container(height: theme.borderWidth, color: theme.border),
        pw.SizedBox(height: 4),
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Text(
                footer.message == null
                    ? footer.left
                    : '${footer.left}  ·  ${footer.message}',
                style: style,
              ),
            ),
            pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: style,
            ),
          ],
        ),
      ],
    ),
  );
}
