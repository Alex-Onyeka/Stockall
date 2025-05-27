// lib/web_barcode_scanner.dart
// ignore: deprecated_member_use, avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:ui' as ui; // ignore: undefined_prefixed_name
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class WebBarcodeScanner extends StatefulWidget {
  final void Function(String code) onScanned;
  const WebBarcodeScanner({
    super.key,
    required this.onScanned,
  });

  @override
  State<WebBarcodeScanner> createState() =>
      _WebBarcodeScannerState();
}

class _WebBarcodeScannerState
    extends State<WebBarcodeScanner> {
  final viewId = 'web-barcode-scanner';

  @override
  void initState() {
    super.initState();

    if (kIsWeb) {
      // Register the HTML element
      // ignore: undefined_prefixed_name
      ui.platformViewRegistry.registerViewFactory(
        viewId,
        (int _) => html.DivElement()..id = viewId,
      );

      // Inject JS script only once
      final script =
          html.ScriptElement()
            ..src = 'https://unpkg.com/html5-qrcode'
            ..type = 'application/javascript'
            ..defer = true;

      html.document.body!.append(script);

      // Wait a bit and initialize
      Future.delayed(const Duration(seconds: 1), () {
        html.window.console.log(
          "Initializing barcode scanner",
        );

        html.window.dispatchEvent(
          html.CustomEvent('initScanner'),
        );

        html.window.addEventListener('barcodeScanned', (
          event,
        ) {
          final result = (event as html.CustomEvent).detail;
          widget.onScanned(result);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return const HtmlElementView(
      viewType: 'web-barcode-scanner',
    );
  }
}
