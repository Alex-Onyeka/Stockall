import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/production/materials_page/platforms/materials_page_desktop.dart';
import 'package:stockall/pages/production/materials_page/platforms/materials_page_mobile.dart';

class MaterialsPage extends StatelessWidget {
  const MaterialsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          () =>
              FocusManager.instance.primaryFocus?.unfocus(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < mobileScreen) {
            return MaterialsPageMobile();
          } else {
            return MaterialsPageDesktop();
          }
        },
      ),
    );
  }
}
