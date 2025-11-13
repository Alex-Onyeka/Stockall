import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stockall/classes/temp_customers/temp_customers_class.dart';
import 'package:stockall/classes/temp_main_receipt/temp_main_receipt.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/classes/user_class/temp_user_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/major/top_banner_two.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/home/home.dart';
import 'package:stockall/providers/theme_provider.dart';
import 'package:stockall/services/auth_service.dart';
import 'package:stockall/services/printing/import_helper.dart'
    show connectToUsbDevice, scanBluetoothPrinters;

class ReceiptPageMobile extends StatefulWidget {
  final bool isMain;
  final String receiptUuid;
  const ReceiptPageMobile({
    super.key,
    required this.receiptUuid,
    required this.isMain,
  });

  @override
  State<ReceiptPageMobile> createState() =>
      _ReceiptPageMobileState();
}

class _ReceiptPageMobileState
    extends State<ReceiptPageMobile> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      returnReceiptProvider(
        context,
        listen: false,
      ).toggleIsLoading(false);
    });
    if (widget.isMain) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        returnReceiptProvider(
          context,
          listen: false,
        ).loadReceipts(
          returnShopProvider(
            context,
            listen: false,
          ).userShop()!.shopId!,
          context,
        );
      });
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    var shop = returnShopProvider(context).userShop();
    var theme = returnTheme(context);
    TempMainReceipt mainReceipt = returnReceiptProvider(
      context,
    ).receipts.firstWhere(
      (rec) => rec.uuid! == widget.receiptUuid,
      orElse:
          () => TempMainReceipt(
            createdAt: DateTime.now(),
            uuid: '1',
            shopId: shopId(context),
            staffId: AuthService().currentUser!,
            staffName: 'Staff Name',
            paymentMethod: 'Cash',
            bank: 0,
            cashAlt: 0,
            isInvoice: false,
          ),
    );
    return SafeArea(
      child: PopScope(
        canPop: false,
        child: Scaffold(
          body: Column(
            children: [
              SizedBox(
                height:
                    MediaQuery.of(context).size.height - 30,
                child: Stack(
                  alignment: Alignment(0, 1),
                  children: [
                    Align(
                      alignment: Alignment(0, -1),
                      child: TopBannerTwo(
                        isMain: widget.isMain,
                        title:
                            mainReceipt.isInvoice == true
                                ? 'Invoice'
                                : 'Receipt',
                        theme: theme,
                        bottomSpace: 200,
                        topSpace: 10,
                      ),
                    ),
                    Align(
                      alignment: Alignment(0.95, -0.95),
                      child: PopupMenuButton(
                        offset: Offset(-20, 30),
                        color: Colors.white,
                        itemBuilder: (context) {
                          return [
                            PopupMenuItem(
                              onTap: () {
                                returnShopProvider(
                                  context,
                                  listen: false,
                                ).updatePrintType(
                                  shopId: shopId(context),
                                  type: 1,
                                );
                              },
                              child: Text(
                                style: TextStyle(
                                  fontSize:
                                      theme
                                          .mobileTexts
                                          .b2
                                          .fontSize,
                                  fontWeight:
                                      returnShopProvider(
                                                    context,
                                                    listen:
                                                        false,
                                                  ).userShop()!.printType !=
                                                  null &&
                                              returnShopProvider(
                                                    context,
                                                    listen:
                                                        false,
                                                  ).userShop()!.printType ==
                                                  1
                                          ? FontWeight.bold
                                          : null,
                                ),
                                kIsWeb
                                    ? 'Printer Type -- 58mm'
                                    : 'Select USB Printer',
                              ),
                            ),
                            PopupMenuItem(
                              onTap: () {
                                returnShopProvider(
                                  context,
                                  listen: false,
                                ).updatePrintType(
                                  shopId: shopId(context),
                                  type: 2,
                                );
                              },
                              child: Text(
                                style: TextStyle(
                                  fontSize:
                                      theme
                                          .mobileTexts
                                          .b2
                                          .fontSize,
                                  fontWeight:
                                      returnShopProvider(
                                                    context,
                                                    listen:
                                                        false,
                                                  ).userShop()!.printType !=
                                                  null &&
                                              returnShopProvider(
                                                    context,
                                                    listen:
                                                        false,
                                                  ).userShop()!.printType ==
                                                  2
                                          ? FontWeight.bold
                                          : null,
                                ),
                                kIsWeb
                                    ? 'Printer Type -- 80mm'
                                    : 'Select Bluetooth Printer',
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
                              mainAxisSize:
                                  MainAxisSize.min,
                              children: [
                                Text(
                                  style: TextStyle(
                                    fontSize:
                                        theme
                                            .mobileTexts
                                            .b4
                                            .fontSize,
                                    color: Colors.white,
                                  ),
                                  'Printer Type:',
                                ),
                                Text(
                                  style: TextStyle(
                                    fontSize:
                                        theme
                                            .mobileTexts
                                            .b2
                                            .fontSize,
                                    color: Colors.white,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                  returnShopProvider(
                                                    context,
                                                    listen:
                                                        false,
                                                  )
                                                  .userShop()!
                                                  .printType !=
                                              null &&
                                          returnShopProvider(
                                                    context,
                                                    listen:
                                                        false,
                                                  )
                                                  .userShop()!
                                                  .printType ==
                                              2
                                      ? (kIsWeb
                                          ? '80mm'
                                          : '( Bluetooth )')
                                      : returnShopProvider(
                                                    context,
                                                    listen:
                                                        false,
                                                  )
                                                  .userShop()!
                                                  .printType !=
                                              null &&
                                          returnShopProvider(
                                                    context,
                                                    listen:
                                                        false,
                                                  )
                                                  .userShop()!
                                                  .printType ==
                                              1
                                      ? (kIsWeb
                                          ? '58mm'
                                          : '( USB )')
                                      // : sortIndex == 2
                                      // ? 'Price'
                                      : 'Settings',
                                ),
                              ],
                            ),
                            Icon(Icons.more_vert_rounded),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 55,
                      child: SizedBox(
                        height:
                            MediaQuery.of(
                              context,
                            ).size.height -
                            25,
                        child: ReceiptDetailsContainer(
                          isMain: widget.isMain,
                          shop: shop!,
                          mainReceipt: mainReceipt,
                          theme: theme,
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
      returnShopProvider(
        context,
        listen: false,
      ).switchLogoPicked(false);
      setState(() {});
    });
  }

  // late Future<void> getLogoFuture;
  Future<void> getLogo() async {
    returnShopProvider(
      context,
      listen: false,
    ).getLogoImage(context);
  }

  @override
  Widget build(BuildContext context) {
    var records =
        returnReceiptProvider(context).produtRecordSalesMain
            .where(
              (record) =>
                  record.receiptUuid ==
                  widget.mainReceipt.uuid!,
            )
            .toList();
    TempCustomersClass? customer;

    try {
      customer = returnCustomers(
        context,
      ).customersMain.firstWhere(
        (c) => c.uuid == widget.mainReceipt.customerUuid,
      );
    } catch (e) {
      customer = null; // not found
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
                            SizedBox(height: 5),
                            // GestureDetector(
                            //   onTap: () {
                            //     returnShopProvider(
                            //       context,
                            //       listen: false,
                            //     ).deletePrinter();
                            //   },
                            //   child: Image.asset(
                            //     mainLogoIcon,
                            //     height: 40,
                            //   ),
                            // ),
                            Builder(
                              builder: (context) {
                                if (returnShopProvider(
                                      context,
                                    ).selectedLogo !=
                                    null) {
                                  return Container(
                                    height:
                                        (returnShopProvider(
                                                      context,
                                                    ).imageWidth ??
                                                    0) >
                                                (2 *
                                                    (returnShopProvider(
                                                          context,
                                                        ).imageHeight ??
                                                        0))
                                            ? 35
                                            : 90,
                                    width: double.infinity,
                                    decoration:
                                        BoxDecoration(),
                                    child: Image.memory(
                                      returnShopProvider(
                                        context,
                                      ).selectedLogo!,
                                      fit: BoxFit.contain,
                                    ),
                                  );
                                } else {
                                  return Container();
                                }
                              },
                            ),
                            SizedBox(height: 10),
                            Column(
                              // spacing: 8,
                              children: [
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
                                      SizedBox(height: 2),
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
                                      SizedBox(height: 2),
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
                                      SizedBox(height: 2),
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
                                      SizedBox(height: 2),
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
                                      SizedBox(height: 2),
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
                                  widget.shop.showFirst!,
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
                                                    .b1
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
                                                  .staffName,
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
                                                    .b1
                                                    .fontSize,
                                            fontWeight:
                                                FontWeight
                                                    .bold,
                                          ),
                                          'Customer Name',
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
                                          customer?.name ??
                                              'Not Saved',
                                        ),
                                      ],
                                    ),
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
                                                        .b1
                                                        .fontSize,
                                                fontWeight:
                                                    FontWeight
                                                        .bold,
                                              ),
                                              'Payment Method',
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
                                                  .paymentMethod,
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
                                                        .b1
                                                        .fontSize,
                                                fontWeight:
                                                    FontWeight
                                                        .bold,
                                              ),
                                              'Amount(s)',
                                            ),
                                            Column(
                                              children: [
                                                Visibility(
                                                  visible:
                                                      widget.mainReceipt.paymentMethod ==
                                                          'Split' ||
                                                      widget.mainReceipt.paymentMethod ==
                                                          'Cash',
                                                  child: Row(
                                                    spacing:
                                                        5,
                                                    children: [
                                                      Text(
                                                        style: TextStyle(
                                                          fontSize:
                                                              widget.theme.mobileTexts.b3.fontSize,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                        ),
                                                        'Cash:',
                                                      ),
                                                      Text(
                                                        style: TextStyle(
                                                          fontSize:
                                                              widget.theme.mobileTexts.b3.fontSize,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                        formatMoneyMid(
                                                          amount:
                                                              widget.mainReceipt.cashAlt,
                                                          context:
                                                              context,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Visibility(
                                                  visible:
                                                      widget.mainReceipt.paymentMethod ==
                                                          'Split' ||
                                                      widget.mainReceipt.paymentMethod ==
                                                          'Bank',
                                                  child: Row(
                                                    spacing:
                                                        5,
                                                    children: [
                                                      Text(
                                                        style: TextStyle(
                                                          fontSize:
                                                              widget.theme.mobileTexts.b3.fontSize,
                                                          fontWeight:
                                                              FontWeight.normal,
                                                        ),
                                                        'Bank:',
                                                      ),
                                                      Text(
                                                        style: TextStyle(
                                                          fontSize:
                                                              widget.theme.mobileTexts.b3.fontSize,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                        formatMoneyMid(
                                                          amount:
                                                              widget.mainReceipt.bank,
                                                          context:
                                                              context,
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
                                                        .b1
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
                                                        .b2
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
                                                        .b1
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
                                                        .b2
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
                            SizedBox(height: 10),
                            Divider(),
                            Row(
                              children: [
                                Text(
                                  style: TextStyle(
                                    fontSize:
                                        widget
                                            .theme
                                            .mobileTexts
                                            .b1
                                            .fontSize,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                  'Item Record',
                                ),
                              ],
                            ),
                            ListView.builder(
                              physics:
                                  NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: records.length,
                              itemBuilder: (
                                context,
                                index,
                              ) {
                                var productRecord =
                                    records[index];

                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(
                                        vertical: 8.0,
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
                                            spacing: 3,
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
                                                          .b1
                                                          .fontSize,
                                                ),
                                                productRecord
                                                    .productName,
                                              ),
                                              Text(
                                                style: TextStyle(
                                                  fontSize:
                                                      widget
                                                          .theme
                                                          .mobileTexts
                                                          .b3
                                                          .fontSize,
                                                ),
                                                'Qty: ${productRecord.quantity.toStringAsFixed(0)} Item(s)',
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
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
                                                          .b1
                                                          .fontSize,
                                                  fontWeight:
                                                      FontWeight
                                                          .bold,
                                                ),
                                                formatMoneyMid(
                                                  amount:
                                                      productRecord
                                                          .revenue,
                                                  context:
                                                      context,
                                                ),
                                              ),
                                              // Visibility(
                                              //   visible:
                                              //       productRecord.discount !=
                                              //           null &&
                                              //       !productRecord
                                              //           .customPriceSet,
                                              //   child: Text(
                                              //     style: TextStyle(
                                              //       decoration:
                                              //           TextDecoration.lineThrough,
                                              //       fontSize:
                                              //           widget.theme.mobileTexts.b2.fontSize,
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
                              },
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
                                          .b2
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
                                          .b2
                                          .fontSize,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                                formatMoneyMid(
                                  amount: returnReceiptProvider(
                                    context,
                                    listen: false,
                                  ).getSubTotalRevenueForReceipt(
                                    context,
                                    records,
                                  ),
                                  context: context,
                                ),
                              ),
                            ),
                          ],
                        ),
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
                                              .b2
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
                                              .b2
                                              .fontSize,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                    widget
                                                .mainReceipt
                                                .generalDiscount !=
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
                                          .b2
                                          .fontSize,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                                formatMoneyMid(
                                  amount:
                                      returnReceiptProvider(
                                        context,
                                        listen: false,
                                      ).getTotalMainRevenueReceipt(
                                        records,
                                        context,
                                      ) -
                                      returnReceiptProvider(
                                        context,
                                        listen: false,
                                      ).getSubTotalRevenueForReceipt(
                                        context,
                                        records,
                                      ),
                                  context: context,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 0),
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
                                          .b1
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
                                          .b1
                                          .fontSize,
                                  fontWeight:
                                      FontWeight.bold,
                                ),

                                formatMoneyMid(
                                  amount: returnReceiptProvider(
                                    context,
                                    listen: false,
                                  ).getTotalMainRevenueReceipt(
                                    records,
                                    context,
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
                spacing: 10,
                children: [
                  Visibility(
                    visible:
                        authorization(
                          authorized:
                              Authorizations().deleteSale,
                          context: context,
                        ) ||
                        widget.mainReceipt.isInvoice,
                    child: BottomActionButton(
                      text:
                          widget.mainReceipt.isInvoice
                              ? 'Pay'
                              : null,
                      color:
                          widget.mainReceipt.isInvoice
                              ? widget
                                  .theme
                                  .lightModeColor
                                  .secColor200
                              : widget
                                  .theme
                                  .lightModeColor
                                  .errorColor200,
                      iconSize: 20,
                      theme: widget.theme,
                      icon:
                          widget.mainReceipt.isInvoice
                              ? Icons.check
                              : Icons
                                  .delete_outline_rounded,
                      action: () {
                        final receiptP =
                            returnReceiptProvider(
                              context,
                              listen: false,
                            );
                        final shopId =
                            returnShopProvider(
                              context,
                              listen: false,
                            ).userShop()!.shopId!;
                        var safeContext = context;
                        if (!widget.mainReceipt.isInvoice) {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return ConfirmationAlert(
                                theme: widget.theme,
                                message:
                                    'This action cannot be recovered. Are you sure you want to delete this sale receipt?',
                                title: 'Delete Receipt?',
                                action: () async {
                                  Navigator.of(
                                    safeContext,
                                  ).pop();
                                  setState(() {
                                    isLoading = true;
                                  });

                                  await receiptP
                                      .deleteReceipt(
                                        widget
                                            .mainReceipt
                                            .uuid!,
                                        context,
                                      );

                                  if (safeContext.mounted) {
                                    await receiptP
                                        .loadReceipts(
                                          shopId,
                                          context,
                                        );
                                  }

                                  setState(() {
                                    isLoading = false;
                                    showSuccess = true;
                                  });

                                  await Future.delayed(
                                    Duration(
                                      milliseconds: 1500,
                                    ),
                                  );

                                  if (safeContext.mounted) {
                                    Navigator.pushReplacement(
                                      safeContext,
                                      MaterialPageRoute(
                                        builder:
                                            (safeContext) =>
                                                Home(),
                                      ),
                                    );
                                    returnNavProvider(
                                      safeContext,
                                      listen: false,
                                    ).navigate(2);
                                  }
                                },
                              );
                            },
                          );
                        } else {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return ConfirmationAlert(
                                theme: widget.theme,
                                message:
                                    'Are you sure you want to proceed with action? This action cannot be reverted.',
                                title: 'Record as Paid?',
                                action: () async {
                                  Navigator.of(
                                    safeContext,
                                  ).pop();
                                  setState(() {
                                    isLoading = true;
                                  });

                                  await receiptP.payCredit(
                                    widget
                                        .mainReceipt
                                        .uuid!,
                                  );

                                  if (safeContext.mounted) {
                                    await receiptP
                                        .loadReceipts(
                                          shopId,
                                          context,
                                        );
                                  }

                                  setState(() {
                                    isLoading = false;
                                    showSuccess = true;
                                  });

                                  await Future.delayed(
                                    Duration(
                                      milliseconds: 1500,
                                    ),
                                  );

                                  setState(() {
                                    showSuccess = false;
                                  });
                                },
                              );
                            },
                          );
                        }
                      },
                    ),
                  ),
                  Visibility(
                    visible: authorization(
                      authorized:
                          Authorizations().updateSale,
                      context: context,
                    ),
                    child: BottomActionButton(
                      // text:
                      //     widget.mainReceipt.isInvoice
                      //         ? 'Pay Credit'
                      //         : 'Delete',
                      color: Colors.grey,
                      iconSize: 20,
                      theme: widget.theme,
                      icon: Icons.edit,
                      action: () {
                        returnSalesProvider(
                          context,
                          listen: false,
                        ).onEditReceipt(
                          receipt: widget.mainReceipt,
                          context: context,
                        );
                      },
                    ),
                  ),
                  BottomActionButton(
                    action: () async {
                      var safeContext = context;
                      if (!kIsWeb) {
                        await generateAndPreviewPdf(
                          staffName:
                              staff?.name ??
                              widget.mainReceipt.staffName,
                          context: safeContext,
                          receipt: widget.mainReceipt,
                          records: records,

                          shop:
                              returnShopProvider(
                                safeContext,
                                listen: false,
                              ).userShop()!,
                        );
                      } else {
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
                                Navigator.of(context).pop();
                                if (kIsWeb) {
                                  downloadPdfWeb(
                                    staffName:
                                        staff?.name ??
                                        widget
                                            .mainReceipt
                                            .staffName,
                                    filename:
                                        'Stockall_${widget.mainReceipt.isInvoice ? 'Invoice' : 'Receipt'}_${widget.mainReceipt.uuid}.pdf',
                                    context: safeContext,
                                    receipt:
                                        widget.mainReceipt,
                                    records: records,
                                    shop:
                                        returnShopProvider(
                                          safeContext,
                                          listen: false,
                                        ).userShop()!,
                                  );
                                }
                              },
                            );
                          },
                        );
                      }
                      if (safeContext.mounted) {
                        returnReceiptProvider(
                          safeContext,
                          listen: false,
                        ).toggleIsLoading(false);
                      }
                    },
                    // text:
                    //     (kIsWeb ||
                    //             (platforms(context) ==
                    //                     TargetPlatform
                    //                         .windows ||
                    //                 platforms(context) ==
                    //                     TargetPlatform
                    //                         .macOS ||
                    //                 platforms(context) ==
                    //                     TargetPlatform
                    //                         .linux))
                    //         ? 'Download'
                    //         : 'Share',
                    color: Colors.grey,
                    icon:
                        (kIsWeb ||
                                (platforms(context) ==
                                        TargetPlatform
                                            .windows ||
                                    platforms(context) ==
                                        TargetPlatform
                                            .macOS ||
                                    platforms(context) ==
                                        TargetPlatform
                                            .linux))
                            ? Icons.download_outlined
                            : Icons.share,
                    iconSize: 20,
                    theme: widget.theme,
                  ),
                  BottomActionButton(
                    action: () {
                      var safeContext = context;
                      if (returnShopProvider(
                            context,
                            listen: false,
                          ).userShop()!.printType ==
                          null) {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              backgroundColor: Colors.white,
                              title: Text(
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                                'SELECT PRINTER TYPE',
                              ),
                              content: Column(
                                mainAxisSize:
                                    MainAxisSize.min,
                                children: [
                                  Divider(
                                    color:
                                        Colors
                                            .grey
                                            .shade200,
                                    height: 0,
                                  ),
                                  ListTile(
                                    onTap: () async {
                                      Navigator.of(
                                        context,
                                      ).pop();
                                      returnReceiptProvider(
                                        safeContext,
                                        listen: false,
                                      ).toggleIsLoading(
                                        true,
                                      );
                                      await returnShopProvider(
                                        safeContext,
                                        listen: false,
                                      ).updatePrintType(
                                        shopId: shopId(
                                          safeContext,
                                        ),
                                        type: 1,
                                      );

                                      if (safeContext
                                          .mounted) {
                                        returnReceiptProvider(
                                          safeContext,
                                          listen: false,
                                        ).toggleIsLoading(
                                          false,
                                        );
                                      }
                                    },
                                    title: Text(
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                      kIsWeb
                                          ? 'Select Paper Size -- 58mm'
                                          : 'Select Type - USB',
                                    ),
                                    trailing: Container(
                                      padding:
                                          EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(
                                              2,
                                            ),
                                        border: Border.all(
                                          color:
                                              returnShopProvider(
                                                        safeContext,
                                                      ).userShop()!.printType ==
                                                      1
                                                  ? Colors
                                                      .grey
                                                  : Colors
                                                      .transparent,
                                        ),
                                        color:
                                            returnShopProvider(
                                                      safeContext,
                                                    ).userShop()!.printType ==
                                                    1
                                                ? widget
                                                    .theme
                                                    .lightModeColor
                                                    .prColor250
                                                : Colors
                                                    .transparent,
                                      ),
                                      child: Opacity(
                                        opacity:
                                            returnShopProvider(
                                                      safeContext,
                                                    ).userShop()!.printType ==
                                                    1
                                                ? 1
                                                : 0,
                                        child: Icon(
                                          size: 14,
                                          color:
                                              Colors.white,
                                          Icons.check,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Divider(
                                    color:
                                        Colors
                                            .grey
                                            .shade200,
                                    height: 5,
                                  ),
                                  ListTile(
                                    onTap: () async {
                                      Navigator.of(
                                        context,
                                      ).pop();
                                      returnReceiptProvider(
                                        safeContext,
                                        listen: false,
                                      ).toggleIsLoading(
                                        true,
                                      );
                                      await returnShopProvider(
                                        safeContext,
                                        listen: false,
                                      ).updatePrintType(
                                        shopId: shopId(
                                          safeContext,
                                        ),
                                        type: 2,
                                      );

                                      if (safeContext
                                          .mounted) {
                                        returnReceiptProvider(
                                          safeContext,
                                          listen: false,
                                        ).toggleIsLoading(
                                          false,
                                        );
                                      }
                                    },
                                    title: Text(
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                      kIsWeb
                                          ? 'Select Paper Size -- 80mm'
                                          : 'Select Type - Bluetooth',
                                    ),
                                    trailing: Container(
                                      padding:
                                          EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(
                                              2,
                                            ),
                                        border: Border.all(
                                          color:
                                              returnShopProvider(
                                                        safeContext,
                                                      ).userShop()!.printType ==
                                                      2
                                                  ? Colors
                                                      .grey
                                                  : Colors
                                                      .transparent,
                                        ),
                                        color:
                                            returnShopProvider(
                                                      safeContext,
                                                    ).userShop()!.printType ==
                                                    2
                                                ? widget
                                                    .theme
                                                    .lightModeColor
                                                    .prColor250
                                                : Colors
                                                    .transparent,
                                      ),
                                      child: Opacity(
                                        opacity:
                                            returnShopProvider(
                                                      safeContext,
                                                    ).userShop()!.printType ==
                                                    2
                                                ? 1
                                                : 0,
                                        child: Icon(
                                          size: 14,
                                          color:
                                              Colors.white,
                                          Icons.check,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return ConfirmationAlert(
                              theme: widget.theme,
                              message:
                                  'You are about to Print This Receipt. Are you sure you want to Proceed?',
                              title: 'Print Receipt',
                              action: () async {
                                returnReceiptProvider(
                                  context,
                                  listen: false,
                                ).toggleIsLoading(true);
                                Navigator.of(context).pop();
                                if (kIsWeb) {
                                  downloadPdfWebRoll(
                                    staffName:
                                        staff?.name ??
                                        widget
                                            .mainReceipt
                                            .staffName,
                                    filename:
                                        'Stockall_${widget.mainReceipt.isInvoice ? 'Invoice' : 'Receipt'}_${widget.mainReceipt.uuid}.pdf',
                                    context: safeContext,
                                    receipt:
                                        widget.mainReceipt,
                                    records: records,
                                    shop:
                                        returnShopProvider(
                                          safeContext,
                                          listen: false,
                                        ).userShop()!,
                                    printType:
                                        shop(
                                          context,
                                        )!.printType!,
                                  );
                                }
                                if (!kIsWeb) {
                                  // await printWithRawBT(
                                  //   fileName:
                                  //       'Alex Printing',
                                  //   context: safeContext,
                                  //   receipt:
                                  //       widget.mainReceipt,
                                  //   records: records,
                                  //   printerType:
                                  //       returnShopProvider(
                                  //             context,
                                  //             listen: false,
                                  //           )
                                  //           . userShop()!
                                  //           .printType ??
                                  //       1,
                                  //   shop:
                                  //       returnShopProvider(
                                  //         safeContext,
                                  //         listen: false,
                                  //       ). userShop()!,
                                  // );

                                  if (returnShopProvider(
                                            context,
                                            listen: false,
                                          )
                                          .userShop()!
                                          .printType! ==
                                      1) {
                                    await connectToUsbDevice(
                                      receipt:
                                          widget
                                              .mainReceipt,
                                      context: safeContext,
                                      records: records,
                                      shop:
                                          returnShopProvider(
                                            context,
                                            listen: false,
                                          ).userShop()!,
                                    );
                                  } else {
                                    print(
                                      'Bluetooth Scanning Started',
                                    );
                                    scanBluetoothPrinters(
                                      receipt:
                                          widget
                                              .mainReceipt,
                                      context: safeContext,
                                      records: records,
                                      shop:
                                          returnShopProvider(
                                            context,
                                            listen: false,
                                          ).userShop()!,
                                    );
                                  }
                                }
                                if (safeContext.mounted &&
                                    kIsWeb) {
                                  returnReceiptProvider(
                                    safeContext,
                                    listen: false,
                                  ).toggleIsLoading(false);
                                }
                              },
                            );
                          },
                        );
                      }
                    },
                    color: Colors.grey,
                    icon: Icons.print,
                    iconSize: 20,
                    theme: widget.theme,
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

  const BottomActionButton({
    super.key,
    this.text,
    this.action,
    this.icon,
    required this.color,
    required this.iconSize,
    required this.theme,
    this.svg,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
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
                spacing: 5,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Visibility(
                    visible: text != null,
                    child: Text(
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color:
                            theme
                                .lightModeColor
                                .secColor100,
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
    );
  }
}
