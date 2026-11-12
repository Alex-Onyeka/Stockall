// The staff page's blue card (the customer page's account card style):
// what the staff did today, as the Staff Report shows it, and Print
// Report.

import 'package:flutter/material.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/employees/employee_page/components/staff_page_data.dart';
import 'package:stockall/pages/report/components/export/report_export_backend.dart';
import 'package:stockall/pages/report/components/export/report_export_button.dart';
import 'package:stockall/providers/theme_provider.dart';

String _count(int n, String noun) => '$n $noun${n == 1 ? '' : 's'}';

class StaffTodaySummaryCard extends StatelessWidget {
  final StaffPageData data;
  final String Function(num amount) money;
  final String currency;
  final ReportExportBackend exportBackend;

  const StaffTodaySummaryCard({
    super.key,
    required this.data,
    required this.money,
    required this.currency,
    required this.exportBackend,
  });

  @override
  Widget build(BuildContext context) {
    final theme = returnTheme(context);
    final s = data.summary;
    final figures = <Widget>[
      _figure(
        theme,
        id: 'invoices',
        label: 'Invoice Sales',
        amount: s.invoiceSales,
        note: _count(s.invoiceCount, 'invoice'),
      ),
      if (data.showOrders)
        _figure(
          theme,
          id: 'orders',
          label: 'Orders',
          amount: s.orderTotal,
          note: _count(s.orderCount, 'order'),
        ),
      if (data.showPurchases)
        _figure(
          theme,
          id: 'purchases',
          label: 'Purchases',
          amount: s.purchaseTotal,
          note: _count(s.purchaseCount, 'purchase'),
        ),
      if (data.showExpenses)
        _figure(
          theme,
          id: 'expenses',
          label: 'Expenses',
          amount: s.expenseTotal,
          note: _count(s.expenseCount, 'expense'),
        ),
    ];

    return Container(
      key: const ValueKey('staff-summary-card'),
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        boxShadow: const [
          BoxShadow(color: Color.fromARGB(26, 0, 0, 0), blurRadius: 10),
        ],
        gradient: theme.lightModeColor.prGradient,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade100,
                ),
                child: const Icon(size: 16, Icons.insights_outlined),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      style: TextStyle(
                        fontSize: theme.mobileTexts.b4.fontSize,
                        color: Colors.grey.shade200,
                      ),
                      'Today\'s Activity'.toUpperCase(),
                    ),
                    Text(
                      key: const ValueKey('staff-summary-date'),
                      style: TextStyle(
                        fontSize: theme.mobileTexts.b5.fontSize,
                        color: Colors.grey.shade300,
                      ),
                      formatDateTime(data.period.start!),
                    ),
                  ],
                ),
              ),
              ReportExportButton(
                label: 'Print Report',
                backend: exportBackend,
                buildSpec: () => data.printSpec(currency: currency),
              ),
            ],
          ),
          Divider(color: Colors.grey.shade500, height: 25),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              key: const ValueKey('staff-figure-sales'),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b4.fontSize,
                    color: Colors.grey.shade200,
                  ),
                  'Total Sales',
                ),
                Text(
                  style: TextStyle(
                    fontSize: theme.mobileTexts.h2.fontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade100,
                  ),
                  money(s.receiptSales),
                ),
                Text(
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b4.fontSize,
                    color: Colors.grey.shade200,
                  ),
                  _count(s.receiptCount, 'receipt'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              spacing: 12,
              children: [
                for (var i = 0; i < figures.length; i += 2)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: figures[i]),
                      Expanded(
                        child:
                            i + 1 < figures.length
                                ? figures[i + 1]
                                : const SizedBox(),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _figure(
    ThemeProvider theme, {
    required String id,
    required String label,
    required double amount,
    required String note,
  }) {
    return Column(
      key: ValueKey('staff-figure-$id'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          style: TextStyle(
            fontSize: theme.mobileTexts.b5.fontSize,
            color: Colors.grey.shade200,
          ),
          label.toUpperCase(),
        ),
        Divider(color: Colors.grey.shade500, height: 10),
        Text(
          style: TextStyle(
            fontSize: theme.mobileTexts.b3.fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade200,
          ),
          money(amount),
        ),
        Text(
          style: TextStyle(
            fontSize: theme.mobileTexts.b5.fontSize,
            color: Colors.grey.shade300,
          ),
          note,
        ),
      ],
    );
  }
}
