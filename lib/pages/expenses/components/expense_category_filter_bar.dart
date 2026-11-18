import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_expenses/temp_expenses_class.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/expenses/categories/expense_categories_page.dart';

class ExpenseCategoryFilterBar extends StatelessWidget {
  const ExpenseCategoryFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = returnTheme(context);
    final provider = returnExpensesProvider(context);
    final selected = provider.selectedCategoryFilter;
    final customCategories = provider.expenseCategories;

    final chips = <({String? value, String label})>[
      (value: null, label: 'All'),
      (value: ExpenseType.simpleExpense, label: 'Simple Expense'),
      (value: ExpenseType.staffSalary, label: 'Staff Salary'),
      (value: ExpenseType.stockPurchase, label: 'Stock Purchase'),
      for (final cat in customCategories)
        (value: 'custom:${cat.uuid}', label: cat.name),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                spacing: 6,
                children:
                    chips.map((item) {
                      final isSelected = selected == item.value;
                      return ChoiceChip(
                        label: Text(
                          item.label,
                          style: TextStyle(
                            fontSize: theme.mobileTexts.b4.fontSize,
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: theme.lightModeColor.prColor250,
                        backgroundColor: Colors.white,
                        side: BorderSide(
                          color:
                              isSelected
                                  ? theme.lightModeColor.prColor250
                                  : Colors.grey.shade300,
                        ),
                        onSelected: (_) {
                          provider.setCategoryFilter(
                            isSelected ? null : item.value,
                          );
                        },
                      );
                    }).toList(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              side: BorderSide(color: theme.lightModeColor.prColor250),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ExpenseCategoriesPage(),
                ),
              );
            },
            icon: Icon(
              Icons.category_outlined,
              size: 16,
              color: theme.lightModeColor.prColor250,
            ),
            label: Text(
              'Categories',
              style: TextStyle(
                fontSize: theme.mobileTexts.b4.fontSize,
                color: theme.lightModeColor.prColor250,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
