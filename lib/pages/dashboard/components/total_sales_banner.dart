import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:stockall/classes/temp_expenses/temp_expenses_class.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/refresh_functions.dart';
import 'package:stockall/constants/subscription/general_settings_auth.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/theme_provider.dart';

class DashboardTotalSalesBanner extends StatefulWidget {
  final double? value;
  // final TempUserClass? currentUser;
  final double? userValue;
  const DashboardTotalSalesBanner({
    super.key,
    required this.theme,
    required this.value,
    // this.currentUser,
    this.userValue,
  });

  final ThemeProvider theme;

  @override
  State<DashboardTotalSalesBanner> createState() =>
      _DashboardTotalSalesBannerState();
}

class _DashboardTotalSalesBannerState
    extends State<DashboardTotalSalesBanner> {
  String setName() {
    if (returnDepartmentProvider().currentDepartment() !=
        null) {
      return cutLongText(
        returnDepartmentProvider()
            .currentDepartment()!
            .name,
        22,
      );
    } else {
      return 'Department Not Set';
    }
  }

  String setNameUser() {
    if (returnUserProvider(context).currentUserMain !=
        null) {
      return '${cutLongText(returnUserProvider(context).currentUserMain!.name.toUpperCase(), 15)} (${returnUserProvider(context).currentUserMain!.role})';
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
    var visible = returnCompProvider(context);
    var toggleVisible = returnCompProvider(
      context,
      listen: false,
    );
    return Stack(
      alignment: Alignment(0.9, 0.0),
      children: [
        Container(
          padding: EdgeInsets.only(
            left: 15,
            top: 10,
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
                  Ink(
                    child: InkWell(
                      onTap: () {
                        toggleVisible.toggleVisible();
                      },
                      child: SizedBox(
                        child: Row(
                          children: [
                            Text(
                              style: TextStyle(
                                fontSize:
                                    widget
                                        .theme
                                        .mobileTexts
                                        .b2
                                        .fontSize,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                              'Today\'s Sale Revenue',
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: Center(
                                child: Icon(
                                  size: 18,
                                  color:
                                      Colors.grey.shade300,
                                  visible.isVisible
                                      ? Icons
                                          .visibility_outlined
                                      : Icons
                                          .visibility_off_outlined,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      toggleVisible.toggleVisible();
                    },
                    child: Row(
                      children: [
                        Visibility(
                          visible: !visible.isVisible,
                          child: Text(
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
                            currencySymbol(
                              context: context,
                            ),
                          ),
                        ),
                        Visibility(
                          visible: !visible.isVisible,
                          child: SizedBox(width: 5),
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
                          returnCompProvider(
                            context,
                          ).returnMoney(
                            formatMoneyMid(
                              amount:
                                  widget.value != null
                                      ? widget.value!
                                      : 0,
                              context: context,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 0),
                  Builder(
                    builder: (context) {
                      // var expenses = widget.expenses;
                      List<TempExpensesClass>
                      getTodaysExpenses() {
                        return returnExpensesProvider(
                          context,
                          listen: false,
                        ).returnExpensesByDayOrWeek(
                          context,
                          // expenses ?? [],
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
                        expenses: visible.returnMoney(
                          formatMoneyMid(
                            amount: getTotal(),
                            context: context,
                          ),
                        ),
                        profit: visible.returnMoney(
                          formatMoneyMid(
                            amount: getProfit(),
                            context: context,
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 2),
                  Builder(
                    builder: (context) {
                      if (returnShopProvider(
                            context: context,
                          ).userShop()?.manageDepartments ==
                          true) {
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius:
                                BorderRadius.circular(5),
                            onTap: () {
                              GeneralSettingsAuthAction().manageDeparmtmentsAction(
                                context: context,
                                action: () {
                                  String? selectedDept;
                                  setState(() {
                                    selectedDept =
                                        returnDepartmentProvider()
                                            .currentDepartment()
                                            ?.uuid;
                                  });
                                  showDialog(
                                    context: context,
                                    builder: (
                                      firstContext,
                                    ) {
                                      return StatefulBuilder(
                                        builder: (
                                          secondContext,
                                          setState,
                                        ) {
                                          return DialogTemplate(
                                            theme:
                                                widget
                                                    .theme,
                                            message:
                                                'Select Your Current Department',
                                            title:
                                                'Select Department',
                                            action: () {
                                              returnDepartmentProvider().selectDepartment(
                                                departmentClass:
                                                    returnDepartmentProvider().departments
                                                            .where(
                                                              (
                                                                dept,
                                                              ) =>
                                                                  dept.uuid ==
                                                                  selectedDept,
                                                            )
                                                            .isEmpty
                                                        ? null
                                                        : returnDepartmentProvider().departments
                                                            .where(
                                                              (
                                                                dept,
                                                              ) =>
                                                                  dept.uuid ==
                                                                  selectedDept,
                                                            )
                                                            .first,
                                              );
                                              Navigator.of(
                                                context,
                                              ).pop();
                                            },
                                            widget: SizedBox(
                                              height:
                                                  screenHeight(
                                                    context,
                                                  ) -
                                                  300,
                                              child: SingleChildScrollView(
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(
                                                    horizontal:
                                                        20.0,
                                                    vertical:
                                                        15,
                                                  ),
                                                  child: Builder(
                                                    builder: (
                                                      context,
                                                    ) {
                                                      if (returnDepartmentProvider()
                                                          .departments
                                                          .isEmpty) {
                                                        return SizedBox(
                                                          height:
                                                              400,
                                                          child: EmptyWidgetDisplayOnly(
                                                            title:
                                                                'No Department Found',
                                                            subText:
                                                                'You have not been added to any departments.',
                                                            theme:
                                                                widget.theme,
                                                            height:
                                                                30,
                                                            altAction: () {
                                                              returnDepartmentProvider().getDepartments();
                                                            },
                                                            altActionText:
                                                                'Refresh',
                                                            icon:
                                                                Icons.clear,
                                                          ),
                                                        );
                                                      } else {
                                                        return Column(
                                                          spacing:
                                                              5,
                                                          children:
                                                              returnDepartmentProvider().departments
                                                                  .map(
                                                                    (
                                                                      dept,
                                                                    ) => Material(
                                                                      color:
                                                                          Colors.transparent,
                                                                      child: InkWell(
                                                                        onTap: () {
                                                                          setState(
                                                                            () {
                                                                              if (selectedDept ==
                                                                                  dept.uuid) {
                                                                                selectedDept =
                                                                                    null;
                                                                              } else {
                                                                                selectedDept =
                                                                                    dept.uuid;
                                                                              }
                                                                            },
                                                                          );
                                                                        },
                                                                        child: Padding(
                                                                          padding: const EdgeInsets.symmetric(
                                                                            vertical:
                                                                                9.0,
                                                                            horizontal:
                                                                                12,
                                                                          ),
                                                                          child: Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceBetween,
                                                                            children: [
                                                                              Text(
                                                                                style: TextStyle(
                                                                                  fontSize:
                                                                                      widget.theme.mobileTexts.b3.fontSize,
                                                                                  fontWeight:
                                                                                      FontWeight.bold,
                                                                                ),
                                                                                dept.name,
                                                                              ),
                                                                              Container(
                                                                                padding: EdgeInsets.all(
                                                                                  2,
                                                                                ),
                                                                                decoration: BoxDecoration(
                                                                                  shape:
                                                                                      BoxShape.circle,
                                                                                  border: Border.all(
                                                                                    color:
                                                                                        Colors.grey,
                                                                                  ),
                                                                                ),
                                                                                child: Container(
                                                                                  padding: EdgeInsets.all(
                                                                                    5,
                                                                                  ),
                                                                                  decoration: BoxDecoration(
                                                                                    shape:
                                                                                        BoxShape.circle,
                                                                                    color:
                                                                                        selectedDept ==
                                                                                                dept.uuid
                                                                                            ? widget.theme.lightModeColor.prColor250
                                                                                            : Colors.transparent,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  )
                                                                  .toList(),
                                                        );
                                                      }
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  );
                                },
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(
                                4.0,
                              ),
                              child: Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .center,
                                children: [
                                  Icon(
                                    size: 14,
                                    color:
                                        const Color.fromARGB(
                                          255,
                                          255,
                                          208,
                                          67,
                                        ),
                                    Icons
                                        .width_normal_outlined,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    style: TextStyle(
                                      fontWeight:
                                          FontWeight.bold,
                                      color:
                                          const Color.fromARGB(
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
                                  Icon(
                                    color:
                                        const Color.fromARGB(
                                          255,
                                          255,
                                          208,
                                          67,
                                        ),
                                    Icons
                                        .keyboard_arrow_down_rounded,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      } else {
                        return Row(
                          spacing: 5,
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  style: TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
                                    color:
                                        const Color.fromARGB(
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

                                  setNameUser(),
                                ),
                                // Text(
                                //   style: TextStyle(
                                //     fontWeight:
                                //         FontWeight.bold,
                                //     color:
                                //         const Color.fromARGB(
                                //           241,
                                //           255,
                                //           255,
                                //           255,
                                //         ),
                                //     fontSize:
                                //         widget
                                //             .theme
                                //             .mobileTexts
                                //             .b3
                                //             .fontSize,
                                //   ),

                                //   visible.returnMoney(
                                //     formatMoneyMid(
                                //       amount:
                                //           widget
                                //               .userValue ??
                                //           0,
                                //       context: context,
                                //     ),
                                //   ),
                                // ),
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
                        );
                      }
                    },
                  ),
                  SizedBox(height: 3),
                ],
              ),
            ],
          ),
        ),
        Visibility(
          visible: screenWidth(context) <= mobileScreen,
          child: Positioned(
            top: 7,
            right: 20,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(5),
                onTap: () async {
                  if (returnData().isSynced() == 0) {
                    await returnData().syncData(context);
                  } else {
                    print('Data is in sync');
                    returnData().toggleRefreshing(true);
                    await RefreshFunctions(
                      context,
                    ).refreshAll(context);
                    if (context.mounted) {
                      returnData().toggleRefreshing(false);
                    }
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 2,
                    horizontal: 5,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: const Color.fromARGB(
                      33,
                      255,
                      255,
                      255,
                    ),
                  ),
                  child: Row(
                    spacing: 10,
                    children: [
                      Icon(
                        size: 13,
                        color:
                            returnConnectivityProvider(
                              context,
                            ).connectedColor(),
                        returnConnectivityProvider(
                              context,
                            ).isConnected
                            ? Icons.wifi
                            : Icons.wifi_off_sharp,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          2,
                          2,
                          2,
                          2,
                        ),
                        child: Stack(
                          children: [
                            Visibility(
                              visible:
                                  !returnData(
                                    context: context,
                                  ).isRefreshing,
                              child: Row(
                                // spacing: 5,
                                children: [
                                  Stack(
                                    children: [
                                      Visibility(
                                        visible:
                                            returnData(
                                              context:
                                                  context,
                                            ).isSynced() !=
                                            2,
                                        child: Icon(
                                          color:
                                              returnData(
                                                        context:
                                                            context,
                                                      ).isSynced() ==
                                                      1
                                                  ? const Color.fromARGB(
                                                    255,
                                                    87,
                                                    160,
                                                    89,
                                                  )
                                                  : Colors
                                                      .grey,
                                          size: 14,
                                          returnData(
                                                    context:
                                                        context,
                                                  ).isSynced() ==
                                                  1
                                              ? Icons
                                                  .cloud_done_outlined
                                              : Icons
                                                  .cloud_off_rounded,
                                        ),
                                      ),
                                      Visibility(
                                        visible:
                                            returnData(
                                              context:
                                                  context,
                                            ).isSynced() ==
                                            2,
                                        child: Row(
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  style: TextStyle(
                                                    color:
                                                        Colors.white,
                                                    fontSize:
                                                        8,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                  ),

                                                  'Syncing',
                                                ),
                                                SizedBox(
                                                  width: 5,
                                                ),
                                              ],
                                            ),
                                            Stack(
                                              alignment:
                                                  Alignment(
                                                    0,
                                                    0,
                                                  ),
                                              children: [
                                                SizedBox(
                                                  height:
                                                      15,
                                                  width: 15,
                                                  child: CircularProgressIndicator(
                                                    color:
                                                        Colors.amber,
                                                    strokeWidth:
                                                        1.2,
                                                  ),
                                                ),
                                                Center(
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        style: TextStyle(
                                                          color:
                                                              Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize:
                                                              6,
                                                        ),
                                                        returnData(
                                                          context:
                                                              context,
                                                        ).syncProgress.toStringAsFixed(
                                                          0,
                                                        ),
                                                        // '100',
                                                      ),
                                                      Text(
                                                        style: TextStyle(
                                                          color:
                                                              Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize:
                                                              5,
                                                        ),
                                                        '%',
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Visibility(
                              visible:
                                  returnData(
                                    context: context,
                                  ).isRefreshing,
                              child: SizedBox(
                                height: 13,
                                width: 13,
                                child:
                                    CircularProgressIndicator(
                                      color: Colors.amber,
                                      strokeWidth: 1.5,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
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
    required this.profit,
    required this.expenses,
  });

  final DashboardTotalSalesBanner widget;
  final String expenses;
  final String profit;

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

              expenses,
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

              profit,
            ),
          ],
        ),
      ],
    );
  }
}
