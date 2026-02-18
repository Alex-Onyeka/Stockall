import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/products/store_page/platforms/store_page_desktop.dart';
import 'package:stockall/pages/products/store_page/platforms/store_page_mobile.dart';

class StorePage extends StatelessWidget {
  const StorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < mobileScreen) {
          return StorePageMobile();
        } else {
          return StorePageDesktop();
        }
      },
    );
  }
}
