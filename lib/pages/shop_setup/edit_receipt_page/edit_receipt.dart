import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/shop_setup/edit_receipt_page/platforms/edit_receipt_page_desktop.dart';
import 'package:stockall/pages/shop_setup/edit_receipt_page/platforms/edit_receipt_page_mobile.dart';

class EditReceipt extends StatelessWidget {
  const EditReceipt({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < mobileScreen) {
          return EditReceiptPageMobile();
        } else {
          return EditReceiptPageDesktop();
        }
      },
    );
  }
}
