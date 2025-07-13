import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScanner extends StatefulWidget {
  const BarcodeScanner({super.key});

  @override
  State<BarcodeScanner> createState() =>
      _BarcodeScannerState();
}

class _BarcodeScannerState extends State<BarcodeScanner> {
  String? scannedCode;
  bool isScanning = true;

  final MobileScannerController cameraController =
      MobileScannerController();

  void _onDetect(BarcodeCapture capture) {
    if (!isScanning) return; // Prevent repeated scans

    final Barcode? barcode = capture.barcodes.first;
    final String? value = barcode?.rawValue;

    if (value != null && value.isNotEmpty) {
      setState(() {
        scannedCode = value;
        isScanning = false;
      });

      // Stop scanning after first successful scan
      cameraController.stop();

      // Optional: Show result in dialog
      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text('Scanned Code'),
              content: Text(value),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      isScanning = true;
                      cameraController.start();
                    });
                  },
                  child: const Text('Scan Again'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop(
                      value,
                    ); // return value to previous page
                  },
                  child: const Text('Done'),
                ),
              ],
            ),
      );
    }
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Barcode / QR Code'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => cameraController.toggleTorch(),
          ),
          if (!kIsWeb)
            IconButton(
              icon: const Icon(Icons.cameraswitch),
              onPressed:
                  () => cameraController.switchCamera(),
            ),
        ],
      ),
      body: MobileScanner(
        controller: cameraController,
        onDetect: _onDetect,
        fit: BoxFit.cover,
      ),
    );
  }
}
