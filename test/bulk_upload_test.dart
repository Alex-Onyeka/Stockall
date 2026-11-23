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

  group('Full template', () {
    test('simple template is unchanged', () {
      final csv = SpreadsheetReader.read(
        bytes: BulkProductTemplate.buildCsv(),
        fileName: 't.csv',
      );
      expect(csv.first, BulkProductValidator.headers);
      expect(BulkProductTemplate.instructions().length, 10);
    });

    test('full csv and xlsx templates round-trip', () {
      final csv = SpreadsheetReader.read(
        bytes: BulkProductTemplate.buildCsv(full: true),
        fileName: 't.csv',
      );
      expect(csv.first, BulkProductValidator.fullHeaders);

      final xlsx = SpreadsheetReader.read(
        bytes: BulkProductTemplate.buildXlsx(
          full: true,
          sizeTypes: _sizes,
        ),
        fileName: 't.xlsx',
      );
      expect(xlsx.first, BulkProductValidator.fullHeaders);
      expect(
        BulkProductValidator.fullHeaders.take(
          BulkProductValidator.headers.length,
        ),
        BulkProductValidator.headers,
      );
    });

    test('full instructions document every extra column and 1/0', () {
      final guide = BulkProductTemplate.instructions(
        full: true,
        sizeTypes: _sizes,
      );
      final byColumn = {for (final r in guide.skip(1)) r[0]: r};
      for (final h in BulkProductValidator.fullHeaders) {
        expect(byColumn.containsKey(h), isTrue, reason: h);
      }
      for (final h in [
        'allow_custom_price',
        'manage_quantity',
        'derive_quantity_from_price',
        'manage_wastage',
      ]) {
        expect(byColumn[h]![2], contains('1 = Yes, 0 = No'));
      }
      expect(byColumn['size_type']![2], contains('X Large'));
    });

    test('simple file leaves the extra fields null', () {
      final row = _validateCsv('$_header\nRice,,,,,,\n').rows.single;
      expect(row.hasErrors, isFalse);
      expect(row.setCustomPrice, isNull);
      expect(row.isManaged, isNull);
      expect(row.deriveQuantityFromPrice, isNull);
      expect(row.manageSalesWastage, isNull);
      expect(row.discount, isNull);
      expect(row.sizeType, isNull);
    });

    test('blank extra cells keep defaults', () {
      final r = _validateFull('Rice,,,,,,,,,,,,,,\n');
      final row = r.rows.single;
      expect(r.hasErrors, isFalse);
      expect(row.setCustomPrice, isNull);
      expect(row.isManaged, isNull);
      expect(row.deriveQuantityFromPrice, isNull);
      expect(row.manageSalesWastage, isNull);
      expect(row.discount, isNull);
      expect(row.sizeType, isNull);
    });

    test('parses 1/0, TRUE/FALSE, yes/no and y/n', () {
      final r = _validateFull(
        'A,,,,,,,,,1,0,1,,5,medium\n'
        'B,,,,,,,,,TRUE,false,No,,,\n'
        'C,,,,,,,,,Yes,Y,n,,,\n'
        'D,,,,,,,100,200,0,1,,1,,X LARGE\n',
      );
      expect(r.hasErrors, isFalse, reason: '${r.rows.map((e) => e.errors)}');
      final a = r.rows[0];
      expect(a.setCustomPrice, isTrue);
      expect(a.isManaged, isFalse);
      expect(a.deriveQuantityFromPrice, isTrue);
      expect(a.manageSalesWastage, isNull);
      expect(a.discount, 5);
      expect(a.sizeType, 'Medium');
      expect(r.rows[1].setCustomPrice, isTrue);
      expect(r.rows[1].isManaged, isFalse);
      expect(r.rows[1].deriveQuantityFromPrice, isFalse);
      expect(r.rows[2].setCustomPrice, isTrue);
      expect(r.rows[2].isManaged, isTrue);
      expect(r.rows[2].deriveQuantityFromPrice, isFalse);
      final d = r.rows[3];
      expect(d.is2D, isTrue);
      expect(d.setCustomPrice, isFalse);
      expect(d.manageSalesWastage, isTrue);
      expect(d.sizeType, 'X Large');
    });

    test('invalid booleans are row errors', () {
      final row = _validateFull('A,,,,,,,,,2,maybe,,,,\n').rows.single;
      expect(
        row.errors,
        containsAll([
          'allow_custom_price must be 1 (yes) or 0 (no).',
          'manage_quantity must be 1 (yes) or 0 (no).',
        ]),
      );
    });

    test('discount_percent must be a number from 0 to 100', () {
      final r = _validateFull(
        'A,,,,,,,,,,,,,-1,\n'
        'B,,,,,,,,,,,,,101,\n'
        'C,,,,,,,,,,,,,abc,\n'
        'D,,,,,,,,,,,,,12.5%,\n',
      );
      expect(
        r.rows[0].errors,
        contains('discount_percent must be between 0 and 100.'),
      );
      expect(
        r.rows[1].errors,
        contains('discount_percent must be between 0 and 100.'),
      );
      expect(
        r.rows[2].errors,
        contains('discount_percent must be a number.'),
      );
      expect(r.rows[3].hasErrors, isFalse);
      expect(r.rows[3].discount, 12.5);
    });

    test('size_type must be a known size and allowed by the plan', () {
      final bad = _validateFull('A,,,,,,,,,,,,,,Huge\n').rows.single;
      expect(
        bad.errors.single,
        startsWith('size_type must be one of: Small, Medium'),
      );

      final gated = _validateFull(
        'A,,,,,,,,,,,,,,Small\nB,,,,,,,,,,,,,,\n',
        canSetSizeType: false,
      );
      expect(
        gated.rows[0].errors,
        contains('size_type is not available on your plan.'),
      );
      expect(gated.rows[1].hasErrors, isFalse);
    });

    test('1D-only and 2D-only flags are row errors on the wrong item', () {
      final r = _validateFull(
        'Glass,,,,,,,100,200,,,1,,,\n'
        'Rice,,,,,,,,,,,,1,,\n'
        'Sheet,,,,,,,100,200,,,0,1,,\n'
        'Beans,,,,,,,,,,,1,0,,\n',
      );
      expect(
        r.rows[0].errors,
        contains(
          'derive_quantity_from_price can only be 1 for 1D items (leave width and height blank).',
        ),
      );
      expect(
        r.rows[1].errors,
        contains(
          'manage_wastage can only be 1 for 2D items (set width and height).',
        ),
      );
      expect(r.rows[2].hasErrors, isFalse);
      expect(r.rows[3].hasErrors, isFalse);
    });

    test('staff permissions are checked per column', () {
      final r = _validateFull(
        'A,,,,,,,,,1,,,,,\n'
        'B,,,,,,,,,0,,,,,\n'
        'C,,,,,,,,,,0,,,,\n'
        'D,,,,,,,,,,1,,,,\n',
        canSetCustomPrice: false,
        canManageQuantity: false,
      );
      expect(
        r.rows[0].errors,
        contains(
          'You do not have permission to set allow_custom_price (Edit Selling Price).',
        ),
      );
      expect(r.rows[1].hasErrors, isFalse);
      expect(
        r.rows[2].errors,
        contains(
          'You do not have permission to change manage_quantity (Update Item Quantity).',
        ),
      );
      expect(r.rows[3].hasErrors, isFalse);
    });

    test('accepts header aliases for the extra columns', () {
      final r = _validateCsv(
        '$_header,Set Custom Price,Discount (%),Wastage,Manage Item Quantity\n'
        'Rice,,,,,,,1,10,0,0\n',
      );
      expect(r.fileErrors, isEmpty);
      final row = r.rows.single;
      expect(row.setCustomPrice, isTrue);
      expect(row.discount, 10);
      expect(row.manageSalesWastage, isFalse);
      expect(row.isManaged, isFalse);
    });

    test('reads 1/0 typed as numbers in an xlsx file', () {
      final wb = Workbook();
      final sheet = wb.worksheets[0];
      final headers = BulkProductValidator.fullHeaders;
      for (var i = 0; i < headers.length; i++) {
        sheet.getRangeByIndex(1, i + 1).setText(headers[i]);
      }
      sheet.getRangeByIndex(2, 1).setText('Rice');
      sheet
          .getRangeByIndex(2, headers.indexOf('allow_custom_price') + 1)
          .setNumber(1);
      sheet
          .getRangeByIndex(2, headers.indexOf('manage_quantity') + 1)
          .setNumber(0);
      final bytes = Uint8List.fromList(wb.saveAsStream());
      wb.dispose();

      final r = BulkProductValidator.validate(
        table: SpreadsheetReader.read(bytes: bytes, fileName: 'f.xlsx'),
        sizeTypes: _sizes,
      );
      expect(r.hasErrors, isFalse);
      expect(r.rows.single.setCustomPrice, isTrue);
      expect(r.rows.single.isManaged, isFalse);
    });

    test('unknown columns are still file errors', () {
      final r = _validateCsv('$_header,brand\nRice,,,,,,,Acme\n');
      expect(r.fileErrors, contains('Unknown column "brand".'));
    });
  });
}

const _sizes = ['Small', 'Medium', 'Large', 'X Large'];

BulkValidationResult _validateFull(
  String rows, {
  bool canSetCustomPrice = true,
  bool canManageQuantity = true,
  bool canSetSizeType = true,
}) {
  return BulkProductValidator.validate(
    table: SpreadsheetReader.read(
      bytes: _csv(
        '${BulkProductValidator.fullHeaders.join(',')}\n$rows',
      ),
      fileName: 'f.csv',
    ),
    sizeTypes: _sizes,
    canSetCustomPrice: canSetCustomPrice,
    canManageQuantity: canManageQuantity,
    canSetSizeType: canSetSizeType,
  );
}
