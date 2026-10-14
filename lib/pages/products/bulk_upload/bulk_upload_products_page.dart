import 'package:flutter/material.dart';
import 'package:stockall/bulk_upload/bulk_product_template.dart';
import 'package:stockall/bulk_upload/bulk_product_validator.dart';
import 'package:stockall/bulk_upload/spreadsheet_picker.dart';
import 'package:stockall/bulk_upload/spreadsheet_reader.dart';
import 'package:stockall/classes/temp_product_class/prices_class/product_prices_class.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/classes/temp_product_class/units_class/product_units_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/subscription/items_auth.dart';
import 'package:stockall/constants/subscription/subscription_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/excel_provider.dart';
import 'package:stockall/providers/theme_provider.dart';

class BulkUploadProductsPage extends StatefulWidget {
  const BulkUploadProductsPage({super.key});

  @override
  State<BulkUploadProductsPage> createState() =>
      _BulkUploadProductsPageState();
}

class _BulkUploadProductsPageState
    extends State<BulkUploadProductsPage> {
  String? fileName;
  BulkValidationResult? result;
  bool isBusy = false;
  int? importedCount;

  static const _previewLimit = 200;

  Future<void> _downloadTemplate({
    required bool csv,
  }) async {
    final bytes =
        csv
            ? BulkProductTemplate.buildCsv()
            : BulkProductTemplate.buildXlsx();
    final saved = await ExcelProvider().save(
      bytes: bytes,
      name: 'Stockall Products Template',
      isCsv: csv,
      addSuffix: false,
    );
    if (!mounted || saved) {
      _showInfo(
        title: 'Success',
        message: 'Template File Downloaded Successfully',
        isSuccess: true,
      );
      return;
    }
    _showInfo(
      title: 'Error',
      message: 'The template could not be saved.',
      isSuccess: false,
    );
  }

  Future<void> _pickFile() async {
    // Must be called synchronously from the tap (no awaits before it),
    // otherwise browsers block the file chooser on web.
    final PickedSpreadsheet? file;
    try {
      file = await pickSpreadsheetFile();
    } catch (_) {
      if (!mounted) return;
      _showInfo(
        title: 'Error',
        message:
            'Could not open the file chooser on this device.',
        isSuccess: false,
      );
      return;
    }
    if (file == null) return;
    final bytes = file.bytes;
    if (bytes == null) {
      _showInfo(
        title: 'Error',
        message: 'The selected file could not be read.',
        isSuccess: false,
      );
      return;
    }

    setState(() {
      isBusy = true;
      importedCount = null;
    });
    try {
      final table = SpreadsheetReader.read(
        bytes: bytes,
        fileName: file.name,
      );
      final products = returnData().productList();
      final validation = BulkProductValidator.validate(
        table: table,
        existingNames: products.map((p) => p.name).toSet(),
        existingBarcodes:
            products
                .map((p) => p.barcode)
                .whereType<String>()
                .where((b) => b.trim().isNotEmpty)
                .toSet(),
      );
      if (!mounted) return;
      setState(() {
        fileName = file?.name ?? 'Not Set';
        result = validation;
      });
    } on SpreadsheetFormatException catch (e) {
      if (!mounted) return;
      setState(() {
        fileName = file?.name ?? 'Not Set';
        result = BulkValidationResult(
          fileErrors: [e.message],
          rows: [],
        );
      });
    } finally {
      if (mounted) setState(() => isBusy = false);
    }
  }

  void _showInfo({
    required String title,
    required String message,
    required bool isSuccess,
  }) {
    showDialog(
      context: context,
      builder:
          (context) => InfoAlert(
            color:
                isSuccess
                    ? returnTheme(
                      context,
                      listen: false,
                    ).lightModeColor.prColor300
                    : null,
            icon: isSuccess ? Icons.check : null,
            theme: returnTheme(context, listen: false),
            title: title,
            message: message,
          ),
    );
  }

  void _startImport() {
    final validation = result;
    if (validation == null ||
        validation.hasErrors ||
        validation.isEmpty) {
      return;
    }

    final allowed = ItemsAuthAction().itemsAllowedToAdd(
      context,
    );
    if (allowed == null ||
        validation.rows.length > allowed) {
      showDialog(
        context: context,
        builder:
            (context) => SubscribeAlertDialog(
              message:
                  allowed == null
                      ? 'You need an active subscription to add products.'
                      : 'This file has ${validation.rows.length} products, but your plan only allows $allowed more. '
                          'Remove some rows or upgrade your plan. No products were uploaded.',
            ),
      );
      return;
    }

    if (validation.hasWarnings) {
      showDialog(
        context: context,
        builder:
            (dialogContext) => ConfirmationAlert(
              theme: returnTheme(context, listen: false),
              title: 'Duplicates Found',
              message:
                  '${validation.rows.where((r) => r.hasWarnings).length} row(s) have warnings (duplicate names or barcodes, or negative values). '
                  'Do you want to upload anyway, or cancel and edit your file?',
              actionButtonText: 'Upload Anyway',
              action: () {
                Navigator.of(dialogContext).pop();
                _import(validation);
              },
            ),
      );
      return;
    }
    _import(validation);
  }

  void _clearFile() {
    setState(() {
      fileName = null;
      result = null;
    });
  }

  Future<void> _import(
    BulkValidationResult validation,
  ) async {
    setState(() => isBusy = true);
    try {
      final products =
          validation.rows.map(_buildProduct).toList();
      await returnData().bulkCreateProducts(products);
      if (!mounted) return;
      setState(() {
        importedCount = products.length;
        result = null;
        fileName = null;
      });
    } catch (e) {
      if (!mounted) return;
      _showInfo(
        title: 'Upload Failed',
        message:
            'Something went wrong while saving the products. Please check your inventory and try again.',
        isSuccess: false,
      );
    } finally {
      if (mounted) setState(() => isBusy = false);
    }
  }

  TempProductClass _buildProduct(BulkProductRow row) {
    final uuid = uuidGen();
    final now = DateTime.now();
    return TempProductClass(
      manageSalesWastage: null,
      name: row.name,
      barcode: row.barcode,
      unit: 'Unit(s)',
      isRefundable: false,
      costPrice: row.costPrice,
      sellingPrice: row.sellingPrice,
      quantity: row.quantity,
      lowQtty: row.lowQtty,
      expiryDate: row.expiryDate,
      shopId: shopId(),
      createdAt: now,
      updatedAt: now,
      setCustomPrice: false,
      isManaged: true,
      departmentName: null,
      departmentUuid: null,
      groupUnit: 'Group(s)',
      qttyPerGroup: null,
      wholeSalePrice: null,
      storageUuid: null,
      categories: [],
      useGroupUnit: false,
      uuid: uuid,
      unitsList: ProductUnitsClass.getUnitList(
        productUuid: uuid,
        tempUnitList: null,
      ),
      pricesList: ProductPricesClass.getPricesList(
        itemUuid: uuid,
        price: row.sellingPrice,
        tempPricesList: null,
      ),
      widthDimension: null,
      heightDimension: null,
      quantityType: 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = returnTheme(context);
    final validation = result;

    return Scaffold(
      appBar: appBar(
        context: context,
        title: 'Bulk Upload Products',
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: ListView(
            padding: const EdgeInsets.all(15),
            children: [
              Text(
                '1. Download the template',
                style: TextStyle(
                  fontSize: theme.mobileTexts.h4.fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Fill in one product per row. Only the name is required. '
                'Blank quantity and prices count as 0, and a blank low_qtty is 10. '
                'This only supports simple (1-D) items.',
                style: TextStyle(
                  fontSize: theme.mobileTexts.b1.fontSize,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  OutlinedButton.icon(
                    onPressed:
                        () => _downloadTemplate(csv: false),
                    icon: const Icon(Icons.download),
                    label: const Text('Excel (.xlsx)'),
                  ),
                  OutlinedButton.icon(
                    onPressed:
                        () => _downloadTemplate(csv: true),
                    icon: const Icon(Icons.download),
                    label: const Text('CSV (.csv)'),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              Text(
                '2. Upload your file',
                style: TextStyle(
                  fontSize: theme.mobileTexts.h4.fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              MainButtonP(
                themeProvider: theme,
                action: isBusy ? () {} : _pickFile,
                text:
                    fileName == null
                        ? 'Choose .xlsx or .csv file'
                        : 'Choose a different file',
              ),
              if (isBusy)
                const Padding(
                  padding: EdgeInsets.only(top: 15),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              if (importedCount != null)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    '$importedCount products added successfully. They will sync automatically.',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize:
                          theme.mobileTexts.b1.fontSize,
                    ),
                  ),
                ),
              if (validation != null)
                ..._buildPreview(theme, validation),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPreview(
    ThemeProvider theme,
    BulkValidationResult validation,
  ) {
    final problems =
        validation.rows
            .where((r) => r.hasErrors || r.hasWarnings)
            .toList();
    final shown = problems.take(_previewLimit).toList();

    return [
      const SizedBox(height: 20),
      Row(
        children: [
          Expanded(
            child: Text(
              fileName ?? '',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: isBusy ? null : _clearFile,
            icon: const Icon(Icons.close),
            label: const Text('Clear file'),
          ),
        ],
      ),
      const SizedBox(height: 5),
      for (final e in validation.fileErrors)
        Text(
          e,
          style: TextStyle(color: Colors.red.shade700),
        ),
      if (validation.fileErrors.isEmpty) ...[
        if (validation.hasErrors)
          Text(
            'Fix the errors above in your file and upload it again.',
            style: TextStyle(color: Colors.red.shade700),
          )
        else
          MainButtonP(
            themeProvider: theme,
            action: isBusy ? () {} : _startImport,
            text:
                'Upload ${validation.rows.length} Products',
          ),
        Text(
          '${validation.rows.length} products found  •  '
          '${validation.errorRowCount} with errors  •  '
          '${validation.warningRowCount} with warnings',
        ),
        const SizedBox(height: 10),
        for (final row in shown)
          Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color:
                  row.hasErrors
                      ? Colors.red.shade50
                      : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Row ${row.rowNumber}'
                  '${row.name.isEmpty ? '' : ' – ${row.name}'}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                for (final e in row.errors)
                  Text(
                    e,
                    style: TextStyle(
                      color: Colors.red.shade700,
                    ),
                  ),
                for (final w in row.warnings)
                  Text(
                    w,
                    style: TextStyle(
                      color: Colors.orange.shade900,
                    ),
                  ),
              ],
            ),
          ),
        if (problems.length > shown.length)
          Text(
            '…and ${problems.length - shown.length} more rows with issues.',
          ),
        const SizedBox(height: 15),
      ],
    ];
  }
}
