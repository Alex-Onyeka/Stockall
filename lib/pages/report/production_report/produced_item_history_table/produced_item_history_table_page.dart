import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/report/production_report/produced_item_history_table/platforms/produced_item_history_table_desktop.dart';
import 'package:stockall/pages/report/production_report/produced_item_history_table/platforms/produced_item_history_table_mobile.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/stock_history_logic.dart';
import 'package:stockall/pages/report/production_report/stock_shared/components/production_stock_env.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

/// [initialFilters] and [initialPeriod] open the page on a given set,
/// e.g. one item's records from the history summary.
class ProducedItemHistoryTablePage extends StatelessWidget {
  final ProductionHistoryFilters? initialFilters;
  final ReceiptsReportPeriod? initialPeriod;
  final ProductionStockEnv? env;

  const ProducedItemHistoryTablePage({
    super.key,
    this.initialFilters,
    this.initialPeriod,
    this.env,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < tabletScreen) {
          return ProducedItemHistoryTableMobile(
            initialFilters: initialFilters,
            initialPeriod: initialPeriod,
            env: env,
          );
        }
        return ProducedItemHistoryTableDesktop(
            initialFilters: initialFilters,
          initialPeriod: initialPeriod,
          env: env,
        );
      },
    );
  }
}
