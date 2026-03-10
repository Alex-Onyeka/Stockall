import 'package:flutter/material.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/buttons/floating_action_butto.dart';
import 'package:stockall/components/major/desktop_page_container.dart';
import 'package:stockall/components/major/drawer_widget/platforms/my_drawer_widget_desktop.dart';
import 'package:stockall/components/major/empty_widget_display.dart';
import 'package:stockall/components/major/drawer_widget/my_drawer_widget.dart';
import 'package:stockall/components/major/right_side_bar.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/date_picker_function.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/refresh_functions.dart';
import 'package:stockall/constants/subscription/expenses_auth.dart';
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
      returnData().toggleFloatingAction(context);
    });
  }

  void clearDate() {
    returnExpensesProvider(
      context,
      listen: false,
    ).clearDate();
  }

  bool isLoading = false;
  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();

  Future<void> getExpenses() async {
    await RefreshFunctions(
      context,
    ).refreshExpenses(context);
  }

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
        ).clearDate();
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
                      appBar: appBar(
                        context: context,
                        title: 'All Expenses',
                        widget: Visibility(
                          visible:
                              screenWidth(context) >
                              mobileScreen,
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius:
                                  BorderRadius.circular(10),
                              onTap: () async {
                                await getExpenses();
                              },
                              child: Padding(
                                padding:
                                    const EdgeInsets.all(
                                      10,
                                    ),
                                child: Row(
                                  spacing: 5,
                                  children: [
                                    Text(
                                      style: TextStyle(
                                        fontSize:
                                            theme
                                                .mobileTexts
                                                .b3
                                                .fontSize,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                      'Refresh',
                                    ),
                                    Icon(
                                      size: 18,
                                      Icons.refresh_rounded,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      floatingActionButton:
                          FloatingActionButtonMain(
                            action: () {
                              ExpensesAuthAction()
                                  .numberOfDailyExpensesAction(
                                    context: context,
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
                                        setState(() {});
                                      });
                                    },
                                  );
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

                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(
                                  horizontal: 20.0,
                                ),
                            child: RefreshIndicator(
                              onRefresh: () {
                                return returnExpensesProvider(
                                  context,
                                  listen: false,
                                ).getExpenses(shopId());
                              },
                              backgroundColor: Colors.white,
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
                                              isMoney: true,
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
                                          ),
                                          child: SizedBox(
                                            height: 30,
                                          ),
                                        ),
                                        Visibility(
                                          visible: authorization(
                                            authorized:
                                                Authorizations()
                                                    .viewDate,
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
                                                          ).dateSet !=
                                                          null ||
                                                      returnExpensesProvider(
                                                            context,
                                                            listen:
                                                                false,
                                                          ).rangeStartDate !=
                                                          null) {
                                                    returnExpensesProvider(
                                                      context,
                                                      listen:
                                                          false,
                                                    ).clearDate();
                                                  } else {
                                                    mainDatePicker(
                                                      context:
                                                          context,
                                                      theme:
                                                          theme,
                                                      singleDate: (
                                                        date,
                                                      ) {
                                                        returnExpensesProvider(
                                                          context,
                                                          listen:
                                                              false,
                                                        ).setDate(
                                                          date!,
                                                        );
                                                      },
                                                      rangeDate: (
                                                        firstDate,
                                                        lastDate,
                                                      ) {
                                                        returnExpensesProvider(
                                                          context,
                                                          listen:
                                                              false,
                                                        ).setRange(
                                                          firstDate!,
                                                          lastDate ??
                                                              DateTime.now(),
                                                        );
                                                      },
                                                    );
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
                                                                  ).dateSet !=
                                                                  null ||
                                                              returnExpensesProvider(
                                                                    context,
                                                                  ).rangeStartDate !=
                                                                  null
                                                          ? 'Clear'
                                                          : 'Set Date',
                                                    ),
                                                    Icon(
                                                      size:
                                                          20,
                                                      color:
                                                          theme.lightModeColor.secColor100,
                                                      returnExpensesProvider(
                                                                    context,
                                                                  ).dateSet !=
                                                                  null ||
                                                              returnExpensesProvider(
                                                                    context,
                                                                  ).rangeStartDate !=
                                                                  null
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
                                      builder: (context) {
                                        if (expenses
                                            .isEmpty) {
                                          return EmptyWidgetDisplay(
                                            title:
                                                'Empty List',
                                            subText:
                                                'You don\'t have any Expenses under this Date',
                                            buttonText:
                                                'Create Expenses',
                                            theme: theme,
                                            altAction:
                                                () async {
                                                  await getExpenses();
                                                  setState(
                                                    () {},
                                                  );
                                                },
                                            altActionText:
                                                'Refresh Expenses',
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
                                                  ).then((
                                                    _,
                                                  ) {
                                                    setState(
                                                      () {},
                                                    );
                                                  });
                                                },
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
                                                          expenseUuid:
                                                              expense.uuid!,
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
              ).showLoader(message: 'Logging Out...'),
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
