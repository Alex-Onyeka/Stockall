import 'package:flutter/material.dart';
import 'package:stockall/pages/report/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/receipts_report_summary/components/receipts_report_summary_view.dart';

class ReceiptsReportSummaryDesktop extends StatelessWidget {
  final ReceiptsReportFilters? initialFilters;
  final ReceiptsReportPeriod? initialPeriod;

  const ReceiptsReportSummaryDesktop({
    super.key,
    this.initialFilters,
    this.initialPeriod,
  });

  @override
  Widget build(BuildContext context) {
    return ReceiptsReportSummaryView(
      isDesktop: true,
      initialFilters: initialFilters,
      initialPeriod: initialPeriod,
    );
  }
}
