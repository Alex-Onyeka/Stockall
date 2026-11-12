import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/report/production_report/materials_analysis/platforms/materials_analysis_desktop.dart';
import 'package:stockall/pages/report/production_report/materials_analysis/platforms/materials_analysis_mobile.dart';
import 'package:stockall/pages/report/production_report/stock_shared/components/production_stock_env.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

class MaterialsAnalysisPage extends StatelessWidget {
  final ReceiptsReportPeriod? initialPeriod;
  final ProductionStockEnv? env;

  const MaterialsAnalysisPage({
    super.key,
    this.initialPeriod,
    this.env,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < tabletScreen) {
          return MaterialsAnalysisMobile(
            initialPeriod: initialPeriod,
            env: env,
          );
        }
        return MaterialsAnalysisDesktop(
          initialPeriod: initialPeriod,
          env: env,
        );
      },
    );
  }
}
