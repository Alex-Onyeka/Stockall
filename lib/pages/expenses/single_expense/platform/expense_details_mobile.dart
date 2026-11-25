import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_expenses/temp_expenses_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/expenses/add_expenses/add_expenses.dart';
import 'package:stockall/pages/expenses/single_expense/components/expense_breakdown_section_widget.dart';
import 'package:stockall/pages/expenses/single_expense/components/expense_details_section_widget.dart';
import 'package:stockall/pages/expenses/single_expense/components/stock_purchase_expense_actions.dart';
import 'package:stockall/providers/theme_provider.dart';

class ExpenseDetailsMobile extends StatefulWidget {
  final String expenseUuid;
  const ExpenseDetailsMobile({
    super.key,
    required this.expenseUuid,
  });

  @override
  State<ExpenseDetailsMobile> createState() =>
      _ExpenseDetailsMobileState();
}

class _ExpenseDetailsMobileState
    extends State<ExpenseDetailsMobile> {
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

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color.fromARGB(
          255,
          253,
          254,
          255,
        ),
        body: Column(
          spacing: 10,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 15,
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
                children: [
                  Row(
                    spacing: 6,
                    children: [
                      Material(
                        type: MaterialType.transparency,
                        child: InkWell(
                          mouseCursor:
                              SystemMouseCursors.click,
                          onTap: () {
                            Navigator.pop(context);
                          },
                          borderRadius:
                              BorderRadius.circular(30),
                          child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.grey.shade200,
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              size: 16,
                              color: Colors.grey.shade700,
                              Icons
                                  .arrow_back_ios_new_outlined,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        style: TextStyle(
                          fontSize:
                              theme.mobileTexts.b3.fontSize,
                        ),
                        'Expense Details',
                      ),
                    ],
                  ),
                  const Spacer(),
                  if (expense != null)
                    Padding(
                      padding: const EdgeInsets.only(
                        right: 15.0,
                      ),
                      child: PopupMenuButton(
                        offset: Offset(-20, 30),
                        color: Colors.white,
                        itemBuilder: (context) {
                          return [
                            PopupMenuItem(
                              height: 45,
                              onTap: () {
                                if (isDeleting) return;
                                if (expense
                                        .isStockPurchase &&
                                    expense.purchaseUuid !=
                                        null) {
                                  openLinkedPurchase(
                                    context,
                                    expense.purchaseUuid!,
                                  );
                                  return;
                                }
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return AddExpenses(
                                        expense: expense,
                                      );
                                    },
                                  ),
                                );
                              },
                              child: Text(
                                style: TextStyle(
                                  fontSize:
                                      theme
                                          .mobileTexts
                                          .b3
                                          .fontSize,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                                expense.isStockPurchase
                                    ? 'Open Purchase'
                                    : 'Edit Expense',
                              ),
                            ),
                            PopupMenuItem(
                              height: 45,
                              onTap:
                                  () => _handleDelete(
                                    context,
                                    theme,
                                    expense,
                                  ),
                              child: Text(
                                style: TextStyle(
                                  fontSize:
                                      theme
                                          .mobileTexts
                                          .b3
                                          .fontSize,
                                  fontWeight:
                                      FontWeight.bold,
                                  color: Colors.red,
                                ),
                                'Delete Expense',
                              ),
                            ),
                          ];
                        },
                        child: Icon(Icons.more_vert_rounded),
                      ),
                    ),
                ],
              ),
            ),
            Builder(
              builder: (context) {
                if (expense == null || isDeleting) {
                  return Expanded(
                    child: Center(
                      child: returnCompProvider(
                        context,
                        listen: false,
                      ).showLoader(
                        message:
                            isDeleting
                                ? 'Deleting Expense'
                                : 'Loading',
                      ),
                    ),
                  );
                }
                return Expanded(
                  child: ListView(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15.0,
                        ),
                        child: Column(
                          spacing: 5,
                          children: [
                            ExpenseDetailsSectionWidget(
                              expense: expense,
                            ),
                            if (expense.hasSubExpenses)
                              ExpenseBreakdownSectionWidget(
                                expense: expense,
                              ),
                            SizedBox(height: 30),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
