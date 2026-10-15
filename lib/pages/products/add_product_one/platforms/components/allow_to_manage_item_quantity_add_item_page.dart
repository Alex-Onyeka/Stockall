import 'package:flutter/material.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/theme_provider.dart';

class AllowToManageItemQuantityAddItemPage extends StatelessWidget {
  const AllowToManageItemQuantityAddItemPage({super.key, required this.theme});

  final ThemeProvider theme;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      mouseCursor: SystemMouseCursors.click,
      onTap: () {
        returnData().toggleIsManaged(context: context);
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  style: TextStyle(
                    fontSize: theme.mobileTexts.b1.fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                  'Allow Stockall to Manage Item Quantity?',
                ),
                Column(
                  spacing: 5,
                  children: [
                    Text(
                      style: TextStyle(fontSize: 10),
                      'This controls whether Item quantity is automatically deducted after sales, and notifications are sent when item quantity is low or out of stock.',
                    ),
                    // Text(
                    //   'NOTE: if "YES", then cashier can set a custom price during sale, instead of the selling price.',
                    // ),
                  ],
                ),
              ],
            ),
          ),
          Checkbox(
            activeColor: theme.lightModeColor.secColor100,
            value: returnData(context: context).isManaged,
            onChanged: (value) {
              returnData().toggleIsManaged(context: context);
              FocusManager.instance.primaryFocus?.unfocus();
            },
          ),
        ],
      ),
    );
  }
}
