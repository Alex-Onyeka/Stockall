import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stockitt/classes/temp_shop_class.dart';
import 'package:stockitt/components/buttons/main_button_transparent.dart';
import 'package:stockitt/constants/app_bar.dart';
import 'package:stockitt/constants/constants_main.dart';
import 'package:stockitt/main.dart';
import 'package:stockitt/pages/shop_setup/shop_setup_page.dart';
import 'package:stockitt/pages/shop_setup/shop_setup_two.dart';
import 'package:stockitt/services/auth_service.dart';

class ShopPageMobile extends StatefulWidget {
  const ShopPageMobile({super.key});

  @override
  State<ShopPageMobile> createState() =>
      _ShopPageMobileState();
}

class _ShopPageMobileState extends State<ShopPageMobile> {
  late Future<TempShopClass> shopFuture;
  Future<TempShopClass> getShop() async {
    var tempShp = await returnShopProvider(
      context,
      listen: false,
    ).getUserShop(AuthService().currentUser!.id);

    return tempShp!;
  }

  @override
  void initState() {
    super.initState();
    shopFuture = getShop();
  }

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
                  SizedBox(height: 30),
                  Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color.fromARGB(
                        43,
                        0,
                        150,
                        135,
                      ),
                    ),
                    child: Image.asset(
                      shopIconImage,
                      height: 110,
                    ),
                  ),
                  SizedBox(height: 10),
                  Column(
                    spacing: 2,
                    children: [
                      Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.white,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius:
                                BorderRadius.circular(10),
                          ),
                          child: Text(
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b1
                                      .fontSize,
                            ),
                            'Shop Name',
                          ),
                        ),
                      ),
                      Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.white,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius:
                                BorderRadius.circular(10),
                          ),
                          child: Text(
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b1
                                      .fontSize,
                            ),
                            '000 0 00 000 0',
                          ),
                        ),
                      ),
                      Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.white,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius:
                                BorderRadius.circular(10),
                          ),
                          child: Text(
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b1
                                      .fontSize,
                            ),
                            'alexonyekasm@gmail.com',
                          ),
                        ),
                      ),
                    ],
                  ),
                  Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.white,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(
                          10,
                        ),
                      ),
                      child: Text(
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize:
                              theme.mobileTexts.b1.fontSize,
                          color:
                              theme
                                  .lightModeColor
                                  .secColor200,
                        ),
                        ' shop.shopAddress shop.shopAddress',
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50.0,
                    ),
                    child: Column(
                      spacing: 10,
                      children: [
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .spaceBetween,
                          children: [
                            Text('Country:'),
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
                                    fontWeight:
                                        FontWeight.normal,
                                    fontSize:
                                        theme
                                            .mobileTexts
                                            .b1
                                            .fontSize,
                                    color:
                                        theme
                                            .lightModeColor
                                            .secColor200,
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
                            Text('State:'),
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
                                    fontWeight:
                                        FontWeight.normal,
                                    fontSize:
                                        theme
                                            .mobileTexts
                                            .b1
                                            .fontSize,
                                    color:
                                        theme
                                            .lightModeColor
                                            .secColor200,
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
                            Text('City:'),
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
                                    fontWeight:
                                        FontWeight.normal,
                                    fontSize:
                                        theme
                                            .mobileTexts
                                            .b1
                                            .fontSize,
                                    color:
                                        theme
                                            .lightModeColor
                                            .secColor200,
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
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30.0,
                    ),
                    child: Column(
                      spacing: 10,
                      children: [
                        MainButtonTransparent(
                          themeProvider: theme,
                          action: () {},
                          text: 'Edit Shop Details',
                          constraints: BoxConstraints(),
                        ),
                        // MainButtonTransparent(
                        //   themeProvider: theme,
                        //   action: () {},
                        //   text: 'Change Email',
                        //   constraints: BoxConstraints(),
                        // ),
                        MainButtonTransparent(
                          themeProvider: theme,
                          action: () {},
                          text: 'Edit Shop Address',
                          constraints: BoxConstraints(),
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
                    SizedBox(height: 30),
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color.fromARGB(
                          43,
                          0,
                          150,
                          135,
                        ),
                      ),
                      child: Image.asset(
                        shopIconImage,
                        height: 110,
                      ),
                    ),
                    SizedBox(height: 10),
                    Column(
                      spacing: 2,
                      children: [
                        Text(
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b1
                                    .fontSize,
                          ),
                          shop.name,
                        ),
                        Text(
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b1
                                    .fontSize,
                          ),
                          shop.phoneNumber ??
                              'Phone Number Not Set',
                        ),
                        Text(
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b1
                                    .fontSize,
                            color:
                                theme
                                    .lightModeColor
                                    .secColor200,
                          ),
                          shop.email,
                        ),
                        SizedBox(height: 20),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(
                                horizontal: 50.0,
                              ),
                          child: Column(
                            spacing: 10,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment
                                        .spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: Text('Country:'),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      textAlign:
                                          TextAlign.right,
                                      style: TextStyle(
                                        fontWeight:
                                            FontWeight.bold,
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
                                    child: Text('State:'),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      textAlign:
                                          TextAlign.right,
                                      style: TextStyle(
                                        fontWeight:
                                            FontWeight.bold,
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
                                    child: Text('City:'),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      textAlign:
                                          TextAlign.right,
                                      style: TextStyle(
                                        fontWeight:
                                            FontWeight.bold,
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
                                    child: Text('Address:'),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      textAlign:
                                          TextAlign.right,
                                      style: TextStyle(
                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                      shop.shopAddress ??
                                          'Address Not Set',
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
                          MainButtonTransparent(
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
                                  shopFuture = getShop();
                                });
                              });
                            },
                            text: 'Edit Shop Details',
                            constraints: BoxConstraints(),
                          ),
                          // MainButtonTransparent(
                          //   themeProvider: theme,
                          //   action: () {},
                          //   text: 'Change Email',
                          //   constraints: BoxConstraints(),
                          // ),
                          MainButtonTransparent(
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
                                  shopFuture = getShop();
                                });
                              });
                            },
                            text: 'Edit Shop Address',
                            constraints: BoxConstraints(),
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
