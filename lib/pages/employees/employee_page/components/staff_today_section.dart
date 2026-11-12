// The staff page's "today" sections, in the customer page's section
// style: the latest records of each kind and "View All", which opens
// the kind's report table on today, filtered to the staff.

import 'package:flutter/material.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/customers/customer_details_page/components/customer_invoices_section.dart';
import 'package:stockall/pages/customers/customer_details_page/components/customer_orders_section.dart';
import 'package:stockall/pages/customers/customer_details_page/components/customer_sales_section.dart';
import 'package:stockall/pages/employees/employee_page/components/staff_page_data.dart';
import 'package:stockall/pages/report/purchase_report/purchase_report_table/class/purchase_report_table_logic.dart';
import 'package:stockall/pages/report/staff_report/staff_analysis/class/staff_analysis_logic.dart';
import 'package:stockall/pages/report/staff_report/staff_report_table/class/staff_report_table_logic.dart';
import 'package:stockall/pages/report/staff_report/staff_report_table/components/staff_report_table_view.dart';
import 'package:stockall/providers/theme_provider.dart';

/// One section: icon, "TODAY'S …" with the day's count, "View All ›",
/// then [rows] or the empty state.
class StaffTodaySection extends StatelessWidget {
  final String id;
  final String title;
  final IconData icon;
  final int count;
  final String emptyText;
  final VoidCallback onViewAll;
  final List<Widget> rows;

  const StaffTodaySection({
    super.key,
    required this.id,
    required this.title,
    required this.icon,
    required this.count,
    required this.emptyText,
    required this.onViewAll,
    required this.rows,
  });

  @override
  Widget build(BuildContext context) {
    final theme = returnTheme(context);
    return Container(
      key: ValueKey('staff-section-$id'),
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        boxShadow: const [
          BoxShadow(color: Color.fromARGB(26, 0, 0, 0), blurRadius: 10),
        ],
        color: Colors.white,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade100,
                ),
                child: Icon(size: 16, icon),
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b4.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  'Today\'s $title'.toUpperCase(),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                key: ValueKey('staff-section-count-$id'),
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.grey.shade100,
                ),
                child: Text(
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b5.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  '$count',
                ),
              ),
              const Spacer(),
              Material(
                type: MaterialType.transparency,
                child: InkWell(
                  key: ValueKey('staff-view-all-$id'),
                  mouseCursor: SystemMouseCursors.click,
                  onTap: onViewAll,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 10,
                    ),
                    child: Row(
                      spacing: 5,
                      children: [
                        Text(
                          style: TextStyle(
                            fontSize: theme.mobileTexts.b4.fontSize,
                          ),
                          'View All',
                        ),
                        const Icon(size: 14, Icons.arrow_forward_ios_rounded),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Divider(color: Colors.grey.shade300, height: 25),
          if (rows.isEmpty)
            Center(
              child: EmptyWidgetDisplayOnly(
                title: 'Empty List',
                subText: emptyText,
                theme: theme,
                height: 15,
                icon: Icons.clear,
              ),
            )
          else
            Column(spacing: 5, children: rows),
        ],
      ),
    );
  }
}

/// The page's sections, in order: Sales, Invoices, Orders†,
/// Purchases†, Expenses† (†under their gates). Rows are the latest
/// records ([StaffPageData.analysis]); View All opens the report
/// tables of [StaffSeeAll] on today.
List<Widget> staffTodaySections({
  required BuildContext context,
  required StaffPageData data,
  required StaffReportEnv report,
}) {
  final theme = returnTheme(context);
  final a = data.analysis;
  final s = data.summary;
  final key = data.staffKey;
  final period = data.period;

  return [
    StaffTodaySection(
      id: 'sales',
      title: 'Sales',
      icon: Icons.receipt_outlined,
      count: s.receiptCount,
      emptyText: 'No sales today',
      onViewAll:
          () => report.openReceiptsTable(
            context,
            StaffSeeAll.receiptsFilters(key),
            period,
          ),
      rows: [
        for (final r in a.recentReceipts)
          CustomerSalesList(receipt: r.receipt, theme: theme),
      ],
    ),
    StaffTodaySection(
      id: 'invoices',
      title: 'Invoices',
      icon: Icons.description_outlined,
      count: s.invoiceCount,
      emptyText: 'No invoices today',
      onViewAll:
          () => report.openInvoiceTable(
            context,
            StaffSeeAll.invoiceFilters(key, period),
          ),
      rows: [
        for (final r in a.recentInvoices)
          CustomerInvoicesList(invoice: r.invoice, theme: theme),
      ],
    ),
    if (data.showOrders)
      StaffTodaySection(
        id: 'orders',
        title: 'Orders',
        icon: Icons.shopping_bag_outlined,
        count: s.orderCount,
        emptyText: 'No orders today',
        onViewAll:
            () => report.openOrderTable(
              context,
              StaffSeeAll.orderFilters(key),
              period,
            ),
        rows: [
          for (final r in a.recentOrders)
            CustomerdOrdersList(order: r.order, theme: theme),
        ],
      ),
    if (data.showPurchases)
      StaffTodaySection(
        id: 'purchases',
        title: 'Purchases',
        icon: Icons.local_shipping_outlined,
        count: s.purchaseCount,
        emptyText: 'No purchases today',
        onViewAll:
            () => report.openPurchaseTable(
              context,
              StaffSeeAll.purchaseFilters(key),
              period,
            ),
        rows: [
          for (final r in a.recentPurchases)
            StaffPurchaseTile(
              row: r,
              theme: theme,
              money: (v) => report.money(context, v),
              onTap: () => report.openPurchase(context, r.purchase),
            ),
        ],
      ),
    if (data.showExpenses)
      StaffTodaySection(
        id: 'expenses',
        title: 'Expenses',
        icon: Icons.money_off_outlined,
        count: s.expenseCount,
        emptyText: 'No expenses today',
        onViewAll: () => report.openExpensesTable(context, key, period),
        rows: [
          for (final r in a.recentExpenses)
            StaffExpenseTile(
              row: r,
              theme: theme,
              money: (v) => report.money(context, v),
              onTap: () => report.openExpense(context, r.expense),
            ),
        ],
      ),
  ];
}

/// A row in [CustomerSalesList]'s style: dot, bold amount, a label,
/// then the date and time.
class _StaffRecordTile extends StatelessWidget {
  final Key tileKey;
  final ThemeProvider theme;
  final String amount;
  final String label;
  final DateTime? createdAt;
  final VoidCallback onTap;

  const _StaffRecordTile({
    required this.tileKey,
    required this.theme,
    required this.amount,
    required this.label,
    required this.createdAt,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final at = createdAt;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        key: tileKey,
        mouseCursor: SystemMouseCursors.click,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 5),
          child: Row(
            spacing: 8,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade400,
                ),
              ),
              Text(
                style: TextStyle(
                  fontSize: theme.mobileTexts.b4.fontSize,
                  fontWeight: FontWeight.bold,
                ),
                amount,
              ),
              Expanded(
                child: Text(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b4.fontSize,
                    color: Colors.grey.shade600,
                  ),
                  label,
                ),
              ),
              Flexible(
                child: Text(
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: theme.mobileTexts.b4.fontSize),
                  at == null
                      ? '—'
                      : '${formatDateTime(at)} - ${formatTime(at)}',
                ),
              ),
              const Icon(size: 12, Icons.arrow_forward_ios_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

/// A purchase: amount, supplier, date. Opens the purchase.
class StaffPurchaseTile extends StatelessWidget {
  final PurchaseReportRow row;
  final ThemeProvider theme;
  final String Function(num) money;
  final VoidCallback onTap;

  const StaffPurchaseTile({
    super.key,
    required this.row,
    required this.theme,
    required this.money,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => _StaffRecordTile(
    tileKey: ValueKey('staff-purchase-${row.uuid}'),
    theme: theme,
    amount: money(row.total),
    label: row.supplierLabel,
    createdAt: row.createdAt,
    onTap: onTap,
  );
}

/// An expense: amount, title, date. Opens the expense.
class StaffExpenseTile extends StatelessWidget {
  final StaffExpenseRow row;
  final ThemeProvider theme;
  final String Function(num) money;
  final VoidCallback onTap;

  const StaffExpenseTile({
    super.key,
    required this.row,
    required this.theme,
    required this.money,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => _StaffRecordTile(
    tileKey: ValueKey('staff-expense-${row.uuid}'),
    theme: theme,
    amount: money(row.amount),
    label: row.title,
    createdAt: row.createdAt,
    onTap: onTap,
  );
}
