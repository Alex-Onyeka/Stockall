import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_production_folder/temp_material_class/material_class.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/production/materials_page/add_material/platforms/add_material_desktop.dart';
import 'package:stockall/pages/production/materials_page/add_material/platforms/add_material_mobile.dart';

class AddMaterial extends StatefulWidget {
  final MaterialClass? material;
  const AddMaterial({super.key, this.material});

  @override
  State<AddMaterial> createState() => _AddMaterialState();
}

class _AddMaterialState extends State<AddMaterial> {
  TextEditingController nameController =
      TextEditingController();
  TextEditingController costController =
      TextEditingController();
  TextEditingController lowQttyController =
      TextEditingController(text: '10');
  TextEditingController qttyPerGroupController =
      TextEditingController();

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    costController.dispose();
    lowQttyController.dispose();
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
              return AddMaterialMobile(
                material: widget.material,
                lowQttyController: lowQttyController,
                costController: costController,
                nameController: nameController,
                qttyPerGroupController:
                    qttyPerGroupController,
              );
            } else {
              return AddMaterialDesktop(
                material: widget.material,
                lowQttyController: lowQttyController,
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
