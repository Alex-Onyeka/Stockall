import 'package:flutter/material.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/expenses/single_expense/expense_details.dart';
import 'package:stockall/providers/theme_provider.dart';

/// "Expense:" row of a purchase page: opens the Stock Purchase
/// expense recorded for the purchase's payments. Shows nothing
/// when this device has no such expense (e.g. unpaid purchase).
/// Shared by the mobile and desktop purchase pages.
class PurchaseLinkedExpenseRow extends StatelessWidget {
  final String? purchaseUuid;
  final ThemeProvider theme;

  const PurchaseLinkedExpenseRow({
    super.key,
    required this.purchaseUuid,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final uuid = purchaseUuid;
    if (uuid == null || uuid.isEmpty) return const SizedBox.shrink();
    final expense = returnExpensesProvider(context).expenseForPurchase(uuid);
    final expenseUuid = expense?.uuid;
    if (expenseUuid == null) return const SizedBox.shrink();
    return Row(
      spacing: 5,
      children: [
        SizedBox(
          width: 65,
          child: Text(
            style: TextStyle(
              fontSize: theme.mobileTexts.b4.fontSize,
              fontWeight: FontWeight.normal,
            ),
            'Expense:',
          ),
        ),
        InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ExpenseDetails(expenseUuid: expenseUuid),
              ),
            );
          },
          child: Text(
            style: TextStyle(
              fontSize: theme.mobileTexts.b4.fontSize,
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade700,
              decoration: TextDecoration.underline,
            ),
            'View Linked Expense',
          ),
        ),
      ],
    );
  }
}
