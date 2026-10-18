import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/report/receipts_report_summary/platforms/receipts_report_summary_desktop.dart';
import 'package:stockall/pages/report/receipts_report_summary/platforms/receipts_report_summary_mobile.dart';

/// Opens on today's business day with no filters. Reached only
/// from its Sales Reports tile.
class ReceiptsReportSummaryPage extends StatelessWidget {
  const ReceiptsReportSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < tabletScreen) {
          return const ReceiptsReportSummaryMobile();
        } else {
          return const ReceiptsReportSummaryDesktop();
        }
      },
    );
  }
}
