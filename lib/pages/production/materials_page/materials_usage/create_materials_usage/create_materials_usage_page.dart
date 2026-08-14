import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/production/materials_page/materials_usage/create_materials_usage/platforms/create_materials_usage_desktop.dart';
import 'package:stockall/pages/production/materials_page/materials_usage/create_materials_usage/platforms/create_materials_usage_mobile.dart';

class CreateMaterialsUsagePage extends StatefulWidget {
  const CreateMaterialsUsagePage({super.key});

  @override
  State<CreateMaterialsUsagePage> createState() =>
      _CreateProductionState();
}

class _CreateProductionState
    extends State<CreateMaterialsUsagePage> {
  @override
  // void initState() {
  //   super.initState();
  //   if (returnProductionsActionProvider()
  //           .getProductionsCart()
  //           ?.isEdit !=
  //       true) {
  //     WidgetsBinding.instance.addPostFrameCallback((_) {
  //       returnProductionsActionProvider()
  //           .initProductionsCart();
  //     });
  //   }
  // }
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= mobileScreen) {
          return CreateMaterialsUsageMobile();
        } else {
          return CreateMaterialsUsageDesktop();
        }
      },
    );
  }
}
