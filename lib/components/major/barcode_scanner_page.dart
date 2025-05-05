// import 'package:flutter/material.dart';
// import 'package:qr_code_scanner/qr_code_scanner.dart';

// class BarcodeScannerPage extends StatefulWidget {
//   const BarcodeScannerPage({super.key});

//   @override
//   State<BarcodeScannerPage> createState() =>
//       _BarcodeScannerPageState();
// }

// class _BarcodeScannerPageState
//     extends State<BarcodeScannerPage> {
//   final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
//   QRViewController? controller;
//   String? scannedCode;

//   @override
//   void reassemble() {
//     super.reassemble();
//     if (controller != null) {
//       controller!.pauseCamera();
//       controller!.resumeCamera();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           QRView(
//             key: qrKey,
//             onQRViewCreated: _onQRViewCreated,
//             overlay: QrScannerOverlayShape(
//               borderColor: Colors.red,
//               borderRadius: 10,
//               borderLength: 30,
//               borderWidth: 10,
//               cutOutSize: 250,
//             ),
//           ),
//           if (scannedCode != null)
//             Positioned(
//               bottom: 40,
//               left: 20,
//               right: 20,
//               child: Container(
//                 padding: EdgeInsets.all(12),
//                 color: Colors.white,
//                 child: Text(
//                   'Scanned: $scannedCode',
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   void _onQRViewCreated(QRViewController controller) {
//     this.controller = controller;
//     controller.scannedDataStream.listen((scanData) {
//       setState(() {
//         scannedCode = scanData.code;
//       });
//     });
//   }

//   @override
//   void dispose() {
//     controller?.dispose();
//     super.dispose();
//   }
// }
