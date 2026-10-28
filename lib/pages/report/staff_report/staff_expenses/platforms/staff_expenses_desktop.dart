import 'package:flutter/material.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/staff_report/staff_expenses/components/staff_expenses_view.dart';
import 'package:stockall/pages/report/staff_report/staff_report_table/components/staff_report_table_view.dart';

class StaffExpensesDesktop extends StatelessWidget {
  final String staffKey;
  final ReceiptsReportPeriod? initialPeriod;
  final StaffReportEnv? env;

  const StaffExpensesDesktop({
    super.key,
    required this.staffKey,
    this.initialPeriod,
    this.env,
  });

  @override
  Widget build(BuildContext context) {
    return StaffExpensesView(
      isDesktop: true,
      staffKey: staffKey,
      initialPeriod: initialPeriod,
      env: env,
    );
  }
}
