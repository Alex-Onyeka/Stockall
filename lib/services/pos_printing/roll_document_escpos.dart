import 'dart:math';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:stockall/services/documents/document_model.dart';
import 'package:stockall/services/documents/sales_document_layout.dart';
import 'package:stockall/services/pos_printing/pos_print_rules.dart';
import 'package:stockall/services/printing/escpos_builder.dart';
import 'package:stockall/services/printing/pdf_escpos_raster.dart'
    show rasterImageBands;

// The roll (58mm/80mm) version of a SalesDocument as ESC/POS. It uses the
// same document as the A4 page, so the lines, totals and payments match:
// one payment line per channel, and payment/delivery receipts show the
// amount paid and the invoice or order balance.
//
// Layout:
//   [logo] SHOP NAME, contact lines, shop ID
//   ---- TITLE, No., title line ----
//   label: value lines
//   ---- item name / "qty x unit price" ... amount, notes ----
//   totals (Total in double height)
//   ---- Payments ----  ---- Notes ----
//   barcode, footer text, feed, cut

EscPosBuilder buildRollEscPos(
  SalesDocument doc,
  DocFormat fmt, {
  required PosPaper paper,
  List<Uint8List>? logo,
  bool cut = false,
  int feedLines = 4,
}) {
  final b = EscPosBuilder(paperDots: paper.dots);
  final shop = doc.shop;

  // Header.
  if (logo != null && logo.isNotEmpty) b.raster(logo);
  if (shop.showName || logo == null || logo.isEmpty) {
    b.text(
      shop.name,
      align: EscAlign.center,
      bold: true,
      doubleHeight: true,
      doubleWidth:
          escPosSafe(shop.name).length <= b.charsPerLine(doubleWidth: true),
    );
  }
  for (final line in shop.contactLines) {
    b.text(line, align: EscAlign.center);
  }
  if (shop.reference != null) {
    b.text(shop.reference!, align: EscAlign.center, small: true);
  }

  b.divider();
  b.text(doc.title, align: EscAlign.center, bold: true);
  b.text('No. ${doc.number}', align: EscAlign.center);
  if (doc.titleLine != null) {
    b.text(doc.titleLine!, align: EscAlign.center, bold: true);
  }
  b.divider();

  // Information, without the number (it is under the title). The label
  // column is as wide as the longest label.
  final info = doc.info.skip(1).toList();
  if (info.isNotEmpty) {
    final labelWidth = min(
      b.charsPerLine() ~/ 2,
      info.map((f) => escPosSafe(f.label).length + 2).reduce(max),
    );
    for (final field in info) {
      b.columns([
        EscCol('${field.label}:', flex: labelWidth),
        EscCol(
          field.value,
          flex: b.charsPerLine() - labelWidth,
          bold: true,
        ),
      ]);
    }
  }
  b.divider();

  // Lines: the name, then "qty x unit price" and the amount.
  for (final line in doc.lines) {
    b.text(line.name, bold: true);
    final quantity = fmt.quantity(line.quantity, line.unit);
    _leftRight(
      b,
      line.unitPrice == null
          ? quantity
          : '$quantity x ${fmt.money(line.unitPrice!)}',
      fmt.money(line.amount),
    );
    final notes = [
      if (doc.type == DocType.order)
        'Delivered ${fmt.quantity(line.delivered ?? 0, line.unit)}, '
            'outstanding ${fmt.quantity(line.outstanding ?? line.quantity, line.unit)}',
      ...line.notes,
      if (line.discount > 0)
        line.discountRate != null
            ? 'Less ${fmt.rate(line.discountRate!)} discount: ${fmt.minus(line.discount)}'
            : 'Less discount: ${fmt.minus(line.discount)}',
    ];
    for (final note in notes) {
      b.text(note, small: true, indent: 2);
    }
  }
  if (doc.lines.isEmpty) b.text('No items', align: EscAlign.center);
  b.divider();

  // Totals, as on the A4 page.
  for (final row in salesDocumentTotalRows(doc, fmt)) {
    _leftRight(
      b,
      row.label,
      row.value,
      bold: row.emphasize,
      doubleHeight: row.label == 'Total' || row.label == 'Amount paid',
    );
  }

  // Payments: one line per channel.
  if (doc.payments.isNotEmpty) {
    b.divider();
    b.text('Payments', bold: true);
    for (final payment in doc.payments) {
      _leftRight(
        b,
        payment.date == null
            ? payment.method
            : '${fmt.date(payment.date!)} ${payment.method}',
        fmt.money(payment.amount),
      );
    }
  }

  if (doc.notes != null) {
    b.divider();
    b.text('Notes', bold: true);
    b.text(doc.notes!);
  }

  if (doc.barcode != null) {
    b.divider();
    b.ean13(doc.barcode!);
  }
  if (doc.footerText != null) {
    b.text(doc.footerText!.toUpperCase(), align: EscAlign.center, bold: true);
  }
  b.feed(feedLines);
  if (cut) b.cut();
  return b;
}

// [left] and [right] on one line: the right text keeps its full width
// (an amount never wraps) and the left wraps in what is left.
void _leftRight(
  EscPosBuilder b,
  String left,
  String right, {
  bool bold = false,
  bool doubleHeight = false,
}) {
  final cpl = b.charsPerLine();
  final rightWidth = min(escPosSafe(right).length, cpl ~/ 2);
  b.columns([
    EscCol(left, flex: cpl - rightWidth, bold: bold),
    EscCol(right, flex: rightWidth, align: EscAlign.right, bold: bold),
  ], doubleHeight: doubleHeight);
}

// The shop logo as raster bands for the paper width: at most 200pt wide
// and 25pt (wide logos) or 75pt tall, as on the roll PDF, centred.
// Null when the bytes aren't an image.
List<Uint8List>? rollLogoBands(Uint8List? logo, PosPaper paper) {
  if (logo == null || logo.isEmpty) return null;
  img.Image? decoded;
  try {
    decoded = img.decodeImage(logo);
  } catch (_) {
    decoded = null;
  }
  if (decoded == null || decoded.width == 0 || decoded.height == 0) {
    return null;
  }
  const pointsToDots = 203 / 72;
  final boxWidth = min(paper.dots, (200 * pointsToDots).round());
  final boxHeight =
      ((decoded.width > 2 * decoded.height ? 25 : 75) * pointsToDots).round();
  final scale = min(
    boxWidth / decoded.width,
    boxHeight / decoded.height,
  );
  final resized = img.copyResize(
    decoded,
    width: max(1, (decoded.width * scale).round()),
    height: max(1, (decoded.height * scale).round()),
    interpolation: img.Interpolation.average,
  );
  // Pad with white on the left to centre it; not every printer applies
  // ESC a alignment to raster images.
  final left = (paper.dots - resized.width) ~/ 2;
  final canvas = img.Image(
    width: left + resized.width,
    height: resized.height,
    numChannels: 4,
  );
  img.fill(canvas, color: img.ColorRgba8(255, 255, 255, 255));
  img.compositeImage(canvas, resized, dstX: left);
  return rasterImageBands(canvas);
}
