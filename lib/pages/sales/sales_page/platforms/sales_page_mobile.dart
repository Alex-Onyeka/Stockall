import 'package:flutter/material.dart';
import 'package:stockall/classes/checkout_response.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/classes/temp_notification/temp_notification.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/list_tiles/main_receipt_tile.dart';
import 'package:stockall/components/major/empty_widget_display.dart';
import 'package:stockall/components/major/items_summary.dart';
import 'package:stockall/components/major/drawer_widget/my_drawer_widget.dart';
import 'package:stockall/components/major/top_banner.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/date_picker_function.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/refresh_functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/authentication/auth_screens/auth_screens_page.dart';
import 'package:stockall/pages/dashboard/components/main_bottom_nav.dart';
import 'package:stockall/pages/sales/make_sales/page1/make_sales_page.dart';
import 'package:stockall/pages/sales/make_sales/receipt_page/receipt_page.dart';
import 'package:stockall/pages/sales/search_receipt/search_receipt_page.dart';
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
    await RefreshFunctions(
      context,
    ).refreshReceipts(context);
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
      returnShopProvider().userShop()!.shopId!,
    );

    return tempGet;
  }

  // List<TempProductSaleRecord> getProductSalesRecord() {
  //   var tempRecords =
  //       returnReceiptProvider(
  //         context,
  //         listen: false,
  //       ).produtRecordSalesMain;

  //   return tempRecords
  //       .where(
  //         (beans) =>
  //             beans.shopId ==
  //             returnShopProvider().userShop()!.shopId!,
  //       )
  //       .toList();
  // }

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
                      action: () async {
                        var res = await AuthService()
                            .signOut(
                              context: context,
                              allowLogout: false,
                            );
                        if (res == 1) {
                          if (context.mounted) {
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
                          }
                        }
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
        child: Column(
          children: [
            Material(
              color: Colors.transparent,
              child: SizedBox(
                height: 250,
                child: Stack(
                  children: [
                    TopBanner(
                      subTitle: 'Data of All Sales Records',
                      title: 'Sales',
                      theme: theme,
                      bottomSpace: 80,
                      topSpace: 20,
                      iconSvg: salesIconSvg,
                    ),
                    Align(
                      alignment: Alignment(0, 1),
                      child: ItemsSummary(
                        scanReceiptBarcode: () {
                          showSearchReceiptPage(context);
                        },
                        isFilter: authorization(
                          authorized:
                              Authorizations().viewDate,
                        ),
                        isMoney1: true,
                        mainTitle: 'Sales Summary',
                        subTitle:
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
                        firsRow: true,
                        color1: Colors.green,
                        title1: 'Sales Revenue',
                        value1:
                            returnReceiptProvider(
                              context,
                            ).getTotalRevenueForSelectedDay(),
                        color2: Colors.amber,
                        title2: 'Sales Number',
                        value2:
                            returnReceiptProvider(context)
                                .returnOwnReceiptsByDayOrWeek()
                                .toList()
                                .length
                                .toDouble(),
                        secondRow: false,
                        onSearch: false,
                        isDateSet:
                            returnReceiptProvider(
                                  context,
                                  listen: false,
                                ).dateSet !=
                                null ||
                            returnReceiptProvider(
                                  context,
                                  listen: false,
                                ).rangeStartDate !=
                                null,
                        setDate:
                            returnReceiptProvider(
                                  context,
                                  listen: false,
                                ).dateSet !=
                                null ||
                            returnReceiptProvider(
                                  context,
                                  listen: false,
                                ).rangeStartDate !=
                                null,
                        filterAction: () {
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
                                returnReceiptProvider(
                                  context,
                                  listen: false,
                                ).setDate(date!);
                              },
                              rangeDate: (
                                firstDate,
                                lastDate,
                              ) {
                                returnReceiptProvider(
                                  context,
                                  listen: false,
                                ).setRange(
                                  firstDate!,
                                  lastDate ??
                                      DateTime.now(),
                                );
                              },
                            );
                          }
                        },
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
                        padding: const EdgeInsets.symmetric(
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
                                            ).dateSet !=
                                            null ||
                                        returnReceiptProvider(
                                              context,
                                            ).rangeStartDate !=
                                            null
                                    ? 'All Sales'
                                    : 'Sales For Today',
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
                                    ).clearDate();
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
                                  .returnOwnReceiptsByDayOrWeek()
                                  .toList()
                                  .isEmpty) {
                                return EmptyWidgetDisplay(
                                  buttonText: 'Make Sales',
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
                                        builder: (context) {
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
                                            .returnOwnReceiptsByDayOrWeek()
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
                                              .returnOwnReceiptsByDayOrWeek()
                                              .toList()[index];
                                      return MainReceiptTile(
                                        action: () {
                                          FocusManager
                                              .instance
                                              .primaryFocus
                                              ?.unfocus();
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (
                                                context,
                                              ) {
                                                return ReceiptPage(
                                                  response: CheckoutResponse(
                                                    resUuid:
                                                        mainReceipt.uuid!,
                                                    isReceipt:
                                                        true,
                                                  ),
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
                                          mainReceipt.uuid!,
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
      ),
    );
  }
}
