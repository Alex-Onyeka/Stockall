import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/expenses/single_expense/platform/expense_details_desktop.dart';
import 'package:stockall/pages/expenses/single_expense/platform/expense_details_mobile.dart';

class ExpenseDetails extends StatefulWidget {
  final String expenseUuid;
  final String? notifId;
  const ExpenseDetails({
    super.key,
    required this.expenseUuid,
    this.notifId,
  });

  @override
  State<ExpenseDetails> createState() =>
      _ExpenseDetailsState();
}

class _ExpenseDetailsState extends State<ExpenseDetails> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.notifId != null) {
        returnNotificationProvider(
          context,
          listen: false,
        ).updateNotification(widget.notifId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < mobileScreen) {
          return ExpenseDetailsMobile(
            expenseUuid: widget.expenseUuid,
          );
        } else {
          return ExpenseDetailsDesktop(
            expenseUuid: widget.expenseUuid,
          );
        }
      },
    );
  }
}
