import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/report/production_report/usage_records_table/class/usage_records_table_logic.dart';
import 'package:stockall/pages/report/production_report/usage_records_table/components/usage_records_table_view.dart';
import 'package:stockall/pages/report/production_report/usage_records_table/platforms/usage_records_table_desktop.dart';
import 'package:stockall/pages/report/production_report/usage_records_table/platforms/usage_records_table_mobile.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

/// [initialFilters] and [initialPeriod] open the table on a given set,
/// e.g. one material's usage from the summary.
class UsageRecordsTablePage extends StatelessWidget {
  final UsageRecordsFilters? initialFilters;
  final ReceiptsReportPeriod? initialPeriod;

  /// Null in the app: [UsageRecordsEnv.live] is used.
  final UsageRecordsEnv? env;

  const UsageRecordsTablePage({
    super.key,
    this.initialFilters,
    this.initialPeriod,
    this.env,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < tabletScreen) {
          return UsageRecordsTableMobile(
            initialFilters: initialFilters,
            initialPeriod: initialPeriod,
            env: env,
          );
        } else {
          return UsageRecordsTableDesktop(
            initialFilters: initialFilters,
            initialPeriod: initialPeriod,
            env: env,
          );
        }
      },
    );
  }
}
