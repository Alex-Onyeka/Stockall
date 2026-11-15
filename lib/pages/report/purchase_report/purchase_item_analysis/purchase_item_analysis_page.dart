import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/report/purchase_report/purchase_item_analysis/components/purchase_item_analysis_view.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/components/purchase_report_table_view.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

class PurchaseItemAnalysisPage extends StatelessWidget {
  final ReceiptsReportPeriod? initialPeriod;
  final PurchaseReportEnv? env;

  const PurchaseItemAnalysisPage({
    super.key,
    this.initialPeriod,
    this.env,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return PurchaseItemAnalysisView(
          isDesktop: constraints.maxWidth > mobileScreen,
          initialPeriod: initialPeriod,
          env: env,
        );
      },
    );
  }
}
