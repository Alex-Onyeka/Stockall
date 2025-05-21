import 'package:flutter/material.dart';
import 'package:stockitt/classes/temp_main_receipt.dart';
import 'package:stockitt/classes/temp_product_sale_record.dart';
import 'package:stockitt/components/calendar/calendar_widget.dart';
import 'package:stockitt/components/list_tiles/main_receipt_tile.dart';
import 'package:stockitt/components/major/empty_widget_display.dart';
import 'package:stockitt/components/major/empty_widget_display_only.dart';
import 'package:stockitt/constants/calculations.dart';
import 'package:stockitt/main.dart';
import 'package:stockitt/pages/sales/make_sales/page1/make_sales_page.dart';

class TotalSalesMobile extends StatefulWidget {
  const TotalSalesMobile({super.key});

  @override
  State<TotalSalesMobile> createState() =>
      _TotalSalesMobileState();
}

class _TotalSalesMobileState
    extends State<TotalSalesMobile> {
  Future<List<TempMainReceipt>> getMainReceipts() {
    var tempReceipts = returnReceiptProvider(
      context,
      listen: false,
    ).loadReceipts(
      returnShopProvider(
        context,
        listen: false,
      ).userShop!.shopId!,
    );

    return tempReceipts;
  }

  late Future<List<TempMainReceipt>> mainReceiptFuture;

  @override
  void initState() {
    super.initState();
    mainReceiptFuture = getMainReceipts();
    getProdutRecordsFuture = getProductSalesRecord();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      clearDate();
    });
  }

  void clearDate() {
    returnReceiptProvider(
      context,
      listen: false,
    ).clearReceiptDate();
  }

  late Future<List<TempProductSaleRecord>>
  getProdutRecordsFuture;
  Future<List<TempProductSaleRecord>>
  getProductSalesRecord() async {
    var tempRecords = await returnReceiptProvider(
      context,
      listen: false,
    ).loadProductSalesRecord(
      returnShopProvider(
        context,
        listen: false,
      ).userShop!.shopId!,
    );

    return tempRecords
        .where(
          (beans) =>
              beans.shopId ==
              returnShopProvider(
                context,
                listen: false,
              ).userShop!.shopId!,
        )
        .toList();
  }

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
        appBar: AppBar(
          toolbarHeight: 60,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Padding(
              padding: const EdgeInsets.only(
                left: 20.0,
                right: 10,
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded),
            ),
          ),
          centerTitle: true,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                style: TextStyle(
                  fontSize: theme.mobileTexts.h4.fontSize,
                  fontWeight: FontWeight.bold,
                ),
                returnReceiptProvider(context).dateSet ??
                    'Todays Sales Receipts',
              ),
            ],
          ),
        ),
        body: FutureBuilder(
          future: mainReceiptFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return returnCompProvider(
                context,
                listen: false,
              ).showLoader('Loading');
            } else if (snapshot.hasError) {
              return EmptyWidgetDisplayOnly(
                title: 'An Error Occured',
                subText:
                    'Couldn\'t load your data because an error occured. Check your internet connection and try again.',
                theme: theme,
                height: 35,
              );
            } else {
              var mainReceipts = returnReceiptProvider(
                context,
                listen: false,
              ).returnOwnReceiptsByDayOrWeek(
                context,
                snapshot.data!,
              );
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
                          child: FutureBuilder<
                            List<TempProductSaleRecord>
                          >(
                            future: getProdutRecordsFuture,
                            builder: (context, snapshot) {
                              return Column(
                                children: [
                                  snapshot.connectionState ==
                                          ConnectionState
                                              .waiting
                                      ? Row(
                                        spacing: 10,
                                        children: [
                                          ValueSummaryTabSmall(
                                            color:
                                                Colors
                                                    .amber,
                                            isMoney: true,
                                            title:
                                                'Total Revenue',
                                            value: 2000,
                                          ),
                                          ValueSummaryTabSmall(
                                            value: 2000,
                                            title:
                                                'Sales Number',
                                            color:
                                                Colors
                                                    .green,
                                            isMoney: false,
                                          ),
                                        ],
                                      )
                                      : snapshot.hasError
                                      ? Row(
                                        spacing: 10,
                                        children: [
                                          ValueSummaryTabSmall(
                                            color:
                                                Colors
                                                    .amber,
                                            isMoney: true,
                                            title:
                                                'Total Revenue',
                                            value: 2000,
                                          ),
                                          ValueSummaryTabSmall(
                                            value: 2000,
                                            title:
                                                'Sales Number',
                                            color:
                                                Colors
                                                    .green,
                                            isMoney: false,
                                          ),
                                        ],
                                      )
                                      : Row(
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
                                            ).getTotalRevenueForSelectedDay(
                                              context,
                                              mainReceipts,
                                              snapshot
                                                  .data!,
                                            ),
                                          ),
                                          ValueSummaryTabSmall(
                                            value:
                                                mainReceipts
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
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .end,
                                    children: [
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
                                              listen: false,
                                            ).clearReceiptDate();
                                          } else {
                                            returnReceiptProvider(
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
                                                    FontWeight
                                                        .bold,
                                                color:
                                                    Colors
                                                        .grey
                                                        .shade700,
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
                                              size: 20,
                                              color:
                                                  theme
                                                      .lightModeColor
                                                      .secColor100,
                                              returnReceiptProvider(
                                                        context,
                                                      ).isDateSet ||
                                                      returnReceiptProvider(
                                                        context,
                                                      ).setDate
                                                  ? Icons
                                                      .clear
                                                  : Icons
                                                      .date_range_outlined,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        Expanded(
                          child: Builder(
                            builder: (context) {
                              if (mainReceipts.isEmpty) {
                                return EmptyWidgetDisplay(
                                  title: 'Empty List',
                                  subText:
                                      'You don\'t have any Sales under this category',
                                  buttonText: 'Create Sale',
                                  icon: Icons.clear,
                                  theme: theme,
                                  height: 35,
                                  action: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return MakeSalesPage();
                                        },
                                      ),
                                    );
                                  },
                                );
                              } else {
                                return ListView.builder(
                                  itemCount:
                                      mainReceipts.length,
                                  itemBuilder: (
                                    context,
                                    index,
                                  ) {
                                    var receipt =
                                        mainReceipts[index];
                                    return MainReceiptTile(
                                      key: ValueKey(
                                        receipt.id,
                                      ),
                                      mainReceipt: receipt,
                                    );
                                  },
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
                    Positioned(
                      top: 40,
                      left: 0,
                      right: 0,
                      child: Material(
                        child: Ink(
                          color: Colors.white,
                          child: Container(
                            padding: EdgeInsets.only(
                              top: 40,
                              bottom: 40,
                            ),
                            color: Colors.white,
                            child: Center(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(
                                      horizontal: 15.0,
                                    ),
                                child: Container(
                                  height: 430,
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
                                    border: Border.all(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  child: CalendarWidget(
                                    onDaySelected: (
                                      selectedDay,
                                      focusedDay,
                                    ) {
                                      returnReceiptProvider(
                                        context,
                                        listen: false,
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
                                        listen: false,
                                      ).setReceiptWeek(
                                        startOfWeek,
                                        endOfWeek,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            }
          },
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
          horizontal: 20,
          vertical: 15,
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
                      visible: isMoney,
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
                      formatLargeNumberDouble(value),
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
