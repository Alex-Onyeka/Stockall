import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/report/customer_report/customer_report_table/class/customer_report_table_logic.dart';
import 'package:stockall/pages/report/customer_report/customer_report_table/components/customer_report_table_view.dart';
import 'package:stockall/pages/report/customer_report/customer_report_table/platforms/customer_report_table_desktop.dart';
import 'package:stockall/pages/report/customer_report/customer_report_table/platforms/customer_report_table_mobile.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

class CustomerReportTablePage extends StatelessWidget {
  final CustomerReportFilters? initialFilters;
  final ReceiptsReportPeriod? initialPeriod;

  /// Null in the app: [CustomerReportEnv.live] is used.
  final CustomerReportEnv? env;

  const CustomerReportTablePage({
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
          return CustomerReportTableMobile(
            initialFilters: initialFilters,
            initialPeriod: initialPeriod,
            env: env,
          );
        } else {
          return CustomerReportTableDesktop(
            initialFilters: initialFilters,
            initialPeriod: initialPeriod,
            env: env,
          );
        }
      },
    );
  }
}
