import 'package:flutter/material.dart';
import 'package:stockall/pages/report/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/receipts_report_main/components/receipts_report_main_view.dart';

class ReceiptsReportMainMobile extends StatelessWidget {
  final ReceiptsReportFilters? initialFilters;
  final ReceiptsReportPeriod? initialPeriod;
  final bool openedFromSummary;

  const ReceiptsReportMainMobile({
    super.key,
    this.initialFilters,
    this.initialPeriod,
    this.openedFromSummary = false,
  });

  @override
  Widget build(BuildContext context) {
    return ReceiptsReportMainView(
      isDesktop: false,
      initialFilters: initialFilters,
      initialPeriod: initialPeriod,
      openedFromSummary: openedFromSummary,
    );
  }
}
