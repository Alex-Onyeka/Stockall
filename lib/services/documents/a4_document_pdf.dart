import 'dart:typed_data';

import 'package:stockall/services/documents/document_model.dart';
import 'package:stockall/services/documents/pdf_document_kit.dart';
import 'package:stockall/services/documents/sales_document_layout.dart';

// The A4 PDF of a receipt, invoice, order or purchase. Build the
// SalesDocument with the functions in document_mappers.dart.
Future<Uint8List> buildA4DocumentPdf(
  SalesDocument doc,
  DocFormat fmt, {
  DocFonts? fonts,
  DocTheme theme = DocTheme.standard,
}) async {
  final document = buildA4LayoutDocument(
    salesDocumentLayout(doc, fmt),
    fonts: fonts ?? await DocFonts.load(),
    theme: theme,
  );
  return document.save();
}
