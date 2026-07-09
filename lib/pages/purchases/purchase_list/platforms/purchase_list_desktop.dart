import 'package:flutter/material.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/buttons/floating_action_butto.dart';
import 'package:stockall/components/list_tiles/main_purchase_tile.dart';
import 'package:stockall/components/major/desktop_page_container.dart';
import 'package:stockall/components/major/drawer_widget/my_drawer_widget.dart';
import 'package:stockall/components/major/drawer_widget/platforms/my_drawer_widget_desktop.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/components/major/right_side_bar.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/date_picker_function.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/purchases/create_purchase/create_purchase.dart';
import 'package:stockall/pages/purchases/purchase_page/purchase_page.dart';
import 'package:stockall/services/auth_service.dart';

class PurchaseListDesktop extends StatefulWidget {
  final String? id;
  final String? supplierUuid;
  const PurchaseListDesktop({
    super.key,
    this.id,
    this.supplierUuid,
  });

  @override
  State<PurchaseListDesktop> createState() =>
      _PurchaseListDesktopState();
}

class _PurchaseListDesktopState
    extends State<PurchaseListDesktop> {
  Future<void> getPurchases() async {
    await returnPurchaseProvider().loadPurchases(shopId());
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      clearDate();
    });
  }

  bool isLoading = false;

  int paidPurchaseIndex = 1;

  void switchPurchasePaymentIndex(int index) {
    setState(() {
      paidPurchaseIndex = index;
    });
  }

  void clearDate() {
    returnPurchaseProvider().clearDate();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Scaffold(
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
                    var res = await AuthService().signOut(
                      context: safeContext,
                      allowLogout: false,
                    );
                    if (res == 0 && safeContext.mounted) {
                      setState(() {
                        isLoading = false;
                      });
                    }
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
                ).notifications().isEmpty
                ? []
                : returnNotificationProvider(
                  context,
                ).notifications(),
        globalKey: _scaffoldKey,
      ),
      key: _scaffoldKey,
      body: Stack(
        children: [
          Row(
            spacing: 15,
            children: [
              Builder(
                builder: (context) {
                  if (widget.id != null ||
                      widget.supplierUuid != null) {
                    return Container(
                      width:
                          screenWidth(context) <
                                  tabletScreenSmall
                              ? 50
                              : (screenWidth(context) >
                                      tabletScreenSmall &&
                                  screenWidth(context) <
                                      tabletScreen + 100)
                              ? 100
                              : 230,
                    );
                  } else {
                    return MyDrawerWidget(
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
                                  var res =
                                      await AuthService()
                                          .signOut(
                                            context:
                                                safeContext,
                                            allowLogout:
                                                false,
                                          );
                                  if (res == 0 &&
                                      safeContext.mounted) {
                                    setState(() {
                                      isLoading = false;
                                    });
                                  }
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
                              ).notifications().isEmpty
                              ? []
                              : returnNotificationProvider(
                                context,
                              ).notifications(),
                    );
                  }
                },
              ),
              Expanded(
                child: DesktopPageContainer(
                  widget: Scaffold(
                    appBar: appBar(
                      context: context,
                      title: 'All Purchases',
                      widget: Row(
                        spacing: 15,
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment:
                            MainAxisAlignment.end,
                        children: [
                          Visibility(
                            visible:
                                screenWidth(context) >
                                mobileScreen,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius:
                                    BorderRadius.circular(
                                      10,
                                    ),
                                onTap: () async {
                                  getPurchases();
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
                                              FontWeight
                                                  .bold,
                                        ),
                                        'Refresh',
                                      ),
                                      Icon(
                                        size: 18,
                                        Icons
                                            .refresh_rounded,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              right: 15.0,
                            ),
                            child: PopupMenuButton(
                              offset: Offset(-20, 30),
                              color: Colors.white,
                              itemBuilder: (context) {
                                return [
                                  PopupMenuItem(
                                    onTap: () {
                                      switchPurchasePaymentIndex(
                                        1,
                                      );
                                    },
                                    child: Text(
                                      style: TextStyle(
                                        fontSize:
                                            theme
                                                .mobileTexts
                                                .b2
                                                .fontSize,
                                        fontWeight:
                                            paidPurchaseIndex ==
                                                    1
                                                ? FontWeight
                                                    .bold
                                                : null,
                                      ),
                                      'All',
                                    ),
                                  ),
                                  PopupMenuItem(
                                    onTap: () {
                                      switchPurchasePaymentIndex(
                                        2,
                                      );
                                      returnData()
                                          .toggleFloatingAction(
                                            context,
                                          );
                                    },
                                    child: Text(
                                      style: TextStyle(
                                        fontSize:
                                            theme
                                                .mobileTexts
                                                .b2
                                                .fontSize,
                                        fontWeight:
                                            paidPurchaseIndex ==
                                                    2
                                                ? FontWeight
                                                    .bold
                                                : null,
                                      ),
                                      'Fully Paid',
                                    ),
                                  ),
                                  PopupMenuItem(
                                    onTap: () {
                                      switchPurchasePaymentIndex(
                                        3,
                                      );
                                      returnData()
                                          .toggleFloatingAction(
                                            context,
                                          );
                                    },
                                    child: Text(
                                      style: TextStyle(
                                        fontSize:
                                            theme
                                                .mobileTexts
                                                .b2
                                                .fontSize,
                                        fontWeight:
                                            paidPurchaseIndex ==
                                                    4
                                                ? FontWeight
                                                    .bold
                                                : null,
                                      ),
                                      'UnPaid',
                                    ),
                                  ),
                                ];
                              },
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .center,
                                mainAxisSize:
                                    MainAxisSize.min,
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
                                    paidPurchaseIndex == 1
                                        ? 'All'
                                        : paidPurchaseIndex ==
                                            2
                                        ? 'Fully Paid'
                                        : 'UnPaid',
                                  ),
                                  Icon(
                                    Icons.more_vert_rounded,
                                  ),
                                ],
                              ),
                            ),
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
                                  return CreatePurchase();
                                },
                              ),
                            ).then((_) {
                              getPurchases();
                            });
                            //       },
                            //     );
                          },
                          color:
                              theme
                                  .lightModeColor
                                  .secColor100,
                          text: 'Create Purchase',
                          theme: theme,
                        ),
                    body: Padding(
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
                                      title: 'Total Amount',
                                      value: returnPurchaseProvider(
                                        context: context,
                                      ).getTotalRevenueForSelectedDayAll(
                                        supplierUuid:
                                            widget
                                                .supplierUuid,
                                        staffId: widget.id,
                                        index:
                                            paidPurchaseIndex,
                                      ),
                                    ),
                                    ValueSummaryTabSmall(
                                      value:
                                          widget.id != null
                                              ? returnPurchaseProvider(
                                                    context:
                                                        context,
                                                  )
                                                  .returnOwnPurchasesByDayOrWeek(
                                                    index:
                                                        paidPurchaseIndex,
                                                  )
                                                  .where(
                                                    (
                                                      purchase,
                                                    ) =>
                                                        purchase.staffId ==
                                                        widget.id,
                                                  )
                                                  .toList()
                                                  .length
                                                  .toDouble()
                                              : widget.supplierUuid !=
                                                  null
                                              ? returnPurchaseProvider(
                                                    context:
                                                        context,
                                                  )
                                                  .returnOwnPurchasesByDayOrWeek(
                                                    index:
                                                        paidPurchaseIndex,
                                                  )
                                                  .where(
                                                    (
                                                      purchase,
                                                    ) =>
                                                        purchase.supplierId ==
                                                        widget.supplierUuid,
                                                  )
                                                  .toList()
                                                  .length
                                                  .toDouble()
                                              : returnPurchaseProvider(
                                                    context:
                                                        context,
                                                  )
                                                  .returnOwnPurchasesByDayOrWeek(
                                                    index:
                                                        paidPurchaseIndex,
                                                  )
                                                  .toList()
                                                  .length
                                                  .toDouble(),
                                      title:
                                          'Purchase Number',
                                      color: Colors.green,
                                      isMoney: false,
                                    ),
                                  ],
                                ),
                                // SizedBox(height: 20),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(
                                        vertical: 10.0,
                                      ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .spaceBetween,
                                    children: [
                                      Visibility(
                                        visible: authorization(
                                          authorized:
                                              Authorizations()
                                                  .viewDate,
                                        ),
                                        child: Text(
                                          style: TextStyle(
                                            fontSize:
                                                theme
                                                    .mobileTexts
                                                    .b1
                                                    .fontSize,
                                          ),
                                          returnPurchaseProvider(
                                                        context:
                                                            context,
                                                      ).dateSet !=
                                                      null ||
                                                  returnPurchaseProvider(
                                                        context:
                                                            context,
                                                      ).rangeStartDate !=
                                                      null
                                              ? 'All Purchases'
                                              : 'For Today',
                                        ),
                                      ),
                                      Visibility(
                                        visible: authorization(
                                          authorized:
                                              Authorizations()
                                                  .viewDate,
                                        ),
                                        child: MaterialButton(
                                          onPressed: () {
                                            if (returnPurchaseProvider()
                                                        .dateSet !=
                                                    null ||
                                                returnPurchaseProvider()
                                                        .rangeStartDate !=
                                                    null) {
                                              returnPurchaseProvider()
                                                  .clearDate();
                                            } else {
                                              mainDatePicker(
                                                context:
                                                    context,
                                                theme:
                                                    theme,
                                                singleDate: (
                                                  date,
                                                ) {
                                                  returnPurchaseProvider()
                                                      .setDate(
                                                        date!,
                                                      );
                                                },
                                                rangeDate: (
                                                  firstDate,
                                                  lastDate,
                                                ) {
                                                  returnPurchaseProvider().setRange(
                                                    firstDate!,
                                                    lastDate ??
                                                        DateTime.now(),
                                                  );
                                                },
                                              );
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
                                                returnPurchaseProvider(
                                                              context:
                                                                  context,
                                                            ).dateSet !=
                                                            null ||
                                                        returnPurchaseProvider(
                                                              context:
                                                                  context,
                                                            ).rangeStartDate !=
                                                            null
                                                    ? 'Clear'
                                                    : 'Set Date',
                                              ),
                                              Icon(
                                                size: 20,
                                                color:
                                                    theme
                                                        .lightModeColor
                                                        .secColor100,
                                                returnPurchaseProvider(
                                                              context:
                                                                  context,
                                                            ).dateSet !=
                                                            null ||
                                                        returnPurchaseProvider(
                                                              context:
                                                                  context,
                                                            ).rangeStartDate !=
                                                            null
                                                    ? Icons
                                                        .clear
                                                    : Icons.date_range_outlined,
                                              ),
                                            ],
                                          ),
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
                                if (widget.id != null
                                    ? returnPurchaseProvider(
                                          context: context,
                                        )
                                        .returnOwnPurchasesByDayOrWeek(
                                          index:
                                              paidPurchaseIndex,
                                        )
                                        .toList()
                                        .where(
                                          (rec) =>
                                              rec.staffId ==
                                              widget.id,
                                        )
                                        .toList()
                                        .isEmpty
                                    : widget.supplierUuid !=
                                        null
                                    ? returnPurchaseProvider(
                                          context: context,
                                        )
                                        .returnOwnPurchasesByDayOrWeek(
                                          index:
                                              paidPurchaseIndex,
                                        )
                                        .where(
                                          (rec) =>
                                              rec.supplierId ==
                                              widget
                                                  .supplierUuid,
                                        )
                                        .toList()
                                        .isEmpty
                                    : returnPurchaseProvider(
                                          context: context,
                                        )
                                        .returnOwnPurchasesByDayOrWeek(
                                          index:
                                              paidPurchaseIndex,
                                        )
                                        .toList()
                                        .isEmpty) {
                                  return EmptyWidgetDisplayOnly(
                                    title: 'Empty List',
                                    subText:
                                        'You don\'t have any Purchase under this category',
                                    icon: Icons.clear,
                                    theme: theme,
                                    height: 35,
                                    altAction: () {
                                      getPurchases();
                                    },
                                    altActionText:
                                        'Refresh List',
                                  );
                                } else {
                                  return RefreshIndicator(
                                    onRefresh: getPurchases,
                                    backgroundColor:
                                        Colors.white,
                                    color:
                                        theme
                                            .lightModeColor
                                            .prColor300,
                                    displacement: 10,
                                    child: ListView.builder(
                                      itemCount:
                                          widget.id != null
                                              ? returnPurchaseProvider(
                                                    context:
                                                        context,
                                                  )
                                                  .returnOwnPurchasesByDayOrWeek(
                                                    index:
                                                        paidPurchaseIndex,
                                                  )
                                                  .where(
                                                    (rec) =>
                                                        rec.staffId ==
                                                        widget.id,
                                                  )
                                                  .toList()
                                                  .length
                                              : widget.supplierUuid !=
                                                  null
                                              ? returnPurchaseProvider(
                                                    context:
                                                        context,
                                                  )
                                                  .returnOwnPurchasesByDayOrWeek(
                                                    index:
                                                        paidPurchaseIndex,
                                                  )
                                                  .where(
                                                    (rec) =>
                                                        rec.supplierId ==
                                                        widget.supplierUuid,
                                                  )
                                                  .toList()
                                                  .length
                                              : returnPurchaseProvider(
                                                    context:
                                                        context,
                                                  )
                                                  .returnOwnPurchasesByDayOrWeek(
                                                    index:
                                                        paidPurchaseIndex,
                                                  )
                                                  .toList()
                                                  .length,
                                      itemBuilder: (
                                        context,
                                        index,
                                      ) {
                                        var purchase =
                                            widget.id !=
                                                    null
                                                ? returnPurchaseProvider(
                                                      context:
                                                          context,
                                                    )
                                                    .returnOwnPurchasesByDayOrWeek(
                                                      index:
                                                          paidPurchaseIndex,
                                                    )
                                                    .where(
                                                      (
                                                        rec,
                                                      ) =>
                                                          rec.staffId ==
                                                          widget.id,
                                                    )
                                                    .toList()[index]
                                                : widget.supplierUuid !=
                                                    null
                                                ? returnPurchaseProvider(
                                                      context:
                                                          context,
                                                    )
                                                    .returnOwnPurchasesByDayOrWeek(
                                                      index:
                                                          paidPurchaseIndex,
                                                    )
                                                    .where(
                                                      (
                                                        rec,
                                                      ) =>
                                                          rec.supplierId ==
                                                          widget.supplierUuid,
                                                    )
                                                    .toList()[index]
                                                : returnPurchaseProvider(
                                                      context:
                                                          context,
                                                    )
                                                    .returnOwnPurchasesByDayOrWeek(
                                                      index:
                                                          paidPurchaseIndex,
                                                    )
                                                    .toList()[index];
                                        return MainPurchaseTile(
                                          action: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (
                                                  context,
                                                ) {
                                                  return PurchasePage(
                                                    purchaseUuid:
                                                        purchase.uuid!,
                                                  );
                                                },
                                              ),
                                            ).then((_) {
                                              getPurchases();
                                            });
                                          },
                                          key: ValueKey(
                                            purchase.uuid,
                                          ),
                                          purchase:
                                              purchase,
                                        );
                                      },
                                    ),
                                  );
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Builder(
                builder: (context) {
                  if (widget.id != null ||
                      widget.supplierUuid != null) {
                    return Container(
                      width:
                          screenWidth(context) <
                                  tabletScreenSmall
                              ? 50
                              : (screenWidth(context) >
                                      tabletScreenSmall &&
                                  screenWidth(context) <
                                      tabletScreen + 100)
                              ? 100
                              : 230,
                    );
                  } else {
                    return RightSideBar(theme: theme);
                  }
                },
              ),
            ],
          ),
          Visibility(
            visible: isLoading,
            child: returnCompProvider(
              context,
            ).showLoader(message: 'Logging Out...'),
          ),
        ],
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
                      visible: false,
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
                      isMoney
                          ? formatMoneyMid(
                            amount: value,
                            context: context,
                          )
                          : formatLargeNumberDoubleWidgetDecimal(
                            value,
                          ),
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
