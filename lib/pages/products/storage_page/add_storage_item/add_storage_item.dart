import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_storage_product/temp_storage_products.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/products/storage_page/add_storage_item/platforms/add_storage_item_desktop.dart';
import 'package:stockall/pages/products/storage_page/add_storage_item/platforms/add_storage_item_mobile.dart';

class AddStorageItem extends StatefulWidget {
  final TempStorageProducts? productStorage;
  const AddStorageItem({super.key, this.productStorage});

  @override
  State<AddStorageItem> createState() =>
      _AddStorageItemState();
}

class _AddStorageItemState extends State<AddStorageItem> {
  TextEditingController nameController =
      TextEditingController();
  TextEditingController quantityController =
      TextEditingController();
  TextEditingController qttyPerGroupController =
      TextEditingController();

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    quantityController.dispose();
    qttyPerGroupController.dispose();
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
                quantityController.text.isNotEmpty ||
                nameController.text.isNotEmpty,
            didPop: didPop,
          );
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < mobileScreen) {
              return AddStorageItemMobile(
                quantityController: quantityController,
                nameController: nameController,
                qttyPerGroupController:
                    qttyPerGroupController,
                storageProduct: widget.productStorage,
              );
            } else {
              return AddStorageItemDesktop(
                quantityController: quantityController,
                nameController: nameController,
                qttyPerGroupController:
                    qttyPerGroupController,
                storageProduct: widget.productStorage,
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
