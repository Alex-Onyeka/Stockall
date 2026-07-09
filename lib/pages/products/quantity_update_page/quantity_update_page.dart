import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/pages/products/quantity_update_page/platforms/quantity_updates_desktop.dart';
import 'package:stockall/pages/products/quantity_update_page/platforms/quantity_updates_mobile.dart';

class QuantityUpdatesPage extends StatefulWidget {
  final String? productUuid;
  const QuantityUpdatesPage({super.key, this.productUuid});

  @override
  State<QuantityUpdatesPage> createState() =>
      _QuantityUpdatePageState();
}

class _QuantityUpdatePageState
    extends State<QuantityUpdatesPage> {
  @override
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < tabletScreenSmall) {
          return QuantityUpdatesMobile(
            productUuid: widget.productUuid,
          );
        } else {
          return QuantityUpdatesDesktop(
            productUuid: widget.productUuid,
          );
        }
      },
    );
  }
}
