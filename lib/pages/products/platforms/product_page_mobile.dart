import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:shimmer/shimmer.dart';
import 'package:stockall/classes/temp_notification.dart';
import 'package:stockall/classes/temp_product_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/major/empty_widget_display.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/components/major/items_summary.dart';
import 'package:stockall/components/major/drawer_widget/my_drawer_widget.dart';
import 'package:stockall/components/major/top_banner.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/scan_barcode.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/authentication/auth_screens/auth_screens_page.dart';
import 'package:stockall/pages/products/add_product_one/add_product.dart';
import 'package:stockall/pages/dashboard/components/main_bottom_nav.dart';
import 'package:stockall/pages/products/compnents/product_tile_main.dart';
import 'package:stockall/pages/products/compnents/search_product_tile.dart';
import 'package:stockall/pages/products/product_details/product_details_page.dart';
import 'package:stockall/pages/products/total_products/total_products_page.dart';
import 'package:stockall/providers/data_provider.dart';
import 'package:stockall/providers/theme_provider.dart';
import 'package:stockall/services/auth_service.dart';

class ProductPageMobile extends StatefulWidget {
  const ProductPageMobile({super.key, required this.theme});

  final ThemeProvider theme;

  @override
  State<ProductPageMobile> createState() =>
      _ProductPageMobileState();
}

class _ProductPageMobileState
    extends State<ProductPageMobile> {
  void clearState() {
    setState(() {
      searchResult = null;
      searchController.clear();
      productsResult.clear();
    });
  }

  // late Future<List<TempProductClass>> _productsFuture;

  List<TempProductClass> productsResult = [];
  String? searchResult;
  TextEditingController searchController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    // _productsFuture =
    // getProductList(context);
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

  Future<void> getProductList(
    // BuildContext context,
  ) async {
    // return returnData(context, listen: false).productList;
    await returnData(
      context,
      listen: false,
    ).getProducts(shopId(context));
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // getProductList(context);
  }

  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    final products =
        context.watch<DataProvider>().productList;
    return Scaffold(
      bottomNavigationBar: MainBottomNav(
        action: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return AddProduct();
              },
            ),
          ).then((_) {
            if (context.mounted) {
              setState(() {
                // getProductList(context);
              });
            } else {
              print('Context not mounted');
            }
          });
        },
        globalKey: _scaffoldKey,
      ),
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

            // returnLocalDatabase(
            //   context,
            //   listen: false,
            // ).currentEmployee;

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
                        AuthService().signOut(context);
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
      onDrawerChanged: (isOpened) {
        if (!isOpened) {
          returnNavProvider(
            context,
            listen: false,
          ).closeDrawer();
        }
      },
      key: _scaffoldKey,
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(
                height:
                    authorization(
                          authorized:
                              Authorizations().addProduct,
                          context: context,
                        )
                        ? 270
                        : 250,
                child: Stack(
                  children: [
                    TopBanner(
                      subTitle: 'Data of All Item Records',
                      title: 'Items',
                      theme: widget.theme,
                      bottomSpace: 100,
                      topSpace: 20,
                      iconSvg: productIconSvg,
                    ),
                    Align(
                      alignment: Alignment(0, 1),
                      child: ItemsSummary(
                        clearTextField: () {
                          setState(() {});
                        },
                        searchController: searchController,
                        searchAction: (value) {
                          setState(() {
                            searchResult =
                                searchController.text;
                          });
                        },
                        hintText: 'Search Item Name',
                        mainTitle: 'Items Summary',
                        firsRow: true,
                        scanAction: () async {
                          String? result = await scanCode(
                            context,
                            'Scan Failed',
                          );
                          setState(() {
                            if (result != null) {
                              searchController.text =
                                  result;
                            } else {
                              return;
                            }
                          });
                          if (!context.mounted) {
                            return;
                          }
                          setState(() {
                            productsResult =
                                products
                                    .where(
                                      (product) =>
                                          product.barcode ==
                                          result,
                                    )
                                    .toList();
                          });
                        },
                        color1: Colors.green,
                        title1: 'In Stock',
                        color0: Colors.green,
                        show0: true,
                        title0: 'Total Stock',
                        value0: products.length.toDouble(),
                        value1:
                            products
                                .where(
                                  (product) =>
                                      product.quantity !=
                                          null &&
                                      product.quantity! > 0,
                                )
                                .length
                                .toDouble(),
                        color2: Colors.amber,
                        title2: 'Out of Stock',
                        value2:
                            products
                                .where(
                                  (product) =>
                                      product.quantity == 0,
                                )
                                .length
                                .toDouble(),
                        secondRow: false,
                        isProduct: true,
                      ),
                    ),
                    //
                  ],
                ),
              ),
              Expanded(
                child: SizedBox(
                  child: Builder(
                    builder: (context) {
                      if (products.isEmpty) {
                        if (!authorization(
                          authorized:
                              Authorizations().addProduct,
                          context: context,
                        )) {
                          return Center(
                            child: SingleChildScrollView(
                              child: RefreshIndicator(
                                onRefresh: getProductList,
                                color:
                                    theme
                                        .lightModeColor
                                        .prColor300,
                                backgroundColor:
                                    Colors.white,
                                displacement: 10,
                                child: EmptyWidgetDisplayOnly(
                                  subText:
                                      'No Item has been added to this store yet.',
                                  title:
                                      'You have no Items Yet',
                                  height: 35,
                                  icon: Icons.clear,

                                  theme: widget.theme,
                                ),
                              ),
                            ),
                          );
                        } else {
                          return Center(
                            child: SingleChildScrollView(
                              child: RefreshIndicator(
                                onRefresh: getProductList,
                                color:
                                    theme
                                        .lightModeColor
                                        .prColor300,
                                backgroundColor:
                                    Colors.white,
                                displacement: 10,
                                child: EmptyWidgetDisplay(
                                  buttonText: 'Add Item',
                                  subText:
                                      'Click on the button below to start adding Items to your store.',
                                  title:
                                      'You have no Items Yet',
                                  svg: productIconSvg,
                                  height: 35,
                                  action: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return AddProduct();
                                        },
                                      ),
                                    ).then((_) {
                                      if (context.mounted) {
                                        setState(() {});
                                      }
                                    });
                                  },
                                  theme: widget.theme,
                                ),
                              ),
                            ),
                          );
                        }
                      } else {
                        return Padding(
                          padding:
                              const EdgeInsets.fromLTRB(
                                10.0,
                                15,
                                10,
                                15,
                              ),
                          child: Column(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(
                                      horizontal: 20.0,
                                    ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment
                                          .spaceBetween,
                                  children: [
                                    Text(
                                      style: TextStyle(
                                        fontWeight:
                                            FontWeight.bold,
                                        fontSize:
                                            theme
                                                .mobileTexts
                                                .b1
                                                .fontSize,
                                      ),
                                      'Items',
                                    ),
                                    MaterialButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (
                                              context,
                                            ) {
                                              return TotalProductsPage(
                                                theme:
                                                    theme,
                                              );
                                            },
                                          ),
                                        ).then((_) {
                                          setState(() {});
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
                                child: RefreshIndicator(
                                  onRefresh: getProductList,
                                  color:
                                      theme
                                          .lightModeColor
                                          .prColor300,
                                  backgroundColor:
                                      Colors.white,
                                  displacement: 10,
                                  child: ListView.builder(
                                    itemCount:
                                        products.length,
                                    itemBuilder: (
                                      context,
                                      index,
                                    ) {
                                      TempProductClass
                                      product =
                                          products[index];

                                      return ProductTileMain(
                                        action: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (
                                                context,
                                              ) {
                                                return ProductDetailsPage(
                                                  productId:
                                                      product
                                                          .id!,
                                                );
                                              },
                                            ),
                                          ).then((_) {
                                            if (context
                                                .mounted) {
                                              setState(() {
                                                // getProductList(
                                                //   context,
                                                // );
                                              });
                                            }
                                          });
                                        },
                                        theme: theme,
                                        product: product,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          // Overlayed search results container
          if (searchController.text.isNotEmpty ||
              searchResult != null)
            Stack(
              children: [
                Positioned(
                  top: 200,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.only(
                      // top: 40,
                      bottom: 40,
                    ),
                    color: Colors.white,
                    child: Column(
                      children: [
                        SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.only(
                            right: 30.0,
                            left: 30,
                          ),
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
                                          .b1
                                          .fontSize,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                                'Search Result ${products.where((product) => product.name.toLowerCase().contains(searchController.text.toLowerCase())).isEmpty && productsResult.isEmpty
                                    ? '(0)'
                                    : productsResult.isNotEmpty
                                    ? '(${productsResult.length})'
                                    : '(${(products.where((product) => product.name.toLowerCase().contains(searchController.text.toLowerCase())).length)})'}',
                              ),
                              IconButton(
                                onPressed: () {
                                  clearState();
                                },
                                icon: Icon(Icons.clear),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(
                                horizontal: 20.0,
                              ),
                          child: Material(
                            // elevation: 10,
                            child: Container(
                              height:
                                  MediaQuery.of(
                                    context,
                                  ).size.height *
                                  0.5,
                              padding: EdgeInsets.symmetric(
                                vertical: 15,
                                horizontal: 10,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(
                                      10,
                                    ),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        const Color.fromARGB(
                                          23,
                                          0,
                                          0,
                                          0,
                                        ),
                                    blurRadius: 5,
                                  ),
                                ],
                              ),
                              child:
                                  productsResult.isEmpty
                                      ? ListView.builder(
                                        itemCount:
                                            products
                                                .where(
                                                  (
                                                    product,
                                                  ) => product
                                                      .name
                                                      .toLowerCase()
                                                      .contains(
                                                        searchController.text.toLowerCase(),
                                                      ),
                                                )
                                                .length,
                                        itemBuilder: (
                                          context,
                                          index,
                                        ) {
                                          TempProductClass
                                          product =
                                              products
                                                  .where(
                                                    (
                                                      product,
                                                    ) => product
                                                        .name
                                                        .toLowerCase()
                                                        .contains(
                                                          searchController.text.toLowerCase(),
                                                        ),
                                                  )
                                                  .toList()[index];
                                          return SearchProductTile(
                                            action: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (
                                                    context,
                                                  ) {
                                                    return ProductDetailsPage(
                                                      productId:
                                                          product.id!,
                                                    );
                                                  },
                                                ),
                                              ).then((_) {
                                                if (context
                                                    .mounted) {
                                                  setState(
                                                    () {},
                                                  );
                                                }
                                              });
                                              clearState();
                                            },
                                            product:
                                                product,
                                          );
                                        },
                                      )
                                      : ListView.builder(
                                        itemCount:
                                            productsResult
                                                .length,
                                        itemBuilder: (
                                          context,
                                          index,
                                        ) {
                                          TempProductClass
                                          product =
                                              productsResult[index];
                                          return SearchProductTile(
                                            action: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (
                                                    context,
                                                  ) {
                                                    return ProductDetailsPage(
                                                      productId:
                                                          product.id!,
                                                    );
                                                  },
                                                ),
                                              ).then((_) {
                                                if (context
                                                    .mounted) {
                                                  setState(
                                                    () {},
                                                  );
                                                }
                                              });
                                            },
                                            product:
                                                product,
                                          );
                                        },
                                      ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
