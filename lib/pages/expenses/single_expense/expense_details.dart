import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/expenses/single_expense/platform/expense_details_desktop.dart';
import 'package:stockall/pages/expenses/single_expense/platform/expense_details_mobile.dart';

class ExpenseDetails extends StatelessWidget {
  final String expenseUuid;
  const ExpenseDetails({
    super.key,
    required this.expenseUuid,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < mobileScreen) {
          return ExpenseDetailsMobile(
            expenseUuid: expenseUuid,
          );
        } else {
          return ExpenseDetailsDesktop(
            expenseUuid: expenseUuid,
          );
        }
      },
    );
  }
}
