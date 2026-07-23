import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_expenses/temp_expenses_class.dart';
import 'package:stockall/components/buttons/floating_action_butto.dart';
import 'package:stockall/components/major/empty_widget_display.dart';
import 'package:stockall/components/major/items_summary.dart';
import 'package:stockall/components/major/top_banner.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/date_picker_function.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/refresh_functions.dart';
import 'package:stockall/constants/subscription/expenses_auth.dart';
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
  @override
  void initState() {
    super.initState();
    returnData().toggleFloatingAction(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      clearDate();
    });
  }

  void clearDate() {
    returnExpensesProvider(
      context,
      listen: false,
    ).clearDate();
  }

  Future<void> getExpenses() async {
    await RefreshFunctions(
      context,
    ).refreshExpenses(context);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    // var expenseProvider = returnExpensesProvider(
    //   context,
    //   listen: false,
    // );
    var expenses = returnExpensesProvider(
      context,
    ).returnExpensesByDayOrWeek(context);
    var theme = returnTheme(context);
    return Scaffold(
      floatingActionButton: Builder(
        builder: (context) {
          return Visibility(
            visible: expenses.isNotEmpty,
            child: FloatingActionButtonMain(
              action: () {
                ExpensesAuthAction()
                    .numberOfDailyExpensesAction(
                      context: context,
                      action: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return AddExpenses();
                            },
                          ),
                        ).then((_) {
                          setState(() {});
                        });
                      },
                    );
              },
              color: theme.lightModeColor.secColor100,
              text: 'Add Expenses',
              theme: theme,
            ),
          );
        },
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            Material(
              color: Colors.transparent,
              child: SizedBox(
                height:
                    authorization(
                          authorized:
                              Authorizations().viewDate,
                        )
                        ? 250
                        : 235,
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
                        double getTotalAmount() {
                          double tempAmount = 0;
                          for (var item in expenses) {
                            tempAmount += item.amount;
                          }
                          return tempAmount;
                        }

                        return Align(
                          alignment: Alignment(0, 1),
                          child: InkWell(
                            mouseCursor:
                                SystemMouseCursors.click,
                            onTap: () {
                              returnExpensesProvider(
                                context,
                                listen: false,
                              ).clearDate();
                            },
                            child: ItemsSummary(
                              isFilter: authorization(
                                authorized:
                                    Authorizations()
                                        .viewDate,
                              ),
                              isMoney1: true,
                              mainTitle: 'Expenses Summary',
                              subTitle: 'All Expenses',
                              firsRow: true,
                              color1: Colors.green,
                              title1: 'Expenses Revenue',
                              value1: getTotalAmount(),
                              color2: Colors.amber,
                              title2: 'Expenses Number',
                              value2:
                                  expenses.length
                                      .toDouble(),
                              secondRow: false,
                              onSearch: false,
                              isDateSet:
                                  returnExpensesProvider(
                                        context,
                                      ).dateSet !=
                                      null ||
                                  returnExpensesProvider(
                                        context,
                                      ).rangeStartDate !=
                                      null,
                              setDate:
                                  returnExpensesProvider(
                                        context,
                                      ).dateSet !=
                                      null ||
                                  returnExpensesProvider(
                                        context,
                                      ).rangeStartDate !=
                                      null,
                              filterAction: () {
                                if (returnExpensesProvider(
                                          context,
                                          listen: false,
                                        ).dateSet !=
                                        null ||
                                    returnExpensesProvider(
                                          context,
                                          listen: false,
                                        ).rangeStartDate !=
                                        null) {
                                  returnExpensesProvider(
                                    context,
                                    listen: false,
                                  ).clearDate();
                                } else {
                                  mainDatePicker(
                                    context: context,
                                    theme: theme,
                                    singleDate: (date) {
                                      returnExpensesProvider(
                                        context,
                                        listen: false,
                                      ).setDate(date!);
                                    },
                                    rangeDate: (
                                      firstDate,
                                      lastDate,
                                    ) {
                                      returnExpensesProvider(
                                        context,
                                        listen: false,
                                      ).setRange(
                                        firstDate!,
                                        lastDate ??
                                            DateTime.now(),
                                      );
                                    },
                                  );
                                }
                              },
                            ),
                          ),
                        );
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
                  padding: const EdgeInsets.fromLTRB(
                    10.0,
                    10,
                    10,
                    10,
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10.0,
                        ),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          children: [
                            Text(
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              'All Expenses',
                            ),
                            MaterialButton(
                              mouseCursor:
                                  SystemMouseCursors.click,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return TotalExpenses();
                                    },
                                  ),
                                ).then((_) {
                                  setState(() {});
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
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(
                                  horizontal: 10.0,
                                ),
                            child: Builder(
                              builder: (context) {
                                if (expenses.isEmpty) {
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
                                            'Click on the button below to Record an Expense.',
                                        title:
                                            'No Expenses Recorded Yet',
                                        svg:
                                            expensesIconSvg,
                                        height: 35,
                                        action: () {
                                          ExpensesAuthAction().numberOfDailyExpensesAction(
                                            context:
                                                context,
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
                                              ).then((_) {
                                                setState(
                                                  () {},
                                                );
                                              });
                                            },
                                          );
                                        },
                                        altAction: () async {
                                          await getExpenses();
                                          setState(() {});
                                        },
                                        altActionText:
                                            'Refresh Expenses',
                                        theme: theme,
                                      ),
                                    ),
                                  );
                                } else {
                                  return RefreshIndicator(
                                    onRefresh: () async {
                                      await getExpenses();
                                    },
                                    backgroundColor:
                                        Colors.white,
                                    color:
                                        theme
                                            .lightModeColor
                                            .prColor300,
                                    displacement: 10,
                                    child: SizedBox(
                                      height:
                                          MediaQuery.of(
                                            context,
                                          ).size.height -
                                          350,
                                      child: ListView.builder(
                                        itemCount:
                                            expenses.length,
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
                                                      expenseUuid:
                                                          expense.uuid!,
                                                    );
                                                  },
                                                ),
                                              ).then((
                                                context,
                                              ) {
                                                setState(() {
                                                  // expensesFuture =
                                                  //     getExpenses();
                                                });
                                              });
                                            },
                                            expense:
                                                expense,
                                            key: ValueKey(
                                              expense.uuid!,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
