import 'package:flutter/material.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/components/purchase_report_table_view.dart';
import 'package:stockall/pages/report/purchase_report/purchase_summary/components/purchase_summary_view.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

class PurchaseSummaryDesktop extends StatelessWidget {
  final ReceiptsReportPeriod? initialPeriod;
  final PurchaseReportEnv? env;

  const PurchaseSummaryDesktop({
    super.key,
    this.initialPeriod,
    this.env,
  });

  @override
  Widget build(BuildContext context) {
    return PurchaseSummaryView(
      isDesktop: true,
      initialPeriod: initialPeriod,
      env: env,
    );
  }
}
