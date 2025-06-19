import 'package:flutter/material.dart';
import 'package:stockall/classes/product_report_summary.dart';
import 'package:stockall/classes/temp_product_class.dart';
import 'package:stockall/classes/temp_product_sale_record.dart';
import 'package:stockall/components/calendar/calendar_widget.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/main.dart';
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
  late Future<List<TempProductSaleRecord>>
  productRecordFuture;
  Future<List<TempProductSaleRecord>>
  getProductRecord() async {
    var tempEx = await returnReceiptProvider(
      context,
      listen: false,
    ).loadProductSalesRecord(
      returnShopProvider(
        context,
        listen: false,
      ).userShop!.shopId!,
    );

    return tempEx;
  }

  late Future<List<TempProductClass>> productsFuture;
  Future<List<TempProductClass>> getProducts() async {
    var tempEx = await returnData(
      context,
      listen: false,
    ).getProducts(
      returnShopProvider(
        context,
        listen: false,
      ).userShop!.shopId!,
    );

    return tempEx;
  }

  List<ProductReportSummary> generateProductReportSummary(
    List<TempProductSaleRecord> records,
  ) {
    final Map<String, ProductReportSummary> summaryMap = {};

    for (var record in records) {
      final name = record.productName;

      if (summaryMap.containsKey(name)) {
        final existing = summaryMap[name]!;
        summaryMap[name] = ProductReportSummary(
          productName: name,
          quantity: existing.quantity + record.quantity,
          total: existing.total + record.revenue,
          costTotal:
              existing.costTotal + (record.costPrice ?? 0),
          profit:
              (existing.total + record.revenue) -
              (existing.costTotal +
                  (record.costPrice ?? 0)),
        );
      } else {
        summaryMap[name] = ProductReportSummary(
          productName: name,
          quantity: record.quantity,
          total: record.revenue,
          costTotal: record.costPrice ?? 0,
          profit:
              (record.revenue) - (record.costPrice ?? 0),
        );
      }
    }

    return summaryMap.values.toList();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      returnReportProvider(
        context,
        listen: false,
      ).clearDate(context);
    });
    productRecordFuture = getProductRecord();
    productsFuture = getProducts();
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    var salesRecords = returnReceiptProvider(
      context,
    ).returnproductsRecordByDayOrWeek(
      context,
      returnReceiptProvider(context).produtRecordSalesMain,
    );
    double getTotal() {
      double tempTotal = 0;
      for (var element in salesRecords) {
        tempTotal += element.revenue;
      }
      return tempTotal;
    }

    return Stack(
      children: [
        Scaffold(
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
                      child: Text('View Total Sales'),
                    ),
                    PopupMenuItem(
                      onTap: () {
                        setState(() {
                          isSummary = true;
                        });
                      },
                      child: Text('View Summary of Sales'),
                    ),
                  ];
                },
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(isSummary ? 'Summary' : 'Total'),
                    Icon(Icons.more_vert_rounded),
                  ],
                ),
              ),
            ),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15.0,
                ),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(width: 10),
                        Text(
                          returnReportProvider(
                                context,
                              ).dateSet ??
                              'For Today',
                        ),
                      ],
                    ),
                    Visibility(
                      visible:
                          userGeneral(context).role ==
                          'Owner',
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.end,
                        children: [
                          MaterialButton(
                            onPressed: () {
                              if (returnReportProvider(
                                    context,
                                    listen: false,
                                  ).isDateSet ||
                                  returnReportProvider(
                                    context,
                                    listen: false,
                                  ).setDate) {
                                returnReportProvider(
                                  context,
                                  listen: false,
                                ).clearDate(context);
                              } else {
                                returnReportProvider(
                                  context,
                                  listen: false,
                                ).openDatePicker();
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
                                  returnReportProvider(
                                            context,
                                          ).isDateSet ||
                                          returnReportProvider(
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
                                  returnReportProvider(
                                            context,
                                          ).isDateSet ||
                                          returnReportProvider(
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
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                  ),
                  child: SingleChildScrollView(
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
                                  150
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
                                  100
                              : MediaQuery.of(
                                context,
                              ).size.width,
                      // height:
                      //     MediaQuery.of(
                      //       context,
                      //     ).size.height -
                      //     200,
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey,
                              ),
                              color: Colors.grey.shade100,
                            ),
                            child: Row(
                              spacing: 0,
                              mainAxisAlignment:
                                  MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    padding:
                                        EdgeInsets.symmetric(
                                          horizontal: 3,
                                          vertical: 10,
                                        ),
                                    child: Center(
                                      child: Text(
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
                                        'S/N',
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 4,
                                  child: Container(
                                    padding:
                                        EdgeInsets.symmetric(
                                          horizontal: 5,
                                          vertical: 10,
                                        ),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        // right: BorderSide(
                                        //   color: Colors.grey,
                                        // ),
                                        left: BorderSide(
                                          color:
                                              Colors.grey,
                                        ),
                                      ),
                                    ),
                                    child: Center(
                                      child: Row(
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
                                            'Name',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    padding:
                                        EdgeInsets.symmetric(
                                          horizontal: 5,
                                          vertical: 10,
                                        ),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        right: BorderSide(
                                          color:
                                              Colors.grey,
                                        ),
                                        left: BorderSide(
                                          color:
                                              Colors.grey,
                                        ),
                                      ),
                                    ),
                                    child: Center(
                                      child: Row(
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
                                            'Quantity',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Container(
                                    padding:
                                        EdgeInsets.symmetric(
                                          horizontal: 5,
                                          vertical: 10,
                                        ),
                                    child: Center(
                                      child: Row(
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
                                            'Selling-Price',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible:
                                      salesRecords
                                          .isNotEmpty,
                                  child: Expanded(
                                    flex: 3,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border(
                                          right: BorderSide(
                                            color:
                                                Colors.grey,
                                          ),
                                          left: BorderSide(
                                            color:
                                                Colors.grey,
                                          ),
                                        ),
                                      ),
                                      padding:
                                          EdgeInsets.symmetric(
                                            horizontal: 5,
                                            vertical: 10,
                                          ),
                                      child: Center(
                                        child: Row(
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
                                              'Cost-Price',
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Visibility(
                                  visible:
                                      salesRecords
                                          .isNotEmpty,
                                  child: Expanded(
                                    flex: 3,
                                    child: Container(
                                      padding:
                                          EdgeInsets.symmetric(
                                            horizontal: 5,
                                            vertical: 10,
                                          ),
                                      child: Center(
                                        child: Row(
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
                                              'Profit/Loss',
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
                                        generateProductReportSummary(
                                          salesRecords,
                                        );
                                    return ListView.builder(
                                      shrinkWrap: true,
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
                                          theme: theme,
                                          recordIndex:
                                              recordIndex,
                                          record: record,
                                        );
                                      },
                                    );
                                  } else {
                                    // return Container();
                                    return ListView.builder(
                                      itemCount:
                                          salesRecords
                                              .length,
                                      itemBuilder: (
                                        context,
                                        index,
                                      ) {
                                        var record =
                                            salesRecords[index];
                                        var recordIndex =
                                            salesRecords
                                                .indexOf(
                                                  record,
                                                ) +
                                            1;

                                        return TableRowRecordWidget(
                                          theme: theme,
                                          recordIndex:
                                              recordIndex,
                                          record: record,
                                        );
                                      },
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
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                  color: Colors.grey.shade100,
                ),
                padding: EdgeInsets.fromLTRB(
                  30,
                  15,
                  30,
                  25,
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 5,
                    horizontal: 5,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.grey,
                      ),
                      top: BorderSide(color: Colors.grey),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total'),
                      Text(
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize:
                              theme.mobileTexts.h4.fontSize,
                        ),
                        formatMoneyBig(getTotal()),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (returnReportProvider(context).setDate)
          Material(
            color: const Color.fromARGB(75, 0, 0, 0),
            child: GestureDetector(
              onTap: () {
                returnReportProvider(
                  context,
                  listen: false,
                ).clearDate(context);
              },
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                  ),
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height:
                            MediaQuery.of(
                              context,
                            ).size.height *
                            0.2,
                      ),
                      Ink(
                        color: Colors.white,
                        child: Container(
                          padding: EdgeInsets.only(
                            top: 20,
                            bottom: 20,
                          ),
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(10),
                            color: Colors.white,
                          ),
                          child: Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(
                                    horizontal: 5.0,
                                  ),
                              child: Column(
                                children: [
                                  Container(
                                    width: 100,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color:
                                          Colors
                                              .grey
                                              .shade400,
                                      borderRadius:
                                          BorderRadius.circular(
                                            5,
                                          ),
                                    ),
                                  ),
                                  SizedBox(height: 20),
                                  Container(
                                    height: 480,
                                    width: 380,
                                    padding: EdgeInsets.all(
                                      15,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(
                                            10,
                                          ),
                                      color: Colors.white,
                                      // border: Border.all(
                                      //   color:
                                      //       Colors
                                      //           .grey,
                                      // ),
                                    ),
                                    child: CalendarWidget(
                                      onDaySelected: (
                                        selectedDay,
                                        focusedDay,
                                      ) {
                                        returnReportProvider(
                                          context,
                                          listen: false,
                                        ).setDay(
                                          context,
                                          selectedDay,
                                        );
                                      },
                                      actionWeek: (
                                        startOfWeek,
                                        endOfWeek,
                                      ) {
                                        returnReportProvider(
                                          context,
                                          listen: false,
                                        ).setWeek(
                                          context,
                                          startOfWeek,
                                          endOfWeek,
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height:
                            MediaQuery.of(
                              context,
                            ).size.height *
                            0.4,
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

class TableRowRecordWidgetSummary extends StatelessWidget {
  const TableRowRecordWidgetSummary({
    super.key,
    required this.theme,
    required this.recordIndex,
    required this.record,
  });

  final ThemeProvider theme;
  final int recordIndex;
  final ProductReportSummary record;

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
            flex: 1,
            child: Container(
              padding: EdgeInsets.all(5),
              child: Center(
                child: Text(
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b3.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  recordIndex.toString(),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 4,
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
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b3.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                      record.productName,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
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
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b3.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                      record.quantity.toString(),
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
              child: Center(
                child: Row(
                  children: [
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b3.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                      formatMoneyMid(record.total),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
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
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b3.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                      formatMoneyMid(record.costTotal),
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
              child: Center(
                child: Row(
                  children: [
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b3.fontSize,
                        fontWeight: FontWeight.bold,
                        color:
                            (record.profit) >= 0
                                ? null
                                : const Color.fromARGB(
                                  255,
                                  218,
                                  86,
                                  76,
                                ),
                      ),
                      "${(record.profit) >= 0 ? '+' : ''}${formatMoneyMid(record.profit)}",
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TableRowRecordWidget extends StatelessWidget {
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
            flex: 1,
            child: Container(
              padding: EdgeInsets.all(5),
              child: Center(
                child: Text(
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b3.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  recordIndex.toString(),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 4,
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
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b3.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                      record.productName,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
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
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b3.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                      record.quantity.toString(),
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
              child: Center(
                child: Row(
                  children: [
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b3.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                      formatMoneyMid(record.revenue),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
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
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b3.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                      formatMoneyMid(record.costPrice ?? 0),
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
              child: Center(
                child: Row(
                  children: [
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b3.fontSize,
                        fontWeight: FontWeight.bold,
                        color:
                            (record.revenue -
                                        (record.costPrice ??
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
                      "${(record.revenue - (record.costPrice ?? 0)) >= 0 ? '+' : ''}${formatMoneyMid(record.revenue - (record.costPrice ?? 0))}",
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
