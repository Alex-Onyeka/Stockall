import 'package:flutter/material.dart';
import 'package:stockitt/classes/temp_main_receipt.dart';
import 'package:stockitt/classes/temp_notification.dart';
import 'package:stockitt/classes/temp_product_sale_record.dart';
import 'package:stockitt/components/calendar/calendar_widget.dart';
import 'package:stockitt/components/list_tiles/main_receipt_tile.dart';
import 'package:stockitt/components/major/empty_widget_display.dart';
import 'package:stockitt/components/major/empty_widget_display_only.dart';
import 'package:stockitt/components/major/items_summary.dart';
import 'package:stockitt/components/major/my_drawer_widget.dart';
import 'package:stockitt/components/major/top_banner.dart';
import 'package:stockitt/constants/constants_main.dart';
import 'package:stockitt/main.dart';
import 'package:stockitt/pages/dashboard/components/main_bottom_nav.dart';
import 'package:stockitt/pages/sales/make_sales/page1/make_sales_page.dart';
import 'package:stockitt/pages/sales/total_sales/total_sales_page.dart';

class SalesPageMobile extends StatefulWidget {
  const SalesPageMobile({super.key});

  @override
  State<SalesPageMobile> createState() =>
      _SalesPageMobileState();
}

class _SalesPageMobileState extends State<SalesPageMobile> {
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
    // Defer clearDate until after first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      clearDate();
    });

    mainReceiptFuture = getMainReceipts();
    getProdutRecordsFuture = getProductSalesRecord();
    notificationsFuture = fetchNotifications();
  }

  late Future<List<TempNotification>> notificationsFuture;

  Future<List<TempNotification>>
  fetchNotifications() async {
    var tempGet = await returnNotificationProvider(
      context,
      listen: false,
    ).fetchRecentNotifications(
      returnShopProvider(
        context,
        listen: false,
      ).userShop!.shopId!,
    );

    return tempGet;
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

  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();

  void clearDate() {
    returnReceiptProvider(
      context,
      listen: false,
    ).clearReceiptDate();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    mainReceiptFuture = getMainReceipts();
    getProdutRecordsFuture = getProductSalesRecord();
  }

  @override
  Widget build(BuildContext context) {
    clearDate();
    var theme = returnTheme(context);
    return Scaffold(
      key: _scaffoldKey,
      bottomNavigationBar: MainBottomNav(
        globalKey: _scaffoldKey,
      ),
      onDrawerChanged: (isOpened) {
        if (!isOpened) {
          returnNavProvider(
            context,
            listen: false,
          ).closeDrawer();
        }
      },
      drawer: FutureBuilder<List<TempNotification>>(
        future: notificationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return MyDrawerWidget(
              theme: theme,
              notifications: [],
            );
          } else if (snapshot.hasError) {
            return MyDrawerWidget(
              theme: theme,
              notifications: [],
            );
          } else {
            List<TempNotification> notifications =
                snapshot.data!;

            return MyDrawerWidget(
              theme: theme,
              notifications: notifications,
            );
          }
        },
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
            return SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Stack(
                children: [
                  Column(
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: SizedBox(
                          height: 300,
                          child: Stack(
                            children: [
                              TopBanner(
                                subTitle:
                                    'Data of All Sales Records',
                                title: 'Sales',
                                theme: theme,
                                bottomSpace: 100,
                                topSpace: 20,
                                iconSvg: salesIconSvg,
                              ),
                              Align(
                                alignment: Alignment(0, 1),
                                child: InkWell(
                                  onTap: () {
                                    returnReceiptProvider(
                                      context,
                                      listen: false,
                                    ).clearReceiptDate();
                                  },
                                  child: FutureBuilder<
                                    List<
                                      TempProductSaleRecord
                                    >
                                  >(
                                    future:
                                        getProdutRecordsFuture,
                                    builder: (
                                      context,
                                      snapshot,
                                    ) {
                                      if (snapshot
                                              .connectionState ==
                                          ConnectionState
                                              .waiting) {
                                        return ItemsSummary(
                                          isFilter: true,
                                          isMoney1: true,
                                          mainTitle:
                                              'Sales Record Summary',
                                          subTitle:
                                              returnReceiptProvider(
                                                context,
                                              ).dateSet ??
                                              'For Today',
                                          firsRow: true,
                                          color1:
                                              Colors.green,
                                          title1:
                                              'Sales Revenue',
                                          value1: 0,

                                          color2:
                                              Colors.amber,
                                          title2:
                                              'Sales Number',
                                          value2:
                                              mainReceipts
                                                  .length
                                                  .toDouble(),
                                          secondRow: false,
                                          onSearch: false,
                                          filterAction: () {
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
                                        );
                                      } else if (snapshot
                                          .hasError) {
                                        return Container(
                                          height: 100,
                                          width: 200,
                                          color:
                                              Colors.amber,
                                        );
                                      } else {
                                        List<
                                          TempProductSaleRecord
                                        >
                                        records =
                                            snapshot.data!;
                                        return ItemsSummary(
                                          isFilter: true,
                                          isMoney1: true,
                                          mainTitle:
                                              'Sales Record Summary',
                                          subTitle:
                                              returnReceiptProvider(
                                                context,
                                              ).dateSet ??
                                              'For Today',
                                          firsRow: true,
                                          color1:
                                              Colors.green,
                                          title1:
                                              'Sales Revenue',
                                          value1: returnReceiptProvider(
                                            context,
                                          ).getTotalRevenueForSelectedDay(
                                            context,
                                            mainReceipts,
                                            records,
                                          ),
                                          color2:
                                              Colors.amber,
                                          title2:
                                              'Sales Number',
                                          value2:
                                              mainReceipts
                                                  .length
                                                  .toDouble(),
                                          secondRow: false,
                                          onSearch: false,
                                          filterAction: () {
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
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ),
                              //
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: SizedBox(
                          child: Padding(
                            padding:
                                const EdgeInsets.fromLTRB(
                                  10.0,
                                  15,
                                  10,
                                  15,
                                ),
                            child: Column(
                              children: [
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(
                                        horizontal: 20.0,
                                      ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .spaceBetween,
                                    children: [
                                      Text(
                                        style: TextStyle(
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                          fontSize: 16,
                                        ),
                                        returnReceiptProvider(
                                              context,
                                            ).dateSet ??
                                            'Sales For Today',
                                      ),
                                      MaterialButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (
                                                context,
                                              ) {
                                                return TotalSalesPage();
                                              },
                                            ),
                                          ).then((_) {
                                            setState(() {
                                              mainReceiptFuture =
                                                  getMainReceipts();
                                              getProdutRecordsFuture =
                                                  getProductSalesRecord();
                                            });
                                          });
                                        },
                                        child: Row(
                                          spacing: 5,
                                          children: [
                                            Text(
                                              style: TextStyle(
                                                color:
                                                    theme
                                                        .lightModeColor
                                                        .secColor100,
                                              ),
                                              'See All',
                                            ),
                                            Icon(
                                              size: 16,
                                              color:
                                                  theme
                                                      .lightModeColor
                                                      .secColor100,
                                              Icons
                                                  .arrow_forward_ios_rounded,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.symmetric(
                                          horizontal: 10.0,
                                        ),
                                    child: Builder(
                                      builder: (context) {
                                        if (mainReceipts
                                            .isEmpty) {
                                          return EmptyWidgetDisplay(
                                            buttonText:
                                                'Make Sales',
                                            subText:
                                                'Click on the button below to start adding Sales to your Record.',
                                            title:
                                                'No Sales Recorded Yet',
                                            svg:
                                                productIconSvg,
                                            height: 35,
                                            action: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (
                                                    context,
                                                  ) {
                                                    return MakeSalesPage();
                                                  },
                                                ),
                                              );
                                            },
                                            theme: theme,
                                          );
                                        } else {
                                          return ListView.builder(
                                            itemCount:
                                                mainReceipts
                                                    .length,
                                            itemBuilder: (
                                              context,
                                              index,
                                            ) {
                                              TempMainReceipt
                                              mainReceipt =
                                                  mainReceipts[index];
                                              return MainReceiptTile(
                                                mainReceipt:
                                                    mainReceipt,
                                                key: ValueKey(
                                                  mainReceipt
                                                      .id!,
                                                ),
                                              );
                                              // return ListTile(
                                              //   title: Text(
                                              //     mainReceipt
                                              //         .staffName,
                                              //   ),
                                              // );
                                            },
                                          );
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Overlayed search results container
                        ),
                      ),
                    ],
                  ),
                  if (returnReceiptProvider(
                    context,
                  ).setDate)
                    Positioned(
                      top: 190,
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
              ),
            );
          }
        },
      ),
    );
  }
}
