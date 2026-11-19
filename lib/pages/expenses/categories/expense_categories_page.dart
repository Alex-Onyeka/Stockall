import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_expenses/expense_category.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/floating_action_butto.dart';
import 'package:stockall/components/major/desktop_center_container.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/components/text_fields/general_textfield.dart';
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
    bool isSaving = false;
    await showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return DialogTemplate(
              theme: theme,
              title: existing == null ? 'Create Category' : 'Edit Category',
              message: 'Enter Category Name',
              actionButtonText: existing == null ? 'Create' : 'Save',
              action: () async {
                if (isSaving) return;
                final name = controller.text.trim();
                if (name.isEmpty) {
                  showDialog(
                    context: dialogCtx,
                    builder:
                        (_) => InfoAlert(
                          theme: theme,
                          title: 'Category Name Empty',
                          message:
                              'Category Name Cannot be empty. Please enter Category name and try again.',
                        ),
                  );
                  return;
                }
                setDialogState(() {
                  isSaving = true;
                });
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
                  setDialogState(() {
                    isSaving = false;
                  });
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
              widget: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: SizedBox(
                  height: 120,
                  width: 500,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        spacing: 10,
                        children: [
                          GeneralTextField(
                            title: 'Category Name *',
                            hint: 'e.g. Electricity, Rent, Fuel',
                            controller: controller,
                            lines: 1,
                            theme: theme,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
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
      floatingActionButton: FloatingActionButtonMain(
        action: () => _showCategoryDialog(),
        color: theme.lightModeColor.secColor100,
        text: 'Add Category',
        theme: theme,
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
