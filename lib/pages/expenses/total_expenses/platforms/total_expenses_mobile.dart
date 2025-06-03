import 'package:flutter/material.dart';
import 'package:storrec/classes/temp_expenses_class.dart';
import 'package:storrec/components/calendar/calendar_widget.dart';
import 'package:storrec/components/major/empty_widget_display.dart';
import 'package:storrec/components/major/empty_widget_display_only.dart';
import 'package:storrec/constants/calculations.dart';
import 'package:storrec/constants/constants_main.dart';
import 'package:storrec/main.dart';
import 'package:storrec/pages/expenses/add_expenses/add_expenses.dart';
import 'package:storrec/pages/expenses/components/expenses_tile.dart';
import 'package:storrec/pages/expenses/single_expense/expense_details.dart';

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
                                    return ExpensesTile(
                                      expense: expense,
                                      action: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (
                                              context,
                                            ) {
                                              return ExpenseDetails(
                                                expenseId:
                                                    expense
                                                        .id!,
                                              );
                                            },
                                          ),
                                        );
                                      },
                                    );
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
                    Material(
                      color: const Color.fromARGB(
                        75,
                        0,
                        0,
                        0,
                      ),
                      child: GestureDetector(
                        onTap: () {
                          returnExpensesProvider(
                            context,
                            listen: false,
                          ).clearExpenseDate();
                        },
                        child: SingleChildScrollView(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(
                                  horizontal: 10.0,
                                ),
                            child: Column(
                              mainAxisAlignment:
                                  MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height:
                                      MediaQuery.of(
                                        context,
                                      ).size.height *
                                      0.05,
                                ),
                                Ink(
                                  color: Colors.white,
                                  child: Container(
                                    padding:
                                        EdgeInsets.only(
                                          top: 20,
                                          bottom: 20,
                                        ),
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(
                                            10,
                                          ),
                                      color: Colors.white,
                                    ),
                                    child: Center(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.symmetric(
                                              horizontal:
                                                  5.0,
                                            ),
                                        child: Column(
                                          children: [
                                            Container(
                                              width: 100,
                                              height: 4,
                                              decoration: BoxDecoration(
                                                color:
                                                    Colors
                                                        .grey
                                                        .shade400,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      5,
                                                    ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 20,
                                            ),
                                            Container(
                                              height: 480,
                                              width: 380,
                                              padding:
                                                  EdgeInsets.all(
                                                    15,
                                                  ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      10,
                                                    ),
                                                color:
                                                    Colors
                                                        .white,
                                                // border: Border.all(
                                                //   color:
                                                //       Colors
                                                //           .grey,
                                                // ),
                                              ),
                                              child: CalendarWidget(
                                                onDaySelected: (
                                                  selectedDay,
                                                  focusedDay,
                                                ) {
                                                  returnExpensesProvider(
                                                    context,
                                                    listen:
                                                        false,
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
                                                    listen:
                                                        false,
                                                  ).setExpenseWeek(
                                                    startOfWeek,
                                                    endOfWeek,
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.of(
                                        context,
                                      ).size.height *
                                      0.4,
                                ),
                              ],
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
