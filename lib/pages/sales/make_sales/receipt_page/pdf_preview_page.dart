import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfPreviewPag extends StatelessWidget {
  const PdfPreviewPag({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("PDF Preview")),
      body: Container(
        width: 300,
        child: PdfPreview(
          actions: [],
          build:
              (format) async =>
                  (await _generatePdf()).save(),
          allowPrinting: true,
          allowSharing: true,
          initialPageFormat: PdfPageFormat.roll80,
          pdfFileName: "stockall_receipt.pdf",
        ),
      ),
    );
  }
}

Future<pw.Document> _generatePdf() async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      build:
          (pw.Context context) => pw.Center(
            child: pw.Text(
              "Hello from Stockall PDF!",
              style: pw.TextStyle(fontSize: 30),
            ),
          ),
    ),
  );

  return pdf;
}
