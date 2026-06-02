import 'package:flutter/material.dart';
import 'package:stockall/classes/checkout_response.dart';
import 'package:stockall/components/buttons/floating_action_butto.dart';
import 'package:stockall/components/list_tiles/main_receipt_tile.dart';
import 'package:stockall/components/major/desktop_page_container.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/date_picker_function.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/refresh_functions.dart';
import 'package:stockall/constants/subscription/sales_auth.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/invoices/invoice_list/platforms/invoice_list_desktop.dart';
import 'package:stockall/pages/products/compnents/product_filter_button.dart';
import 'package:stockall/pages/sales/make_sales/page1/make_sales_page.dart';
import 'package:stockall/pages/sales/make_sales/receipt_page/receipt_page.dart';

class TotalSalesDesktop extends StatefulWidget {
  final String? id;
  final String? customerUuid;
  final String? subStaffId;
  // final bool? isInvoice;
  final bool? turnOff;
  const TotalSalesDesktop({
    super.key,
    this.id,
    this.customerUuid,
    // this.isInvoice,
    this.turnOff,
    this.subStaffId,
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
      returnNavProvider(context, listen: false).navigate(2);
    });
  }

  bool returnInvoice = false;

  void switchReturnInvoice(bool value) {
    setState(() {
      returnInvoice = value;
    });
  }

  bool isLoading = false;

  void clearDate() {
    returnReceiptProvider(
      context,
      listen: false,
    ).clearDate();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: [
          Row(
            spacing: 15,
            children: [
              Container(
                width:
                    screenWidth(context) < tabletScreenSmall
                        ? 50
                        : (screenWidth(context) >
                                tabletScreenSmall &&
                            screenWidth(context) <
                                tabletScreen + 100)
                        ? 100
                        : 230,
              ),
              Expanded(
                child: DesktopPageContainer(
                  widget: Scaffold(
                    appBar: appBar(
                      turnOff: widget.turnOff,
                      context: context,
                      title:
                          !returnInvoice
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
                                      switchReturnInvoice(
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
                                            !returnInvoice
                                                ? FontWeight
                                                    .bold
                                                : null,
                                      ),
                                      'Receipts',
                                    ),
                                  ),
                                  PopupMenuItem(
                                    onTap: () {
                                      switchReturnInvoice(
                                        true,
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
                                            returnInvoice
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
                                              .b3
                                              .fontSize,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                    !returnInvoice
                                        ? 'Receipts'
                                        : 'Invoices',
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
                    floatingActionButton: Visibility(
                      visible: returnInvoice,
                      child: FloatingActionButtonMain(
                        action: () {
                          SalesAuthAction()
                              .invoiceManagementAction(
                                context: context,
                                action: () {
                                  if (authorization(
                                    authorized:
                                        Authorizations()
                                            .makeSale,
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
                                            isInvoice: true,
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
                            theme
                                .lightModeColor
                                .secColor100,
                        text: 'Create Invoice',
                        theme: theme,
                      ),
                    ),
                    body: Builder(
                      builder: (context) {
                        if (!returnInvoice) {
                          return Padding(
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
                                            value: returnReceiptProvider(
                                              context,
                                              listen: false,
                                            ).getTotalRevenueForSelectedDayAll(
                                              customerId:
                                                  widget
                                                      .customerUuid,
                                              staffId:
                                                  widget.id,
                                              subStaffId:
                                                  widget
                                                      .subStaffId,
                                            ),
                                          ),
                                          ValueSummaryTabSmall(
                                            value:
                                                widget.id !=
                                                        null
                                                    ? returnReceiptProvider(
                                                          context,
                                                        )
                                                        .returnOwnReceiptsByDayOrWeek()
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
                                                    : widget.subStaffId !=
                                                        null
                                                    ? returnReceiptProvider(
                                                          context,
                                                        )
                                                        .returnOwnReceiptsByDayOrWeek()
                                                        .where(
                                                          (
                                                            receipt,
                                                          ) =>
                                                              receipt.subStaffUuid ==
                                                              widget.subStaffId,
                                                        )
                                                        .toList()
                                                        .length
                                                        .toDouble()
                                                    : widget.customerUuid !=
                                                        null
                                                    ? returnReceiptProvider(
                                                          context,
                                                        )
                                                        .returnOwnReceiptsByDayOrWeek()
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
                                                        .returnOwnReceiptsByDayOrWeek()
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
                                      // SizedBox(height: 20),
                                      Padding(
                                        padding:
                                            const EdgeInsets.symmetric(
                                              vertical:
                                                  10.0,
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
                                                returnReceiptProvider(context).dateSet !=
                                                            null ||
                                                        returnReceiptProvider(context).rangeStartDate !=
                                                            null
                                                    ? 'All Sales'
                                                    : 'For Today',
                                              ),
                                            ),
                                            SizedBox(
                                              width: 20,
                                            ),
                                            SizedBox(
                                              width: 250,
                                              child: Row(
                                                spacing: 6,
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .center,
                                                children: [
                                                  Expanded(
                                                    child: ProductsFilterButton(
                                                      action: () {
                                                        returnReceiptProviderSingle().selectPaymentMethod(
                                                          0,
                                                        );
                                                      },
                                                      currentSelected:
                                                          returnReceiptProvider(
                                                            context,
                                                          ).paymentMethod,
                                                      number:
                                                          0,
                                                      title:
                                                          'All',
                                                      theme:
                                                          theme,
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: ProductsFilterButton(
                                                      action: () {
                                                        returnReceiptProviderSingle().selectPaymentMethod(
                                                          1,
                                                        );
                                                      },
                                                      currentSelected:
                                                          returnReceiptProvider(
                                                            context,
                                                          ).paymentMethod,
                                                      number:
                                                          1,
                                                      title:
                                                          'Cash',
                                                      theme:
                                                          theme,
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: ProductsFilterButton(
                                                      action: () {
                                                        returnReceiptProviderSingle().selectPaymentMethod(
                                                          2,
                                                        );
                                                      },
                                                      currentSelected:
                                                          returnReceiptProvider(
                                                            context,
                                                          ).paymentMethod,
                                                      number:
                                                          2,
                                                      title:
                                                          'Bank',
                                                      theme:
                                                          theme,
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: ProductsFilterButton(
                                                      currentSelected:
                                                          returnReceiptProvider(
                                                            context,
                                                          ).paymentMethod,
                                                      action: () {
                                                        returnReceiptProviderSingle().selectPaymentMethod(
                                                          3,
                                                        );
                                                      },
                                                      number:
                                                          3,
                                                      title:
                                                          'Split',
                                                      theme:
                                                          theme,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              width: 20,
                                            ),
                                            Visibility(
                                              visible: authorization(
                                                authorized:
                                                    Authorizations()
                                                        .viewDate,
                                              ),
                                              child: MaterialButton(
                                                onPressed: () {
                                                  if (returnReceiptProvider(
                                                            context,
                                                            listen:
                                                                false,
                                                          ).dateSet !=
                                                          null ||
                                                      returnReceiptProvider(
                                                            context,
                                                            listen:
                                                                false,
                                                          ).rangeStartDate !=
                                                          null) {
                                                    returnReceiptProvider(
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
                                                        returnReceiptProvider(
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
                                                        returnReceiptProvider(
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
                                                      returnReceiptProvider(
                                                                    context,
                                                                  ).dateSet !=
                                                                  null ||
                                                              returnReceiptProvider(
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
                                                      returnReceiptProvider(
                                                                    context,
                                                                  ).dateSet !=
                                                                  null ||
                                                              returnReceiptProvider(
                                                                    context,
                                                                  ).rangeStartDate !=
                                                                  null
                                                          ? Icons.clear
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
                                          ? returnReceiptProvider(
                                                context,
                                              )
                                              .returnOwnReceiptsByDayOrWeek()
                                              .toList()
                                              .where(
                                                (rec) =>
                                                    rec.staffId ==
                                                    widget
                                                        .id,
                                              )
                                              .toList()
                                              .isEmpty
                                          : widget.subStaffId !=
                                              null
                                          ? returnReceiptProvider(
                                                context,
                                              )
                                              .returnOwnReceiptsByDayOrWeek()
                                              .toList()
                                              .where(
                                                (rec) =>
                                                    rec.subStaffUuid ==
                                                    widget
                                                        .subStaffId,
                                              )
                                              .toList()
                                              .isEmpty
                                          : widget.customerUuid !=
                                              null
                                          ? returnReceiptProvider(
                                                context,
                                              )
                                              .returnOwnReceiptsByDayOrWeek()
                                              .where(
                                                (rec) =>
                                                    rec.customerUuid ==
                                                    widget
                                                        .customerUuid,
                                              )
                                              .toList()
                                              .isEmpty
                                          : returnReceiptProvider(
                                                context,
                                              )
                                              .returnOwnReceiptsByDayOrWeek()
                                              .toList()
                                              .isEmpty) {
                                        return EmptyWidgetDisplayOnly(
                                          title:
                                              'Empty List',
                                          subText:
                                              'You don\'t have any Sales under this category',
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
                                                        .returnOwnReceiptsByDayOrWeek()
                                                        .where(
                                                          (
                                                            rec,
                                                          ) =>
                                                              rec.staffId ==
                                                              widget.id,
                                                        )
                                                        .toList()
                                                        .length
                                                    : widget.subStaffId !=
                                                        null
                                                    ? returnReceiptProvider(
                                                          context,
                                                        )
                                                        .returnOwnReceiptsByDayOrWeek()
                                                        .where(
                                                          (
                                                            rec,
                                                          ) =>
                                                              rec.subStaffUuid ==
                                                              widget.subStaffId,
                                                        )
                                                        .toList()
                                                        .length
                                                    : widget.customerUuid !=
                                                        null
                                                    ? returnReceiptProvider(
                                                          context,
                                                        )
                                                        .returnOwnReceiptsByDayOrWeek()
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
                                                        .returnOwnReceiptsByDayOrWeek()
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
                                                          .returnOwnReceiptsByDayOrWeek()
                                                          .where(
                                                            (
                                                              rec,
                                                            ) =>
                                                                rec.staffId ==
                                                                widget.id,
                                                          )
                                                          .toList()[index]
                                                      : widget.subStaffId !=
                                                          null
                                                      ? returnReceiptProvider(
                                                            context,
                                                          )
                                                          .returnOwnReceiptsByDayOrWeek()
                                                          .where(
                                                            (
                                                              rec,
                                                            ) =>
                                                                rec.subStaffUuid ==
                                                                widget.subStaffId,
                                                          )
                                                          .toList()[index]
                                                      : widget.customerUuid !=
                                                          null
                                                      ? returnReceiptProvider(
                                                            context,
                                                          )
                                                          .returnOwnReceiptsByDayOrWeek()
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
                                                      ).returnOwnReceiptsByDayOrWeek().toList()[index];
                                              return MainReceiptTile(
                                                action: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (
                                                        context,
                                                      ) {
                                                        return ReceiptPage(
                                                          response: CheckoutResponse(
                                                            resUuid:
                                                                receipt.uuid!,
                                                            isReceipt:
                                                                true,
                                                          ),
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
                          );
                        } else {
                          return InvoiceListBodyDesktop(
                            agentUuid: widget.id,
                            customerUuid:
                                widget.customerUuid,
                            subStaffId: widget.subStaffId,
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),
              Container(
                width:
                    screenWidth(context) < tabletScreenSmall
                        ? 50
                        : (screenWidth(context) >
                                tabletScreenSmall &&
                            screenWidth(context) <
                                tabletScreen + 100)
                        ? 100
                        : 230,
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
