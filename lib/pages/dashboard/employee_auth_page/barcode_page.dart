// import 'package:flutter/material.dart';
// import 'package:mobile_scanner/mobile_scanner.dart';

// class BarcodeScannerPage extends StatefulWidget {
//   const BarcodeScannerPage({Key? key}) : super(key: key);

//   @override
//   State<BarcodeScannerPage> createState() =>
//       _BarcodeScannerPageState();
// }

// class _BarcodeScannerPageState
//     extends State<BarcodeScannerPage> {
//   late MobileScannerController controller;

//   @override
//   void initState() {
//     super.initState();
//     controller = MobileScannerController();
//   }

//   @override
//   void dispose() {
//     controller.dispose();
//     super.dispose();
//   }

//   void _onDetect(BarcodeCapture capture) {
//     final List<Barcode> barcodes = capture.barcodes;
//     final String? code = barcodes.first.rawValue;

//     if (code != null) {
//       controller.stop(); // stop the scanner
//       Navigator.pop(
//         context,
//         code,
//       ); // return the scanned value
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Scan Barcode")),
//       body: MobileScanner(
//         controller: controller,
//         onDetect: _onDetect,
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:stockitt/constants/play_sounds.dart';

class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({super.key});

  @override
  State<BarcodeScannerPage> createState() =>
      _BarcodeScannerPageState();
}

class _BarcodeScannerPageState
    extends State<BarcodeScannerPage> {
  MobileScannerController controller =
      MobileScannerController(
        formats: [
          BarcodeFormat.code128,
          BarcodeFormat.code39,
          BarcodeFormat.code93,
          BarcodeFormat.ean13,
          BarcodeFormat.ean8,
          BarcodeFormat.upcA,
          BarcodeFormat.upcE,
        ],
      );

  bool _isScanned = false;

  void _onDetect(BarcodeCapture capture) async {
    if (_isScanned) return; // Avoid multiple pops

    final Barcode? barcode = capture.barcodes.first;
    if (barcode?.rawValue == null) return;

    _isScanned = true; // Set flag so it doesn’t pop again

    final String code = barcode!.rawValue!;
    await playBeep();
    if (context.mounted) {
      Navigator.of(context).pop(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: _onDetect,
          ),

          // Dark overlay with cut-out square in the middle
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.5),
              BlendMode.srcOut,
            ),
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    backgroundBlendMode: BlendMode.dstOut,
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.all(
                        Radius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Optional: Border around the scanning square
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          // Optional: back button
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
