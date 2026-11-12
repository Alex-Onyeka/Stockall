import 'package:flutter/material.dart';
import 'package:stockall/pages/report/production_report/usage_records_table/class/usage_records_table_logic.dart';
import 'package:stockall/pages/report/production_report/usage_records_table/components/usage_records_table_view.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

class UsageRecordsTableDesktop extends StatelessWidget {
  final UsageRecordsFilters? initialFilters;
  final ReceiptsReportPeriod? initialPeriod;
  final UsageRecordsEnv? env;

  const UsageRecordsTableDesktop({
    super.key,
    this.initialFilters,
    this.initialPeriod,
    this.env,
  });

  @override
  Widget build(BuildContext context) {
    return UsageRecordsTableView(
      isDesktop: true,
      initialFilters: initialFilters,
      initialPeriod: initialPeriod,
      env: env,
    );
  }
}
