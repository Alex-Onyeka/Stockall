import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_expenses/expense_category.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/major/desktop_center_container.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';

class ExpenseCategoriesPage extends StatefulWidget {
  const ExpenseCategoriesPage({super.key});

  @override
  State<ExpenseCategoriesPage> createState() => _ExpenseCategoriesPageState();
}

class _ExpenseCategoriesPageState extends State<ExpenseCategoriesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      returnExpensesProvider(
        context,
        listen: false,
      ).getExpenseCategories(shopId());
    });
  }

  Future<void> _showCategoryDialog({ExpenseCategory? existing}) async {
    final theme = returnTheme(context, listen: false);
    final controller = TextEditingController(text: existing?.name ?? '');
    await showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            existing == null ? 'New Expense Category' : 'Edit Category',
            style: TextStyle(
              fontSize: theme.mobileTexts.h4.fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Category Name',
              hintText: 'e.g. Electricity, Rent, Fuel',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = controller.text.trim();
                if (name.isEmpty) return;
                final provider = returnExpensesProvider(
                  context,
                  listen: false,
                );
                final ok =
                    existing == null
                        ? await provider.createExpenseCategory(
                          shopId: shopId(),
                          name: name,
                          departmentUuid:
                              returnDepartmentProvider()
                                  .currentDepartment()
                                  ?.uuid,
                          departmentName:
                              returnDepartmentProvider()
                                  .currentDepartment()
                                  ?.name,
                        )
                        : await provider.updateExpenseCategory(existing, name);
                if (!dialogCtx.mounted) return;
                if (!ok) {
                  showDialog(
                    context: dialogCtx,
                    builder:
                        (_) => InfoAlert(
                          theme: theme,
                          title: 'Duplicate Category',
                          message:
                              'An expense category with this name already exists.',
                        ),
                  );
                  return;
                }
                Navigator.of(dialogCtx).pop();
              },
              child: Text(existing == null ? 'Create' : 'Save'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(ExpenseCategory category) {
    final theme = returnTheme(context, listen: false);
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return ConfirmationAlert(
          theme: theme,
          title: 'Delete Category?',
          message:
              'Delete "${category.name}"? Existing expenses under this category will remain intact with their historical category name.',
          action: () async {
            Navigator.of(dialogCtx).pop();
            await returnExpensesProvider(
              context,
              listen: false,
            ).deleteExpenseCategory(category);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = returnTheme(context);
    final provider = returnExpensesProvider(context);
    final categories = provider.expenseCategories;
    final isMobile = MediaQuery.of(context).size.width < mobileScreen;

    final body = Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Expense Categories',
          style: TextStyle(
            fontSize: theme.mobileTexts.h4.fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Add Category',
            onPressed: () => _showCategoryDialog(),
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCategoryDialog(),
        backgroundColor: theme.lightModeColor.prColor250,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'New Category',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body:
          categories.isEmpty
              ? Center(
                child: EmptyWidgetDisplayOnly(
                  svg: expensesIconSvg,
                  title: 'No Custom Categories Yet',
                  subText:
                      'Create custom categories like Electricity, Rent, or Fuel.',
                  height: 35,
                  theme: theme,
                ),
              )
              : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.label_outline,
                          color: theme.lightModeColor.prColor250,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            cat.name,
                            style: TextStyle(
                              fontSize: theme.mobileTexts.b2.fontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: 'Edit',
                          onPressed: () => _showCategoryDialog(existing: cat),
                          icon: const Icon(Icons.edit_outlined, size: 20),
                        ),
                        IconButton(
                          tooltip: 'Delete',
                          onPressed: () => _confirmDelete(cat),
                          icon: const Icon(
                            Icons.delete_outline,
                            size: 20,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
    );

    if (isMobile) return body;
    return DesktopCenterContainer(mainWidget: body);
  }
}
