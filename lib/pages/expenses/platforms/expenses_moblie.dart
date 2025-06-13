import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stockall/classes/temp_expenses_class.dart';
import 'package:stockall/components/buttons/floating_action_butto.dart';
import 'package:stockall/components/calendar/calendar_widget.dart';
import 'package:stockall/components/major/empty_widget_display.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/components/major/items_summary.dart';
import 'package:stockall/components/major/top_banner.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/expenses/add_expenses/add_expenses.dart';
import 'package:stockall/pages/expenses/components/expenses_tile.dart';
import 'package:stockall/pages/expenses/single_expense/expense_details.dart';
import 'package:stockall/pages/expenses/total_expenses/total_expenses.dart';

class ExpensesMoblie extends StatefulWidget {
  final bool? isMain;
  const ExpensesMoblie({super.key, this.isMain});

  @override
  State<ExpensesMoblie> createState() =>
      _ExpensesMoblieState();
}

class _ExpensesMoblieState extends State<ExpensesMoblie> {
  late Future<List<TempExpensesClass>> expensesFuture;

  Future<List<TempExpensesClass>> getExpenses() async {
    var tempExp = await returnExpensesProvider(
      context,
      listen: false,
    ).getExpenses(
      returnShopProvider(
        context,
        listen: false,
      ).userShop!.shopId!,
    );

    return tempExp;
  }

  @override
  void initState() {
    super.initState();
    returnData(
      context,
      listen: false,
    ).toggleFloatingAction(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      clearDate();
    });

    expensesFuture = getExpenses();
  }

  void clearDate() {
    returnExpensesProvider(
      context,
      listen: false,
    ).clearExpenseDate();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    expensesFuture = getExpenses();
  }

  @override
  Widget build(BuildContext context) {
    var expenseProvider = returnExpensesProvider(
      context,
      listen: false,
    );
    var theme = returnTheme(context);
    return FutureBuilder(
      future: expensesFuture,
      builder: (context, snapshot) {
        return Scaffold(
          floatingActionButton: Builder(
            builder: (context) {
              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return Container();
              } else if (snapshot.hasError) {
                return Container();
              } else {
                var expenses = snapshot.data;
                return Visibility(
                  visible: expenses!.isNotEmpty,
                  child: FloatingActionButtonMain(
                    action: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return AddExpenses();
                          },
                        ),
                      ).then((_) {
                        setState(() {
                          expensesFuture = getExpenses();
                        });
                      });
                    },
                    color: theme.lightModeColor.secColor100,
                    text: 'Add Expenses',
                    theme: theme,
                  ),
                );
              }
            },
          ),
          body: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Stack(
              children: [
                Column(
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: SizedBox(
                        height: 260,
                        child: Stack(
                          children: [
                            TopBanner(
                              subTitle:
                                  'Data of All Expenses Records',
                              title: 'Expenses',
                              theme: theme,
                              bottomSpace: 80,
                              topSpace: 20,
                              iconSvg: salesIconSvg,
                              isMain: widget.isMain,
                            ),

                            Builder(
                              builder: (context) {
                                if (snapshot
                                        .connectionState ==
                                    ConnectionState
                                        .waiting) {
                                  return Align(
                                    alignment: Alignment(
                                      0,
                                      1,
                                    ),
                                    child: InkWell(
                                      onTap: () {},
                                      child: ItemsSummary(
                                        isFilter: true,
                                        isMoney1: true,
                                        mainTitle:
                                            'Expenses Summary',
                                        subTitle:
                                            returnExpensesProvider(
                                              context,
                                            ).dateSet ??
                                            'For Today',
                                        firsRow: true,
                                        color1:
                                            Colors.green,
                                        title1:
                                            'Expenses Revenue',
                                        value1: 0,
                                        color2:
                                            Colors.amber,
                                        title2:
                                            'Expenses Number',
                                        value2: 0,
                                        secondRow: false,
                                        onSearch: false,
                                        isDateSet: false,
                                        setDate: false,
                                        filterAction: () {},
                                      ),
                                    ),
                                  );
                                } else if (snapshot
                                    .hasError) {
                                  return Align(
                                    alignment: Alignment(
                                      0,
                                      1,
                                    ),
                                    child: InkWell(
                                      onTap: () {},
                                      child: ItemsSummary(
                                        isFilter: true,
                                        isMoney1: true,
                                        mainTitle:
                                            'Expenses Summary',
                                        subTitle:
                                            returnExpensesProvider(
                                              context,
                                            ).dateSet ??
                                            'For Today',
                                        firsRow: true,
                                        color1:
                                            Colors.green,
                                        title1:
                                            'Expenses Revenue',
                                        value1: 0,
                                        color2:
                                            Colors.amber,
                                        title2:
                                            'Expenses Number',
                                        value2: 0,
                                        secondRow: false,
                                        onSearch: false,
                                        isDateSet: false,
                                        setDate: false,
                                        filterAction: () {},
                                      ),
                                    ),
                                  );
                                } else {
                                  var expenses =
                                      returnExpensesProvider(
                                        context,
                                        listen: false,
                                      ).returnExpensesByDayOrWeek(
                                        context,
                                        snapshot.data!,
                                      );

                                  double getTotalAmount() {
                                    double tempAmount = 0;
                                    for (var item
                                        in expenses) {
                                      tempAmount +=
                                          item.amount;
                                    }
                                    return tempAmount;
                                  }

                                  return Align(
                                    alignment: Alignment(
                                      0,
                                      1,
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        returnExpensesProvider(
                                          context,
                                          listen: false,
                                        ).clearExpenseDate();
                                      },
                                      child: ItemsSummary(
                                        isFilter: true,
                                        // returnLocalDatabase(
                                        //       context,
                                        //       listen:
                                        //           false,
                                        //     )
                                        //     .currentEmployee!
                                        //     .role ==
                                        // 'Owner',
                                        isMoney1: true,
                                        mainTitle:
                                            'Expenses Summary',
                                        subTitle:
                                            returnExpensesProvider(
                                              context,
                                            ).dateSet ??
                                            'For Today',
                                        firsRow: true,
                                        color1:
                                            Colors.green,
                                        title1:
                                            'Expenses Revenue',
                                        value1:
                                            getTotalAmount(),
                                        color2:
                                            Colors.amber,
                                        title2:
                                            'Expenses Number',
                                        value2:
                                            expenses.length
                                                .toDouble(),
                                        secondRow: false,
                                        onSearch: false,
                                        isDateSet:
                                            expenseProvider
                                                .isDateSet,
                                        setDate:
                                            expenseProvider
                                                .setDate,
                                        filterAction: () {
                                          if (returnExpensesProvider(
                                                context,
                                                listen:
                                                    false,
                                              ).isDateSet ||
                                              returnExpensesProvider(
                                                context,
                                                listen:
                                                    false,
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
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                            //
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        child: Padding(
                          padding:
                              const EdgeInsets.fromLTRB(
                                10.0,
                                10,
                                10,
                                10,
                              ),
                          child: Column(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(
                                      horizontal: 10.0,
                                    ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment
                                          .spaceBetween,
                                  children: [
                                    Text(
                                      style: TextStyle(
                                        fontWeight:
                                            FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                      returnExpensesProvider(
                                            context,
                                          ).dateSet ??
                                          'Expenses For Today',
                                    ),
                                    MaterialButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (
                                              context,
                                            ) {
                                              return TotalExpenses();
                                            },
                                          ),
                                        ).then((_) {
                                          setState(() {
                                            expensesFuture =
                                                getExpenses();
                                          });
                                        });
                                      },
                                      child: Row(
                                        spacing: 5,
                                        children: [
                                          Text(
                                            style: TextStyle(
                                              color:
                                                  theme
                                                      .lightModeColor
                                                      .secColor100,
                                            ),
                                            'See All',
                                          ),
                                          Icon(
                                            size: 16,
                                            color:
                                                theme
                                                    .lightModeColor
                                                    .secColor100,
                                            Icons
                                                .arrow_forward_ios_rounded,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Builder(
                                builder: (context) {
                                  if (snapshot
                                          .connectionState ==
                                      ConnectionState
                                          .waiting) {
                                    return Expanded(
                                      child: ListView.builder(
                                        itemCount: 4,
                                        itemBuilder: (
                                          context,
                                          index,
                                        ) {
                                          return Shimmer.fromColors(
                                            baseColor:
                                                Colors
                                                    .grey
                                                    .shade300,
                                            highlightColor:
                                                Colors
                                                    .white,
                                            child: Container(
                                              margin: EdgeInsets.symmetric(
                                                vertical: 5,
                                                horizontal:
                                                    15,
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      5,
                                                    ),
                                                color:
                                                    Colors
                                                        .grey,
                                              ),
                                              height: 150,
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  } else if (snapshot
                                      .hasError) {
                                    return SizedBox(
                                      height:
                                          MediaQuery.of(
                                            context,
                                          ).size.height -
                                          400,
                                      child: Center(
                                        child: EmptyWidgetDisplayOnly(
                                          title:
                                              'An Error Occured',
                                          subText:
                                              'Couldn\'t load your data because an error occured. Check your internet connection and try again.',
                                          theme: theme,
                                          height: 30,
                                          icon: Icons.clear,
                                        ),
                                      ),
                                    );
                                  } else {
                                    var expenses =
                                        returnExpensesProvider(
                                          context,
                                          listen: false,
                                        ).returnExpensesByDayOrWeek(
                                          context,
                                          snapshot.data!,
                                        );
                                    return Padding(
                                      padding:
                                          const EdgeInsets.symmetric(
                                            horizontal:
                                                10.0,
                                          ),
                                      child: Builder(
                                        builder: (context) {
                                          if (expenses
                                              .isEmpty) {
                                            return SizedBox(
                                              height:
                                                  MediaQuery.of(
                                                    context,
                                                  ).size.height -
                                                  400,
                                              child: Center(
                                                child: EmptyWidgetDisplay(
                                                  buttonText:
                                                      'Create Expenses',
                                                  subText:
                                                      'Click on the button below Record an Expense.',
                                                  title:
                                                      'No Expenses Recorded Yet',
                                                  svg:
                                                      expensesIconSvg,
                                                  height:
                                                      35,
                                                  action: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (
                                                          context,
                                                        ) {
                                                          return AddExpenses();
                                                        },
                                                      ),
                                                    ).then((
                                                      _,
                                                    ) {
                                                      setState(() {
                                                        expensesFuture =
                                                            getExpenses();
                                                      });
                                                    });
                                                  },
                                                  theme:
                                                      theme,
                                                ),
                                              ),
                                            );
                                          } else {
                                            return SizedBox(
                                              height:
                                                  MediaQuery.of(
                                                    context,
                                                  ).size.height -
                                                  350,
                                              child: ListView.builder(
                                                itemCount:
                                                    expenses
                                                        .length,
                                                itemBuilder: (
                                                  context,
                                                  index,
                                                ) {
                                                  TempExpensesClass
                                                  expense =
                                                      expenses[index];
                                                  return ExpensesTile(
                                                    action: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (
                                                            context,
                                                          ) {
                                                            return ExpenseDetails(
                                                              expenseId:
                                                                  expense.id!,
                                                            );
                                                          },
                                                        ),
                                                      ).then((
                                                        context,
                                                      ) {
                                                        setState(() {
                                                          expensesFuture =
                                                              getExpenses();
                                                        });
                                                      });
                                                    },
                                                    expense:
                                                        expense,
                                                    key: ValueKey(
                                                      expense
                                                          .id!,
                                                    ),
                                                  );
                                                },
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (returnExpensesProvider(context).setDate)
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
                                    0.2,
                              ),
                              Ink(
                                color: Colors.white,
                                child: Container(
                                  padding: EdgeInsets.only(
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
                                            horizontal: 5.0,
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
            ),
          ),
        );
      },
    );
  }
}
