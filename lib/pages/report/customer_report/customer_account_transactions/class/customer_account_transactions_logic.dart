import 'package:flutter/material.dart';
import 'package:stockall/pages/report/customer_report/customer_report_table/class/customer_report_table_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';

/// Customer account ledger entries (`isBalance` true or null):
/// manual credits and debits and purchases paid from the account.
/// Reached only from a customer, and only while customer accounts
/// are managed.
class CustomerAccountTransactionsTable {
  static String directionLabel(CustomerLedgerRow row) =>
      row.isAdd ? 'Credit' : 'Debit';

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
      kind: CustomerLedgerKind.account,
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

/// Account names for the ledger totals.
extension CustomerAccountTotals on CustomerLedgerTotals {
  double get credits => added;
  double get debits => deducted;
}
