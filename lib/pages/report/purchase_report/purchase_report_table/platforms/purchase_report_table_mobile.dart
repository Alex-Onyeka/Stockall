import 'package:flutter/material.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/class/purchase_report_table_logic.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/components/purchase_report_table_view.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

class PurchaseReportTableMobile extends StatelessWidget {
  final PurchaseReportFilters? initialFilters;
  final ReceiptsReportPeriod? initialPeriod;
  final PurchaseReportEnv? env;

  const PurchaseReportTableMobile({
    super.key,
    this.initialFilters,
    this.initialPeriod,
    this.env,
  });

  @override
  Widget build(BuildContext context) {
    return PurchaseReportTableView(
      isDesktop: false,
      initialFilters: initialFilters,
      initialPeriod: initialPeriod,
      env: env,
    );
  }
}
