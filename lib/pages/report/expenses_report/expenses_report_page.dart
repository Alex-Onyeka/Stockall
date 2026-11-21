import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/report/expenses_report/platforms/expenses_report_desktop.dart';
import 'package:stockall/pages/report/expenses_report/platforms/expenses_report_mobile.dart';

/// The Expenses Report hub: the table and the analysis. Neither page
/// links to the other; the analysis opens the table on its rows.
class ExpensesReportPage extends StatelessWidget {
  const ExpensesReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < mobileScreen) {
          return const ExpensesReportMobile();
        } else {
          return const ExpensesReportDesktop();
        }
      },
    );
  }
}
