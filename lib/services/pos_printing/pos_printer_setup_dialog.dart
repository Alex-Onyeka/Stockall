import 'package:flutter/material.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/main.dart' show returnTheme;
import 'package:stockall/services/pos_printing/pos_print_rules.dart';
import 'package:stockall/services/pos_printing/pos_printer_sources.dart';

// Choose the POS printer for this device: the printers this platform can
// reach, the paper size and whether to cut. Returns the printer, or null
// when cancelled. Picking a printer returns at once, so printing goes on
// straight after.
Future<PosPrinterConfig?> showPosPrinterSetup(
  BuildContext context, {
  required PosPlatform platform,
  required PosPaper paper,
  bool? cut,
  PosPrinterConfig? current,
}) {
  return showDialog<PosPrinterConfig>(
    context: context,
    builder:
        (_) => _PosPrinterSetupDialog(
          platform: platform,
          paper: paper,
          cut: cut,
          current: current,
        ),
  );
}

class _PosPrinterSetupDialog extends StatefulWidget {
  final PosPlatform platform;
  final PosPaper paper;
  final bool? cut;
  final PosPrinterConfig? current;

  const _PosPrinterSetupDialog({
    required this.platform,
    required this.paper,
    this.cut,
    this.current,
  });

  @override
  State<_PosPrinterSetupDialog> createState() =>
      _PosPrinterSetupDialogState();
}

class _PosPrinterSetupDialogState
    extends State<_PosPrinterSetupDialog> {
  late final List<PosTransport> _transports = transportsFor(
    widget.platform,
  );

  late PosPaper _paper = widget.paper;
  late bool _cut =
      widget.cut ??
      widget.current?.cut ??
      (_transports.isNotEmpty
          ? defaultCut(_transports.first)
          : false);

  void _pick(PosPrinterChoice choice) {
    Navigator.of(context).pop(
      PosPrinterConfig(
        transport: choice.transport,
        address: choice.address,
        name: choice.name,
        port: choice.port,
        paper: _paper,
        cut: _cut,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context, listen: false);
    return DialogTemplate(
      theme: theme,
      message: 'Set the Printer below',
      title: 'Choose your POS Printer',
      action: () {},
      showMainBottomActionButton: false,
      widget: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              _sectionTitle('Paper size'),
              Wrap(
                spacing: 8,
                children: [
                  for (final paper in PosPaper.values)
                    ChoiceChip(
                      label: Text(
                        paper.label,
                        style: TextStyle(
                          fontSize:
                              theme.mobileTexts.b4.fontSize,
                        ),
                      ),
                      selected: _paper == paper,
                      onSelected:
                          (_) => setState(() => _paper = paper),
                    ),
                ],
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Cut the paper after printing',
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b3.fontSize,
                  ),
                ),
                value: _cut,
                onChanged:
                    (value) => setState(() => _cut = value),
              ),
              const Divider(),
              // Keep the saved printer with the paper and cut above (it may
              // not show up in a Bluetooth search right now).
              if (widget.current != null) ...[
                _sectionTitle('Current printer'),
                ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                  ),
                  tileColor: Colors.grey.shade200,
                  leading: const Icon(
                    Icons.check_circle_outline,
                    size: 20,
                  ),
                  title: Text(
                    widget.current!.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: const Text('Keep this printer'),
                  trailing: const Icon(
                    Icons.chevron_right,
                    size: 18,
                  ),
                  onTap:
                      () => Navigator.of(context).pop(
                        keepPrinter(
                          widget.current!,
                          paper: _paper,
                          cut: _cut,
                        ),
                      ),
                ),
                const Divider(),
              ],
              PosPrinterSources(
                platform: widget.platform,
                current: widget.current,
                onPick: _pick,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) => Padding(
    padding: const EdgeInsets.only(top: 8, bottom: 6),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
