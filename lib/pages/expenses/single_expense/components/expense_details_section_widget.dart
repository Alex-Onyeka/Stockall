import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stockall/classes/temp_expenses/temp_expenses_class.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/expenses/add_expenses/add_expenses.dart';
import 'package:stockall/pages/expenses/single_expense/components/stock_purchase_expense_actions.dart';
import 'package:stockall/pages/invoices/invoice_page/invoice_page_desktop.dart';
import 'package:stockall/providers/theme_provider.dart';

class ExpenseDetailsSectionWidget extends StatelessWidget {
  final TempExpensesClass expense;
  const ExpenseDetailsSectionWidget({
    super.key,
    required this.expense,
  });

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    final paymentText =
        expense.paymentEntries != null &&
                expense.paymentEntries!.length > 1
            ? expense.paymentEntries!
                .map(
                  (p) =>
                      '${p.method}: ${formatMoneyMid(amount: p.amount, context: context)}',
                )
                .join(', ')
            : expense.resolvedPaymentChannelLabel;

    return Container(
      margin: EdgeInsets.only(top: 10),
      padding: EdgeInsets.symmetric(
        vertical: 25,
        horizontal: 15,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(26, 0, 0, 0),
            blurRadius: 10,
          ),
        ],
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Row(
                spacing: 5,
                children: [
                  Container(
                    padding: EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade100,
                    ),
                    child: SvgPicture.asset(
                      expensesIconSvg,
                      height: 16,
                      colorFilter: ColorFilter.mode(
                        Colors.grey.shade700,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  Text(
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b4.fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                    'Expense Details'.toUpperCase(),
                  ),
                ],
              ),
              ActionButtonSmall(
                isLoading: false,
                action: () {
                  if (expense.isStockPurchase &&
                      expense.purchaseUuid != null) {
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
                text:
                    expense.isStockPurchase
                        ? 'Open Purchase'
                        : 'Edit',
                textColor: Colors.grey.shade500,
                icon: Icon(
                  size: 16,
                  color: Colors.grey.shade500,
                  expense.isStockPurchase
                      ? Icons.open_in_new_rounded
                      : Icons.edit,
                ),
              ),
            ],
          ),
          Divider(color: Colors.grey.shade300, height: 25),
          Column(
            spacing: 15,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                spacing: 5,
                children: [
                  Expanded(
                    flex: 3,
                    child: ExpenseDetailsColumnSection(
                      theme: theme,
                      title: 'Expense Name',
                      text: expense.name,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: ExpenseDetailsColumnSection(
                      theme: theme,
                      title:
                          'Amount (${currencySymbol(context: context)})',
                      text: formatMoneyMid(
                        amount: expense.amount,
                        context: context,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                spacing: 5,
                children: [
                  Expanded(
                    flex: 3,
                    child: ExpenseDetailsColumnSection(
                      theme: theme,
                      title: 'Unit',
                      text:
                          (expense.unit != null &&
                                  expense.unit!
                                      .trim()
                                      .isNotEmpty)
                              ? expense.unit!
                              : 'Not Set',
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: ExpenseDetailsColumnSection(
                      theme: theme,
                      title: 'Quantity',
                      text:
                          expense.quantity != null
                              ? formatLargeNumberDouble(
                                expense.quantity!,
                              )
                              : 'Not Set',
                    ),
                  ),
                ],
              ),
              Row(
                spacing: 5,
                children: [
                  Expanded(
                    flex: 3,
                    child: ExpenseDetailsColumnSection(
                      theme: theme,
                      title: 'Created By',
                      text:
                          (expense.creator != null &&
                                  expense.creator!
                                      .trim()
                                      .isNotEmpty)
                              ? expense.creator!
                              : 'Not Set',
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: ExpenseDetailsColumnSection(
                      theme: theme,
                      title: 'Created Date',
                      text:
                          expense.createdDate != null
                              ? formatDateWithDay(
                                expense.createdDate!,
                              )
                              : 'Not Set',
                    ),
                  ),
                ],
              ),
              Row(
                spacing: 5,
                children: [
                  Expanded(
                    flex: 3,
                    child: ExpenseDetailsColumnSection(
                      theme: theme,
                      title: 'Category',
                      text: returnExpensesProvider(
                        context,
                      ).categoryLabelFor(expense),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: ExpenseDetailsColumnSection(
                      theme: theme,
                      title: 'Payment Channel',
                      text: paymentText,
                    ),
                  ),
                ],
              ),
              if ((expense.isStaffSalary &&
                      expense.staffName != null &&
                      expense.staffName!.isNotEmpty) ||
                  (expense.isStockPurchase &&
                      expense.purchaseUuid != null))
                Row(
                  spacing: 5,
                  children: [
                    if (expense.isStaffSalary &&
                        expense.staffName != null &&
                        expense.staffName!.isNotEmpty)
                      Expanded(
                        flex: 3,
                        child: ExpenseDetailsColumnSection(
                          theme: theme,
                          title: 'Staff Member',
                          text: expense.staffName!,
                        ),
                      ),
                    if (expense.isStockPurchase &&
                        expense.purchaseUuid != null)
                      Expanded(
                        flex: 2,
                        child: InkWell(
                          mouseCursor:
                              SystemMouseCursors.click,
                          onTap:
                              () => openLinkedPurchase(
                                context,
                                expense.purchaseUuid!,
                              ),
                          child:
                              ExpenseDetailsColumnSection(
                                theme: theme,
                                title: 'Linked Purchase',
                                text:
                                    'Purchase #${expense.purchaseUuid!.split('-').first.toUpperCase()}',
                              ),
                        ),
                      ),
                  ],
                ),
              ExpenseDetailsColumnSection(
                theme: theme,
                title: 'Description',
                text:
                    (expense.description != null &&
                            expense.description!
                                .trim()
                                .isNotEmpty)
                        ? expense.description!
                        : 'Not Set',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ExpenseDetailsColumnSection extends StatelessWidget {
  const ExpenseDetailsColumnSection({
    super.key,
    required this.theme,
    required this.title,
    required this.text,
  });

  final ThemeProvider theme;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 5,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          style: TextStyle(
            fontSize: theme.mobileTexts.b4.fontSize,
            color: theme.lightModeColor.secColor200,
          ),
          '$title:'.toUpperCase(),
        ),
        Row(
          children: [
            Expanded(
              child: Text(
                style: TextStyle(
                  fontSize: theme.mobileTexts.b4.fontSize,
                  fontWeight: FontWeight.bold,
                ),
                text,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
