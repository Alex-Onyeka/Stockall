/// Pure Dart validation of the bulk product upload table.
class BulkProductRow {
  final int rowNumber;
  final String name;
  final double quantity;
  final double costPrice;
  final double sellingPrice;
  final double lowQtty;
  final String? barcode;
  final DateTime? expiryDate;
  final List<String> errors;
  final List<String> warnings;

  BulkProductRow({
    required this.rowNumber,
    required this.name,
    required this.quantity,
    required this.costPrice,
    required this.sellingPrice,
    required this.lowQtty,
    required this.barcode,
    required this.expiryDate,
    required this.errors,
    required this.warnings,
  });

  bool get hasErrors => errors.isNotEmpty;
  bool get hasWarnings => warnings.isNotEmpty;
}

class BulkValidationResult {
  final List<String> fileErrors;
  final List<BulkProductRow> rows;

  BulkValidationResult({
    required this.fileErrors,
    required this.rows,
  });

  int get errorRowCount => rows.where((r) => r.hasErrors).length;
  int get warningRowCount =>
      rows.where((r) => !r.hasErrors && r.hasWarnings).length;
  bool get hasErrors => fileErrors.isNotEmpty || errorRowCount > 0;
  bool get hasWarnings => rows.any((r) => r.hasWarnings);
  bool get isEmpty => rows.isEmpty;
}

class BulkProductValidator {
  static const headers = [
    'name',
    'quantity',
    'cost_price',
    'selling_price',
    'barcode',
    'expiry_date',
    'low_qtty',
  ];

  static const defaultLowQtty = 10.0;

  static String _normalizeHeader(String h) =>
      h.trim().toLowerCase().replaceAll(RegExp(r'[\s-]+'), '_');

  static String _key(String s) => s.trim().toLowerCase();

  static BulkValidationResult validate({
    required List<List<String>> table,
    Set<String> existingNames = const {},
    Set<String> existingBarcodes = const {},
  }) {
    final fileErrors = <String>[];

    // Skip leading blank rows, the first non-blank row is the header.
    var headerIndex = table.indexWhere(
      (r) => r.any((c) => c.trim().isNotEmpty),
    );
    if (headerIndex < 0) {
      return BulkValidationResult(
        fileErrors: ['The file is empty.'],
        rows: [],
      );
    }

    final headerRow = table[headerIndex];
    final columns = <String, int>{};
    final seen = <String>{};
    for (var i = 0; i < headerRow.length; i++) {
      final raw = headerRow[i];
      if (raw.trim().isEmpty) continue;
      final h = _normalizeHeader(raw);
      if (!headers.contains(h)) {
        fileErrors.add('Unknown column "${raw.trim()}".');
      } else if (!seen.add(h)) {
        fileErrors.add('Column "$h" appears more than once.');
      } else {
        columns[h] = i;
      }
    }
    for (final h in headers) {
      if (!columns.containsKey(h)) {
        fileErrors.add('Missing column "$h".');
      }
    }
    if (fileErrors.isNotEmpty) {
      return BulkValidationResult(fileErrors: fileErrors, rows: []);
    }

    String cell(List<String> row, String h) {
      final i = columns[h]!;
      return i < row.length ? row[i].trim() : '';
    }

    final nameKeys = existingNames.map(_key).toSet();
    final barcodeKeys = existingBarcodes.map(_key).toSet();
    final fileNameCount = <String, int>{};
    final fileBarcodeCount = <String, int>{};

    final parsed = <BulkProductRow>[];
    for (var r = headerIndex + 1; r < table.length; r++) {
      final row = table[r];
      if (row.every((c) => c.trim().isEmpty)) continue;

      final errors = <String>[];
      final warnings = <String>[];

      final name = cell(row, 'name');
      if (name.isEmpty) errors.add('Name is required.');

      double number(String h, double fallback) {
        final raw = cell(row, h);
        if (raw.isEmpty) return fallback;
        final v = double.tryParse(raw.replaceAll(RegExp(r'[,\s]'), ''));
        if (v == null || v.isNaN || v.isInfinite) {
          errors.add('$h must be a number.');
          return fallback;
        }
        if (v < 0) {
          warnings.add('$h is negative.');
        }
        return v;
      }

      final quantity = number('quantity', 0);
      final cost = number('cost_price', 0);
      final selling = number('selling_price', 0);
      final low = number('low_qtty', defaultLowQtty);

      final barcodeRaw = cell(row, 'barcode');
      final barcode = barcodeRaw.isEmpty ? null : barcodeRaw;

      DateTime? expiry;
      final expiryRaw = cell(row, 'expiry_date');
      if (expiryRaw.isNotEmpty) {
        expiry = parseDate(expiryRaw);
        if (expiry == null) {
          errors.add(
            'expiry_date must look like 2026-12-31 or 31/12/2026.',
          );
        }
      }

      if (name.isNotEmpty) {
        final k = _key(name);
        fileNameCount[k] = (fileNameCount[k] ?? 0) + 1;
      }
      if (barcode != null) {
        final k = _key(barcode);
        fileBarcodeCount[k] = (fileBarcodeCount[k] ?? 0) + 1;
      }

      parsed.add(
        BulkProductRow(
          rowNumber: r + 1,
          name: name,
          quantity: quantity,
          costPrice: cost,
          sellingPrice: selling,
          lowQtty: low,
          barcode: barcode,
          expiryDate: expiry,
          errors: errors,
          warnings: warnings,
        ),
      );
    }

    for (final row in parsed) {
      if (row.name.isNotEmpty) {
        final k = _key(row.name);
        if ((fileNameCount[k] ?? 0) > 1) {
          row.warnings.add('Name appears more than once in the file.');
        }
        if (nameKeys.contains(k)) {
          row.warnings.add('A product with this name already exists.');
        }
      }
      if (row.barcode != null) {
        final k = _key(row.barcode!);
        if ((fileBarcodeCount[k] ?? 0) > 1) {
          row.warnings.add('Barcode appears more than once in the file.');
        }
        if (barcodeKeys.contains(k)) {
          row.warnings.add('A product with this barcode already exists.');
        }
      }
    }

    if (parsed.isEmpty) {
      fileErrors.add('The file has no product rows.');
    }

    return BulkValidationResult(fileErrors: fileErrors, rows: parsed);
  }

  /// Accepts yyyy-MM-dd (optionally followed by a time) and dd/MM/yyyy.
  static DateTime? parseDate(String raw) {
    final iso = RegExp(r'^(\d{4})-(\d{1,2})-(\d{1,2})(?:[T\s].*)?$')
        .firstMatch(raw);
    if (iso != null) {
      return _build(
        int.parse(iso.group(1)!),
        int.parse(iso.group(2)!),
        int.parse(iso.group(3)!),
      );
    }
    final dmy = RegExp(r'^(\d{1,2})[/.-](\d{1,2})[/.-](\d{4})$')
        .firstMatch(raw);
    if (dmy != null) {
      return _build(
        int.parse(dmy.group(3)!),
        int.parse(dmy.group(2)!),
        int.parse(dmy.group(1)!),
      );
    }
    return null;
  }

  static DateTime? _build(int y, int m, int d) {
    final date = DateTime(y, m, d);
    if (date.year != y || date.month != m || date.day != d) return null;
    return date;
  }
}
