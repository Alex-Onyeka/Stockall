import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/sales/sales_page/platforms/sales_page_desktop.dart';
import 'package:stockall/pages/sales/sales_page/platforms/sales_page_mobile.dart';

class SalesPage extends StatefulWidget {
  const SalesPage({super.key});

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  void clearDate() {
    returnReceiptProvider(
      context,
      listen: false,
    ).clearDate();
  }

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
          print(constraints.constrainWidth());
          if (constraints.maxWidth < mobileScreen) {
            return SalesPageMobile();
          } else {
            return SalesPageDesktop();
          }
        },
      ),
    );
  }
}
