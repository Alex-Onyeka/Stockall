import 'package:flutter/material.dart';
import 'package:stockall/pages/report/production_report/production_records_table/class/production_records_table_logic.dart';
import 'package:stockall/pages/report/production_report/production_records_table/components/production_records_table_view.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

class ProductionRecordsTableDesktop extends StatelessWidget {
  final ProductionRecordsFilters? initialFilters;
  final ReceiptsReportPeriod? initialPeriod;
  final ProductionRecordsEnv? env;

  const ProductionRecordsTableDesktop({
    super.key,
    this.initialFilters,
    this.initialPeriod,
    this.env,
  });

  @override
  Widget build(BuildContext context) {
    return ProductionRecordsTableView(
      isDesktop: true,
      initialFilters: initialFilters,
      initialPeriod: initialPeriod,
      env: env,
    );
  }
}
