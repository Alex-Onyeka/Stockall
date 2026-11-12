// The staff page's one "Records" dropdown (desktop and mobile): each
// full list filtered to the staff. Orders, Purchases and Expenses
// follow the Staff Report's gates.

import 'package:flutter/material.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/employees/employee_page/components/staff_page_env.dart';

class StaffRecordsMenu extends StatelessWidget {
  final bool showOrders;
  final bool showPurchases;
  final bool showExpenses;
  final void Function(StaffRecordsList list) onSelected;

  const StaffRecordsMenu({
    super.key,
    required this.showOrders,
    required this.showPurchases,
    required this.showExpenses,
    required this.onSelected,
  });

  static const Map<StaffRecordsList, String> labels = {
    StaffRecordsList.sales: 'Sales',
    StaffRecordsList.invoices: 'Invoices',
    StaffRecordsList.orders: 'Orders',
    StaffRecordsList.purchases: 'Purchases',
    StaffRecordsList.expenses: 'Expenses',
  };

  List<StaffRecordsList> get items => [
    StaffRecordsList.sales,
    StaffRecordsList.invoices,
    if (showOrders) StaffRecordsList.orders,
    if (showPurchases) StaffRecordsList.purchases,
    if (showExpenses) StaffRecordsList.expenses,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = returnTheme(context);
    return PopupMenuButton<StaffRecordsList>(
      key: const ValueKey('staff-records-menu'),
      offset: const Offset(0, 40),
      color: Colors.white,
      tooltip: 'Records',
      onSelected: onSelected,
      itemBuilder:
          (context) => [
            for (final list in items)
              PopupMenuItem<StaffRecordsList>(
                key: ValueKey('staff-records-${list.name}'),
                value: list,
                height: 45,
                child: Text(
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b3.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  labels[list]!,
                ),
              ),
          ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 4,
          children: [
            Text(
              style: TextStyle(
                fontSize: theme.mobileTexts.b3.fontSize,
                color: Colors.grey.shade700,
              ),
              'Records',
            ),
            Icon(
              size: 18,
              color: Colors.grey.shade700,
              Icons.keyboard_arrow_down_rounded,
            ),
          ],
        ),
      ),
    );
  }
}
