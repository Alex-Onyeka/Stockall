import 'package:flutter/material.dart';
import 'package:stockitt/pages/expenses/total_expenses/platforms/total_expenses_mobile.dart';

class TotalExpenses extends StatelessWidget {
  const TotalExpenses({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 550) {
          return TotalExpensesMobile();
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
