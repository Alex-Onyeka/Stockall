import 'package:flutter/material.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/buttons/floating_action_butto.dart';
import 'package:stockall/components/calendar/calendar_widget.dart';
import 'package:stockall/components/major/desktop_page_container.dart';
import 'package:stockall/components/major/drawer_widget/platforms/my_drawer_widget_desktop.dart';
import 'package:stockall/components/major/empty_widget_display.dart';
import 'package:stockall/components/major/drawer_widget/my_drawer_widget.dart';
import 'package:stockall/components/major/right_side_bar.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/expenses/add_expenses/add_expenses.dart';
import 'package:stockall/pages/expenses/components/expenses_tile.dart';
import 'package:stockall/pages/expenses/single_expense/expense_details.dart';
import 'package:stockall/services/auth_service.dart';

class TotalExpensesDesktop extends StatefulWidget {
  const TotalExpensesDesktop({super.key});

  @override
  State<TotalExpensesDesktop> createState() =>
      TotalExpensesDesktopState();
}

class TotalExpensesDesktopState
    extends State<TotalExpensesDesktop> {
  @override
  void initState() {
    super.initState();
    // expensesFuture = getExpenses();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      clearDate();
      returnData(
        context,
        listen: false,
      ).toggleFloatingAction(context);
    });
  }

  void clearDate() {
    returnExpensesProvider(
      context,
      listen: false,
    ).clearExpenseDate();
  }

  bool isLoading = false;
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    var expensesMain =
        returnExpensesProvider(context).expenses;

    return GestureDetector(
      onTap: () {
        returnExpensesProvider(
          context,
          listen: false,
        ).clearExpenseDate();
      },
      child: Scaffold(
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
                          message:
                              'You are about to Logout',
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
                            child: Icon(
                              Icons
                                  .arrow_back_ios_new_rounded,
                            ),
                          ),
                        ),
                        centerTitle: true,
                        title: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              style: TextStyle(
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .b1
                                        .fontSize,
                                fontWeight: FontWeight.bold,
                              ),
                              returnExpensesProvider(
                                    context,
                                  ).dateSet ??
                                  'Todays Expenses',
                            ),
                          ],
                        ),
                      ),
                      floatingActionButton:
                          FloatingActionButtonMain(
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
                                  // expensesFuture = getExpenses();
                                });
                              });
                            },
                            color:
                                theme
                                    .lightModeColor
                                    .secColor100,
                            text: 'Add Expenses',
                            theme: theme,
                          ),
                      body: Builder(
                        builder: (context) {
                          var expenses =
                              returnExpensesProvider(
                                context,
                              ).returnExpensesByDayOrWeek(
                                context,
                                expensesMain,
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
                                padding:
                                    const EdgeInsets.symmetric(
                                      horizontal: 20.0,
                                    ),
                                child: RefreshIndicator(
                                  onRefresh: () {
                                    return returnExpensesProvider(
                                      context,
                                      listen: false,
                                    ).getExpenses(
                                      shopId(context),
                                    );
                                  },
                                  backgroundColor:
                                      Colors.white,
                                  color:
                                      theme
                                          .lightModeColor
                                          .prColor300,
                                  displacement: 10,
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
                                                  color:
                                                      Colors
                                                          .amber,
                                                  isMoney:
                                                      true,
                                                  title:
                                                      'Expenses Cost',
                                                  value:
                                                      getTotalExpenses(),
                                                ),
                                                ValueSummaryTabSmall(
                                                  value:
                                                      expenses
                                                          .length
                                                          .toDouble(),
                                                  title:
                                                      'Expenses Number',
                                                  color:
                                                      Colors
                                                          .green,
                                                  isMoney:
                                                      false,
                                                ),
                                              ],
                                            ),
                                            Visibility(
                                              visible: authorization(
                                                authorized:
                                                    Authorizations()
                                                        .viewDate,
                                                context:
                                                    context,
                                              ),
                                              child:
                                                  SizedBox(
                                                    height:
                                                        30,
                                                  ),
                                            ),
                                            Visibility(
                                              visible: authorization(
                                                authorized:
                                                    Authorizations()
                                                        .viewDate,
                                                context:
                                                    context,
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .end,
                                                children: [
                                                  MaterialButton(
                                                    onPressed: () {
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
                                                    child: Row(
                                                      spacing:
                                                          3,
                                                      children: [
                                                        Text(
                                                          style: TextStyle(
                                                            fontSize:
                                                                theme.mobileTexts.b2.fontSize,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color:
                                                                Colors.grey.shade700,
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
                                                          size:
                                                              20,
                                                          color:
                                                              theme.lightModeColor.secColor100,
                                                          returnExpensesProvider(
                                                                    context,
                                                                  ).isDateSet ||
                                                                  returnExpensesProvider(
                                                                    context,
                                                                  ).setDate
                                                              ? Icons.clear
                                                              : Icons.date_range_outlined,
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
                                          builder: (
                                            context,
                                          ) {
                                            if (expenses
                                                .isEmpty) {
                                              return EmptyWidgetDisplay(
                                                title:
                                                    'Empty List',
                                                subText:
                                                    'You don\'t have any Expenses under this Date',
                                                buttonText:
                                                    'Create Expenses',
                                                theme:
                                                    theme,
                                                svg:
                                                    expensesIconSvg,
                                                height: 35,
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
                                                  );
                                                },
                                              );
                                            } else {
                                              return ListView.builder(
                                                itemCount:
                                                    expenses
                                                        .length,
                                                itemBuilder: (
                                                  context,
                                                  index,
                                                ) {
                                                  var expense =
                                                      expenses[index];
                                                  return ExpensesTile(
                                                    expense:
                                                        expense,
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
                              ),
                              if (returnExpensesProvider(
                                context,
                              ).setDate)
                                Material(
                                  color:
                                      const Color.fromARGB(
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
                                              horizontal:
                                                  10.0,
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
                                                  ).size.height *
                                                  0.05,
                                            ),
                                            Ink(
                                              color:
                                                  Colors
                                                      .white,
                                              child: Container(
                                                padding:
                                                    EdgeInsets.only(
                                                      top:
                                                          20,
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
                        },
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
              ).showLoader('Logging Out...'),
            ),
          ],
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
                        currencySymbol(context: context),
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
