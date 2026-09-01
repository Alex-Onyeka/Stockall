import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/orders/invoice_list/platforms/order_list_desktop.dart';
import 'package:stockall/pages/orders/invoice_list/platforms/order_list_mobile.dart';

class OrderListPage extends StatefulWidget {
  final String? agentUuid;
  final String? customerUuid;
  const OrderListPage({
    super.key,
    this.agentUuid,
    this.customerUuid,
  });

  @override
  State<OrderListPage> createState() =>
      _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // returnNavProvider(context, listen: false).navigate(7);
      returnOrdersProvider().loadOrders(shopId());
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      returnOrdersProvider().clearDate();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < mobileScreen) {
          return OrderListMobile(
            agentUuid: widget.agentUuid,
            customerUuid: widget.customerUuid,
          );
        } else {
          return OrderListDesktop(
            customerUuid: widget.customerUuid,
            agentUuid: widget.agentUuid,
          );
        }
      },
    );
  }
}
