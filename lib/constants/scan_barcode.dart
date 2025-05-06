import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

Future<String> scanCode(
  BuildContext context,
  String message,
) async {
  try {
    String? res = await SimpleBarcodeScanner.scanBarcode(
      context,
      barcodeAppBar: const BarcodeAppBar(
        appBarTitle: 'Test',
        centerTitle: false,
        enableBackButton: true,
        backButtonIcon: Icon(Icons.arrow_back_ios),
      ),
      isShowFlashIcon: true,
      delayMillis: 100,
      cameraFace: CameraFace.back,
    );
    if (res == '-1') {
      return message;
    } else {
      return res as String;
    }
  } catch (e) {
    return message;
  }
}
