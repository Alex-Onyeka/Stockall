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
  final double? width;
  final double? height;

  // Full template columns. Null means blank or column missing,
  // so the caller keeps today's default.
  final bool? setCustomPrice;
  final bool? isManaged;
  final bool? deriveQuantityFromPrice;
  final bool? manageSalesWastage;
  final double? discount;
  final String? sizeType;

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
    this.width,
    this.height,
    this.setCustomPrice,
    this.isManaged,
    this.deriveQuantityFromPrice,
    this.manageSalesWastage,
    this.discount,
    this.sizeType,
    required this.errors,
    required this.warnings,
  });

  bool get is2D =>
      width != null && height != null && width! > 0 && height! > 0;
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
    'width',
    'height',
  ];

  /// Extra columns that only the Full template has.
  static const fullOnlyHeaders = [
    'allow_custom_price',
    'manage_quantity',
    'derive_quantity_from_price',
    'manage_wastage',
    'discount_percent',
    'size_type',
  ];

  /// Columns of the Full template: the simple ones, then the extras.
  static const fullHeaders = [...headers, ...fullOnlyHeaders];

  static const requiredHeaders = [
    'name',
    'quantity',
    'cost_price',
    'selling_price',
    'barcode',
    'expiry_date',
    'low_qtty',
  ];

  static const defaultLowQtty = 10.0;

  static String _normalizeHeader(String h) {
    final normalized =
        h.trim().toLowerCase().replaceAll(RegExp(r'[\s-]+'), '_');
    if (normalized == 'width_dimension' ||
        normalized == 'dimension_width' ||
        normalized == 'width_(cm)' ||
        normalized == 'width_cm' ||
        normalized == 'width(cm)') {
      return 'width';
    }
    if (normalized == 'height_dimension' ||
        normalized == 'dimension_height' ||
        normalized == 'height_(cm)' ||
        normalized == 'height_cm' ||
        normalized == 'height(cm)' ||
        normalized == 'length' ||
        normalized == 'length_dimension' ||
        normalized == 'length_(cm)' ||
        normalized == 'length_cm' ||
        normalized == 'length(cm)') {
      return 'height';
    }
    switch (normalized) {
      case 'set_custom_price':
      case 'custom_price':
        return 'allow_custom_price';
      case 'manage_item_quantity':
        return 'manage_quantity';
      case 'derive_quantity':
        return 'derive_quantity_from_price';
      case 'wastage':
      case 'manage_sales_wastage':
        return 'manage_wastage';
      case 'discount':
      case 'discount_(%)':
      case 'discount_%':
        return 'discount_percent';
    }
    return normalized;
  }

  /// Accepts 1/0, true/false, yes/no and y/n in any case.
  static bool? parseBool(String raw) {
    switch (raw.trim().toLowerCase()) {
      case '1':
      case 'true':
      case 'yes':
      case 'y':
        return true;
      case '0':
      case 'false':
      case 'no':
      case 'n':
        return false;
    }
    return null;
  }

  static String _key(String s) => s.trim().toLowerCase();

  static BulkValidationResult validate({
    required List<List<String>> table,
    Set<String> existingNames = const {},
    Set<String> existingBarcodes = const {},
    // Full template rules. The page passes the shop's size types,
    // the staff permissions and the plan; the validator stays pure.
    List<String> sizeTypes = const [],
    bool canSetCustomPrice = true,
    bool canManageQuantity = true,
    bool canSetSizeType = true,
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
      if (!fullHeaders.contains(h)) {
        fileErrors.add('Unknown column "${raw.trim()}".');
      } else if (!seen.add(h)) {
        fileErrors.add('Column "$h" appears more than once.');
      } else {
        columns[h] = i;
      }
    }
    for (final h in requiredHeaders) {
      if (!columns.containsKey(h)) {
        fileErrors.add('Missing column "$h".');
      }
    }
    if (fileErrors.isNotEmpty) {
      return BulkValidationResult(fileErrors: fileErrors, rows: []);
    }

    String cell(List<String> row, String h) {
      final i = columns[h];
      if (i == null) return '';
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

      double? optionalDimension(String h) {
        final raw = cell(row, h);
        if (raw.isEmpty) return null;
        final cleaned = raw.replaceAll(
          RegExp(r'[,\s]|cm$', caseSensitive: false),
          '',
        );
        final v = double.tryParse(cleaned);
        if (v == null || v.isNaN || v.isInfinite) {
          errors.add('$h must be a number.');
          return null;
        }
        if (v <= 0) {
          errors.add('$h must be greater than 0.');
          return null;
        }
        return v;
      }

      final widthRaw = cell(row, 'width');
      final heightRaw = cell(row, 'height');
      final width = optionalDimension('width');
      final height = optionalDimension('height');

      final hasAnyDimension = widthRaw.isNotEmpty || heightRaw.isNotEmpty;
      if (hasAnyDimension) {
        if (widthRaw.isEmpty || heightRaw.isEmpty) {
          errors.add('Both width and height must be provided for 2D items.');
        }
      }

      bool? flag(String h) {
        final raw = cell(row, h);
        if (raw.isEmpty) return null;
        final v = parseBool(raw);
        if (v == null) {
          errors.add('$h must be 1 (yes) or 0 (no).');
        }
        return v;
      }

      final setCustomPrice = flag('allow_custom_price');
      if (setCustomPrice == true && !canSetCustomPrice) {
        errors.add(
          'You do not have permission to set allow_custom_price (Edit Selling Price).',
        );
      }

      final isManaged = flag('manage_quantity');
      if (isManaged == false && !canManageQuantity) {
        errors.add(
          'You do not have permission to change manage_quantity (Update Item Quantity).',
        );
      }

      final deriveQuantity = flag('derive_quantity_from_price');
      if (deriveQuantity == true && hasAnyDimension) {
        errors.add(
          'derive_quantity_from_price can only be 1 for 1D items (leave width and height blank).',
        );
      }

      final manageWastage = flag('manage_wastage');
      if (manageWastage == true && !hasAnyDimension) {
        errors.add(
          'manage_wastage can only be 1 for 2D items (set width and height).',
        );
      }

      double? discount;
      final discountRaw = cell(row, 'discount_percent');
      if (discountRaw.isNotEmpty) {
        final v = double.tryParse(
          discountRaw.replaceAll(RegExp(r'[,\s%]'), ''),
        );
        if (v == null || v.isNaN || v.isInfinite) {
          errors.add('discount_percent must be a number.');
        } else if (v < 0 || v > 100) {
          errors.add('discount_percent must be between 0 and 100.');
        } else {
          discount = v;
        }
      }

      String? sizeType;
      final sizeRaw = cell(row, 'size_type');
      if (sizeRaw.isNotEmpty) {
        if (!canSetSizeType) {
          errors.add('size_type is not available on your plan.');
        } else {
          final k = _key(sizeRaw).replaceAll(RegExp(r'\s+'), ' ');
          for (final s in sizeTypes) {
            if (_key(s) == k) {
              sizeType = s;
              break;
            }
          }
          if (sizeType == null) {
            errors.add(
              'size_type must be one of: ${sizeTypes.join(', ')}.',
            );
          }
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
          width: width,
          height: height,
          setCustomPrice: setCustomPrice,
          isManaged: isManaged,
          deriveQuantityFromPrice: deriveQuantity,
          manageSalesWastage: manageWastage,
          discount: discount,
          sizeType: sizeType,
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
