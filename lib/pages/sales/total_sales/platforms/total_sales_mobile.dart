import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_main_receipt.dart';
import 'package:stockall/classes/temp_product_sale_record.dart';
import 'package:stockall/components/calendar/calendar_widget.dart';
import 'package:stockall/components/list_tiles/main_receipt_tile.dart';
import 'package:stockall/components/major/empty_widget_display.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/sales/make_sales/page1/make_sales_page.dart';

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
        appBar: appBar(
          context: context,
          title: 'All Sales',
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
                height: 30,
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
                                  Visibility(
                                    visible:
                                        returnLocalDatabase(
                                              context,
                                            )
                                            .currentEmployee!
                                            .role !=
                                        'Owner',
                                    child: SizedBox(
                                      height: 30,
                                    ),
                                  ),
                                  Visibility(
                                    visible:
                                        returnLocalDatabase(
                                              context,
                                            )
                                            .currentEmployee!
                                            .role ==
                                        'Owner',
                                    child: Row(
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
                                      padding:
                                          EdgeInsets.all(
                                            20,
                                          ),
                                      color: Colors.white,

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
                      formatMoney(value),
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
