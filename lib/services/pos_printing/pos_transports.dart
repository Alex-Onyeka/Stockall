import 'dart:async';
import 'dart:io';

import 'package:bluetooth_print_plus/bluetooth_print_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:stockall/services/pos_printing/pos_print_rules.dart';
import 'package:stockall/services/receipt_print_service/receipt_import_helper.dart'
    show sendReceiptToPrinter;

// Sending ESC/POS bytes to the saved printer. Native platforms only; the
// dispatcher never calls this on web.

class PosSendException implements Exception {
  final String message;

  const PosSendException(this.message);

  @override
  String toString() => message;
}

PosPlatform currentPosPlatform() {
  if (kIsWeb) return PosPlatform.web;
  if (Platform.isAndroid) return PosPlatform.android;
  if (Platform.isIOS) return PosPlatform.ios;
  if (Platform.isWindows) return PosPlatform.windows;
  if (Platform.isMacOS) return PosPlatform.macos;
  return PosPlatform.linux;
}

Future<void> sendToPosPrinter(
  PosPrinterConfig printer,
  List<Uint8List> chunks,
) {
  switch (printer.transport) {
    case PosTransport.bluetooth:
      return _sendBluetooth(printer, chunks);
    case PosTransport.network:
      return _sendNetwork(printer, chunks);
    case PosTransport.windowsSpooler:
      return _sendWindows(printer, chunks);
    case PosTransport.cups:
      return _sendCups(printer, chunks);
  }
}

// ---------------------------------------------------------------------
// Bluetooth (Android, iOS)

// The printer this module connected to. The plugin only says whether
// something is connected, not what.
String? _connectedAddress;

Future<void> _sendBluetooth(
  PosPrinterConfig printer,
  List<Uint8List> chunks,
) async {
  if (!BluetoothPrintPlus.isBlueOn) {
    throw const PosSendException('Bluetooth is off. Turn it on and try again.');
  }
  await _ensureBluetoothConnected(printer);
  for (final chunk in chunks) {
    await BluetoothPrintPlus.write(chunk);
  }
}

Future<void> _ensureBluetoothConnected(PosPrinterConfig printer) async {
  if (BluetoothPrintPlus.isConnected &&
      _connectedAddress == printer.address) {
    return;
  }
  if (BluetoothPrintPlus.isConnected) {
    // Connected elsewhere (another printer, or before this session).
    await BluetoothPrintPlus.disconnect();
    _connectedAddress = null;
  }
  // Android connects to a known address directly.
  if (await _connectAndWait(
    BluetoothDevice(printer.name, printer.address),
    const Duration(seconds: 6),
  )) {
    _connectedAddress = printer.address;
    return;
  }
  // iOS (and some Android printers) need the printer found in a scan
  // first: scan until the saved printer shows up, then connect.
  final found = BluetoothPrintPlus.scanResults
      .map(
        (devices) =>
            devices.where((d) => d.address == printer.address).firstOrNull,
      )
      .firstWhere((device) => device != null)
      .timeout(const Duration(seconds: 10), onTimeout: () => null);
  unawaited(BluetoothPrintPlus.startScan(timeout: const Duration(seconds: 10)));
  final device = await found;
  await BluetoothPrintPlus.stopScan();
  if (device == null) {
    throw PosSendException(
      '${printer.name} was not found. Check it is on and nearby.',
    );
  }
  if (!await _connectAndWait(device, const Duration(seconds: 8))) {
    throw PosSendException('Could not connect to ${printer.name}.');
  }
  _connectedAddress = printer.address;
}

Future<bool> _connectAndWait(BluetoothDevice device, Duration timeout) async {
  final connected = BluetoothPrintPlus.connectState
      .firstWhere((state) => state == ConnectState.connected)
      .timeout(timeout)
      .then((_) => true, onError: (_) => false);
  try {
    await BluetoothPrintPlus.connect(device);
  } catch (_) {
    return false;
  }
  if (BluetoothPrintPlus.isConnected) return true;
  return connected;
}

// ---------------------------------------------------------------------
// Network (raw TCP, usually port 9100)

Future<void> _sendNetwork(
  PosPrinterConfig printer,
  List<Uint8List> chunks,
) async {
  final Socket socket;
  try {
    socket = await Socket.connect(
      printer.address,
      printer.port ?? defaultNetworkPort,
      timeout: const Duration(seconds: 5),
    );
  } on SocketException catch (e) {
    throw PosSendException(
      'Could not reach ${printer.address}:${printer.port ?? defaultNetworkPort} '
      '(${e.osError?.message ?? e.message}).',
    );
  }
  try {
    for (final chunk in chunks) {
      socket.add(chunk);
    }
    await socket.flush();
  } finally {
    await socket.close();
    socket.destroy();
  }
}

// ---------------------------------------------------------------------
// Windows: RAW to an installed printer (the items report's path)

Future<void> _sendWindows(
  PosPrinterConfig printer,
  List<Uint8List> chunks,
) async {
  final bytes = Uint8List.fromList([for (final c in chunks) ...c]);
  final sent = await sendReceiptToPrinter(bytes, printerName: printer.address);
  if (!sent) {
    throw PosSendException('Windows could not print to ${printer.name}.');
  }
}

// ---------------------------------------------------------------------
// macOS / Linux: raw through the CUPS queue

Future<List<String>> listCupsQueues() async {
  try {
    var result = await Process.run('lpstat', ['-e']);
    if (result.exitCode != 0 || '${result.stdout}'.trim().isEmpty) {
      result = await Process.run('lpstat', ['-a']);
    }
    if (result.exitCode != 0) return const [];
    return parseLpstatQueues('${result.stdout}');
  } catch (_) {
    return const [];
  }
}

Future<void> _sendCups(
  PosPrinterConfig printer,
  List<Uint8List> chunks,
) async {
  final dir = await Directory.systemTemp.createTemp('stockall_print');
  try {
    final file = File('${dir.path}/receipt.bin');
    await file.writeAsBytes([for (final c in chunks) ...c], flush: true);
    final ProcessResult result;
    try {
      result = await Process.run('lp', [
        '-d',
        printer.address,
        '-o',
        'raw',
        file.path,
      ]);
    } on ProcessException catch (e) {
      throw PosSendException('Could not run lp: ${e.message}');
    }
    if (result.exitCode != 0) {
      throw PosSendException(
        'The print queue ${printer.address} refused the job: '
        '${'${result.stderr}'.trim()}',
      );
    }
  } finally {
    await dir.delete(recursive: true);
  }
}
