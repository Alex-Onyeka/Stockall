import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stockall/classes/temp_expenses/temp_expenses_class.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';

class ExpensesTile extends StatefulWidget {
  final TempExpensesClass expense;
  final Function() action;
  const ExpensesTile({
    super.key,
    required this.expense,
    required this.action,
  });

  @override
  State<ExpensesTile> createState() => _ExpensesTileState();
}

class _ExpensesTileState extends State<ExpensesTile> {
  String cutLongText(String text) {
    if (text.length < 12) {
      return text;
    } else {
      return '${text.substring(0, 12)}...';
    }
  }

  String cutLongText2(String text) {
    if (text.length < 20) {
      return text;
    } else {
      return '${text.substring(0, 20)}...';
    }
  }

  Color _categoryColor(TempExpensesClass exp) {
    switch (exp.expenseType) {
      case ExpenseType.staffSalary:
        return Colors.indigo;
      case ExpenseType.stockPurchase:
        return Colors.teal;
      case ExpenseType.custom:
        return Colors.deepPurple;
      case ExpenseType.simpleExpense:
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    final catColor = _categoryColor(widget.expense);
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Ink(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),

          borderRadius: BorderRadius.circular(5),
          color: Colors.white,
        ),
        child: InkWell(
          mouseCursor: SystemMouseCursors.click,
          borderRadius: BorderRadius.circular(5),
          onTap: widget.action,
          child: Container(
            padding: EdgeInsetsDirectional.all(15),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.start,
                      spacing: 10,
                      children: [
                        SvgPicture.asset(
                          expensesIconSvg,
                          height: 20,
                        ),
                        Text(
                          style: TextStyle(
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b2
                                    .fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                          formatDateWithDay(
                            widget.expense.createdDate!,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      color: Colors.grey,
                      size: 20,
                      Icons.arrow_forward_ios_rounded,
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: const Color.fromARGB(
                      162,
                      245,
                      245,
                      245,
                    ),
                    border: Border.all(
                      color: Colors.grey.shade200,
                    ),
                  ),
                  child: Row(
                    spacing: 5,
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        spacing: 3,
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b3
                                      .fontSize,
                            ),
                            'Expenses Name',
                          ),
                          Text(
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b2
                                      .fontSize,
                              fontWeight: FontWeight.bold,
                            ),
                            cutLongText2(
                              widget.expense.name,
                            ),
                          ),
                        ],
                      ),

                      Column(
                        spacing: 3,
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b3
                                      .fontSize,
                            ),
                            'Total',
                          ),
                          Text(
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b2
                                      .fontSize,
                              color:
                                  theme
                                      .lightModeColor
                                      .secColor200,
                              fontWeight: FontWeight.bold,
                            ),
                            formatMoneyMid(
                              amount: widget.expense.amount,
                              context: context,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Row(
                        children: [
                          Text(
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b3
                                      .fontSize,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.bold,
                            ),
                            'Created By: ',
                          ),
                          Flexible(
                            child: Text(
                              style: TextStyle(
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .b3
                                        .fontSize,
                                color: Colors.grey.shade900,
                                fontWeight: FontWeight.bold,
                              ),
                              cutLongText2(
                                widget.expense.creator ??
                                    'Not Set',
                              ),
                              overflow:
                                  TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      spacing: 6,
                      children: [
                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                          decoration: BoxDecoration(
                            color: catColor.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius:
                                BorderRadius.circular(4),
                            border: Border.all(
                              color: catColor.withValues(
                                alpha: 0.35,
                              ),
                            ),
                          ),
                          child: Text(
                            widget.expense.categoryLabel,
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b5
                                      .fontSize,
                              color: catColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius:
                                BorderRadius.circular(4),
                            border: Border.all(
                              color: Colors.grey.shade300,
                            ),
                          ),
                          child: Text(
                            widget
                                .expense
                                .resolvedPaymentChannelLabel,
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b5
                                      .fontSize,
                              color: Colors.grey.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (widget.expense.isStaffSalary &&
                    widget.expense.staffName != null &&
                    widget
                        .expense
                        .staffName!
                        .isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Staff: ${widget.expense.staffName}',
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b4.fontSize,
                        color: Colors.indigo.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                if (widget.expense.isStockPurchase &&
                    widget.expense.purchaseUuid !=
                        null) ...[
                  const SizedBox(height: 6),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Linked Purchase #${widget.expense.purchaseUuid!.split('-').first.toUpperCase()}',
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b4.fontSize,
                        color: Colors.teal.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
