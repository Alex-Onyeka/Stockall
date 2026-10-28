import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_customers/temp_customers_class.dart';
import 'package:stockall/pages/report/customer_report/customer_reward_earnings/components/customer_reward_earnings_view.dart';
import 'package:stockall/pages/report/customer_report/customer_report_table/components/customer_report_table_view.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

class CustomerRewardEarningsMobile extends StatelessWidget {
  final TempCustomersClass customer;
  final ReceiptsReportPeriod? initialPeriod;
  final CustomerReportEnv? env;

  const CustomerRewardEarningsMobile({
    super.key,
    required this.customer,
    this.initialPeriod,
    this.env,
  });

  @override
  Widget build(BuildContext context) {
    return CustomerRewardEarningsView(
      isDesktop: false,
      customer: customer,
      initialPeriod: initialPeriod,
      env: env,
    );
  }
}
