import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/products/storage_page/storage_details/platforms/storage_details_desktop.dart';
import 'package:stockall/pages/products/storage_page/storage_details/platforms/storage_details_mobile.dart';

class StorageDetailsPage extends StatefulWidget {
  final String productUuid;
  const StorageDetailsPage({
    super.key,
    required this.productUuid,
  });

  @override
  State<StorageDetailsPage> createState() =>
      _StorageDetailsPageState();
}

class _StorageDetailsPageState
    extends State<StorageDetailsPage> {
  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < mobileScreen) {
          return StorageDetailsMobile(
            theme: theme,
            productUuid: widget.productUuid,
          );
        } else {
          return StorageDetailsDesktop(
            theme: theme,
            productUuid: widget.productUuid,
          );
        }
      },
    );
  }
}
