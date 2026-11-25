import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_expenses/sub_expense.dart';
import 'package:stockall/classes/temp_expenses/temp_expenses_class.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/main.dart';

/// Card-style sub-expenses breakdown matching the Supplier/Customer section cards.
class ExpenseBreakdownSectionWidget
    extends StatelessWidget {
  final TempExpensesClass expense;
  const ExpenseBreakdownSectionWidget({
    super.key,
    required this.expense,
  });

  @override
  Widget build(BuildContext context) {
    if (!expense.hasSubExpenses) {
      return const SizedBox.shrink();
    }
    final theme = returnTheme(context);
    final subs = expense.subExpenses!;
    final entries = SubExpense.paymentEntriesOf(subs);
    final greyStyle = TextStyle(
      fontSize: theme.mobileTexts.b4.fontSize,
      color: Colors.grey.shade600,
    );

    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(
        vertical: 25,
        horizontal: 15,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(26, 0, 0, 0),
            blurRadius: 10,
          ),
        ],
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: 5,
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade100,
                ),
                child: const Icon(
                  size: 16,
                  Icons.list_alt_rounded,
                ),
              ),
              Text(
                'Breakdown'.toUpperCase(),
                style: TextStyle(
                  fontSize: theme.mobileTexts.b4.fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Divider(color: Colors.grey.shade300, height: 25),
          for (final sub in subs) ...[
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 10,
              ),
              child: Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                spacing: 15,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      spacing: 3,
                      children: [
                        Text(
                          sub.name,
                          style: TextStyle(
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b4
                                    .fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          [
                            if (sub.quantity != null)
                              'Qty ${formatLargeNumberDouble(sub.quantity!)}',
                            sub.paymentChannel,
                          ].join(' · '),
                          style: greyStyle,
                        ),
                        if (sub.description != null &&
                            sub.description!
                                .trim()
                                .isNotEmpty)
                          Text(
                            sub.description!.trim(),
                            style: greyStyle,
                          ),
                      ],
                    ),
                  ),
                  Text(
                    formatMoneyMid(
                      amount: sub.amount,
                      context: context,
                    ),
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b4.fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: Colors.grey.shade200),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Total',
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b3.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                formatMoneyMid(
                  amount: expense.subExpensesTotal,
                  context: context,
                ),
                style: TextStyle(
                  fontSize: theme.mobileTexts.b3.fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            entries
                .map(
                  (e) =>
                      '${e.method}: ${formatMoneyMid(amount: e.amount, context: context)}',
                )
                .join(', '),
            style: greyStyle,
          ),
          if (expense.subExpensesMismatch) ...[
            const SizedBox(height: 10),
            Text(
              'Sub-expenses total (${formatMoneyMid(amount: expense.subExpensesTotal, context: context)}) differs from recorded expense (${formatMoneyMid(amount: expense.amount, context: context)}).',
              style: TextStyle(
                fontSize: theme.mobileTexts.b4.fontSize,
                color: Colors.orange.shade800,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
