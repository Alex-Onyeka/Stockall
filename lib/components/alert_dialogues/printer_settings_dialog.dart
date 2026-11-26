import 'dart:async';

import 'package:bluetooth_print_plus/bluetooth_print_plus.dart'
    show BluetoothDevice, BluetoothPrintPlus;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/discount_setter.dart/discount_setter_widget.dart';
import 'package:stockall/main.dart' show returnTheme;
import 'package:stockall/services/pos_printing/bluetooth_permission_helper.dart'
    show ensureBluetoothPermissions;
import 'package:stockall/services/pos_printing/pos_print_rules.dart';
import 'package:stockall/services/printing/app_printer_service.dart';

/// Opens the global Printer Settings dialog using [DialogTemplate].
/// Returns the saved [AppPrinterSettings], or `null` if cancelled.
Future<AppPrinterSettings?> showPrinterSettingsDialog(
  BuildContext context,
) {
  return showDialog<AppPrinterSettings>(
    context: context,
    builder: (_) => const PrinterSettingsDialog(),
  );
}

class PrinterSettingsDialog extends StatefulWidget {
  const PrinterSettingsDialog({super.key});

  @override
  State<PrinterSettingsDialog> createState() =>
      _PrinterSettingsDialogState();
}

class _PrinterSettingsDialogState
    extends State<PrinterSettingsDialog> {
  bool _loadingSettings = true;
  bool _loadingPrinters = true;
  bool _saving = false;

  String? _selectedPrinterName;
  String? _selectedPrinterUrl;
  AppPrintDocumentType _documentType = AppPrintDocumentType.roll;
  PosPaper _paper = PosPaper.mm58;
  bool _cutPaper = true;
  List<Printer> _systemPrinters = [];
  StreamSubscription<List<BluetoothDevice>>? _btSubscription;
  List<BluetoothDevice> _bluetoothDevices = [];

  bool get _isMobile => AppPrinterService.isMobileNative;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final settings = await AppPrinterService.loadSettings();
    if (!mounted) return;
    setState(() {
      _selectedPrinterName =
          settings.hasPrinter ? settings.printerName : null;
      _selectedPrinterUrl =
          settings.hasPrinter ? settings.printerUrl : null;
      _documentType = settings.documentType;
      _paper = settings.paper;
      _cutPaper = settings.cutPaper;
      _loadingSettings = false;
    });
    await _loadPrinters();
  }

  @override
  void dispose() {
    _btSubscription?.cancel();
    try {
      if (_isMobile && BluetoothPrintPlus.isScanningNow) {
        BluetoothPrintPlus.stopScan();
      }
    } catch (_) {}
    super.dispose();
  }

  Future<void> _loadPrinters() async {
    if (mounted) {
      setState(() => _loadingPrinters = true);
    }
    if (_isMobile) {
      try {
        final hasPermission =
            await ensureBluetoothPermissions();
        if (!hasPermission) {
          if (mounted) {
            setState(() => _loadingPrinters = false);
          }
          return;
        }
        _btSubscription ??= BluetoothPrintPlus.scanResults
            .listen((devices) {
          if (mounted) {
            setState(() => _bluetoothDevices = devices);
          }
        });
        if (!BluetoothPrintPlus.isBlueOn) {
          if (mounted) {
            setState(() => _loadingPrinters = false);
          }
          return;
        }
        await BluetoothPrintPlus.startScan(
          timeout: const Duration(seconds: 8),
        );
      } catch (_) {}
      if (mounted) setState(() => _loadingPrinters = false);
      return;
    }

    final printers =
        await AppPrinterService.listSystemPrinters();
    if (!mounted) return;
    setState(() {
      _systemPrinters = printers;
      _loadingPrinters = false;
    });
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    final updated = AppPrinterSettings(
      printerName: _selectedPrinterName,
      printerUrl: _selectedPrinterUrl,
      documentType: _documentType,
      paper: _paper,
      cutPaper: _cutPaper,
    );
    await AppPrinterService.saveSettings(updated);
    if (!mounted) return;
    Navigator.of(context).pop(updated);
  }

  @override
  Widget build(BuildContext context) {
    final theme = returnTheme(context, listen: false);
    final primaryColor = theme.lightModeColor.prColor300;
    final hasSelected =
        _selectedPrinterName != null &&
        _selectedPrinterName!.trim().isNotEmpty;

    return DialogTemplate(
      theme: theme,
      title: 'Printer Settings',
      message:
          'Select your default printer and receipt roll settings.',
      actionButtonText: _saving ? 'Saving...' : 'Save',
      action: _save,
      topRightWidget: IconButton(
        tooltip: 'Refresh Printers',
        mouseCursor: SystemMouseCursors.click,
        onPressed: _loadingPrinters ? null : _loadPrinters,
        icon: Icon(
          Icons.refresh,
          size: 20,
          color:
              _loadingPrinters
                  ? Colors.grey.shade400
                  : Colors.grey.shade700,
        ),
      ),
      widget: SizedBox(
        width: 500,
        child:
            _loadingSettings
                ? const Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 40,
                  ),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
                : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 1. Currently Selected Printer
                      _sectionHeader(
                        'Currently Selected Printer',
                        theme.mobileTexts.b3.fontSize,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(8),
                          color:
                              hasSelected
                                  ? primaryColor.withValues(
                                    alpha: 0.08,
                                  )
                                  : Colors.grey.shade100,
                          border: Border.all(
                            color:
                                hasSelected
                                    ? primaryColor
                                    : Colors.grey.shade300,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              hasSelected
                                  ? Icons.print_rounded
                                  : Icons
                                      .print_disabled_outlined,
                              size: 20,
                              color:
                                  hasSelected
                                      ? primaryColor
                                      : Colors
                                          .grey
                                          .shade600,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Text(
                                    hasSelected
                                        ? _selectedPrinterName!
                                        : 'No Printer Selected',
                                    style: TextStyle(
                                      fontSize:
                                          theme
                                              .mobileTexts
                                              .b3
                                              .fontSize,
                                      fontWeight:
                                          FontWeight.bold,
                                      color:
                                          hasSelected
                                              ? Colors
                                                  .grey
                                                  .shade900
                                              : Colors
                                                  .grey
                                                  .shade600,
                                    ),
                                  ),
                                  Text(
                                    hasSelected
                                        ? 'Used as default across the app'
                                        : 'System print dialog will be used',
                                    style: TextStyle(
                                      fontSize:
                                          theme
                                              .mobileTexts
                                              .b4
                                              .fontSize,
                                      color:
                                          Colors
                                              .grey
                                              .shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (hasSelected)
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedPrinterName =
                                        null;
                                    _selectedPrinterUrl =
                                        null;
                                  });
                                },
                                child: Text(
                                  'Clear',
                                  style: TextStyle(
                                    fontSize:
                                        theme
                                            .mobileTexts
                                            .b4
                                            .fontSize,
                                    color:
                                        theme
                                            .lightModeColor
                                            .errorColor200,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // 2. List of printers in the system (or Bluetooth on Mobile)
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          _sectionHeader(
                            _isMobile
                                ? 'Bluetooth Printers'
                                : 'System Printers',
                            theme.mobileTexts.b3.fontSize,
                          ),
                          if (_loadingPrinters)
                            const SizedBox(
                              width: 14,
                              height: 14,
                              child:
                                  CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      if (kIsWeb)
                        _emptyHint(
                          'In web browsers, select your printer in the browser print dialog when printing.',
                          theme.mobileTexts.b4.fontSize,
                        )
                      else if (_isMobile &&
                          !BluetoothPrintPlus.isBlueOn)
                        _emptyHint(
                          'Bluetooth is turned off. Turn on Bluetooth and tap refresh to scan for printers.',
                          theme.mobileTexts.b4.fontSize,
                        )
                      else if (_loadingPrinters &&
                          (_isMobile
                              ? _bluetoothDevices.isEmpty
                              : _systemPrinters.isEmpty))
                        _emptyHint(
                          _isMobile
                              ? 'Scanning for Bluetooth printers...'
                              : 'Searching for system printers...',
                          theme.mobileTexts.b4.fontSize,
                        )
                      else if (_isMobile &&
                          _bluetoothDevices.isEmpty)
                        _emptyHint(
                          'No Bluetooth printers found nearby. Ensure your printer is turned on and tap refresh.',
                          theme.mobileTexts.b4.fontSize,
                        )
                      else if (!_isMobile &&
                          _systemPrinters.isEmpty)
                        _emptyHint(
                          'No printers found on this system. Connect or install a printer and tap refresh.',
                          theme.mobileTexts.b4.fontSize,
                        )
                      else if (_isMobile)
                        Container(
                          constraints: const BoxConstraints(
                            maxHeight: 200,
                          ),
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.grey.shade300,
                            ),
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount:
                                _bluetoothDevices.length,
                            separatorBuilder:
                                (_, __) => Divider(
                                  height: 1,
                                  color:
                                      Colors.grey.shade200,
                                ),
                            itemBuilder: (context, index) {
                              final device =
                                  _bluetoothDevices[index];
                              final deviceName =
                                  device.name.isEmpty
                                      ? device.address
                                      : device.name;
                              final isSelected =
                                  _selectedPrinterUrl ==
                                      device.address ||
                                  _selectedPrinterName ==
                                      deviceName;
                              return InkWell(
                                mouseCursor:
                                    SystemMouseCursors
                                        .click,
                                onTap: () {
                                  setState(() {
                                    _selectedPrinterName =
                                        deviceName;
                                    _selectedPrinterUrl =
                                        device.address;
                                    _documentType =
                                        AppPrintDocumentType
                                            .roll;
                                  });
                                },
                                child: Container(
                                  color:
                                      isSelected
                                          ? primaryColor
                                              .withValues(
                                                alpha: 0.08,
                                              )
                                          : Colors
                                              .transparent,
                                  padding:
                                      const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.bluetooth,
                                        size: 18,
                                        color:
                                            isSelected
                                                ? primaryColor
                                                : Colors
                                                    .grey
                                                    .shade700,
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,
                                          children: [
                                            Text(
                                              deviceName,
                                              style: TextStyle(
                                                fontSize:
                                                    theme
                                                        .mobileTexts
                                                        .b3
                                                        .fontSize,
                                                fontWeight:
                                                    isSelected
                                                        ? FontWeight.bold
                                                        : FontWeight.w500,
                                              ),
                                            ),
                                            Text(
                                              device.address,
                                              style: TextStyle(
                                                fontSize:
                                                    theme
                                                        .mobileTexts
                                                        .b4
                                                        .fontSize,
                                                color:
                                                    Colors
                                                        .grey
                                                        .shade600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (isSelected)
                                        Icon(
                                          Icons
                                              .check_circle,
                                          size: 18,
                                          color:
                                              primaryColor,
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        )
                      else
                        Container(
                          constraints: const BoxConstraints(
                            maxHeight: 200,
                          ),
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.grey.shade300,
                            ),
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount:
                                _systemPrinters.length,
                            separatorBuilder:
                                (_, __) => Divider(
                                  height: 1,
                                  color:
                                      Colors.grey.shade200,
                                ),
                            itemBuilder: (context, index) {
                              final printer =
                                  _systemPrinters[index];
                              final isSelected =
                                  _selectedPrinterName ==
                                  printer.name;
                              return InkWell(
                                mouseCursor:
                                    SystemMouseCursors
                                        .click,
                                onTap: () {
                                  final detected =
                                      AppPrinterService
                                          .detectDocumentTypeForPrinter(
                                        printer,
                                      );
                                  setState(() {
                                    _selectedPrinterName =
                                        printer.name;
                                    _selectedPrinterUrl =
                                        printer.url;
                                    if (detected != null) {
                                      _documentType =
                                          detected;
                                    }
                                  });
                                },
                                child: Container(
                                  color:
                                      isSelected
                                          ? primaryColor
                                              .withValues(
                                                alpha: 0.08,
                                              )
                                          : Colors
                                              .transparent,
                                  padding:
                                      const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 10,
                                      ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons
                                            .print_outlined,
                                        size: 18,
                                        color:
                                            isSelected
                                                ? primaryColor
                                                : Colors
                                                    .grey
                                                    .shade700,
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,
                                          children: [
                                            Text(
                                              printer.name,
                                              style: TextStyle(
                                                fontSize:
                                                    theme
                                                        .mobileTexts
                                                        .b3
                                                        .fontSize,
                                                fontWeight:
                                                    isSelected
                                                        ? FontWeight.bold
                                                        : FontWeight.w500,
                                              ),
                                            ),
                                            if (printer
                                                .isDefault)
                                              Text(
                                                'System Default',
                                                style: TextStyle(
                                                  fontSize:
                                                      theme
                                                          .mobileTexts
                                                          .b4
                                                          .fontSize,
                                                  color:
                                                      Colors
                                                          .grey
                                                          .shade600,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      if (isSelected)
                                        Icon(
                                          Icons
                                              .check_circle,
                                          size: 18,
                                          color:
                                              primaryColor,
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                      // const SizedBox(height: 16),
                      // Divider(color: Colors.grey.shade200),
                      if (!_isMobile) ...[
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: DiscountSelectionTab(
                                genNum:
                                    _documentType ==
                                            AppPrintDocumentType
                                                .a4
                                        ? 0
                                        : 1,
                                title: 'A4 Document',
                                action: () {
                                  setState(
                                    () =>
                                        _documentType =
                                            AppPrintDocumentType
                                                .a4,
                                  );
                                },
                                myNum: 0,
                                theme: theme,
                              ),
                            ),
                            Expanded(
                              child: DiscountSelectionTab(
                                genNum:
                                    _documentType ==
                                            AppPrintDocumentType
                                                .a4
                                        ? 0
                                        : 1,
                                title: 'Receipt Roll',
                                action: () {
                                  setState(
                                    () =>
                                        _documentType =
                                            AppPrintDocumentType
                                                .roll,
                                  );
                                },
                                myNum: 1,
                                theme: theme,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (_isMobile ||
                          _documentType ==
                              AppPrintDocumentType.roll) ...[
                        const SizedBox(height: 16),
                        _sectionHeader(
                          'Receipt Roll Printer Settings',
                          theme.mobileTexts.b3.fontSize,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Paper Roll Size',
                          style: TextStyle(
                            fontSize:
                                theme.mobileTexts.b4.fontSize,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _radioOptionTile(
                                isSelected:
                                    _paper == PosPaper.mm58,
                                label: '58mm',
                                primaryColor: primaryColor,
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .b3
                                        .fontSize,
                                onTap:
                                    () => setState(
                                      () =>
                                          _paper =
                                              PosPaper.mm58,
                                    ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _radioOptionTile(
                                isSelected:
                                    _paper == PosPaper.mm80,
                                label: '80mm',
                                primaryColor: primaryColor,
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .b3
                                        .fontSize,
                                onTap:
                                    () => setState(
                                      () =>
                                          _paper =
                                              PosPaper.mm80,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        if (!kIsWeb) ...[
                          const SizedBox(height: 8),
                          CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            controlAffinity:
                                ListTileControlAffinity.leading,
                            activeColor: primaryColor,
                            title: Text(
                              'Cut paper roll after printing',
                              style: TextStyle(
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .b3
                                        .fontSize,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            value: _cutPaper,
                            onChanged: (val) {
                              setState(
                                () => _cutPaper = val ?? false,
                              );
                            },
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
      ),
    );
  }

  Widget _sectionHeader(String title, double? fontSize) {
    return Text(
      title,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade900,
      ),
    );
  }

  Widget _emptyHint(String text, double? fontSize) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade100,
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _radioOptionTile({
    required bool isSelected,
    required String label,
    required Color primaryColor,
    required double? fontSize,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        mouseCursor: SystemMouseCursors.click,
        borderRadius: BorderRadius.circular(6),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 10,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color:
                isSelected
                    ? primaryColor.withValues(alpha: 0.1)
                    : Colors.grey.shade100,
            border: Border.all(
              color:
                  isSelected
                      ? primaryColor
                      : Colors.grey.shade300,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                size: 18,
                color:
                    isSelected
                        ? primaryColor
                        : Colors.grey.shade600,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight:
                      isSelected
                          ? FontWeight.bold
                          : FontWeight.w500,
                  color:
                      isSelected
                          ? primaryColor
                          : Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
