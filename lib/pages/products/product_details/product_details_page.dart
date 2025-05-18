import 'package:flutter/material.dart';
import 'package:stockitt/classes/temp_product_class.dart';
import 'package:stockitt/components/major/empty_widget_display_only.dart';
import 'package:stockitt/main.dart';

class ProductDetailsPage extends StatelessWidget {
  final TempProductClass product;
  const ProductDetailsPage({
    super.key,
    required this.product,
  });

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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 30.0),
          child: EmptyWidgetDisplayOnly(
            title: 'Coming Soon',
            subText:
                'This feature is not yet available... Our group of dedicated professional engineers are working on it.',
            theme: theme,
            height: 30,
            icon: Icons.clear,
          ),
        ),
      ),
    );
  }
}
