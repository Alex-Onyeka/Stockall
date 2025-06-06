import 'package:flutter/material.dart';
import 'package:stockall/components/major/unsupported_platform.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/sales/sales_page/platforms/sales_page_mobile.dart';

class SalesPage extends StatelessWidget {
  const SalesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        returnNavProvider(
          context,
          listen: false,
        ).navigate(0);
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 550) {
            return SalesPageMobile();
          } else if (constraints.maxWidth > 550 &&
              constraints.maxWidth < 1000) {
            return UnsupportedPlatform();
            // return Scaffold();
          } else {
            return UnsupportedPlatform();
            // return Scaffold();
          }
        },
      ),
    );
  }
}
