import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_main_receipt.dart';
import 'package:stockall/classes/temp_notification.dart';
import 'package:stockall/classes/temp_product_sale_record.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/calendar/calendar_widget.dart';
import 'package:stockall/components/list_tiles/main_receipt_tile.dart';
import 'package:stockall/components/major/empty_widget_display.dart';
import 'package:stockall/components/major/items_summary.dart';
import 'package:stockall/components/major/my_drawer_widget.dart';
import 'package:stockall/components/major/top_banner.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/authentication/auth_screens/auth_screens_page.dart';
import 'package:stockall/pages/dashboard/components/main_bottom_nav.dart';
import 'package:stockall/pages/sales/make_sales/page1/make_sales_page.dart';
import 'package:stockall/pages/sales/make_sales/receipt_page/receipt_page.dart';
import 'package:stockall/pages/sales/total_sales/total_sales_page.dart';
import 'package:stockall/services/auth_service.dart';

class SalesPageMobile extends StatefulWidget {
  const SalesPageMobile({super.key});

  @override
  State<SalesPageMobile> createState() =>
      _SalesPageMobileState();
}

class _SalesPageMobileState extends State<SalesPageMobile> {
  Future<void> getMainReceipts() async {
    await returnReceiptProvider(
      context,
      listen: false,
    ).loadReceipts(
      returnShopProvider(
        context,
        listen: false,
      ).userShop!.shopId!,
      context,
    );
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
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

  List<TempProductSaleRecord> getProductSalesRecord() {
    var tempRecords =
        returnReceiptProvider(
          context,
          listen: false,
        ).produtRecordSalesMain;

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

  @override
  Widget build(BuildContext context) {
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
              action: () {},
              theme: theme,
              notifications: [],
            );
          } else if (snapshot.hasError) {
            return MyDrawerWidget(
              action: () {},
              theme: theme,
              notifications: [],
            );
          } else {
            List<TempNotification> notifications =
                snapshot.data!;

            return MyDrawerWidget(
              action: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return ConfirmationAlert(
                      theme: theme,
                      message: 'You are about to Logout',
                      title: 'Are you Sure?',
                      action: () {
                        AuthService().signOut();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return AuthScreensPage();
                            },
                          ),
                        );
                        returnNavProvider(
                          context,
                          listen: false,
                        ).navigate(0);
                      },
                    );
                  },
                );
              },
              theme: theme,
              notifications: notifications,
            );
          }
        },
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            Column(
              children: [
                Material(
                  color: Colors.transparent,
                  child: SizedBox(
                    height: 250,
                    child: Stack(
                      children: [
                        TopBanner(
                          subTitle:
                              'Data of All Sales Records',
                          title: 'Sales',
                          theme: theme,
                          bottomSpace: 80,
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
                            child: ItemsSummary(
                              isFilter: authorization(
                                authorized:
                                    Authorizations()
                                        .viewDate,
                                context: context,
                              ),
                              isMoney1: true,
                              mainTitle: 'Sales Summary',
                              subTitle:
                                  returnReceiptProvider(
                                    context,
                                  ).dateSet ??
                                  'For Today',
                              firsRow: true,
                              color1: Colors.green,
                              title1: 'Sales Revenue',
                              value1: returnReceiptProvider(
                                context,
                              ).getTotalRevenueForSelectedDay(
                                context,
                                returnReceiptProvider(
                                  context,
                                ).receipts,
                                returnReceiptProvider(
                                  context,
                                ).produtRecordSalesMain,
                              ),
                              color2: Colors.amber,
                              title2: 'Sales Number',
                              value2:
                                  returnReceiptProvider(
                                        context,
                                      )
                                      .returnOwnReceiptsByDayOrWeek(
                                        context,
                                        returnReceiptProvider(
                                          context,
                                        ).receipts,
                                      )
                                      .toList()
                                      .length
                                      .toDouble(),
                              secondRow: false,
                              onSearch: false,
                              isDateSet:
                                  returnReceiptProvider(
                                    context,
                                    listen: false,
                                  ).isDateSet,
                              setDate:
                                  returnReceiptProvider(
                                    context,
                                    listen: false,
                                  ).setDate,
                              filterAction: () {
                                if (returnReceiptProvider(
                                      context,
                                      listen: false,
                                    ).isDateSet ||
                                    returnReceiptProvider(
                                      context,
                                      listen: false,
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
                      padding: const EdgeInsets.fromLTRB(
                        10.0,
                        10,
                        10,
                        10,
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(
                                  horizontal: 10.0,
                                ),
                            child: Row(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    style: TextStyle(
                                      fontWeight:
                                          FontWeight.bold,
                                      fontSize:
                                          theme
                                              .mobileTexts
                                              .b1
                                              .fontSize,
                                    ),
                                    returnReceiptProvider(
                                          context,
                                        ).dateSet ??
                                        'Sales For Today',
                                  ),
                                ),
                                MaterialButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return TotalSalesPage();
                                        },
                                      ),
                                    ).then((_) {
                                      setState(() {
                                        returnReceiptProvider(
                                          context,
                                          listen: false,
                                        ).clearReceiptDate();
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
                                          fontSize:
                                              theme
                                                  .mobileTexts
                                                  .b1
                                                  .fontSize,
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
                                  if (returnReceiptProvider(
                                        context,
                                      )
                                      .returnOwnReceiptsByDayOrWeek(
                                        context,
                                        returnReceiptProvider(
                                          context,
                                        ).receipts,
                                      )
                                      .toList()
                                      .isEmpty) {
                                    return EmptyWidgetDisplay(
                                      buttonText:
                                          'Make Sales',
                                      subText:
                                          'Click on the button below to start adding Sales to your Record.',
                                      title:
                                          'No Sales Recorded Yet',
                                      // svg: productIconSvg,
                                      icon: Icons.clear,
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
                                      altAction: () {
                                        getMainReceipts();
                                      },
                                      altActionText:
                                          'Refresh List',
                                      theme: theme,
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
                                            returnReceiptProvider(
                                                  context,
                                                )
                                                .returnOwnReceiptsByDayOrWeek(
                                                  context,
                                                  returnReceiptProvider(
                                                    context,
                                                  ).receipts,
                                                )
                                                .toList()
                                                .length,
                                        itemBuilder: (
                                          context,
                                          index,
                                        ) {
                                          TempMainReceipt
                                          mainReceipt =
                                              returnReceiptProvider(
                                                    context,
                                                  )
                                                  .returnOwnReceiptsByDayOrWeek(
                                                    context,
                                                    returnReceiptProvider(
                                                      context,
                                                    ).receipts,
                                                  )
                                                  .toList()[index];
                                          return MainReceiptTile(
                                            action: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (
                                                    context,
                                                  ) {
                                                    return ReceiptPage(
                                                      receiptId:
                                                          mainReceipt.id!,
                                                      isMain:
                                                          false,
                                                    );
                                                  },
                                                ),
                                              ).then((_) {
                                                // mainReceiptFuture =
                                              });
                                            },
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
                                      ),
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
            if (returnReceiptProvider(context).setDate)
              GestureDetector(
                onTap: () {
                  returnReceiptProvider(
                    context,
                    listen: false,
                  ).clearReceiptDate();
                },
                child: Material(
                  color: const Color.fromARGB(100, 0, 0, 0),
                  child: SizedBox(
                    height:
                        MediaQuery.of(context).size.height,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(
                            height:
                                MediaQuery.of(
                                  context,
                                ).size.height *
                                0.12,
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
        ),
      ),
    );
  }
}
