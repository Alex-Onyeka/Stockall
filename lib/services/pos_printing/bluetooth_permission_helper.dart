import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stockall/main.dart' show mainLocalLog;

/// Requests runtime permissions required for Bluetooth scanning and connecting
/// on Android (and iOS).
///
/// On Android 12+ (API >= 31):
/// - [Permission.bluetoothScan]
/// - [Permission.bluetoothConnect]
///
/// On Android < 12 (API < 31):
/// - [Permission.location] (required for Bluetooth LE / Classic discovery)
///
/// Returns `true` if all necessary permissions are granted, `false` otherwise.
Future<bool> ensureBluetoothPermissions() async {
  if (kIsWeb) return true;

  if (Platform.isAndroid) {
    try {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      final sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 31) {
        final scanStatus = await Permission.bluetoothScan.request();
        final connectStatus = await Permission.bluetoothConnect.request();
        if (!scanStatus.isGranted || !connectStatus.isGranted) {
          await mainLocalLog(
            'Bluetooth permissions denied on Android 12+ (scan: $scanStatus, connect: $connectStatus)',
          );
          return false;
        }
        return true;
      } else {
        final locationStatus = await Permission.location.request();
        if (!locationStatus.isGranted) {
          await mainLocalLog(
            'Location permission denied on Android < 12 (location: $locationStatus)',
          );
          return false;
        }
        return true;
      }
    } catch (e, st) {
      await mainLocalLog('Error requesting bluetooth permissions: $e\n$st');
      return false;
    }
  }

  if (Platform.isIOS) {
    try {
      final bluetoothStatus = await Permission.bluetooth.request();
      return bluetoothStatus.isGranted;
    } catch (e, st) {
      await mainLocalLog('Error requesting bluetooth permissions on iOS: $e\n$st');
      return false;
    }
  }

  return true;
}
