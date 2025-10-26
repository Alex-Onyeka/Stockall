import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/major/top_banner_two.dart';
import 'package:stockall/components/text_fields/general_textfield_only.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/shop_setup/edit_receipt_page/platforms/edit_receipt_page_desktop.dart';
import 'package:stockall/providers/theme_provider.dart';

class EditReceiptPageMobile extends StatefulWidget {
  const EditReceiptPageMobile({super.key});

  @override
  State<EditReceiptPageMobile> createState() =>
      _EditReceiptPageMobileState();
}

class _EditReceiptPageMobileState
    extends State<EditReceiptPageMobile> {
  @override
  Widget build(BuildContext context) {
    var shop = returnShopProvider(context).userShop;
    var theme = returnTheme(context);
    return SafeArea(
      child: PopScope(
        canPop: false,
        child: Scaffold(
          body: Column(
            children: [
              SizedBox(
                height:
                    MediaQuery.of(context).size.height - 20,
                child: Stack(
                  alignment: Alignment(0, 1),
                  children: [
                    Align(
                      alignment: Alignment(0, -1),
                      child: TopBannerTwo(
                        isMain: false,
                        title: 'Edit Receipt Template',
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
                                                  ).userShop!.printType !=
                                                  null &&
                                              returnShopProvider(
                                                    context,
                                                    listen:
                                                        false,
                                                  ).userShop!.printType ==
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
                                                  ).userShop!.printType !=
                                                  null &&
                                              returnShopProvider(
                                                    context,
                                                    listen:
                                                        false,
                                                  ).userShop!.printType ==
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
                                                  .userShop!
                                                  .printType !=
                                              null &&
                                          returnShopProvider(
                                                    context,
                                                    listen:
                                                        false,
                                                  )
                                                  .userShop!
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
                                                  .userShop!
                                                  .printType !=
                                              null &&
                                          returnShopProvider(
                                                    context,
                                                    listen:
                                                        false,
                                                  )
                                                  .userShop!
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
                      top: 60,
                      child: SizedBox(
                        height:
                            MediaQuery.of(
                              context,
                            ).size.height -
                            20,
                        child: ReceiptEditContainer(
                          isMain: false,
                          shop: shop!,
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

class ReceiptEditContainer extends StatefulWidget {
  final bool isMain;
  final TempShopClass shop;
  final ThemeProvider theme;
  const ReceiptEditContainer({
    super.key,
    required this.theme,
    required this.shop,
    required this.isMain,
  });

  @override
  State<ReceiptEditContainer> createState() =>
      _ReceiptEditContainerState();
}

class _ReceiptEditContainerState
    extends State<ReceiptEditContainer> {
  bool isLoading = false;
  bool showSuccess = false;
  final _formState = GlobalKey<FormState>();

  final bottomTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var receipP = returnShopProvider(context).userShop!;
    var receiptPFalse = returnShopProvider(
      context,
      listen: false,
    );
    return Stack(
      children: [
        Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width - 40,
              height:
                  MediaQuery.of(context).size.height - 140,
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
                            // SizedBox(height: 15),
                            Column(
                              spacing: 3,
                              children: [
                                Text(
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
                                ToggleElement(
                                  action: () {
                                    receiptPFalse
                                        .showEmailAction();
                                  },
                                  element: Text(
                                    style: TextStyle(
                                      fontSize:
                                          widget
                                              .theme
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
                                    widget.shop.email,
                                  ),
                                  value: receipP.showEmail!,
                                ),
                                ToggleElement(
                                  action: () {
                                    receiptPFalse
                                        .showAddressAction();
                                  },
                                  element: Text(
                                    style: TextStyle(
                                      fontSize:
                                          widget
                                              .theme
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
                                    widget
                                            .shop
                                            .shopAddress ??
                                        'Address Not Set',
                                  ),

                                  value:
                                      receipP.showAddress!,
                                ),
                                ToggleElement(
                                  action: () {
                                    receiptPFalse
                                        .showPhoneAction();
                                  },
                                  element: Text(
                                    style: TextStyle(
                                      fontSize:
                                          widget
                                              .theme
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
                                    widget
                                            .shop
                                            .phoneNumber ??
                                        'Phone Not Set',
                                  ),
                                  value: receipP.showPhone!,
                                ),
                                ToggleElement(
                                  value:
                                      receipP.instaHandle ==
                                              null
                                          ? false
                                          : receipP
                                              .showInstaTop!,
                                  element: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .center,
                                    spacing: 10,
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
                                        "Instagram: ${widget.shop.instaHandle ?? 'Instagram Not Set'}",
                                      ),
                                    ],
                                  ),
                                  action: () {
                                    if (receiptPFalse
                                            .userShop!
                                            .instaHandle ==
                                        null) {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return InfoAlert(
                                            theme:
                                                widget
                                                    .theme,
                                            message:
                                                'You can\'t turn this on because you have not set Your Instagram handle. Go to your Shop Profile to Set your Instagram Handle.',
                                            title:
                                                'Instagram Handle Not Set',
                                          );
                                        },
                                      );
                                    } else {
                                      receiptPFalse
                                          .showInstaTopAction();
                                    }
                                  },
                                ),
                                ToggleElement(
                                  value:
                                      receipP.faceBookHandle ==
                                              null
                                          ? false
                                          : receipP
                                              .showFacebookTop!,
                                  element: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .center,
                                    spacing: 10,
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
                                        "Facebook: ${widget.shop.faceBookHandle ?? 'FaceBook Not Set'}",
                                      ),
                                    ],
                                  ),
                                  action: () {
                                    if (receiptPFalse
                                            .userShop!
                                            .faceBookHandle ==
                                        null) {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return InfoAlert(
                                            theme:
                                                widget
                                                    .theme,
                                            message:
                                                'You can\'t turn this on because you have not set Your Facebook handle. Go to your Shop Profile to Set your Facebook Handle.',
                                            title:
                                                'FaceBook Handle Not Set',
                                          );
                                        },
                                      );
                                    } else {
                                      receiptPFalse
                                          .showFacebookTopAction();
                                    }
                                  },
                                ),
                              ],
                            ),
                            SizedBox(height: 15),
                            ToggleElement(
                              value: receipP.showFirst!,
                              element: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .spaceBetween,
                                    spacing: 10,
                                    children: [
                                      SizedBox(
                                        width: 110,
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
                                              'Cashier',
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
                                              'Staff Name',
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: 110,
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
                                              'Customer Name',
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

                                              'Customer Name',
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5),
                                ],
                              ),
                              action: () {
                                receiptPFalse
                                    .showFirstSectionAction();
                              },
                            ),
                            // SizedBox(height: 10),
                            ToggleElement(
                              value: receipP.showSecond!,
                              element: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .spaceBetween,
                                    spacing: 10,
                                    children: [
                                      SizedBox(
                                        width: 110,
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
                                              'Payment Method',
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
                                              'Payment Method',
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: 110,
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
                                              'Amount(s)',
                                            ),
                                            Column(
                                              children: [
                                                Row(
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
                                                            10000,
                                                        context:
                                                            context,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5),
                                ],
                              ),
                              action: () {
                                receiptPFalse
                                    .showSecondSectionAction();
                              },
                            ),
                            ToggleElement(
                              value: receipP.showThird!,
                              element: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment
                                            .spaceBetween,
                                    spacing: 10,
                                    children: [
                                      SizedBox(
                                        width: 110,
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
                                                DateTime.now(),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: 110,
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
                                                DateTime.now(),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5),
                                ],
                              ),
                              action: () {
                                receiptPFalse
                                    .showThirdSectionAction();
                              },
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
                              itemCount: 3,
                              itemBuilder: (
                                context,
                                index,
                              ) {
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
                                                'Item $index',
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
                                                'Qty: 2 Item(s)',
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
                                                      1200 *
                                                      index,
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
                                  amount: 50000,
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
                                    '2%',
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
                                  amount: 12000,
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
                                  amount: 48000,
                                  context: context,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        SizedBox(height: 5),
                        Divider(),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Column(
                              spacing: 5,
                              children: [
                                SizedBox(
                                  width: 280,
                                  child: Stack(
                                    alignment: Alignment(
                                      1,
                                      0,
                                    ),
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment
                                                .center,
                                        spacing: 5,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              textAlign:
                                                  TextAlign
                                                      .center,
                                              style: TextStyle(
                                                fontSize:
                                                    widget
                                                        .theme
                                                        .mobileTexts
                                                        .b1
                                                        .fontSize,
                                                color:
                                                    Colors
                                                        .grey
                                                        .shade700,
                                                fontWeight:
                                                    FontWeight
                                                        .bold,
                                              ),
                                              '${receipP.bottomText?.toUpperCase() ?? 'Thank You For Shopping With Us'.toUpperCase()}.',
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color:
                                                Colors
                                                    .grey
                                                    .shade400,
                                          ),
                                          shape:
                                              BoxShape
                                                  .circle,
                                          color:
                                              const Color.fromARGB(
                                                17,
                                                255,
                                                193,
                                                7,
                                              ),
                                        ),
                                        child: IconButton(
                                          onPressed: () {
                                            showDialog(
                                              context:
                                                  context,
                                              builder: (
                                                context,
                                              ) {
                                                return DialogTemplate(
                                                  action: () {
                                                    if (_formState
                                                        .currentState!
                                                        .validate()) {
                                                      receiptPFalse.setBottomText(
                                                        bottomTextController.text,
                                                      );
                                                      bottomTextController
                                                          .clear();
                                                      Navigator.of(
                                                        context,
                                                      ).pop();
                                                    }
                                                  },
                                                  message:
                                                      '',
                                                  theme:
                                                      widget
                                                          .theme,
                                                  title:
                                                      'Enter Bottom Text',
                                                  widget: GeneralTextfieldOnly(
                                                    initialValue:
                                                        receiptPFalse.userShop!.bottomText,
                                                    formState:
                                                        _formState,
                                                    controller:
                                                        bottomTextController,
                                                    hint:
                                                        'Enter Text',
                                                    lines:
                                                        2,
                                                    theme:
                                                        widget.theme,
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                          icon: Icon(
                                            Icons.edit,
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
                  ],
                ),
              ),
            ),
            SizedBox(height: 5),
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 10,
                children: [
                  Visibility(
                    visible: authorization(
                      authorized:
                          Authorizations().updateSale,
                      context: context,
                    ),
                    child: ReceiptUpdateButton(
                      text: 'Save Template',
                      color: Colors.grey,
                      iconSize: 20,
                      theme: widget.theme,
                      icon: Icons.edit,
                      action: () async {
                        setState(() {
                          isLoading = true;
                        });
                        var int =
                            await receiptPFalse
                                .updateShopPrintDetails();
                        if (int == 1) {
                          setState(() {
                            isLoading = false;
                            showSuccess = true;
                          });
                          await Future.delayed(
                            Duration(seconds: 2),
                          );
                          // ignore: use_build_context_synchronously
                          Navigator.of(context).pop();
                        } else {
                          setState(() {
                            isLoading = false;
                          });
                          showDialog(
                            // ignore: use_build_context_synchronously
                            context: context,
                            builder: (context) {
                              return InfoAlert(
                                theme: widget.theme,
                                message:
                                    'An Error Occoured when updating Your printer details. Please try again',
                                title: 'Update Failed',
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
          ],
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
            ).showSuccess('Updated Successfully'),
          ),
        ),
      ],
    );
  }
}
