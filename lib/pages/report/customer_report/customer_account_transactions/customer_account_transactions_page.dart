import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_customers/temp_customers_class.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/report/customer_report/customer_account_transactions/platforms/customer_account_transactions_desktop.dart';
import 'package:stockall/pages/report/customer_report/customer_account_transactions/platforms/customer_account_transactions_mobile.dart';
import 'package:stockall/pages/report/customer_report/customer_report_table/components/customer_report_table_view.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

/// Account Transactions table of one customer. Only reachable from the
/// Customer Analysis page.
class CustomerAccountTransactionsPage extends StatelessWidget {
  final TempCustomersClass customer;
  final ReceiptsReportPeriod? initialPeriod;

  /// Null in the app: [CustomerReportEnv.live] is used.
  final CustomerReportEnv? env;

  const CustomerAccountTransactionsPage({
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
          return CustomerAccountTransactionsMobile(
            customer: customer,
            initialPeriod: initialPeriod,
            env: env,
          );
        } else {
          return CustomerAccountTransactionsDesktop(
            customer: customer,
            initialPeriod: initialPeriod,
            env: env,
          );
        }
      },
    );
  }
}
