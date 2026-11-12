import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/report/production_report/material_history_summary/platforms/material_history_summary_desktop.dart';
import 'package:stockall/pages/report/production_report/material_history_summary/platforms/material_history_summary_mobile.dart';
import 'package:stockall/pages/report/production_report/stock_shared/components/production_stock_env.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

class MaterialHistorySummaryPage extends StatelessWidget {
  final ReceiptsReportPeriod? initialPeriod;
  final ProductionStockEnv? env;

  const MaterialHistorySummaryPage({
    super.key,
    this.initialPeriod,
    this.env,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < tabletScreen) {
          return MaterialHistorySummaryMobile(
            initialPeriod: initialPeriod,
            env: env,
          );
        }
        return MaterialHistorySummaryDesktop(
          initialPeriod: initialPeriod,
          env: env,
        );
      },
    );
  }
}
