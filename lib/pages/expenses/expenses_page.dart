import 'package:flutter/material.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/expenses/total_expenses/total_expenses.dart';

class ExpensesPage extends StatefulWidget {
  final bool? turnOnBackNavButton;
  final bool? isMain;
  const ExpensesPage({
    super.key,
    required this.isMain,
    this.turnOnBackNavButton,
  });

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  @override
  void initState() {
    super.initState();
    returnNavProvider(context, listen: false).navigate(6);
    // WidgetsBinding.instance.addPostFrameCallback((_) async {
    //   await returnNavProvider(
    //     context,
    //     listen: false,
    //   ).validate(context);
    //   setState(() {
    //     // stillLoading = false;
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    return TotalExpenses(
      turnOff: widget.turnOnBackNavButton == false,
    );
  }
}
