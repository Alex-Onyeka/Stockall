import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/products/product_details/platforms/product_details_desktop.dart';
import 'package:stockall/pages/products/product_details/platforms/product_details_mobile.dart';

class ProductDetailsPage extends StatefulWidget {
  final String productUuid;
  final String? notifId;
  const ProductDetailsPage({
    super.key,
    required this.productUuid,
    this.notifId,
  });

  @override
  State<ProductDetailsPage> createState() =>
      _ProductDetailsPageState();
}

class _ProductDetailsPageState
    extends State<ProductDetailsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.notifId != null) {
        returnNotificationProvider(
          context,
          listen: false,
        ).updateNotification(widget.notifId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < mobileScreen) {
          return ProductDetailsMobile(
            theme: theme,
            productUuid: widget.productUuid,
          );
        } else {
          return ProductDetailsDesktop(
            theme: theme,
            productUuid: widget.productUuid,
          );
        }
      },
    );
  }
}
