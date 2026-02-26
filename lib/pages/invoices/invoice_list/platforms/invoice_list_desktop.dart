import 'package:flutter/material.dart';
import 'package:stockall/classes/checkout_response.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/buttons/floating_action_butto.dart';
import 'package:stockall/components/calendar/calendar_widget.dart';
import 'package:stockall/components/list_tiles/main_invoice_tile.dart';
import 'package:stockall/components/major/desktop_page_container.dart';
import 'package:stockall/components/major/drawer_widget/platforms/my_drawer_widget_desktop.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/components/major/drawer_widget/my_drawer_widget.dart';
import 'package:stockall/components/major/right_side_bar.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/refresh_functions.dart';
import 'package:stockall/constants/subscription/sales_auth.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/sales/make_sales/page1/make_sales_page.dart';
import 'package:stockall/pages/sales/make_sales/receipt_page/receipt_page.dart';
import 'package:stockall/services/auth_service.dart';

class InvoiceListDesktop extends StatefulWidget {
  final String? agentUuid;
  final String? customerUuid;
  const InvoiceListDesktop({
    super.key,
    this.agentUuid,
    this.customerUuid,
  });

  @override
  State<InvoiceListDesktop> createState() =>
      _InvoiceListDesktopState();
}

class _InvoiceListDesktopState
    extends State<InvoiceListDesktop> {
  Future<void> getInvoices() async {
    await RefreshFunctions(
      context,
    ).refreshInvoices(context);
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
    returnInvoicesProvider().clearInvoiceDate();
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
              ),
              Expanded(
                child: DesktopPageContainer(
                  widget: Scaffold(
                    appBar: appBar(
                      turnOff: true,
                      context: context,
                      title: 'All Invoices',
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
                                  getInvoices();
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
                        SalesAuthAction()
                            .invoiceManagementAction(
                              context: context,
                              action: () {
                                returnNavProvider(
                                  context,
                                  listen: false,
                                ).navigate(2);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return MakeSalesPage(
                                        isInvoice: true,
                                      );
                                    },
                                  ),
                                ).then((_) {
                                  setState(() {
                                    // getProductList(context);
                                  });
                                });
                              },
                            );
                      },
                      color:
                          theme.lightModeColor.secColor100,
                      text: 'Create Invoice',
                      theme: theme,
                    ),
                    body: InvoiceListBodyDesktop(
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

class InvoiceListBodyDesktop extends StatefulWidget {
  final String? customerUuid;
  final String? agentUuid;
  const InvoiceListBodyDesktop({
    super.key,
    this.customerUuid,
    this.agentUuid,
  });

  @override
  State<InvoiceListBodyDesktop> createState() =>
      _InvoiceListBodyDesktopState();
}

class _InvoiceListBodyDesktopState
    extends State<InvoiceListBodyDesktop> {
  Future<void> getInvoices() async {
    await RefreshFunctions(
      context,
    ).refreshInvoices(context);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
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
                          value: returnInvoicesProvider(
                            context: context,
                          ).getTotalRevenueForSelectedDayAll(
                            customerId: widget.customerUuid,
                            staffId: widget.agentUuid,
                          ),
                        ),
                        ValueSummaryTabSmall(
                          value:
                              widget.agentUuid != null
                                  ? returnInvoicesProvider(
                                        context: context,
                                      )
                                      .returnInvoicesByDayOrWeekAll(
                                        // context,
                                      )
                                      .where(
                                        (receipt) =>
                                            receipt
                                                .staffId ==
                                            widget
                                                .agentUuid,
                                      )
                                      .toList()
                                      .length
                                      .toDouble()
                                  : widget.customerUuid !=
                                      null
                                  ? returnInvoicesProvider(
                                        context: context,
                                      )
                                      .returnInvoicesByDayOrWeekAll(
                                        // context,
                                      )
                                      .where(
                                        (receipt) =>
                                            receipt
                                                .customerUuid ==
                                            widget
                                                .customerUuid,
                                      )
                                      .toList()
                                      .length
                                      .toDouble()
                                  : returnInvoicesProvider(
                                        context: context,
                                      )
                                      .returnInvoicesByDayOrWeekAll()
                                      .toList()
                                      .length
                                      .toDouble(),
                          title: 'Sales Number',
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
                      child: Visibility(
                        visible: authorization(
                          authorized:
                              Authorizations().viewDate,
                        ),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          children: [
                            Text(
                              style: TextStyle(
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .b1
                                        .fontSize,
                              ),
                              returnInvoicesProvider(
                                        context: context,
                                      ).dateSet ==
                                      null
                                  ? 'For Today'
                                  : '${returnInvoicesProvider(context: context).dateSet}',
                            ),
                            MaterialButton(
                              onPressed: () {
                                if (returnInvoicesProvider()
                                        .isDateSet ||
                                    returnInvoicesProvider()
                                        .setDate) {
                                  returnInvoicesProvider()
                                      .clearInvoiceDate();
                                } else {
                                  returnInvoicesProvider()
                                      .openDatePicker();
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
                                          Colors
                                              .grey
                                              .shade700,
                                    ),
                                    returnInvoicesProvider(
                                              context:
                                                  context,
                                            ).isDateSet ||
                                            returnInvoicesProvider(
                                              context:
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
                                    returnInvoicesProvider(
                                              context:
                                                  context,
                                            ).isDateSet ||
                                            returnInvoicesProvider(
                                              context:
                                                  context,
                                            ).setDate
                                        ? Icons.clear
                                        : Icons
                                            .date_range_outlined,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Builder(
                  builder: (context) {
                    if (widget.agentUuid != null
                        ? returnInvoicesProvider(
                              context: context,
                            )
                            .returnInvoicesByDayOrWeekAll(
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
                        : widget.customerUuid != null
                        ? returnInvoicesProvider(
                              context: context,
                            )
                            .returnInvoicesByDayOrWeekAll()
                            .where(
                              (rec) =>
                                  rec.customerUuid ==
                                  widget.customerUuid,
                            )
                            .toList()
                            .isEmpty
                        : returnInvoicesProvider(
                              context: context,
                            )
                            .returnInvoicesByDayOrWeekAll()
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
                          getInvoices();
                        },
                        altActionText: 'Refresh List',
                      );
                    } else {
                      return RefreshIndicator(
                        onRefresh: getInvoices,
                        backgroundColor: Colors.white,
                        color:
                            theme.lightModeColor.prColor300,
                        displacement: 10,
                        child: ListView.builder(
                          itemCount:
                              widget.agentUuid != null
                                  ? returnInvoicesProvider(
                                        context: context,
                                      )
                                      .returnInvoicesByDayOrWeekAll()
                                      .where(
                                        (rec) =>
                                            rec.staffId ==
                                            widget
                                                .agentUuid,
                                      )
                                      .toList()
                                      .length
                                  : widget.customerUuid !=
                                      null
                                  ? returnInvoicesProvider(
                                        context: context,
                                      )
                                      .returnInvoicesByDayOrWeekAll(
                                        // context,
                                      )
                                      .where(
                                        (rec) =>
                                            rec.customerUuid ==
                                            widget
                                                .customerUuid,
                                      )
                                      .toList()
                                      .length
                                  : returnInvoicesProvider(
                                        context: context,
                                      )
                                      .returnInvoicesByDayOrWeekAll(
                                        // context,
                                      )
                                      .toList()
                                      .length,
                          itemBuilder: (context, index) {
                            var invoice =
                                widget.agentUuid != null
                                    ? returnInvoicesProvider(
                                          context: context,
                                        )
                                        .returnInvoicesByDayOrWeekAll(
                                          // context,
                                        )
                                        .where(
                                          (rec) =>
                                              rec.staffId ==
                                              widget
                                                  .agentUuid,
                                        )
                                        .toList()[index]
                                    : widget.customerUuid !=
                                        null
                                    ? returnInvoicesProvider(
                                          context: context,
                                        )
                                        .returnInvoicesByDayOrWeekAll(
                                          // context,
                                        )
                                        .where(
                                          (rec) =>
                                              rec.customerUuid ==
                                              widget
                                                  .customerUuid,
                                        )
                                        .toList()[index]
                                    : returnInvoicesProvider(
                                          context: context,
                                        )
                                        .returnInvoicesByDayOrWeekAll()
                                        .toList()[index];
                            return MainInvoiceTile(
                              action: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return ReceiptPage(
                                        response:
                                            CheckoutResponse(
                                              resUuid:
                                                  invoice
                                                      .uuid!,
                                              isReceipt:
                                                  false,
                                            ),
                                        isMain: false,
                                      );
                                    },
                                  ),
                                ).then((_) {
                                  setState(() {});
                                });
                              },
                              key: ValueKey(invoice.uuid),
                              invoice: invoice,
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
        if (returnInvoicesProvider(
          context: context,
        ).setDate)
          GestureDetector(
            onTap: () {
              returnInvoicesProvider().clearInvoiceDate();
            },
            child: Material(
              color: const Color.fromARGB(100, 0, 0, 0),
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        height:
                            MediaQuery.of(
                              context,
                            ).size.height *
                            0.02,
                      ),
                      Center(
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(
                                horizontal: 15.0,
                              ),
                          child: Container(
                            height: 500,
                            width: 400,
                            padding: EdgeInsets.all(20),
                            color: Colors.white,

                            child: CalendarWidget(
                              onDaySelected: (
                                selectedDay,
                                focusedDay,
                              ) {
                                returnInvoicesProvider()
                                    .setInvoiceDay(
                                      selectedDay,
                                    );
                              },
                              actionWeek: (
                                startOfWeek,
                                endOfWeek,
                              ) {
                                returnInvoicesProvider()
                                    .setInvoiceWeek(
                                      startOfWeek,
                                      endOfWeek,
                                    );
                              },
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height:
                            MediaQuery.of(
                              context,
                            ).size.height *
                            0.3,
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
}
