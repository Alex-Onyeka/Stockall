// Shared fixtures for the report export tests: a small item-like row
// type, a spec over it, and the bundled fonts.

import 'dart:io';
import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:stockall/pages/report/components/export/report_document_parts.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/components/export/report_export_splits.dart';

class TItem {
  final String id;
  final String name;
  final double? qty;
  final String unit;

  /// "3 Sheets (4 x 2)" style text for 2D items.
  final String? sizeLabel;
  final double price;
  final double? total;
  final double? margin;
  final List<String> categories;
  final String? dept;
  final DateTime? created;

  const TItem({
    required this.id,
    required this.name,
    required this.qty,
    this.unit = 'Pcs',
    this.sizeLabel,
    required this.price,
    required this.total,
    this.margin,
    this.categories = const [],
    this.dept,
    this.created,
  });
}

const categoryNames = {
  'c-drinks': 'Drinks',
  'c-bakery': 'Bakery',
  'c-empty': 'Empty Category',
};

const departmentNames = {'d-front': 'Front Shop', 'd-back': 'Back Store'};

final testContext = ExportContext(
  shopName: 'Mama Put Stores',
  currencySymbol: '₦',
  generatedBy: 'Ada Obi',
  generatedAt: DateTime(2026, 11, 4, 14, 5),
  shopDetails: const ['12 Allen Ave, Ikeja, Lagos', '0801 234 5678'],
);

final sampleItems = [
  TItem(
    id: '1',
    name: 'Coke',
    qty: 12,
    unit: 'Bottles',
    price: 125,
    total: 1500,
    margin: 20,
    categories: const ['c-drinks'],
    dept: 'd-front',
    created: DateTime(2026, 10, 1, 9, 30),
  ),
  TItem(
    id: '2',
    name: 'Meat Pie',
    qty: 2.5,
    unit: 'Trays',
    price: 1000,
    total: 2500,
    margin: 12.5,
    categories: const ['c-bakery', 'c-drinks'],
    dept: 'd-back',
    created: DateTime(2026, 10, 2, 15, 0),
  ),
  TItem(
    id: '3',
    name: 'Roofing Sheet',
    qty: 3,
    unit: 'Sheets',
    sizeLabel: '3 Sheets (4 x 2)',
    price: -500,
    total: -1500,
    margin: -3.456,
    categories: const ['c-deleted'],
    created: DateTime(2026, 10, 3, 8, 0),
  ),
  const TItem(
    id: '4',
    name: 'Service Charge',
    qty: null,
    price: 0,
    total: null,
  ),
];

Map<String, Object?> itemTotals(List<TItem> rows) => {
  'name': '${rows.length} items',
  'total': rows.fold<double>(0, (s, r) => s + (r.total ?? 0)),
};

ExportTableSection<TItem> itemsSection(
  List<TItem> rows, {
  Map<String, Object?>? totals,
  List<ExportColumn<TItem>>? extraColumns,
}) {
  return ExportTableSection<TItem>(
    title: 'Items',
    rows: rows,
    columns: [
      ExportColumn<TItem>(
        id: 'name',
        label: 'Item Name',
        value: (r) => r.name,
        width: 3,
      ),
      ExportColumn<TItem>(
        id: 'qty',
        label: 'Quantity',
        format: ExportFormat.quantity,
        value: (r) => r.qty,
        display: (r) => r.qty == null
            ? 'Not managed'
            : r.sizeLabel ?? '${_qty(r.qty!)} ${r.unit}',
      ),
      ExportColumn<TItem>(
        id: 'price',
        label: 'Selling Price',
        format: ExportFormat.money,
        value: (r) => r.price,
      ),
      ExportColumn<TItem>(
        id: 'total',
        label: 'Total Selling Value',
        format: ExportFormat.money,
        value: (r) => r.total,
      ),
      ExportColumn<TItem>(
        id: 'margin',
        label: 'Profit Margin',
        format: ExportFormat.percent,
        value: (r) => r.margin,
      ),
      ExportColumn<TItem>(
        id: 'created',
        label: 'Created Date',
        format: ExportFormat.date,
        value: (r) => r.created,
      ),
      ExportColumn<TItem>(
        id: 'createdTime',
        label: 'Created Time',
        format: ExportFormat.time,
        value: (r) => r.created,
        inPdf: false,
      ),
      ...?extraColumns,
    ],
    totals: totals,
    totalsFor: itemTotals,
    splits: [
      categorySplit<TItem>(
        categoryIds: (r) => r.categories,
        names: categoryNames,
      ),
      departmentSplit<TItem>(
        departmentId: (r) => r.dept,
        names: departmentNames,
      ),
    ],
    roll: const RollLayout(
      cols58: ['name', 'qty'],
      cols80: ['name', 'qty', 'total'],
      sub80: ['created'],
    ),
  );
}

String _qty(double v) =>
    v == v.roundToDouble() ? v.toInt().toString() : v.toString();

ReportExportSpec itemsSpec(
  List<TItem> rows, {
  List<ExportSection> extraSections = const [],
  List<ExportColumn<TItem>>? extraColumns,
  List<String> notes = const [],
}) {
  return ReportExportSpec(
    reportName: 'Items Report',
    fileSlug: 'items_report',
    period: const ExportPeriod(label: 'Oct 1, 2026 - Oct 31, 2026'),
    filters: const [
      ExportFilter('Stock level', 'In Stock'),
      ExportFilter('Search', 'co'),
    ],
    sortedBy: 'Item Name (A-Z)',
    notes: notes,
    sections: [
      ...extraSections,
      itemsSection(rows, extraColumns: extraColumns),
    ],
  );
}

/// A roll-only column (not in the PDF, not in Excel).
final rollOnlyColumn = ExportColumn<TItem>(
  id: 'nameQty',
  label: 'Item x Qty',
  value: (r) => '${r.name} ×${r.qty ?? 0}',
  inPdf: false,
  inExcel: false,
);

const sampleNotes = [
  'All time covers the receipts loaded on this device.',
  '2 receipts are left out of the profit range: no item data or a missing cost price.',
];

/// [count] text columns, for the PDF width rules.
List<ExportColumn<TItem>> wideColumns(int count) => [
  for (var i = 0; i < count; i++)
    ExportColumn<TItem>(
      id: 'extra$i',
      label: 'Extra $i',
      value: (r) => '${r.name} $i',
    ),
];

/// White full-page fills in an uncompressed PDF: the pdf package writes
/// `0 0 width height re 1 1 1 rg f` for each page background.
List<Match> whitePageFills(String pdfText, PdfPageFormat format) {
  String size(double v) => '${v.floor()}(?:\\.\\d+)?';
  return RegExp(
    '0 0 ${size(format.width)} ${size(format.height)} re 1 1 1 rg f',
  ).allMatches(pdfText).toList();
}

ByteData _fontBytes(String file) {
  final bytes = File('assets/fonts/$file').readAsBytesSync();
  return ByteData.view(Uint8List.fromList(bytes).buffer);
}

ByteData regularFontBytes() => _fontBytes('PlusJakartaSans-Regular.ttf');

ByteData boldFontBytes() => _fontBytes('PlusJakartaSans-Bold.ttf');

DocFonts loadTestFonts() => DocFonts(
  regular: pw.Font.ttf(regularFontBytes()),
  bold: pw.Font.ttf(boldFontBytes()),
);
