import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/production/platforms/production_page_desktop.dart';
import 'package:stockall/pages/production/platforms/production_page_mobile.dart';

class ProductionPage extends StatelessWidget {
  const ProductionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= mobileScreen) {
          return ProductionPageMobile();
        } else {
          return ProductionPageDesktop();
        }
      },
    );
  }
}
