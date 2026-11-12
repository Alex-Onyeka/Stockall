import 'package:flutter/material.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/production_stock_model.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/stock_history_logic.dart';
import 'package:stockall/pages/report/production_report/stock_shared/components/production_stock_env.dart';
import 'package:stockall/pages/report/production_report/stock_shared/components/stock_history_view.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

class MaterialHistoryTableDesktop extends StatelessWidget {
  final ProductionHistoryFilters? initialFilters;
  final ReceiptsReportPeriod? initialPeriod;
  final ProductionStockEnv? env;

  const MaterialHistoryTableDesktop({
    super.key,
    this.initialFilters,
    this.initialPeriod,
    this.env,
  });

  @override
  Widget build(BuildContext context) {
    return StockHistoryView(
      isDesktop: true,
      kind: ProductionStockKind.material,
      initialFilters: initialFilters,
      initialPeriod: initialPeriod,
      env: env,
    );
  }
}
