import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stockitt/classes/temp_product_class.dart';
import 'package:stockitt/components/major/empty_widget_display.dart';
import 'package:stockitt/constants/calculations.dart';
import 'package:stockitt/constants/constants_main.dart';
import 'package:stockitt/constants/scan_barcode.dart';
import 'package:stockitt/main.dart';
import 'package:stockitt/pages/products/add_product_one/add_product.dart';
import 'package:stockitt/pages/products/compnents/product_tile_main.dart';
import 'package:stockitt/providers/data_provider.dart';
import 'package:stockitt/providers/theme_provider.dart';

class TotalProductsPage extends StatefulWidget {
  const TotalProductsPage({super.key, required this.theme});

  final ThemeProvider theme;

  @override
  State<TotalProductsPage> createState() =>
      _TotalProductsPageState();
}

class _TotalProductsPageState
    extends State<TotalProductsPage> {
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
  bool listEmpty = false;
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return GestureDetector(
      onTap:
          () =>
              FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 60,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Padding(
              padding: const EdgeInsets.only(
                left: 20.0,
                right: 10,
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded),
            ),
          ),
          centerTitle: true,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    listEmpty = !listEmpty;
                  });
                },
                child: Text(
                  style: TextStyle(
                    fontSize: theme.mobileTexts.h4.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  'All Products',
                ),
              ),
            ],
          ),
        ),
        // bottomNavigationBar: MainBottomNav(),
        body: Stack(
          children: [
            Column(
              children: [
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30.0,
                  ),
                  child: TextFormField(
                    controller: searchController,
                    onChanged: (value) {
                      setState(() {
                        searchResult = value;
                      });
                    },
                    onTap: () {
                      setState(() {
                        isFocus = true;
                      });
                    },
                    onTapOutside: (p0) {
                      setState(() {
                        isFocus = false;
                      });
                    },
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: isFocus,
                      suffixIcon: IconButton(
                        onPressed: () async {
                          String result = await scanCode(
                            context,
                            'Scan Failed',
                          );
                          setState(() {
                            searchController.text = result;
                          });
                          if (!context.mounted) return;
                          setState(() {
                            productsResult = returnData(
                              context,
                              listen: false,
                            ).searchProductsBarcode(result);
                          });
                        },
                        icon: Icon(
                          color:
                              isFocus
                                  ? theme
                                      .lightModeColor
                                      .secColor100
                                  : Colors.grey.shade600,
                          Icons.qr_code_scanner,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      prefixIcon: Icon(
                        size: 25,
                        color:
                            isFocus
                                ? theme
                                    .lightModeColor
                                    .secColor100
                                : Colors.grey,
                        Icons.search_rounded,
                      ),
                      hintText:
                          'Search Name or Scan Barcode',
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          30,
                        ),
                        borderSide: BorderSide(
                          color: Colors.grey.shade500,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          30,
                        ),
                        borderSide: BorderSide(
                          color:
                              theme
                                  .lightModeColor
                                  .prColor300,
                          width: 1.5,
                        ),
                      ),
                    ),
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
                                  child: SizedBox(
                                    width: double.infinity,
                                    height: 40,
                                    child: ListView(
                                      scrollDirection:
                                          Axis.horizontal,
                                      children: [
                                        ProductsFilterButton(
                                          action: () {},
                                          title:
                                              'All Products',
                                          theme: theme,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),
                                Expanded(
                                  child: ListView.builder(
                                    itemCount:
                                        returnData(context)
                                            .searchProductsName(
                                              searchController
                                                  .text,
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
                                        searchController
                                            .text,
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
                                        'Found ${Provider.of<DataProvider>(context).searchProductsBarcode(searchController.text).isEmpty ? Provider.of<DataProvider>(context).searchProductsName(searchController.text).length : Provider.of<DataProvider>(context).searchProductsBarcode(searchController.text).length} Items',
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(
                                              right: 0.0,
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
                                                  )[index];
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
                                                onTap:
                                                    () {},
                                                subtitle: Text(
                                                  [
                                                    if (product.color !=
                                                        null)
                                                      product
                                                          .color,
                                                    if (product.sizeType !=
                                                        null)
                                                      product
                                                          .sizeType,
                                                    if (product.size !=
                                                        null)
                                                      product
                                                          .size,
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
                                                onTap:
                                                    () {},
                                                subtitle: Text(
                                                  [
                                                    if (product.color !=
                                                        null)
                                                      product
                                                          .color,
                                                    if (product.sizeType !=
                                                        null)
                                                      product
                                                          .sizeType,
                                                    if (product.size !=
                                                        null)
                                                      product
                                                          .size,
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
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class ProductsFilterButton extends StatelessWidget {
  final String title;
  final Function()? action;
  const ProductsFilterButton({
    super.key,
    required this.theme,
    required this.action,
    required this.title,
  });

  final ThemeProvider theme;

  @override
  Widget build(BuildContext context) {
    return Ink(
      decoration: BoxDecoration(
        color: theme.lightModeColor.prColor300,
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        radius: 15,
        onTap: action,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 3,
          ),

          child: Center(
            child: Text(
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              title,
            ),
          ),
        ),
      ),
    );
  }
}
