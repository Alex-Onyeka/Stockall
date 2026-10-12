import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:csv/csv.dart';
import 'package:xml/xml.dart';

class SpreadsheetFormatException implements Exception {
  final String message;
  SpreadsheetFormatException(this.message);

  @override
  String toString() => message;
}

/// Reads the first sheet of an .xlsx file, or a .csv file, into a
/// table of strings. Rows skipped in the sheet are kept as empty rows
/// so that row numbers reported to the user match the spreadsheet.
class SpreadsheetReader {
  static List<List<String>> read({
    required Uint8List bytes,
    required String fileName,
  }) {
    final name = fileName.toLowerCase();
    if (bytes.isEmpty) {
      throw SpreadsheetFormatException('The file is empty.');
    }
    if (name.endsWith('.xlsx')) return _readXlsx(bytes);
    if (name.endsWith('.csv')) return _readCsv(bytes);
    throw SpreadsheetFormatException(
      'Unsupported file type. Please upload an .xlsx or .csv file.',
    );
  }

  static List<List<String>> _readCsv(Uint8List bytes) {
    var text = utf8.decode(bytes, allowMalformed: true);
    if (text.startsWith('\uFEFF')) text = text.substring(1);
    try {
      return Csv(skipEmptyLines: false)
          .decode(text)
          .map((row) => row.map((c) => c?.toString() ?? '').toList())
          .toList();
    } catch (_) {
      throw SpreadsheetFormatException(
        'The CSV file could not be read.',
      );
    }
  }

  static List<List<String>> _readXlsx(Uint8List bytes) {
    final Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(bytes);
    } catch (_) {
      throw SpreadsheetFormatException(
        'The Excel file is corrupt or is not a valid .xlsx file.',
      );
    }

    try {
      final sheetXml = _readXml(archive, _firstSheetPath(archive));
      if (sheetXml == null) {
        throw SpreadsheetFormatException(
          'The Excel file has no readable sheet.',
        );
      }
      final sharedStrings = _readSharedStrings(archive);
      final dateStyles = _readDateStyles(archive);

      final rows = <List<String>>[];
      for (final rowElement in sheetXml.findAllElements('row')) {
        final rowIndex =
            int.tryParse(rowElement.getAttribute('r') ?? '') ??
            (rows.length + 1);
        while (rows.length < rowIndex) {
          rows.add(<String>[]);
        }
        final cells = rows[rowIndex - 1];
        var nextColumn = 0;
        for (final cell in rowElement.findElements('c')) {
          final ref = cell.getAttribute('r');
          final column = ref != null ? _columnIndex(ref) : nextColumn;
          nextColumn = column + 1;
          while (cells.length <= column) {
            cells.add('');
          }
          cells[column] = _cellValue(cell, sharedStrings, dateStyles);
        }
      }
      return rows;
    } on SpreadsheetFormatException {
      rethrow;
    } catch (_) {
      throw SpreadsheetFormatException(
        'The Excel file could not be read.',
      );
    }
  }

  static XmlDocument? _readXml(Archive archive, String path) {
    final file = archive.findFile(path);
    if (file == null) return null;
    return XmlDocument.parse(
      utf8.decode(file.content, allowMalformed: true),
    );
  }

  static String _firstSheetPath(Archive archive) {
    const fallback = 'xl/worksheets/sheet1.xml';
    final workbook = _readXml(archive, 'xl/workbook.xml');
    final rels = _readXml(archive, 'xl/_rels/workbook.xml.rels');
    if (workbook == null || rels == null) return fallback;

    final sheets = workbook.findAllElements('sheet');
    if (sheets.isEmpty) return fallback;
    String? relId;
    for (final a in sheets.first.attributes) {
      if (a.name.local == 'id' && a.name.prefix != null) {
        relId = a.value;
      }
    }
    if (relId == null) return fallback;

    for (final rel in rels.findAllElements('Relationship')) {
      if (rel.getAttribute('Id') == relId) {
        final target = rel.getAttribute('Target') ?? '';
        if (target.isEmpty) return fallback;
        return target.startsWith('/')
            ? target.substring(1)
            : 'xl/$target';
      }
    }
    return fallback;
  }

  static List<String> _readSharedStrings(Archive archive) {
    final doc = _readXml(archive, 'xl/sharedStrings.xml');
    if (doc == null) return [];
    return doc.findAllElements('si').map((si) {
      final buffer = StringBuffer();
      for (final t in si.findAllElements('t')) {
        // Phonetic hints are not part of the cell text.
        if (t.ancestors.whereType<XmlElement>().any(
          (e) => e.name.local == 'rPh',
        )) {
          continue;
        }
        buffer.write(t.innerText);
      }
      return buffer.toString();
    }).toList();
  }

  /// For each cell style index, whether it is a date format.
  static List<bool> _readDateStyles(Archive archive) {
    final doc = _readXml(archive, 'xl/styles.xml');
    if (doc == null) return [];

    final customFormats = <int, String>{};
    for (final fmt in doc.findAllElements('numFmt')) {
      final id = int.tryParse(fmt.getAttribute('numFmtId') ?? '');
      final code = fmt.getAttribute('formatCode');
      if (id != null && code != null) customFormats[id] = code;
    }

    final cellXfs = doc.findAllElements('cellXfs');
    if (cellXfs.isEmpty) return [];
    return cellXfs.first
        .findElements('xf')
        .map(
          (xf) => _isDateFormat(
            int.tryParse(xf.getAttribute('numFmtId') ?? '') ?? 0,
            customFormats,
          ),
        )
        .toList();
  }

  static bool _isDateFormat(int id, Map<int, String> custom) {
    if ((id >= 14 && id <= 22) ||
        (id >= 27 && id <= 36) ||
        (id >= 45 && id <= 47) ||
        (id >= 50 && id <= 58)) {
      return true;
    }
    final code = custom[id];
    if (code == null) return false;
    final stripped = code
        .replaceAll(RegExp(r'"[^"]*"'), '')
        .replaceAll(RegExp(r'\[[^\]]*\]'), '')
        .replaceAll(RegExp(r'\\.'), '');
    return RegExp(r'[dmyhs]', caseSensitive: false).hasMatch(stripped);
  }

  static int _columnIndex(String ref) {
    var index = 0;
    for (final unit in ref.toUpperCase().codeUnits) {
      if (unit < 65 || unit > 90) break;
      index = index * 26 + (unit - 64);
    }
    return index - 1;
  }

  static String _cellValue(
    XmlElement cell,
    List<String> sharedStrings,
    List<bool> dateStyles,
  ) {
    final type = cell.getAttribute('t');

    if (type == 'inlineStr') {
      return cell.findAllElements('t').map((t) => t.innerText).join();
    }

    final raw = cell.getElement('v')?.innerText ?? '';
    if (raw.isEmpty) return '';

    switch (type) {
      case 's':
        final index = int.tryParse(raw);
        return index != null && index < sharedStrings.length
            ? sharedStrings[index]
            : '';
      case 'b':
        return raw == '1' ? 'TRUE' : 'FALSE';
      case 'str':
      case 'e':
        return raw;
      default:
        final number = double.tryParse(raw);
        if (number == null) return raw;
        final style = int.tryParse(cell.getAttribute('s') ?? '');
        if (style != null &&
            style < dateStyles.length &&
            dateStyles[style]) {
          return _serialToIsoDate(number);
        }
        if (number == number.truncateToDouble() &&
            number.abs() < 1e15) {
          return number.toInt().toString();
        }
        return number.toString();
    }
  }

  static String _serialToIsoDate(double serial) {
    final date = DateTime.utc(1899, 12, 30)
        .add(Duration(days: serial.floor()));
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '${date.year}-$m-$d';
  }
}
