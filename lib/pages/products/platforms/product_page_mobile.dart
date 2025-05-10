import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockitt/classes/temp_product_class.dart';
import 'package:stockitt/components/major/empty_widget_display.dart';
import 'package:stockitt/components/major/items_summary.dart';
import 'package:stockitt/components/major/top_banner.dart';
import 'package:stockitt/constants/calculations.dart';
import 'package:stockitt/constants/constants_main.dart';
import 'package:stockitt/constants/scan_barcode.dart';
import 'package:stockitt/main.dart';
import 'package:stockitt/pages/products/add_product_one/add_product.dart';
import 'package:stockitt/pages/dashboard/components/main_bottom_nav.dart';
import 'package:stockitt/pages/products/compnents/product_tile_main.dart';
import 'package:stockitt/pages/products/compnents/search_product_tile.dart';
import 'package:stockitt/pages/products/total_products/total_products_page.dart';
import 'package:stockitt/providers/data_provider.dart';
import 'package:stockitt/providers/theme_provider.dart';

class ProductPageMobile extends StatefulWidget {
  const ProductPageMobile({
    super.key,
    required this.theme,
    required this.isEmpty,
  });

  final ThemeProvider theme;
  final bool isEmpty;

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

  List<TempProductClass> productsResult = [];
  String? searchResult;
  TextEditingController searchController =
      TextEditingController();
  bool listEmpty = false;
  @override
  Widget build(BuildContext context) {
    var shop = returnShopProvider(
      context,
    ).returnShop(userId());
    var theme = returnTheme(context);
    return Scaffold(
      bottomNavigationBar: MainBottomNav(),
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(
                height: 320,
                child: Stack(
                  children: [
                    TopBanner(
                      subTitle:
                          'Data of All Product Records',
                      title: 'Products',
                      theme: widget.theme,
                      bottomSpace: 100,
                      topSpace: 30,
                      iconSvg: productIconSvg,
                    ),
                    Align(
                      alignment: Alignment(0, 1),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            listEmpty = !listEmpty;
                          });
                        },
                        child: ItemsSummary(
                          searchController:
                              searchController,
                          searchAction: (value) {
                            setState(() {
                              searchResult =
                                  searchController.text;
                            });
                          },
                          hintText: 'Search Product Name',
                          mainTitle:
                              searchResult == null ||
                                      searchController
                                              .text ==
                                          ''
                                  ? 'Products Summary'
                                  : searchController.text,
                          firsRow: true,
                          scanAction: () async {
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
                              productsResult = returnData(
                                context,
                                listen: false,
                              ).searchProductsBarcode(
                                result,
                                shop,
                              );
                            });
                          },
                          color1: Colors.green,
                          title1: 'In Stock',
                          value1:
                              returnData(
                                context,
                              ).totalInStock(),
                          color2: Colors.amber,
                          title2: 'Out of Stock',
                          value2:
                              returnData(
                                context,
                              ).totalOutOfStock(),
                          secondRow: false,
                        ),
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
                      if (!listEmpty) {
                        return Center(
                          child: SingleChildScrollView(
                            child: EmptyWidgetDisplay(
                              buttonText: 'Add Product',
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
                                    builder: (context) {
                                      return AddProduct();
                                    },
                                  ),
                                );
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
                                        fontSize: 16,
                                      ),
                                      'Products',
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
                                        );
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
                                child: ListView.builder(
                                  itemCount:
                                      returnData(context)
                                          .searchProductsName(
                                            searchController
                                                .text,
                                            shop,
                                          )
                                          .length,
                                  itemBuilder: (
                                    context,
                                    index,
                                  ) {
                                    List<TempProductClass>
                                    products = returnData(
                                      context,
                                    ).searchProductsName(
                                      searchController.text,
                                      shop,
                                    );

                                    TempProductClass
                                    product =
                                        products[index];

                                    return ProductTileMain(
                                      theme: theme,
                                      product: product,
                                    );
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
                  top: 200,
                  left: 0,
                  right: 0,
                  child: Container(
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
                          padding: const EdgeInsets.only(
                            right: 30.0,
                          ),
                          child: Row(
                            mainAxisAlignment:
                                MainAxisAlignment.end,
                            children: [
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
                            elevation: 4,
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
                              ),
                              child:
                                  productsResult.isEmpty
                                      ? ListView.builder(
                                        itemCount:
                                            Provider.of<
                                                  DataProvider
                                                >(context)
                                                .searchProductsName(
                                                  searchController
                                                      .text,
                                                  shop,
                                                )
                                                .length,
                                        itemBuilder: (
                                          context,
                                          index,
                                        ) {
                                          TempProductClass
                                          product =
                                              Provider.of<
                                                DataProvider
                                              >(
                                                context,
                                              ).searchProductsName(
                                                searchController
                                                    .text,
                                                shop,
                                              )[index];
                                          return SearchProductTile(
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
                                              spacing: 10,
                                              children: [
                                                Text(
                                                  style: TextStyle(
                                                    fontSize:
                                                        14,
                                                    fontWeight:
                                                        FontWeight.bold,
                                                  ),
                                                  product
                                                      .name,
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
                                            onTap: () {},
                                            subtitle: Text(
                                              [
                                                if (product
                                                        .color !=
                                                    null)
                                                  product
                                                      .color,
                                                if (product
                                                        .sizeType !=
                                                    null)
                                                  product
                                                      .sizeType,
                                                if (product
                                                        .size !=
                                                    null)
                                                  product
                                                      .size,
                                              ].join(
                                                '  |  ',
                                              ),
                                              style: TextStyle(
                                                color:
                                                    theme
                                                        .lightModeColor
                                                        .secColor200,
                                                fontSize:
                                                    12,
                                                fontWeight:
                                                    FontWeight
                                                        .bold,
                                              ),

                                              // 'N${formatLargeNumberDouble(product.sellingPrice)}',
                                            ),
                                            trailing: Icon(
                                              size: 20,
                                              color:
                                                  Colors
                                                      .grey
                                                      .shade400,
                                              Icons
                                                  .arrow_forward_ios_rounded,
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
              ],
            ),
        ],
      ),
    );
  }
}
