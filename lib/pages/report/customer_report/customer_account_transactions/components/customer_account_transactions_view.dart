import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_customers/temp_customers_class.dart';
import 'package:stockall/pages/report/customer_report/customer_report_table/class/customer_report_table_logic.dart';
import 'package:stockall/pages/report/customer_report/customer_report_table/components/customer_ledger_table_view.dart';
import 'package:stockall/pages/report/customer_report/customer_report_table/components/customer_report_table_view.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

/// Account Transactions table of one customer (desktop + mobile).
/// The table is the shared [CustomerLedgerTableView].
class CustomerAccountTransactionsView extends StatelessWidget {
  final bool isDesktop;
  final TempCustomersClass customer;
  final ReceiptsReportPeriod? initialPeriod;

  /// Null in the app: [CustomerReportEnv.live] is used.
  final CustomerReportEnv? env;

  const CustomerAccountTransactionsView({
    super.key,
    required this.isDesktop,
    required this.customer,
    this.initialPeriod,
    this.env,
  });

  @override
  Widget build(BuildContext context) {
    return CustomerLedgerTableView(
      kind: CustomerLedgerKind.account,
      isDesktop: isDesktop,
      customer: customer,
      initialPeriod: initialPeriod,
      env: env,
    );
  }
}
