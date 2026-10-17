import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/report/invoice_credit_report/platforms/invoice_credit_report_desktop.dart';
import 'package:stockall/pages/report/invoice_credit_report/platforms/invoice_credit_report_mobile.dart';

class InvoiceCreditReportPage extends StatelessWidget {
  const InvoiceCreditReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < mobileScreen) {
          return const InvoiceCreditReportMobile();
        } else {
          return const InvoiceCreditReportDesktop();
        }
      },
    );
  }
}

