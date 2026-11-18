import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/expenses/total_expenses/platforms/total_expenses_desktop.dart';
import 'package:stockall/pages/expenses/total_expenses/platforms/total_expenses_mobile.dart';

class TotalExpenses extends StatelessWidget {
  final bool? turnOff;
  const TotalExpenses({super.key, this.turnOff});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < mobileScreen) {
          return TotalExpensesMobile(turnOff: turnOff);
        } else {
          return TotalExpensesDesktop(turnOff: turnOff);
        }
      },
    );
  }
}
