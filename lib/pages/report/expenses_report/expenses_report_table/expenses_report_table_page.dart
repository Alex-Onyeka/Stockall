import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/report/expenses_report/expenses_report_table/class/expenses_report_table_logic.dart';
import 'package:stockall/pages/report/expenses_report/expenses_report_table/components/expenses_report_table_view.dart';
import 'package:stockall/pages/report/expenses_report/expenses_report_table/platforms/expenses_report_table_desktop.dart';
import 'package:stockall/pages/report/expenses_report/expenses_report_table/platforms/expenses_report_table_mobile.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

/// [initialFilters], [initialPeriod] and [initialIncludeStockPurchases]
/// open the table on a given set, e.g. one analysis row's expenses.
class ExpensesReportTablePage extends StatelessWidget {
  final ExpensesReportFilters? initialFilters;
  final ReceiptsReportPeriod? initialPeriod;

  /// "Include stock purchases" to start with. Null: on.
  final bool? initialIncludeStockPurchases;

  /// Null in the app: [ExpensesReportEnv.live] is used.
  final ExpensesReportEnv? env;

  const ExpensesReportTablePage({
    super.key,
    this.initialFilters,
    this.initialPeriod,
    this.initialIncludeStockPurchases,
    this.env,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < tabletScreen) {
          return ExpensesReportTableMobile(
            initialFilters: initialFilters,
            initialPeriod: initialPeriod,
            initialIncludeStockPurchases: initialIncludeStockPurchases,
            env: env,
          );
        } else {
          return ExpensesReportTableDesktop(
            initialFilters: initialFilters,
            initialPeriod: initialPeriod,
            initialIncludeStockPurchases: initialIncludeStockPurchases,
            env: env,
          );
        }
      },
    );
  }
}
