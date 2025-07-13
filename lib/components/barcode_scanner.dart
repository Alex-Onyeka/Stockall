// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:stockall/constants/play_sounds.dart';

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

  void _onDetect(BarcodeCapture capture) async {
    var safeContext = context;
    if (!isScanning) return;

    final Barcode? barcode = capture.barcodes.first;
    final String? value = barcode?.rawValue;

    if (value != null && value.isNotEmpty) {
      setState(() {
        scannedCode = value;
        isScanning = false;
      });
      await playBeep();

      // Stop scanning after first successful scan
      cameraController.stop();

      // Optional: Show result in dialog
      // Navigator.of(context).pop();
      if (safeContext.mounted) {
        Navigator.of(safeContext).pop(value);
      }
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
        title: const Text('Scan Barcode'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => cameraController.toggleTorch(),
          ),
          // if (!kIsWeb)
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
