import 'package:flutter/material.dart';
import 'package:stockall/pages/report/invoice_summary/components/invoice_summary_view.dart';

class InvoiceSummaryMobile extends StatelessWidget {
  const InvoiceSummaryMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return const InvoiceSummaryView(isDesktop: false);
  }
}

