import 'package:stockall/pages/report/customer_report/customer_report_table/class/customer_report_table_logic.dart';
import 'package:stockall/pages/report/invoice_report/invoice_report_table/class/invoice_report_table_logic.dart';
import 'package:stockall/pages/report/order_report/order_report_table/class/order_report_table_logic.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/class/purchase_report_table_logic.dart';
import 'package:stockall/pages/report/sales_report_/receipts_report_main/class/receipts_report_main_logic.dart';
import 'package:stockall/pages/report/staff_report/staff_report_table/class/staff_report_table_logic.dart';

/// Records shown in each section before "See all".
const int staffAnalysisRecentCount = 5;

/// One staff's numbers and most recent records in one period. The
/// KPIs are the staff's table row, so both pages agree.
class StaffAnalysis {
  final StaffReportRow summary;

  /// Newest first, at most [staffAnalysisRecentCount] each. Empty
  /// while the section is hidden ([showOrders] etc.).
  final List<ReceiptsReportRow> recentReceipts;
  final List<InvoiceReportRow> recentInvoices;
  final List<OrderReportRow> recentOrders;
  final List<PurchaseReportRow> recentPurchases;
  final List<StaffExpenseRow> recentExpenses;

  final bool showOrders;
  final bool showPurchases;
  final bool showExpenses;

  const StaffAnalysis({
    required this.summary,
    required this.recentReceipts,
    required this.recentInvoices,
    required this.recentOrders,
    required this.recentPurchases,
    required this.recentExpenses,
    required this.showOrders,
    required this.showPurchases,
    required this.showExpenses,
  });

  factory StaffAnalysis.build({
    required String staffKey,
    required StaffReportSlice slice,
  }) {
    final access = slice.base.access;
    return StaffAnalysis(
      summary: StaffReportRowBuilder.single(staffKey: staffKey, slice: slice),
      recentReceipts: _recent(slice.receiptsOf(staffKey)),
      recentInvoices: _recent(slice.invoicesOf(staffKey)),
      recentOrders: _recent(slice.ordersOf(staffKey)),
      recentPurchases: _recent(slice.purchasesOf(staffKey)),
      recentExpenses: _recent(slice.expensesOf(staffKey)),
      showOrders: access.showOrders,
      showPurchases: access.showPurchases,
      showExpenses: access.showExpenses,
    );
  }

  /// The slice lists are already newest first.
  static List<T> _recent<T>(List<T> rows) =>
      rows.take(staffAnalysisRecentCount).toList();

  String get staffKey => summary.key;
}

/// What each "See all" link opens: the report's own table,
/// filtered to the staff, on the analysis page's period.
class StaffSeeAll {
  /// `ReceiptsReportMainPage(initialFilters:, initialPeriod:)`.
  static ReceiptsReportFilters receiptsFilters(String staffKey) =>
      ReceiptsReportFilters(staffKey: staffKey);

  /// `InvoiceReportTablePage(initialFilters:)`: the table has no
  /// period parameter, so the period travels as
  /// [InvoiceReportFilters.dateRange] (All time is null).
  static InvoiceReportFilters invoiceFilters(
    String staffKey,
    ReceiptsReportPeriod period,
  ) => InvoiceReportFilters(
    staffId: staffKey,
    dateRange: customerReportDateRange(period),
  );

  /// `OrderReportTablePage(initialFilters:, initialPeriod:)`.
  static OrderReportFilters orderFilters(String staffKey) =>
      OrderReportFilters(staffKey: staffKey);

  /// `PurchaseReportTablePage(initialFilters:, initialPeriod:)`.
  static PurchaseReportFilters purchaseFilters(String staffKey) =>
      PurchaseReportFilters(staffKey: staffKey);
}
