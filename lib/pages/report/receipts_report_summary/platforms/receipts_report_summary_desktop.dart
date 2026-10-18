import 'package:flutter/material.dart';
import 'package:stockall/pages/report/receipts_report_summary/components/receipts_report_summary_view.dart';

class ReceiptsReportSummaryDesktop extends StatelessWidget {
  const ReceiptsReportSummaryDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    return const ReceiptsReportSummaryView(isDesktop: true);
  }
}
