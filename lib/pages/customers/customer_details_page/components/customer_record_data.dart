// The customer page's Print Record: the Customer Analysis export for
// one customer, with every record of the period rather than the
// latest 5 (as the staff page's Print Report does with the Staff
// Analysis). Account and reward parts follow the report's gates
// (shop settings and View Customers Account), so a hidden part has no
// section, figure or rows.
//
// Pure Dart: no BuildContext and no providers, so it can be tested.

import 'package:stockall/classes/temp_customers/temp_customers_class.dart';
import 'package:stockall/pages/report/components/export/report_export_spec.dart';
import 'package:stockall/pages/report/customer_report/customer_analysis/class/customer_analysis_export_spec.dart';
import 'package:stockall/pages/report/customer_report/customer_analysis/class/customer_analysis_logic.dart';
import 'package:stockall/pages/report/customer_report/customer_report_table/class/customer_report_table_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

/// [customer] on [period], every record. Hidden ledgers stay empty.
CustomerAnalysis customerRecordAnalysis({
  required TempCustomersClass customer,
  required CustomerReportSlice slice,
}) {
  final access = slice.base.access;
  final key = customer.uuid;
  final rewards =
      access.showReward ? slice.rewardsOf(key) : const <CustomerLedgerRow>[];
  final account =
      access.showAccount
          ? slice.accountTransactionsOf(key)
          : const <CustomerLedgerRow>[];
  return CustomerAnalysis(
    summary: CustomerReportRowBuilder.build(customer: customer, slice: slice),
    recentReceipts: slice.receiptsOf(key),
    recentInvoices: slice.invoicesOf(key),
    recentOrders: slice.ordersOf(key),
    recentRewards: rewards,
    recentAccountTransactions: account,
    rewardTotals: CustomerLedgerTotals.of(rewards),
    accountTotals: CustomerLedgerTotals.of(account),
    showAccount: access.showAccount,
    showReward: access.showReward,
  );
}

/// The Print Record export. [period] defaults to the report's own
/// rule ([CustomerReportAccess.initialPeriod]): All time with View
/// Date, otherwise today's business day.
ReportExportSpec customerRecordSpec({
  required CustomerReportBase base,
  required TempCustomersClass customer,
  required String currency,
  ReceiptsReportPeriod? period,
}) {
  final p = period ?? base.access.initialPeriod();
  return customerAnalysisExportSpec(
    analysis: customerRecordAnalysis(
      customer: customer,
      slice: CustomerReportSlice.of(base, p),
    ),
    period: p,
    showTotalBalance: base.access.showTotalBalance,
    currency: currency,
  );
}
