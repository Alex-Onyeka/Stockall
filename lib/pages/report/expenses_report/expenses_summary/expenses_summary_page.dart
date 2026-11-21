import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/report/expenses_report/expenses_report_table/components/expenses_report_table_view.dart';
import 'package:stockall/pages/report/expenses_report/expenses_summary/platforms/expenses_summary_desktop.dart';
import 'package:stockall/pages/report/expenses_report/expenses_summary/platforms/expenses_summary_mobile.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

class ExpensesSummaryPage extends StatelessWidget {
  final ReceiptsReportPeriod? initialPeriod;

  /// Null in the app: [ExpensesReportEnv.live] is used.
  final ExpensesReportEnv? env;

  const ExpensesSummaryPage({super.key, this.initialPeriod, this.env});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < tabletScreen) {
          return ExpensesSummaryMobile(initialPeriod: initialPeriod, env: env);
        } else {
          return ExpensesSummaryDesktop(initialPeriod: initialPeriod, env: env);
        }
      },
    );
  }
}
