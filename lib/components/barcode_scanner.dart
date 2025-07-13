// import 'package:flutter/foundation.dart';
import 'dart:ui';

import 'package:flutter/foundation.dart';
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
          // Visibility(
          //   visible: !kIsWeb,
          //   child: Row(
          //     children: [
          //       IconButton(
          //         icon: const Icon(Icons.flash_on),
          //         onPressed:
          //             () => cameraController.toggleTorch(),
          //       ),
          //       IconButton(
          //         icon: const Icon(Icons.cameraswitch),
          //         onPressed:
          //             () => cameraController.switchCamera(),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: _onDetect,
            fit: BoxFit.cover,
          ),
          // Center(
          //   child: ClipPath(
          //     clipper: HoleClipper(),
          //     child: BackdropFilter(
          //       filter: ImageFilter.blur(
          //         sigmaX: 0,
          //         sigmaY: 0,
          //       ),
          //       child: Container(color: Colors.transparent),
          //     ),
          //   ),
          // ),
          // Container(color: Colors.black),
        ],
      ),
    );
  }
}

// // Custom clipper for the transparent square
// class HoleClipper extends CustomClipper<Path> {
//   @override
//   Path getClip(Size size) {
//     const double holeSize =
//         200; // size of the transparent square
//     final double left = (size.width - holeSize) / 2;
//     final double top = (size.height - holeSize) / 2;

//     final Path path =
//         Path()
//           ..addRect(
//             Rect.fromLTWH(0, 0, size.width, size.height),
//           )
//           ..addRect(
//             Rect.fromLTWH(left, top, holeSize, holeSize),
//           )
//           ..fillType =
//               PathFillType.evenOdd; // creates a "hole"

//     return path;
//   }

//   @override
//   bool shouldReclip(
//     covariant CustomClipper<Path> oldClipper,
//   ) => false;
// }
