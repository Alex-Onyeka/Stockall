// Android/iOS: writes ESC/POS chunks to the connected Bluetooth printer.
import 'dart:typed_data';

import 'package:bluetooth_print_plus/bluetooth_print_plus.dart';
import 'package:flutter/material.dart';
import 'package:stockall/services/printing/printer_service_mobile.dart'
    show BluetoothDevicesPage;

/// Prints [chunks]. With no printer connected it opens the device list
/// first; tapping a device there connects and closes it, so the print
/// goes out right after a printer is picked. Returns false when the list
/// was closed without connecting (the user cancelled).
Future<bool> reportPrintBluetooth(
  BuildContext context,
  List<Uint8List> chunks, {
  required VoidCallback beforeUi,
}) async {
  if (!BluetoothPrintPlus.isConnected) {
    beforeUi();
    await showDialog<void>(
      context: context,
      builder: (_) => const BluetoothDevicesPage(),
    );
    if (!BluetoothPrintPlus.isConnected) return false;
  }
  for (final chunk in chunks) {
    await BluetoothPrintPlus.write(chunk);
  }
  return true;
}
