import 'package:flutter/material.dart';
import 'package:stockall/pages/report/customer_report/customer_report_table/class/customer_report_table_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

/// Reward ledger entries (`isBalance == false`): earnings from
/// sales receipts, redemptions and deductions. Reached only from a
/// customer, and only while reward earning is managed.
class CustomerRewardEarningsTable {
  static String directionLabel(CustomerLedgerRow row) =>
      row.isAdd ? 'Earned' : 'Redeemed';

  static List<CustomerLedgerRow> filterAndSort({
    required CustomerReportBase base,
    required String customerUuid,
    required ReceiptsReportPeriod period,
    required CustomerLedgerFilters filters,
    CustomerLedgerSortField sortField = CustomerLedgerSortField.createdAt,
    bool ascending = false,
    TimeOfDay? closingTime,
  }) {
    return CustomerLedgerQuery.filterAndSort(
      base: base,
      customerUuid: customerUuid,
      kind: CustomerLedgerKind.reward,
      period: period,
      filters: filters,
      sortField: sortField,
      ascending: ascending,
      closingTime: closingTime,
    );
  }

  static CustomerLedgerPage page({
    required CustomerReportBase base,
    required String customerUuid,
    required ReceiptsReportPeriod period,
    required CustomerLedgerFilters filters,
    CustomerLedgerSortField sortField = CustomerLedgerSortField.createdAt,
    bool ascending = false,
    int page = 1,
    TimeOfDay? closingTime,
  }) {
    return CustomerLedgerQuery.paginate(
      filterAndSort(
        base: base,
        customerUuid: customerUuid,
        period: period,
        filters: filters,
        sortField: sortField,
        ascending: ascending,
        closingTime: closingTime,
      ),
      page,
    );
  }
}

/// Reward names for the ledger totals.
extension CustomerRewardTotals on CustomerLedgerTotals {
  double get earned => added;

  /// Redeemed and deducted together.
  double get redeemed => deducted;
}
