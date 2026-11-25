import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_expenses/temp_expenses_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/expenses/single_expense/components/expense_breakdown_section_widget.dart';
import 'package:stockall/pages/expenses/single_expense/components/expense_details_section_widget.dart';
import 'package:stockall/pages/expenses/single_expense/components/stock_purchase_expense_actions.dart';
import 'package:stockall/pages/invoices/invoice_page/invoice_page_desktop.dart';
import 'package:stockall/providers/theme_provider.dart';

class ExpenseDetailsDesktop extends StatefulWidget {
  final String expenseUuid;
  const ExpenseDetailsDesktop({
    super.key,
    required this.expenseUuid,
  });

  @override
  State<ExpenseDetailsDesktop> createState() =>
      _ExpenseDetailsDesktopState();
}

class _ExpenseDetailsDesktopState
    extends State<ExpenseDetailsDesktop> {
  bool isDeleting = false;

  void _handleDelete(
    BuildContext context,
    ThemeProvider theme,
    TempExpensesClass expense,
  ) {
    if (isDeleting) return;
    if (expense.isStockPurchase &&
        expense.purchaseUuid != null) {
      confirmDeleteStockPurchaseExpense(
        context: context,
        theme: theme,
        expense: expense,
        onStart: () {
          setState(() {
            isDeleting = true;
          });
        },
        onDone: (deleted) {
          if (!mounted) return;
          if (deleted) {
            Navigator.of(context).pop();
          } else {
            setState(() {
              isDeleting = false;
            });
          }
        },
      );
      return;
    }

    var expP = returnExpensesProvider(
      context,
      listen: false,
    );
    final safeContext = context;
    showDialog(
      context: safeContext,
      builder: (confirmDialog) {
        return ConfirmationAlert(
          theme: theme,
          message:
              'You are about to delete your Expenses, are you sure you want to proceed?',
          title: 'Delete Expense?',
          action: () async {
            Navigator.of(confirmDialog).pop();
            setState(() {
              isDeleting = true;
            });
            await expP.deleteExpense(expense, safeContext);
            if (safeContext.mounted) {
              Navigator.of(safeContext).pop();
            }
            if (mounted) {
              setState(() {
                isDeleting = false;
              });
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    final provider = returnExpensesProvider(context);
    var matching = provider
        .returnExpensesByDayOrWeek(context)
        .where((e) => e.uuid == widget.expenseUuid);
    if (matching.isEmpty) {
      matching = provider.expensesMain.where(
        (e) => e.uuid == widget.expenseUuid,
      );
    }
    final TempExpensesClass? expense =
        matching.isNotEmpty ? matching.first : null;

    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 30,
              vertical: 20,
            ),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade200,
                ),
              ),
              color: Colors.white,
            ),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              spacing: 10,
              children: [
                Row(
                  spacing: 10,
                  children: [
                    InkWell(
                      mouseCursor: SystemMouseCursors.click,
                      onTap: () {
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(
                        30,
                      ),
                      child: Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          size: 18,
                          color: Colors.grey.shade700,
                          Icons.arrow_back_ios_new_outlined,
                        ),
                      ),
                    ),
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b2.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                      'Expense Details',
                    ),
                  ],
                ),
                Row(
                  spacing: 5,
                  children: [
                    if (expense != null &&
                        expense.isStockPurchase &&
                        expense.purchaseUuid != null)
                      ActionButtonSmall(
                        isLoading: isDeleting,
                        action: () {
                          if (!isDeleting) {
                            openLinkedPurchase(
                              context,
                              expense.purchaseUuid!,
                            );
                          }
                        },
                        text: 'Purchase',
                        textColor: Colors.grey.shade500,
                        icon: Icon(
                          size: 14,
                          color: Colors.grey.shade500,
                          Icons.arrow_forward_ios_rounded,
                        ),
                      ),
                    if (expense != null)
                      Padding(
                        padding: const EdgeInsets.only(
                          right: 20.0,
                        ),
                        child: ActionButtonSmall(
                          isLoading: isDeleting,
                          action:
                              () => _handleDelete(
                                context,
                                theme,
                                expense,
                              ),
                          text: 'Delete',
                          textColor: Colors.red.shade300,
                          icon: Icon(
                            size: 16,
                            color: Colors.red.shade300,
                            Icons.delete,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Builder(
              builder: (context) {
                if (expense == null || isDeleting) {
                  return Center(
                    child: returnCompProvider(
                      context,
                      listen: false,
                    ).showLoader(
                      message:
                          isDeleting
                              ? 'Deleting Expense'
                              : 'Loading',
                    ),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.fromLTRB(
                    50,
                    0,
                    50,
                    30,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(
                                horizontal: 10.0,
                              ),
                          child:
                              ExpenseDetailsSectionWidget(
                                expense: expense,
                              ),
                        ),
                        if (expense.hasSubExpenses)
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(
                                  horizontal: 10.0,
                                ),
                            child:
                                ExpenseBreakdownSectionWidget(
                                  expense: expense,
                                ),
                          ),
                        SizedBox(height: 30),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
