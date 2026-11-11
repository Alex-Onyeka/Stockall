import 'package:flutter/material.dart';
import 'package:stockall/pages/report/production_report/usage_records_table/components/usage_records_table_view.dart';
import 'package:stockall/pages/report/production_report/usage_summary/components/usage_summary_view.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

class UsageSummaryDesktop extends StatelessWidget {
  final ReceiptsReportPeriod? initialPeriod;
  final UsageRecordsEnv? env;

  const UsageSummaryDesktop({super.key, this.initialPeriod, this.env});

  @override
  Widget build(BuildContext context) {
    return UsageSummaryView(
      isDesktop: true,
      initialPeriod: initialPeriod,
      env: env,
    );
  }
}
