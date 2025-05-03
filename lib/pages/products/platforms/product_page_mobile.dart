import 'package:flutter/material.dart';
import 'package:stockitt/components/major/empty_widget_display.dart';
import 'package:stockitt/components/major/items_summary.dart';
import 'package:stockitt/components/major/top_banner.dart';
import 'package:stockitt/constants/constants_main.dart';
import 'package:stockitt/pages/products/add_product_one/add_product.dart';
import 'package:stockitt/pages/dashboard/components/main_bottom_nav.dart';
import 'package:stockitt/providers/theme_provider.dart';

class ProductPageMobile extends StatelessWidget {
  const ProductPageMobile({
    super.key,
    required this.theme,
    required this.isEmpty,
  });

  final ThemeProvider theme;
  final bool isEmpty;

  @override
  Widget build(BuildContext context) {
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
                  theme: theme,
                  bottomSpace: 100,
                  topSpace: 30,
                  iconSvg: productIconSvg,
                ),
                Align(
                  alignment: Alignment(0, 1),
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
              ],
            ),
          ),
          Expanded(
            child: SizedBox(
              child: Builder(
                builder: (context) {
                  if (isEmpty) {
                    return EmptyWidgetDisplay(
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
                      theme: theme,
                    );
                  } else {
                    return Column();
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
