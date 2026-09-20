import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/components/buttons/main_button_transparent.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/subscription/general_settings_auth.dart';
import 'package:stockall/constants/subscription/subscription_func.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/shop_setup/edit_receipt_page/edit_receipt.dart';
import 'package:stockall/pages/shop_setup/shop_page/components/delete_shop_button_widget.dart';
import 'package:stockall/pages/shop_setup/shop_page/components/select_currency_widget.dart';
import 'package:stockall/pages/shop_setup/shop_page/components/set_social_details.dart';
import 'package:stockall/pages/shop_setup/shop_setup_one/shop_setup_page.dart';
import 'package:stockall/pages/shop_setup/shop_setup_two/shop_setup_two.dart';
import 'package:stockall/providers/theme_provider.dart';

class ShopPageMobile extends StatefulWidget {
  const ShopPageMobile({super.key});

  @override
  State<ShopPageMobile> createState() =>
      _ShopPageMobileState();
}

class _ShopPageMobileState extends State<ShopPageMobile> {
  late Future<TempShopClass> shopFuture;
  Future<TempShopClass> getShop() async {
    var shopP = returnShopProvider();
    await shopP.getUserShops();

    return shopP.userShop()!;
  }

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    shopFuture = getShop();
  }

  final instaController = TextEditingController();
  final faceBookController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Scaffold(
      appBar: appBar(context: context, title: 'Shop'),
      body: FutureBuilder(
        future: shopFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
                  ConnectionState.waiting ||
              snapshot.hasError) {
            return Center(
              child: Column(
                children: [
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30.0,
                    ),
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.white,
                      child: Container(
                        height: 120,

                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius:
                              BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30.0,
                    ),
                    child: Column(
                      spacing: 5,
                      children: [
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          children: [
                            Text(
                              style: TextStyle(
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .b3
                                        .fontSize,
                              ),
                              'Country:',
                            ),
                            Shimmer.fromColors(
                              baseColor:
                                  Colors.grey.shade300,
                              highlightColor: Colors.white,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius:
                                      BorderRadius.circular(
                                        10,
                                      ),
                                ),
                                child: Text(
                                  style: TextStyle(
                                    fontSize:
                                        theme
                                            .mobileTexts
                                            .b3
                                            .fontSize,
                                  ),
                                  'Not Set',
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          children: [
                            Text(
                              style: TextStyle(
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .b3
                                        .fontSize,
                              ),
                              'State:',
                            ),
                            Shimmer.fromColors(
                              baseColor:
                                  Colors.grey.shade300,
                              highlightColor: Colors.white,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius:
                                      BorderRadius.circular(
                                        10,
                                      ),
                                ),
                                child: Text(
                                  style: TextStyle(
                                    fontSize:
                                        theme
                                            .mobileTexts
                                            .b3
                                            .fontSize,
                                  ),
                                  'Not Set',
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          children: [
                            Text(
                              style: TextStyle(
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .b3
                                        .fontSize,
                              ),
                              'City:',
                            ),
                            Shimmer.fromColors(
                              baseColor:
                                  Colors.grey.shade300,
                              highlightColor: Colors.white,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius:
                                      BorderRadius.circular(
                                        10,
                                      ),
                                ),
                                child: Text(
                                  style: TextStyle(
                                    fontSize:
                                        theme
                                            .mobileTexts
                                            .b3
                                            .fontSize,
                                  ),
                                  'Not Set',
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          children: [
                            Text(
                              style: TextStyle(
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .b3
                                        .fontSize,
                              ),
                              'Address:',
                            ),
                            Shimmer.fromColors(
                              baseColor:
                                  Colors.grey.shade300,
                              highlightColor: Colors.white,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius:
                                      BorderRadius.circular(
                                        10,
                                      ),
                                ),
                                child: Text(
                                  style: TextStyle(
                                    fontSize:
                                        theme
                                            .mobileTexts
                                            .b3
                                            .fontSize,
                                  ),
                                  'Not Set',
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          children: [
                            Text(
                              style: TextStyle(
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .b3
                                        .fontSize,
                              ),
                              'Facebook:',
                            ),
                            Shimmer.fromColors(
                              baseColor:
                                  Colors.grey.shade300,
                              highlightColor: Colors.white,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius:
                                      BorderRadius.circular(
                                        10,
                                      ),
                                ),
                                child: Text(
                                  style: TextStyle(
                                    fontSize:
                                        theme
                                            .mobileTexts
                                            .b3
                                            .fontSize,
                                  ),
                                  'Not Set',
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          children: [
                            Text(
                              style: TextStyle(
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .b3
                                        .fontSize,
                              ),
                              'Instagram:',
                            ),
                            Shimmer.fromColors(
                              baseColor:
                                  Colors.grey.shade300,
                              highlightColor: Colors.white,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius:
                                      BorderRadius.circular(
                                        10,
                                      ),
                                ),
                                child: Text(
                                  style: TextStyle(
                                    fontSize:
                                        theme
                                            .mobileTexts
                                            .b3
                                            .fontSize,
                                  ),
                                  'Not Set',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30.0,
                    ),
                    child: Column(
                      spacing: 10,
                      children: [
                        Row(
                          spacing: 10,
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: MainButtonTransparent(
                                themeProvider: theme,
                                action: () {},
                                text: 'Edit Shop Details',
                                constraints:
                                    BoxConstraints(),
                              ),
                            ),
                            Expanded(
                              child: MainButtonTransparent(
                                themeProvider: theme,
                                action: () {},
                                text: 'Edit Shop Address',
                                constraints:
                                    BoxConstraints(),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          spacing: 10,
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: MainButtonTransparent(
                                themeProvider: theme,
                                action: () {},
                                text: 'Edit Social Details',
                                constraints:
                                    BoxConstraints(),
                              ),
                            ),
                            Visibility(
                              visible: authorization(
                                authorized:
                                    Authorizations()
                                        .editReceiptTemplate,
                              ),
                              child: Expanded(
                                child: MainButtonTransparent(
                                  themeProvider: theme,
                                  action: () {},
                                  text: 'Receipt Settings',
                                  constraints:
                                      BoxConstraints(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else {
            var shop = snapshot.data!;
            return SingleChildScrollView(
              child: Center(
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    ShopDetailsTopSectionWidget(
                      theme: theme,
                      shop: shop,
                    ),
                    SizedBox(height: 5),
                    Column(
                      spacing: 2,
                      children: [
                        SizedBox(height: 10),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(
                                horizontal: 30.0,
                              ),
                          child: Column(
                            spacing: 5,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      style: TextStyle(
                                        fontWeight:
                                            FontWeight
                                                .normal,
                                        fontSize:
                                            theme
                                                .mobileTexts
                                                .b3
                                                .fontSize,
                                      ),
                                      'Country:',
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      textAlign:
                                          TextAlign.right,
                                      style: TextStyle(
                                        fontWeight:
                                            FontWeight.bold,
                                        fontSize:
                                            theme
                                                .mobileTexts
                                                .b3
                                                .fontSize,
                                      ),
                                      shop.country ??
                                          'Not Set',
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      style: TextStyle(
                                        fontWeight:
                                            FontWeight
                                                .normal,
                                        fontSize:
                                            theme
                                                .mobileTexts
                                                .b3
                                                .fontSize,
                                      ),
                                      'State:',
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      textAlign:
                                          TextAlign.right,
                                      style: TextStyle(
                                        fontWeight:
                                            FontWeight.bold,
                                        fontSize:
                                            theme
                                                .mobileTexts
                                                .b3
                                                .fontSize,
                                      ),
                                      shop.state ??
                                          'Not Set',
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      style: TextStyle(
                                        fontWeight:
                                            FontWeight
                                                .normal,
                                        fontSize:
                                            theme
                                                .mobileTexts
                                                .b3
                                                .fontSize,
                                      ),
                                      'City:',
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      textAlign:
                                          TextAlign.right,
                                      style: TextStyle(
                                        fontWeight:
                                            FontWeight.bold,
                                        fontSize:
                                            theme
                                                .mobileTexts
                                                .b3
                                                .fontSize,
                                      ),

                                      shop.city ??
                                          'Not Set',
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      style: TextStyle(
                                        fontWeight:
                                            FontWeight
                                                .normal,
                                        fontSize:
                                            theme
                                                .mobileTexts
                                                .b3
                                                .fontSize,
                                      ),
                                      'Address:',
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      textAlign:
                                          TextAlign.right,
                                      style: TextStyle(
                                        fontWeight:
                                            FontWeight.bold,
                                        fontSize:
                                            theme
                                                .mobileTexts
                                                .b3
                                                .fontSize,
                                      ),
                                      shop.shopAddress ??
                                          'Address Not Set',
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      style: TextStyle(
                                        fontWeight:
                                            FontWeight
                                                .normal,
                                        fontSize:
                                            theme
                                                .mobileTexts
                                                .b3
                                                .fontSize,
                                      ),
                                      'Facebook:',
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      textAlign:
                                          TextAlign.right,
                                      style: TextStyle(
                                        fontWeight:
                                            FontWeight.bold,
                                        fontSize:
                                            theme
                                                .mobileTexts
                                                .b3
                                                .fontSize,
                                      ),
                                      shop.faceBookHandle ??
                                          'Not Set',
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      style: TextStyle(
                                        fontWeight:
                                            FontWeight
                                                .normal,
                                        fontSize:
                                            theme
                                                .mobileTexts
                                                .b3
                                                .fontSize,
                                      ),
                                      'Instagram:',
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      textAlign:
                                          TextAlign.right,
                                      style: TextStyle(
                                        fontWeight:
                                            FontWeight.bold,
                                        fontSize:
                                            theme
                                                .mobileTexts
                                                .b3
                                                .fontSize,
                                      ),
                                      shop.instaHandle ??
                                          'Not Set',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30.0,
                      ),
                      child: Column(
                        spacing: 10,
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            spacing: 10,
                            children: [
                              Expanded(
                                child: MainButtonTransparent(
                                  themeProvider: theme,
                                  action: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return ShopSetupPage(
                                            shop: shop,
                                          );
                                        },
                                      ),
                                    ).then((_) {
                                      setState(() {
                                        shopFuture =
                                            getShop();
                                      });
                                    });
                                  },
                                  text: 'Edit Shop Details',
                                  constraints:
                                      BoxConstraints(),
                                ),
                              ),
                              Expanded(
                                child: MainButtonTransparent(
                                  themeProvider: theme,
                                  action: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return ShopSetupTwo(
                                            shop: shop,
                                          );
                                        },
                                      ),
                                    ).then((_) {
                                      setState(() {
                                        shopFuture =
                                            getShop();
                                      });
                                    });
                                  },
                                  text: 'Edit Shop Address',
                                  constraints:
                                      BoxConstraints(),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            spacing: 10,
                            children: [
                              Expanded(
                                child: SubWrapper(
                                  isVisible:
                                      !GeneralSettingsAuthAction()
                                          .addSocialsAction(
                                            context:
                                                context,
                                          ),
                                  mainWidget: MainButtonTransparent(
                                    themeProvider: theme,
                                    action: () {
                                      setSocialDetails(
                                        context: context,
                                        setShopFuture: () {
                                          setState(() {
                                            shopFuture =
                                                getShop();
                                          });
                                        },
                                        toggleLoading: (
                                          value,
                                        ) {
                                          setState(() {
                                            isLoading =
                                                value;
                                          });
                                        },
                                        faceBookController:
                                            faceBookController,
                                        instaController:
                                            instaController,
                                        shop: shop,
                                        theme: theme,
                                      );
                                    },
                                    text:
                                        'Edit Social Details',
                                    constraints:
                                        BoxConstraints(),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: SubWrapper(
                                  isVisible:
                                      !GeneralSettingsAuthAction()
                                          .customizeReceiptTemplateAction(
                                            context:
                                                context,
                                          ),
                                  mainWidget: MainButtonTransparent(
                                    themeProvider: theme,
                                    action: () {
                                      GeneralSettingsAuthAction()
                                          .customizeReceiptTemplateAction(
                                            context:
                                                context,
                                            action: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (
                                                    context,
                                                  ) {
                                                    return EditReceipt();
                                                  },
                                                ),
                                              ).then((_) {
                                                setState(() {
                                                  shopFuture =
                                                      getShop();
                                                });
                                              });
                                            },
                                          );
                                    },
                                    text:
                                        'Receipt Settings',
                                    constraints:
                                        BoxConstraints(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 2),
                          SelectCurrencyWidget(),
                          SizedBox(height: 1),
                          DeleteShopButtonWidget(
                            toggleLoading: (value) {
                              setState(() {
                                isLoading = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

class ShopDetailsTopSectionWidget extends StatelessWidget {
  const ShopDetailsTopSectionWidget({
    super.key,
    required this.theme,
    required this.shop,
  });

  final ThemeProvider theme;
  final TempShopClass shop;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30),
      padding: EdgeInsets.symmetric(
        vertical: 15,
        horizontal: 15,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.grey.shade100,
      ),
      child: Row(
        spacing: 10,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color.fromARGB(43, 0, 150, 135),
            ),
            child: Image.asset(shopIconImage, height: 80),
          ),
          Column(
            spacing: 5,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(
                    color: Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: theme.mobileTexts.b4.fontSize,
                  ),
                  "#Shop ID: ${shopRef()}",
                ),
              ),
              Text(
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: theme.mobileTexts.b2.fontSize,
                ),
                shop.name,
              ),
              Text(
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: theme.mobileTexts.b3.fontSize,
                ),
                shop.phoneNumber ?? 'Phone Number Not Set',
              ),
              Text(
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: theme.mobileTexts.b3.fontSize,
                  color: theme.lightModeColor.secColor200,
                ),
                shop.email ?? 'Email Not Set',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
