import 'dart:async';

import 'package:bluetooth_print_plus/bluetooth_print_plus.dart'
    show BluetoothDevice, BluetoothPrintPlus;
import 'package:flutter/material.dart';
import 'package:stockall/main.dart'
    show returnShopProvider, returnTheme;
import 'package:stockall/services/barcode_generation/barcode_import_helper.dart'
    show listPrinters;
import 'package:stockall/services/pos_printing/pos_print_rules.dart';
import 'package:stockall/services/pos_printing/pos_transports.dart'
    show listCupsQueues;

// Choose the POS printer for this device: the printers this platform can
// reach, the paper size and whether to cut. Returns the printer, or null
// when cancelled. Picking a printer returns at once, so printing goes on
// straight after.
Future<PosPrinterConfig?> showPosPrinterSetup(
  BuildContext context, {
  required PosPlatform platform,
  required PosPaper paper,
  PosPrinterConfig? current,
}) {
  return showDialog<PosPrinterConfig>(
    context: context,
    builder:
        (_) => _PosPrinterSetupDialog(
          platform: platform,
          paper: paper,
          current: current,
        ),
  );
}

class _PosPrinterSetupDialog extends StatefulWidget {
  final PosPlatform platform;
  final PosPaper paper;
  final PosPrinterConfig? current;

  const _PosPrinterSetupDialog({
    required this.platform,
    required this.paper,
    this.current,
  });

  @override
  State<_PosPrinterSetupDialog> createState() =>
      _PosPrinterSetupDialogState();
}

class _PosPrinterSetupDialogState
    extends State<_PosPrinterSetupDialog> {
  late PosPaper _paper = widget.paper;
  late bool _cut =
      widget.current?.cut ??
      defaultCut(transportsFor(widget.platform).first);

  late final List<PosTransport> _transports = transportsFor(
    widget.platform,
  );

  // Bluetooth
  StreamSubscription<List<BluetoothDevice>>?
  _scanSubscription;
  List<BluetoothDevice> _bluetoothDevices = [];
  bool _scanning = false;

  // Installed printers (Windows) or print queues (macOS/Linux)
  Future<List<String>>? _installed;

  // Network
  late final TextEditingController _host =
      TextEditingController(
        text:
            widget.current?.transport ==
                    PosTransport.network
                ? widget.current!.address
                : '',
      );
  late final TextEditingController _port =
      TextEditingController(
        text:
            '${widget.current?.port ?? defaultNetworkPort}',
      );
  String? _networkError;

  @override
  void initState() {
    super.initState();
    if (_transports.contains(PosTransport.bluetooth)) {
      _scanSubscription = BluetoothPrintPlus.scanResults
          .listen((devices) {
            if (mounted)
              setState(() => _bluetoothDevices = devices);
          });
      _scan();
    }
    if (_transports.contains(PosTransport.windowsSpooler)) {
      _installed = _windowsPrinters();
    }
    if (_transports.contains(PosTransport.cups)) {
      _installed = listCupsQueues();
    }
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    if (_scanning) BluetoothPrintPlus.stopScan();
    _host.dispose();
    _port.dispose();
    super.dispose();
  }

  Future<void> _scan() async {
    if (!BluetoothPrintPlus.isBlueOn) {
      setState(() {});
      return;
    }
    setState(() => _scanning = true);
    try {
      await BluetoothPrintPlus.startScan(
        timeout: const Duration(seconds: 8),
      );
    } catch (_) {
      // The list stays as it is; the user can scan again.
    }
    if (mounted) setState(() => _scanning = false);
  }

  Future<List<String>> _windowsPrinters() async {
    try {
      listPrinters();
    } catch (_) {
      return const [];
    }
    return [
      for (final printer in returnShopProvider().printers)
        printer.name,
    ];
  }

  void _pick(
    PosTransport transport,
    String address,
    String name, {
    int? port,
  }) {
    Navigator.of(context).pop(
      PosPrinterConfig(
        transport: transport,
        address: address,
        name: name,
        port: port,
        paper: _paper,
        cut: _cut,
      ),
    );
  }

  bool _isCurrent(PosTransport transport, String address) =>
      widget.current?.transport == transport &&
      widget.current?.address == address;

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context, listen: false);
    final width = MediaQuery.of(context).size.width;
    return AlertDialog(
      backgroundColor: Colors.white,
      title: const Text(
        'Choose your POS printer',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SizedBox(
        width: width < 480 ? width - 40 : 440,
        child: ListView(
          shrinkWrap: true,
          children: [
            _sectionTitle('Paper size'),
            Wrap(
              spacing: 8,
              children: [
                for (final paper in PosPaper.values)
                  ChoiceChip(
                    label: Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b4.fontSize,
                      ),
                      paper.label,
                    ),
                    selected: _paper == paper,
                    onSelected:
                        (_) =>
                            setState(() => _paper = paper),
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
            for (final transport in _transports) ...[
              _section(transport),
              const Divider(),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  Widget _sectionTitle(String text, {Widget? trailing}) =>
      Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 6),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      );

  Widget _printerTile(
    PosTransport transport,
    String address,
    String name, {
    String? subtitle,
    IconData icon = Icons.print_outlined,
  }) {
    final current = _isCurrent(transport, address);
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 8,
      ),
      tileColor:
          current
              ? Colors.grey.shade200
              : Colors.grey.shade50,
      leading: Icon(icon, size: 18),
      title: Text(
        name,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize:
              returnTheme(
                context,
                listen: false,
              ).mobileTexts.b3.fontSize,
        ),
      ),
      subtitle:
          subtitle == null
              ? null
              : Text(
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize:
                      returnTheme(
                        context,
                        listen: false,
                      ).mobileTexts.b4.fontSize,
                  color: Colors.grey,
                ),
                subtitle,
              ),
      trailing:
          current
              ? const Icon(Icons.check, size: 16)
              : null,
      onTap: () => _pick(transport, address, name),
    );
  }

  Widget _hint(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Text(
      text,
      style: TextStyle(color: Colors.grey.shade700),
    ),
  );

  Widget _section(PosTransport transport) {
    switch (transport) {
      case PosTransport.bluetooth:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _sectionTitle(
              'Bluetooth printers',
              trailing:
                  _scanning
                      ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                      : IconButton(
                        tooltip: 'Search again',
                        icon: const Icon(
                          Icons.refresh,
                          size: 20,
                        ),
                        onPressed: _scan,
                      ),
            ),
            if (!BluetoothPrintPlus.isBlueOn)
              _hint(
                'Bluetooth is off. Turn it on, then search again.',
              )
            else if (_bluetoothDevices.isEmpty)
              _hint(
                _scanning
                    ? 'Searching for printers…'
                    : 'No printers found. Check the printer is on and nearby.',
              ),
            for (final device in _bluetoothDevices)
              _printerTile(
                PosTransport.bluetooth,
                device.address,
                device.name.isEmpty
                    ? device.address
                    : device.name,
                subtitle: device.address,
                icon: Icons.bluetooth,
              ),
          ],
        );
      case PosTransport.windowsSpooler:
      case PosTransport.cups:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _sectionTitle('Installed printers'),
            FutureBuilder<List<String>>(
              future: _installed,
              builder: (context, snapshot) {
                if (snapshot.connectionState !=
                    ConnectionState.done) {
                  return _hint('Looking for printers…');
                }
                final names = snapshot.data ?? const [];
                if (names.isEmpty) {
                  return _hint(
                    'No printers are installed on this computer. Install '
                    'the printer first, or use a network printer below.',
                  );
                }
                return Column(
                  children: [
                    for (final name in names)
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: 4,
                        ),
                        child: _printerTile(
                          transport,
                          name,
                          name,
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        );
      case PosTransport.network:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _sectionTitle('Network printer'),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _host,
                    keyboardType: TextInputType.url,
                    decoration: const InputDecoration(
                      labelText: 'IP address',
                      hintText: '192.168.1.50',
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _port,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Port',
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
            if (_networkError != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  _networkError!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: () {
                  final error = networkPrinterError(
                    _host.text,
                    _port.text,
                  );
                  if (error != null) {
                    setState(() => _networkError = error);
                    return;
                  }
                  final host = _host.text.trim();
                  final port = int.parse(_port.text.trim());
                  _pick(
                    PosTransport.network,
                    host,
                    '$host:$port',
                    port: port,
                  );
                },
                child: Text(
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize:
                        returnTheme(
                          context,
                          listen: false,
                        ).mobileTexts.b3.fontSize,
                  ),
                  'Use this printer',
                ),
              ),
            ),
          ],
        );
    }
  }
}
