import 'package:flutter/material.dart';
import 'package:stockitt/pages/expenses/single_expense/platform/expense_details_mobile.dart';

class ExpenseDetails extends StatelessWidget {
  final int expenseId;
  const ExpenseDetails({
    super.key,
    required this.expenseId,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 550) {
          return ExpenseDetailsMobile(expenseId: expenseId);
        } else if (constraints.maxWidth > 550 &&
            constraints.maxWidth < 1000) {
          return Scaffold();
        } else {
          return Scaffold();
        }
      },
    );
  }
}
