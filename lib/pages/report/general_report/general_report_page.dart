import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/report/general_report/components/general_report_view.dart';
import 'package:stockall/pages/report/general_report/platforms/general_report_desktop.dart';
import 'package:stockall/pages/report/general_report/platforms/general_report_mobile.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

class GeneralReportPage extends StatelessWidget {
  final ReceiptsReportPeriod? initialPeriod;

  /// Null in the app: [GeneralReportEnv.live] is used.
  final GeneralReportEnv? env;

  const GeneralReportPage({
    super.key,
    this.initialPeriod,
    this.env,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < tabletScreen) {
          return GeneralReportMobile(
            initialPeriod: initialPeriod,
            env: env,
          );
        } else {
          return GeneralReportDesktop(
            initialPeriod: initialPeriod,
            env: env,
          );
        }
      },
    );
  }
}
