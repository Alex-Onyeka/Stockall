import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/report/invoice_summary/platforms/invoice_summary_desktop.dart';
import 'package:stockall/pages/report/invoice_summary/platforms/invoice_summary_mobile.dart';

class InvoiceSummaryPage extends StatelessWidget {
  const InvoiceSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < tabletScreen) {
          return const InvoiceSummaryMobile();
        } else {
          return const InvoiceSummaryDesktop();
        }
      },
    );
  }
}

