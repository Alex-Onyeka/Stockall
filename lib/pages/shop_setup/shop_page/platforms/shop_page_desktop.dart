import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/components/buttons/main_button_transparent.dart';
import 'package:stockall/components/major/desktop_center_container.dart';
import 'package:stockall/components/text_fields/general_textfield_only.dart';
import 'package:stockall/components/text_fields/main_dropdown_only.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/shop_setup/shop_setup_one/shop_setup_page.dart';
import 'package:stockall/pages/shop_setup/shop_setup_two/shop_setup_two.dart';
import 'package:stockall/services/auth_service.dart';

class ShopPageDesktop extends StatefulWidget {
  const ShopPageDesktop({super.key});

  @override
  State<ShopPageDesktop> createState() =>
      ShopPageDesktopState();
}

class ShopPageDesktopState extends State<ShopPageDesktop> {
  late Future<TempShopClass> shopFuture;
  Future<TempShopClass> getShop() async {
    var tempShp = await returnShopProvider(
      context,
      listen: false,
    ).getUserShop(AuthService().currentUser!);

    return tempShp!;
  }

  TextEditingController currencyController =
      TextEditingController();

  String? selectedCurrency;
  String? displayCurrency;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    shopFuture = getShop();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        displayCurrency =
            returnShopProvider(
                  context,
                  listen: false,
                ).userShop!.currency.isEmpty
                ? 'Currency Not Set'
                : '${currencies.firstWhere((currency) => currency.symbol == returnShopProvider(context, listen: false).userShop!.currency).currency} (${currencies.firstWhere((currency) => currency.symbol == returnShopProvider(context, listen: false).userShop!.currency).symbol})';
        selectedCurrency =
            returnShopProvider(
                  context,
                  listen: false,
                ).userShop!.currency.isEmpty
                ? null
                : currencies
                    .firstWhere(
                      (currency) =>
                          currency.symbol ==
                          returnShopProvider(
                            context,
                            listen: false,
                          ).userShop!.currency,
                    )
                    .symbol;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return DesktopCenterContainer(
      mainWidget: Scaffold(
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
                    SizedBox(height: 20),
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
                          borderRadius:
                              BorderRadius.circular(10),
                        ),
                        child: Text(
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
                                highlightColor:
                                    Colors.white,
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
                                highlightColor:
                                    Colors.white,
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
                                highlightColor:
                                    Colors.white,
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
                      SizedBox(height: 20),
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
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(
                                  horizontal: 30.0,
                                ),
                            child: Text(
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .h4
                                        .fontSize,
                              ),
                              shop.name,
                            ),
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
                            textAlign: TextAlign.center,
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
                                      child: Text(
                                        style: TextStyle(
                                          fontWeight:
                                              FontWeight
                                                  .normal,
                                          fontSize:
                                              theme
                                                  .mobileTexts
                                                  .b1
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
                                              FontWeight
                                                  .bold,
                                          fontSize:
                                              theme
                                                  .mobileTexts
                                                  .b1
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
                                                  .b1
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
                                              FontWeight
                                                  .bold,
                                          fontSize:
                                              theme
                                                  .mobileTexts
                                                  .b1
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
                                                  .b1
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
                                              FontWeight
                                                  .bold,
                                          fontSize:
                                              theme
                                                  .mobileTexts
                                                  .b1
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
                                                  .b1
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
                                              FontWeight
                                                  .bold,
                                          fontSize:
                                              theme
                                                  .mobileTexts
                                                  .b1
                                                  .fontSize,
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
                            SizedBox(height: 10),
                            Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  style: TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
                                    fontSize:
                                        theme
                                            .mobileTexts
                                            .b2
                                            .fontSize,
                                  ),
                                  'Set your Currency',
                                ),
                                SizedBox(height: 5),
                                MainDropdownOnly(
                                  valueSet:
                                      displayCurrency !=
                                      null,
                                  hint:
                                      displayCurrency ??
                                      'Select Your Currency',
                                  theme: theme,
                                  isOpen: false,
                                  onTap: () {
                                    showGeneralDialog(
                                      context: context,
                                      pageBuilder: (
                                        context,
                                        animation,
                                        secondaryAnimation,
                                      ) {
                                        return GestureDetector(
                                          onTap:
                                              () =>
                                                  FocusManager
                                                      .instance
                                                      .primaryFocus
                                                      ?.unfocus(),
                                          child: StatefulBuilder(
                                            builder:
                                                (
                                                  context,
                                                  setState,
                                                ) => Material(
                                                  color:
                                                      Colors
                                                          .transparent,
                                                  // elevation: 1,
                                                  child: Padding(
                                                    padding: const EdgeInsets.only(
                                                      top:
                                                          10.0,
                                                    ),
                                                    child: Ink(
                                                      height:
                                                          MediaQuery.of(
                                                            context,
                                                          ).size.height,
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Colors.grey.shade100,
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: const Color.fromARGB(
                                                              55,
                                                              0,
                                                              0,
                                                              0,
                                                            ),
                                                            blurRadius:
                                                                5,
                                                          ),
                                                        ],
                                                        borderRadius: BorderRadius.vertical(
                                                          top: Radius.circular(
                                                            20,
                                                          ),
                                                        ),
                                                      ),
                                                      child: Container(
                                                        height:
                                                            MediaQuery.of(
                                                              context,
                                                            ).size.height *
                                                            0.9,

                                                        padding: const EdgeInsets.fromLTRB(
                                                          15,
                                                          15,
                                                          15,
                                                          45,
                                                        ),
                                                        child: Column(
                                                          children: [
                                                            Material(
                                                              color:
                                                                  Colors.white,
                                                              child: Column(
                                                                children: [
                                                                  Center(
                                                                    child: Container(
                                                                      height:
                                                                          4,
                                                                      width:
                                                                          70,
                                                                      decoration: BoxDecoration(
                                                                        borderRadius: BorderRadius.circular(
                                                                          15,
                                                                        ),
                                                                        color:
                                                                            Colors.grey.shade400,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height:
                                                                        10,
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          15.0,
                                                                    ),
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment.spaceBetween,
                                                                      children: [
                                                                        Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            Text(
                                                                              'Select Your Currency',
                                                                              style: TextStyle(
                                                                                fontSize:
                                                                                    returnTheme(
                                                                                      context,
                                                                                    ).mobileTexts.b1.fontSize,
                                                                                fontWeight:
                                                                                    FontWeight.bold,
                                                                              ),
                                                                            ),
                                                                            Text(
                                                                              'Search For Countries or Currency name',
                                                                              style: TextStyle(
                                                                                fontSize:
                                                                                    returnTheme(
                                                                                      context,
                                                                                    ).mobileTexts.b2.fontSize,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                        InkWell(
                                                                          onTap: () {
                                                                            Navigator.of(
                                                                              context,
                                                                            ).pop();
                                                                            currencyController.clear();
                                                                          },
                                                                          child: Container(
                                                                            padding: EdgeInsets.all(
                                                                              10,
                                                                            ),
                                                                            decoration: BoxDecoration(
                                                                              shape:
                                                                                  BoxShape.circle,
                                                                              color:
                                                                                  Colors.grey.shade800,
                                                                            ),
                                                                            child: Icon(
                                                                              color:
                                                                                  Colors.white,
                                                                              Icons.clear_rounded,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height:
                                                                        10,
                                                                  ),
                                                                  Padding(
                                                                    padding: const EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          20.0,
                                                                    ),
                                                                    child: GeneralTextfieldOnly(
                                                                      hint:
                                                                          'Search for country or currency',
                                                                      lines:
                                                                          1,
                                                                      theme:
                                                                          theme,
                                                                      controller:
                                                                          currencyController,
                                                                      onChanged: (
                                                                        value,
                                                                      ) {
                                                                        setState(
                                                                          () {},
                                                                        );
                                                                      },
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: Builder(
                                                                builder: (
                                                                  context,
                                                                ) {
                                                                  var safeContext =
                                                                      context;
                                                                  var currenciies = currencies.where(
                                                                    (
                                                                      currency,
                                                                    ) =>
                                                                        currency.country.toLowerCase().contains(
                                                                          currencyController.text.toLowerCase(),
                                                                        ) ||
                                                                        currency.currency.toLowerCase().contains(
                                                                          currencyController.text.toLowerCase(),
                                                                        ),
                                                                  );
                                                                  if (isLoading) {
                                                                    return Container(
                                                                      color: const Color.fromARGB(
                                                                        67,
                                                                        255,
                                                                        255,
                                                                        255,
                                                                      ),
                                                                      child: Center(
                                                                        child: returnCompProvider(
                                                                          context,
                                                                          listen:
                                                                              false,
                                                                        ).showLoader(
                                                                          'Loading',
                                                                        ),
                                                                      ),
                                                                    );
                                                                  } else {
                                                                    if (currenciies.isEmpty) {
                                                                      return Container(
                                                                        color:
                                                                            Colors.white,
                                                                        child: Center(
                                                                          child: Text(
                                                                            'Not Found',
                                                                          ),
                                                                        ),
                                                                      );
                                                                    } else {
                                                                      return ListView.builder(
                                                                        itemCount:
                                                                            currenciies.length,
                                                                        itemBuilder: (
                                                                          context,
                                                                          index,
                                                                        ) {
                                                                          var item =
                                                                              currenciies.toList()[index];
                                                                          return Padding(
                                                                            padding: const EdgeInsets.symmetric(
                                                                              vertical:
                                                                                  5,
                                                                            ),
                                                                            child: ListTile(
                                                                              tileColor:
                                                                                  Colors.white,
                                                                              subtitle: Text(
                                                                                style: TextStyle(
                                                                                  fontSize:
                                                                                      theme.mobileTexts.b2.fontSize,
                                                                                  fontWeight:
                                                                                      FontWeight.normal,
                                                                                  color:
                                                                                      theme.lightModeColor.secColor100,
                                                                                ),
                                                                                item.currency,
                                                                              ),
                                                                              title: Text(
                                                                                style: TextStyle(
                                                                                  fontSize:
                                                                                      theme.mobileTexts.b1.fontSize,
                                                                                  fontWeight:
                                                                                      FontWeight.bold,
                                                                                ),
                                                                                item.country,
                                                                              ),
                                                                              trailing: Text(
                                                                                style: TextStyle(
                                                                                  fontSize:
                                                                                      theme.mobileTexts.b1.fontSize,
                                                                                  fontWeight:
                                                                                      FontWeight.bold,
                                                                                  color:
                                                                                      theme.lightModeColor.secColor100,
                                                                                ),
                                                                                item.symbol,
                                                                              ),
                                                                              onTap: () async {
                                                                                setState(
                                                                                  () {
                                                                                    isLoading =
                                                                                        true;
                                                                                  },
                                                                                );
                                                                                await returnShopProvider(
                                                                                  context,
                                                                                  listen:
                                                                                      false,
                                                                                ).updateShopCurrency(
                                                                                  currency:
                                                                                      item.symbol,
                                                                                  shopId: shopId(
                                                                                    context,
                                                                                  ),
                                                                                );
                                                                                setState(
                                                                                  () {
                                                                                    selectedCurrency =
                                                                                        item.symbol;
                                                                                    displayCurrency =
                                                                                        '${item.currency} (${item.symbol})';
                                                                                    isLoading =
                                                                                        false;
                                                                                  },
                                                                                );
                                                                                if (safeContext.mounted) {
                                                                                  Navigator.of(
                                                                                    safeContext,
                                                                                  ).pop();
                                                                                }
                                                                              },
                                                                            ),
                                                                          );
                                                                        },
                                                                      );
                                                                    }
                                                                  }
                                                                },
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
                                      },
                                    ).then((context) {
                                      setState(() {});
                                    });
                                  },
                                ),
                              ],
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
      ),
    );
  }
}
