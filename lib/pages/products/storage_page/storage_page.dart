import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/products/storage_page/platforms/storage_page_desktop.dart';
import 'package:stockall/pages/products/storage_page/platforms/storage_page_mobile.dart';

class StoragePage extends StatelessWidget {
  const StoragePage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < tabletScreenSmall) {
          return StoragePageMobile();
        } else {
          return StoragePageDesktop();
        }
      },
    );
  }
}
