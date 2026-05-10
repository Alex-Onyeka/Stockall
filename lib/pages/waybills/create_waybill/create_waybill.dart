import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_waybills/temp_way_bills.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/waybills/create_waybill/platforms/create_waybill_desktop.dart';
import 'package:stockall/pages/waybills/create_waybill/platforms/create_waybill_mobile.dart';

class CreateWaybill extends StatefulWidget {
  final TempWayBills? waybill;
  const CreateWaybill({super.key, this.waybill});

  @override
  State<CreateWaybill> createState() =>
      _CreateWaybillState();
}

class _CreateWaybillState extends State<CreateWaybill> {
  TextEditingController searchController =
      TextEditingController();
  TextEditingController priceController =
      TextEditingController();
  TextEditingController quantityController =
      TextEditingController();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.waybill != null) {
        returnWaybillProvider().initUpdateWaybill(
          waybill: widget.waybill!,
          context: context,
        );
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
    priceController.dispose();
    quantityController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          () =>
              FocusManager.instance.primaryFocus?.unfocus(),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          checkPop(
            context: context,
            conditionX: widget.waybill != null,
            didPop: didPop,
            action: () {
              returnWaybillProvider()
                  .clearAllAfterCreatingWaybill();
            },
          );
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < mobileScreen) {
              return CreateWaybillMobile(
                waybill: widget.waybill,
                searchController: searchController,
                priceController: priceController,
                quantityController: quantityController,
              );
            } else {
              return CreateWaybillDesktop(
                waybill: widget.waybill,
                searchController: searchController,
                priceController: priceController,
                quantityController: quantityController,
              );
            }
          },
        ),
      ),
    );
  }
}

void checkPop({
  required BuildContext context,
  bool? conditionX,
  bool? didPop,
  Function()? action,
}) {
  if (didPop != null && didPop) {
    return;
  }
  if ((conditionX != null && conditionX == true) ||
      conditionX == null) {
    showDialog(
      context: context,
      builder: (confirmDialog) {
        return ConfirmationAlert(
          theme: returnTheme(context, listen: false),
          message:
              'Your changes might not be saved when you exit this page. Are you sure you want to exit?',
          title: 'Discard Changes',
          action: () {
            action != null ? action() : () {};
            Navigator.of(context).pop();
            Navigator.of(context).pop();
          },
        );
      },
    );
  } else {
    Navigator.of(context).pop();
  }
}
