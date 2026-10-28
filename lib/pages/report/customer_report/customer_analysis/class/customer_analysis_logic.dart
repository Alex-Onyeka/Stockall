import 'package:stockall/classes/temp_customers/temp_customers_class.dart';
import 'package:stockall/pages/report/customer_report/customer_report_table/class/customer_report_table_logic.dart';
import 'package:stockall/pages/report/invoice_report/invoice_report_table/class/invoice_report_table_logic.dart';
import 'package:stockall/pages/report/order_report/order_report_table/class/order_report_table_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

/// Records shown in each section before "See all".
const int customerAnalysisRecentCount = 5;

/// One customer's numbers and most recent records in one period.
/// The KPIs are the customer's table row, so both pages agree.
class CustomerAnalysis {
  final CustomerReportRow summary;

  /// Newest first, at most [customerAnalysisRecentCount] each.
  final List<ReceiptsReportRow> recentReceipts;
  final List<InvoiceReportRow> recentInvoices;
  final List<OrderReportRow> recentOrders;

  /// Empty while the section is hidden ([showReward] /
  /// [showAccount]).
  final List<CustomerLedgerRow> recentRewards;
  final List<CustomerLedgerRow> recentAccountTransactions;

  /// Over the whole period, not just the recent records.
  final CustomerLedgerTotals rewardTotals;
  final CustomerLedgerTotals accountTotals;

  final bool showAccount;
  final bool showReward;

  const CustomerAnalysis({
    required this.summary,
    required this.recentReceipts,
    required this.recentInvoices,
    required this.recentOrders,
    required this.recentRewards,
    required this.recentAccountTransactions,
    required this.rewardTotals,
    required this.accountTotals,
    required this.showAccount,
    required this.showReward,
  });

  factory CustomerAnalysis.build({
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
      recentReceipts: _recent(slice.receiptsOf(key)),
      recentInvoices: _recent(slice.invoicesOf(key)),
      recentOrders: _recent(slice.ordersOf(key)),
      recentRewards: _recent(rewards),
      recentAccountTransactions: _recent(account),
      rewardTotals: CustomerLedgerTotals.of(rewards),
      accountTotals: CustomerLedgerTotals.of(account),
      showAccount: access.showAccount,
      showReward: access.showReward,
    );
  }

  /// The slice lists are already newest first.
  static List<T> _recent<T>(List<T> rows) =>
      rows.take(customerAnalysisRecentCount).toList();

  String get customerUuid => summary.uuid;
}

/// What each "See all" link opens: the report's own table,
/// filtered to the customer, on the analysis page's period.
class CustomerSeeAll {
  /// `ReceiptsReportMainPage(initialFilters:, initialPeriod:)`.
  static ReceiptsReportFilters receiptsFilters(String customerUuid) =>
      ReceiptsReportFilters(customerKey: customerUuid);

  /// `InvoiceReportTablePage(initialFilters:)`: the table has no
  /// period parameter, so the period travels as
  /// [InvoiceReportFilters.dateRange] (All time is null).
  static InvoiceReportFilters invoiceFilters(
    String customerUuid,
    ReceiptsReportPeriod period,
  ) => InvoiceReportFilters(
    customerUuid: customerUuid,
    dateRange: customerReportDateRange(period),
  );

  /// `OrderReportTablePage(initialFilters:, initialPeriod:)`.
  static OrderReportFilters orderFilters(String customerUuid) =>
      OrderReportFilters(customerKey: customerUuid);
}
