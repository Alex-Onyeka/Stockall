import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/products/storage_page/platforms/storage_page_desktop.dart';
import 'package:stockall/pages/products/storage_page/platforms/storage_page_mobile.dart';

class StoragePage extends StatefulWidget {
  final String? itemName;
  final bool isMainTab;
  const StoragePage({
    super.key,
    this.itemName,
    this.isMainTab = false,
  });

  @override
  State<StoragePage> createState() => _StoragePageState();
}

class _StoragePageState extends State<StoragePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && widget.isMainTab) {
        returnNavProvider(context, listen: false).navigate(11);
      }
      returnStorageItemHistoryProvider().clearDate();
      returnStorageProductProvider().getStorageProducts(shopId());
    });
  }

  @override
  Widget build(BuildContext context) {
    final content = LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < tabletScreenSmall) {
          return StoragePageMobile(
            itemName: widget.itemName,
            isMainTab: widget.isMainTab,
          );
        } else {
          return StoragePageDesktop(
            itemName: widget.itemName,
            isMainTab: widget.isMainTab,
          );
        }
      },
    );

    if (!widget.isMainTab) {
      return content;
    }

    return SafeArea(
      child: GestureDetector(
        onTap:
            () => FocusManager.instance.primaryFocus?.unfocus(),
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            returnNavProvider(
              context,
              listen: false,
            ).navigate(0);
          },
          child: content,
        ),
      ),
    );
  }
}
