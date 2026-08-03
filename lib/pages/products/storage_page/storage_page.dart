import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/products/storage_page/platforms/storage_page_desktop.dart';
import 'package:stockall/pages/products/storage_page/platforms/storage_page_mobile.dart';

class StoragePage extends StatefulWidget {
  final String? itemName;
  const StoragePage({super.key, this.itemName});

  @override
  State<StoragePage> createState() => _StoragePageState();
}

class _StoragePageState extends State<StoragePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      returnInventoryUpdatesProvider().clearDate();
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < tabletScreenSmall) {
          return StoragePageMobile(
            itemName: widget.itemName,
          );
        } else {
          return StoragePageDesktop(
            itemName: widget.itemName,
          );
        }
      },
    );
  }
}
