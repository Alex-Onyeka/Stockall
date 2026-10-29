import 'package:flutter/material.dart';
import 'package:stockall/pages/report/general_report/components/general_report_view.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

class GeneralReportMobile extends StatelessWidget {
  final ReceiptsReportPeriod? initialPeriod;
  final GeneralReportEnv? env;

  const GeneralReportMobile({
    super.key,
    this.initialPeriod,
    this.env,
  });

  @override
  Widget build(BuildContext context) {
    return GeneralReportView(
      isDesktop: false,
      initialPeriod: initialPeriod,
      env: env,
    );
  }
}
