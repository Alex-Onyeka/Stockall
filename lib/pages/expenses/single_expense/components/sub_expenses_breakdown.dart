import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_expenses/sub_expense.dart';
import 'package:stockall/classes/temp_expenses/temp_expenses_class.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/providers/theme_provider.dart';

/// Breakdown of an expense's sub-expenses on the details page (mobile
/// and desktop). Shows nothing when the expense has none.
class SubExpensesBreakdown extends StatelessWidget {
  final TempExpensesClass expense;
  final ThemeProvider theme;

  const SubExpensesBreakdown({
    super.key,
    required this.expense,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    if (!expense.hasSubExpenses) return const SizedBox.shrink();
    final subs = expense.subExpenses!;
    final entries = SubExpense.paymentEntriesOf(subs);
    final greyStyle = TextStyle(
      fontSize: theme.mobileTexts.b3.fontSize,
      color: Colors.grey.shade700,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 40),
        Text(
          'BREAKDOWN:',
          style: TextStyle(
            fontSize: theme.mobileTexts.b2.fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        const Divider(),
        for (final sub in subs) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 15,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 2,
                    children: [
                      Text(
                        sub.name,
                        style: TextStyle(
                          fontSize: theme.mobileTexts.b2.fontSize,
                          fontWeight: FontWeight.w600,
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
                          sub.description!.trim().isNotEmpty)
                        Text(sub.description!.trim(), style: greyStyle),
                    ],
                  ),
                ),
                Text(
                  formatMoneyMid(amount: sub.amount, context: context),
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b2.fontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade200),
        ],
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: Text(
                'Total',
                style: TextStyle(
                  fontSize: theme.mobileTexts.b2.fontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Text(
              formatMoneyMid(amount: expense.subExpensesTotal, context: context),
              style: TextStyle(
                fontSize: theme.mobileTexts.b2.fontSize,
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Text(
              'This breakdown no longer matches the expense amount (${formatMoneyMid(amount: expense.amount, context: context)}). It was probably edited on an older app version. Edit and save the expense to bring them back in line.',
              style: TextStyle(
                fontSize: theme.mobileTexts.b3.fontSize,
                color: Colors.orange.shade900,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
