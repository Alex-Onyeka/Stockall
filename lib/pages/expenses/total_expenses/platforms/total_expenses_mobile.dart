import 'package:flutter/material.dart';
import 'package:stockitt/classes/temp_expenses_class.dart';
import 'package:stockitt/components/calendar/calendar_widget.dart';
import 'package:stockitt/components/major/empty_widget_display.dart';
import 'package:stockitt/components/major/empty_widget_display_only.dart';
import 'package:stockitt/constants/calculations.dart';
import 'package:stockitt/constants/constants_main.dart';
import 'package:stockitt/main.dart';
import 'package:stockitt/pages/expenses/add_expenses/add_expenses.dart';

class TotalExpensesMobile extends StatefulWidget {
  const TotalExpensesMobile({super.key});

  @override
  State<TotalExpensesMobile> createState() =>
      _TotalExpensesMobileState();
}

class _TotalExpensesMobileState
    extends State<TotalExpensesMobile> {
  Future<List<TempExpensesClass>> getExpenses() {
    var tempExpenses = returnExpensesProvider(
      context,
      listen: false,
    ).getExpenses(
      returnShopProvider(
        context,
        listen: false,
      ).userShop!.shopId!,
    );

    return tempExpenses;
  }

  late Future<List<TempExpensesClass>> expensesFuture;

  @override
  void initState() {
    super.initState();
    expensesFuture = getExpenses();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      clearDate();
    });
  }

  void clearDate() {
    returnExpensesProvider(
      context,
      listen: false,
    ).clearExpenseDate();
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return GestureDetector(
      onTap: () {
        returnExpensesProvider(
          context,
          listen: false,
        ).clearExpenseDate();
      },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 60,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Padding(
              padding: const EdgeInsets.only(
                left: 10.0,
                right: 5,
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded),
            ),
          ),
          centerTitle: true,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                style: TextStyle(
                  fontSize: theme.mobileTexts.b1.fontSize,
                  fontWeight: FontWeight.bold,
                ),
                returnExpensesProvider(context).dateSet ??
                    'Todays Expenses',
              ),
            ],
          ),
        ),
        body: FutureBuilder(
          future: expensesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return returnCompProvider(
                context,
                listen: false,
              ).showLoader('Loading');
            } else if (snapshot.hasError) {
              return EmptyWidgetDisplayOnly(
                title: 'An Error Occured',
                subText:
                    'Couldn\'t load your data because an error occured. Check your internet connection and try again.',
                theme: theme,
                height: 30,
                icon: Icons.clear,
              );
            } else {
              var expenses = returnExpensesProvider(
                context,
                listen: false,
              ).returnExpensesByDayOrWeek(
                context,
                snapshot.data!,
              );
              double getTotalExpenses() {
                double tempTotal = 0;
                for (var item in expenses) {
                  tempTotal += item.amount;
                }
                return tempTotal;
              }

              return Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                    ),
                    child: Column(
                      children: [
                        Material(
                          color: Colors.white,
                          child: Column(
                            children: [
                              Row(
                                spacing: 10,
                                children: [
                                  ValueSummaryTabSmall(
                                    color: Colors.amber,
                                    isMoney: true,
                                    title: 'Total Revenue',
                                    value:
                                        getTotalExpenses(),
                                  ),
                                  ValueSummaryTabSmall(
                                    value:
                                        expenses.length
                                            .toDouble(),
                                    title: 'Sales Number',
                                    color: Colors.green,
                                    isMoney: false,
                                  ),
                                ],
                              ),
                              Visibility(
                                visible:
                                    returnLocalDatabase(
                                          context,
                                        )
                                        .currentEmployee!
                                        .role !=
                                    'Owner',
                                child: SizedBox(height: 30),
                              ),
                              Visibility(
                                visible:
                                    returnLocalDatabase(
                                          context,
                                        )
                                        .currentEmployee!
                                        .role ==
                                    'Owner',
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.end,
                                  children: [
                                    MaterialButton(
                                      onPressed: () {
                                        if (returnExpensesProvider(
                                              context,
                                              listen: false,
                                            ).isDateSet ||
                                            returnExpensesProvider(
                                              context,
                                              listen: false,
                                            ).setDate) {
                                          returnExpensesProvider(
                                            context,
                                            listen: false,
                                          ).clearExpenseDate();
                                        } else {
                                          returnExpensesProvider(
                                            context,
                                            listen: false,
                                          ).openExpenseDatePicker();
                                        }
                                      },
                                      child: Row(
                                        spacing: 3,
                                        children: [
                                          Text(
                                            style: TextStyle(
                                              fontSize:
                                                  theme
                                                      .mobileTexts
                                                      .b2
                                                      .fontSize,
                                              fontWeight:
                                                  FontWeight
                                                      .bold,
                                              color:
                                                  Colors
                                                      .grey
                                                      .shade700,
                                            ),
                                            returnExpensesProvider(
                                                      context,
                                                    ).isDateSet ||
                                                    returnExpensesProvider(
                                                      context,
                                                    ).setDate
                                                ? 'Clear Date'
                                                : 'Set Date',
                                          ),
                                          Icon(
                                            size: 20,
                                            color:
                                                theme
                                                    .lightModeColor
                                                    .secColor100,
                                            returnExpensesProvider(
                                                      context,
                                                    ).isDateSet ||
                                                    returnExpensesProvider(
                                                      context,
                                                    ).setDate
                                                ? Icons
                                                    .clear
                                                : Icons
                                                    .date_range_outlined,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Builder(
                            builder: (context) {
                              if (expenses.isEmpty) {
                                return EmptyWidgetDisplay(
                                  title: 'Empty List',
                                  subText:
                                      'You don\'t have any Expenses under this category',
                                  buttonText:
                                      'Create Expenses',
                                  theme: theme,
                                  svg: expensesIconSvg,
                                  height: 35,
                                  action: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return AddExpenses();
                                        },
                                      ),
                                    );
                                  },
                                );
                              } else {
                                return ListView.builder(
                                  itemCount:
                                      expenses.length,
                                  itemBuilder: (
                                    context,
                                    index,
                                  ) {
                                    var expense =
                                        expenses[index];
                                    return ListTile(
                                      title: Text(
                                        expense.name,
                                      ),
                                    );
                                    // MainReceiptTile(
                                    //   key: ValueKey(
                                    //     receipt.id,
                                    //   ),
                                    //   mainReceipt: receipt,
                                    // );
                                  },
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (returnExpensesProvider(
                    context,
                  ).setDate)
                    Positioned(
                      top: 40,
                      left: 0,
                      right: 0,
                      child: Material(
                        child: Ink(
                          color: Colors.white,
                          child: Container(
                            padding: EdgeInsets.only(
                              top: 40,
                              bottom: 40,
                            ),
                            color: Colors.white,
                            child: Center(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(
                                      horizontal: 15.0,
                                    ),
                                child: Container(
                                  height: 430,
                                  width: 380,
                                  padding: EdgeInsets.all(
                                    15,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(
                                          10,
                                        ),
                                    color: Colors.white,
                                    border: Border.all(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  child: CalendarWidget(
                                    onDaySelected: (
                                      selectedDay,
                                      focusedDay,
                                    ) {
                                      returnExpensesProvider(
                                        context,
                                        listen: false,
                                      ).setExpenseDay(
                                        selectedDay,
                                      );
                                    },
                                    actionWeek: (
                                      startOfWeek,
                                      endOfWeek,
                                    ) {
                                      returnExpensesProvider(
                                        context,
                                        listen: false,
                                      ).setExpenseWeek(
                                        startOfWeek,
                                        endOfWeek,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}

class ValueSummaryTabSmall extends StatelessWidget {
  final double value;
  final String title;
  final Color color;
  final bool isMoney;

  const ValueSummaryTabSmall({
    super.key,
    required this.value,
    required this.title,
    required this.color,
    required this.isMoney,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.grey.shade300),
          color: Colors.grey.shade200,
        ),
        child: Row(
          spacing: 10,
          children: [
            Container(
              height: 10,
              width: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
              ),
            ),
            Column(
              spacing: 0,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                  title,
                ),
                Row(
                  children: [
                    Visibility(
                      visible: isMoney,
                      child: Text(
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                        "N",
                      ),
                    ),
                    SizedBox(width: 2),
                    Text(
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Colors.grey.shade700,
                      ),
                      formatLargeNumberDouble(value),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
