import 'dart:html' as html;
import 'dart:js' as js; // <---- Add this import
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class WebBarcodeScanner extends StatefulWidget {
  final void Function(String) onScanned;
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
  final String viewId = 'html5-qrcode-scanner';

  @override
  void initState() {
    super.initState();

    if (kIsWeb) {
      // Register the view factory once
      // ignore: undefined_prefixed_name
      ui.platformViewRegistry.registerViewFactory(viewId, (
        int viewId,
      ) {
        final element =
            html.DivElement()
              ..id = 'scanner-div'
              ..style.width = '100%'
              ..style.height = '100%';
        return element;
      });

      Future.delayed(Duration(milliseconds: 100), () {
        js.context.callMethod('eval', [
          """
          new Html5Qrcode("scanner-div").start(
            { facingMode: "environment" },
            {
              fps: 10,
              qrbox: { width: 250, height: 250 }
            },
            qrCodeMessage => {
              window.dispatchEvent(new CustomEvent('qrResult', { detail: qrCodeMessage }));
            },
            errorMessage => {
              console.log("QR Error", errorMessage);
            }
          );
        """,
        ]);
      });

      html.window.addEventListener('qrResult', (event) {
        final result = (event as html.CustomEvent).detail;
        widget.onScanned(result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: viewId);
  }
}
