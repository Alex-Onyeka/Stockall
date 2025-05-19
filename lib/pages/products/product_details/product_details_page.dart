import 'package:flutter/material.dart';
import 'package:stockitt/classes/temp_product_class.dart';
import 'package:stockitt/components/major/empty_widget_display_only.dart';
import 'package:stockitt/main.dart';

class ProductDetailsPage extends StatefulWidget {
  final int productId;
  const ProductDetailsPage({
    super.key,
    required this.productId,
  });

  @override
  State<ProductDetailsPage> createState() =>
      _ProductDetailsPageState();
}

class _ProductDetailsPageState
    extends State<ProductDetailsPage> {
  late Future<TempProductClass> productFuture;

  Future<TempProductClass> getProduct() async {
    var tempProduct = await returnData(
      context,
      listen: false,
    ).getProducts(
      returnShopProvider(
        context,
        listen: false,
      ).userShop!.shopId!,
    );

    return tempProduct.firstWhere(
      (product) => product.id == widget.productId,
    );
  }

  @override
  void initState() {
    super.initState();
    productFuture = getProduct();
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Scaffold(
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
            Text(
              style: TextStyle(
                fontSize: theme.mobileTexts.h4.fontSize,
                fontWeight: FontWeight.bold,
              ),
              'Product Details',
            ),
          ],
        ),
      ),
      body: FutureBuilder<TempProductClass>(
        future: productFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return returnCompProvider(
              context,
              listen: false,
            ).showLoader('Loading');
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.only(
                  bottom: 30.0,
                ),
                child: EmptyWidgetDisplayOnly(
                  title: 'An Error Occured',
                  subText:
                      'Please Check your internet connection and try again',
                  theme: theme,
                  height: 30,
                  icon: Icons.clear,
                ),
              ),
            );
          } else {
            return Center(
              child: Padding(
                padding: const EdgeInsets.only(
                  bottom: 30.0,
                ),
                child: EmptyWidgetDisplayOnly(
                  title: 'Coming Soon',
                  subText:
                      'This feature is not yet available... Our group of dedicated professional engineers are working on it.',
                  theme: theme,
                  height: 30,
                  icon: Icons.clear,
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
