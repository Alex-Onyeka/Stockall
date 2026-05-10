import 'package:flutter/material.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/waybills/waybill_list/platforms/waybill_list_desktop.dart';
import 'package:stockall/pages/waybills/waybill_list/platforms/waybill_list_mobile.dart';

class WaybillList extends StatefulWidget {
  final String? id;
  final String? customerUuid;
  const WaybillList({
    super.key,
    this.id,
    this.customerUuid,
  });

  @override
  State<WaybillList> createState() => _WaybillListState();
}

class _WaybillListState extends State<WaybillList> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      returnNavProvider(context, listen: false).navigate(5);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < mobileScreen) {
          return WaybillListMobile(
            id: widget.id,
            customerId: widget.customerUuid,
          );
        } else {
          return WaybillListDesktop(
            customerUuid: widget.customerUuid,
            id: widget.id,
          );
        }
      },
    );
  }
}
