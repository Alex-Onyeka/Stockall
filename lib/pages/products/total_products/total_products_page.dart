import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_product_class.dart';
import 'package:stockall/components/buttons/floating_action_butto.dart';
import 'package:stockall/components/major/empty_widget_display.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/components/text_fields/text_field_barcode.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/scan_barcode.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/products/add_product_one/add_product.dart';
import 'package:stockall/pages/products/compnents/product_filter_button.dart';
import 'package:stockall/pages/products/compnents/product_tile_main.dart';
import 'package:stockall/pages/products/compnents/search_product_tile.dart';
import 'package:stockall/pages/products/product_details/product_details_page.dart';
import 'package:stockall/providers/theme_provider.dart';

class TotalProductsPage extends StatefulWidget {
  const TotalProductsPage({super.key, required this.theme});

  final ThemeProvider theme;

  @override
  State<TotalProductsPage> createState() =>
      _TotalProductsPageState();
}

class _TotalProductsPageState
    extends State<TotalProductsPage> {
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

  late Future<List<TempProductClass>> _productsFuture;
  @override
  void initState() {
    super.initState();
    returnData(
      context,
      listen: false,
    ).toggleFloatingAction(context);
    _productsFuture = getProductList(context);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _productsFuture = getProductList(context);
  }

  Future<List<TempProductClass>> getProductList(
    BuildContext context,
  ) async {
    return await returnData(
      context,
      listen: false,
    ).getProducts(shopId(context));
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return GestureDetector(
      onTap:
          () =>
              FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: appBar(
          context: context,
          title: 'All Products',
        ),
        floatingActionButton: Visibility(
          visible:
              returnLocalDatabase(
                context,
              ).currentEmployee!.role ==
              'Owner',
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
                  _productsFuture = getProductList(context);
                });
              });
            },
            color: theme.lightModeColor.secColor100,
            text: 'Add Products',
            theme: theme,
          ),
        ),
        floatingActionButtonLocation:
            FloatingActionButtonLocation.endFloat,
        body: FutureBuilder(
          future: _productsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return returnCompProvider(
                context,
                listen: false,
              ).showLoader('Loading');
            } else if (snapshot.hasError) {
              return Center(
                child: EmptyWidgetDisplay(
                  title: 'An Error Occoured',
                  subText:
                      'We Couldn\'t Load Your Data. Check Your internet',
                  buttonText: 'Reload',
                  icon: Icons.clear,
                  theme: theme,
                  height: 30,
                  action: () {
                    Navigator.popAndPushNamed(context, '/');
                  },
                ),
              );
            } else {
              var products = snapshot.data!;
              List<TempProductClass> filterProducts() {
                switch (currentSelect) {
                  case 1:
                    return products
                        .where((p) => p.quantity != 0)
                        .toList();
                  case 2:
                    return products
                        .where(
                          (p) =>
                              p.quantity <= 10 &&
                              p.quantity != 0,
                        )
                        .toList();
                  case 3:
                    return products
                        .where((p) => p.quantity == 0)
                        .toList();
                  case 0:
                  default:
                    return products;
                }
              }

              return Stack(
                children: [
                  Column(
                    children: [
                      SizedBox(height: 10),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30.0,
                        ),
                        child: TextFieldBarcode(
                          searchController:
                              searchController,

                          onChanged: (value) {
                            setState(() {
                              searchResult = value;
                            });
                          },

                          onPressedScan: () async {
                            String result = await scanCode(
                              context,
                              'Scan Failed',
                            );
                            setState(() {
                              searchController.text =
                                  result;
                            });
                            if (!context.mounted) return;
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
                                    child: EmptyWidgetDisplay(
                                      buttonText:
                                          'Add Product',
                                      subText:
                                          'Click on the button below to start adding Products to your store.',
                                      title:
                                          'You have no Products Yet',
                                      svg: productIconSvg,
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
                                            _productsFuture =
                                                getProductList(
                                                  context,
                                                );
                                          }
                                        });
                                      },
                                      theme: widget.theme,
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
                                                  20.0,
                                            ),
                                        child: SizedBox(
                                          width:
                                              double
                                                  .infinity,
                                          // height: 40,
                                          child: SingleChildScrollView(
                                            clipBehavior:
                                                Clip.hardEdge,
                                            scrollDirection:
                                                Axis.horizontal,
                                            child: Row(
                                              spacing: 5,
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .center,
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
                                                  number: 0,
                                                  title:
                                                      'All Products',
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
                                                  number: 1,
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
                                                  number: 2,
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
                                                  number: 3,
                                                  title:
                                                      'Out of Stock',
                                                  theme:
                                                      theme,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Expanded(
                                        child: Builder(
                                          builder: (
                                            context,
                                          ) {
                                            if (filterProducts()
                                                .isNotEmpty) {
                                              return ListView.builder(
                                                itemCount:
                                                    filterProducts()
                                                        .length,
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
                                                              productId:
                                                                  product.id!,
                                                            );
                                                          },
                                                        ),
                                                      ).then((
                                                        _,
                                                      ) {
                                                        if (context.mounted) {
                                                          setState(
                                                            () {
                                                              _productsFuture = getProductList(
                                                                context,
                                                              );
                                                            },
                                                          );
                                                        }
                                                      });
                                                    },
                                                    theme:
                                                        theme,
                                                    product:
                                                        product,
                                                  );
                                                },
                                              );
                                            } else {
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.only(
                                                      bottom:
                                                          30.0,
                                                    ),
                                                child: EmptyWidgetDisplayOnly(
                                                  title:
                                                      'Empty List',
                                                  subText:
                                                      'You Don\'t have any product under this category',

                                                  icon:
                                                      Icons
                                                          .dangerous_outlined,
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
                  if (searchController.text.isNotEmpty ||
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
                              height: double.maxFinite,
                              padding: EdgeInsets.only(
                                // top: 40,
                                bottom: 40,
                              ),
                              color: const Color.fromARGB(
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
                                      color: Colors.white,
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(
                                              left: 20.0,
                                              right: 10,
                                            ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceBetween,
                                          children: [
                                            Text(
                                              style: TextStyle(
                                                fontWeight:
                                                    FontWeight
                                                        .bold,
                                                fontSize:
                                                    theme
                                                        .mobileTexts
                                                        .h4
                                                        .fontSize,
                                              ),
                                              'Found ${productsResult.isEmpty ? products.where((product) => product.name.toLowerCase().contains(searchController.text.toLowerCase())).length : productsResult.length} Items',
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.only(
                                                    right:
                                                        0.0,
                                                  ),
                                              child: IconButton(
                                                color:
                                                    Colors
                                                        .black,
                                                onPressed: () {
                                                  clearState();
                                                },
                                                icon: Icon(
                                                  Icons
                                                      .clear,
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
                                          horizontal: 20.0,
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
                                              vertical: 0,
                                              horizontal:
                                                  10,
                                            ),
                                        decoration:
                                            BoxDecoration(
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
                                                            ) => product.name.toLowerCase().contains(
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
                                                              ) => product.name.toLowerCase().contains(
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
                                                        ).then((
                                                          _,
                                                        ) {
                                                          if (context.mounted) {
                                                            setState(
                                                              () {
                                                                _productsFuture = getProductList(
                                                                  context,
                                                                );
                                                              },
                                                            );
                                                          }
                                                        });
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
                                                    return ListTile(
                                                      title: Row(
                                                        spacing:
                                                            10,
                                                        children: [
                                                          Text(
                                                            style: TextStyle(
                                                              fontSize:
                                                                  14,
                                                              fontWeight:
                                                                  FontWeight.bold,
                                                            ),
                                                            product.name,
                                                          ),
                                                          Text(
                                                            style: TextStyle(
                                                              fontSize:
                                                                  14,
                                                              fontWeight:
                                                                  FontWeight.bold,
                                                            ),
                                                            'N${formatLargeNumberDouble(product.sellingPrice)}',
                                                          ),
                                                        ],
                                                      ),
                                                      onTap:
                                                          () {},
                                                      subtitle: Text(
                                                        [
                                                          if (product.color !=
                                                              null)
                                                            product.color,
                                                          if (product.sizeType !=
                                                              null)
                                                            product.sizeType,
                                                          if (product.size !=
                                                              null)
                                                            product.size,
                                                        ].join(
                                                          '  |  ',
                                                        ),
                                                        style: TextStyle(
                                                          color:
                                                              theme.lightModeColor.secColor200,
                                                          fontSize:
                                                              12,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),

                                                        // 'N${formatLargeNumberDouble(product.sellingPrice)}',
                                                      ),
                                                      trailing: Icon(
                                                        size:
                                                            20,
                                                        color:
                                                            Colors.grey.shade400,
                                                        Icons.arrow_forward_ios_rounded,
                                                      ),
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
              );
            }
          },
        ),
      ),
    );
  }
}
