import 'package:flutter/material.dart';
import 'package:stockall/classes/checkout_response.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/invoices/invoice_page/invoice_page_desktop.dart';
import 'package:stockall/pages/invoices/invoice_page/invoice_page_mobile.dart';
import 'package:stockall/pages/sales/make_sales/receipt_page/platforms/receipt_page_desktop.dart';
import 'package:stockall/pages/sales/make_sales/receipt_page/platforms/receipt_page_mobile.dart';

class ReceiptPage extends StatelessWidget {
  final CheckoutResponse response;
  final bool isMain;
  final bool? isComingFromInvoice;
  const ReceiptPage({
    super.key,
    required this.response,
    required this.isMain,
    this.isComingFromInvoice,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < mobileScreen) {
          if (response.isReceipt) {
            return ReceiptPageMobile(
              isMain: isMain,
              response: response,
              isComingFromInvoice: isComingFromInvoice,
            );
          } else {
            return InvoicePageMobile(
              invoiceUuid: response.resUuid,
            );
          }
        } else {
          if (response.isReceipt) {
            return ReceiptPageDesktop(
              isMain: isMain,
              response: response,
              isComingFromInvoice: isComingFromInvoice,
            );
          } else {
            return InvoicePageDesktop(
              invoiceUuid: response.resUuid,
            );
          }
        }
      },
    );
  }
}
