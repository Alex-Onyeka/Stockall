import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_product_class.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';

class SearchProductTile extends StatelessWidget {
  final TempProductClass product;
  final Function() action;
  const SearchProductTile({
    super.key,
    required this.product,
    required this.action,
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
            '$nairaSymbol${formatLargeNumberDouble(product.sellingPrice ?? 0)}',
          ),
        ],
      ),
      onTap: action,
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
