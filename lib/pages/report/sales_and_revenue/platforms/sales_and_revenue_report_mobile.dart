import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_product_slaes_record/temp_product_sale_record.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/date_picker_function.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/refresh_functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/report/general_report/class/general_report_class.dart';
import 'package:stockall/providers/theme_provider.dart';

class SalesAndRevenueReportMobile extends StatefulWidget {
  const SalesAndRevenueReportMobile({super.key});

  @override
  State<SalesAndRevenueReportMobile> createState() =>
      _SalesAndRevenueReportMobileState();
}

class _SalesAndRevenueReportMobileState
    extends State<SalesAndRevenueReportMobile> {
  bool isSummary = false;
  late Future<void> productRecordFuture;
  Future<void> getProductRecord() async {
    await RefreshFunctions(
      context,
    ).refreshProductSalesRecord(context);
  }

  int sortIndex = 1;

  late Future<void> productsFuture;
  Future<void> getProducts() async {
    await RefreshFunctions(
      context,
    ).refreshProducts(context);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      returnReceiptProvider(
        context,
        listen: false,
      ).clearDate();
      returnSalesProvider().toggleIsLoading(false);
    });
    productRecordFuture = getProductRecord();
    productsFuture = getProducts();
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    List<TempProductSaleRecord> salesRecords =
        returnReceiptProvider(context)
            .returnProductsRecordByDayOrWeek()
            .where(
              (item) =>
                  item.isVoid != true &&
                  item.invoiceUuid == null,
            )
            .toList();

    return Scaffold(
      appBar: appBar(
        context: context,
        title: 'Sales',
        widget: Padding(
          padding: const EdgeInsets.only(right: 15.0),
          child: PopupMenuButton(
            offset: Offset(-20, 30),
            color: Colors.white,
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  onTap: () {
                    setState(() {
                      isSummary = false;
                    });
                  },
                  child: Text(
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b2.fontSize,
                      fontWeight:
                          !isSummary
                              ? FontWeight.bold
                              : null,
                    ),
                    'View Total Sales',
                  ),
                ),
                PopupMenuItem(
                  onTap: () {
                    setState(() {
                      isSummary = true;
                    });
                  },
                  child: Text(
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b2.fontSize,
                      fontWeight:
                          isSummary
                              ? FontWeight.bold
                              : null,
                    ),
                    'View Summary of Sales',
                  ),
                ),
                PopupMenuItem(
                  onTap: () {
                    setState(() {
                      sortIndex = 1;
                    });
                  },
                  child: Text(
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b2.fontSize,
                      fontWeight:
                          sortIndex == 1
                              ? FontWeight.bold
                              : null,
                    ),
                    'Sort By Name',
                  ),
                ),
                PopupMenuItem(
                  onTap: () {
                    setState(() {
                      sortIndex = 2;
                    });
                  },
                  child: Text(
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b2.fontSize,
                      fontWeight:
                          sortIndex == 2
                              ? FontWeight.bold
                              : null,
                    ),
                    'Sort By Quantity',
                  ),
                ),
                PopupMenuItem(
                  onTap: () {
                    setState(() {
                      sortIndex = 3;
                    });
                  },
                  child: Text(
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b2.fontSize,
                      fontWeight:
                          sortIndex == 3
                              ? FontWeight.bold
                              : null,
                    ),
                    'Sort By Revenue',
                  ),
                ),
                PopupMenuItem(
                  enabled: isSummary,
                  onTap: () {
                    setState(() {
                      sortIndex = 4;
                    });
                  },
                  child: Text(
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b2.fontSize,
                      fontWeight:
                          sortIndex == 4
                              ? FontWeight.bold
                              : null,
                    ),
                    'Sort By Profit',
                  ),
                ),
                PopupMenuItem(
                  enabled: !isSummary,
                  onTap: () {
                    setState(() {
                      sortIndex = 5;
                    });
                  },
                  child: Text(
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b2.fontSize,
                      fontWeight:
                          sortIndex == 5
                              ? FontWeight.bold
                              : null,
                    ),
                    'Sort By Created Date',
                  ),
                ),
              ];
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b2.fontSize,
                      ),
                      isSummary ? 'Summary' : 'Total',
                    ),
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b4.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                      "(${sortIndex == 1
                          ? 'Name'
                          : sortIndex == 2
                          ? 'Quantity'
                          : sortIndex == 3
                          ? 'Revenue'
                          : sortIndex == 4
                          ? 'Profit'
                          : sortIndex == 5
                          ? 'Date/Time'
                          : 'Name'})",
                    ),
                  ],
                ),
                Icon(Icons.more_vert_rounded),
              ],
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 5.0,
                ),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(width: 10),
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
                                      ).dateSet !=
                                      null ||
                                  returnReceiptProvider(
                                        context,
                                      ).rangeStartDate !=
                                      null
                              ? 'All Sales'
                              : 'For Today',
                        ),
                      ],
                    ),

                    // Visibility(
                    //   visible: false,
                    //   //  salesRecords.isNotEmpty,
                    //   child: Row(
                    //     mainAxisAlignment:
                    //         MainAxisAlignment.end,
                    //     children: [
                    //       InkWell(
                    //         onTap: () {
                    //           List<
                    //             GeneralReportSalesSummaryItem
                    //           >
                    //           summary =
                    //               returnReceiptProviderSingle()
                    //                   .returnGeneralReportSalesSummary();
                    //           summary.sort((a, b) {
                    //             switch (sortIndex) {
                    //               case 1:
                    //                 return a.itemName
                    //                     .compareTo(
                    //                       b.itemName,
                    //                     );
                    //               case 2:
                    //                 return b.quantity
                    //                     .compareTo(
                    //                       a.quantity,
                    //                     );
                    //               case 3:
                    //                 return b.totalCost
                    //                     .compareTo(
                    //                       a.totalCost,
                    //                     );
                    //               case 4:
                    //                 return b
                    //                     .profit()
                    //                     .compareTo(
                    //                       a.profit(),
                    //                     );
                    //               default:
                    //                 return a.itemName
                    //                     .compareTo(
                    //                       b.itemName,
                    //                     );
                    //             }
                    //           });

                    //           // List<TempProductSaleRecord> records =
                    //           //     salesRecords;

                    //           salesRecords.sort((a, b) {
                    //             switch (sortIndex) {
                    //               case 1:
                    //                 return a.productName
                    //                     .compareTo(
                    //                       b.productName,
                    //                     );
                    //               case 2:
                    //                 return b.quantity
                    //                     .compareTo(
                    //                       a.quantity,
                    //                     );
                    //               case 3:
                    //                 return b.revenue
                    //                     .compareTo(
                    //                       a.revenue,
                    //                     );
                    //               case 4:
                    //                 return a.productName
                    //                     .compareTo(
                    //                       b.productName,
                    //                     );
                    //               default:
                    //                 return b.createdAt
                    //                     .compareTo(
                    //                       a.createdAt,
                    //                     );
                    //             }
                    //           });

                    //           var safeContext = context;
                    //           showDialog(
                    //             context: context,
                    //             builder: (context) {
                    //               return ConfirmationAlert(
                    //                 theme: theme,
                    //                 message:
                    //                     'You are about to Print Sales Report, are you sure you want to proceed?',
                    //                 title:
                    //                     'Print Sales Report',
                    //                 action: () async {
                    //                   Navigator.of(
                    //                     context,
                    //                   ).pop();
                    //                   if (kIsWeb) {
                    //                     if (safeContext
                    //                         .mounted) {
                    //                       if (isSummary) {
                    //                       } else {}
                    //                     }
                    //                   }
                    //                   if (isSummary) {
                    //                     await generateAndPreviewPdfRollGeneralReport(
                    //                       context: context,
                    //                     );
                    //                   } else {
                    //                     await generateAndPreviewPdfSales(
                    //                       context:
                    //                           safeContext,
                    //                       records:
                    //                           salesRecords,
                    //                       shop:
                    //                           returnShopProvider()
                    //                               .userShop()!,
                    //                     );
                    //                   }

                    //                   if (safeContext
                    //                       .mounted) {
                    //                     returnSalesProvider()
                    //                         .toggleIsLoading(
                    //                           false,
                    //                         );
                    //                   }
                    //                 },
                    //               );
                    //             },
                    //           );
                    //         },
                    //         child: Container(
                    //           padding: EdgeInsets.symmetric(
                    //             horizontal: 10,
                    //           ),
                    //           child: Row(
                    //             spacing: 5,
                    //             children: [
                    //               Text(
                    //                 style: TextStyle(
                    //                   fontSize:
                    //                       theme
                    //                           .mobileTexts
                    //                           .b3
                    //                           .fontSize,
                    //                   color:
                    //                       Colors
                    //                           .grey
                    //                           .shade700,
                    //                   fontWeight:
                    //                       FontWeight.bold,
                    //                 ),
                    //                 'Print Report',
                    //               ),
                    //               Icon(
                    //                 color: Colors.grey,
                    //                 Icons.print,
                    //               ),
                    //             ],
                    //           ),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    Visibility(
                      visible: authorization(
                        authorized:
                            Authorizations().viewDate,
                      ),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.end,
                        children: [
                          MaterialButton(
                            onPressed: () {
                              if (returnReceiptProvider(
                                        context,
                                        listen: false,
                                      ).dateSet !=
                                      null ||
                                  returnReceiptProvider(
                                        context,
                                        listen: false,
                                      ).rangeStartDate !=
                                      null) {
                                returnReceiptProvider(
                                  context,
                                  listen: false,
                                ).clearDate();
                              } else {
                                mainDatePicker(
                                  context: context,
                                  theme: theme,
                                  singleDate: (date) {
                                    returnReceiptProviderSingle()
                                        .setDate(date!);
                                  },
                                  rangeDate: (
                                    firstDate,
                                    lastDate,
                                  ) {
                                    returnReceiptProviderSingle()
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
                                        Colors
                                            .grey
                                            .shade700,
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
                                  size: 20,
                                  color:
                                      theme
                                          .lightModeColor
                                          .secColor100,
                                  returnReceiptProvider(
                                                context,
                                              ).dateSet !=
                                              null ||
                                          returnReceiptProvider(
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
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                  ),
                  child: SingleChildScrollView(
                    primary: false,
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width:
                          salesRecords.isEmpty
                              ? MediaQuery.of(
                                context,
                              ).size.width
                              : MediaQuery.of(
                                    context,
                                  ).size.width <
                                  555
                              ? MediaQuery.of(
                                    context,
                                  ).size.width +
                                  580
                              : MediaQuery.of(
                                        context,
                                      ).size.width >
                                      555 &&
                                  MediaQuery.of(
                                        context,
                                      ).size.width <
                                      755
                              ? MediaQuery.of(
                                    context,
                                  ).size.width +
                                  380
                              : MediaQuery.of(
                                context,
                              ).size.width,
                      child: Column(
                        children: [
                          SummaryTableHeadingBar(
                            isHeading: true,
                            theme: theme,
                            salesRecords: salesRecords,
                          ),
                          Expanded(
                            child: Builder(
                              builder: (context) {
                                if (salesRecords.isEmpty) {
                                  return EmptyWidgetDisplayOnly(
                                    title: 'Empty List',
                                    subText:
                                        'No Sales Recorded Yet',
                                    theme: theme,
                                    height: 35,
                                    icon: Icons.clear,
                                  );
                                } else {
                                  if (isSummary) {
                                    var summary =
                                        returnReceiptProviderSingle()
                                            .returnGeneralReportSalesSummary();
                                    summary.sort((a, b) {
                                      switch (sortIndex) {
                                        case 1:
                                          return a.itemName
                                              .compareTo(
                                                b.itemName,
                                              );
                                        case 2:
                                          return b.quantity
                                              .compareTo(
                                                a.quantity,
                                              );
                                        case 3:
                                          return b.totalCost
                                              .compareTo(
                                                a.totalCost,
                                              );
                                        case 4:
                                          return b
                                              .profit()
                                              .compareTo(
                                                a.profit(),
                                              );
                                        default:
                                          return a.itemName
                                              .compareTo(
                                                b.itemName,
                                              );
                                      }
                                    });
                                    return RefreshIndicator(
                                      onRefresh: () {
                                        return RefreshFunctions(
                                          context,
                                        ).refreshReceipts(
                                          context,
                                        );
                                      },
                                      backgroundColor:
                                          Colors.white,
                                      color:
                                          theme
                                              .lightModeColor
                                              .prColor300,
                                      displacement: 10,
                                      child: ListView(
                                        children: [
                                          ListView.builder(
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            shrinkWrap:
                                                true,
                                            itemCount:
                                                summary
                                                    .length,
                                            itemBuilder: (
                                              context,
                                              index,
                                            ) {
                                              var record =
                                                  summary[index];
                                              var recordIndex =
                                                  summary.indexOf(
                                                    record,
                                                  ) +
                                                  1;

                                              return TableRowRecordWidgetSummary(
                                                theme:
                                                    theme,
                                                recordIndex:
                                                    recordIndex,
                                                record:
                                                    record,
                                              );
                                            },
                                          ),
                                          SummaryTableHeadingBar(
                                            isHeading:
                                                false,
                                            theme: theme,
                                            salesRecords:
                                                salesRecords,
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                        ],
                                      ),
                                    );
                                  } else {
                                    return RefreshIndicator(
                                      onRefresh: () {
                                        return RefreshFunctions(
                                          context,
                                        ).refreshReceipts(
                                          context,
                                        );
                                      },
                                      backgroundColor:
                                          Colors.white,
                                      color:
                                          theme
                                              .lightModeColor
                                              .prColor300,
                                      displacement: 10,
                                      child: ListView(
                                        children: [
                                          ListView.builder(
                                            shrinkWrap:
                                                true,
                                            itemCount:
                                                salesRecords
                                                    .length,
                                            physics:
                                                NeverScrollableScrollPhysics(),

                                            itemBuilder: (
                                              context,
                                              index,
                                            ) {
                                              salesRecords.sort((
                                                a,
                                                b,
                                              ) {
                                                switch (sortIndex) {
                                                  case 1:
                                                    return a
                                                        .productName
                                                        .compareTo(
                                                          b.productName,
                                                        );
                                                  case 2:
                                                    return b
                                                        .quantity
                                                        .compareTo(
                                                          a.quantity,
                                                        );
                                                  case 3:
                                                    return b
                                                        .revenue
                                                        .compareTo(
                                                          a.revenue,
                                                        );
                                                  case 4:
                                                    return a
                                                        .productName
                                                        .compareTo(
                                                          b.productName,
                                                        );
                                                  default:
                                                    return b
                                                        .createdAt
                                                        .compareTo(
                                                          a.createdAt,
                                                        );
                                                }
                                              });
                                              var record =
                                                  salesRecords[index];
                                              var recordIndex =
                                                  salesRecords
                                                      .indexOf(
                                                        record,
                                                      ) +
                                                  1;

                                              // return Container(
                                              //   margin:
                                              //       EdgeInsets.symmetric(
                                              //         vertical:
                                              //             5,
                                              //       ),
                                              //   padding:
                                              //       EdgeInsets.symmetric(
                                              //         vertical:
                                              //             20,
                                              //       ),
                                              //   color:
                                              //       Colors
                                              //           .teal,
                                              // );

                                              return TableRowRecordWidget(
                                                theme:
                                                    theme,
                                                recordIndex:
                                                    recordIndex,
                                                record:
                                                    record,
                                              );
                                            },
                                          ),
                                          SummaryTableHeadingBar(
                                            isHeading:
                                                false,
                                            theme: theme,
                                            salesRecords:
                                                salesRecords,
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                        ],
                                      ),
                                    );
                                  }
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
            ],
          ),
          Visibility(
            visible:
                returnSalesProviderContext(
                  context,
                ).isLoading,
            child: returnCompProvider(
              context,
              listen: false,
            ).showLoader(message: 'Generating Pdf'),
          ),
        ],
      ),
    );
  }
}

class SummaryTableHeadingBar extends StatefulWidget {
  const SummaryTableHeadingBar({
    super.key,
    required this.theme,
    required this.salesRecords,
    required this.isHeading,
  });

  final ThemeProvider theme;
  final List<TempProductSaleRecord> salesRecords;
  final bool isHeading;
  @override
  State<SummaryTableHeadingBar> createState() =>
      _SummaryTableHeadingBarState();
}

class _SummaryTableHeadingBarState
    extends State<SummaryTableHeadingBar> {
  double getTotal() {
    double tempTotal = 0;
    for (var item in widget.salesRecords) {
      tempTotal += item.revenue;
    }
    return tempTotal;
  }

  double getTotalCostPrice() {
    double tempTotal = 0;
    for (var item in widget.salesRecords) {
      tempTotal += (item.costPrice ?? 0);
    }
    return tempTotal;
  }

  double getTotalQuantity() {
    double tempTotal = 0;
    for (var item in widget.salesRecords) {
      tempTotal += item.quantity;
    }
    return tempTotal;
  }

  double getTotalProfit() {
    double tempTotal = 0;
    for (var item in widget.salesRecords) {
      tempTotal +=
          item.revenue -
          (item.costPrice == null || item.costPrice == 0
              ? item.revenue
              : item.costPrice!);
    }
    return tempTotal;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border:
            widget.isHeading
                ? Border(
                  left: BorderSide(color: Colors.grey),
                  right: BorderSide(color: Colors.grey),
                  bottom: BorderSide(color: Colors.grey),
                  top: BorderSide(color: Colors.grey),
                )
                : Border(
                  left: BorderSide(color: Colors.grey),
                  right: BorderSide(color: Colors.grey),
                  bottom: BorderSide(color: Colors.grey),
                ),
        color:
            widget.isHeading
                ? Colors.grey.shade100
                : Colors.grey.shade200,
      ),
      child: Row(
        spacing: 0,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 3,
                vertical: 10,
              ),
              child: Center(
                child: Text(
                  style: TextStyle(
                    fontSize:
                        widget
                            .theme
                            .mobileTexts
                            .b3
                            .fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  widget.isHeading ? 'S/N' : '',
                ),
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 5,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                border: Border(
                  // right: BorderSide(
                  //   color: Colors.grey,
                  // ),
                  left: BorderSide(color: Colors.grey),
                ),
              ),
              child: Center(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        style: TextStyle(
                          fontSize:
                              widget.isHeading
                                  ? widget
                                      .theme
                                      .mobileTexts
                                      .b3
                                      .fontSize
                                  : widget
                                      .theme
                                      .mobileTexts
                                      .b2
                                      .fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                        widget.isHeading ? 'Name' : 'TOTAL',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 5,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: Colors.grey),
                  left: BorderSide(color: Colors.grey),
                ),
              ),
              child: Center(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        style: TextStyle(
                          fontSize:
                              widget
                                  .theme
                                  .mobileTexts
                                  .b3
                                  .fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                        widget.isHeading
                            ? 'Quantity'
                            : getTotalQuantity().toString(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 5,
                vertical: 10,
              ),
              child: Center(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        style: TextStyle(
                          fontSize:
                              widget
                                  .theme
                                  .mobileTexts
                                  .b3
                                  .fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                        widget.isHeading
                            ? 'Selling-Price'
                            : formatMoneyBig(
                              amount: getTotal(),
                              context: context,
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
                widget.salesRecords.isNotEmpty &&
                authorization(
                  authorized:
                      Authorizations().manageCostPrice,
                ),
            child: Expanded(
              flex: 5,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(color: Colors.grey),
                    left: BorderSide(color: Colors.grey),
                  ),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 10,
                ),
                child: Center(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          style: TextStyle(
                            fontSize:
                                widget
                                    .theme
                                    .mobileTexts
                                    .b3
                                    .fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                          widget.isHeading
                              ? 'Cost-Price'
                              : formatMoneyBig(
                                amount: getTotalCostPrice(),
                                context: context,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Visibility(
            visible:
                widget.salesRecords.isNotEmpty &&
                authorization(
                  authorized:
                      Authorizations().manageCostPrice,
                ),
            child: Expanded(
              flex: 5,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 10,
                ),
                child: Center(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          style: TextStyle(
                            fontSize:
                                widget
                                    .theme
                                    .mobileTexts
                                    .b3
                                    .fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                          widget.isHeading
                              ? 'Profit/Loss'
                              : getTotalProfit() == 0
                              ? "Nill"
                              : formatMoneyBig(
                                amount: getTotalProfit(),
                                context: context,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TableRowRecordWidgetSummary extends StatelessWidget {
  const TableRowRecordWidgetSummary({
    super.key,
    required this.theme,
    required this.recordIndex,
    required this.record,
  });

  final ThemeProvider theme;
  final int recordIndex;
  final GeneralReportSalesSummaryItem record;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey),
          left: BorderSide(color: Colors.grey),
          right: BorderSide(color: Colors.grey),
        ),
      ),
      child: Row(
        spacing: 0,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.all(5),
              child: Center(
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        style: TextStyle(
                          fontSize:
                              theme.mobileTexts.b3.fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                        recordIndex.toString(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                border: Border(
                  // right: BorderSide(
                  //   color: Colors.grey,
                  // ),
                  left: BorderSide(color: Colors.grey),
                ),
              ),
              child: Center(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        style: TextStyle(
                          fontSize:
                              theme.mobileTexts.b3.fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                        record.itemName,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: Colors.grey),
                  left: BorderSide(color: Colors.grey),
                ),
              ),
              child: Center(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        style: TextStyle(
                          fontSize:
                              theme.mobileTexts.b3.fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                        record.quantity.toString(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Container(
              padding: EdgeInsets.all(5),
              child: Center(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        style: TextStyle(
                          fontSize:
                              theme.mobileTexts.b3.fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                        formatMoneyBig(
                          amount: record.totalCost,
                          context: context,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Visibility(
            visible: authorization(
              authorized: Authorizations().manageCostPrice,
            ),
            child: Expanded(
              flex: 5,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(color: Colors.grey),
                    left: BorderSide(color: Colors.grey),
                  ),
                ),
                padding: EdgeInsets.all(5),
                child: Center(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          style: TextStyle(
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b3
                                    .fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                          formatMoneyBig(
                            amount: record.costPrice,
                            context: context,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Visibility(
            visible: authorization(
              authorized: Authorizations().manageCostPrice,
            ),
            child: Expanded(
              flex: 5,
              child: Container(
                padding: EdgeInsets.all(5),
                child: Center(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          style: TextStyle(
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b3
                                    .fontSize,
                            fontWeight: FontWeight.bold,
                            color:
                                (record.profit()) >= 0
                                    ? null
                                    : const Color.fromARGB(
                                      255,
                                      218,
                                      86,
                                      76,
                                    ),
                          ),
                          "${(record.profit()) >= 0 ? '+' : ''}${formatMoneyBig(amount: record.profit(), context: context)}",
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TableRowRecordWidget extends StatefulWidget {
  const TableRowRecordWidget({
    super.key,
    required this.theme,
    required this.recordIndex,
    required this.record,
  });

  final ThemeProvider theme;
  final int recordIndex;
  final TempProductSaleRecord record;

  @override
  State<TableRowRecordWidget> createState() =>
      _TableRowRecordWidgetState();
}

class _TableRowRecordWidgetState
    extends State<TableRowRecordWidget> {
  String returnProfit() {
    if (widget.record.costPrice == null ||
        widget.record.costPrice == 0) {
      return "Nill";
    } else {
      return "${(widget.record.revenue - (widget.record.costPrice ?? 0)) >= 0 ? '+' : ''}${formatMoneyBig(amount: widget.record.revenue - (widget.record.costPrice ?? 0), context: context)}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey),
          left: BorderSide(color: Colors.grey),
          right: BorderSide(color: Colors.grey),
        ),
      ),
      child: Row(
        spacing: 0,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.all(5),
              child: Center(
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        style: TextStyle(
                          fontSize:
                              widget
                                  .theme
                                  .mobileTexts
                                  .b3
                                  .fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                        widget.recordIndex.toString(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                border: Border(
                  // right: BorderSide(
                  //   color: Colors.grey,
                  // ),
                  left: BorderSide(color: Colors.grey),
                ),
              ),
              child: Center(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        style: TextStyle(
                          fontSize:
                              widget
                                  .theme
                                  .mobileTexts
                                  .b3
                                  .fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                        widget.record.productName,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: Colors.grey),
                  left: BorderSide(color: Colors.grey),
                ),
              ),
              child: Center(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        style: TextStyle(
                          fontSize:
                              widget
                                  .theme
                                  .mobileTexts
                                  .b3
                                  .fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                        widget.record.quantity.toString(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 5,
            child: Container(
              padding: EdgeInsets.all(5),
              child: Center(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        style: TextStyle(
                          fontSize:
                              widget
                                  .theme
                                  .mobileTexts
                                  .b3
                                  .fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                        formatMoneyBig(
                          amount: widget.record.revenue,
                          context: context,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Visibility(
            visible: authorization(
              authorized: Authorizations().manageCostPrice,
            ),
            child: Expanded(
              flex: 5,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(color: Colors.grey),
                    left: BorderSide(color: Colors.grey),
                  ),
                ),
                padding: EdgeInsets.all(5),
                child: Center(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          style: TextStyle(
                            fontSize:
                                widget
                                    .theme
                                    .mobileTexts
                                    .b3
                                    .fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                          formatMoneyBig(
                            amount:
                                widget.record.costPrice ??
                                0,
                            context: context,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Visibility(
            visible: authorization(
              authorized: Authorizations().manageCostPrice,
            ),
            child: Expanded(
              flex: 5,
              child: Container(
                padding: EdgeInsets.all(5),
                child: Center(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          style: TextStyle(
                            fontSize:
                                widget
                                    .theme
                                    .mobileTexts
                                    .b3
                                    .fontSize,
                            fontWeight: FontWeight.bold,
                            color:
                                (widget.record.revenue -
                                            (widget
                                                    .record
                                                    .costPrice ??
                                                0)) >=
                                        0
                                    ? null
                                    : const Color.fromARGB(
                                      255,
                                      218,
                                      86,
                                      76,
                                    ),
                          ),
                          returnProfit(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
