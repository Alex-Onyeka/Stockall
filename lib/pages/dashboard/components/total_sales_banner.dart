import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:stockall/classes/temp_expenses_class.dart';
import 'package:stockall/classes/temp_user_class.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/theme_provider.dart';

class DashboardTotalSalesBanner extends StatefulWidget {
  final double? value;
  final TempUserClass? currentUser;
  final double? userValue;
  final List<TempExpensesClass>? expenses;
  const DashboardTotalSalesBanner({
    super.key,
    required this.theme,
    required this.value,
    this.currentUser,
    this.userValue,
    this.expenses,
  });

  final ThemeProvider theme;

  @override
  State<DashboardTotalSalesBanner> createState() =>
      _DashboardTotalSalesBannerState();
}

class _DashboardTotalSalesBannerState
    extends State<DashboardTotalSalesBanner> {
  String setName() {
    if (widget.currentUser != null) {
      return '${cutLongText(widget.currentUser!.name.toUpperCase(), 15)} (${widget.currentUser!.role})';
    } else {
      return 'Not Set';
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment(0.9, 0.0),
      children: [
        Container(
          padding: EdgeInsets.only(
            left: 15,
            top: 15,
            bottom: 10,
          ),
          decoration: BoxDecoration(
            // gradient: theme.lightModeColor.prGradient,
            color: widget.theme.lightModeColor.prColor300,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    style: TextStyle(
                      fontSize:
                          widget
                              .theme
                              .mobileTexts
                              .b3
                              .fontSize,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    'Today\'s Sale Revenue',
                  ),
                  Row(
                    children: [
                      Text(
                        style: TextStyle(
                          fontSize:
                              widget
                                  .theme
                                  .mobileTexts
                                  .h2
                                  .fontSize,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        nairaSymbol,
                      ),
                      Text(
                        style: TextStyle(
                          fontSize:
                              widget
                                  .theme
                                  .mobileTexts
                                  .h2
                                  .fontSize,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        formatLargeNumberDoubleWidgetDecimal(
                          widget.value != null
                              ? widget.value!
                              : 0,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 0),
                  Builder(
                    builder: (context) {
                      var expenses = widget.expenses;
                      List<TempExpensesClass>
                      getTodaysExpenses() {
                        return returnExpensesProvider(
                          context,
                          listen: false,
                        ).returnExpensesByDayOrWeek(
                          context,
                          expenses ?? [],
                        );
                      }

                      double getTotal() {
                        double tempTotal = 0;

                        for (var item
                            in getTodaysExpenses()) {
                          tempTotal += item.amount;
                        }
                        return tempTotal;
                      }

                      double getProfit() {
                        return widget.value! - getTotal();
                      }

                      return ExpensesAndProfitValues(
                        widget: widget,
                        expenses:
                            formatLargeNumberDoubleWidgetDecimal(
                              getTotal(),
                            ),
                        profit:
                            formatLargeNumberDoubleWidgetDecimal(
                              getProfit(),
                            ),
                      );
                    },
                  ),
                  SizedBox(height: 10),
                  Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    spacing: 5,
                    children: [
                      // Container(
                      //   padding: EdgeInsets.all(3),
                      //   decoration: BoxDecoration(
                      //     shape: BoxShape.circle,
                      //     color:
                      //         theme
                      //             .lightModeColor
                      //             .secColor200,
                      //   ),
                      // ),
                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: const Color.fromARGB(
                                255,
                                255,
                                208,
                                67,
                              ),
                              fontSize:
                                  widget
                                      .theme
                                      .mobileTexts
                                      .b4
                                      .fontSize,
                            ),

                            setName(),
                          ),
                          Text(
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: const Color.fromARGB(
                                241,
                                255,
                                255,
                                255,
                              ),
                              fontSize:
                                  widget
                                      .theme
                                      .mobileTexts
                                      .b3
                                      .fontSize,
                            ),

                            '$nairaSymbol${formatLargeNumberDoubleWidgetDecimal(widget.userValue ?? 0)}',
                          ),
                        ],
                      ),
                      Icon(
                        size: 14,
                        color: const Color.fromARGB(
                          255,
                          255,
                          208,
                          67,
                        ),
                        Icons.person,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          top: 30,
          child: Lottie.asset(
            welcomeLady,
            height: 100,
            fit: BoxFit.cover,
          ),
        ),
        // Image.asset(cctvImage, height: 85),
      ],
    );
  }
}

class ExpensesAndProfitValues extends StatelessWidget {
  const ExpensesAndProfitValues({
    super.key,
    required this.widget,
    this.profit,
    this.expenses,
  });

  final DashboardTotalSalesBanner widget;
  final String? expenses;
  final String? profit;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 15,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              style: TextStyle(
                fontSize:
                    widget.theme.mobileTexts.b3.fontSize,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),

              'Expenses:',
            ),
            Text(
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(
                  241,
                  255,
                  255,
                  255,
                ),
                fontSize:
                    widget.theme.mobileTexts.b3.fontSize,
              ),

              '$nairaSymbol ${expenses ?? 0}',
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              style: TextStyle(
                fontSize:
                    widget.theme.mobileTexts.b3.fontSize,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),

              'Profit:',
            ),
            Text(
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: const Color.fromARGB(
                  241,
                  255,
                  255,
                  255,
                ),
                fontSize:
                    widget.theme.mobileTexts.b3.fontSize,
              ),

              '$nairaSymbol ${profit ?? 0}',
            ),
          ],
        ),
      ],
    );
  }
}
