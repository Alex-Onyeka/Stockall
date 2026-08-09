import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_production_folder/temp_production_items/production_item.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/production/production_items/add_production_item/platforms/add_production_item_mobile.dart';
import 'package:stockall/pages/production/production_items/add_production_item/platforms/add_production_item_desktop.dart';

class AddProductionItem extends StatefulWidget {
  final ProductionItem? productionItem;
  const AddProductionItem({super.key, this.productionItem});

  @override
  State<AddProductionItem> createState() =>
      _AddProductionItemState();
}

class _AddProductionItemState
    extends State<AddProductionItem> {
  TextEditingController nameController =
      TextEditingController();
  TextEditingController costController =
      TextEditingController();
  TextEditingController qttyPerGroupController =
      TextEditingController();

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    costController.dispose();
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
                costController.text.isNotEmpty ||
                nameController.text.isNotEmpty,
            didPop: didPop,
          );
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < mobileScreen) {
              return AddProductionItemMobile(
                productionItem: widget.productionItem,
                costController: costController,
                nameController: nameController,
                qttyPerGroupController:
                    qttyPerGroupController,
              );
            } else {
              return AddProductionItemDesktop(
                productionItem: widget.productionItem,
                costController: costController,
                nameController: nameController,
                qttyPerGroupController:
                    qttyPerGroupController,
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
