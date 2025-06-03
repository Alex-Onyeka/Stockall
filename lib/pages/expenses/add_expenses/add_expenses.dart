import 'package:flutter/material.dart';
import 'package:storrec/classes/temp_expenses_class.dart';
import 'package:storrec/pages/expenses/add_expenses/platforms/add_expenses_mobile.dart';

class AddExpenses extends StatefulWidget {
  final TempExpensesClass? expense;
  const AddExpenses({super.key, this.expense});

  @override
  State<AddExpenses> createState() => _AddExpensesState();
}

class _AddExpensesState extends State<AddExpenses> {
  TextEditingController nameController =
      TextEditingController();
  TextEditingController descController =
      TextEditingController();
  TextEditingController amountController =
      TextEditingController();
  TextEditingController quantityController =
      TextEditingController();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          () =>
              FocusManager.instance.primaryFocus?.unfocus(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 550) {
            return AddExpensesMobile(
              expenses: widget.expense,
              amountController: amountController,
              descController: descController,
              nameController: nameController,
              quantityController: quantityController,
            );
          } else if (constraints.maxWidth > 550 &&
              constraints.maxWidth < 1000) {
            return Scaffold();
          } else {
            return Scaffold();
          }
        },
      ),
    );
  }
}
