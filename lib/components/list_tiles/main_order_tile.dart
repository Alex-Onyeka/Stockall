import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:stockall/classes/temp_customers/temp_customers_class.dart';
import 'package:stockall/classes/temp_orders/order_items.dart';
import 'package:stockall/classes/temp_orders/orders.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/constants_main.dart';
import 'package:stockall/constants/functions.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/theme_provider.dart';

class MainOrderTile extends StatelessWidget {
  final Orders order;
  final Function()? action;
  const MainOrderTile({
    super.key,
    required this.order,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    if (screenWidth(context) < mobileScreen) {
      return MainOrderTileMobile(
        order: order,
        action: action,
      );
    } else {
      return MainOrderTileDesktop(
        order: order,
        action: action,
      );
    }
  }
}

class MainOrderTileMobile extends StatefulWidget {
  final Orders order;
  final Function()? action;
  const MainOrderTileMobile({
    super.key,
    required this.order,
    required this.action,
  });

  @override
  State<MainOrderTileMobile> createState() =>
      _MainOrderTileMobileState();
}

class _MainOrderTileMobileState
    extends State<MainOrderTileMobile> {
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getCustomer();
    });
  }

  TempCustomersClass? customer;
  void getCustomer() {
    List<TempCustomersClass> customers =
        returnCustomers(context, listen: false).customers
            .where(
              (customer) =>
                  customer.uuid != null &&
                  customer.uuid == widget.order.customerId,
            )
            .toList();
    if (customers.isNotEmpty) {
      setState(() {
        customer = customers.first;
      });
    }
  }

  List<OrderItems> getProductRecord() {
    return widget.order.orderItems.toList();
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 15.0),
      child: Ink(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),

          borderRadius: BorderRadius.circular(5),
          color: Colors.white,
        ),
        child: InkWell(
          mouseCursor: SystemMouseCursors.click,
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
                                    .b3
                                    .fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                          formatDateWithDay(
                            widget.order.createdAt,
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
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b3.fontSize,
                        fontWeight: FontWeight.bold,
                        color:
                            theme
                                .lightModeColor
                                .secColor200,
                      ),
                      'Payment',
                    ),
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b3.fontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                      '${getProductRecord().length} Item(s) Sold',
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
                                        .b3
                                        .fontSize,
                                fontWeight: FontWeight.bold,
                              ),
                              cutLongText(
                                getProductRecord()
                                        .isNotEmpty
                                    ? getProductRecord()
                                        .first
                                        .productName
                                    : '',
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
                                        .b3
                                        .fontSize,
                                fontWeight: FontWeight.bold,
                              ),
                              formatMoneyMid(
                                amount: returnOrdersProvider(
                                  context: context,
                                ).getTotalMainRevenueOrder(
                                  order: widget.order,
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
                            theme.mobileTexts.b4.fontSize,
                        fontWeight: FontWeight.bold,
                        color:
                            theme
                                .lightModeColor
                                .secColor200,
                      ),

                      "Customer: ${cutLongText2(customer != null ? customer!.name : 'Not Set')}",
                    ),
                    SizedBox(width: 10),
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b4.fontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                      ),
                      'Cashier: ${cutLongText2((widget.order.staffName?.isNotEmpty == true) ? widget.order.staffName ?? 'Not Set' : 'Not Set')}.',
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

class MainOrderTileDesktop extends StatefulWidget {
  final Orders order;
  final Function()? action;
  const MainOrderTileDesktop({
    super.key,
    required this.order,
    required this.action,
  });

  @override
  State<MainOrderTileDesktop> createState() =>
      _MainOrderTileDesktopState();
}

class _MainOrderTileDesktopState
    extends State<MainOrderTileDesktop> {
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getCustomer();
    });
  }

  TempCustomersClass? customer;
  void getCustomer() {
    List<TempCustomersClass> customers =
        returnCustomers(context, listen: false).customers
            .where(
              (customer) =>
                  customer.uuid != null &&
                  customer.uuid == widget.order.customerId,
            )
            .toList();
    if (customers.isNotEmpty) {
      setState(() {
        customer = customers.first;
      });
    }
  }

  List<OrderItems> getProductRecord() {
    return widget.order.orderItems.toList();
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Ink(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),

          borderRadius: BorderRadius.circular(5),
          color: Colors.white,
        ),
        child: InkWell(
          mouseCursor: SystemMouseCursors.click,
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
                                    .b3
                                    .fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                          formatDateWithDay(
                            widget.order.createdAt,
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
                          getProductRecord().isNotEmpty
                              ? getProductRecord()
                                  .first
                                  .productName
                              : '',
                        ),
                        theme: theme,
                      ),
                      ReceicptTileSectionDesktop(
                        flex: 4,
                        subTitle: 'Total',
                        title: formatMoneyMid(
                          amount: returnOrdersProvider(
                            context: context,
                          ).getTotalMainRevenueOrder(
                            order: widget.order,
                          ),
                          context: context,
                        ),
                        theme: theme,
                      ),
                      ReceicptTileSectionDesktop(
                        flex: 3,
                        subTitle: 'Quantity',
                        title:
                            '${getProductRecord().length} Item(s)',
                        theme: theme,
                      ),
                      ReceicptTileSectionDesktop(
                        flex: 3,
                        subTitle: 'Payment Type',
                        title: 'Cash',
                        theme: theme,
                      ),
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
                        subTitle: 'Cashier',
                        title:
                            '${cutLongText2((widget.order.staffName?.isNotEmpty == true) ? widget.order.staffName ?? 'Not Set' : 'Not Set')}.',
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
