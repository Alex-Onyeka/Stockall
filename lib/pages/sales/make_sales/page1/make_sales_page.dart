import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_cart/temp_cart.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/sales/make_sales/page1/platforms/make_sales_desktop.dart';
import 'package:stockall/pages/sales/make_sales/page1/platforms/make_sales_mobile.dart';

class MakeSalesPage extends StatefulWidget {
  final bool? isMain;
  final int? cartItemTypeIndex;
  const MakeSalesPage({
    super.key,
    this.isMain,
    this.cartItemTypeIndex,
  });

  @override
  State<MakeSalesPage> createState() =>
      _MakeSalesPageState();
}

class _MakeSalesPageState extends State<MakeSalesPage> {
  TextEditingController searchController =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await returnMultiDisplayProvider().getAllSubWindows();
      await returnSalesProvider().fetchMainCart();
      if (widget.cartItemTypeIndex == 2) {
        if (returnSalesProvider()
            .currentCart()
            .cartItems
            .isNotEmpty) {
          returnSalesProvider().addNewCart(
            context,
            TempCart(
              comment: null,
              timeOfDay: null,
              // createdDate: DateTime.now(),
              hasPrintedDocket: false,
              subStaffName: null,
              customDate: null,
              departmentName: null,
              departmentUuid: null,
              staffId: currentUser().userId,
              staffName:
                  "${currentUser().name} ${currentUser().lastName}",
              cartItems: [],
              id: uuidGen(),
              cartItemTypeIndex:
                  widget.cartItemTypeIndex ?? 1,
              orderUuidEdit: null,
            ),
          );
        } else {
          returnSalesProvider().switchInvoiceSale(
            value: 2,
            context: context,
          );
        }
      }
      if (returnSalesProvider()
          .currentCart()
          .isReceiptEdit) {
        if (returnSalesProvider().currentCart().discount !=
            null) {
          returnSalesProvider().addPercentageDiscount(
            returnSalesProvider().currentCart().discount,
          );
        }
        if (returnSalesProvider()
                .currentCart()
                .fixedDiscount !=
            null) {
          returnSalesProvider().addFixedDiscount(
            returnSalesProvider()
                .currentCart()
                .fixedDiscount,
          );
        }
      }
      // await returnNavProvider(
      //   context,
      //   listen: false,
      // ).validate(context);

      setState(() {
        // stillLoading = false;
      });
    });
  }

  // final FocusNode barcodeNode = FocusNode();

  // @override
  // void dispose() {
  //   super.dispose();
  //   barcodeNode.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    if (returnSalesProvider().mainCartQueue.isEmpty) {
      return Scaffold(
        appBar: appBar(
          context: context,
          title: 'Cart Page',
          backAction: () {
            Navigator.of(context).pop();
          },
        ),
        body: Center(
          child: returnCompProvider(
            context,
          ).showLoader(message: 'Loading'),
        ),
      );
    } else {
      return LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < mobileScreen) {
            return MakeSalesMobile(
              isMain: widget.isMain,
              searchController: searchController,
            );
          } else {
            return MakeSalesDesktop(
              isMain: widget.isMain,
              searchController: searchController,
            );
          }
        },
      );
    }
  }
}
