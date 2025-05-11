import 'package:flutter/material.dart';
import 'package:stockitt/classes/temp_main_receipt.dart';
import 'package:stockitt/pages/sales/make_sales/receipt_page/platforms/receipt_page_mobile.dart';

class ReceiptPage extends StatelessWidget {
  final TempMainReceipt mainReceipt;
  const ReceiptPage({super.key, required this.mainReceipt});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 550) {
          return ReceiptPageMobile(
            mainReceipt: mainReceipt,
          );
        } else if (constraints.maxWidth > 550 &&
            constraints.maxWidth < 1000) {
          return Scaffold();
        } else {
          return Scaffold();
        }
      },
    );
  }
}
