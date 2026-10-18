import 'package:flutter/material.dart';
import 'package:stockall/pages/report/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/receipts_report_main/components/receipts_report_main_view.dart';

class ReceiptsReportMainMobile extends StatelessWidget {
  final ReceiptsReportFilters? initialFilters;
  final ReceiptsReportPeriod? initialPeriod;

  const ReceiptsReportMainMobile({
    super.key,
    this.initialFilters,
    this.initialPeriod,
  });

  @override
  Widget build(BuildContext context) {
    return ReceiptsReportMainView(
      isDesktop: false,
      initialFilters: initialFilters,
      initialPeriod: initialPeriod,
    );
  }
}
