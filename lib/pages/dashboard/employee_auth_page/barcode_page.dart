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

// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:stockitt/constants/play_sounds.dart';

class BarcodeScannerPage extends StatelessWidget {
  const BarcodeScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (kIsWeb ||
        !(defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS)) {
      return const UnsupportedScanner();
    } else {
      return const MobileBarcodeScanner();
    }
  }
}

/// ========== Mobile Scanner ==========
class MobileBarcodeScanner extends StatefulWidget {
  const MobileBarcodeScanner({super.key});

  @override
  State<MobileBarcodeScanner> createState() =>
      _MobileBarcodeScannerState();
}

class _MobileBarcodeScannerState
    extends State<MobileBarcodeScanner> {
  final MobileScannerController controller =
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
    if (_isScanned) return;

    final Barcode? barcode = capture.barcodes.first;
    if (barcode?.rawValue == null) return;

    _isScanned = true;
    final String code = barcode!.rawValue!;
    await playBeep();
    Navigator.of(context).pop(code);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
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

          // Border around scanning area
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

          // Back button
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

/// ========== Fallback for Unsupported Platforms ==========
class UnsupportedScanner extends StatelessWidget {
  const UnsupportedScanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner Not Supported'),
      ),
      body: const Center(
        child: Text(
          'Barcode scanning is only supported on mobile devices.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
