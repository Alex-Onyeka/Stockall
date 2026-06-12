import 'package:flutter/material.dart';
import 'package:stockall/classes/checkout_response.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/invoices/invoice_page/invoice_page_desktop.dart';
import 'package:stockall/pages/invoices/invoice_page/invoice_page_mobile.dart';
import 'package:stockall/pages/sales/make_sales/receipt_page/platforms/receipt_page_desktop.dart';
import 'package:stockall/pages/sales/make_sales/receipt_page/platforms/receipt_page_mobile.dart';

class ReceiptPage extends StatefulWidget {
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
  State<ReceiptPage> createState() => _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptPage> {
  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isMain &&
          widget.isComingFromInvoice != true) {
        returnData().syncData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < mobileScreen) {
          if (widget.response.isReceipt) {
            return ReceiptPageMobile(
              isMain: widget.isMain,
              response: widget.response,
              isComingFromInvoice:
                  widget.isComingFromInvoice,
            );
          } else {
            return InvoicePageMobile(
              invoiceUuid: widget.response.resUuid,
            );
          }
        } else {
          if (widget.response.isReceipt) {
            return ReceiptPageDesktop(
              isMain: widget.isMain,
              response: widget.response,
              isComingFromInvoice:
                  widget.isComingFromInvoice,
            );
          } else {
            return InvoicePageDesktop(
              invoiceUuid: widget.response.resUuid,
            );
          }
        }
      },
    );
  }
}
