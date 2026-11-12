import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/report/production_report/produced_items_table/platforms/produced_items_table_desktop.dart';
import 'package:stockall/pages/report/production_report/produced_items_table/platforms/produced_items_table_mobile.dart';
import 'package:stockall/pages/report/production_report/stock_shared/class/stock_items_logic.dart';
import 'package:stockall/pages/report/production_report/stock_shared/components/production_stock_env.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

/// [initialFilters] and [initialPeriod] open the page on a given set,
/// e.g. one item, department or category from the analysis.
class ProducedItemsTablePage extends StatelessWidget {
  final ProductionStockFilters? initialFilters;
  final ReceiptsReportPeriod? initialPeriod;
  final ProductionStockEnv? env;

  const ProducedItemsTablePage({
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
          return ProducedItemsTableMobile(
            initialFilters: initialFilters,
            initialPeriod: initialPeriod,
            env: env,
          );
        }
        return ProducedItemsTableDesktop(
            initialFilters: initialFilters,
          initialPeriod: initialPeriod,
          env: env,
        );
      },
    );
  }
}
