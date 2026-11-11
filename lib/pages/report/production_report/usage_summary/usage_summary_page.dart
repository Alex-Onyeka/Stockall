import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/report/production_report/usage_records_table/components/usage_records_table_view.dart';
import 'package:stockall/pages/report/production_report/usage_summary/platforms/usage_summary_desktop.dart';
import 'package:stockall/pages/report/production_report/usage_summary/platforms/usage_summary_mobile.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

class UsageSummaryPage extends StatelessWidget {
  final ReceiptsReportPeriod? initialPeriod;

  /// Null in the app: [UsageRecordsEnv.live] is used.
  final UsageRecordsEnv? env;

  const UsageSummaryPage({super.key, this.initialPeriod, this.env});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < tabletScreen) {
          return UsageSummaryMobile(initialPeriod: initialPeriod, env: env);
        } else {
          return UsageSummaryDesktop(initialPeriod: initialPeriod, env: env);
        }
      },
    );
  }
}
