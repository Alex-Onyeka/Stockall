import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_expenses/expense_category.dart';
import 'package:stockall/classes/temp_expenses/temp_expenses_class.dart';
import 'package:stockall/providers/theme_provider.dart';

class ExpenseCategorySelection {
  final String expenseType;
  final String? categoryUuid;
  final String? categoryName;

  const ExpenseCategorySelection({
    required this.expenseType,
    this.categoryUuid,
    this.categoryName,
  });

  String get displayLabel => ExpenseType.labelFor(
    expenseType,
    customCategoryName: categoryName,
  );
}

/// Expandable category selector matching the Add to Cart multi-unit /
/// multi-price PopupMenuButton style.
class ExpenseCategorySelector extends StatelessWidget {
  final ThemeProvider theme;
  final ExpenseCategorySelection selected;
  final List<ExpenseCategory> customCategories;
  final ValueChanged<ExpenseCategorySelection> onSelected;
  final VoidCallback? onManageCategories;
  final bool enabled;

  const ExpenseCategorySelector({
    super.key,
    required this.theme,
    required this.selected,
    required this.customCategories,
    required this.onSelected,
    this.onManageCategories,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 5,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Expense Category',
              style: theme.mobileTexts.b3.textStyleBold,
            ),
            if (onManageCategories != null)
              InkWell(
                onTap: onManageCategories,
                child: Text(
                  'Manage Categories',
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b4.fontSize,
                    color: theme.lightModeColor.prColor250,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        PopupMenuButton<ExpenseCategorySelection>(
          enabled: enabled,
          color: Colors.white,
          onSelected: onSelected,
          itemBuilder: (context) {
            final items = <PopupMenuEntry<ExpenseCategorySelection>>[
              _buildItem(
                label: 'Simple Expense',
                value: const ExpenseCategorySelection(
                  expenseType: ExpenseType.simpleExpense,
                ),
                isSelected:
                    selected.expenseType == ExpenseType.simpleExpense,
              ),
              _buildItem(
                label: 'Staff Salary',
                value: const ExpenseCategorySelection(
                  expenseType: ExpenseType.staffSalary,
                ),
                isSelected:
                    selected.expenseType == ExpenseType.staffSalary,
              ),
              _buildItem(
                label: 'Stock Purchase',
                value: const ExpenseCategorySelection(
                  expenseType: ExpenseType.stockPurchase,
                ),
                isSelected:
                    selected.expenseType == ExpenseType.stockPurchase,
              ),
            ];

            if (customCategories.isNotEmpty) {
              items.add(const PopupMenuDivider());
              for (final cat in customCategories) {
                items.add(
                  _buildItem(
                    label: cat.name,
                    value: ExpenseCategorySelection(
                      expenseType: ExpenseType.custom,
                      categoryUuid: cat.uuid,
                      categoryName: cat.name,
                    ),
                    isSelected:
                        selected.expenseType == ExpenseType.custom &&
                        selected.categoryUuid == cat.uuid,
                  ),
                );
              }
            }
            return items;
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(10, 10, 8, 10),
            decoration: BoxDecoration(
              color: enabled ? Colors.white : Colors.grey.shade100,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    selected.displayLabel,
                    style: TextStyle(
                      fontSize: theme.mobileTexts.b3.fontSize,
                      fontWeight: FontWeight.bold,
                      color: enabled ? Colors.black87 : Colors.grey.shade600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: enabled ? Colors.black87 : Colors.grey.shade500,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  PopupMenuItem<ExpenseCategorySelection> _buildItem({
    required String label,
    required ExpenseCategorySelection value,
    required bool isSelected,
  }) {
    return PopupMenuItem<ExpenseCategorySelection>(
      value: value,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: theme.mobileTexts.b3.fontSize,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check,
                size: 17,
                color: Colors.grey.shade700,
              ),
          ],
        ),
      ),
    );
  }
}
