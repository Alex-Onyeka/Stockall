import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/production/production_items/production_items_details/platforms/production_items_details_mobile.dart';
import 'package:stockall/pages/production/production_items/production_items_details/platforms/production_items_details_desktop.dart';

class ProductionItemsDetailsPage extends StatefulWidget {
  final String productionItemUuid;
  const ProductionItemsDetailsPage({
    super.key,
    required this.productionItemUuid,
  });

  @override
  State<ProductionItemsDetailsPage> createState() =>
      _ProductionItemsDetailsPageState();
}

class _ProductionItemsDetailsPageState
    extends State<ProductionItemsDetailsPage> {
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < tabletScreenSmall) {
          return ProductionItemsDetailsMobile(
            theme: theme,
            productionItemUuid: widget.productionItemUuid,
          );
        } else {
          return ProductionItemsDetailsDesktop(
            theme: theme,
            productionItemUuid: widget.productionItemUuid,
          );
        }
      },
    );
  }
}
