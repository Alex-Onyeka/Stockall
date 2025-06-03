import 'package:flutter/material.dart';
import 'package:storrec/pages/expenses/platforms/expenses_moblie.dart';

class ExpensesPage extends StatelessWidget {
  final bool? isMain;
  const ExpensesPage({super.key, required this.isMain});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 550) {
          return ExpensesMoblie(isMain: isMain);
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
