import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_orders/orders.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/orders/order_page/deliver_order_items/platforms/deliver_orders_mobile.dart';
import 'package:stockall/pages/orders/order_page/deliver_order_items/platforms/deliver_orders_desktop.dart';

class DeliverOrdersPage extends StatefulWidget {
  final Orders order;
  const DeliverOrdersPage({super.key, required this.order});

  @override
  State<DeliverOrdersPage> createState() =>
      _DeliverOrdersPageState();
}

class _DeliverOrdersPageState
    extends State<DeliverOrdersPage> {
  TextEditingController searchController =
      TextEditingController();
  TextEditingController priceController =
      TextEditingController();
  TextEditingController quantityController =
      TextEditingController();

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
    priceController.dispose();
    quantityController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          () =>
              FocusManager.instance.primaryFocus?.unfocus(),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          checkPop(
            context: context,
            conditionX:
                returnOrdersActionProvider()
                    .orderListItems
                    .isNotEmpty ||
                returnOrdersActionProvider().comment !=
                    null,
            didPop: didPop,
            action: () {
              returnOrdersActionProvider().clearAll();
            },
          );
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < mobileScreen) {
              return DeliverOrdersMobile(
                order: widget.order,
                searchController: searchController,
                priceController: priceController,
                quantityController: quantityController,
              );
            } else {
              return DeliverOrdersDesktop(
                order: widget.order,
                searchController: searchController,
                priceController: priceController,
                quantityController: quantityController,
              );
            }
          },
        ),
      ),
    );
  }
}

void checkPop({
  required BuildContext context,
  bool? conditionX,
  bool? didPop,
  Function()? action,
}) {
  if (didPop != null && didPop) {
    return;
  }
  if ((conditionX != null && conditionX == true) ||
      conditionX == null) {
    showDialog(
      context: context,
      builder: (confirmDialog) {
        return ConfirmationAlert(
          theme: returnTheme(context, listen: false),
          message:
              'Your changes might not be saved when you exit this page. Are you sure you want to exit?',
          title: 'Discard Changes',
          action: () {
            action != null ? action() : () {};
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
        );
      },
    );
  } else {
    Navigator.of(context).pop();
  }
}
