import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_shop/temp_shop_class.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/providers/theme_provider.dart';

class ShopDetailsTopSectionWidget extends StatelessWidget {
  const ShopDetailsTopSectionWidget({
    super.key,
    required this.theme,
    required this.shop,
  });

  final ThemeProvider theme;
  final TempShopClass shop;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 30),
      padding: EdgeInsets.symmetric(
        vertical: 15,
        horizontal: 15,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.grey.shade100,
      ),
      child: Row(
        spacing: 10,
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color.fromARGB(43, 0, 150, 135),
            ),
            child: Image.asset(shopIconImage, height: 80),
          ),
          Expanded(
            child: Column(
              spacing: 5,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(
                      color: Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize:
                          theme.mobileTexts.b4.fontSize,
                    ),
                    "#Shop ID: ${shopRef()}",
                  ),
                ),
                Text(
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: theme.mobileTexts.b2.fontSize,
                  ),
                  shop.name,
                ),
                Text(
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: theme.mobileTexts.b3.fontSize,
                  ),
                  shop.phoneNumber ??
                      'Phone Number Not Set',
                ),
                Text(
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: theme.mobileTexts.b3.fontSize,
                    color: theme.lightModeColor.secColor200,
                  ),
                  shop.email ?? 'Email Not Set',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
