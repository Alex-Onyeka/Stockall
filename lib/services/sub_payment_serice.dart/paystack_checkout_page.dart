import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/main.dart';
import 'package:stockall/services/payment_result_page.dart/payment_result_page.dart';
import 'package:stockall/services/sub_payment_serice.dart/sub_payment_service.dart';

class PaystackCheckoutPage extends StatefulWidget {
  final PaymentInitResponse authorizationUrl;
  final Uri callbackUrl;

  const PaystackCheckoutPage({
    super.key,
    required this.authorizationUrl,
    required this.callbackUrl,
  });

  @override
  State<PaystackCheckoutPage> createState() =>
      _PaystackCheckoutPageState();
}

class _PaystackCheckoutPageState
    extends State<PaystackCheckoutPage> {
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(
        context: context,
        title: 'Complete Checkout',
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialSettings: InAppWebViewSettings(
              cacheEnabled: true,
              javaScriptEnabled: true,
              useOnDownloadStart: true,
            ),
            initialUrlRequest: URLRequest(
              url: WebUri(
                widget.authorizationUrl.authorizationUrl,
              ),
            ),
            shouldOverrideUrlLoading: (
              controller,
              navigationAction,
            ) async {
              final url = navigationAction.request.url;
              if (url != null &&
                  url.scheme == widget.callbackUrl.scheme &&
                  url.host == widget.callbackUrl.host &&
                  url.path == widget.callbackUrl.path) {
                if (context.mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder:
                          (_) => PaymentResultPage(
                            response:
                                widget.authorizationUrl,
                          ),
                    ),
                  );
                }

                return NavigationActionPolicy.CANCEL;
              }
              return NavigationActionPolicy.ALLOW;
            },
            onLoadStart: (controller, url) {
              setState(() => _isLoading = true);
            },
            onLoadStop: (controller, url) {
              setState(() => _isLoading = false);
            },
          ),
          if (_isLoading)
            Center(
              child: returnCompProvider(
                context,
              ).showLoader(message: 'Loading'),
            ),
        ],
      ),
    );
  }
}
