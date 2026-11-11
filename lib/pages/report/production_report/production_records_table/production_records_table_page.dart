import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/report/production_report/production_records_table/class/production_records_table_logic.dart';
import 'package:stockall/pages/report/production_report/production_records_table/components/production_records_table_view.dart';
import 'package:stockall/pages/report/production_report/production_records_table/platforms/production_records_table_desktop.dart';
import 'package:stockall/pages/report/production_report/production_records_table/platforms/production_records_table_mobile.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

/// [initialFilters] and [initialPeriod] open the table on a given set,
/// e.g. one output item's records from the summary.
class ProductionRecordsTablePage extends StatelessWidget {
  final ProductionRecordsFilters? initialFilters;
  final ReceiptsReportPeriod? initialPeriod;

  /// Null in the app: [ProductionRecordsEnv.live] is used.
  final ProductionRecordsEnv? env;

  const ProductionRecordsTablePage({
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
          return ProductionRecordsTableMobile(
            initialFilters: initialFilters,
            initialPeriod: initialPeriod,
            env: env,
          );
        } else {
          return ProductionRecordsTableDesktop(
            initialFilters: initialFilters,
            initialPeriod: initialPeriod,
            env: env,
          );
        }
      },
    );
  }
}
