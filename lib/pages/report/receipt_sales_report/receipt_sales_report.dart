import 'package:flutter/material.dart';
import 'package:stockall/pages/report/receipt_sales_report/platforms/receipt_sales_report_desktop.dart';

class ReceiptSalesReport extends StatelessWidget {
  const ReceiptSalesReport({super.key});

  @override
  Widget build(BuildContext context) {
    // return LayoutBuilder(
    //   builder: (context, constraints) {
    //     if (constraints.maxWidth < mobileScreen) {
    //       return ReceiptSalesReportMobile();
    //     } else {
    //       return ReceiptSalesReportDesktop();
    //     }
    //   },
    // );
    return ReceiptSalesReportDesktop();
  }
}
