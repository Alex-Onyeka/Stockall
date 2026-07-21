import 'package:flutter/material.dart';
import 'package:stockall/pages/report/invoice_sales_report/platforms/invoice_sales_report_desktop.dart';

class InvoiceSalesReport extends StatelessWidget {
  const InvoiceSalesReport({super.key});

  @override
  Widget build(BuildContext context) {
    // return LayoutBuilder(
    //   builder: (context, constraints) {
    //     if (constraints.maxWidth < mobileScreen) {
    //       return InvoiceSalesReportMobile();
    //     } else {
    //       return InvoiceSalesReportDesktop();
    //     }
    //   },
    // );
    return InvoiceSalesReportDesktop();
  }
}
