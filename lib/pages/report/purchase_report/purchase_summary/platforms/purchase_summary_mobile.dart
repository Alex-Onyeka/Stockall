import 'package:flutter/material.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/components/purchase_report_table_view.dart';
import 'package:stockall/pages/report/purchase_report/purchase_summary/components/purchase_summary_view.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

class PurchaseSummaryMobile extends StatelessWidget {
  final ReceiptsReportPeriod? initialPeriod;
  final PurchaseReportEnv? env;

  const PurchaseSummaryMobile({
    super.key,
    this.initialPeriod,
    this.env,
  });

  @override
  Widget build(BuildContext context) {
    return PurchaseSummaryView(
      isDesktop: false,
      initialPeriod: initialPeriod,
      env: env,
    );
  }
}
