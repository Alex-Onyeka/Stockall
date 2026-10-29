import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/staff_report/staff_expenses/platforms/staff_expenses_desktop.dart';
import 'package:stockall/pages/report/staff_report/staff_expenses/platforms/staff_expenses_mobile.dart';
import 'package:stockall/pages/report/staff_report/staff_report_table/components/staff_report_table_view.dart';

/// One staff's expenses. Reached only from the staff's analysis
/// ("See all" on Expenses).
class StaffExpensesPage extends StatelessWidget {
  /// `TempUserClass.userId`, the staff id every record carries.
  final String staffKey;
  final ReceiptsReportPeriod? initialPeriod;

  /// Null in the app: [StaffReportEnv.live] is used.
  final StaffReportEnv? env;

  const StaffExpensesPage({
    super.key,
    required this.staffKey,
    this.initialPeriod,
    this.env,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < tabletScreen) {
          return StaffExpensesMobile(
            staffKey: staffKey,
            initialPeriod: initialPeriod,
            env: env,
          );
        } else {
          return StaffExpensesDesktop(
            staffKey: staffKey,
            initialPeriod: initialPeriod,
            env: env,
          );
        }
      },
    );
  }
}
