import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:stockall/bulk_upload/bulk_product_template.dart';
import 'package:stockall/bulk_upload/bulk_product_validator.dart';
import 'package:stockall/bulk_upload/spreadsheet_reader.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart';

const _header =
    'name,quantity,cost_price,selling_price,barcode,expiry_date,low_qtty';
const _headerWithDimensions =
    'name,quantity,cost_price,selling_price,barcode,expiry_date,low_qtty,width,height';

Uint8List _csv(String text) => Uint8List.fromList(utf8.encode(text));

BulkValidationResult _validateCsv(
  String text, {
  Set<String> names = const {},
  Set<String> barcodes = const {},
}) {
  return BulkProductValidator.validate(
    table: SpreadsheetReader.read(
      bytes: _csv(text),
      fileName: 'p.csv',
    ),
    existingNames: names,
    existingBarcodes: barcodes,
  );
}

void main() {
  group('SpreadsheetReader', () {
    test('reads csv with BOM', () {
      final table = SpreadsheetReader.read(
        bytes: _csv('\uFEFFa,b\r\n1,2\r\n'),
        fileName: 'x.CSV',
      );
      expect(table, [
        ['a', 'b'],
        ['1', '2'],
      ]);
    });

    test('reads semicolon csv', () {
      final table = SpreadsheetReader.read(
        bytes: _csv('a;b\n1;2\n'),
        fileName: 'x.csv',
      );
      expect(table[1], ['1', '2']);
    });

    test('reads the generated xlsx template', () {
      final table = SpreadsheetReader.read(
        bytes: BulkProductTemplate.buildXlsx(),
        fileName: 'template.xlsx',
      );
      expect(table.first, BulkProductValidator.headers);
    });

    test('reads xlsx numbers, text barcodes, dates and gaps', () {
      final wb = Workbook();
      final sheet = wb.worksheets[0];
      for (var i = 0; i < BulkProductValidator.headers.length; i++) {
        sheet.getRangeByIndex(1, i + 1).setText(
          BulkProductValidator.headers[i],
        );
      }
      sheet.getRangeByIndex(3, 1).setText('Rice');
      sheet.getRangeByIndex(3, 2).setNumber(5);
      sheet.getRangeByIndex(3, 4).setNumber(12.5);
      sheet.getRangeByIndex(3, 5).setText('00123');
      sheet.getRangeByIndex(3, 6).setDateTime(DateTime(2026, 12, 31));
      sheet.getRangeByIndex(3, 6).numberFormat = 'yyyy-mm-dd';
      final bytes = Uint8List.fromList(wb.saveAsStream());
      wb.dispose();

      final table = SpreadsheetReader.read(
        bytes: bytes,
        fileName: 'a.xlsx',
      );
      expect(table[1], isEmpty);
      expect(table[2][0], 'Rice');
      expect(table[2][1], '5');
      expect(table[2][3], '12.5');
      expect(table[2][4], '00123');
      expect(table[2][5], '2026-12-31');

      final result = BulkProductValidator.validate(table: table);
      expect(result.hasErrors, isFalse);
      expect(result.rows.single.rowNumber, 3);
      expect(result.rows.single.expiryDate, DateTime(2026, 12, 31));
    });

    test('rejects corrupt xlsx, empty and unknown files', () {
      expect(
        () => SpreadsheetReader.read(
          bytes: _csv('not a zip'),
          fileName: 'a.xlsx',
        ),
        throwsA(isA<SpreadsheetFormatException>()),
      );
      expect(
        () => SpreadsheetReader.read(
          bytes: Uint8List(0),
          fileName: 'a.csv',
        ),
        throwsA(isA<SpreadsheetFormatException>()),
      );
      expect(
        () => SpreadsheetReader.read(
          bytes: _csv('x'),
          fileName: 'a.txt',
        ),
        throwsA(isA<SpreadsheetFormatException>()),
      );
    });
  });

  group('BulkProductValidator', () {
    test('applies defaults for blank optional values', () {
      final r = _validateCsv('$_header\nRice,,,,,,\n');
      final row = r.rows.single;
      expect(r.hasErrors, isFalse);
      expect(row.quantity, 0);
      expect(row.costPrice, 0);
      expect(row.sellingPrice, 0);
      expect(row.lowQtty, 10);
      expect(row.barcode, isNull);
      expect(row.expiryDate, isNull);
      expect(row.width, isNull);
      expect(row.height, isNull);
      expect(row.is2D, isFalse);
    });

    test('reports header problems', () {
      final r = _validateCsv('name,quantity,foo\nRice,1,2\n');
      expect(r.fileErrors, isNotEmpty);
      expect(r.rows, isEmpty);
    });

    test('reports row errors', () {
      final r = _validateCsv(
        '$_header\n,abc,,,,32/13/2026,\n',
      );
      expect(r.rows.single.errors.length, 3);
    });

    test('negative numbers are warnings, not errors', () {
      final r = _validateCsv('$_header\nRice,-5,,,,,\n');
      expect(r.hasErrors, isFalse);
      expect(r.hasWarnings, isTrue);
      expect(r.rows.single.quantity, -5);
    });

    test('skips blank rows and keeps row numbers', () {
      final r = _validateCsv('$_header\nRice,1,,,,,\n,,,,,,\nBeans,1,,,,,\n');
      expect(r.rows.map((e) => e.rowNumber), [2, 4]);
    });

    test('flags duplicates in file and against existing products', () {
      final r = _validateCsv(
        '$_header\nRice,1,,,111,,\nrice ,1,,,111,,\nBeans,1,,,222,,\nOil,1,,,,,\n',
        names: {'Beans'},
        barcodes: {'999'},
      );
      expect(r.hasErrors, isFalse);
      expect(r.rows[0].warnings.length, 2);
      expect(r.rows[1].warnings.length, 2);
      expect(r.rows[2].warnings.length, 1);
      expect(r.rows[3].hasWarnings, isFalse);
      expect(r.hasWarnings, isTrue);
    });

    test('parses both date formats', () {
      expect(
        BulkProductValidator.parseDate('2026-01-31'),
        DateTime(2026, 1, 31),
      );
      expect(
        BulkProductValidator.parseDate('31/01/2026'),
        DateTime(2026, 1, 31),
      );
      expect(BulkProductValidator.parseDate('2026-02-30'), isNull);
    });

    test('header-only file has no product rows', () {
      final r = _validateCsv('$_header\n');
      expect(r.hasErrors, isTrue);
    });

    test('parses optional dimensions and identifies 2D products', () {
      final r = _validateCsv(
        '$_headerWithDimensions\nGlass,10,100,150,,,10,120,240\nWood,5,50,80,,,,,\n',
      );
      expect(r.hasErrors, isFalse);
      expect(r.rows.length, 2);

      final glass = r.rows[0];
      expect(glass.is2D, isTrue);
      expect(glass.width, 120.0);
      expect(glass.height, 240.0);

      final wood = r.rows[1];
      expect(wood.is2D, isFalse);
      expect(wood.width, isNull);
      expect(wood.height, isNull);
    });

    test('reports error if only one dimension is provided', () {
      final r = _validateCsv(
        '$_headerWithDimensions\nTile,10,,,,,10,120,\n',
      );
      expect(r.rows.single.hasErrors, isTrue);
      expect(
        r.rows.single.errors,
        contains('Both width and height must be provided for 2D items.'),
      );
    });

    test('reports error if dimension is non-numeric or <= 0', () {
      final r = _validateCsv(
        '$_headerWithDimensions\nItemA,10,,,,,10,abc,200\nItemB,10,,,,,10,-10,200\n',
      );
      expect(r.rows[0].errors, contains('width must be a number.'));
      expect(r.rows[1].errors, contains('width must be greater than 0.'));
    });

    test('accepts dimension aliases in header', () {
      final customHeader =
          'name,quantity,cost_price,selling_price,barcode,expiry_date,low_qtty,width_dimension,height_dimension';
      final r = _validateCsv(
        '$customHeader\nGranite,2,,,,,10,60,180\n',
      );
      expect(r.hasErrors, isFalse);
      expect(r.rows.single.is2D, isTrue);
      expect(r.rows.single.width, 60.0);
      expect(r.rows.single.height, 180.0);
    });
  });
}
