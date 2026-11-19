import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_expenses/temp_expenses_class.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/products/compnents/product_filter_button.dart';

class ExpenseCategoryFilterButtons extends StatelessWidget {
  const ExpenseCategoryFilterButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = returnTheme(context);
    final provider = returnExpensesProvider(context);
    final selected = provider.selectedCategoryFilter;
    final customCategories = provider.expenseCategories;

    final chips = <({String? value, String label})>[
      (value: null, label: 'All'),
      (value: ExpenseType.simpleExpense, label: 'Simple Expenses'),
      (value: ExpenseType.staffSalary, label: 'Staff Salary'),
      (value: ExpenseType.stockPurchase, label: 'Stock Purchase'),
      for (final cat in customCategories)
        (value: 'custom:${cat.uuid}', label: cat.name),
    ];

    final foundIndex = chips.indexWhere((c) => c.value == selected);
    final currentSelected = foundIndex < 0 ? 0 : foundIndex;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: 6,
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < chips.length; i++)
            ProductsFilterButton(
              theme: theme,
              title: chips[i].label,
              number: i,
              currentSelected: currentSelected,
              action: () {
                final isSelected = selected == chips[i].value;
                provider.setCategoryFilter(
                  isSelected ? null : chips[i].value,
                );
              },
            ),
        ],
      ),
    );
  }
}
