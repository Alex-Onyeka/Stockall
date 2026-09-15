import 'package:flutter/material.dart';
import 'package:stockall/classes/checkout_response.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/buttons/floating_action_butto.dart';
import 'package:stockall/components/list_tiles/main_order_tile.dart';
import 'package:stockall/components/major/desktop_page_container.dart';
import 'package:stockall/components/major/drawer_widget/platforms/my_drawer_widget_desktop.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/components/major/drawer_widget/my_drawer_widget.dart';
import 'package:stockall/components/major/right_side_bar.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/date_picker_function.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/subscription/sales_auth.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/orders/search_order/search_order_page.dart';
import 'package:stockall/pages/products/compnents/product_filter_button.dart';
import 'package:stockall/pages/sales/make_sales/page1/make_sales_page.dart';
import 'package:stockall/pages/sales/make_sales/receipt_page/receipt_page.dart';
import 'package:stockall/services/auth_service.dart';

class OrderListDesktop extends StatefulWidget {
  final String? agentUuid;
  final String? customerUuid;
  const OrderListDesktop({
    super.key,
    this.agentUuid,
    this.customerUuid,
  });

  @override
  State<OrderListDesktop> createState() =>
      _OrderListDesktopState();
}

class _OrderListDesktopState
    extends State<OrderListDesktop> {
  Future<void> getOrders() async {
    await returnOrdersProvider().loadOrders(shopId());
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      clearDate();
      returnData().toggleFloatingAction(context);
    });
  }

  bool isLoading = false;

  void clearDate() {
    returnOrdersProvider().clearDate();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
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
      body: Stack(
        children: [
          Row(
            spacing: 15,
            children: [
              Visibility(
                visible:
                    widget.agentUuid == null &&
                    widget.customerUuid == null,
                child: MyDrawerWidget(
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
                              var res = await AuthService()
                                  .signOut(
                                    context: safeContext,
                                    allowLogout: false,
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
                ),
              ),
              Expanded(
                child: DesktopPageContainer(
                  widget: Scaffold(
                    appBar: appBar(
                      turnOff: true,
                      context: context,
                      title: 'All Orders',
                      widget: Row(
                        spacing: 15,
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment:
                            MainAxisAlignment.end,
                        children: [
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              mouseCursor:
                                  SystemMouseCursors.click,
                              borderRadius:
                                  BorderRadius.circular(5),
                              onTap: () {
                                showSearchOrderPage(
                                  context,
                                );
                              },
                              child: Padding(
                                padding:
                                    EdgeInsetsGeometry.all(
                                      6.5,
                                    ),
                                child: Row(
                                  mainAxisSize:
                                      MainAxisSize.min,
                                  children: [
                                    Row(
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
                                                FontWeight
                                                    .bold,
                                            color:
                                                Colors
                                                    .grey
                                                    .shade700,
                                          ),
                                          'Search${screenWidth(context) <= mobileScreen ? '' : ' Order'}',
                                        ),
                                        SizedBox(width: 3),
                                      ],
                                    ),
                                    Icon(
                                      size: 20,
                                      // color:
                                      //     theme
                                      //         .lightModeColor
                                      //         .secColor100,
                                      Icons
                                          .manage_search_rounded,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Visibility(
                            visible:
                                screenWidth(context) >
                                mobileScreen,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                mouseCursor:
                                    SystemMouseCursors
                                        .click,
                                borderRadius:
                                    BorderRadius.circular(
                                      10,
                                    ),
                                onTap: () async {
                                  getOrders();
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
                        ],
                      ),
                    ),
                    floatingActionButton: FloatingActionButtonMain(
                      action: () {
                        SalesAuthAction().manageOrdersAction(
                          context: context,
                          action: () {
                            if (authorization(
                              authorized:
                                  Authorizations().makeSale,
                            )) {
                              returnNavProvider(
                                context,
                                listen: false,
                              ).navigate(2);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return MakeSalesPage(
                                      cartItemTypeIndex: 3,
                                    );
                                  },
                                ),
                              ).then((_) {
                                setState(() {
                                  // getProductList(context);
                                });
                              });
                            }
                          },
                        );
                      },
                      color:
                          theme.lightModeColor.secColor100,
                      text: 'Create Order',
                      theme: theme,
                    ),
                    body: OrderListBodyDesktop(
                      agentUuid: widget.agentUuid,
                      customerUuid: widget.customerUuid,
                    ),
                  ),
                ),
              ),
              Visibility(
                visible:
                    widget.agentUuid == null &&
                    widget.customerUuid == null,
                child: RightSideBar(theme: theme),
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

class OrderListBodyDesktop extends StatefulWidget {
  final String? customerUuid;
  final String? agentUuid;
  final String? subStaffId;
  const OrderListBodyDesktop({
    super.key,
    this.customerUuid,
    this.agentUuid,
    this.subStaffId,
  });

  @override
  State<OrderListBodyDesktop> createState() =>
      _OrderListBodyDesktopState();
}

class _OrderListBodyDesktopState
    extends State<OrderListBodyDesktop> {
  Future<void> getOrders() async {
    await returnOrdersProvider().loadOrders(shopId());
    setState(() {});
  }

  int currentFilter = 0;

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                      title: 'Unpaid Balance',
                      value: returnOrdersProvider(
                        context: context,
                      ).getTotalRevenueForSelectedDayAll(
                        customerId: widget.customerUuid,
                        staffId: widget.agentUuid,
                      ),
                    ),
                    ValueSummaryTabSmall(
                      value:
                          widget.agentUuid != null
                              ? returnOrdersProvider(
                                    context: context,
                                  )
                                  .returnOrdersByDayOrWeekAll(
                                    // context,
                                  )
                                  .where(
                                    (order) =>
                                        order.staffId ==
                                        widget.agentUuid,
                                  )
                                  .toList()
                                  .length
                                  .toDouble()
                              : widget.subStaffId != null
                              ? returnOrdersProvider(
                                    context: context,
                                  )
                                  .returnOrdersByDayOrWeekAll(
                                    // context,
                                  )
                                  .where(
                                    (order) =>
                                        order
                                            .subStaffUuid ==
                                        widget.subStaffId,
                                  )
                                  .toList()
                                  .length
                                  .toDouble()
                              : widget.customerUuid != null
                              ? returnOrdersProvider(
                                    context: context,
                                  )
                                  .returnOrdersByDayOrWeekAll(
                                    // context,
                                  )
                                  .where(
                                    (order) =>
                                        order.customerId ==
                                        widget.customerUuid,
                                  )
                                  .toList()
                                  .length
                                  .toDouble()
                              : returnOrdersProvider(
                                    context: context,
                                  )
                                  .returnOrdersByDayOrWeekAll()
                                  .toList()
                                  .length
                                  .toDouble(),
                      title: 'Order Number',
                      color: Colors.green,
                      isMoney: false,
                    ),
                  ],
                ),
                Visibility(
                  visible:
                      !authorization(
                        authorized:
                            Authorizations().viewDate,
                      ),
                  child: SizedBox(height: 20),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10.0,
                  ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Visibility(
                        visible: authorization(
                          authorized:
                              Authorizations().viewDate,
                        ),
                        child: Text(
                          style: TextStyle(
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b1
                                    .fontSize,
                          ),
                          'All Order',
                        ),
                      ),
                      SizedBox(width: 20),
                      SizedBox(
                        width: 270,
                        child: Row(
                          spacing: 6,
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: ProductsFilterButton(
                                action: () {
                                  returnOrdersProvider()
                                      .selectPaymentStatus(
                                        0,
                                      );
                                },
                                currentSelected:
                                    returnOrdersProvider(
                                      context: context,
                                    ).orderPaymentStatusIndex,
                                number: 0,
                                title: 'Unpaid',
                                theme: theme,
                              ),
                            ),
                            Expanded(
                              child: ProductsFilterButton(
                                action: () {
                                  returnOrdersProvider()
                                      .selectPaymentStatus(
                                        1,
                                      );
                                },
                                currentSelected:
                                    returnOrdersProvider(
                                      context: context,
                                    ).orderPaymentStatusIndex,
                                number: 1,
                                title: 'Paid',
                                theme: theme,
                              ),
                            ),
                            Expanded(
                              child: ProductsFilterButton(
                                action: () {
                                  returnOrdersProvider()
                                      .selectPaymentStatus(
                                        2,
                                      );
                                },
                                currentSelected:
                                    returnOrdersProvider(
                                      context: context,
                                    ).orderPaymentStatusIndex,
                                number: 2,
                                title: 'Partial',
                                theme: theme,
                              ),
                            ),
                            Expanded(
                              child: ProductsFilterButton(
                                currentSelected:
                                    returnOrdersProvider(
                                      context: context,
                                    ).orderPaymentStatusIndex,
                                action: () {
                                  returnOrdersProvider()
                                      .selectPaymentStatus(
                                        3,
                                      );
                                },
                                number: 3,
                                title: 'All',
                                theme: theme,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 20),
                      Visibility(
                        visible: authorization(
                          authorized:
                              Authorizations().viewDate,
                        ),
                        child: MaterialButton(
                          mouseCursor:
                              SystemMouseCursors.click,
                          onPressed: () {
                            if (returnOrdersProvider()
                                        .dateSet !=
                                    null ||
                                returnOrdersProvider()
                                        .rangeStartDate !=
                                    null) {
                              returnOrdersProvider()
                                  .clearDate();
                            } else {
                              mainDatePicker(
                                context: context,
                                theme: theme,
                                singleDate: (date) {
                                  returnOrdersProvider()
                                      .setDate(date!);
                                },
                                rangeDate: (
                                  firstDate,
                                  lastDate,
                                ) {
                                  returnOrdersProvider()
                                      .setRange(
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
                                      FontWeight.bold,
                                  color:
                                      Colors.grey.shade700,
                                ),
                                returnOrdersProvider(
                                              context:
                                                  context,
                                            ).dateSet !=
                                            null ||
                                        returnOrdersProvider(
                                              context:
                                                  context,
                                            ).rangeStartDate !=
                                            null
                                    ? 'Clear Date'
                                    : 'Set Date',
                              ),
                              Icon(
                                size: 20,
                                color:
                                    theme
                                        .lightModeColor
                                        .secColor100,
                                returnOrdersProvider(
                                              context:
                                                  context,
                                            ).dateSet !=
                                            null ||
                                        returnOrdersProvider(
                                              context:
                                                  context,
                                            ).rangeStartDate !=
                                            null
                                    ? Icons.clear
                                    : Icons
                                        .date_range_outlined,
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
                if (widget.agentUuid != null
                    ? returnOrdersProvider(context: context)
                        .returnOrdersByDayOrWeekAll(
                          // context,
                        )
                        .toList()
                        .where(
                          (rec) =>
                              rec.staffId ==
                              widget.agentUuid,
                        )
                        .toList()
                        .isEmpty
                    : widget.subStaffId != null
                    ? returnOrdersProvider(context: context)
                        .returnOrdersByDayOrWeekAll(
                          // context,
                        )
                        .toList()
                        .where(
                          (rec) =>
                              rec.subStaffUuid ==
                              widget.subStaffId,
                        )
                        .toList()
                        .isEmpty
                    : widget.customerUuid != null
                    ? returnOrdersProvider(context: context)
                        .returnOrdersByDayOrWeekAll()
                        .where(
                          (rec) =>
                              rec.customerId ==
                              widget.customerUuid,
                        )
                        .toList()
                        .isEmpty
                    : returnOrdersProvider(context: context)
                        .returnOrdersByDayOrWeekAll()
                        .toList()
                        .isEmpty) {
                  return EmptyWidgetDisplayOnly(
                    title: 'Empty List',
                    subText:
                        'You don\'t have any Sales under this category',
                    icon: Icons.clear,
                    theme: theme,
                    height: 35,
                    altAction: () {
                      getOrders();
                    },
                    altActionText: 'Refresh List',
                  );
                } else {
                  return RefreshIndicator(
                    onRefresh: getOrders,
                    backgroundColor: Colors.white,
                    color: theme.lightModeColor.prColor300,
                    displacement: 10,
                    child: ListView.builder(
                      itemCount:
                          widget.agentUuid != null
                              ? returnOrdersProvider(
                                    context: context,
                                  )
                                  .returnOrdersByDayOrWeekAll()
                                  .where(
                                    (rec) =>
                                        rec.staffId ==
                                        widget.agentUuid,
                                  )
                                  .toList()
                                  .length
                              : widget.subStaffId != null
                              ? returnOrdersProvider(
                                    context: context,
                                  )
                                  .returnOrdersByDayOrWeekAll()
                                  .where(
                                    (rec) =>
                                        rec.subStaffUuid ==
                                        widget.subStaffId,
                                  )
                                  .toList()
                                  .length
                              : widget.customerUuid != null
                              ? returnOrdersProvider(
                                    context: context,
                                  )
                                  .returnOrdersByDayOrWeekAll(
                                    // context,
                                  )
                                  .where(
                                    (rec) =>
                                        rec.customerId ==
                                        widget.customerUuid,
                                  )
                                  .toList()
                                  .length
                              : returnOrdersProvider(
                                    context: context,
                                  )
                                  .returnOrdersByDayOrWeekAll(
                                    // context,
                                  )
                                  .toList()
                                  .length,
                      itemBuilder: (context, index) {
                        var order =
                            widget.agentUuid != null
                                ? returnOrdersProvider(
                                      context: context,
                                    )
                                    .returnOrdersByDayOrWeekAll(
                                      // context,
                                    )
                                    .where(
                                      (rec) =>
                                          rec.staffId ==
                                          widget.agentUuid,
                                    )
                                    .toList()[index]
                                : widget.subStaffId != null
                                ? returnOrdersProvider(
                                      context: context,
                                    )
                                    .returnOrdersByDayOrWeekAll(
                                      // context,
                                    )
                                    .where(
                                      (rec) =>
                                          rec.subStaffUuid ==
                                          widget.subStaffId,
                                    )
                                    .toList()[index]
                                : widget.customerUuid !=
                                    null
                                ? returnOrdersProvider(
                                      context: context,
                                    )
                                    .returnOrdersByDayOrWeekAll(
                                      // context,
                                    )
                                    .where(
                                      (rec) =>
                                          rec.customerId ==
                                          widget
                                              .customerUuid,
                                    )
                                    .toList()[index]
                                : returnOrdersProvider(
                                      context: context,
                                    )
                                    .returnOrdersByDayOrWeekAll()
                                    .toList()[index];
                        return MainOrderTile(
                          action: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return ReceiptPage(
                                    response:
                                        CheckoutResponse(
                                          order: order,
                                        ),
                                    isMain: false,
                                  );
                                },
                              ),
                            ).then((_) {
                              setState(() {});
                            });
                          },
                          key: ValueKey(order.uuid),
                          order: order,
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
    );
  }
}
