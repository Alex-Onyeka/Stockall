import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stockall/classes/temp_customers/temp_customers_class.dart';
import 'package:stockall/classes/temp_waybills/temp_way_bills.dart';
import 'package:stockall/classes/temp_waybills/waybill_items.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/theme_provider.dart';

class MainWaybillTile extends StatelessWidget {
  final TempWayBills waybill;
  final Function()? action;
  const MainWaybillTile({
    super.key,
    required this.waybill,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    if (screenWidth(context) < mobileScreen) {
      return MainWaybillTileMobile(
        waybill: waybill,
        action: action,
      );
    } else {
      return MainWaybillTileDesktop(
        waybill: waybill,
        action: action,
      );
    }
  }
}

class MainWaybillTileMobile extends StatefulWidget {
  final TempWayBills waybill;
  final Function()? action;
  const MainWaybillTileMobile({
    super.key,
    required this.waybill,
    required this.action,
  });

  @override
  State<MainWaybillTileMobile> createState() =>
      _MainWaybillTileMobileState();
}

class _MainWaybillTileMobileState
    extends State<MainWaybillTileMobile> {
  String cutLongText(String text) {
    if (text.length < 12) {
      return text;
    } else {
      return '${text.substring(0, 12)}...';
    }
  }

  String cutLongText2(String text) {
    if (text.length < 8) {
      return text;
    } else {
      return '${text.substring(0, 8)}...';
    }
  }

  List<WaybillItems> getWaybillItems() {
    return widget.waybill.items;
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    TempCustomersClass? customer;
    List<TempCustomersClass> customers =
        returnCustomers(context).customers
            .where(
              (customer) =>
                  customer.uuid != null &&
                  customer.uuid ==
                      widget.waybill.customerId,
            )
            .toList();
    if (customers.isNotEmpty) {
      customer = customers.first;
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Ink(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),

          borderRadius: BorderRadius.circular(5),
          color: Colors.white,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(5),
          onTap: widget.action,
          child: Container(
            padding: EdgeInsetsDirectional.all(15),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.start,
                      spacing: 5,
                      children: [
                        SvgPicture.asset(receiptIconSvg),
                        Text(
                          style: TextStyle(
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b2
                                    .fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                          formatDateWithDay(
                            widget.waybill.createdAt ??
                                DateTime.now(),
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      color: Colors.grey,
                      size: 20,
                      Icons.arrow_forward_ios_rounded,
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    // Text(
                    //   style: TextStyle(
                    //     fontSize:
                    //         theme.mobileTexts.b2.fontSize,
                    //     fontWeight: FontWeight.bold,
                    //     color:
                    //         theme
                    //             .lightModeColor
                    //             .secColor200,
                    //   ),
                    //   '${widget.waybill.paymentMethod} Payment',
                    // ),
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b2.fontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                      '${getWaybillItems().length} Item(s) Sold',
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: const Color.fromARGB(
                      162,
                      245,
                      245,
                      245,
                    ),
                    border: Border.all(
                      color: Colors.grey.shade200,
                    ),
                  ),
                  child: Row(
                    spacing: 5,
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        flex: 5,
                        child: Column(
                          spacing: 3,
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              style: TextStyle(
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .b3
                                        .fontSize,
                              ),
                              'Item Name',
                            ),
                            Text(
                              style: TextStyle(
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .b2
                                        .fontSize,
                                fontWeight: FontWeight.bold,
                              ),
                              cutLongText(
                                getWaybillItems().isNotEmpty
                                    ? getWaybillItems()
                                        .first
                                        .itemName
                                    : 'Not Set',
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Column(
                          spacing: 3,
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              style: TextStyle(
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .b3
                                        .fontSize,
                              ),
                              'Total',
                            ),
                            Text(
                              style: TextStyle(
                                fontSize:
                                    theme
                                        .mobileTexts
                                        .b2
                                        .fontSize,
                                fontWeight: FontWeight.bold,
                              ),
                              formatMoneyMid(
                                amount: returnWaybillProvider(
                                  context: context,
                                ).getTotalMainRevenueWaybill(
                                  widget.waybill,
                                ),
                                context: context,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b2.fontSize,
                        fontWeight: FontWeight.bold,
                        color:
                            theme
                                .lightModeColor
                                .secColor200,
                      ),

                      "Customer: ${cutLongText2(customer != null ? (customer.name) : 'Not Set')}",
                    ),
                    SizedBox(width: 10),
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b2.fontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                      'Staff: ${cutLongText2((widget.waybill.staffName == null || widget.waybill.staffName!.isEmpty) ? 'Not Set' : (widget.waybill.staffName ?? 'Not Set'))}',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MainWaybillTileDesktop extends StatefulWidget {
  final TempWayBills waybill;
  final Function()? action;
  const MainWaybillTileDesktop({
    super.key,
    required this.waybill,
    required this.action,
  });

  @override
  State<MainWaybillTileDesktop> createState() =>
      _MainWaybillTileDesktopState();
}

class _MainWaybillTileDesktopState
    extends State<MainWaybillTileDesktop> {
  String cutLongText(String text) {
    if (text.length < 12) {
      return text;
    } else {
      return '${text.substring(0, 12)}...';
    }
  }

  String cutLongText2(String text) {
    if (text.length < 8) {
      return text;
    } else {
      return '${text.substring(0, 8)}...';
    }
  }

  List<WaybillItems> getWaybillItems() {
    return widget.waybill.items;
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    TempCustomersClass? customer =
        returnCustomers(context).customers
                .where(
                  (customer) =>
                      customer.uuid ==
                      widget.waybill.customerId,
                )
                .isNotEmpty
            ? returnCustomers(context).customers
                .where(
                  (customer) =>
                      customer.uuid ==
                      widget.waybill.customerId,
                )
                .first
            : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Ink(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),

          borderRadius: BorderRadius.circular(5),
          color: Colors.white,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(5),
          onTap: widget.action,
          child: Container(
            padding: EdgeInsetsDirectional.all(10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.start,
                      spacing: 5,
                      children: [
                        SvgPicture.asset(
                          height: 18,
                          receiptIconSvg,
                        ),
                        Text(
                          style: TextStyle(
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b2
                                    .fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                          formatDateWithDay(
                            widget.waybill.createdAt ??
                                DateTime.now(),
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      color: Colors.grey,
                      size: 15,
                      Icons.arrow_forward_ios_rounded,
                    ),
                  ],
                ),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: const Color.fromARGB(
                      162,
                      245,
                      245,
                      245,
                    ),
                    border: Border.all(
                      color: Colors.grey.shade200,
                    ),
                  ),
                  child: Row(
                    spacing: 5,
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      ReceicptTileSectionDesktop(
                        flex: 5,
                        subTitle: 'First Item Name',
                        title: cutLongText(
                          getWaybillItems().isNotEmpty
                              ? getWaybillItems()
                                  .first
                                  .itemName
                              : '',
                        ),
                        theme: theme,
                      ),
                      ReceicptTileSectionDesktop(
                        flex: 4,
                        subTitle: 'Total',
                        title: formatMoneyMid(
                          amount: returnWaybillProvider(
                            context: context,
                          ).getTotalMainRevenueWaybill(
                            widget.waybill,
                          ),
                          context: context,
                        ),
                        theme: theme,
                      ),
                      ReceicptTileSectionDesktop(
                        flex: 3,
                        subTitle: 'Quantity',
                        title:
                            '${getWaybillItems().length} Item(s)',
                        theme: theme,
                      ),
                      // ReceicptTileSectionDesktop(
                      //   flex: 3,
                      //   subTitle: 'Payment Type',
                      //   title:
                      //       widget.waybill.paymentMethod,
                      //   theme: theme,
                      // ),
                      ReceicptTileSectionDesktop(
                        flex: 3,
                        subTitle: 'Customer',
                        title: cutLongText(
                          customer?.name ?? 'Not Set',
                        ),
                        theme: theme,
                      ),

                      ReceicptTileSectionDesktop(
                        flex: 3,
                        subTitle: 'Staff',
                        title:
                            'Staff: ${cutLongText2((widget.waybill.staffName == null || widget.waybill.staffName!.isEmpty) ? 'Not Set' : (widget.waybill.staffName ?? 'Not Set'))}',
                        theme: theme,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ReceicptTileSectionDesktop extends StatelessWidget {
  final String title;
  final String subTitle;
  final int flex;
  const ReceicptTileSectionDesktop({
    super.key,
    required this.theme,
    required this.title,
    required this.subTitle,
    required this.flex,
  });

  final ThemeProvider theme;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Column(
        spacing: 3,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            style: TextStyle(
              fontSize: theme.mobileTexts.b4.fontSize,
            ),
            subTitle,
          ),
          Text(
            style: TextStyle(
              fontSize: theme.mobileTexts.b3.fontSize,
              fontWeight: FontWeight.bold,
            ),
            title,
          ),
        ],
      ),
    );
  }
}
