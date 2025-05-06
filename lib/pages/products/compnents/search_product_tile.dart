import 'package:flutter/material.dart';
import 'package:stockitt/classes/temp_product_class.dart';
import 'package:stockitt/constants/calculations.dart';
import 'package:stockitt/main.dart';
import 'package:stockitt/pages/products/product_details/product_details_page.dart';

class SearchProductTile extends StatelessWidget {
  final TempProductClass product;
  const SearchProductTile({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return ListTile(
      title: Row(
        spacing: 10,
        children: [
          Text(
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            product.name,
          ),
          Text(
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            'N${formatLargeNumberDouble(product.sellingPrice)}',
          ),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return ProductDetailsPage(product: product);
            },
          ),
        );
      },
      subtitle: Text(
        [
          if (product.color != null) product.color,
          if (product.sizeType != null) product.sizeType,
          if (product.size != null) product.size,
        ].join('  |  '),
        style: TextStyle(
          color: theme.lightModeColor.secColor200,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),

        // 'N${formatLargeNumberDouble(product.sellingPrice)}',
      ),
      trailing: Icon(
        size: 20,
        color: Colors.grey.shade400,
        Icons.arrow_forward_ios_rounded,
      ),
    );
  }
}
