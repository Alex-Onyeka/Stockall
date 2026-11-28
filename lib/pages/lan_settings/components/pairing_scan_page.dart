import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/main.dart';

/// Scans the QR code the store server shows, on a phone or
/// tablet. Closes with what it read; the caller pairs with it.
class PairingScanPage extends StatefulWidget {
  const PairingScanPage({super.key});

  @override
  State<PairingScanPage> createState() => _PairingScanPageState();
}

class _PairingScanPageState extends State<PairingScanPage> {
  final MobileScannerController _camera = MobileScannerController(
    facing: CameraFacing.back,
  );
  bool _done = false;

  void _onDetect(BarcodeCapture capture) {
    if (_done || capture.barcodes.isEmpty) return;
    final value = capture.barcodes.first.rawValue;
    if (value == null || value.isEmpty) return;
    _done = true;
    _camera.stop();
    Navigator.of(context).pop(value);
  }

  @override
  void dispose() {
    _camera.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = returnTheme(context);
    return Scaffold(
      appBar: appBar(context: context, title: 'Scan the Server\'s Code'),
      body: Container(
        color: Colors.grey.shade100,
        padding: const EdgeInsets.all(20),
        child: Column(
          spacing: 20,
          children: [
            Text(
              'On the store server, open Settings › Store Network and tap '
              '"Show QR code". Point this camera at it.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: theme.mobileTexts.b2.fontSize),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.lightBlue, width: 2.5),
                borderRadius: BorderRadius.circular(10),
              ),
              clipBehavior: Clip.antiAlias,
              height: 280,
              width: 280,
              child: MobileScanner(
                controller: _camera,
                onDetect: _onDetect,
                onDetectError: (error, stackTrace) async {
                  await mainLocalLog('Pairing scan failed: $error');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
