import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stockitt/classes/temp_expenses_class.dart';
import 'package:stockitt/constants/calculations.dart';
import 'package:stockitt/constants/constants_main.dart';
import 'package:stockitt/main.dart';

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
    if (text.length < 8) {
      return text;
    } else {
      return '${text.substring(0, 8)}...';
    }
  }

  // late Future<TempExpensesClass> expenseFuture;

  // Future<TempExpensesClass> getExpense() async {
  //   var tempExpense = await returnExpensesProvider(
  //     context,
  //     listen: false,
  //   ).getExpenses(
  //     returnShopProvider(
  //       context,
  //       listen: false,
  //     ).userShop!.shopId!,
  //   );

  //   return tempExpense.firstWhere(
  //     (exp) => exp.id! == widget.expenseId,
  //   );
  // }

  // @override
  // void initState() {
  //   super.initState();
  //   expenseFuture = getExpense();
  // }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Ink(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),

          borderRadius: BorderRadius.circular(5),
          color: Colors.white,
        ),
        child: InkWell(
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
                            cutLongText(
                              cutLongText(
                                widget.expense.name,
                              ),
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
                            '$nairaSymbol ${formatLargeNumberDouble(widget.expense.amount)}',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
