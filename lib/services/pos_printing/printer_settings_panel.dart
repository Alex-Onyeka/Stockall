import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/constants/constants_main.dart' show mobileScreen;
import 'package:stockall/main.dart' show returnShopProvider, returnTheme;
import 'package:stockall/providers/printer_settings_provider.dart';
import 'package:stockall/services/pos_printing/pos_print_rules.dart';
import 'package:stockall/services/pos_printing/pos_printer_sources.dart';
import 'package:stockall/services/pos_printing/pos_transports.dart'
    show currentPosPlatform;

// The Printer Settings panel: the roll printer and its options, and the
// A4 printer, all saved on this device (PrinterSettingsProvider). Changes
// save as they are made.

enum PrinterSettingsFocus { roll, a4 }

// The shop's default roll width (1 = 58mm, 2 = 80mm), for devices that
// have none of their own.
int? shopDefaultPrintType() {
  try {
    return returnShopProvider().userShop()?.printType;
  } catch (_) {
    return null;
  }
}

// On Windows with no roll printer saved yet, start from the receipt
// printer the app used before (ReceiptPrinterClass).
Future<void> seedRollPrinterIfNeeded(PosPlatform platform) async {
  final settings = PrinterSettingsProvider();
  await settings.ensureLoaded();
  if (settings.rollPrinter != null || platform != PosPlatform.windows) return;
  try {
    final legacy = returnShopProvider().getReceiptPrinter();
    final seeded = seedPosPrinter(
      platform: platform,
      windowsPrinterName: legacy?.printerName,
      windowsPaperSize: legacy?.printerSize,
      shopPrintType: shopDefaultPrintType(),
    );
    if (seeded != null) {
      await settings.setRollPrinter(
        seeded,
        shopPrintType: shopDefaultPrintType(),
      );
    }
  } catch (_) {}
}

// Opens the panel: a dialog on wide screens, a bottom sheet on phones.
Future<void> openPrinterSettings(
  BuildContext context, {
  PrinterSettingsFocus focus = PrinterSettingsFocus.roll,
}) async {
  final platform = currentPosPlatform();
  await seedRollPrinterIfNeeded(platform);
  if (!context.mounted) return;
  final panel = PrinterSettingsPanel(
    platform: platform,
    focus: focus,
    shopPrintType: shopDefaultPrintType(),
  );
  if (MediaQuery.sizeOf(context).width < mobileScreen) {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder:
          (sheetContext) => SafeArea(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.85,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Printer Settings',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(sheetContext).pop(),
                          child: const Text('Done'),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        16,
                        0,
                        16,
                        16 + MediaQuery.viewInsetsOf(sheetContext).bottom,
                      ),
                      child: panel,
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
    return;
  }
  await showDialog<void>(
    context: context,
    builder:
        (dialogContext) => DialogTemplate(
          theme: returnTheme(dialogContext, listen: false),
          title: 'Printer Settings',
          message: 'The printers this device prints to',
          action: () {},
          showMainBottomActionButton: false,
          cancelText: 'Done',
          widget: SizedBox(
            width: 500,
            child: SingleChildScrollView(child: panel),
          ),
        ),
  );
}

class PrinterSettingsPanel extends StatefulWidget {
  final PosPlatform platform;
  final PrinterSettingsFocus focus;
  final int? shopPrintType;

  // Lists the A4 printers on desktop. Replaceable in tests.
  final Future<List<Printer>> Function() listA4Printers;

  // The roll printers to choose from (PosPrinterSources). Replaceable in
  // tests.
  final Widget Function(
    PosPrinterConfig? current,
    ValueChanged<PosPrinterChoice> onPick,
  )?
  rollSourcesBuilder;

  const PrinterSettingsPanel({
    super.key,
    required this.platform,
    this.focus = PrinterSettingsFocus.roll,
    this.shopPrintType,
    this.listA4Printers = Printing.listPrinters,
    this.rollSourcesBuilder,
  });

  @override
  State<PrinterSettingsPanel> createState() => _PrinterSettingsPanelState();
}

class _PrinterSettingsPanelState extends State<PrinterSettingsPanel> {
  final PrinterSettingsProvider _settings = PrinterSettingsProvider();
  Future<List<Printer>>? _a4Printers;

  bool get _isWeb => widget.platform == PosPlatform.web;

  @override
  void initState() {
    super.initState();
    _settings.ensureLoaded();
    if (canListA4Printers(widget.platform)) _a4Printers = _listA4();
  }

  Future<List<Printer>> _listA4() async {
    try {
      final printers = await widget.listA4Printers();
      return [
        for (final p in printers)
          if (p.isAvailable) p,
      ];
    } catch (_) {
      return const [];
    }
  }

  RollOptions get _options =>
      _settings.rollOptions(shopPrintType: widget.shopPrintType);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _settings,
      builder: (context, _) {
        final roll = _rollSection(context);
        final a4 = _isWeb ? null : _a4Section(context);
        final sections =
            widget.focus == PrinterSettingsFocus.a4 && a4 != null
                ? [a4, roll]
                : [roll, if (a4 != null) a4];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < sections.length; i++) ...[
              if (i > 0) const Divider(height: 32, thickness: 1.5),
              sections[i],
            ],
          ],
        );
      },
    );
  }

  // ------------------------------------------------------------------
  // Receipt roll

  Widget _rollSection(BuildContext context) {
    final theme = returnTheme(context, listen: false);
    final options = _options;
    final printer = _settings.rollPrinter;
    return Column(
      key: const ValueKey('printer-settings-roll'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _heading('Receipt roll printer'),
        if (_isWeb)
          _note(
            'Your browser asks which printer to use each time you print. '
            'Choose the roll width below.',
          )
        else ...[
          _currentTile(
            key: const ValueKey('printer-settings-roll-current'),
            name: printer?.name,
            subtitle: printer == null ? null : _transportLabel(printer),
            empty: 'No roll printer selected. Choose one below.',
          ),
        ],
        _subheading('Roll paper'),
        Wrap(
          spacing: 8,
          children: [
            for (final paper in PosPaper.values)
              ChoiceChip(
                key: ValueKey('printer-settings-paper-${paper.name}'),
                label: Text(
                  paper.label,
                  style: TextStyle(fontSize: theme.mobileTexts.b4.fontSize),
                ),
                selected: options.paper == paper,
                onSelected:
                    (_) => _settings.setRollOptions(
                      options.copyWith(paper: paper),
                    ),
              ),
          ],
        ),
        if (!_isWeb)
          SwitchListTile(
            key: const ValueKey('printer-settings-cut'),
            contentPadding: EdgeInsets.zero,
            title: Text(
              'Cut paper after print',
              style: TextStyle(fontSize: theme.mobileTexts.b3.fontSize),
            ),
            value: options.cut,
            onChanged:
                (value) =>
                    _settings.setRollOptions(options.copyWith(cut: value)),
          ),
        if (!_isWeb) ...[
          _subheading('Other printers'),
          widget.rollSourcesBuilder?.call(printer, _pickRoll) ??
              PosPrinterSources(
                platform: widget.platform,
                current: printer,
                onPick: _pickRoll,
              ),
        ],
      ],
    );
  }

  void _pickRoll(PosPrinterChoice choice) {
    final options = _options;
    _settings.setRollPrinter(
      PosPrinterConfig(
        transport: choice.transport,
        address: choice.address,
        name: choice.name,
        port: choice.port,
        paper: options.paper,
        cut: options.cut,
      ),
      shopPrintType: widget.shopPrintType,
    );
  }

  String _transportLabel(PosPrinterConfig printer) {
    switch (printer.transport) {
      case PosTransport.bluetooth:
        return 'Bluetooth · ${printer.address}';
      case PosTransport.network:
        return 'Network · ${printer.address}:${printer.port ?? defaultNetworkPort}';
      case PosTransport.windowsSpooler:
      case PosTransport.cups:
        return 'Installed printer';
    }
  }

  // ------------------------------------------------------------------
  // A4

  Widget _a4Section(BuildContext context) {
    final printer = _settings.a4Printer;
    return Column(
      key: const ValueKey('printer-settings-a4'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _heading('A4 printer'),
        if (!canDirectPrintA4(widget.platform))
          _note(
            'Android asks which printer to use each time you print an A4 '
            'document, in the system print dialog.',
          )
        else ...[
          _currentTile(
            key: const ValueKey('printer-settings-a4-current'),
            name: printer?.name,
            subtitle: printer == null ? null : 'A4 documents print here',
            empty:
                canPickA4Printer(widget.platform)
                    ? 'No A4 printer selected. Choose an AirPrint printer below.'
                    : 'No A4 printer selected. Choose one below.',
            onClear:
                printer == null ? null : () => _settings.setA4Printer(null),
          ),
          if (canPickA4Printer(widget.platform))
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: FilledButton.icon(
                  icon: const Icon(Icons.print_outlined, size: 18),
                  label: const Text('Choose AirPrint printer'),
                  onPressed: _pickAirPrint,
                ),
              ),
            ),
          if (canListA4Printers(widget.platform)) ...[
            _subheading(
              'Other printers',
              trailing: IconButton(
                tooltip: 'Search again',
                icon: const Icon(Icons.refresh, size: 20),
                onPressed: () => setState(() => _a4Printers = _listA4()),
              ),
            ),
            FutureBuilder<List<Printer>>(
              future: _a4Printers,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return _note('Looking for printers…');
                }
                final printers = snapshot.data ?? const <Printer>[];
                if (printers.isEmpty) {
                  return _note(
                    'No printers are installed on this computer. Install '
                    'the printer first, then search again.',
                  );
                }
                return Column(
                  children: [
                    for (final p in printers)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: _a4Tile(context, p, printer),
                      ),
                  ],
                );
              },
            ),
          ],
        ],
      ],
    );
  }

  Future<void> _pickAirPrint() async {
    try {
      final picked = await Printing.pickPrinter(context: context);
      if (picked == null) return;
      await _settings.setA4Printer(
        A4PrinterConfig(url: picked.url, name: picked.name),
      );
    } catch (_) {}
  }

  Widget _a4Tile(
    BuildContext context,
    Printer printer,
    A4PrinterConfig? current,
  ) {
    final selected = current?.url == printer.url;
    final theme = returnTheme(context, listen: false);
    return ListTile(
      key: ValueKey('printer-settings-a4-${printer.url}'),
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      tileColor: selected ? Colors.grey.shade200 : Colors.grey.shade50,
      leading: const Icon(Icons.print_outlined, size: 18),
      title: Text(
        printer.name,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: theme.mobileTexts.b3.fontSize,
        ),
      ),
      subtitle:
          printer.isDefault
              ? Text(
                'System default',
                style: TextStyle(
                  fontSize: theme.mobileTexts.b4.fontSize,
                  color: Colors.grey,
                ),
              )
              : null,
      trailing: selected ? const Icon(Icons.check, size: 16) : null,
      onTap:
          () => _settings.setA4Printer(
            A4PrinterConfig(url: printer.url, name: printer.name),
          ),
    );
  }

  // ------------------------------------------------------------------
  // Shared pieces

  Widget _heading(String text) => Padding(
    padding: const EdgeInsets.only(top: 4, bottom: 8),
    child: Text(
      text,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
    ),
  );

  Widget _subheading(String text, {Widget? trailing}) => Padding(
    padding: const EdgeInsets.only(top: 12, bottom: 6),
    child: Row(
      children: [
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ),
        if (trailing != null) trailing,
      ],
    ),
  );

  Widget _note(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text(text, style: TextStyle(color: Colors.grey.shade700)),
  );

  // The selected printer, at the top of its section.
  Widget _currentTile({
    required Key key,
    required String? name,
    required String? subtitle,
    required String empty,
    VoidCallback? onClear,
  }) {
    if (name == null) return _note(empty);
    return ListTile(
      key: key,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      tileColor: Colors.green.shade50,
      leading: const Icon(Icons.check_circle, color: Colors.green, size: 20),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: subtitle == null ? null : Text(subtitle),
      trailing:
          onClear == null
              ? null
              : IconButton(
                tooltip: 'Remove',
                icon: const Icon(Icons.close, size: 18),
                onPressed: onClear,
              ),
    );
  }
}
