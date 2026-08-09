import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/products/item_history_page/platforms/item_history_desktop.dart';
import 'package:stockall/pages/products/item_history_page/platforms/item_history_mobile.dart';

class ItemHistoryPage extends StatefulWidget {
  final String? productUuid;
  final bool fromItemDetails;
  const ItemHistoryPage({
    super.key,
    this.productUuid,
    required this.fromItemDetails,
  });

  @override
  State<ItemHistoryPage> createState() =>
      _ItemHistoryPageState();
}

class _ItemHistoryPageState extends State<ItemHistoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      returnItemHistoryProvider().getItemHistories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < tabletScreenSmall) {
          return ItemHistoryMobile(
            productUuid: widget.productUuid,
            fromItemDetails: widget.fromItemDetails,
          );
        } else {
          return ItemHistoryDesktop(
            productUuid: widget.productUuid,
            fromItemDetails: widget.fromItemDetails,
          );
        }
      },
    );
  }
}
