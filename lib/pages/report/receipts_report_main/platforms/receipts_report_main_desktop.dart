import 'package:flutter/material.dart';
import 'package:stockall/pages/report/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/receipts_report_main/components/receipts_report_main_view.dart';

class ReceiptsReportMainDesktop extends StatelessWidget {
  final ReceiptsReportFilters? initialFilters;
  final ReceiptsReportPeriod? initialPeriod;

  const ReceiptsReportMainDesktop({
    super.key,
    this.initialFilters,
    this.initialPeriod,
  });

  @override
  Widget build(BuildContext context) {
    return ReceiptsReportMainView(
      isDesktop: true,
      initialFilters: initialFilters,
      initialPeriod: initialPeriod,
    );
  }
}
