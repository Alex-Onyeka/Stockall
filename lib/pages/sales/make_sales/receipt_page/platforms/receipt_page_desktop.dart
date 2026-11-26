import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stockall/classes/checkout_response.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/printer_settings_dialog.dart';
import 'package:stockall/components/major/top_banner_two.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/generate_barcode.dart';
import 'package:stockall/constants/subscription/sales_auth.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/sales/make_sales/page1/make_sales_page.dart';
import 'package:stockall/providers/theme_provider.dart';
import 'package:stockall/services/auth_service.dart';
import 'package:stockall/services/printing/app_printer_service.dart';
import 'package:stockall/services/printing/import_helper.dart'
    show scanBluetoothPrinters;

class ReceiptPageDesktop extends StatefulWidget {
  final bool isMain;
  final CheckoutResponse response;
  const ReceiptPageDesktop({
    super.key,
    required this.response,
    required this.isMain,
  });

  @override
  State<ReceiptPageDesktop> createState() =>
      _ReceiptPageDesktopState();
}

class _ReceiptPageDesktopState
    extends State<ReceiptPageDesktop> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      returnReceiptProvider(
        context,
        listen: false,
      ).toggleIsLoading(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    var shop = returnShopProvider().userShop();
    var theme = returnTheme(context);

    TempMainReceipt defaultReceipt = TempMainReceipt(
      tempItems: null,
      salesTypeIndex: 1,
      orderUuid: null,
      customerAccount: 0,
      comment: null,
      subStaffName: null,
      departmentName:
          returnDepartmentProvider()
              .currentDepartment()
              ?.name,
      departmentUuidNew:
          returnDepartmentProvider()
              .currentDepartment()
              ?.uuid,
      createdAt: DateTime.now(),
      uuid: '1',
      shopId: shopId(),
      staffId: AuthService().currentUser!,
      staffName: 'Staff Name',
      paymentMethod: 'Cash',
      bank: 0,
      cashAlt: 0,
      isInvoice: false,
      cartName: 'Cart 1',
    );

    TempMainReceipt mainReceipt =
        widget.response.receipt ?? defaultReceipt;
    // returnReceiptProvider(
    //   context,
    // ).receipts.firstWhere(
    //   (rec) => rec.uuid! == widget.response.receipt?.uuid,
    //   orElse:
    //       () => TempMainReceipt(
    //         tempItems: null,
    //         salesTypeIndex: 1,
    //         orderUuid: null,
    //         customerAccount: 0,
    //         comment: null,
    //         subStaffName: null,
    //         departmentName:
    //             returnDepartmentProvider()
    //                 .currentDepartment()
    //                 ?.name,
    //         departmentUuidNew:
    //             returnDepartmentProvider()
    //                 .currentDepartment()
    //                 ?.uuid,
    //         createdAt: DateTime.now(),
    //         uuid: '1',
    //         shopId: shopId(),
    //         staffId: AuthService().currentUser!,
    //         staffName: 'Staff Name',
    //         paymentMethod: 'Cash',
    //         bank: 0,
    //         cashAlt: 0,
    //         isInvoice: false,
    //         cartName: 'Cart 1',
    //       ),
    // );

    return SafeArea(
      child: PopScope(
        canPop: false,
        child: Scaffold(
          body: Center(
            child: Column(
              children: [
                SizedBox(
                  height:
                      MediaQuery.of(context).size.height -
                      10,
                  width: 600,
                  child: Stack(
                    alignment: Alignment(0, 1),
                    children: [
                      Align(
                        alignment: Alignment(0, -1),
                        child: SizedBox(
                          child: TopBannerTwo(
                            isMain: widget.isMain,
                            title: 'Receipt',
                            theme: theme,
                            bottomSpace: 200,
                            topSpace: 10,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment(0.95, -0.95),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            mouseCursor:
                                SystemMouseCursors.click,
                            borderRadius:
                                BorderRadius.circular(6),
                            onTap: () {
                              showPrinterSettingsDialog(
                                context,
                              );
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                              child: Row(
                                mainAxisSize:
                                    MainAxisSize.min,
                                spacing: 4,
                                children: [
                                  Text(
                                    'Settings',
                                    style: TextStyle(
                                      fontSize:
                                          theme
                                              .mobileTexts
                                              .b3
                                              .fontSize,
                                      color: Colors.white,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                  Icon(
                                    Icons.settings_outlined,
                                    color: Colors.amber,
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 60,
                        child: SizedBox(
                          height:
                              MediaQuery.of(
                                context,
                              ).size.height -
                              10,
                          width: 500,
                          child: Builder(
                            builder: (context) {
                              // if (mainReceipt() != null) {
                              return ReceiptDetailsContainer(
                                isMain: widget.isMain,
                                shop: shop!,
                                mainReceipt: mainReceipt,
                                theme: theme,
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ReceiptDetailsContainer extends StatefulWidget {
  final bool isMain;
  final TempShopClass shop;
  final TempMainReceipt mainReceipt;
  final ThemeProvider theme;
  const ReceiptDetailsContainer({
    super.key,
    required this.theme,
    required this.mainReceipt,
    required this.shop,
    required this.isMain,
  });

  @override
  State<ReceiptDetailsContainer> createState() =>
      _ReceiptDetailsContainerState();
}

class _ReceiptDetailsContainerState
    extends State<ReceiptDetailsContainer> {
  bool isLoading = false;
  bool showSuccess = false;
  @override
  initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await getLogo();
      returnShopProvider().switchLogoPicked(false);
      setState(() {});
    });
  }

  // late Future<void> getLogoFuture;
  Future<void> getLogo() async {
    returnShopProvider().getLogoImage(context);
  }

  @override
  Widget build(BuildContext context) {
    var records = widget.mainReceipt.getItemsNoVoid();
    var recordsVoid = widget.mainReceipt.getItemsVoid();
    String? customer;

    try {
      customer =
          returnCustomers(context)
              .customersMain()
              .firstWhere(
                (c) =>
                    c.uuid ==
                    widget.mainReceipt.customerUuid,
              )
              .name;
    } catch (e) {
      customer = widget.mainReceipt.customerName;
    }

    TempUserClass? staff;

    try {
      staff = returnUserProvider(
        context,
      ).usersMain.firstWhere(
        (c) => c.userId == widget.mainReceipt.staffId,
      );
    } catch (e) {
      staff = null; // not found
    }

    return Stack(
      children: [
        Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width - 40,
              height:
                  MediaQuery.of(context).size.height - 150,
              padding: EdgeInsets.all(25),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(
                      32,
                      0,
                      0,
                      0,
                    ),
                    blurRadius: 5,
                  ),
                ],
              ),
              child: SizedBox(
                height:
                    MediaQuery.of(context).size.height -
                    200,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Builder(
                              builder: (context) {
                                if (returnShopProvider(
                                      context: context,
                                    ).selectedLogo !=
                                    null) {
                                  return Column(
                                    children: [
                                      Container(
                                        height:
                                            (returnShopProvider(
                                                          context:
                                                              context,
                                                        ).imageWidth ??
                                                        0) >
                                                    (2 *
                                                        (returnShopProvider(context: context).imageHeight ??
                                                            0))
                                                ? 40
                                                : 100,
                                        width: 400,
                                        decoration:
                                            BoxDecoration(),
                                        child: Image.memory(
                                          returnShopProvider(
                                            context:
                                                context,
                                          ).selectedLogo!,
                                          fit:
                                              BoxFit
                                                  .contain,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                    ],
                                  );
                                } else {
                                  return Container();
                                }
                              },
                            ),

                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment
                                          .center,
                                  children: [
                                    Text(
                                      textAlign:
                                          TextAlign.center,
                                      style: TextStyle(
                                        fontSize:
                                            widget
                                                .theme
                                                .mobileTexts
                                                .b4
                                                .fontSize,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                      "Shop Id: ${shopRef()}",
                                    ),
                                  ],
                                ),
                                Visibility(
                                  visible:
                                      widget
                                          .shop
                                          .showShopName!,
                                  child: Text(
                                    textAlign:
                                        TextAlign.center,
                                    style: TextStyle(
                                      fontSize:
                                          widget
                                              .theme
                                              .mobileTexts
                                              .h4
                                              .fontSize,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                    widget.shop.name,
                                  ),
                                ),
                                Visibility(
                                  visible:
                                      widget
                                          .shop
                                          .showEmail! &&
                                      widget.shop.email !=
                                          null,
                                  child: Column(
                                    children: [
                                      SizedBox(height: 4),
                                      Text(
                                        style: TextStyle(
                                          fontSize:
                                              widget
                                                  .theme
                                                  .mobileTexts
                                                  .b3
                                                  .fontSize,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                          color:
                                              Colors
                                                  .grey
                                                  .shade700,
                                        ),
                                        widget.shop.email ??
                                            'Email Not Set',
                                      ),
                                    ],
                                  ),
                                ),
                                Visibility(
                                  visible:
                                      widget
                                          .shop
                                          .showAddress!,
                                  child: Column(
                                    children: [
                                      SizedBox(height: 4),
                                      Text(
                                        style: TextStyle(
                                          fontSize:
                                              widget
                                                  .theme
                                                  .mobileTexts
                                                  .b3
                                                  .fontSize,
                                        ),
                                        widget
                                                .shop
                                                .shopAddress ??
                                            'Address Not Set',
                                      ),
                                    ],
                                  ),
                                ),
                                Visibility(
                                  visible:
                                      widget
                                          .shop
                                          .showPhone! &&
                                      widget
                                              .shop
                                              .phoneNumber !=
                                          null,
                                  child: Column(
                                    children: [
                                      SizedBox(height: 4),
                                      Text(
                                        style: TextStyle(
                                          fontSize:
                                              widget
                                                  .theme
                                                  .mobileTexts
                                                  .b3
                                                  .fontSize,
                                        ),
                                        widget
                                                .shop
                                                .phoneNumber ??
                                            'Phone Number Not Set',
                                      ),
                                    ],
                                  ),
                                ),
                                Visibility(
                                  visible:
                                      widget
                                          .shop
                                          .showInstaTop!,
                                  child: Column(
                                    children: [
                                      SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment
                                                .center,
                                        // spacing: 10,
                                        children: [
                                          // Image.asset(
                                          //   height: 15,
                                          //   width: 15,
                                          //   mainLogoIcon,
                                          // ),
                                          Text(
                                            style: TextStyle(
                                              fontSize:
                                                  widget
                                                      .theme
                                                      .mobileTexts
                                                      .b4
                                                      .fontSize,
                                              color:
                                                  Colors
                                                      .grey
                                                      .shade600,
                                              fontWeight:
                                                  FontWeight
                                                      .bold,
                                            ),
                                            "Instagram: ",
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
                                                  Colors
                                                      .grey
                                                      .shade600,
                                              fontWeight:
                                                  FontWeight
                                                      .normal,
                                            ),
                                            widget
                                                    .shop
                                                    .instaHandle ??
                                                'Instagram Not Set',
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Visibility(
                                  visible:
                                      widget
                                          .shop
                                          .showFacebookTop!,
                                  child: Column(
                                    children: [
                                      SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment
                                                .center,
                                        spacing: 0,
                                        children: [
                                          // Image.asset(
                                          //   height: 15,
                                          //   width: 15,
                                          //   mainLogoIcon,
                                          // ),
                                          Text(
                                            style: TextStyle(
                                              fontSize:
                                                  widget
                                                      .theme
                                                      .mobileTexts
                                                      .b4
                                                      .fontSize,
                                              color:
                                                  Colors
                                                      .grey
                                                      .shade600,
                                              fontWeight:
                                                  FontWeight
                                                      .bold,
                                            ),
                                            "Facebook: ",
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
                                                  Colors
                                                      .grey
                                                      .shade600,
                                              fontWeight:
                                                  FontWeight
                                                      .normal,
                                            ),
                                            widget
                                                    .shop
                                                    .faceBookHandle ??
                                                'FaceBook Not Set',
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            Visibility(
                              visible:
                                  widget.shop.showFirst! &&
                                  widget
                                          .mainReceipt
                                          .subStaffName !=
                                      null,
                              child: Row(
                                spacing: 10,
                                children: [
                                  Expanded(
                                    flex: 5,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                      children: [
                                        Text(
                                          style: TextStyle(
                                            fontSize:
                                                widget
                                                    .theme
                                                    .mobileTexts
                                                    .b3
                                                    .fontSize,
                                            fontWeight:
                                                FontWeight
                                                    .bold,
                                          ),
                                          'Cashier',
                                        ),
                                        Text(
                                          style: TextStyle(
                                            fontSize:
                                                widget
                                                    .theme
                                                    .mobileTexts
                                                    .b2
                                                    .fontSize,
                                            fontWeight:
                                                FontWeight
                                                    .normal,
                                          ),
                                          staff?.name ??
                                              widget
                                                  .mainReceipt
                                                  .staffName ??
                                              'Not Set',
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
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
                                                FontWeight
                                                    .bold,
                                          ),
                                          'Cart Name',
                                        ),
                                        Text(
                                          style: TextStyle(
                                            fontSize:
                                                widget
                                                    .theme
                                                    .mobileTexts
                                                    .b3
                                                    .fontSize,
                                            fontWeight:
                                                FontWeight
                                                    .normal,
                                          ),
                                          widget
                                                  .mainReceipt
                                                  .cartName ??
                                              'Not Set',
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Visibility(
                              visible:
                                  widget.shop.showFirst!,
                              child: Column(
                                children: [
                                  SizedBox(height: 5),
                                  Row(
                                    spacing: 10,
                                    children: [
                                      Expanded(
                                        flex: 6,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,
                                          children: [
                                            Text(
                                              style: TextStyle(
                                                fontSize:
                                                    widget
                                                        .theme
                                                        .mobileTexts
                                                        .b3
                                                        .fontSize,
                                                fontWeight:
                                                    FontWeight
                                                        .bold,
                                              ),
                                              widget.mainReceipt.subStaffName !=
                                                      null
                                                  ? 'Waiter'
                                                  : 'Cashier',
                                            ),
                                            Text(
                                              style: TextStyle(
                                                fontSize:
                                                    widget
                                                        .theme
                                                        .mobileTexts
                                                        .b2
                                                        .fontSize,
                                                fontWeight:
                                                    FontWeight
                                                        .normal,
                                              ),
                                              widget
                                                      .mainReceipt
                                                      .subStaffName ??
                                                  staff
                                                      ?.name ??
                                                  widget
                                                      .mainReceipt
                                                      .staffName ??
                                                  'Not Set',
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        flex: 4,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,
                                          children: [
                                            Text(
                                              style: TextStyle(
                                                fontSize:
                                                    widget
                                                        .theme
                                                        .mobileTexts
                                                        .b3
                                                        .fontSize,
                                                fontWeight:
                                                    FontWeight
                                                        .bold,
                                              ),
                                              'Customer',
                                            ),
                                            Text(
                                              style: TextStyle(
                                                fontSize:
                                                    widget
                                                        .theme
                                                        .mobileTexts
                                                        .b2
                                                        .fontSize,
                                                fontWeight:
                                                    FontWeight
                                                        .normal,
                                              ),
                                              customer ??
                                                  'Not Saved',
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Visibility(
                              visible:
                                  widget.shop.showSecond!,
                              child: Column(
                                children: [
                                  SizedBox(height: 5),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                    spacing: 10,
                                    children: [
                                      Expanded(
                                        flex: 6,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,
                                          children: [
                                            Text(
                                              style: TextStyle(
                                                fontSize:
                                                    widget
                                                        .theme
                                                        .mobileTexts
                                                        .b3
                                                        .fontSize,
                                                fontWeight:
                                                    FontWeight
                                                        .bold,
                                              ),
                                              'Payment Method',
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .start,
                                              children: [
                                                ...widget.mainReceipt.displayPayments().map(
                                                  (
                                                    payment,
                                                  ) => Padding(
                                                    padding: const EdgeInsets.only(
                                                      bottom:
                                                          2,
                                                    ),
                                                    child: Text.rich(
                                                      TextSpan(
                                                        children: [
                                                          TextSpan(
                                                            text:
                                                                '${payment.method}: ',
                                                            style: TextStyle(
                                                              fontSize:
                                                                  widget.theme.mobileTexts.b3.fontSize,
                                                              fontWeight:
                                                                  FontWeight.normal,
                                                            ),
                                                          ),
                                                          TextSpan(
                                                            text: formatMoneyMid(
                                                              amount:
                                                                  payment.amount,
                                                              context:
                                                                  context,
                                                            ),
                                                            style: TextStyle(
                                                              fontSize:
                                                                  widget.theme.mobileTexts.b3.fontSize,
                                                              fontWeight:
                                                                  FontWeight.bold,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        flex: 4,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,
                                          children: [
                                            Text(
                                              style: TextStyle(
                                                fontSize:
                                                    widget
                                                        .theme
                                                        .mobileTexts
                                                        .b3
                                                        .fontSize,
                                                fontWeight:
                                                    FontWeight
                                                        .bold,
                                              ),
                                              '#Ticket Id',
                                            ),
                                            Text(
                                              style: TextStyle(
                                                fontSize:
                                                    widget
                                                        .theme
                                                        .mobileTexts
                                                        .b2
                                                        .fontSize,
                                                fontWeight:
                                                    FontWeight
                                                        .normal,
                                              ),
                                              widget
                                                      .mainReceipt
                                                      .barcode ??
                                                  returnOnlyDigits(
                                                    widget.mainReceipt.uuid ??
                                                        '',
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
                            Visibility(
                              visible:
                                  widget.shop.showThird!,
                              child: Column(
                                children: [
                                  SizedBox(height: 5),
                                  Row(
                                    spacing: 10,
                                    children: [
                                      Expanded(
                                        flex: 6,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,
                                          children: [
                                            Text(
                                              style: TextStyle(
                                                fontSize:
                                                    widget
                                                        .theme
                                                        .mobileTexts
                                                        .b3
                                                        .fontSize,
                                                fontWeight:
                                                    FontWeight
                                                        .bold,
                                              ),
                                              'Date',
                                            ),
                                            Text(
                                              style: TextStyle(
                                                fontSize:
                                                    widget
                                                        .theme
                                                        .mobileTexts
                                                        .b3
                                                        .fontSize,
                                                fontWeight:
                                                    FontWeight
                                                        .normal,
                                              ),
                                              formatDateTime(
                                                widget
                                                    .mainReceipt
                                                    .createdAt,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        flex: 4,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,
                                          children: [
                                            Text(
                                              style: TextStyle(
                                                fontSize:
                                                    widget
                                                        .theme
                                                        .mobileTexts
                                                        .b3
                                                        .fontSize,
                                                fontWeight:
                                                    FontWeight
                                                        .bold,
                                              ),
                                              'Time',
                                            ),
                                            Text(
                                              style: TextStyle(
                                                fontSize:
                                                    widget
                                                        .theme
                                                        .mobileTexts
                                                        .b3
                                                        .fontSize,
                                                fontWeight:
                                                    FontWeight
                                                        .normal,
                                              ),
                                              formatTime(
                                                widget
                                                    .mainReceipt
                                                    .createdAt,
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
                            Visibility(
                              visible:
                                  widget
                                          .mainReceipt
                                          .comment !=
                                      null &&
                                  widget
                                          .mainReceipt
                                          .comment
                                          ?.isNotEmpty ==
                                      true,
                              child: Column(
                                children: [
                                  SizedBox(height: 5),
                                  Row(
                                    spacing: 10,
                                    children: [
                                      Expanded(
                                        flex: 6,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,
                                          children: [
                                            Text(
                                              style: TextStyle(
                                                fontSize:
                                                    widget
                                                        .theme
                                                        .mobileTexts
                                                        .b3
                                                        .fontSize,
                                                fontWeight:
                                                    FontWeight
                                                        .bold,
                                              ),
                                              'Comment',
                                            ),
                                            Text(
                                              style: TextStyle(
                                                fontSize:
                                                    widget
                                                        .theme
                                                        .mobileTexts
                                                        .b3
                                                        .fontSize,
                                                fontWeight:
                                                    FontWeight
                                                        .normal,
                                              ),
                                              widget
                                                      .mainReceipt
                                                      .comment ??
                                                  'Comment',
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 5),
                            Divider(),
                            Row(
                              children: [
                                Text(
                                  style: TextStyle(
                                    fontSize:
                                        widget
                                            .theme
                                            .mobileTexts
                                            .b3
                                            .fontSize,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                  'Item Record:',
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Column(
                                  children:
                                      records.map((
                                        productRecord,
                                      ) {
                                        return Container(
                                          margin:
                                              EdgeInsets.symmetric(
                                                vertical: 4,
                                              ),
                                          padding:
                                              const EdgeInsets.symmetric(
                                                vertical:
                                                    8.0,
                                                horizontal:
                                                    10,
                                              ),
                                          decoration:
                                              BoxDecoration(
                                                color:
                                                    Colors
                                                        .grey
                                                        .shade100,
                                              ),
                                          child: SizedBox(
                                            child: Row(
                                              spacing: 10,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  flex: 4,
                                                  child: Column(
                                                    spacing:
                                                        3,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        style: TextStyle(
                                                          fontSize:
                                                              widget.theme.mobileTexts.b2.fontSize,
                                                        ),
                                                        '${productRecord.productName}${productRecord.dimensionsLabel()}',
                                                      ),
                                                      Visibility(
                                                        visible:
                                                            productRecord.wastageNote().isNotEmpty,
                                                        child: Text(
                                                          style: TextStyle(
                                                            fontSize:
                                                                widget.theme.mobileTexts.b4.fontSize,
                                                            color:
                                                                Colors.grey.shade700,
                                                          ),
                                                          productRecord.wastageNote(),
                                                        ),
                                                      ),
                                                      Text(
                                                        style: TextStyle(
                                                          fontSize:
                                                              widget.theme.mobileTexts.b4.fontSize,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                        'Qty: ${productRecord.quantityText()} ${productRecord.unit == 'Others' || productRecord.unit == null ? 'Unit(s)' : productRecord.unit}',
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 3,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.start,
                                                    children: [
                                                      Text(
                                                        style: TextStyle(
                                                          fontSize:
                                                              widget.theme.mobileTexts.b3.fontSize,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                        formatMoneyMid(
                                                          amount:
                                                              (widget.mainReceipt.fixedDiscount ==
                                                                              null &&
                                                                          widget.mainReceipt.generalDiscount ==
                                                                              null) &&
                                                                      productRecord.discount !=
                                                                          null
                                                                  ? ((productRecord.originalCost ??
                                                                          0) -
                                                                      (productRecord.discountedAmount ??
                                                                          0))
                                                                  : (productRecord.originalCost ??
                                                                      0),
                                                          context:
                                                              context,
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.only(
                                                          left:
                                                              1.0,
                                                        ),
                                                        child: Text(
                                                          style: TextStyle(
                                                            fontSize:
                                                                widget.theme.mobileTexts.b4.fontSize,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                          "${formatMoneyMid(amount: ((widget.mainReceipt.fixedDiscount == null && widget.mainReceipt.generalDiscount == null) && productRecord.discount != null ? ((productRecord.originalCost ?? 0) - (productRecord.discountedAmount ?? 0)) : (productRecord.originalCost ?? 0) / productRecord.priceQuantity()), context: context)} per 1",
                                                        ),
                                                      ),
                                                      // Visibility(
                                                      //   visible:
                                                      //       productRecord.discount !=
                                                      //           null &&
                                                      //       !productRecord.customPriceSet &&
                                                      //       (widget.mainReceipt.fixedDiscount ==
                                                      //               null &&
                                                      //           widget.mainReceipt.generalDiscount ==
                                                      //               null),
                                                      //   child: Text(
                                                      //     style: TextStyle(
                                                      //       decoration:
                                                      //           TextDecoration.lineThrough,
                                                      //       fontSize:
                                                      //           widget.theme.mobileTexts.b3.fontSize,
                                                      //       fontWeight:
                                                      //           FontWeight.normal,
                                                      //     ),
                                                      //     formatMoneyMid(
                                                      //       amount:
                                                      //           productRecord.originalCost!,
                                                      //       context:
                                                      //           context,
                                                      //     ),
                                                      //   ),
                                                      // ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                ),
                                Visibility(
                                  visible:
                                      recordsVoid
                                          .isNotEmpty,
                                  child: Column(
                                    children: [
                                      SizedBox(height: 15),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment
                                                .center,
                                        children: [
                                          Text(
                                            style: TextStyle(
                                              fontSize:
                                                  returnTheme(
                                                        context,
                                                      )
                                                      .mobileTexts
                                                      .b4
                                                      .fontSize,
                                              fontWeight:
                                                  FontWeight
                                                      .bold,
                                            ),
                                            'Deleted Items',
                                          ),
                                        ],
                                      ),
                                      Divider(height: 10),
                                      Column(
                                        children:
                                            recordsVoid.map((
                                              productRecord,
                                            ) {
                                              return Container(
                                                margin:
                                                    EdgeInsets.symmetric(
                                                      vertical:
                                                          2,
                                                    ),
                                                padding: const EdgeInsets.symmetric(
                                                  vertical:
                                                      4.0,
                                                  // horizontal:
                                                  //     10,
                                                ),
                                                decoration: BoxDecoration(
                                                  // color:
                                                  //     Colors
                                                  //         .red
                                                  //         .shade100,
                                                ),
                                                child: SizedBox(
                                                  child: Row(
                                                    spacing:
                                                        10,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Icon(
                                                        color:
                                                            Colors.red.shade500,
                                                        Icons.arrow_right,
                                                      ),
                                                      Expanded(
                                                        flex:
                                                            4,
                                                        child: Column(
                                                          spacing:
                                                              3,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              style: TextStyle(
                                                                fontSize:
                                                                    widget.theme.mobileTexts.b3.fontSize,
                                                              ),
                                                              '${productRecord.productName}${productRecord.dimensionsLabel()}',
                                                            ),
                                                            Visibility(
                                                              visible:
                                                                  productRecord.wastageNote().isNotEmpty,
                                                              child: Text(
                                                                style: TextStyle(
                                                                  fontSize:
                                                                      widget.theme.mobileTexts.b4.fontSize,
                                                                  color:
                                                                      Colors.grey.shade700,
                                                                ),
                                                                productRecord.wastageNote(),
                                                              ),
                                                            ),
                                                            Text(
                                                              style: TextStyle(
                                                                fontSize:
                                                                    widget.theme.mobileTexts.b4.fontSize,
                                                              ),
                                                              'Qty: ${productRecord.quantityText()} ${productRecord.unit == 'Others' || productRecord.unit == null ? 'Unit(s)' : productRecord.unit}',
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex:
                                                            3,
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment.start,
                                                          children: [
                                                            Text(
                                                              style: TextStyle(
                                                                fontSize:
                                                                    widget.theme.mobileTexts.b3.fontSize,
                                                                fontWeight:
                                                                    FontWeight.bold,
                                                              ),
                                                              formatMoneyMid(
                                                                amount:
                                                                    (widget.mainReceipt.fixedDiscount ==
                                                                                    null &&
                                                                                widget.mainReceipt.generalDiscount ==
                                                                                    null) &&
                                                                            productRecord.discount !=
                                                                                null
                                                                        ? ((productRecord.originalCost ??
                                                                                0) -
                                                                            (productRecord.discountedAmount ??
                                                                                0))
                                                                        : (productRecord.originalCost ??
                                                                            0),
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
                                              );
                                            }).toList(),
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
                    SizedBox(height: 5),
                    Divider(),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          children: [
                            Expanded(
                              flex: 4,
                              child: Text(
                                style: TextStyle(
                                  fontSize:
                                      widget
                                          .theme
                                          .mobileTexts
                                          .b4
                                          .fontSize,
                                ),
                                'Subtotal',
                              ),
                            ),

                            Expanded(
                              flex: 3,
                              child: Text(
                                style: TextStyle(
                                  fontSize:
                                      widget
                                          .theme
                                          .mobileTexts
                                          .b4
                                          .fontSize,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                                formatMoneyMid(
                                  amount:
                                      returnReceiptProvider(
                                        context,
                                      ).getOriginalCostReceipt(
                                        widget.mainReceipt,
                                      ),
                                  context: context,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Visibility(
                          visible:
                              widget
                                      .mainReceipt
                                      .generalDiscount !=
                                  null ||
                              widget
                                      .mainReceipt
                                      .fixedDiscount !=
                                  null,
                          child: Column(
                            children: [
                              SizedBox(height: 0),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: Row(
                                      children: [
                                        Text(
                                          style: TextStyle(
                                            fontSize:
                                                widget
                                                    .theme
                                                    .mobileTexts
                                                    .b4
                                                    .fontSize,
                                          ),
                                          'Discount',
                                        ),
                                        Text(
                                          style: TextStyle(
                                            fontSize:
                                                widget
                                                    .theme
                                                    .mobileTexts
                                                    .b4
                                                    .fontSize,
                                            fontWeight:
                                                FontWeight
                                                    .bold,
                                          ),
                                          widget.mainReceipt.generalDiscount !=
                                                  null
                                              ? ' (${widget.mainReceipt.generalDiscount}%)'
                                              : '',
                                        ),
                                      ],
                                    ),
                                  ),

                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      style: TextStyle(
                                        fontSize:
                                            widget
                                                .theme
                                                .mobileTexts
                                                .b4
                                                .fontSize,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                      formatMoneyMid(
                                        amount: returnReceiptProvider(
                                          context,
                                        ).getDiscountAmountForReceipt(
                                          widget
                                              .mainReceipt,
                                        ),
                                        context: context,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // SizedBox(height: 0),
                        Visibility(
                          visible:
                              widget.mainReceipt.vat !=
                                  null &&
                              widget.mainReceipt.vat != 0,
                          child: Column(
                            children: [
                              SizedBox(height: 2),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: Row(
                                      children: [
                                        Text(
                                          style: TextStyle(
                                            fontSize:
                                                widget
                                                    .theme
                                                    .mobileTexts
                                                    .b4
                                                    .fontSize,
                                            // fontWeight: FontWeight.bold,
                                          ),
                                          'VAT',
                                        ),
                                        Text(
                                          style: TextStyle(
                                            fontSize:
                                                widget
                                                    .theme
                                                    .mobileTexts
                                                    .b4
                                                    .fontSize,
                                            fontWeight:
                                                FontWeight
                                                    .bold,
                                            // fontWeight: FontWeight.bold,
                                          ),
                                          ' (${widget.mainReceipt.vat ?? 0}%)',
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      style: TextStyle(
                                        fontWeight:
                                            FontWeight.bold,
                                        fontSize:
                                            widget
                                                .theme
                                                .mobileTexts
                                                .b4
                                                .fontSize,
                                      ),
                                      formatMoney(
                                        returnReceiptProvider(
                                          context,
                                          listen: false,
                                        ).getVATForReceipt(
                                          widget
                                              .mainReceipt,
                                        ),
                                        context,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Visibility(
                          visible:
                              widget.mainReceipt.balance !=
                              null,
                          child: Column(
                            children: [
                              SizedBox(height: 2),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: Row(
                                      children: [
                                        Text(
                                          style: TextStyle(
                                            fontSize:
                                                widget
                                                    .theme
                                                    .mobileTexts
                                                    .b4
                                                    .fontSize,
                                            // fontWeight: FontWeight.bold,
                                          ),
                                          'Balance',
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      style: TextStyle(
                                        fontWeight:
                                            FontWeight.bold,
                                        fontSize:
                                            widget
                                                .theme
                                                .mobileTexts
                                                .b4
                                                .fontSize,
                                      ),
                                      formatMoney(
                                        widget
                                                .mainReceipt
                                                .balance ??
                                            0,

                                        context,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          children: [
                            Expanded(
                              flex: 4,
                              child: Text(
                                style: TextStyle(
                                  fontSize:
                                      widget
                                          .theme
                                          .mobileTexts
                                          .b2
                                          .fontSize,
                                ),
                                'Total',
                              ),
                            ),

                            Expanded(
                              flex: 3,
                              child: Text(
                                style: TextStyle(
                                  fontSize:
                                      widget
                                          .theme
                                          .mobileTexts
                                          .b2
                                          .fontSize,
                                  fontWeight:
                                      FontWeight.bold,
                                ),

                                formatMoneyMid(
                                  amount: returnReceiptProvider(
                                    context,
                                    listen: false,
                                  ).getTotalMainRevenueReceipt(
                                    widget.mainReceipt,
                                  ),
                                  context: context,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                // spacing: 10,
                children: [
                  Visibility(
                    visible: authorization(
                      authorized:
                          Authorizations().deleteSale,
                    ),
                    child: BottomActionButton(
                      textColor: Colors.red,
                      text: 'Delete',
                      color:
                          widget
                              .theme
                              .lightModeColor
                              .errorColor200,
                      iconSize: 20,
                      theme: widget.theme,
                      icon: Icons.delete_outline_rounded,
                      action: () {
                        final receiptP =
                            returnReceiptProvider(
                              context,
                              listen: false,
                            );
                        showDialog(
                          context: context,
                          builder: (confirmContext) {
                            return ConfirmationAlert(
                              theme: widget.theme,
                              message:
                                  'This action cannot be recovered. Are you sure you want to delete this sale receipt?',
                              title: 'Delete Receipt?',
                              action: () async {
                                Navigator.of(
                                  confirmContext,
                                ).pop();
                                setState(() {
                                  isLoading = true;
                                });
                                var deleteResult = 1;
                                if (widget.mainReceipt
                                        .getSalesTypeIndex() ==
                                    1) {
                                  await receiptP.deleteReceipt(
                                    widget.mainReceipt,
                                    records
                                        .map(
                                          (rec) =>
                                              rec.productName,
                                        )
                                        .toList(),
                                  );
                                } else if (widget
                                        .mainReceipt
                                        .getSalesTypeIndex() ==
                                    2) {
                                  await receiptP
                                      .deleteReceiptWithoutUpdatingInventory(
                                        receipt:
                                            widget
                                                .mainReceipt,
                                      );
                                } else if (widget
                                        .mainReceipt
                                        .getSalesTypeIndex() ==
                                    3) {
                                  deleteResult = await returnOrdersProvider()
                                      .deleteDeliveryReceipt(
                                        receipt:
                                            widget
                                                .mainReceipt,
                                        records: records,
                                        orderUuid:
                                            widget
                                                .mainReceipt
                                                .orderUuid,
                                      );
                                }

                                if (deleteResult != 1) {
                                  setState(() {
                                    isLoading = false;
                                  });
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(
                                      context,
                                    ).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Receipt was not deleted because its order quantities could not be restored safely.',
                                        ),
                                      ),
                                    );
                                  }
                                  return;
                                }

                                setState(() {
                                  isLoading = false;
                                  showSuccess = true;
                                });

                                await Future.delayed(
                                  Duration(
                                    milliseconds: 300,
                                  ),
                                );

                                if (context.mounted) {
                                  if (widget.isMain) {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                MakeSalesPage(),
                                      ),
                                    );
                                  } else {
                                    Navigator.of(
                                      context,
                                    ).pop();
                                  }
                                }
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                  Visibility(
                    visible:
                        authorization(
                          authorized:
                              Authorizations().updateSale,
                        ) &&
                        widget.mainReceipt.isInvoice ==
                            false,
                    child: BottomActionButton(
                      color: Colors.grey,
                      iconSize: 20,
                      theme: widget.theme,
                      icon: Icons.edit,
                      text: 'Edit',
                      action: () {
                        returnSalesProvider().onEditReceipt(
                          receipt: widget.mainReceipt,
                          context: context,
                        );
                      },
                    ),
                  ),
                  BottomActionButton(
                    action: () {
                      SalesAuthAction().downloadReceiptAction(
                        context: context,
                        action: () async {
                          var safeContext = context;

                          showDialog(
                            context: context,
                            builder: (context) {
                              return ConfirmationAlert(
                                theme: widget.theme,
                                message:
                                    'You are about to download This Receipt. Are you sure you want to Proceed?',
                                title: 'Download Receipt',
                                action: () async {
                                  returnReceiptProvider(
                                    context,
                                    listen: false,
                                  ).toggleIsLoading(true);
                                  Navigator.of(
                                    context,
                                  ).pop();
                                  if (kIsWeb) {
                                    downloadPdfWeb(
                                      staffName:
                                          staff?.name ??
                                          widget
                                              .mainReceipt
                                              .staffName ??
                                          'Not Set',
                                      filename:
                                          'downloaded_receipt_${DateTime.now().millisecondsSinceEpoch}.pdf',
                                      context: safeContext,
                                      receipt:
                                          widget
                                              .mainReceipt,
                                      records: records,
                                      shop:
                                          returnShopProvider()
                                              .userShop()!,
                                    );
                                  }
                                  if (!kIsWeb) {
                                    await generateAndPreviewPdf(
                                      staffName:
                                          staff?.name ??
                                          widget
                                              .mainReceipt
                                              .staffName ??
                                          'Not Set',
                                      context: safeContext,
                                      receipt:
                                          widget
                                              .mainReceipt,
                                      records: records,

                                      shop:
                                          returnShopProvider()
                                              .userShop()!,
                                    );
                                  }
                                  if (safeContext.mounted) {
                                    returnReceiptProvider(
                                      safeContext,
                                      listen: false,
                                    ).toggleIsLoading(
                                      false,
                                    );
                                  }
                                },
                              );
                            },
                          );
                        },
                      );
                    },
                    color: Colors.grey,
                    icon: Icons.download_outlined,
                    iconSize: 20,
                    theme: widget.theme,
                    text: 'Download',
                  ),
                  BottomActionButton(
                    action: () {
                      SalesAuthAction().printReceiptAction(
                        context: context,
                        action: () async {
                          var safeContext = context;
                          final printerSettings =
                              await AppPrinterService
                                  .loadSettings();
                          if (!safeContext.mounted) return;
                          if (!kIsWeb &&
                              !printerSettings.hasPrinter &&
                              returnShopProvider()
                                      .userShop()!
                                      .printType ==
                                  null) {
                            final saved =
                                await showPrinterSettingsDialog(
                                  safeContext,
                                );
                            if (saved == null ||
                                !safeContext.mounted) {
                              return;
                            }
                          }
                          if (!safeContext.mounted) return;
                          showDialog(
                              context: safeContext,
                              builder: (dialogContext) {
                                return ConfirmationAlert(
                                  theme: widget.theme,
                                  message:
                                      'You are about to Print This Receipt. Are you sure you want to Proceed?',
                                  title: 'Print Receipt',
                                  action: () async {
                                    returnReceiptProvider(
                                      dialogContext,
                                      listen: false,
                                    ).toggleIsLoading(true);
                                    Navigator.of(
                                      dialogContext,
                                    ).pop();
                                    final activeSettings =
                                        await AppPrinterService
                                            .loadSettings();
                                    if (activeSettings
                                            .documentType ==
                                        AppPrintDocumentType
                                            .a4) {
                                      if (!safeContext
                                          .mounted) {
                                        return;
                                      }
                                      await printReceiptA4Pdf(
                                        staffName:
                                            staff?.name ??
                                            widget
                                                .mainReceipt
                                                .staffName ??
                                            "Not Set",
                                        context: safeContext,
                                        receipt:
                                            widget
                                                .mainReceipt,
                                        records: records,
                                        shop:
                                            returnShopProvider()
                                                .userShop()!,
                                      );
                                    } else if (usesBluetoothPrint()) {
                                      if (!safeContext
                                          .mounted) {
                                        return;
                                      }
                                      scanBluetoothPrinters(
                                        receipt:
                                            widget
                                                .mainReceipt,
                                        context:
                                            safeContext,
                                        records: records,
                                        shop:
                                            returnShopProvider()
                                                .userShop()!,
                                        staffName:
                                            staff?.name ??
                                            widget
                                                .mainReceipt
                                                .staffName ??
                                            "Not Set",
                                      );
                                    } else {
                                      if (!safeContext
                                          .mounted) {
                                        return;
                                      }
                                      await generateAndPreviewPdfRoll(
                                        printerType:
                                            activeSettings
                                                .printerTypeInt,
                                        staffName:
                                            staff?.name ??
                                            widget
                                                .mainReceipt
                                                .staffName ??
                                            "Not Set",
                                        context:
                                            safeContext,
                                        receipt:
                                            widget
                                                .mainReceipt,
                                        records: records,
                                        shop:
                                            returnShopProvider()
                                                .userShop()!,
                                      );
                                    }
                                    if (safeContext
                                            .mounted &&
                                        kIsWeb) {
                                      returnReceiptProvider(
                                        safeContext,
                                        listen: false,
                                      ).toggleIsLoading(
                                        false,
                                      );
                                    }
                                  },
                                );
                              },
                            );
                        },
                      );
                    },
                    color: Colors.grey,
                    icon: Icons.print,
                    iconSize: 20,
                    theme: widget.theme,
                    text: 'Print',
                  ),
                ],
              ),
            ),
          ],
        ),
        Visibility(
          visible: returnReceiptProvider(context).isLoading,
          child: Container(
            color: Colors.grey,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width - 50,
            child: returnCompProvider(
              context,
              listen: false,
            ).showLoader(message: 'Generating Receipt'),
          ),
        ),
        Visibility(
          visible: isLoading,
          child: Container(
            color: Colors.grey,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width - 50,
            child: returnCompProvider(
              context,
              listen: false,
            ).showLoader(message: 'Loading'),
          ),
        ),
        Visibility(
          visible: showSuccess,
          child: Container(
            color: Colors.grey,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width - 50,
            child: returnCompProvider(
              context,
              listen: false,
            ).showSuccess('Completed Successfully'),
          ),
        ),
      ],
    );
  }
}

class BottomActionButton extends StatelessWidget {
  final String? text;
  final Function()? action;
  final IconData? icon;
  final Color color;
  final double iconSize;
  final ThemeProvider theme;
  final String? svg;
  final Color? textColor;

  const BottomActionButton({
    super.key,
    this.text,
    this.action,
    this.icon,
    required this.color,
    required this.iconSize,
    required this.theme,
    this.svg,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 5.0,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            mouseCursor: SystemMouseCursors.click,
            onTap: action,
            borderRadius: BorderRadius.circular(5),
            child: Container(
              height: 40,
              padding: EdgeInsets.symmetric(
                vertical: 7,
                horizontal: 10,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: Colors.grey.shade400,
                ),
              ),
              child: Center(
                child: Row(
                  // spacing: 5,
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Visibility(
                      visible: text != null,
                      child: Text(
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: textColor ?? Colors.grey,
                          fontSize:
                              theme.mobileTexts.b3.fontSize,
                        ),
                        text ?? '',
                      ),
                    ),
                    Visibility(
                      visible: text == null,
                      child: Stack(
                        children: [
                          Visibility(
                            visible: icon != null,
                            child: Icon(
                              size: iconSize,
                              color: color,
                              icon ??
                                  Icons
                                      .delete_outline_rounded,
                            ),
                          ),
                          Visibility(
                            visible: svg != null,
                            child: SvgPicture.asset(
                              svg ?? '',
                              height: iconSize,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
