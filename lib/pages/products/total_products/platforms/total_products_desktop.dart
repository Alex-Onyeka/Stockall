import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/buttons/floating_action_butto.dart';
import 'package:stockall/components/major/drawer_widget/platforms/my_drawer_widget_desktop.dart';
import 'package:stockall/components/major/empty_widget_display.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/components/major/drawer_widget/my_drawer_widget.dart';
import 'package:stockall/components/major/right_side_bar.dart';
import 'package:stockall/components/text_fields/text_field_barcode.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/constants/scan_barcode.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/products/add_product_one/add_product.dart';
import 'package:stockall/pages/products/compnents/product_filter_button.dart';
import 'package:stockall/pages/products/compnents/product_tile_main.dart';
import 'package:stockall/pages/products/compnents/search_product_tile.dart';
import 'package:stockall/pages/products/product_details/product_details_page.dart';
import 'package:stockall/providers/theme_provider.dart';
import 'package:stockall/services/auth_service.dart';

class TotalProductsDesktop extends StatefulWidget {
  const TotalProductsDesktop({
    super.key,
    required this.theme,
  });

  final ThemeProvider theme;

  @override
  State<TotalProductsDesktop> createState() =>
      _TotalProductsDesktopState();
}

class _TotalProductsDesktopState
    extends State<TotalProductsDesktop> {
  int currentSelect = 0;
  void changeSelected(int number) {
    currentSelect = number;
  }

  void clearState() {
    setState(() {
      searchResult = null;
      searchController.clear();
      productsResult.clear();
    });
  }

  List<TempProductClass> productsResult = [];
  String? searchResult;
  bool isFocus = false;
  TextEditingController searchController =
      TextEditingController();

  bool isLoading = false;

  // late Future<List<TempProductClass>> _productsFuture;
  @override
  void initState() {
    super.initState();
    returnData(
      context,
      listen: false,
    ).toggleFloatingAction(context);

    // _productsFuture = getProductList(context);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // _productsFuture = getProductList(context);
  }

  Future<void> getProductList() async {
    await returnData(
      context,
      listen: false,
    ).getProducts(shopId(context));
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey =
      GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    var products = returnData(context).productList;
    List<TempProductClass> filterProducts() {
      switch (currentSelect) {
        case 1:
          return products
              .where(
                (p) =>
                    p.quantity != 0 && p.quantity != null,
              )
              .toList();
        case 2:
          return products
              .where(
                (p) =>
                    p.quantity != null &&
                    p.quantity! <= p.lowQtty! &&
                    p.quantity != 0,
              )
              .toList();
        case 3:
          return products
              .where((p) => p.quantity == 0)
              .toList();
        case 4:
          return products
              .where((p) => !p.isManaged)
              .toList();
        case 0:
        default:
          return products;
      }
    }

    return Scaffold(
      key: _scaffoldKey,
      drawer: MyDrawerWidgetDesktopMain(
        action: () {
          var safeContext = context;
          showDialog(
            context: context,
            builder: (context) {
              return ConfirmationAlert(
                theme: theme,
                message: 'You are about to Logout',
                title: 'Are you Sure?',
                action: () async {
                  Navigator.of(context).pop();
                  setState(() {
                    isLoading = true;
                  });
                  if (safeContext.mounted) {
                    await AuthService().signOut(
                      safeContext,
                    );
                  }
                },
              );
            },
          );
        },
        theme: theme,
        notifications:
            returnNotificationProvider(
                  context,
                ).notifications.isEmpty
                ? []
                : returnNotificationProvider(
                  context,
                ).notifications,
        globalKey: _scaffoldKey,
      ),
      body: Stack(
        children: [
          Row(
            spacing: 15,
            children: [
              MyDrawerWidget(
                globalKey: _scaffoldKey,
                action: () {
                  var safeContext = context;
                  showDialog(
                    context: context,
                    builder: (context) {
                      return ConfirmationAlert(
                        theme: theme,
                        message: 'You are about to Logout',
                        title: 'Are you Sure?',
                        action: () async {
                          Navigator.of(context).pop();
                          setState(() {
                            isLoading = true;
                          });
                          if (safeContext.mounted) {
                            await AuthService().signOut(
                              safeContext,
                            );
                          }
                        },
                      );
                    },
                  );
                },
                theme: theme,
                notifications:
                    returnNotificationProvider(
                          context,
                        ).notifications.isEmpty
                        ? []
                        : returnNotificationProvider(
                          context,
                        ).notifications,
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(
                    vertical: 15,
                  ),
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(
                          39,
                          4,
                          1,
                          41,
                        ),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Scaffold(
                    appBar: appBar(
                      context: context,
                      title: 'All Items',
                      widget: Visibility(
                        visible:
                            screenWidth(context) >
                            mobileScreen,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius:
                                BorderRadius.circular(10),
                            onTap: () async {
                              await getProductList();
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(
                                10,
                              ),
                              child: Row(
                                spacing: 5,
                                children: [
                                  Text(
                                    style: TextStyle(
                                      fontSize:
                                          theme
                                              .mobileTexts
                                              .b3
                                              .fontSize,
                                      fontWeight:
                                          FontWeight.bold,
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
                    ),
                    floatingActionButton: Visibility(
                      visible: authorization(
                        authorized:
                            Authorizations().addProduct,
                        context: context,
                      ),
                      child: FloatingActionButtonMain(
                        action: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return AddProduct();
                              },
                            ),
                          ).then((_) {
                            setState(() {
                              // getProductList(context);
                            });
                          });
                        },
                        color:
                            theme
                                .lightModeColor
                                .secColor100,
                        text: 'Add Products',
                        theme: theme,
                      ),
                    ),
                    floatingActionButtonLocation:
                        FloatingActionButtonLocation
                            .endFloat,
                    body: Stack(
                      children: [
                        Column(
                          children: [
                            SizedBox(height: 10),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(
                                    horizontal: 30.0,
                                  ),
                              child: TextFieldBarcode(
                                clearTextField: () {
                                  setState(() {});
                                },
                                searchController:
                                    searchController,

                                onChanged: (value) {
                                  setState(() {
                                    searchResult = value;
                                  });
                                },

                                onPressedScan: () async {
                                  String? result =
                                      await scanCode(
                                        context,
                                        'Scan Failed',
                                      );
                                  setState(() {
                                    if (result != null) {
                                      searchController
                                          .text = result;
                                    } else {
                                      return;
                                    }
                                  });
                                  if (!context.mounted)
                                    return;
                                  setState(() {
                                    productsResult =
                                        products
                                            .where(
                                              (product) =>
                                                  product
                                                      .barcode ==
                                                  result,
                                            )
                                            .toList();
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              child: SizedBox(
                                child: Builder(
                                  builder: (context) {
                                    if (products.isEmpty) {
                                      return Center(
                                        child: SingleChildScrollView(
                                          child: RefreshIndicator(
                                            onRefresh:
                                                getProductList,
                                            color:
                                                theme
                                                    .lightModeColor
                                                    .prColor300,
                                            backgroundColor:
                                                Colors
                                                    .white,
                                            displacement:
                                                10,
                                            child: EmptyWidgetDisplay(
                                              buttonText:
                                                  'Add Item',
                                              subText:
                                                  'Click on the button below to start adding Items to your store.',
                                              title:
                                                  'You have no Items Yet',
                                              svg:
                                                  productIconSvg,
                                              height: 35,
                                              action: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (
                                                      context,
                                                    ) {
                                                      return AddProduct();
                                                    },
                                                  ),
                                                ).then((_) {
                                                  if (context
                                                      .mounted) {
                                                    // _productsFuture =
                                                    // getProductList(
                                                    //   context,
                                                    // );
                                                  }
                                                });
                                              },
                                              theme:
                                                  widget
                                                      .theme,
                                            ),
                                          ),
                                        ),
                                      );
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
                                                    horizontal:
                                                        5.0,
                                                  ),
                                              child: SizedBox(
                                                width:
                                                    double
                                                        .infinity,
                                                // height: 40,
                                                child: Builder(
                                                  builder: (
                                                    context,
                                                  ) {
                                                    if (screenWidth(
                                                          context,
                                                        ) <
                                                        tabletScreen) {
                                                      return SingleChildScrollView(
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        child: Row(
                                                          spacing:
                                                              6,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment.center,
                                                          children: [
                                                            ProductsFilterButton(
                                                              action: () {
                                                                setState(
                                                                  () {
                                                                    changeSelected(
                                                                      0,
                                                                    );
                                                                  },
                                                                );
                                                              },
                                                              currentSelected:
                                                                  currentSelect,
                                                              number:
                                                                  0,
                                                              title:
                                                                  'All Items',
                                                              theme:
                                                                  theme,
                                                            ),
                                                            ProductsFilterButton(
                                                              action: () {
                                                                setState(
                                                                  () {
                                                                    changeSelected(
                                                                      1,
                                                                    );
                                                                  },
                                                                );
                                                              },
                                                              currentSelected:
                                                                  currentSelect,
                                                              number:
                                                                  1,
                                                              title:
                                                                  'In Stock',
                                                              theme:
                                                                  theme,
                                                            ),
                                                            ProductsFilterButton(
                                                              action: () {
                                                                setState(
                                                                  () {
                                                                    changeSelected(
                                                                      2,
                                                                    );
                                                                  },
                                                                );
                                                              },
                                                              currentSelected:
                                                                  currentSelect,
                                                              number:
                                                                  2,
                                                              title:
                                                                  'Low Stock',
                                                              theme:
                                                                  theme,
                                                            ),
                                                            ProductsFilterButton(
                                                              currentSelected:
                                                                  currentSelect,
                                                              action: () {
                                                                setState(
                                                                  () {
                                                                    changeSelected(
                                                                      3,
                                                                    );
                                                                  },
                                                                );
                                                              },
                                                              number:
                                                                  3,
                                                              title:
                                                                  'Out of Stock',
                                                              theme:
                                                                  theme,
                                                            ),
                                                            ProductsFilterButton(
                                                              currentSelected:
                                                                  currentSelect,
                                                              action: () {
                                                                setState(
                                                                  () {
                                                                    changeSelected(
                                                                      4,
                                                                    );
                                                                  },
                                                                );
                                                              },
                                                              number:
                                                                  4,
                                                              title:
                                                                  'UnManaged',
                                                              theme:
                                                                  theme,
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    } else {
                                                      return Row(
                                                        spacing:
                                                            5,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment.center,
                                                        children: [
                                                          ProductsFilterButton(
                                                            action: () {
                                                              setState(
                                                                () {
                                                                  changeSelected(
                                                                    0,
                                                                  );
                                                                },
                                                              );
                                                            },
                                                            currentSelected:
                                                                currentSelect,
                                                            number:
                                                                0,
                                                            title:
                                                                'All Items',
                                                            theme:
                                                                theme,
                                                          ),
                                                          ProductsFilterButton(
                                                            action: () {
                                                              setState(
                                                                () {
                                                                  changeSelected(
                                                                    1,
                                                                  );
                                                                },
                                                              );
                                                            },
                                                            currentSelected:
                                                                currentSelect,
                                                            number:
                                                                1,
                                                            title:
                                                                'In Stock',
                                                            theme:
                                                                theme,
                                                          ),
                                                          ProductsFilterButton(
                                                            action: () {
                                                              setState(
                                                                () {
                                                                  changeSelected(
                                                                    2,
                                                                  );
                                                                },
                                                              );
                                                            },
                                                            currentSelected:
                                                                currentSelect,
                                                            number:
                                                                2,
                                                            title:
                                                                'Low Stock',
                                                            theme:
                                                                theme,
                                                          ),
                                                          ProductsFilterButton(
                                                            currentSelected:
                                                                currentSelect,
                                                            action: () {
                                                              setState(
                                                                () {
                                                                  changeSelected(
                                                                    3,
                                                                  );
                                                                },
                                                              );
                                                            },
                                                            number:
                                                                3,
                                                            title:
                                                                'Out of Stock',
                                                            theme:
                                                                theme,
                                                          ),
                                                          ProductsFilterButton(
                                                            currentSelected:
                                                                currentSelect,
                                                            action: () {
                                                              setState(
                                                                () {
                                                                  changeSelected(
                                                                    4,
                                                                  );
                                                                },
                                                              );
                                                            },
                                                            number:
                                                                4,
                                                            title:
                                                                'UnManaged',
                                                            theme:
                                                                theme,
                                                          ),
                                                        ],
                                                      );
                                                    }
                                                  },
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Expanded(
                                              child: Builder(
                                                builder: (
                                                  context,
                                                ) {
                                                  if (filterProducts()
                                                      .isNotEmpty) {
                                                    return RefreshIndicator(
                                                      onRefresh:
                                                          getProductList,
                                                      color:
                                                          theme.lightModeColor.prColor300,
                                                      backgroundColor:
                                                          Colors.white,
                                                      displacement:
                                                          10,
                                                      child: ListView.builder(
                                                        itemCount:
                                                            filterProducts().length,
                                                        itemBuilder: (
                                                          context,
                                                          index,
                                                        ) {
                                                          List<
                                                            TempProductClass
                                                          >
                                                          products =
                                                              filterProducts();

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
                                                                      productUuid:
                                                                          product.uuid!,
                                                                    );
                                                                  },
                                                                ),
                                                              ).then(
                                                                (
                                                                  _,
                                                                ) {
                                                                  if (context.mounted) {
                                                                    setState(
                                                                      () {
                                                                        // _productsFuture =
                                                                        // getProductList(
                                                                        //   context,
                                                                        // );
                                                                      },
                                                                    );
                                                                  }
                                                                },
                                                              );
                                                            },
                                                            theme:
                                                                theme,
                                                            product:
                                                                product,
                                                          );
                                                        },
                                                      ),
                                                    );
                                                  } else {
                                                    return Padding(
                                                      padding: const EdgeInsets.only(
                                                        bottom:
                                                            30.0,
                                                      ),
                                                      child: EmptyWidgetDisplayOnly(
                                                        title:
                                                            'Empty List',
                                                        subText:
                                                            'You Don\'t have any item under this category',

                                                        icon:
                                                            Icons.dangerous_outlined,
                                                        theme:
                                                            theme,
                                                        height:
                                                            40,
                                                      ),
                                                    );
                                                  }
                                                },
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
                        if (searchController
                                .text
                                .isNotEmpty ||
                            searchResult != null)
                          Stack(
                            children: [
                              Positioned(
                                top: 60,
                                left: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    clearState();
                                  },
                                  child: Container(
                                    height:
                                        double.maxFinite,
                                    padding:
                                        EdgeInsets.only(
                                          // top: 40,
                                          bottom: 40,
                                        ),
                                    color:
                                        const Color.fromARGB(
                                          40,
                                          0,
                                          0,
                                          0,
                                        ),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(
                                                right: 20.0,
                                                left: 20,
                                              ),
                                          child: Container(
                                            color:
                                                Colors
                                                    .white,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.only(
                                                    left:
                                                        20.0,
                                                    right:
                                                        10,
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
                                                          theme.mobileTexts.b1.fontSize,
                                                    ),
                                                    'Found ${productsResult.isEmpty ? products.where((product) => product.name.toLowerCase().contains(searchController.text.toLowerCase()) || (product.barcode != null && product.barcode!.toLowerCase().contains(searchController.text.toLowerCase()))).length : productsResult.length} Item(s)',
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.only(
                                                      right:
                                                          0.0,
                                                    ),
                                                    child: IconButton(
                                                      color:
                                                          Colors.black,
                                                      onPressed: () {
                                                        clearState();
                                                      },
                                                      icon: Icon(
                                                        Icons.clear,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.symmetric(
                                                horizontal:
                                                    20.0,
                                              ),
                                          child: Material(
                                            elevation: 4,
                                            child: Container(
                                              height:
                                                  MediaQuery.of(
                                                    context,
                                                  ).size.height *
                                                  0.6,
                                              padding:
                                                  EdgeInsets.symmetric(
                                                    vertical:
                                                        0,
                                                    horizontal:
                                                        10,
                                                  ),
                                              decoration: BoxDecoration(
                                                color:
                                                    Colors
                                                        .white,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      10,
                                                    ),
                                              ),
                                              child:
                                                  productsResult
                                                          .isEmpty
                                                      ? ListView.builder(
                                                        itemCount:
                                                            products
                                                                .where(
                                                                  (
                                                                    product,
                                                                  ) =>
                                                                      product.name.toLowerCase().contains(
                                                                        searchController.text.toLowerCase(),
                                                                      ) ||
                                                                      (product.barcode !=
                                                                              null &&
                                                                          product.barcode!.toLowerCase().contains(
                                                                            searchController.text.toLowerCase(),
                                                                          )),
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
                                                                    ) =>
                                                                        product.name.toLowerCase().contains(
                                                                          searchController.text.toLowerCase(),
                                                                        ) ||
                                                                        (product.barcode !=
                                                                                null &&
                                                                            product.barcode!.toLowerCase().contains(
                                                                              searchController.text.toLowerCase(),
                                                                            )),
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
                                                                      productUuid:
                                                                          product.uuid!,
                                                                    );
                                                                  },
                                                                ),
                                                              ).then(
                                                                (
                                                                  _,
                                                                ) {
                                                                  if (context.mounted) {
                                                                    setState(
                                                                      () {
                                                                        // _productsFuture =
                                                                        // getProductList(
                                                                        //   context,
                                                                        // );
                                                                      },
                                                                    );
                                                                  }
                                                                },
                                                              );
                                                              clearState();
                                                            },
                                                            product:
                                                                product,
                                                          );
                                                        },
                                                      )
                                                      : ListView.builder(
                                                        itemCount:
                                                            productsResult.length,
                                                        itemBuilder: (
                                                          context,
                                                          index,
                                                        ) {
                                                          TempProductClass
                                                          product =
                                                              productsResult[index];
                                                          return SearchProductTile(
                                                            product:
                                                                product,
                                                            action: () {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder: (
                                                                    context,
                                                                  ) {
                                                                    return ProductDetailsPage(
                                                                      productUuid:
                                                                          product.uuid!,
                                                                    );
                                                                  },
                                                                ),
                                                              ).then(
                                                                (
                                                                  _,
                                                                ) {
                                                                  if (context.mounted) {
                                                                    setState(
                                                                      () {
                                                                        // _productsFuture =
                                                                        // getProductList(
                                                                        //   context,
                                                                        // );
                                                                      },
                                                                    );
                                                                  }
                                                                },
                                                              );
                                                            },
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
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              RightSideBar(theme: theme),
            ],
          ),
          Visibility(
            visible: isLoading,
            child: returnCompProvider(
              context,
            ).showLoader('Logging Out...'),
          ),
        ],
      ),
    );
  }
}
