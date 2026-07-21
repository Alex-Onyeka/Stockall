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
import 'package:stockall/pages/report/item_sales/components/generate_section_widget.dart';
import 'package:stockall/pages/report/item_sales/components/summary_table_heading_bar.dart';
import 'package:stockall/pages/report/item_sales/components/table_row_record_widget.dart';
import 'package:stockall/pages/report/item_sales/components/table_row_record_widget_summary.dart';
import 'package:stockall/pages/report/item_sales/platforms/components/departments_section_list_widget.dart';
import 'package:stockall/pages/report/item_sales/platforms/components/total_sales_list_widget.dart';
import 'package:stockall/providers/theme_provider.dart';

class ItemSalesReportMobile extends StatefulWidget {
  const ItemSalesReportMobile({super.key});

  @override
  State<ItemSalesReportMobile> createState() =>
      _ItemSalesReportMobileState();
}

class _ItemSalesReportMobileState
    extends State<ItemSalesReportMobile> {
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
    salesRecords.sort((a, b) {
      if (sortIndex == 1) {
        return a.productName.toLowerCase().compareTo(
          b.productName.toLowerCase(),
        );
      } else if (sortIndex == 2) {
        return b.quantity.compareTo(a.quantity);
      } else if (sortIndex == 3) {
        return b.revenue.compareTo(a.revenue);
      } else if (sortIndex == 4) {
        return (b.revenue - (b.costPrice ?? 0)).compareTo(
          (a.revenue - (a.costPrice ?? 0)),
        );
      } else if (sortIndex == 5) {
        return b.createdAt.compareTo(a.createdAt);
      } else {
        return a.productName.compareTo(b.productName);
      }
    });
    var summary =
        returnReceiptProviderSingle()
            .returnGeneralReportSalesSummary();
    summary.sort((a, b) {
      switch (sortIndex) {
        case 1:
          return a.itemName.toLowerCase().compareTo(
            b.itemName.toLowerCase(),
          );
        case 2:
          return b.quantity.compareTo(a.quantity);
        case 3:
          return b.totalCost.compareTo(a.totalCost);
        case 4:
          return b.profit().compareTo(a.profit());
        default:
          return a.itemName.compareTo(b.itemName);
      }
    });
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
                    Visibility(
                      visible: salesRecords.isNotEmpty,
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.end,
                        children: [
                          InkWell(
                            onTap: () {
                              generatePrintAction(
                                context,
                                summary,
                                theme,
                                salesRecords,
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
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
                                          FontWeight.bold,
                                    ),
                                    'Generate',
                                  ),
                                  Icon(
                                    size: 20,
                                    color: Colors.grey,
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
                            isSummary: isSummary,
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

  Future<Object?> generatePrintAction(
    BuildContext context,
    List<GeneralReportSalesSummaryItem> summary,
    ThemeProvider theme,
    List<TempProductSaleRecord> salesRecords,
  ) {
    return showGeneralDialog(
      barrierColor: Colors.white,

      context: context,
      pageBuilder: (
        context,
        animation,
        secondaryAnimation,
      ) {
        return Material(
          color: Colors.transparent,
          child: SizedBox(
            height: screenHeight(context),
            width: screenWidth(context),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                5,
                0,
                5,
                5,
              ),
              child: Column(
                children: [
                  appBar(
                    context: context,
                    title: 'Total Sales',
                    backAction: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: ListView(
                      // spacing: 10,
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(
                                vertical: 5,
                                horizontal: 10,
                              ),
                          child: GenerateSectionWidget(
                            title: 'All Sales',
                            widget: TotalSalesListWidget(
                              isSummary: isSummary,
                              summary: summary,
                              theme: theme,
                              salesRecords: salesRecords,
                            ),
                          ),
                        ),
                        Visibility(
                          visible:
                              returnShopProvider()
                                  .userShop()
                                  ?.manageDepartments !=
                              false,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(
                                  vertical: 5,
                                  horizontal: 10,
                                ),
                            child: GenerateSectionWidget(
                              title: 'Department Summary',
                              widget:
                                  DepartmentsSectionListWidget(
                                    summary: summary,
                                    theme: theme,
                                    salesRecords:
                                        salesRecords,
                                  ),
                            ),
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(
                                vertical: 5,
                                horizontal: 10,
                              ),
                          child: GenerateSectionWidget(
                            title: 'Calculation',
                            widget: Padding(
                              padding:
                                  const EdgeInsets.symmetric(
                                    horizontal: 10.0,
                                  ),
                              child: Column(
                                spacing: 5,
                                children: [
                                  SizedBox(height: 30),
                                  Container(
                                    height: 6,
                                    color: Colors.amber,
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.all(
                                          8.0,
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
                                            fontWeight:
                                                FontWeight
                                                    .bold,
                                          ),
                                          'TOTAL SALES:',
                                        ),
                                        Text(
                                          style: TextStyle(
                                            fontSize:
                                                theme
                                                    .mobileTexts
                                                    .b1
                                                    .fontSize,
                                            fontWeight:
                                                FontWeight
                                                    .bold,
                                          ),
                                          formatMoneyBig(
                                            amount:
                                                returnReceiptProviderSingle()
                                                    .getTotalSalesRevenue(),
                                            context:
                                                context,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Visibility(
                                    visible:
                                        returnShopProvider()
                                            .userShop()
                                            ?.manageDepartments !=
                                        false,
                                    child: Column(
                                      spacing: 5,
                                      children: [
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Container(
                                          height: 6,
                                          color:
                                              Colors.amber,
                                        ),
                                        SizedBox(height: 5),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment
                                                  .center,
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
                                              'Departments',
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 5),
                                        Divider(
                                          color:
                                              Colors.grey,
                                          height: 0,
                                        ),
                                        Column(
                                          children:
                                              returnDepartmentProvider()
                                                  .departments
                                                  .where((
                                                    item,
                                                  ) {
                                                    for (var rec
                                                        in salesRecords) {
                                                      if (rec.departmentUuid ==
                                                          item.uuid) {
                                                        return true;
                                                      }
                                                    }
                                                    return false;
                                                  })
                                                  .map((
                                                    dept,
                                                  ) {
                                                    return Padding(
                                                      padding: const EdgeInsets.all(
                                                        8.0,
                                                      ),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Text(
                                                            style: TextStyle(
                                                              fontSize:
                                                                  theme.mobileTexts.b3.fontSize,
                                                              fontWeight:
                                                                  FontWeight.bold,
                                                            ),
                                                            "${dept.name}:",
                                                          ),
                                                          Text(
                                                            style: TextStyle(
                                                              fontSize:
                                                                  theme.mobileTexts.b3.fontSize,
                                                              fontWeight:
                                                                  FontWeight.bold,
                                                            ),
                                                            formatMoneyBig(
                                                              amount: returnReceiptProviderSingle().getTotalSalesRevenueForDepartment(
                                                                deptUuid:
                                                                    dept.uuid,
                                                              ),
                                                              context:
                                                                  context,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    );
                                                  })
                                                  .toList(),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.fromLTRB(
                                                8.0,
                                                5,
                                                8,
                                                8,
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
                                                          .b3
                                                          .fontSize,
                                                  fontWeight:
                                                      FontWeight
                                                          .bold,
                                                ),
                                                "No Department:",
                                              ),
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
                                                formatMoneyBig(
                                                  amount:
                                                      returnReceiptProviderSingle()
                                                          .getTotalSalesRevenueNoDepartment(),
                                                  context:
                                                      context,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.fromLTRB(
                                                8.0,
                                                5,
                                                8,
                                                8,
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
                                                          .b3
                                                          .fontSize,
                                                  fontWeight:
                                                      FontWeight
                                                          .bold,
                                                ),
                                                "Deleted Sales:",
                                              ),
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
                                                formatMoneyBig(
                                                  amount:
                                                      returnReceiptProviderSingle()
                                                          .getTotalSalesRevenueVoid(),
                                                  context:
                                                      context,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // MainButtonTransparent(
                                  //   themeProvider: theme,
                                  //   constraints:
                                  //       BoxConstraints(),
                                  //   text: 'Download',
                                  //   action: () {
                                  //     showDialog(
                                  //       context: context,
                                  //       builder: (
                                  //         confirmContext,
                                  //       ) {
                                  //         return ConfirmationAlert(
                                  //           theme: theme,
                                  //           message:
                                  //               'You are about to download this Record, Are you sure you want to proceed?',
                                  //           title:
                                  //               'Download Record',
                                  //           action: () {
                                  //             Navigator.of(
                                  //               confirmContext,
                                  //             ).pop();
                                  //           },
                                  //         );
                                  //       },
                                  //     );
                                  //   },
                                  // ),
                                  // SizedBox(height: 3),
                                  // MainButtonP(
                                  //   themeProvider: theme,
                                  //   action: () {
                                  //     showDialog(
                                  //       context: context,
                                  //       builder: (
                                  //         firstContext,
                                  //       ) {
                                  //         return ConfirmationAlert(
                                  //           theme: theme,
                                  //           message:
                                  //               'You are about to Print This Record. Are you sure you want to Proceed?',
                                  //           title:
                                  //               'Print Record',
                                  //           action: () async {
                                  //             Navigator.of(
                                  //               firstContext,
                                  //             ).pop();
                                  //             if (kIsWeb) {
                                  //               downloadItemSalesPdfWebRoll(
                                  //                 records:
                                  //                     summary,
                                  //                 filename:
                                  //                     'Stockall_Item_Sales_${DateTime.now().millisecondsSinceEpoch}.pdf',
                                  //                 context:
                                  //                     context,
                                  //               );
                                  //             } else {
                                  //               await generateAndPreviewItemSalesPdfRoll(
                                  //                 records:
                                  //                     summary,
                                  //                 context:
                                  //                     context,
                                  //               );
                                  //             }
                                  //           },
                                  //         );
                                  //       },
                                  //     );
                                  //   },
                                  //   text: 'Print',
                                  // ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
