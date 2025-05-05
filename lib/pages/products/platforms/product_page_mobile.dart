import 'package:flutter/material.dart';
import 'package:stockitt/classes/temp_product_class.dart';
import 'package:stockitt/components/major/empty_widget_display.dart';
import 'package:stockitt/components/major/items_summary.dart';
import 'package:stockitt/components/major/top_banner.dart';
import 'package:stockitt/constants/constants_main.dart';
import 'package:stockitt/main.dart';
import 'package:stockitt/pages/products/add_product_one/add_product.dart';
import 'package:stockitt/pages/dashboard/components/main_bottom_nav.dart';
import 'package:stockitt/pages/products/compnents/product_tile_main.dart';
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
  bool listEmpty = false;
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Scaffold(
      bottomNavigationBar: MainBottomNav(),
      body: Column(
        children: [
          SizedBox(
            height: 320,
            child: Stack(
              children: [
                TopBanner(
                  subTitle: 'Data of All Product Records',
                  title: 'Products',
                  theme: widget.theme,
                  bottomSpace: 100,
                  topSpace: 30,
                  iconSvg: productIconSvg,
                ),
                Align(
                  alignment: Alignment(0, 1),
                  child: InkWell(
                    onTap:
                        () => setState(() {
                          listEmpty = !listEmpty;
                        }),
                    child: ItemsSummary(
                      hintText: 'Search Product Name',
                      mainTitle: 'Total Revenue',
                      firsRow: true,
                      searchAction: () {},
                      color1: Colors.green,
                      title1: 'In Stock',
                      value1: 9000,
                      color2: Colors.amber,
                      title2: 'Out of Stock',
                      value2: 50,
                      secondRow: false,
                    ),
                  ),
                ),
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
                          title: 'You have no Products Yet',
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
                      padding: const EdgeInsets.fromLTRB(
                        30.0,
                        15,
                        30,
                        15,
                      ),
                      child: ListView.builder(
                        itemCount:
                            returnData(
                              context,
                            ).products.length,
                        itemBuilder: (context, index) {
                          List<TempProductClass> products =
                              returnData(context).products;

                          TempProductClass product =
                              products[index];

                          return ProductTileMain(
                            theme: theme,
                            product: product,
                          );
                        },
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
