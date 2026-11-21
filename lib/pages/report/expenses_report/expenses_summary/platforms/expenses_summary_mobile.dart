import 'package:flutter/material.dart';
import 'package:stockall/pages/report/expenses_report/expenses_report_table/components/expenses_report_table_view.dart';
import 'package:stockall/pages/report/expenses_report/expenses_summary/components/expenses_summary_view.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

class ExpensesSummaryMobile extends StatelessWidget {
  final ReceiptsReportPeriod? initialPeriod;
  final ExpensesReportEnv? env;

  const ExpensesSummaryMobile({super.key, this.initialPeriod, this.env});

  @override
  Widget build(BuildContext context) {
    return ExpensesSummaryView(
      isDesktop: false,
      initialPeriod: initialPeriod,
      env: env,
    );
  }
}
