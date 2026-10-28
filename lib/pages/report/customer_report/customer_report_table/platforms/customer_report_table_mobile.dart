import 'package:flutter/material.dart';
import 'package:stockall/pages/report/customer_report/customer_report_table/class/customer_report_table_logic.dart';
import 'package:stockall/pages/report/customer_report/customer_report_table/components/customer_report_table_view.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

class CustomerReportTableMobile extends StatelessWidget {
  final CustomerReportFilters? initialFilters;
  final ReceiptsReportPeriod? initialPeriod;
  final CustomerReportEnv? env;

  const CustomerReportTableMobile({
    super.key,
    this.initialFilters,
    this.initialPeriod,
    this.env,
  });

  @override
  Widget build(BuildContext context) {
    return CustomerReportTableView(
      isDesktop: false,
      initialFilters: initialFilters,
      initialPeriod: initialPeriod,
      env: env,
    );
  }
}
