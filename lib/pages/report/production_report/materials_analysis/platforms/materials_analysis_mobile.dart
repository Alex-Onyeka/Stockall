import 'package:flutter/material.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/production_stock_model.dart';
import 'package:stockall/pages/report/production_report/stock_shared/components/production_stock_env.dart';
import 'package:stockall/pages/report/production_report/stock_shared/components/stock_analysis_view.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

class MaterialsAnalysisMobile extends StatelessWidget {
  final ReceiptsReportPeriod? initialPeriod;
  final ProductionStockEnv? env;

  const MaterialsAnalysisMobile({
    super.key,
    this.initialPeriod,
    this.env,
  });

  @override
  Widget build(BuildContext context) {
    return StockAnalysisView(
      isDesktop: false,
      kind: ProductionStockKind.material,
      initialPeriod: initialPeriod,
      env: env,
    );
  }
}
