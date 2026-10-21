import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:bluetooth_print_plus/bluetooth_print_plus.dart';
import 'package:stockall/classes/temp_categories/category_class.dart';
import 'package:stockall/classes/temp_departments_class/department_class.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/subscription/sales_auth.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/report/items_report_/items_report_main/class/items_report_main_logic.dart';
import 'package:stockall/services/barcode_generation/barcode_import_helper.dart'
    show listPrinters;
import 'package:stockall/services/printing/escpos_builder.dart';
import 'package:stockall/services/printing/pdf_escpos_raster.dart'
    show dots58mm, dots80mm;
import 'package:stockall/services/printing/printer_service_mobile.dart'
    show BluetoothDevicesPage;
import 'package:stockall/services/receipt_print_service/receipt_import_helper.dart';

enum ItemsReportPrintMode {
  filtered,
  all,
  categories,
  departments,
  fullBreakdown,
}

String _formatQty(double? qty) {
  if (qty == null) return '0';
  return formatLargeNumberDouble(qty);
}

String _itemRightText(ItemsReportRow row) {
  final qtyStr = _formatQty(row.quantity);
  final unit = row.primaryUnit.trim();
  return unit.isEmpty
      ? qtyStr
      : '$qtyStr ${unit.length > 6 ? unit.substring(0, 6) : unit}';
}

List<String> getFilterCombinationLabels({
  required ItemsReportFilters filters,
  required List<CategoryClass> categories,
  required List<DepartmentClass> departments,
  required bool departmentsEnabled,
}) {
  final labels = <String>[];

  if (departmentsEnabled && filters.departmentKey != null) {
    final name =
        filters.departmentKey == itemsReportNoneKey
            ? 'No Department'
            : departments
                    .where(
                      (d) =>
                          d.uuid == filters.departmentKey,
                    )
                    .map((d) => d.name)
                    .firstOrNull ??
                'Department';
    labels.add(
      name.toLowerCase().contains('department')
          ? name
          : '$name Department',
    );
  }

  if (filters.categoryKey != null) {
    final name =
        filters.categoryKey == itemsReportNoneKey
            ? 'No Category'
            : categories
                    .where(
                      (c) => c.uuid == filters.categoryKey,
                    )
                    .map((c) => c.name)
                    .firstOrNull ??
                'Category';
    labels.add(name);
  }

  if (filters.stockLevel != StockLevelFilter.all) {
    final t = switch (filters.stockLevel) {
      StockLevelFilter.inStock => 'In-Stock',
      StockLevelFilter.lowStock => 'Low in Stock',
      StockLevelFilter.outOfStock => 'Out of Stock',
      _ => '',
    };
    if (t.isNotEmpty) labels.add(t);
  }

  if (filters.search.trim().isNotEmpty) {
    labels.add('Search: "${filters.search.trim()}"');
  }

  if (filters.managed != null) {
    labels.add(filters.managed! ? 'Managed' : 'Un-Managed');
  }

  if (filters.sellingMin != null ||
      filters.sellingMax != null) {
    labels.add('Sell Price Range');
  }

  if (filters.costMin != null || filters.costMax != null) {
    labels.add('Cost Price Range');
  }

  if (filters.quantityMin != null ||
      filters.quantityMax != null) {
    labels.add('Qty Range');
  }

  if (filters.expiryStart != null || filters.expiryEnd != null) {
    labels.add('Expiry Range');
  }

  return labels;
}

void _writeEscPosItemRow(
  EscPosBuilder b,
  ItemsReportRow r,
) {
  b.columns([
    EscCol(r.name, flex: 6, align: EscAlign.left),
    const EscCol('-', flex: 1, align: EscAlign.center),
    EscCol(
      _itemRightText(r),
      flex: 4,
      align: EscAlign.right,
    ),
  ]);
  b.feedDots(6);
}

/// Builds direct ESC/POS byte chunks for thermal receipt roll printing.
List<Uint8List> buildItemsReportEscPos({
  required TempShopClass shop,
  required List<ItemsReportRow> rows,
  required ItemsReportPrintMode mode,
  required List<CategoryClass> categories,
  required List<DepartmentClass> departments,
  required bool departmentsEnabled,
  required int printerType,
  List<String> filterLabels = const [],
}) {
  final dots = printerType == 1 ? dots58mm : dots80mm;
  final b = EscPosBuilder(paperDots: dots);

  final now = DateTime.now();

  // Business Name at top
  b.text(
    shop.name,
    align: EscAlign.center,
    bold: true,
    doubleWidth: true,
  );

  // Date and Time
  b.text(
    'Date: ${formatDateTime(now)} | ${formatTime(now)}',
    align: EscAlign.center,
  );
  b.divider();

  switch (mode) {
    case ItemsReportPrintMode.filtered:
      b.text(
        'FILTERED ITEMS RECORD',
        align: EscAlign.center,
        bold: true,
      );
      b.divider();
      for (final r in rows) {
        _writeEscPosItemRow(b, r);
      }
      b.divider();
      b.text(
        'Total Items: ${rows.length}',
        align: EscAlign.center,
        bold: true,
      );
      if (filterLabels.isNotEmpty) {
        b.divider();
        b.text('Filters: ${filterLabels.join(', ')}');
      }
      break;

    case ItemsReportPrintMode.all:
      b.text(
        'ALL ITEMS RECORD',
        align: EscAlign.center,
        bold: true,
      );
      b.divider();
      for (final r in rows) {
        _writeEscPosItemRow(b, r);
      }
      b.divider();
      b.text(
        'Total Items: ${rows.length}',
        align: EscAlign.center,
        bold: true,
      );
      break;

    case ItemsReportPrintMode.categories:
      b.text(
        'ITEMS IN CATEGORIES',
        align: EscAlign.center,
        bold: true,
      );
      b.divider();
      _writeCategoriesEscPos(b, rows, categories);
      b.divider();
      b.text(
        'Total Items: ${rows.length}',
        align: EscAlign.center,
        bold: true,
      );
      break;

    case ItemsReportPrintMode.departments:
      b.text(
        'ITEMS IN DEPARTMENTS',
        align: EscAlign.center,
        bold: true,
      );
      b.divider();
      _writeDepartmentsEscPos(b, rows, departments);
      b.divider();
      b.text(
        'Total Items: ${rows.length}',
        align: EscAlign.center,
        bold: true,
      );
      break;

    case ItemsReportPrintMode.fullBreakdown:
      b.text(
        'FULL BREAKDOWN RECORD',
        align: EscAlign.center,
        bold: true,
      );
      b.divider();

      // 1. All Items
      b.text(
        '[ ALL ITEMS ]',
        align: EscAlign.center,
        bold: true,
      );
      b.divider();
      for (final r in rows) {
        _writeEscPosItemRow(b, r);
      }
      b.feed(1);

      // 2. Departments
      if (departmentsEnabled && departments.isNotEmpty) {
        b.divider();
        b.text(
          '[ DEPARTMENTS ]',
          align: EscAlign.center,
          bold: true,
        );
        b.divider();
        _writeDepartmentsEscPos(b, rows, departments);
        b.feed(1);
      }

      // 3. Categories
      b.divider();
      b.text(
        '[ CATEGORIES ]',
        align: EscAlign.center,
        bold: true,
      );
      b.divider();
      _writeCategoriesEscPos(b, rows, categories);

      b.divider();
      b.text(
        'Total Items: ${rows.length}',
        align: EscAlign.center,
        bold: true,
      );
      break;
  }

  // Feed lines so paper clears the tear-bar / cutter.
  // 80mm printers have a greater distance between print head and auto-cutter blade,
  // so feed 2 extra lines (6 lines total) to ensure bottom content isn't clipped.
  b.feed(printerType == 2 ? 6 : 3);

  final chunks = b.build();

  // Append ESC/POS partial cut command (GS V 1): 0x1D, 0x56, 0x01
  final cutChunk = Uint8List.fromList([0x1D, 0x56, 0x01]);
  return [...chunks, cutChunk];
}

void _writeCategoriesEscPos(
  EscPosBuilder b,
  List<ItemsReportRow> rows,
  List<CategoryClass> categories,
) {
  final cats =
      categories.toList()..sort(
        (a, b) => a.name.toLowerCase().compareTo(
          b.name.toLowerCase(),
        ),
      );
  final matchedUuids = <String>{};

  for (final cat in cats) {
    final catRows =
        rows
            .where(
              (r) => r.categoryUuids.contains(cat.uuid),
            )
            .toList();

    if (catRows.isNotEmpty) {
      for (final r in catRows) {
        matchedUuids.add(r.uuid);
      }
      b.text(
        'CATEGORY: ${cat.name.toUpperCase()}',
        bold: true,
      );
      b.divider();
      for (final r in catRows) {
        _writeEscPosItemRow(b, r);
      }
      b.feed(1);
    }
  }

  // Items with No Category
  final noCatRows =
      rows
          .where(
            (r) =>
                !matchedUuids.contains(r.uuid) ||
                r.categoryUuids.isEmpty,
          )
          .toList();

  if (noCatRows.isNotEmpty) {
    b.text('NO CATEGORY', bold: true);
    b.divider();
    for (final r in noCatRows) {
      _writeEscPosItemRow(b, r);
    }
    b.feed(1);
  }
}

void _writeDepartmentsEscPos(
  EscPosBuilder b,
  List<ItemsReportRow> rows,
  List<DepartmentClass> departments,
) {
  final depts =
      departments.toList()..sort(
        (a, b) => a.name.toLowerCase().compareTo(
          b.name.toLowerCase(),
        ),
      );
  final matchedUuids = <String>{};

  for (final dept in depts) {
    final deptRows =
        rows
            .where((r) => r.departmentUuid == dept.uuid)
            .toList();

    if (deptRows.isNotEmpty) {
      for (final r in deptRows) {
        matchedUuids.add(r.uuid);
      }
      b.text(
        'DEPARTMENT: ${dept.name.toUpperCase()}',
        bold: true,
      );
      b.divider();
      for (final r in deptRows) {
        _writeEscPosItemRow(b, r);
      }
      b.feed(1);
    }
  }

  // Items with No Department
  final noDeptRows =
      rows
          .where(
            (r) =>
                !matchedUuids.contains(r.uuid) ||
                r.departmentUuid == null ||
                r.departmentUuid!.isEmpty,
          )
          .toList();

  if (noDeptRows.isNotEmpty) {
    b.text('NO DEPARTMENT', bold: true);
    b.divider();
    for (final r in noDeptRows) {
      _writeEscPosItemRow(b, r);
    }
    b.feed(1);
  }
}

pw.Widget _buildPdfItemRow(
  ItemsReportRow r,
  double textSize,
) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 2.0),
    child: pw.Row(
      children: [
        pw.Expanded(
          flex: 5,
          child: pw.Text(
            r.name,
            style: pw.TextStyle(fontSize: textSize),
            textAlign: pw.TextAlign.left,
          ),
        ),
        pw.Expanded(
          flex: 1,
          child: pw.Text(
            '-',
            style: pw.TextStyle(fontSize: textSize),
            textAlign: pw.TextAlign.center,
          ),
        ),
        pw.Expanded(
          flex: 4,
          child: pw.Text(
            _itemRightText(r),
            style: pw.TextStyle(fontSize: textSize),
            textAlign: pw.TextAlign.right,
          ),
        ),
      ],
    ),
  );
}

/// Builds a matching POS Roll PDF document (for Web or fallback layout).
Future<Uint8List> buildItemsReportPdfRoll({
  required TempShopClass shop,
  required List<ItemsReportRow> rows,
  required ItemsReportPrintMode mode,
  required List<CategoryClass> categories,
  required List<DepartmentClass> departments,
  required bool departmentsEnabled,
  required int printerType,
  List<String> filterLabels = const [],
}) async {
  final pdf = pw.Document();
  final now = DateTime.now();

  final double headingSize = printerType == 1 ? 11 : 13;
  final double subHeadingSize = printerType == 1 ? 9 : 10;
  final double textSize = printerType == 1 ? 7.5 : 8.5;

  List<pw.Widget> contentWidgets = [];

  // Top Business Name
  contentWidgets.add(
    pw.Center(
      child: pw.Text(
        shop.name,
        style: pw.TextStyle(
          fontSize: headingSize,
          fontWeight: pw.FontWeight.bold,
        ),
        textAlign: pw.TextAlign.center,
      ),
    ),
  );
  contentWidgets.add(pw.SizedBox(height: 2));

  // Date and Time
  contentWidgets.add(
    pw.Center(
      child: pw.Text(
        'Date: ${formatDateTime(now)} | ${formatTime(now)}',
        style: pw.TextStyle(fontSize: textSize),
        textAlign: pw.TextAlign.center,
      ),
    ),
  );
  contentWidgets.add(pw.Divider(thickness: 0.8));

  switch (mode) {
    case ItemsReportPrintMode.filtered:
      contentWidgets.add(
        pw.Center(
          child: pw.Text(
            'FILTERED ITEMS RECORD',
            style: pw.TextStyle(
              fontSize: subHeadingSize,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
      );
      contentWidgets.add(pw.Divider(thickness: 0.5));
      for (final r in rows) {
        contentWidgets.add(_buildPdfItemRow(r, textSize));
      }
      contentWidgets.add(pw.Divider(thickness: 0.8));
      contentWidgets.add(
        pw.Center(
          child: pw.Text(
            'Total Items: ${rows.length}',
            style: pw.TextStyle(
              fontSize: subHeadingSize,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
      );
      if (filterLabels.isNotEmpty) {
        contentWidgets.add(pw.Divider(thickness: 0.5));
        contentWidgets.add(
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(
              vertical: 2,
            ),
            child: pw.Text(
              'Filters: ${filterLabels.join(', ')}',
              style: pw.TextStyle(
                fontSize: textSize,
                fontWeight: pw.FontWeight.bold,
              ),
              textAlign: pw.TextAlign.center,
            ),
          ),
        );
      }
      break;

    case ItemsReportPrintMode.all:
      contentWidgets.add(
        pw.Center(
          child: pw.Text(
            'ALL ITEMS RECORD',
            style: pw.TextStyle(
              fontSize: subHeadingSize,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
      );
      contentWidgets.add(pw.Divider(thickness: 0.5));
      for (final r in rows) {
        contentWidgets.add(_buildPdfItemRow(r, textSize));
      }
      contentWidgets.add(pw.Divider(thickness: 0.8));
      contentWidgets.add(
        pw.Center(
          child: pw.Text(
            'Total Items: ${rows.length}',
            style: pw.TextStyle(
              fontSize: subHeadingSize,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
      );
      break;

    case ItemsReportPrintMode.categories:
      contentWidgets.add(
        pw.Center(
          child: pw.Text(
            'ITEMS IN CATEGORIES',
            style: pw.TextStyle(
              fontSize: subHeadingSize,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
      );
      contentWidgets.add(pw.Divider(thickness: 0.5));
      _buildCategoriesPdf(
        contentWidgets,
        rows,
        categories,
        textSize,
        subHeadingSize,
      );
      contentWidgets.add(pw.Divider(thickness: 0.8));
      contentWidgets.add(
        pw.Center(
          child: pw.Text(
            'Total Items: ${rows.length}',
            style: pw.TextStyle(
              fontSize: subHeadingSize,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
      );
      break;

    case ItemsReportPrintMode.departments:
      contentWidgets.add(
        pw.Center(
          child: pw.Text(
            'ITEMS IN DEPARTMENTS',
            style: pw.TextStyle(
              fontSize: subHeadingSize,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
      );
      contentWidgets.add(pw.Divider(thickness: 0.5));
      _buildDepartmentsPdf(
        contentWidgets,
        rows,
        departments,
        textSize,
        subHeadingSize,
      );
      contentWidgets.add(pw.Divider(thickness: 0.8));
      contentWidgets.add(
        pw.Center(
          child: pw.Text(
            'Total Items: ${rows.length}',
            style: pw.TextStyle(
              fontSize: subHeadingSize,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
      );
      break;

    case ItemsReportPrintMode.fullBreakdown:
      contentWidgets.add(
        pw.Center(
          child: pw.Text(
            'FULL BREAKDOWN RECORD',
            style: pw.TextStyle(
              fontSize: subHeadingSize,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
      );
      contentWidgets.add(pw.Divider(thickness: 0.5));

      // 1. All Items
      contentWidgets.add(
        pw.Center(
          child: pw.Text(
            '[ ALL ITEMS ]',
            style: pw.TextStyle(
              fontSize: subHeadingSize,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
      );
      contentWidgets.add(pw.Divider(thickness: 0.5));
      for (final r in rows) {
        contentWidgets.add(_buildPdfItemRow(r, textSize));
      }
      contentWidgets.add(pw.SizedBox(height: 8));

      // 2. Departments
      if (departmentsEnabled && departments.isNotEmpty) {
        contentWidgets.add(pw.Divider(thickness: 0.8));
        contentWidgets.add(
          pw.Center(
            child: pw.Text(
              '[ DEPARTMENTS ]',
              style: pw.TextStyle(
                fontSize: subHeadingSize,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
        );
        contentWidgets.add(pw.Divider(thickness: 0.5));
        _buildDepartmentsPdf(
          contentWidgets,
          rows,
          departments,
          textSize,
          subHeadingSize,
        );
        contentWidgets.add(pw.SizedBox(height: 8));
      }

      // 3. Categories
      contentWidgets.add(pw.Divider(thickness: 0.8));
      contentWidgets.add(
        pw.Center(
          child: pw.Text(
            '[ CATEGORIES ]',
            style: pw.TextStyle(
              fontSize: subHeadingSize,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
      );
      contentWidgets.add(pw.Divider(thickness: 0.5));
      _buildCategoriesPdf(
        contentWidgets,
        rows,
        categories,
        textSize,
        subHeadingSize,
      );

      contentWidgets.add(pw.Divider(thickness: 0.8));
      contentWidgets.add(
        pw.Center(
          child: pw.Text(
            'Total Items: ${rows.length}',
            style: pw.TextStyle(
              fontSize: subHeadingSize,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
      );
      break;
  }

  // Trailing space at the bottom of the roll to avoid cutting into content
  contentWidgets.add(
    pw.SizedBox(height: printerType == 2 ? 24 : 12),
  );

  pdf.addPage(
    pw.Page(
      pageFormat:
          printerType == 1
              ? PdfPageFormat.roll57
              : PdfPageFormat.roll80,
      margin: const pw.EdgeInsets.symmetric(
        horizontal: 4,
        vertical: 8,
      ),
      build:
          (pw.Context pdfContext) => pw.Column(
            crossAxisAlignment:
                pw.CrossAxisAlignment.stretch,
            children: contentWidgets,
          ),
    ),
  );

  return pdf.save();
}

void _buildCategoriesPdf(
  List<pw.Widget> list,
  List<ItemsReportRow> rows,
  List<CategoryClass> categories,
  double textSize,
  double subHeadingSize,
) {
  final cats =
      categories.toList()..sort(
        (a, b) => a.name.toLowerCase().compareTo(
          b.name.toLowerCase(),
        ),
      );
  final matchedUuids = <String>{};

  for (final cat in cats) {
    final catRows =
        rows
            .where(
              (r) => r.categoryUuids.contains(cat.uuid),
            )
            .toList();

    if (catRows.isNotEmpty) {
      for (final r in catRows) {
        matchedUuids.add(r.uuid);
      }
      list.add(
        pw.Padding(
          padding: const pw.EdgeInsets.only(
            top: 6,
            bottom: 2,
          ),
          child: pw.Text(
            'CATEGORY: ${cat.name.toUpperCase()}',
            style: pw.TextStyle(
              fontSize: subHeadingSize,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
      );
      list.add(pw.Divider(thickness: 0.4));
      for (final r in catRows) {
        list.add(_buildPdfItemRow(r, textSize));
      }
    }
  }

  final noCatRows =
      rows
          .where(
            (r) =>
                !matchedUuids.contains(r.uuid) ||
                r.categoryUuids.isEmpty,
          )
          .toList();

  if (noCatRows.isNotEmpty) {
    list.add(
      pw.Padding(
        padding: const pw.EdgeInsets.only(
          top: 6,
          bottom: 2,
        ),
        child: pw.Text(
          'NO CATEGORY',
          style: pw.TextStyle(
            fontSize: subHeadingSize,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ),
    );
    list.add(pw.Divider(thickness: 0.4));
    for (final r in noCatRows) {
      list.add(_buildPdfItemRow(r, textSize));
    }
  }
}

void _buildDepartmentsPdf(
  List<pw.Widget> list,
  List<ItemsReportRow> rows,
  List<DepartmentClass> departments,
  double textSize,
  double subHeadingSize,
) {
  final depts =
      departments.toList()..sort(
        (a, b) => a.name.toLowerCase().compareTo(
          b.name.toLowerCase(),
        ),
      );
  final matchedUuids = <String>{};

  for (final dept in depts) {
    final deptRows =
        rows
            .where((r) => r.departmentUuid == dept.uuid)
            .toList();

    if (deptRows.isNotEmpty) {
      for (final r in deptRows) {
        matchedUuids.add(r.uuid);
      }
      list.add(
        pw.Padding(
          padding: const pw.EdgeInsets.only(
            top: 6,
            bottom: 2,
          ),
          child: pw.Text(
            'DEPARTMENT: ${dept.name.toUpperCase()}',
            style: pw.TextStyle(
              fontSize: subHeadingSize,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
      );
      list.add(pw.Divider(thickness: 0.4));
      for (final r in deptRows) {
        list.add(_buildPdfItemRow(r, textSize));
      }
    }
  }

  final noDeptRows =
      rows
          .where(
            (r) =>
                !matchedUuids.contains(r.uuid) ||
                r.departmentUuid == null ||
                r.departmentUuid!.isEmpty,
          )
          .toList();

  if (noDeptRows.isNotEmpty) {
    list.add(
      pw.Padding(
        padding: const pw.EdgeInsets.only(
          top: 6,
          bottom: 2,
        ),
        child: pw.Text(
          'NO DEPARTMENT',
          style: pw.TextStyle(
            fontSize: subHeadingSize,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ),
    );
    list.add(pw.Divider(thickness: 0.4));
    for (final r in noDeptRows) {
      list.add(_buildPdfItemRow(r, textSize));
    }
  }
}

/// Opens dialog to select / change printer and paper size.
Future<void> openPrinterAndPaperSizeDialog(
  BuildContext context,
) async {
  if (kIsWeb) {
    final theme = returnTheme(context, listen: false);
    showDialog(
      context: context,
      builder: (ctx) {
        return DialogTemplate(
          theme: theme,
          title: 'Print Paper Size',
          message:
              'Select your preferred receipt roll paper size for printing.',
          action: () {},
          showBottomActionButtons: false,
          topRightWidget: IconButton(
            mouseCursor: SystemMouseCursors.click,
            onPressed: () => Navigator.of(ctx).pop(),
            icon: const Icon(size: 20, Icons.clear),
          ),
          widget: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 20,
            ),
            child: Row(
              spacing: 10,
              children: [
                Expanded(
                  child: _WebPaperSizeButton(
                    index: 1,
                    title: 'Size 58mm',
                    onSelect: () {
                      returnShopProvider().updatePrintType(
                        shopId: shopId(),
                        type: 1,
                      );
                      Navigator.of(ctx).pop();
                    },
                  ),
                ),
                Expanded(
                  child: _WebPaperSizeButton(
                    index: 2,
                    title: 'Size 80mm',
                    onSelect: () {
                      returnShopProvider().updatePrintType(
                        shopId: shopId(),
                        type: 2,
                      );
                      Navigator.of(ctx).pop();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    return;
  }

  if (usesBluetoothPrint()) {
    final theme = returnTheme(context, listen: false);
    showDialog(
      context: context,
      builder: (ctx) {
        return DialogTemplate(
          theme: theme,
          title: 'Receipt Printer & Paper Size',
          message:
              'Configure your Bluetooth printer and receipt paper size.',
          action: () {},
          showBottomActionButtons: false,
          topRightWidget: IconButton(
            mouseCursor: SystemMouseCursors.click,
            onPressed: () => Navigator.of(ctx).pop(),
            icon: const Icon(size: 20, Icons.clear),
          ),
          widget: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 12,
            children: [
              const SizedBox(height: 10),
              Row(
                spacing: 10,
                children: [
                  Expanded(
                    child: _WebPaperSizeButton(
                      index: 1,
                      title: 'Size 58mm',
                      onSelect: () {
                        returnShopProvider()
                            .updatePrintType(
                              shopId: shopId(),
                              type: 1,
                            );
                        Navigator.of(ctx).pop();
                      },
                    ),
                  ),
                  Expanded(
                    child: _WebPaperSizeButton(
                      index: 2,
                      title: 'Size 80mm',
                      onSelect: () {
                        returnShopProvider()
                            .updatePrintType(
                              shopId: shopId(),
                              type: 2,
                            );
                        Navigator.of(ctx).pop();
                      },
                    ),
                  ),
                ],
              ),
              const Divider(),
              ListTile(
                tileColor: Colors.grey.shade100,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                leading: const Icon(
                  Icons.bluetooth_searching,
                ),
                title: const Text(
                  'Scan Bluetooth Printers',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                subtitle: const Text(
                  'Find and pair with nearby receipt printers',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(ctx).pop();
                  showDialog(
                    context: context,
                    builder:
                        (_) => const BluetoothDevicesPage(),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
    return;
  }

  // Windows Desktop
  try {
    listPrinters();
  } catch (_) {}

  await printerSelectionDialog(
    context: context,
    title: 'Receipt Printer & Paper Size',
    message:
        'Select your preferred receipt printer and paper size from the list below.',
  );
}

class _WebPaperSizeButton extends StatelessWidget {
  final int index;
  final String title;
  final VoidCallback onSelect;

  const _WebPaperSizeButton({
    required this.index,
    required this.title,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final currentSize =
        returnShopProvider(
          context: context,
        ).getReceiptPrinter()?.printerSize ??
        returnShopProvider(
          context: context,
        ).userShop()?.printType ??
        1;
    final isSelected = currentSize == index;
    final theme = returnTheme(context);

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color:
              isSelected
                  ? const Color.fromARGB(38, 255, 127, 7)
                  : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color:
                isSelected
                    ? Colors.amber
                    : Colors.grey.shade300,
          ),
        ),
        child: InkWell(
          mouseCursor: SystemMouseCursors.click,
          borderRadius: BorderRadius.circular(6),
          onTap: onSelect,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 14,
            ),
            child: Center(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: theme.mobileTexts.b3.fontSize,
                  fontWeight:
                      isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Executes the POS roll print directly via ESC/POS (Desktop / Bluetooth) or PDF Roll (Web).
Future<void> executeItemsReportPosPrint({
  required BuildContext context,
  required List<ItemsReportRow> rows,
  required ItemsReportPrintMode mode,
  required bool departmentsEnabled,
  List<String> filterLabels = const [],
}) async {
  SalesAuthAction().printReceiptAction(
    context: context,
    action: () async {
      try {
        final shop = returnShopProvider().userShop()!;
        final printerType =
            returnShopProvider()
                .getReceiptPrinter()
                ?.printerSize ??
            shop.printType ??
            1;

        final categories =
            returnCategoriesProvider().categoriesMain
                .toList();
        final departments =
            returnDepartmentProvider().departments.toList();

        if (kIsWeb) {
          final pdfBytes = await buildItemsReportPdfRoll(
            shop: shop,
            rows: rows,
            mode: mode,
            categories: categories,
            departments: departments,
            departmentsEnabled: departmentsEnabled,
            printerType: printerType,
            filterLabels: filterLabels,
          );
          await Printing.layoutPdf(
            onLayout: (_) async => pdfBytes,
          );
          return;
        }

        if (usesBluetoothPrint()) {
          final chunks = buildItemsReportEscPos(
            shop: shop,
            rows: rows,
            mode: mode,
            categories: categories,
            departments: departments,
            departmentsEnabled: departmentsEnabled,
            printerType: printerType,
            filterLabels: filterLabels,
          );

          if (BluetoothPrintPlus.isConnected) {
            for (final chunk in chunks) {
              await BluetoothPrintPlus.write(chunk);
            }
          } else {
            if (context.mounted) {
              showDialog(
                context: context,
                builder:
                    (_) => const BluetoothDevicesPage(),
              );
            }
          }
          return;
        }

        // Windows Desktop: Direct ESC/POS printing
        final chunks = buildItemsReportEscPos(
          shop: shop,
          rows: rows,
          mode: mode,
          categories: categories,
          departments: departments,
          departmentsEnabled: departmentsEnabled,
          printerType: printerType,
          filterLabels: filterLabels,
        );

        final allBytes = Uint8List.fromList(
          chunks.expand((c) => c).toList(),
        );

        if (context.mounted) {
          await checkPrint(
            context: context,
            receiptBytes: allBytes,
          );
        }
      } catch (e, st) {
        await mainLocalLog(
          'Error in executeItemsReportPosPrint: $e\n$st',
        );
      }
    },
  );
}
