import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stockall/classes/temp_notification/temp_notification.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/local_database/expenses/unsync_funcs/created_expenses/created_expenses_func.dart';
import 'package:stockall/local_database/expenses/unsync_funcs/deleted_expenses/deleted_expenses_func.dart';
import 'package:stockall/local_database/expenses/unsync_funcs/updated_expenses/updated_expenses_func.dart';
import 'package:stockall/local_database/main_receipt/unsync_funcs/created/created_receipts_func.dart';
import 'package:stockall/local_database/product_record_func.dart/unsync_funcs/created/created_records_func.dart';
import 'package:stockall/local_database/products/unsync_funcs/updated_products/updated_products_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/authentication/auth_screens/auth_screens_page.dart';
import 'package:stockall/pages/shop_setup/shop_page/shop_page.dart';
import 'package:stockall/providers/theme_provider.dart';
import 'package:stockall/services/auth_service.dart';

class TopNavBar extends StatefulWidget {
  final Function()? refreshAction;
  final List<TempNotification> notifications;
  final String? title;
  final String? subText;
  final Function()? action;
  final ThemeProvider theme;

  final Function()? openSideBar;

  const TopNavBar({
    super.key,
    required this.notifications,
    this.title,
    this.subText,
    required this.theme,
    required this.openSideBar,
    this.action,
    this.refreshAction,
  });

  @override
  State<TopNavBar> createState() => _TopNavBarState();
}

class _TopNavBarState extends State<TopNavBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 0,
        bottom: 10,
        left: 0,
        right: 15,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(30, 0, 0, 0),
            blurRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            onTap: () {
              screenWidth(context) < mobileScreen
                  ? widget.openSideBar!()
                  : Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return ShopPage();
                      },
                    ),
                  );
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 5,
              children: [
                SizedBox(
                  height: 70,
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.center,
                    children: [
                      SizedBox(width: 15),
                      Visibility(
                        visible:
                            screenWidth(context) <
                            mobileScreen,
                        child: Icon(
                          color: Colors.grey.shade700,
                          size: 28,
                          Icons.menu_rounded,
                        ),
                      ),
                      SizedBox(width: 10),
                      Container(
                        padding: EdgeInsets.all(3),
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          shape: BoxShape.circle,
                        ),
                        child: Image.asset(
                          shopIconImage,
                          height: 35,
                          width: 35,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  spacing: 3,
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.center,
                      children: [
                        Text(
                          style: TextStyle(
                            fontSize:
                                widget
                                    .theme
                                    .mobileTexts
                                    .b2
                                    .fontSize,
                            fontWeight:
                                widget
                                    .theme
                                    .mobileTexts
                                    .b2
                                    .fontWeightBold,
                            color: Colors.black,
                          ),
                          cutLongText(
                            widget.title ??
                                returnShopProvider(
                                  context,
                                ).userShop?.name ??
                                '',
                            17,
                          ),
                        ),
                        SizedBox(width: 5),
                        SvgPicture.asset(
                          checkIconSvg,
                          height: 18,
                          width: 18,
                          fit: BoxFit.contain,
                        ),
                      ],
                    ),
                    Text(
                      style: TextStyle(
                        fontSize:
                            widget
                                .theme
                                .mobileTexts
                                .b3
                                .fontSize,
                        color:
                            widget
                                .theme
                                .lightModeColor
                                .prColor250,
                        fontWeight: FontWeight.w500,
                      ),
                      cutLongText(
                        widget.subText ??
                            returnShopProvider(
                              context,
                            ).userShop?.email ??
                            '',
                        22,
                      ),
                    ),
                    SizedBox(height: 0),
                    Row(
                      spacing: 6,
                      mainAxisAlignment:
                          MainAxisAlignment.end,
                      children: [],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            spacing: 10,
            children: [
              Visibility(
                visible:
                    screenWidth(context) > mobileScreen,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () async {
                      await CreatedExpensesFunc()
                          .clearExpenses();
                      await UpdatedExpensesFunc()
                          .clearupdatedExpenses();
                      await DeletedExpensesFunc()
                          .clearDeletedExpenses();
                      await CreatedReceiptsFunc()
                          .clearReceipts();
                      await CreatedRecordsFunc()
                          .clearRecords();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child:
                      // StreamBuilder(
                      //   stream:
                      //       ConnectivityProvider()
                      //           .connectivityStream,
                      //   builder: (context, snapshot) {
                      //     return Row(
                      //       spacing: 5,
                      //       children: [
                      //         Text(
                      //           style: TextStyle(
                      //             fontSize:
                      //                 theme
                      //                     .mobileTexts
                      //                     .b3
                      //                     .fontSize,
                      //             fontWeight:
                      //                 FontWeight.bold,
                      //           ),
                      //           snapshot.connectionState ==
                      //                   ConnectionState
                      //                       .waiting
                      //               ? 'Checking'
                      //               : snapshot.hasError
                      //               ? 'Error'
                      //               : snapshot.data!.isEmpty
                      //               ? 'Not Connected'
                      //               : 'Connected',
                      //         ),
                      //         Container(
                      //           padding: EdgeInsets.all(3),
                      //           decoration: BoxDecoration(
                      //             shape: BoxShape.circle,
                      //             color:
                      //                 snapshot.connectionState ==
                      //                         ConnectionState
                      //                             .waiting
                      //                     ? Colors.amber
                      //                     : snapshot
                      //                         .hasError
                      //                     ? Colors.grey
                      //                     : snapshot
                      //                         .data!
                      //                         .isEmpty
                      //                     ? Colors.grey
                      //                     : Colors.green,
                      //           ),
                      //         ),
                      //       ],
                      //     );
                      //   },
                      // ),
                      Row(
                        spacing: 5,
                        children: [
                          Text(
                            style: TextStyle(
                              fontSize:
                                  widget
                                      .theme
                                      .mobileTexts
                                      .b3
                                      .fontSize,
                              fontWeight: FontWeight.bold,
                            ),

                            returnConnectivityProvider(
                              context,
                            ).connectedText(),
                          ),
                          Icon(
                            size: 17,
                            color:
                                returnConnectivityProvider(
                                  context,
                                ).connectedColor(),
                            returnConnectivityProvider(
                                  context,
                                ).isConnected
                                ? Icons.wifi
                                : Icons.wifi_off_sharp,
                          ),
                          // Container(
                          //   padding: EdgeInsets.all(3),
                          //   decoration: BoxDecoration(
                          //     shape: BoxShape.circle,
                          //     color:
                          //         returnConnectivityProvider(
                          //               context,
                          //             ).isConnected
                          //             ? Colors.green
                          //             : Colors.grey,
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Visibility(
                visible:
                    screenWidth(context) > mobileScreen,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () async {
                      print(
                        UpdatedProductsFunc()
                            .getProducts()
                            .length
                            .toString(),
                      );
                      await returnData(
                        context,
                        listen: false,
                      ).syncData(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        spacing: 5,
                        children: [
                          Text(
                            style: TextStyle(
                              fontSize:
                                  widget
                                      .theme
                                      .mobileTexts
                                      .b3
                                      .fontSize,
                              fontWeight: FontWeight.bold,
                            ),
                            returnData(
                                      context,
                                    ).isSynced() ==
                                    1
                                ? 'Synced'
                                : returnData(
                                      context,
                                    ).isSynced() ==
                                    0
                                ? 'Unsynced'
                                : 'Syncing',
                          ),
                          Stack(
                            children: [
                              Visibility(
                                visible:
                                    returnData(
                                      context,
                                    ).isSynced() !=
                                    2,
                                child: Icon(
                                  color:
                                      returnData(
                                                context,
                                              ).isSynced() ==
                                              1
                                          ? const Color.fromARGB(
                                            255,
                                            87,
                                            160,
                                            89,
                                          )
                                          : Colors.grey,
                                  size: 18,
                                  returnData(
                                            context,
                                          ).isSynced() ==
                                          1
                                      ? Icons
                                          .cloud_done_outlined
                                      : Icons
                                          .cloud_sync_outlined,
                                ),
                              ),
                              Visibility(
                                visible:
                                    returnData(
                                      context,
                                    ).isSynced() ==
                                    2,
                                child: Stack(
                                  alignment: Alignment(
                                    0,
                                    0,
                                  ),
                                  children: [
                                    SizedBox(
                                      height: 18,
                                      width: 18,
                                      child:
                                          CircularProgressIndicator(
                                            color:
                                                Colors
                                                    .amber,
                                            strokeWidth:
                                                1.5,
                                          ),
                                    ),
                                    Center(
                                      child: Row(
                                        mainAxisSize:
                                            MainAxisSize
                                                .min,
                                        children: [
                                          Text(
                                            style: TextStyle(
                                              fontWeight:
                                                  FontWeight
                                                      .bold,
                                              fontSize: 8,
                                            ),
                                            returnData(
                                                  context,
                                                )
                                                .syncProgress
                                                .toStringAsFixed(
                                                  0,
                                                ),
                                          ),
                                          Text(
                                            style: TextStyle(
                                              fontWeight:
                                                  FontWeight
                                                      .bold,
                                              fontSize: 7,
                                            ),
                                            '%',
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // SizedBox(height: 20),
              Visibility(
                visible:
                    screenWidth(context) > mobileScreen,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: widget.refreshAction,
                    // onTap: () async {
                    //   await MainReceiptFunc()
                    //       .clearReceipts();
                    // },
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        spacing: 5,
                        children: [
                          Text(
                            style: TextStyle(
                              fontSize:
                                  widget
                                      .theme
                                      .mobileTexts
                                      .b3
                                      .fontSize,
                              fontWeight: FontWeight.bold,
                            ),
                            'Refresh',
                          ),
                          Icon(
                            size: 18,
                            Icons.refresh_rounded,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // SizedBox(height: 20),
              Stack(
                children: [
                  Visibility(
                    visible: authorization(
                      authorized:
                          Authorizations()
                              .notificationsPage,
                      context: context,
                    ),
                    child: Stack(
                      alignment: Alignment(1.2, -1.8),
                      children: [
                        InkWell(
                          onTap: () {
                            widget.action!();
                          },
                          child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(
                                208,
                                245,
                                245,
                                245,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: SvgPicture.asset(
                              height: 25,
                              width: 25,
                              notifIconSvg,
                            ),
                          ),
                        ),
                        Visibility(
                          visible:
                              widget.notifications
                                  .where(
                                    (notif) =>
                                        !notif.isViewed,
                                  )
                                  .isNotEmpty,
                          child: Container(
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient:
                                  widget
                                      .theme
                                      .lightModeColor
                                      .secGradient,
                            ),
                            child: Center(
                              child: Text(
                                style: TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                  fontSize:
                                      widget.notifications
                                                  .where(
                                                    (
                                                      notif,
                                                    ) =>
                                                        !notif.isViewed,
                                                  )
                                                  .length ==
                                              2
                                          ? 12
                                          : 14,
                                  color: Colors.white,
                                ),
                                '${widget.notifications.where((notif) => !notif.isViewed).length}',
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible:
                        !authorization(
                          authorized:
                              Authorizations()
                                  .notificationsPage,
                          context: context,
                        ),
                    child: Stack(
                      alignment: Alignment(1.2, -1.8),
                      children: [
                        InkWell(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (dialogContext) {
                                return ConfirmationAlert(
                                  theme: widget.theme,
                                  message:
                                      'You are about to Logout',
                                  title: 'Are you Sure?',
                                  action: () async {
                                    Navigator.of(
                                      dialogContext,
                                    ).pop();

                                    await AuthService()
                                        .signOut(context);
                                    if (context.mounted) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (
                                            context,
                                          ) {
                                            return AuthScreensPage();
                                          },
                                        ),
                                      );
                                      returnNavProvider(
                                        context,
                                        listen: false,
                                      ).navigate(0);
                                    }
                                  },
                                );
                              },
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(
                                208,
                                245,
                                245,
                                245,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.logout_rounded,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
