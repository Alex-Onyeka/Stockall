import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/report/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/receipts_report_main/platforms/receipts_report_main_desktop.dart';
import 'package:stockall/pages/report/receipts_report_main/platforms/receipts_report_main_mobile.dart';

class ReceiptsReportMainPage extends StatelessWidget {
  final ReceiptsReportFilters? initialFilters;
  final ReceiptsReportPeriod? initialPeriod;

  const ReceiptsReportMainPage({
    super.key,
    this.initialFilters,
    this.initialPeriod,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < tabletScreen) {
          return ReceiptsReportMainMobile(
            initialFilters: initialFilters,
            initialPeriod: initialPeriod,
          );
        } else {
          return ReceiptsReportMainDesktop(
            initialFilters: initialFilters,
            initialPeriod: initialPeriod,
          );
        }
      },
    );
  }
}
