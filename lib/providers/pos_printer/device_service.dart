import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:stockall/main.dart';

class DeviceService {
  static bool isPos = false;
  static bool hasInternalPrinter = false;
  static String brand = '';
  static String model = '';
  static String manufacturer = '';
  static String androidVersion = '';

  /// Call this once during app initialization
  static Future<void> init() async {
    final deviceInfo = DeviceInfoPlugin();

    if (kIsWeb) {
      await mainLocalLog("Running on Web");
    } else if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;

      brand = androidInfo.brand;
      model = androidInfo.model;
      manufacturer = androidInfo.manufacturer;
      androidVersion = androidInfo.version.release;

      isPos = _isPosDevice(brand, model, manufacturer);
      hasInternalPrinter = _hasInternalPrinter(
        brand,
        model,
        manufacturer,
      );

      // Print info to console
      await mainLocalLog("=== ANDROID DEVICE INFO ===");
      await mainLocalLog("Brand: $brand");
      await mainLocalLog("Model: $model");
      await mainLocalLog("Manufacturer: $manufacturer");
      await mainLocalLog("Device: ${androidInfo.device}");
      await mainLocalLog(
        "Android Version: $androidVersion",
      );
      await mainLocalLog(
        isPos
            ? "This is a POS device ✅"
            : "This is a normal Android device 📱",
      );
      await mainLocalLog(
        hasInternalPrinter
            ? "Device has internal printer ✅"
            : "No internal printer detected ❌",
      );
    } else if (Platform.isWindows) {
      await mainLocalLog("Running on Windows");
    } else if (Platform.isLinux) {
      await mainLocalLog("Running on Linux");
    } else if (Platform.isMacOS) {
      await mainLocalLog("Running on macOS");
    } else if (Platform.isIOS) {
      await mainLocalLog("Running on iOS");
    } else {
      await mainLocalLog("Unknown platform");
    }
  }

  static bool _isPosDevice(
    String brand,
    String model,
    String manufacturer,
  ) {
    final b = brand.toLowerCase();
    final m = model.toLowerCase();
    final mf = manufacturer.toLowerCase();

    return b.contains('sunmi') ||
        b.contains('imin') ||
        b.contains('pax') ||
        b.contains('alps') || // your POS
        m.contains('q2i') ||
        mf.contains('alps');
  }

  /// Very simple heuristic: known POS brands/models have internal printer
  static bool _hasInternalPrinter(
    String brand,
    String model,
    String manufacturer,
  ) {
    final b = brand.toLowerCase();
    final m = model.toLowerCase();
    final mf = manufacturer.toLowerCase();

    // You can add more vendor-specific rules here
    return b.contains('sunmi') ||
        b.contains('imin') ||
        b.contains('pax') ||
        b.contains('alps') || // your Q2I device
        m.contains('q2i') ||
        mf.contains('alps');
  }
}
