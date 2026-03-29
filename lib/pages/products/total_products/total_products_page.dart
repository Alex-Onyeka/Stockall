import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/products/total_products/platforms/total_products_desktop.dart';
import 'package:stockall/pages/products/total_products/platforms/total_products_mobile.dart';
import 'package:stockall/providers/theme_provider.dart';

class TotalProductsPage extends StatelessWidget {
  final ThemeProvider theme;
  final String? categoryUuid;
  const TotalProductsPage({
    super.key,
    required this.theme,
    this.categoryUuid,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          () =>
              FocusManager.instance.primaryFocus?.unfocus(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < mobileScreen) {
            return TotalProductsMobile(
              theme: theme,
              categoryUuid: categoryUuid,
            );
          } else {
            return TotalProductsDesktop(
              theme: theme,
              categoryUuid: categoryUuid,
            );
          }
        },
      ),
    );
  }
}
