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
  ];

  static Uint8List buildXlsx() {
    final workbook = Workbook();
    final sheet = workbook.worksheets[0];
    sheet.name = 'Products';
    for (
      var i = 0;
      i < BulkProductValidator.headers.length;
      i++
    ) {
      final cell = sheet.getRangeByIndex(1, i + 1);
      cell.setText(BulkProductValidator.headers[i]);
      cell.cellStyle.bold = true;
      sheet.setColumnWidthInPixels(i + 1, 130);
    }
    // Barcode (E) and expiry_date (F) stay as text so digits are kept.
    sheet.getRangeByName('E2:F2000').numberFormat = '@';

    final guide = workbook.worksheets.addWithName(
      'Instructions',
    );
    for (var r = 0; r < _instructions.length; r++) {
      for (var c = 0; c < _instructions[r].length; c++) {
        final cell = guide.getRangeByIndex(r + 1, c + 1);
        cell.setText(_instructions[r][c]);
        if (r == 0) cell.cellStyle.bold = true;
      }
    }
    guide.setColumnWidthInPixels(1, 120);
    guide.setColumnWidthInPixels(2, 80);
    guide.setColumnWidthInPixels(3, 320);
    guide.setColumnWidthInPixels(4, 160);

    final bytes = workbook.saveAsStream();
    workbook.dispose();
    return Uint8List.fromList(bytes);
  }

  static Uint8List buildCsv() {
    return Uint8List.fromList(
      utf8.encode(
        '${BulkProductValidator.headers.join(',')}\r\n',
      ),
    );
  }
}
