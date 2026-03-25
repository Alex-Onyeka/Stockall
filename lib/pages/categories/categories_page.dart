import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/categories/platforms/categories_page_desktop.dart';
import 'package:stockall/pages/categories/platforms/categories_page_mobile.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= mobileScreen) {
          return CategoriesPageMobile();
        } else {
          return CategoriesPageDesktop();
        }
      },
    );
  }
}
