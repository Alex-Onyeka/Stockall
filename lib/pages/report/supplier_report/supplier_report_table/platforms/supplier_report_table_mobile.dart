import 'package:flutter/material.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/supplier_report/supplier_report_table/class/supplier_report_table_logic.dart';
import 'package:stockall/pages/report/supplier_report/supplier_report_table/components/supplier_report_table_view.dart';

class SupplierReportTableMobile extends StatelessWidget {
  final SupplierReportFilters? initialFilters;
  final ReceiptsReportPeriod? initialPeriod;
  final SupplierReportEnv? env;

  const SupplierReportTableMobile({
    super.key,
    this.initialFilters,
    this.initialPeriod,
    this.env,
  });

  @override
  Widget build(BuildContext context) {
    return SupplierReportTableView(
      isDesktop: false,
      initialFilters: initialFilters,
      initialPeriod: initialPeriod,
      env: env,
    );
  }
}
