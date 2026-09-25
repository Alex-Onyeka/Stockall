import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/products/storage_page/storage_item_history_page/platforms/storage_item_history_mobile.dart';
import 'package:stockall/pages/products/storage_page/storage_item_history_page/platforms/storage_item_history_desktop.dart';

class StorageItemHistoryPage extends StatefulWidget {
  final String? productUuid;
  final bool fromItemDetails;
  const StorageItemHistoryPage({
    super.key,
    this.productUuid,
    required this.fromItemDetails,
  });

  @override
  State<StorageItemHistoryPage> createState() =>
      _StorageItemHistoryPageState();
}

class _StorageItemHistoryPageState
    extends State<StorageItemHistoryPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      returnStorageItemHistoryProvider().getItemHistories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < tabletScreenSmall) {
          return StorageItemHistoryMobile(
            productUuid: widget.productUuid,
            fromItemDetails: widget.fromItemDetails,
          );
        } else {
          return StorageItemHistoryDesktop(
            productUuid: widget.productUuid,
            fromItemDetails: widget.fromItemDetails,
          );
        }
      },
    );
  }
}
