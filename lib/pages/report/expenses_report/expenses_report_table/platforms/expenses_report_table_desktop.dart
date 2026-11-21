import 'package:flutter/material.dart';
import 'package:stockall/pages/report/expenses_report/expenses_report_table/class/expenses_report_table_logic.dart';
import 'package:stockall/pages/report/expenses_report/expenses_report_table/components/expenses_report_table_view.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

class ExpensesReportTableDesktop extends StatelessWidget {
  final ExpensesReportFilters? initialFilters;
  final ReceiptsReportPeriod? initialPeriod;
  final bool? initialIncludeStockPurchases;
  final ExpensesReportEnv? env;

  const ExpensesReportTableDesktop({
    super.key,
    this.initialFilters,
    this.initialPeriod,
    this.initialIncludeStockPurchases,
    this.env,
  });

  @override
  Widget build(BuildContext context) {
    return ExpensesReportTableView(
      isDesktop: true,
      initialFilters: initialFilters,
      initialPeriod: initialPeriod,
      initialIncludeStockPurchases: initialIncludeStockPurchases,
      env: env,
    );
  }
}
