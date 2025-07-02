import 'package:flutter/material.dart';
import 'package:stockall/pages/sales/make_sales/receipt_page/platforms/receipt_page_mobile.dart';

class ReceiptPage extends StatelessWidget {
  final int receiptId;
  final bool isMain;
  const ReceiptPage({
    super.key,
    required this.receiptId,
    required this.isMain,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 550) {
          return ReceiptPageMobile(
            isMain: isMain,
            receiptId: receiptId,
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
