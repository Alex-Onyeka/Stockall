import 'package:flutter/material.dart';
import 'package:stockall/pages/report/production_report/usage_records_table/components/usage_records_table_view.dart';
import 'package:stockall/pages/report/production_report/usage_summary/components/usage_summary_view.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

class UsageSummaryMobile extends StatelessWidget {
  final ReceiptsReportPeriod? initialPeriod;
  final UsageRecordsEnv? env;

  const UsageSummaryMobile({super.key, this.initialPeriod, this.env});

  @override
  Widget build(BuildContext context) {
    return UsageSummaryView(
      isDesktop: false,
      initialPeriod: initialPeriod,
      env: env,
    );
  }
}
