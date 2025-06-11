// import 'package:flutter/material.dart';
// import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
// import 'package:stockall/constants/play_sounds.dart';

// Future<String> scanCode(
//   BuildContext context,
//   String message,
// ) async {
//   try {
//     String? res = await SimpleBarcodeScanner.scanBarcode(
//       context,
//       barcodeAppBar: const BarcodeAppBar(
//         appBarTitle: 'Scan Barcode',
//         centerTitle: false,
//         enableBackButton: true,
//         backButtonIcon: Icon(Icons.arrow_back_ios),
//       ),
//       isShowFlashIcon: true,
//       delayMillis: 100,
//       cameraFace: CameraFace.back,
//     );
//     if (res == '-1') {
//       return message;
//     } else {
//       await playBeep();
//       return res!;
//     }
//   } catch (e) {
//     print(e);
//     return message;
//   }
// }

import 'package:flutter/material.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/constants/play_sounds.dart';
import 'package:stockall/main.dart';

Future<String?> scanCode(
  BuildContext context,
  String message,
) async {
  try {
    String? res = await SimpleBarcodeScanner.scanBarcode(
      context,
      barcodeAppBar: const BarcodeAppBar(
        appBarTitle: 'Scan Barcode',
        centerTitle: false,
        enableBackButton: true,
        backButtonIcon: Icon(Icons.arrow_back_ios),
      ),
      isShowFlashIcon: true,
      delayMillis: 100,
      cameraFace: CameraFace.back,
    );

    if (res == '-1') return null;

    // ✅ Validate that it's a typical barcode (numeric only, 8–13 digits)
    final isBarcode = RegExp(r'^\d{8,13}$');
    if (isBarcode.hasMatch(res!)) {
      await playBeep();
      return res;
    } else {
      // Optionally show a message to user
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) {
            return InfoAlert(
              theme: returnTheme(context, listen: false),
              message:
                  'This scanner is for barcodes only. Please point it at a barcode and hold steady for 3 seconds.',
              title: 'Barcode not Detected',
            );
          },
        );
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(
        //     content: Text("Please scan a valid barcode"),
        //   ),
        // );
      }
      return null;
    }
  } catch (e) {
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) {
          return InfoAlert(
            theme: returnTheme(context, listen: false),
            message:
                'Scanning was cancelled. If you did not cancel it manually, barcode scanning may not yet be supported on your device (such as iOS). Please use the search box to find products instead.',
            title: 'Scanning Cancelled',
          );
        },
      );
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text("Please scan a valid barcode"),
      //   ),
      // );
    }
    return null;
  }
}
