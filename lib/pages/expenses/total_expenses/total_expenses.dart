import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/expenses/total_expenses/platforms/total_expenses_desktop.dart';
import 'package:stockall/pages/expenses/total_expenses/platforms/total_expenses_mobile.dart';

class TotalExpenses extends StatelessWidget {
  const TotalExpenses({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < mobileScreen) {
          return TotalExpensesMobile();
        } else {
          return TotalExpensesDesktop();
        }
      },
    );
  }
}
