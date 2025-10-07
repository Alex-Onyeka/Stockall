import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/expenses/platforms/expenses_desktop.dart';
import 'package:stockall/pages/expenses/platforms/expenses_moblie.dart';

class ExpensesPage extends StatefulWidget {
  final bool? turnOn;
  final bool? isMain;
  const ExpensesPage({
    super.key,
    required this.isMain,
    this.turnOn,
  });

  @override
  State<ExpensesPage> createState() => _ExpensesPageState();
}

class _ExpensesPageState extends State<ExpensesPage> {
  @override
  void initState() {
    super.initState();
    returnNavProvider(context, listen: false).navigate(4);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await returnNavProvider(
        context,
        listen: false,
      ).validate(context);
      setState(() {
        // stillLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < mobileScreen) {
          return ExpensesMoblie(isMain: widget.isMain);
        } else {
          return ExpensesDesktop(
            isMain: widget.isMain,
            turnOn: widget.turnOn,
          );
        }
      },
    );
  }
}
