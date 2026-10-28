import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_customers/temp_customers_class.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/report/customer_report/customer_analysis/platforms/customer_analysis_desktop.dart';
import 'package:stockall/pages/report/customer_report/customer_analysis/platforms/customer_analysis_mobile.dart';
import 'package:stockall/pages/report/customer_report/customer_report_table/components/customer_report_table_view.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

class CustomerAnalysisPage extends StatelessWidget {
  final TempCustomersClass customer;
  final ReceiptsReportPeriod? initialPeriod;

  /// Null in the app: [CustomerReportEnv.live] is used.
  final CustomerReportEnv? env;

  const CustomerAnalysisPage({
    super.key,
    required this.customer,
    this.initialPeriod,
    this.env,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < tabletScreen) {
          return CustomerAnalysisMobile(
            customer: customer,
            initialPeriod: initialPeriod,
            env: env,
          );
        } else {
          return CustomerAnalysisDesktop(
            customer: customer,
            initialPeriod: initialPeriod,
            env: env,
          );
        }
      },
    );
  }
}
