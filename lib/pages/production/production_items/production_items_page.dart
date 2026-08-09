import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/production/production_items/platforms/production_items_page_desktop.dart';
import 'package:stockall/pages/production/production_items/platforms/production_items_page_mobile.dart';

class ProductionItemsPage extends StatelessWidget {
  final bool? seeRemainingItems;
  const ProductionItemsPage({
    super.key,
    this.seeRemainingItems,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          () =>
              FocusManager.instance.primaryFocus?.unfocus(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < mobileScreen) {
            return ProductionItemsPageMobile(
              seeRemainingItems: seeRemainingItems,
            );
          } else {
            return ProductionItemsPageDesktop(
              seeRemainingItems: seeRemainingItems,
            );
          }
        },
      ),
    );
  }
}
