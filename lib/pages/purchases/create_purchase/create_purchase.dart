import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_purchase/temp_purchase.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/purchases/create_purchase/platforms/create_purchase_desktop.dart';
import 'package:stockall/pages/purchases/create_purchase/platforms/create_purchase_mobile.dart';

class CreatePurchase extends StatefulWidget {
  final TempPurchase? purchase;
  const CreatePurchase({super.key, this.purchase});

  @override
  State<CreatePurchase> createState() =>
      _CreatePurchaseState();
}

class _CreatePurchaseState extends State<CreatePurchase> {
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
            conditionX: widget.purchase != null,
            didPop: didPop,
            action: () {
              returnPurchaseActionProvider().clearAll();
            },
          );
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < mobileScreen) {
              return CreatePurchaseMobile(
                purchase: widget.purchase,
                searchController: searchController,
                priceController: priceController,
                quantityController: quantityController,
              );
            } else {
              return CreatePurchaseDesktop(
                purchase: widget.purchase,
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
