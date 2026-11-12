import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/report/production_report/production_records_table/components/production_records_table_view.dart';
import 'package:stockall/pages/report/production_report/production_summary/platforms/production_summary_desktop.dart';
import 'package:stockall/pages/report/production_report/production_summary/platforms/production_summary_mobile.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

class ProductionSummaryPage extends StatelessWidget {
  final ReceiptsReportPeriod? initialPeriod;

  /// Null in the app: [ProductionRecordsEnv.live] is used.
  final ProductionRecordsEnv? env;

  const ProductionSummaryPage({super.key, this.initialPeriod, this.env});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < tabletScreen) {
          return ProductionSummaryMobile(initialPeriod: initialPeriod, env: env);
        } else {
          return ProductionSummaryDesktop(initialPeriod: initialPeriod, env: env);
        }
      },
    );
  }
}
