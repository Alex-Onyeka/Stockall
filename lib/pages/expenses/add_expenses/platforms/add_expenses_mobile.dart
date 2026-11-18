import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_expenses/temp_expenses_class.dart';
import 'package:stockall/pages/expenses/add_expenses/components/add_expenses_form.dart';

class AddExpensesMobile extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController descController;
  final TextEditingController amountController;
  final TextEditingController quantityController;
  final TempExpensesClass? expenses;

  const AddExpensesMobile({
    super.key,
    required this.nameController,
    required this.descController,
    required this.amountController,
    required this.quantityController,
    this.expenses,
  });

  @override
  Widget build(BuildContext context) {
    return AddExpensesForm(
      nameController: nameController,
      descController: descController,
      amountController: amountController,
      quantityController: quantityController,
      expenses: expenses,
      isDesktop: false,
    );
  }
}
