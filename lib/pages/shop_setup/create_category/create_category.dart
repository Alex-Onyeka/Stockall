import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/shop_setup/create_category/platforms/create_category_desktop.dart';
import 'package:stockall/pages/shop_setup/create_category/platforms/create_category_mobile.dart';

class CreateCategory extends StatelessWidget {
  const CreateCategory({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth <= mobileScreen) {
          return CreateCategoryMobile();
        } else {
          return CreateCategoryDesktop();
        }
      },
    );
  }
}
