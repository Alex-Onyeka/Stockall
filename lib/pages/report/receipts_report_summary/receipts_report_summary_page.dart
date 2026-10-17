import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/report/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/receipts_report_summary/platforms/receipts_report_summary_desktop.dart';
import 'package:stockall/pages/report/receipts_report_summary/platforms/receipts_report_summary_mobile.dart';

/// Without initial values: today's business day, no filters.
class ReceiptsReportSummaryPage extends StatelessWidget {
  final ReceiptsReportFilters? initialFilters;
  final ReceiptsReportPeriod? initialPeriod;

  const ReceiptsReportSummaryPage({
    super.key,
    this.initialFilters,
    this.initialPeriod,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < tabletScreen) {
          return ReceiptsReportSummaryMobile(
            initialFilters: initialFilters,
            initialPeriod: initialPeriod,
          );
        } else {
          return ReceiptsReportSummaryDesktop(
            initialFilters: initialFilters,
            initialPeriod: initialPeriod,
          );
        }
      },
    );
  }
}
