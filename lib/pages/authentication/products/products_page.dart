import 'package:flutter/material.dart';
import 'package:stockitt/components/major/empty_widget_display.dart';
import 'package:stockitt/components/major/items_summary.dart';
import 'package:stockitt/components/major/top_banner.dart';
import 'package:stockitt/constants/constants_main.dart';
import 'package:stockitt/main.dart';
import 'package:stockitt/pages/dashboard/components/main_bottom_nav.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  bool isEmpty = true;
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return SafeArea(
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          bottomNavigationBar: MainBottomNav(),
          body: Column(
            children: [
              SizedBox(
                height: 320,
                child: Stack(
                  children: [
                    TopBanner(
                      subTitle:
                          'Data of All Product Records',
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
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      if (isEmpty) {
                        return EmptyWidgetDisplay(
                          buttonText: 'Add Product',
                          subText:
                              'Click on the button below to start adding Products to your store.',
                          title: 'You have no Products Yet',
                          svg: productIconSvg,
                          height: 35,
                          action: () {},
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
        ),
      ),
    );
  }
}
