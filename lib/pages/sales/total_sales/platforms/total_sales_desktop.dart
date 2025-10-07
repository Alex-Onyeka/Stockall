import 'package:flutter/material.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/buttons/floating_action_butto.dart';
import 'package:stockall/components/calendar/calendar_widget.dart';
import 'package:stockall/components/list_tiles/main_receipt_tile.dart';
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
import 'package:stockall/main.dart';
import 'package:stockall/pages/sales/make_sales/page1/make_sales_page.dart';
import 'package:stockall/pages/sales/make_sales/receipt_page/receipt_page.dart';
import 'package:stockall/services/auth_service.dart';

class TotalSalesDesktop extends StatefulWidget {
  final String? id;
  final String? customerUuid;
  final bool? isInvoice;
  final bool? turnOff;
  const TotalSalesDesktop({
    super.key,
    this.id,
    this.customerUuid,
    this.isInvoice,
    this.turnOff,
  });

  @override
  State<TotalSalesDesktop> createState() =>
      _TotalSalesDesktopState();
}

class _TotalSalesDesktopState
    extends State<TotalSalesDesktop> {
  Future<void> getMainReceipts() async {
    await RefreshFunctions(
      context,
    ).refreshReceipts(context);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      clearDate();
      if (widget.isInvoice != null) {
        returnNavProvider(
          context,
          listen: false,
        ).navigate(5);
        returnReceiptProvider(
          context,
          listen: false,
        ).switchReturnInvoice(true);
        returnData(
          context,
          listen: false,
        ).toggleFloatingAction(context);
      } else {
        returnNavProvider(
          context,
          listen: false,
        ).navigate(2);
        returnReceiptProvider(
          context,
          listen: false,
        ).switchReturnInvoice(false);
      }
    });
  }

  bool isLoading = false;

  void clearDate() {
    returnReceiptProvider(
      context,
      listen: false,
    ).clearReceiptDate();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return GestureDetector(
      onTap: () {
        returnReceiptProvider(
          context,
          listen: false,
        ).clearReceiptDate();
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
                Visibility(
                  visible:
                      widget.id == null &&
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
                        turnOff: widget.turnOff,
                        context: context,
                        title:
                            !returnReceiptProvider(
                                  context,
                                ).returnInvoice
                                ? 'All Sales'
                                : 'All Invoices',
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
                                    getMainReceipts();
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
                              padding:
                                  const EdgeInsets.only(
                                    right: 15.0,
                                  ),
                              child: PopupMenuButton(
                                offset: Offset(-20, 30),
                                color: Colors.white,
                                itemBuilder: (context) {
                                  return [
                                    PopupMenuItem(
                                      onTap: () {
                                        returnReceiptProvider(
                                          context,
                                          listen: false,
                                        ).switchReturnInvoice(
                                          false,
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
                                              !returnReceiptProvider(
                                                    context,
                                                    listen:
                                                        false,
                                                  ).returnInvoice
                                                  ? FontWeight
                                                      .bold
                                                  : null,
                                        ),
                                        'Receipts',
                                      ),
                                    ),
                                    PopupMenuItem(
                                      onTap: () {
                                        returnReceiptProvider(
                                          context,
                                          listen: false,
                                        ).switchReturnInvoice(
                                          true,
                                        );
                                        returnData(
                                          context,
                                          listen: false,
                                        ).toggleFloatingAction(
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
                                              returnReceiptProvider(
                                                    context,
                                                    listen:
                                                        false,
                                                  ).returnInvoice
                                                  ? FontWeight
                                                      .bold
                                                  : null,
                                        ),
                                        'Invoices',
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
                                                .b2
                                                .fontSize,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                      !returnReceiptProvider(
                                            context,
                                          ).returnInvoice
                                          ? 'Receipts'
                                          : 'Invoices',
                                    ),
                                    Icon(
                                      Icons
                                          .more_vert_rounded,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      floatingActionButton: Visibility(
                        visible:
                            returnReceiptProvider(
                              context,
                            ).returnInvoice,
                        child: FloatingActionButtonMain(
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
                          color:
                              theme
                                  .lightModeColor
                                  .secColor100,
                          text: 'Create Invoice',
                          theme: theme,
                        ),
                      ),
                      // floatingActionButtonLocation:
                      //     FloatingActionButtonLocation.endFloat,
                      body: Stack(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(
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
                                            color:
                                                Colors
                                                    .amber,
                                            isMoney: true,
                                            title:
                                                'Total Revenue',
                                            value:
                                                widget.id !=
                                                        null
                                                    ? returnReceiptProvider(
                                                      context,
                                                      listen:
                                                          false,
                                                    ).getTotalRevenueForSelectedDayAll(
                                                      context,
                                                      returnReceiptProvider(
                                                            context,
                                                          )
                                                          .returnReceipts(
                                                            context,
                                                          )
                                                          .toList(),
                                                      returnReceiptProvider(
                                                            context,
                                                            listen:
                                                                false,
                                                          )
                                                          .produtRecordSalesMain
                                                          .where(
                                                            (
                                                              empId,
                                                            ) =>
                                                                empId.staffId ==
                                                                widget.id!,
                                                          )
                                                          .toList(),
                                                    )
                                                    : widget.customerUuid !=
                                                        null
                                                    ? returnReceiptProvider(
                                                      context,
                                                      listen:
                                                          false,
                                                    ).getTotalRevenueForSelectedDayAll(
                                                      context,
                                                      returnReceiptProvider(
                                                            context,
                                                          )
                                                          .returnReceipts(
                                                            context,
                                                          )
                                                          .toList(),
                                                      returnReceiptProvider(
                                                            context,
                                                            listen:
                                                                false,
                                                          )
                                                          .produtRecordSalesMain
                                                          .where(
                                                            (
                                                              empId,
                                                            ) =>
                                                                empId.customerUuid ==
                                                                widget.customerUuid!,
                                                          )
                                                          .toList(),
                                                    )
                                                    : returnReceiptProvider(
                                                      context,
                                                      listen:
                                                          false,
                                                    ).getTotalRevenueForSelectedDayAll(
                                                      context,
                                                      returnReceiptProvider(
                                                            context,
                                                          )
                                                          .returnReceipts(
                                                            context,
                                                          )
                                                          .toList(),
                                                      returnReceiptProvider(
                                                        context,
                                                        listen:
                                                            false,
                                                      ).produtRecordSalesMain,
                                                    ),
                                          ),
                                          ValueSummaryTabSmall(
                                            value:
                                                widget.id !=
                                                        null
                                                    ? returnReceiptProvider(
                                                          context,
                                                        )
                                                        .returnReceipts(
                                                          context,
                                                        )
                                                        .where(
                                                          (
                                                            receipt,
                                                          ) =>
                                                              receipt.staffId ==
                                                              widget.id,
                                                        )
                                                        .toList()
                                                        .length
                                                        .toDouble()
                                                    : widget.customerUuid !=
                                                        null
                                                    ? returnReceiptProvider(
                                                          context,
                                                        )
                                                        .returnReceipts(
                                                          context,
                                                        )
                                                        .where(
                                                          (
                                                            receipt,
                                                          ) =>
                                                              receipt.customerUuid ==
                                                              widget.customerUuid,
                                                        )
                                                        .toList()
                                                        .length
                                                        .toDouble()
                                                    : returnReceiptProvider(
                                                          context,
                                                        )
                                                        .returnReceipts(
                                                          context,
                                                        )
                                                        .toList()
                                                        .length
                                                        .toDouble(),
                                            title:
                                                'Sales Number',
                                            color:
                                                Colors
                                                    .green,
                                            isMoney: false,
                                          ),
                                        ],
                                      ),
                                      Visibility(
                                        visible:
                                            !authorization(
                                              authorized:
                                                  Authorizations()
                                                      .viewDate,
                                              context:
                                                  context,
                                            ) ||
                                            returnReceiptProvider(
                                              context,
                                            ).returnInvoice,
                                        child: SizedBox(
                                          height: 20,
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.symmetric(
                                              vertical:
                                                  10.0,
                                            ),
                                        child: Visibility(
                                          visible:
                                              authorization(
                                                authorized:
                                                    Authorizations()
                                                        .viewDate,
                                                context:
                                                    context,
                                              ) &&
                                              !returnReceiptProvider(
                                                context,
                                              ).returnInvoice,
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
                                                returnReceiptProvider(
                                                          context,
                                                        ).dateSet ==
                                                        null
                                                    ? 'For Today'
                                                    : '${returnReceiptProvider(context).dateSet}',
                                              ),
                                              MaterialButton(
                                                onPressed: () {
                                                  if (returnReceiptProvider(
                                                        context,
                                                        listen:
                                                            false,
                                                      ).isDateSet ||
                                                      returnReceiptProvider(
                                                        context,
                                                        listen:
                                                            false,
                                                      ).setDate) {
                                                    returnReceiptProvider(
                                                      context,
                                                      listen:
                                                          false,
                                                    ).clearReceiptDate();
                                                  } else {
                                                    returnReceiptProvider(
                                                      context,
                                                      listen:
                                                          false,
                                                    ).openDatePicker();
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
                                                      returnReceiptProvider(
                                                                context,
                                                              ).isDateSet ||
                                                              returnReceiptProvider(
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
                                                      returnReceiptProvider(
                                                                context,
                                                              ).isDateSet ||
                                                              returnReceiptProvider(
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
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Builder(
                                    builder: (context) {
                                      if (widget.id != null
                                          ? returnReceiptProvider(
                                                context,
                                              )
                                              .returnReceipts(
                                                context,
                                              )
                                              .toList()
                                              .where(
                                                (rec) =>
                                                    rec.staffId ==
                                                    widget
                                                        .id,
                                              )
                                              .toList()
                                              .isEmpty
                                          : widget.customerUuid !=
                                              null
                                          ? returnReceiptProvider(
                                                context,
                                              )
                                              .returnOwnReceiptsByDayOrWeek(
                                                context,
                                                returnReceiptProvider(
                                                      context,
                                                    )
                                                    .receipts
                                                    .where(
                                                      (
                                                        rec,
                                                      ) =>
                                                          rec.customerUuid ==
                                                          widget.customerUuid,
                                                    )
                                                    .toList(),
                                              )
                                              .toList()
                                              .isEmpty
                                          : returnReceiptProvider(
                                                context,
                                              )
                                              .returnReceipts(
                                                context,
                                              )
                                              .toList()
                                              .isEmpty) {
                                        return EmptyWidgetDisplayOnly(
                                          title:
                                              'Empty List',
                                          subText:
                                              widget.isInvoice !=
                                                      null
                                                  ? 'You Currently do not have any pending Invoices recorded'
                                                  : 'You don\'t have any Sales under this category',
                                          icon: Icons.clear,
                                          theme: theme,
                                          height: 35,
                                          altAction: () {
                                            getMainReceipts();
                                          },
                                          altActionText:
                                              'Refresh List',
                                        );
                                      } else {
                                        return RefreshIndicator(
                                          onRefresh:
                                              getMainReceipts,
                                          backgroundColor:
                                              Colors.white,
                                          color:
                                              theme
                                                  .lightModeColor
                                                  .prColor300,
                                          displacement: 10,
                                          child: ListView.builder(
                                            itemCount:
                                                widget.id !=
                                                        null
                                                    ? returnReceiptProvider(
                                                          context,
                                                        )
                                                        .returnReceipts(
                                                          context,
                                                        )
                                                        .where(
                                                          (
                                                            rec,
                                                          ) =>
                                                              rec.staffId ==
                                                              widget.id,
                                                        )
                                                        .toList()
                                                        .length
                                                    : widget.customerUuid !=
                                                        null
                                                    ? returnReceiptProvider(
                                                          context,
                                                        )
                                                        .returnReceipts(
                                                          context,
                                                        )
                                                        .where(
                                                          (
                                                            rec,
                                                          ) =>
                                                              rec.customerUuid ==
                                                              widget.customerUuid,
                                                        )
                                                        .toList()
                                                        .length
                                                    : returnReceiptProvider(
                                                          context,
                                                        )
                                                        .returnReceipts(
                                                          context,
                                                        )
                                                        .toList()
                                                        .length,
                                            itemBuilder: (
                                              context,
                                              index,
                                            ) {
                                              var receipt =
                                                  widget.id !=
                                                          null
                                                      ? returnReceiptProvider(
                                                            context,
                                                          )
                                                          .returnReceipts(
                                                            context,
                                                          )
                                                          .where(
                                                            (
                                                              rec,
                                                            ) =>
                                                                rec.staffId ==
                                                                widget.id,
                                                          )
                                                          .toList()[index]
                                                      : widget.customerUuid !=
                                                          null
                                                      ? returnReceiptProvider(
                                                            context,
                                                          )
                                                          .returnReceipts(
                                                            context,
                                                          )
                                                          .where(
                                                            (
                                                              rec,
                                                            ) =>
                                                                rec.customerUuid ==
                                                                widget.customerUuid,
                                                          )
                                                          .toList()[index]
                                                      : returnReceiptProvider(
                                                        context,
                                                      ).returnReceipts(context).toList()[index];
                                              return MainReceiptTile(
                                                action: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (
                                                        context,
                                                      ) {
                                                        return ReceiptPage(
                                                          receiptUuid:
                                                              receipt.uuid!,
                                                          isMain:
                                                              false,
                                                        );
                                                      },
                                                    ),
                                                  ).then((
                                                    _,
                                                  ) {
                                                    // mainReceiptFuture =
                                                    //     getMainReceipts();
                                                  });
                                                },
                                                key: ValueKey(
                                                  receipt
                                                      .uuid,
                                                ),
                                                mainReceipt:
                                                    receipt,
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
                          if (returnReceiptProvider(
                            context,
                          ).setDate)
                            GestureDetector(
                              onTap: () {
                                returnReceiptProvider(
                                  context,
                                  listen: false,
                                ).clearReceiptDate();
                              },
                              child: Material(
                                color: const Color.fromARGB(
                                  100,
                                  0,
                                  0,
                                  0,
                                ),
                                child: SizedBox(
                                  height:
                                      MediaQuery.of(
                                        context,
                                      ).size.height,
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          height:
                                              MediaQuery.of(
                                                    context,
                                                  )
                                                  .size
                                                  .height *
                                              0.02,
                                        ),
                                        Center(
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.symmetric(
                                                  horizontal:
                                                      15.0,
                                                ),
                                            child: Container(
                                              height: 500,
                                              width: 400,
                                              padding:
                                                  EdgeInsets.all(
                                                    20,
                                                  ),
                                              color:
                                                  Colors
                                                      .white,

                                              child: CalendarWidget(
                                                onDaySelected: (
                                                  selectedDay,
                                                  focusedDay,
                                                ) {
                                                  returnReceiptProvider(
                                                    context,
                                                    listen:
                                                        false,
                                                  ).setReceiptDay(
                                                    selectedDay,
                                                  );
                                                },
                                                actionWeek: (
                                                  startOfWeek,
                                                  endOfWeek,
                                                ) {
                                                  returnReceiptProvider(
                                                    context,
                                                    listen:
                                                        false,
                                                  ).setReceiptWeek(
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
                                                  )
                                                  .size
                                                  .height *
                                              0.3,
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
                Visibility(
                  visible:
                      widget.id == null &&
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
