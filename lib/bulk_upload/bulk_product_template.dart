import 'dart:convert';
import 'dart:typed_data';

import 'package:stockall/bulk_upload/bulk_product_validator.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';

class BulkProductTemplate {
  static const _instructions = <List<String>>[
    ['Column', 'Required', 'Description', 'Example'],
    ['name', 'Yes', 'The product name.', 'Coca Cola 50cl'],
    [
      'quantity',
      'No',
      'Quantity in stock. Blank means 0.',
      '24',
    ],
    [
      'cost_price',
      'No',
      'What the product costs you. Blank means 0.',
      '150',
    ],
    [
      'selling_price',
      'No',
      'Price you sell at. Blank or 0 means not set.',
      '200',
    ],
    [
      'barcode',
      'No',
      'Product barcode. Keep it as text.',
      '6001234567890',
    ],
    [
      'expiry_date',
      'No',
      'Use yyyy-MM-dd or dd/MM/yyyy.',
      '2026-12-31',
    ],
    [
      'low_qtty',
      'No',
      'Low stock alert level. Blank means 10.',
      '10',
    ],
    [
      'width',
      'No',
      'Item width in cm. Optional; leave blank for 1D items.',
      '120',
    ],
    [
      'height',
      'No',
      'Item height in cm. Optional; leave blank for 1D items.',
      '240',
    ],
  ];

  /// Column guide rows (first row is the table header). The Full
  /// guide is the simple one plus the Full-only columns.
  static List<List<String>> instructions({
    bool full = false,
    List<String> sizeTypes = const [],
  }) {
    if (!full) return _instructions;
    return [
      ..._instructions,
      [
        'allow_custom_price',
        'No',
        'Let the cashier set a custom price during sales. 1 = Yes, 0 = No. Blank means 0.',
        '1',
      ],
      [
        'manage_quantity',
        'No',
        'Let Stockall manage the item quantity (deduct after sales, low stock alerts). 1 = Yes, 0 = No. Blank means 1.',
        '1',
      ],
      [
        'derive_quantity_from_price',
        'No',
        'Let sellers enter a price during sale and work out the quantity. 1D items only (width and height blank). 1 = Yes, 0 = No. Blank means 0.',
        '0',
      ],
      [
        'manage_wastage',
        'No',
        'Enter wastage during sales. 2D items only (width and height set). 1 = Yes, 0 = No. Blank means 0.',
        '0',
      ],
      [
        'discount_percent',
        'No',
        'Discount in percent, from 0 to 100. Blank means no discount.',
        '5',
      ],
      [
        'size_type',
        'No',
        sizeTypes.isEmpty
            ? 'Item size type. Blank means not set.'
            : 'One of: ${sizeTypes.join(', ')}. Blank means not set.',
        sizeTypes.isEmpty ? '' : sizeTypes.first,
      ],
    ];
  }

  static Uint8List buildXlsx({
    bool full = false,
    List<String> sizeTypes = const [],
  }) {
    final headers =
        full
            ? BulkProductValidator.fullHeaders
            : BulkProductValidator.headers;
    final guideRows = instructions(
      full: full,
      sizeTypes: sizeTypes,
    );
    final workbook = Workbook();
    final sheet = workbook.worksheets[0];
    sheet.name = 'Products';
    for (var i = 0; i < headers.length; i++) {
      final cell = sheet.getRangeByIndex(1, i + 1);
      cell.setText(headers[i]);
      cell.cellStyle.bold = true;
      sheet.setColumnWidthInPixels(i + 1, 130);
    }
    // Barcode (E) and expiry_date (F) stay as text so digits are kept.
    sheet.getRangeByName('E2:F2000').numberFormat = '@';

    final guide = workbook.worksheets.addWithName(
      'Instructions',
    );
    for (var r = 0; r < guideRows.length; r++) {
      for (var c = 0; c < guideRows[r].length; c++) {
        final cell = guide.getRangeByIndex(r + 1, c + 1);
        cell.setText(guideRows[r][c]);
        if (r == 0) cell.cellStyle.bold = true;
      }
    }
    guide.setColumnWidthInPixels(1, full ? 190 : 120);
    guide.setColumnWidthInPixels(2, 80);
    guide.setColumnWidthInPixels(3, 320);
    guide.setColumnWidthInPixels(4, 160);

    final bytes = workbook.saveAsStream();
    workbook.dispose();
    return Uint8List.fromList(bytes);
  }

  static Uint8List buildCsv({bool full = false}) {
    final headers =
        full
            ? BulkProductValidator.fullHeaders
            : BulkProductValidator.headers;
    return Uint8List.fromList(
      utf8.encode('${headers.join(',')}\r\n'),
    );
  }
}
