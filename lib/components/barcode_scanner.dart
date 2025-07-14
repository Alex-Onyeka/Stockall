import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/constants_main.dart';

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
      Navigator.of(context).pop(value);
      // showDialog(
      //   context: context,
      //   builder:
      //       (_) => AlertDialog(
      //         title: const Text('Scanned Code'),
      //         content: Text(value),
      //         actions: [
      //           TextButton(
      //             onPressed: () {
      //               Navigator.of(context).pop();
      //               setState(() {
      //                 isScanning = true;
      //                 cameraController.start();
      //               });
      //             },
      //             child: const Text('Scan Again'),
      //           ),
      //           TextButton(
      //             onPressed: () {
      //               Navigator.of(context).pop();
      //               Navigator.of(context).pop(
      //                 value,
      //               ); // return value to previous page
      //             },
      //             child: const Text('Done'),
      //           ),
      //         ],
      //       ),
      // );
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
      appBar: appBar(
        context: context,
        title: 'Scan Barcode',
        widget: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.flash_on),
              onPressed:
                  () => cameraController.toggleTorch(),
            ),
            if (!kIsWeb)
              IconButton(
                icon: const Icon(Icons.cameraswitch),
                onPressed:
                    () => cameraController.switchCamera(),
              ),
          ],
        ),
      ),
      body: Container(
        color: Colors.grey.shade100,
        child: Stack(
          children: [
            Align(
              alignment: Alignment(0, -0.8),
              child: LottieBuilder.asset(
                searchingAnim2,
                height: 200,
              ),
            ),
            Center(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.amber,
                    width: 2.5,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                height: 200,
                width: 300,
                child: MobileScanner(
                  // fit: BoxFit.contain,
                  controller: cameraController,
                  onDetect: _onDetect,
                  onDetectError: (error, stackTrace) {
                    print(error.toString());
                    print(
                      'Error: ${stackTrace.toString()}',
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
