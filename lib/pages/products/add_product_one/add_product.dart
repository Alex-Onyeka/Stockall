import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_product_class/temp_product_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/products/add_product_one/platforms/add_product_desktop.dart';
import 'package:stockall/pages/products/add_product_one/platforms/add_product_mobile.dart';

class AddProduct extends StatefulWidget {
  final TempProductClass? product;
  const AddProduct({super.key, this.product});

  @override
  State<AddProduct> createState() => _AddProductState();
}

class _AddProductState extends State<AddProduct> {
  TextEditingController nameController =
      TextEditingController();

  TextEditingController costController =
      TextEditingController();
  TextEditingController sellingController =
      TextEditingController();
  TextEditingController lowQttyController =
      TextEditingController(text: '10');
  TextEditingController quantityController =
      TextEditingController();
  TextEditingController discountController =
      TextEditingController();
  TextEditingController storageQuantityController =
      TextEditingController();

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    costController.dispose();
    sellingController.dispose();
    discountController.dispose();
    quantityController.dispose();
    lowQttyController.dispose();
    storageQuantityController.dispose();
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
                costController.text.isNotEmpty ||
                quantityController.text.isNotEmpty ||
                nameController.text.isNotEmpty ||
                sellingController.text.isNotEmpty,
            didPop: didPop,
          );
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < mobileScreen) {
              return AddProductMobile(
                product: widget.product,
                discountController: discountController,
                lowQttyController: lowQttyController,
                quantityController: quantityController,
                costController: costController,
                sellingController: sellingController,
                nameController: nameController,
              );
            } else {
              return AddProductDesktop(
                storageQuantityController:
                    storageQuantityController,
                product: widget.product,
                discountController: discountController,
                lowQttyController: lowQttyController,
                quantityController: quantityController,
                costController: costController,
                sellingController: sellingController,
                nameController: nameController,
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
