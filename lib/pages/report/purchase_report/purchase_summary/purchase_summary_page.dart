import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/components/purchase_report_table_view.dart';
import 'package:stockall/pages/report/purchase_report/purchase_summary/platforms/purchase_summary_desktop.dart';
import 'package:stockall/pages/report/purchase_report/purchase_summary/platforms/purchase_summary_mobile.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

class PurchaseSummaryPage extends StatelessWidget {
  final ReceiptsReportPeriod? initialPeriod;

  /// Null in the app: [PurchaseReportEnv.live] is used.
  final PurchaseReportEnv? env;

  const PurchaseSummaryPage({
    super.key,
    this.initialPeriod,
    this.env,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < tabletScreen) {
          return PurchaseSummaryMobile(
            initialPeriod: initialPeriod,
            env: env,
          );
        } else {
          return PurchaseSummaryDesktop(
            initialPeriod: initialPeriod,
            env: env,
          );
        }
      },
    );
  }
}
