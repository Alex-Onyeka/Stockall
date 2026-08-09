import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/production/production_items/production_item_history_page/platforms/production_item_history_desktop.dart';
import 'package:stockall/pages/production/production_items/production_item_history_page/platforms/production_item_history_mobile.dart';

class ProductionItemHistoryPage extends StatefulWidget {
  final String? productionItemUuid;
  final bool fromProductionItemDetails;
  final bool? viewTransferedOut;
  const ProductionItemHistoryPage({
    super.key,
    this.productionItemUuid,
    required this.fromProductionItemDetails,
    this.viewTransferedOut,
  });

  @override
  State<ProductionItemHistoryPage> createState() =>
      _ProductionItemHistoryPageState();
}

class _ProductionItemHistoryPageState
    extends State<ProductionItemHistoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      returnProductionItemHistoryProvider()
          .getProductionItemHistories();
    });
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      returnProductionItemHistoryProvider().clearDate();
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < tabletScreenSmall) {
          return ProductionItemHistoryMobile(
            productionItemUuid: widget.productionItemUuid,
            fromProductionItemDetails:
                widget.fromProductionItemDetails,
            viewTransferedOut: widget.viewTransferedOut,
          );
        } else {
          return ProductionItemHistoryDesktop(
            productionItemUuid: widget.productionItemUuid,
            fromProductionItemDetails:
                widget.fromProductionItemDetails,
            viewTransferedOut: widget.viewTransferedOut,
          );
        }
      },
    );
  }
}
