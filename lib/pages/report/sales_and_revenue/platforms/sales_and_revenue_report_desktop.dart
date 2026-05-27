import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_product_slaes_record/temp_product_sale_record.dart';
import 'package:stockall/components/major/desktop_center_container.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/date_picker_function.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/refresh_functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/report/sales_and_revenue/components/generate_section_widget.dart';
import 'package:stockall/pages/report/sales_and_revenue/components/summary_table_heading_bar.dart';
import 'package:stockall/pages/report/sales_and_revenue/components/table_row_record_widget.dart';
import 'package:stockall/pages/report/sales_and_revenue/components/table_row_record_widget_summary.dart';

class SalesAndRevenueReportDesktop extends StatefulWidget {
  const SalesAndRevenueReportDesktop({super.key});

  @override
  State<SalesAndRevenueReportDesktop> createState() =>
      _SalesAndRevenueReportDesktopState();
}

class _SalesAndRevenueReportDesktopState
    extends State<SalesAndRevenueReportDesktop> {
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
      returnReceiptProviderSingle().clearDate();
      returnSalesProvider().toggleIsLoading(false);
    });
    productRecordFuture = getProductRecord();
    productsFuture = getProducts();
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    List<TempProductSaleRecord> salesRecords =
        returnReceiptProvider(
          context,
        ).returnProductsRecordByDayOrWeek();
    salesRecords.sort((a, b) {
      if (sortIndex == 1) {
        return a.productName.compareTo(b.productName);
      } else if (sortIndex == 2) {
        return a.quantity.compareTo(b.quantity);
      } else if (sortIndex == 3) {
        return a.revenue.compareTo(b.revenue);
      } else {
        return a.productName.compareTo(b.productName);
      }
    });

    return Stack(
      children: [
        DesktopCenterContainer(
          width: screenWidth(context) - 50,
          mainWidget: Scaffold(
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
                                theme
                                    .mobileTexts
                                    .b2
                                    .fontSize,
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
                                theme
                                    .mobileTexts
                                    .b2
                                    .fontSize,
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
                                theme
                                    .mobileTexts
                                    .b2
                                    .fontSize,
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
                                theme
                                    .mobileTexts
                                    .b2
                                    .fontSize,
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
                                theme
                                    .mobileTexts
                                    .b2
                                    .fontSize,
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
                                theme
                                    .mobileTexts
                                    .b2
                                    .fontSize,
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
                                theme
                                    .mobileTexts
                                    .b2
                                    .fontSize,
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
                    mainAxisAlignment:
                        MainAxisAlignment.center,
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
                                  theme
                                      .mobileTexts
                                      .b2
                                      .fontSize,
                            ),
                            isSummary ? 'Summary' : 'Total',
                          ),
                          Text(
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b4
                                      .fontSize,
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
                          Visibility(
                            visible:
                                salesRecords.isNotEmpty,
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.end,
                              children: [
                                InkWell(
                                  onTap: () {
                                    showGeneralDialog(
                                      barrierColor:
                                          Colors.white,

                                      context: context,
                                      pageBuilder: (
                                        context,
                                        animation,
                                        secondaryAnimation,
                                      ) {
                                        return Material(
                                          color:
                                              Colors
                                                  .transparent,
                                          child: SizedBox(
                                            height:
                                                screenHeight(
                                                  context,
                                                ),
                                            width:
                                                screenWidth(
                                                  context,
                                                ),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.fromLTRB(
                                                    20,
                                                    0,
                                                    20,
                                                    10,
                                                  ),
                                              child: Column(
                                                children: [
                                                  appBar(
                                                    context:
                                                        context,
                                                    title:
                                                        'Total Sales',
                                                    backAction: () {
                                                      Navigator.of(
                                                        context,
                                                      ).pop();
                                                    },
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.center,
                                                    spacing:
                                                        5,
                                                    children: [
                                                      Expanded(
                                                        child:
                                                            GenerateSectionWidget(),
                                                      ),
                                                      Expanded(
                                                        child:
                                                            GenerateSectionWidget(),
                                                      ),
                                                      Expanded(
                                                        child:
                                                            GenerateSectionWidget(),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                  child: Container(
                                    padding:
                                        EdgeInsets.symmetric(
                                          horizontal: 10,
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
                                            color:
                                                Colors
                                                    .grey
                                                    .shade700,
                                            fontWeight:
                                                FontWeight
                                                    .bold,
                                          ),
                                          'Generate',
                                        ),
                                        Icon(
                                          size: 20,
                                          color:
                                              Colors.grey,
                                          Icons.print,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

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
                                              .setDate(
                                                date!,
                                              );
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
                                              FontWeight
                                                  .bold,
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
                    SizedBox(height: 15),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10.0,
                        ),
                        child: SingleChildScrollView(
                          primary: false,
                          scrollDirection: Axis.horizontal,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(
                                  horizontal: 10.0,
                                ),
                            child: SizedBox(
                              width:
                                  salesRecords.isEmpty &&
                                          screenWidth(
                                                context,
                                              ) <
                                              tabletScreen
                                      ? screenWidth(context)
                                      : salesRecords
                                              .isEmpty &&
                                          screenWidth(
                                                context,
                                              ) >
                                              tabletScreen
                                      ? screenWidth(
                                            context,
                                          ) -
                                          100
                                      : salesRecords
                                              .isNotEmpty &&
                                          screenWidth(
                                                context,
                                              ) <=
                                              750
                                      ? screenWidth(
                                            context,
                                          ) +
                                          130
                                      : screenWidth(
                                            context,
                                          ) -
                                          200,
                              child: Column(
                                children: [
                                  SummaryTableHeadingBar(
                                    isSummary: isSummary,
                                    isHeading: true,
                                    theme: theme,
                                    salesRecords:
                                        salesRecords,
                                  ),
                                  Expanded(
                                    child: Builder(
                                      builder: (context) {
                                        if (salesRecords
                                            .isEmpty) {
                                          return EmptyWidgetDisplayOnly(
                                            title:
                                                'Empty List',
                                            subText:
                                                'No Sales Recorded Yet',
                                            theme: theme,
                                            height: 35,
                                            icon:
                                                Icons.clear,
                                          );
                                        } else {
                                          if (isSummary) {
                                            var summary =
                                                returnReceiptProviderSingle()
                                                    .returnGeneralReportSalesSummary();
                                            summary.sort((
                                              a,
                                              b,
                                            ) {
                                              switch (sortIndex) {
                                                case 1:
                                                  return a
                                                      .itemName
                                                      .compareTo(
                                                        b.itemName,
                                                      );
                                                case 2:
                                                  return b
                                                      .quantity
                                                      .compareTo(
                                                        a.quantity,
                                                      );
                                                case 3:
                                                  return b
                                                      .totalCost
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
                                                  return a
                                                      .itemName
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
                                                  Colors
                                                      .white,
                                              color:
                                                  theme
                                                      .lightModeColor
                                                      .prColor300,
                                              displacement:
                                                  10,
                                              child: ListView(
                                                children: [
                                                  ListView.builder(
                                                    physics:
                                                        NeverScrollableScrollPhysics(),
                                                    shrinkWrap:
                                                        true,
                                                    itemCount:
                                                        summary.length,
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
                                                        isSummary:
                                                            isSummary,
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
                                                    isSummary:
                                                        isSummary,
                                                    isHeading:
                                                        false,
                                                    theme:
                                                        theme,
                                                    salesRecords:
                                                        salesRecords,
                                                  ),
                                                  SizedBox(
                                                    height:
                                                        20,
                                                  ),
                                                ],
                                              ),
                                            );
                                          } else {
                                            // return Container();
                                            return RefreshIndicator(
                                              onRefresh: () {
                                                return RefreshFunctions(
                                                  context,
                                                ).refreshReceipts(
                                                  context,
                                                );
                                              },
                                              backgroundColor:
                                                  Colors
                                                      .white,
                                              color:
                                                  theme
                                                      .lightModeColor
                                                      .prColor300,
                                              displacement:
                                                  10,
                                              child: ListView(
                                                children: [
                                                  ListView.builder(
                                                    shrinkWrap:
                                                        true,
                                                    itemCount:
                                                        salesRecords.length,
                                                    physics:
                                                        NeverScrollableScrollPhysics(),

                                                    itemBuilder: (
                                                      context,
                                                      index,
                                                    ) {
                                                      var record =
                                                          salesRecords[index];
                                                      var recordIndex =
                                                          salesRecords.indexOf(
                                                            record,
                                                          ) +
                                                          1;

                                                      return TableRowRecordWidget(
                                                        isSummary:
                                                            isSummary,
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
                                                    isSummary:
                                                        isSummary,
                                                    isHeading:
                                                        false,
                                                    theme:
                                                        theme,
                                                    salesRecords:
                                                        salesRecords,
                                                  ),
                                                  SizedBox(
                                                    height:
                                                        20,
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
          ),
        ),
      ],
    );
  }
}
