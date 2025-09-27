import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/sales/make_sales/receipt_page/platforms/receipt_page_desktop.dart';
import 'package:stockall/pages/sales/make_sales/receipt_page/platforms/receipt_page_mobile.dart';

class ReceiptPage extends StatelessWidget {
  final String receiptUuid;
  final bool isMain;
  const ReceiptPage({
    super.key,
    required this.receiptUuid,
    required this.isMain,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < mobileScreen) {
          return ReceiptPageMobile(
            isMain: isMain,
            receiptUuid: receiptUuid,
          );
        } else {
          return ReceiptPageDesktop(
            isMain: isMain,
            receiptUuid: receiptUuid,
          );
        }
      },
    );
  }
}
