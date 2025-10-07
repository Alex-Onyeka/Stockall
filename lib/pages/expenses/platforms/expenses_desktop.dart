import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_expenses/temp_expenses_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/buttons/floating_action_butto.dart';
import 'package:stockall/components/calendar/calendar_widget.dart';
import 'package:stockall/components/major/desktop_page_container.dart';
import 'package:stockall/components/major/drawer_widget/platforms/my_drawer_widget_desktop.dart';
import 'package:stockall/components/major/empty_widget_display.dart';
import 'package:stockall/components/major/items_summary.dart';
import 'package:stockall/components/major/drawer_widget/my_drawer_widget.dart';
import 'package:stockall/components/major/right_side_bar.dart';
import 'package:stockall/components/major/top_banner.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/refresh_functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/expenses/add_expenses/add_expenses.dart';
import 'package:stockall/pages/expenses/components/expenses_tile.dart';
import 'package:stockall/pages/expenses/single_expense/expense_details.dart';
import 'package:stockall/pages/expenses/total_expenses/total_expenses.dart';
import 'package:stockall/services/auth_service.dart';

class ExpensesDesktop extends StatefulWidget {
  final bool? turnOn;
  final bool? isMain;
  const ExpensesDesktop({
    super.key,
    this.isMain,
    this.turnOn,
  });

  @override
  State<ExpensesDesktop> createState() =>
      _ExpensesDesktopState();
}

class _ExpensesDesktopState extends State<ExpensesDesktop> {
  late Future<List<TempExpensesClass>> expensesFuture;
  bool isLoading = false;

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
  }

  void clearDate() {
    returnExpensesProvider(
      context,
      listen: false,
    ).clearExpenseDate();
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

  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    var expenseProvider = returnExpensesProvider(
      context,
      listen: false,
    );
    var expenses = expenseProvider
        .returnExpensesByDayOrWeek(
          context,
          returnExpensesProvider(context).expenses,
        );
    var theme = returnTheme(context);
    return Scaffold(
      key: _scaffoldKey,
      drawer: MyDrawerWidgetDesktopMain(
        action: () {
          var safeContext = context;
          showDialog(
            context: context,
            builder: (context) {
              return ConfirmationAlert(
                theme: theme,
                message: 'You are about to Logout',
                title: 'Are you Sure?',
                action: () async {
                  Navigator.of(context).pop();
                  setState(() {
                    isLoading = true;
                  });
                  if (safeContext.mounted) {
                    await AuthService().signOut(
                      safeContext,
                    );
                  }
                },
              );
            },
          );
        },
        theme: theme,
        notifications:
            returnNotificationProvider(
                  context,
                ).notifications.isEmpty
                ? []
                : returnNotificationProvider(
                  context,
                ).notifications,
        globalKey: _scaffoldKey,
      ),
      body: Stack(
        children: [
          Row(
            spacing: 15,
            children: [
              MyDrawerWidget(
                globalKey: _scaffoldKey,
                action: () {
                  var safeContext = context;
                  showDialog(
                    context: context,
                    builder: (context) {
                      return ConfirmationAlert(
                        theme: theme,
                        message: 'You are about to Logout',
                        title: 'Are you Sure?',
                        action: () async {
                          Navigator.of(context).pop();
                          setState(() {
                            isLoading = true;
                          });
                          if (safeContext.mounted) {
                            await AuthService().signOut(
                              safeContext,
                            );
                          }
                        },
                      );
                    },
                  );
                },
                theme: theme,
                notifications:
                    returnNotificationProvider(
                          context,
                        ).notifications.isEmpty
                        ? []
                        : returnNotificationProvider(
                          context,
                        ).notifications,
              ),
              Expanded(
                child: DesktopPageContainer(
                  widget: Scaffold(
                    floatingActionButton: Builder(
                      builder: (context) {
                        return Visibility(
                          visible: expenses.isNotEmpty,
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
                                setState(() {});
                              });
                            },
                            color:
                                theme
                                    .lightModeColor
                                    .secColor100,
                            text: 'Add Expenses',
                            theme: theme,
                          ),
                        );
                      },
                    ),
                    body: SizedBox(
                      width:
                          MediaQuery.of(context).size.width,
                      height:
                          MediaQuery.of(
                            context,
                          ).size.height,
                      child: Stack(
                        children: [
                          Column(
                            children: [
                              Material(
                                color: Colors.transparent,
                                child: SizedBox(
                                  height:
                                      screenWidth(context) >
                                              tabletScreen
                                          ? 220
                                          : authorization(
                                            authorized:
                                                Authorizations()
                                                    .viewDate,
                                            context:
                                                context,
                                          )
                                          ? 250
                                          : 235,
                                  child: Stack(
                                    children: [
                                      TopBanner(
                                        turnOn:
                                            widget.turnOn,
                                        subTitle:
                                            'Data of All Expenses Records',
                                        title: 'Expenses',
                                        theme: theme,
                                        bottomSpace: 80,
                                        topSpace: 20,
                                        iconSvg:
                                            salesIconSvg,
                                        isMain:
                                            widget.isMain,
                                      ),

                                      Builder(
                                        builder: (context) {
                                          double
                                          getTotalAmount() {
                                            double
                                            tempAmount = 0;
                                            for (var item
                                                in expenses) {
                                              tempAmount +=
                                                  item.amount;
                                            }
                                            return tempAmount;
                                          }

                                          return Align(
                                            alignment:
                                                Alignment(
                                                  0,
                                                  1,
                                                ),
                                            child: InkWell(
                                              onTap: () {
                                                returnExpensesProvider(
                                                  context,
                                                  listen:
                                                      false,
                                                ).clearExpenseDate();
                                              },
                                              child: ItemsSummary(
                                                refreshAction:
                                                    () async {
                                                      await getExpenses();
                                                    },
                                                isFilter: authorization(
                                                  authorized:
                                                      Authorizations()
                                                          .viewDate,
                                                  context:
                                                      context,
                                                ),
                                                isMoney1:
                                                    true,
                                                mainTitle:
                                                    'Expenses Summary',
                                                subTitle:
                                                    returnExpensesProvider(
                                                      context,
                                                    ).dateSet ??
                                                    'For Today',
                                                firsRow:
                                                    true,
                                                color1:
                                                    Colors
                                                        .green,
                                                title1:
                                                    'Expenses Revenue',
                                                value1:
                                                    getTotalAmount(),
                                                color2:
                                                    Colors
                                                        .amber,
                                                title2:
                                                    'Expenses Number',
                                                value2:
                                                    expenses
                                                        .length
                                                        .toDouble(),
                                                secondRow:
                                                    false,
                                                onSearch:
                                                    false,
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
                                                      listen:
                                                          false,
                                                    ).clearExpenseDate();
                                                  } else {
                                                    returnExpensesProvider(
                                                      context,
                                                      listen:
                                                          false,
                                                    ).openExpenseDatePicker();
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
                                                horizontal:
                                                    10.0,
                                              ),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment
                                                    .spaceBetween,
                                            children: [
                                              Text(
                                                style: TextStyle(
                                                  fontWeight:
                                                      FontWeight
                                                          .bold,
                                                  fontSize:
                                                      16,
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
                                                  ).then((
                                                    _,
                                                  ) {
                                                    setState(
                                                      () {},
                                                    );
                                                  });
                                                },
                                                child: Row(
                                                  spacing:
                                                      5,
                                                  children: [
                                                    Text(
                                                      style: TextStyle(
                                                        color:
                                                            theme.lightModeColor.secColor100,
                                                      ),
                                                      'See All',
                                                    ),
                                                    Icon(
                                                      size:
                                                          16,
                                                      color:
                                                          theme.lightModeColor.secColor100,
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
                                          builder: (
                                            context,
                                          ) {
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal:
                                                        10.0,
                                                  ),
                                              child: Builder(
                                                builder: (
                                                  context,
                                                ) {
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
                                                            ).then(
                                                              (
                                                                _,
                                                              ) {
                                                                setState(
                                                                  () {
                                                                    // expensesFuture =
                                                                    //     getExpenses();
                                                                  },
                                                                );
                                                              },
                                                            );
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
                                                              ).then(
                                                                (
                                                                  context,
                                                                ) {
                                                                  setState(
                                                                    () {
                                                                      // expensesFuture =
                                                                      //     getExpenses();
                                                                    },
                                                                  );
                                                                },
                                                              );
                                                            },
                                                            expense:
                                                                expense,
                                                            key: ValueKey(
                                                              expense.uuid!,
                                                            ),
                                                          );
                                                        },
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
                                          MainAxisAlignment
                                              .center,
                                      children: [
                                        SizedBox(
                                          height:
                                              MediaQuery.of(
                                                    context,
                                                  )
                                                  .size
                                                  .height *
                                              0.2,
                                        ),
                                        Ink(
                                          color:
                                              Colors.white,
                                          child: Container(
                                            padding:
                                                EdgeInsets.only(
                                                  top: 20,
                                                  bottom:
                                                      20,
                                                ),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    10,
                                                  ),
                                              color:
                                                  Colors
                                                      .white,
                                            ),
                                            child: Center(
                                              child: Padding(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal:
                                                      5.0,
                                                ),
                                                child: Column(
                                                  children: [
                                                    Container(
                                                      width:
                                                          100,
                                                      height:
                                                          4,
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Colors.grey.shade400,
                                                        borderRadius: BorderRadius.circular(
                                                          5,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height:
                                                          20,
                                                    ),
                                                    Container(
                                                      height:
                                                          480,
                                                      width:
                                                          380,
                                                      padding: EdgeInsets.all(
                                                        15,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(
                                                          10,
                                                        ),
                                                        color:
                                                            Colors.white,
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
                                                  )
                                                  .size
                                                  .height *
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
                  ),
                ),
              ),
              RightSideBar(theme: theme),
            ],
          ),
          Visibility(
            visible: isLoading,
            child: returnCompProvider(
              context,
              listen: false,
            ).showLoader(message: 'Logging Out...'),
          ),
        ],
      ),
    );
  }
}
