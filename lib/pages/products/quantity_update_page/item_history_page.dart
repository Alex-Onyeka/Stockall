import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/products/quantity_update_page/platforms/item_history_desktop.dart';
import 'package:stockall/pages/products/quantity_update_page/platforms/item_history_mobile.dart';

class ItemHistoryPage extends StatefulWidget {
  final String? productUuid;
  const ItemHistoryPage({super.key, this.productUuid});

  @override
  State<ItemHistoryPage> createState() =>
      _ItemHistoryPageState();
}

class _ItemHistoryPageState extends State<ItemHistoryPage> {
  @override
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < tabletScreenSmall) {
          return ItemHistoryMobile(
            productUuid: widget.productUuid,
          );
        } else {
          return ItemHistoryDesktop(
            productUuid: widget.productUuid,
          );
        }
      },
    );
  }
}
