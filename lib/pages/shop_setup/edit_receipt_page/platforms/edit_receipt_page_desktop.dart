import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/components/alert_dialogues/dialog_template.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/major/top_banner_two.dart';
import 'package:stockall/components/text_fields/general_textfield_only.dart';
import 'package:stockall/components/toggle_button/my_toggle_button.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/theme_provider.dart';

class EditReceiptPageDesktop extends StatefulWidget {
  const EditReceiptPageDesktop({super.key});

  @override
  State<EditReceiptPageDesktop> createState() =>
      _EditReceiptPageDesktopState();
}

class _EditReceiptPageDesktopState
    extends State<EditReceiptPageDesktop> {
  @override
  Widget build(BuildContext context) {
    var shop = returnShopProvider(context).userShop();
    var theme = returnTheme(context);

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
                      20,
                  width: 600,
                  child: Stack(
                    alignment: Alignment(0, 1),
                    children: [
                      Align(
                        alignment: Alignment(0, -1),
                        child: SizedBox(
                          child: TopBannerTwo(
                            isMain: false,
                            title: 'Edit Receipt Template',
                            theme: theme,
                            bottomSpace: 200,
                            topSpace: 10,
                          ),
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
                                                listen:
                                                    false,
                                              )
                                              .userShop()!
                                              .printType !=
                                          1
                                      ? returnShopProvider(
                                        context,
                                        listen: false,
                                      ).updatePrintType(
                                        shopId: shopId(
                                          context,
                                        ),
                                        type: 1,
                                      )
                                      : {};
                                },
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment
                                          .spaceBetween,
                                  children: [
                                    Text(
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
                                                ? FontWeight
                                                    .bold
                                                : null,
                                      ),
                                      kIsWeb
                                          ? 'Printer Type -- 58mm'
                                          : 'Select USB Printer',
                                    ),
                                    Visibility(
                                      visible:
                                          returnShopProvider(
                                                context,
                                                listen:
                                                    false,
                                              )
                                              .userShop()!
                                              .printType ==
                                          1,
                                      child: Icon(
                                        size: 17,
                                        color:
                                            Colors
                                                .grey
                                                .shade700,
                                        Icons.check,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                enabled:
                                    kIsWeb ||
                                    platforms(context) ==
                                        TargetPlatform
                                            .android ||
                                    platforms(context) ==
                                        TargetPlatform.iOS,
                                onTap: () {
                                  returnShopProvider(
                                                context,
                                                listen:
                                                    false,
                                              )
                                              .userShop()!
                                              .printType !=
                                          2
                                      ? returnShopProvider(
                                        context,
                                        listen: false,
                                      ).updatePrintType(
                                        shopId: shopId(
                                          context,
                                        ),
                                        type: 2,
                                      )
                                      : {};
                                },
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment
                                          .spaceBetween,
                                  children: [
                                    Text(
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
                                                ? FontWeight
                                                    .bold
                                                : null,
                                      ),
                                      kIsWeb
                                          ? 'Printer Type -- 80mm'
                                          : 'Select Bluetooth Printer',
                                    ),
                                    Visibility(
                                      visible:
                                          returnShopProvider(
                                                context,
                                                listen:
                                                    false,
                                              )
                                              .userShop()!
                                              .printType ==
                                          2,
                                      child: Icon(
                                        size: 17,
                                        color:
                                            Colors
                                                .grey
                                                .shade700,
                                        Icons.check,
                                      ),
                                    ),
                                  ],
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
                                    MainAxisAlignment
                                        .center,
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
                                                ).userShop()!.printType !=
                                                null &&
                                            returnShopProvider(
                                                  context,
                                                  listen:
                                                      false,
                                                ).userShop()!.printType ==
                                                2
                                        ? (kIsWeb
                                            ? '80mm'
                                            : '( Bluetooth )')
                                        : returnShopProvider(
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
                          width: 500,
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
  initState() {
    super.initState();
    getLogoFuture = getLogo();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      returnShopProvider(
        context,
        listen: false,
      ).switchLogoPicked(false);
      if (returnShopProvider(
            context,
            listen: false,
          ).userShop()!.phoneNumber ==
          null) {
        returnShopProvider(context, listen: false)
            .userShop()!
            .showPhone = false;
      }
      if (returnShopProvider(
            context,
            listen: false,
          ).userShop()!.email ==
          null) {
        returnShopProvider(context, listen: false)
            .userShop()!
            .showEmail = false;
      }
      setState(() {});
    });
  }

  late Future<Uint8List?> getLogoFuture;
  Future<Uint8List?> getLogo() async {
    return returnShopProvider(
      context,
      listen: false,
    ).getLogoImage(context);
  }

  @override
  Widget build(BuildContext context) {
    var receipP = returnShopProvider(context).userShop()!;
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
              child: FutureBuilder(
                future: getLogoFuture,
                builder: (context, asyncSnapshot) {
                  if (asyncSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(
                      child: returnCompProvider(
                        context,
                      ).showLoader(message: 'Loading...'),
                    );
                  } else {
                    return SizedBox(
                      height:
                          MediaQuery.of(
                            context,
                          ).size.height -
                          200,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  // SizedBox(height: 5),
                                  Column(
                                    spacing: 3,
                                    children: [
                                      Visibility(
                                        visible:
                                            returnShopProvider(
                                              context,
                                            ).selectedLogo !=
                                            null,
                                        child: SizedBox(
                                          height: 10,
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () async {
                                          await returnShopProvider(
                                            context,
                                            listen: false,
                                          ).pickLogoImage();
                                        },
                                        child: Container(
                                          height:
                                              returnShopProvider(
                                                        context,
                                                      ).imageWidth ==
                                                      null
                                                  ? 60
                                                  : returnShopProvider(
                                                        context,
                                                      ).imageWidth! >
                                                      (2 *
                                                          returnShopProvider(
                                                            context,
                                                          ).imageHeight!)
                                                  ? 30
                                                  : 60,
                                          width: 400,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(
                                                  10,
                                                ),
                                            border: Border.all(
                                              color:
                                                  returnShopProvider(
                                                            context,
                                                          ).selectedLogo ==
                                                          null
                                                      ? Colors
                                                          .grey
                                                          .shade400
                                                      : Colors
                                                          .transparent,
                                            ),
                                          ),
                                          child: FutureBuilder(
                                            future:
                                                getLogoFuture,
                                            builder: (
                                              context,
                                              snapshot,
                                            ) {
                                              if (snapshot
                                                      .connectionState ==
                                                  ConnectionState
                                                      .waiting) {
                                                return Center(
                                                  child: SizedBox(
                                                    height:
                                                        35,
                                                    width:
                                                        35,
                                                    child: CircularProgressIndicator(
                                                      strokeWidth:
                                                          1.2,
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                return returnShopProvider(
                                                          context,
                                                        ).selectedLogo ==
                                                        null
                                                    ? Stack(
                                                      alignment: Alignment(
                                                        0,
                                                        0,
                                                      ),
                                                      children: [
                                                        Icon(
                                                          size:
                                                              60,
                                                          Icons.image_outlined,
                                                        ),
                                                        Align(
                                                          alignment: Alignment(
                                                            0.1,
                                                            1,
                                                          ),
                                                          child: Container(
                                                            padding: EdgeInsets.all(
                                                              3,
                                                            ),
                                                            decoration: BoxDecoration(
                                                              shape:
                                                                  BoxShape.circle,
                                                              color:
                                                                  widget.theme.lightModeColor.secColor200,
                                                            ),
                                                            child: Icon(
                                                              size:
                                                                  20,
                                                              Icons.add,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                    : Stack(
                                                      alignment: Alignment(
                                                        0,
                                                        0,
                                                      ),
                                                      children: [
                                                        Image.memory(
                                                          returnShopProvider(
                                                            context,
                                                          ).selectedLogo!,
                                                          fit:
                                                              BoxFit.contain,
                                                        ),
                                                        Align(
                                                          alignment: Alignment(
                                                            1,
                                                            1,
                                                          ),
                                                          child: IconButton(
                                                            onPressed: () {
                                                              returnShopProvider(
                                                                context,
                                                                listen:
                                                                    false,
                                                              ).clearImage();
                                                            },
                                                            icon: Icon(
                                                              Icons.clear,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                              }
                                            },
                                          ),
                                        ),
                                      ),
                                      ToggleElement(
                                        action: () {
                                          receiptPFalse
                                              .showShopNameAction();
                                        },
                                        element: Text(
                                          textAlign:
                                              TextAlign
                                                  .center,
                                          style: TextStyle(
                                            fontSize:
                                                widget
                                                    .theme
                                                    .mobileTexts
                                                    .h3
                                                    .fontSize,
                                            fontWeight:
                                                FontWeight
                                                    .bold,
                                          ),
                                          // ",912ms (compile: 153 ms, reload: 1934 ms, reassemble: 1268 ms).",
                                          widget.shop.name,
                                        ),
                                        value:
                                            receipP
                                                .showShopName!,
                                      ),
                                      ToggleElement(
                                        action: () {
                                          receiptPFalse
                                                      .userShop()!
                                                      .email ==
                                                  null
                                              ? {}
                                              : receiptPFalse
                                                  .showEmailAction();
                                        },
                                        element: Text(
                                          textAlign:
                                              TextAlign
                                                  .center,
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
                                            color:
                                                Colors
                                                    .grey
                                                    .shade700,
                                          ),
                                          widget
                                                  .shop
                                                  .email ??
                                              'Email Not Set',
                                        ),
                                        value:
                                            receipP.email ==
                                                    null
                                                ? false
                                                : receipP
                                                    .showEmail!,
                                      ),
                                      ToggleElement(
                                        action: () {
                                          receiptPFalse
                                              .showAddressAction();
                                        },
                                        element: Text(
                                          textAlign:
                                              TextAlign
                                                  .center,
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
                                            receipP
                                                .showAddress!,
                                      ),
                                      ToggleElement(
                                        action: () {
                                          receiptPFalse
                                                      .userShop()!
                                                      .phoneNumber ==
                                                  null
                                              ? {}
                                              : receiptPFalse
                                                  .showPhoneAction();
                                        },
                                        element: Text(
                                          textAlign:
                                              TextAlign
                                                  .center,
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
                                        value:
                                            receipP.phoneNumber ==
                                                    null
                                                ? false
                                                : receipP
                                                    .showPhone!,
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
                                              textAlign:
                                                  TextAlign
                                                      .center,
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
                                                  .userShop()!
                                                  .instaHandle ==
                                              null) {
                                            showDialog(
                                              context:
                                                  context,
                                              builder: (
                                                context,
                                              ) {
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
                                              textAlign:
                                                  TextAlign
                                                      .center,
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
                                                  .userShop()!
                                                  .faceBookHandle ==
                                              null) {
                                            showDialog(
                                              context:
                                                  context,
                                              builder: (
                                                context,
                                              ) {
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
                                    value:
                                        receipP.showFirst!,
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
                                              width: 220,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start,
                                                children: [
                                                  Text(
                                                    style: TextStyle(
                                                      fontSize:
                                                          widget.theme.mobileTexts.b1.fontSize,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    'Cashier',
                                                  ),
                                                  Text(
                                                    style: TextStyle(
                                                      fontSize:
                                                          widget.theme.mobileTexts.b2.fontSize,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                    ),
                                                    'Staff Name',
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              width: 130,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start,
                                                children: [
                                                  Text(
                                                    style: TextStyle(
                                                      fontSize:
                                                          widget.theme.mobileTexts.b1.fontSize,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    'Customer Name',
                                                  ),
                                                  Text(
                                                    style: TextStyle(
                                                      fontSize:
                                                          widget.theme.mobileTexts.b2.fontSize,
                                                      fontWeight:
                                                          FontWeight.normal,
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
                                  ToggleElement(
                                    value:
                                        receipP.showSecond!,
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
                                              width: 220,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start,
                                                children: [
                                                  Text(
                                                    style: TextStyle(
                                                      fontSize:
                                                          widget.theme.mobileTexts.b1.fontSize,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    'Payment Method',
                                                  ),
                                                  Text(
                                                    style: TextStyle(
                                                      fontSize:
                                                          widget.theme.mobileTexts.b2.fontSize,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                    ),
                                                    'Payment Method',
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              width: 130,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start,
                                                children: [
                                                  Text(
                                                    style: TextStyle(
                                                      fontSize:
                                                          widget.theme.mobileTexts.b1.fontSize,
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                    value:
                                        receipP.showThird!,
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
                                              width: 220,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start,
                                                children: [
                                                  Text(
                                                    style: TextStyle(
                                                      fontSize:
                                                          widget.theme.mobileTexts.b1.fontSize,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    'Date',
                                                  ),
                                                  Text(
                                                    style: TextStyle(
                                                      fontSize:
                                                          widget.theme.mobileTexts.b2.fontSize,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                    ),
                                                    formatDateTime(
                                                      DateTime.now(),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            SizedBox(
                                              width: 130,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment
                                                        .start,
                                                children: [
                                                  Text(
                                                    style: TextStyle(
                                                      fontSize:
                                                          widget.theme.mobileTexts.b1.fontSize,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    'Time',
                                                  ),
                                                  Text(
                                                    style: TextStyle(
                                                      fontSize:
                                                          widget.theme.mobileTexts.b2.fontSize,
                                                      fontWeight:
                                                          FontWeight.normal,
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
                                              FontWeight
                                                  .bold,
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
                                                  spacing:
                                                      3,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start,
                                                  children: [
                                                    Text(
                                                      style: TextStyle(
                                                        fontSize:
                                                            widget.theme.mobileTexts.b1.fontSize,
                                                      ),
                                                      'Item $index',
                                                    ),
                                                    Text(
                                                      style: TextStyle(
                                                        fontSize:
                                                            widget.theme.mobileTexts.b3.fontSize,
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
                                                            widget.theme.mobileTexts.b1.fontSize,
                                                        fontWeight:
                                                            FontWeight.bold,
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
                                                .b3
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
                                                    .b3
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
                                                    .b3
                                                    .fontSize,
                                            fontWeight:
                                                FontWeight
                                                    .bold,
                                          ),
                                          '  (2%)',
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
                                    MainAxisAlignment
                                        .center,
                                children: [
                                  Column(
                                    spacing: 5,
                                    children: [
                                      SizedBox(
                                        width: 400,
                                        child: Stack(
                                          alignment:
                                              Alignment(
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
                                                        TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize:
                                                          widget.theme.mobileTexts.b1.fontSize,
                                                      color:
                                                          Colors.grey.shade700,
                                                      fontWeight:
                                                          FontWeight.bold,
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
                                                          if (_formState.currentState!.validate()) {
                                                            receiptPFalse.setBottomText(
                                                              bottomTextController.text,
                                                            );
                                                            bottomTextController.clear();
                                                            Navigator.of(
                                                              context,
                                                            ).pop();
                                                          }
                                                        },
                                                        message:
                                                            '',
                                                        theme:
                                                            widget.theme,
                                                        title:
                                                            'Enter Bottom Text',
                                                        widget: GeneralTextfieldOnly(
                                                          initialValue:
                                                              receiptPFalse.userShop()!.bottomText,
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
                                                  Icons
                                                      .edit,
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
                    );
                  }
                },
              ),
            ),
            SizedBox(height: 5),
            SizedBox(
              width: MediaQuery.of(context).size.width - 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: 10,
                children: [
                  FutureBuilder(
                    future: getLogoFuture,
                    builder: (context, asyncSnapshot) {
                      if (asyncSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Container();
                      } else {
                        return Visibility(
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
                              var int = await receiptPFalse
                                  .updateShopPrintDetails(
                                    context,
                                  );
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
                                      title:
                                          'Update Failed',
                                    );
                                  },
                                );
                              }
                            },
                          ),
                        );
                      }
                    },
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

class ToggleElement extends StatelessWidget {
  const ToggleElement({
    super.key,
    required this.value,
    required this.element,
    required this.action,
  });

  final bool value;
  final Widget element;
  final Function() action;

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Row(
        spacing: 10,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: Opacity(
              opacity: !value ? 0.3 : 1,
              child: element,
            ),
          ),
          MyToggleButton(
            isSmall: true,
            boolValue: value,
            theme: theme,
            toggle: action,
          ),
        ],
      ),
    );
  }
}

class ReceiptUpdateButton extends StatelessWidget {
  final String text;
  final Function()? action;
  final IconData? icon;
  final Color color;
  final double iconSize;
  final ThemeProvider theme;
  final String? svg;

  const ReceiptUpdateButton({
    super.key,
    required this.text,
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
                // spacing: 5,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b3.fontSize,
                    ),
                    text,
                  ),
                  Stack(
                    children: [
                      Visibility(
                        visible: icon != null,
                        child: Icon(
                          size: iconSize,
                          color: color,
                          icon ??
                              Icons.delete_outline_rounded,
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
