import 'package:flutter/material.dart';
import 'package:stockall/pages/report/production_report/production_records_table/components/production_records_table_view.dart';
import 'package:stockall/pages/report/production_report/production_summary/components/production_summary_view.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

class ProductionSummaryDesktop extends StatelessWidget {
  final ReceiptsReportPeriod? initialPeriod;
  final ProductionRecordsEnv? env;

  const ProductionSummaryDesktop({super.key, this.initialPeriod, this.env});

  @override
  Widget build(BuildContext context) {
    return ProductionSummaryView(
      isDesktop: true,
      initialPeriod: initialPeriod,
      env: env,
    );
  }
}
