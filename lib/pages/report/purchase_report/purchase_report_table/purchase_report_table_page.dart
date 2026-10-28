import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/class/purchase_report_table_logic.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/components/purchase_report_table_view.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/platforms/purchase_report_table_desktop.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/platforms/purchase_report_table_mobile.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

/// [initialFilters] and [initialPeriod] open the table on a given
/// set, e.g. one supplier's purchases.
class PurchaseReportTablePage extends StatelessWidget {
  final PurchaseReportFilters? initialFilters;
  final ReceiptsReportPeriod? initialPeriod;

  /// Null in the app: [PurchaseReportEnv.live] is used.
  final PurchaseReportEnv? env;

  const PurchaseReportTablePage({
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
          return PurchaseReportTableMobile(
            initialFilters: initialFilters,
            initialPeriod: initialPeriod,
            env: env,
          );
        } else {
          return PurchaseReportTableDesktop(
            initialFilters: initialFilters,
            initialPeriod: initialPeriod,
            env: env,
          );
        }
      },
    );
  }
}
