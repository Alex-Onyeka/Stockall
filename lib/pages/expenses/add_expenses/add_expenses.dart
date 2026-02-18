import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_expenses/temp_expenses_class.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/expenses/add_expenses/platforms/add_expenses_desktop.dart';
import 'package:stockall/pages/expenses/add_expenses/platforms/add_expenses_mobile.dart';
import 'package:stockall/pages/products/add_product_one/add_product.dart';

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
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          checkPop(
            context: context,
            didPop: didPop,
            conditionX:
                nameController.text.isNotEmpty ||
                descController.text.isNotEmpty ||
                amountController.text.isNotEmpty ||
                quantityController.text.isNotEmpty,
          );
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < mobileScreen) {
              return AddExpensesMobile(
                expenses: widget.expense,
                amountController: amountController,
                descController: descController,
                nameController: nameController,
                quantityController: quantityController,
              );
            } else {
              return AddExpensesDesktop(
                expenses: widget.expense,
                amountController: amountController,
                descController: descController,
                nameController: nameController,
                quantityController: quantityController,
              );
            }
          },
        ),
      ),
    );
  }
}
