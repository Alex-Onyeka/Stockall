import 'package:flutter/material.dart';
import 'package:stockall/classes/checkout_response.dart';
import 'package:stockall/classes/temp_orders/orders.dart';
import 'package:stockall/components/list_tiles/main_order_tile.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/components/text_fields/text_field_barcode.dart';
import 'package:stockall/constants/app_bar.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/constants/scan_barcode.dart';
import 'package:stockall/constants/subscription/items_auth.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/sales/make_sales/receipt_page/receipt_page.dart';

class SearchOrderMobile extends StatefulWidget {
  final TextEditingController searchController;
  const SearchOrderMobile({
    super.key,
    required this.searchController,
  });

  @override
  State<SearchOrderMobile> createState() =>
      _SearchOrderMobileState();
}

class _SearchOrderMobileState
    extends State<SearchOrderMobile> {
  Future<void> getMainOrders() async {
    await returnOrdersProvider().loadOrders(shopId());
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      clearDate();
    });
  }

  void clearDate() {
    returnOrdersProvider().clearDate();
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    List<Orders> orders =
        widget.searchController.text.isNotEmpty
            ? returnOrdersProvider(context: context)
                .departmentOrders()
                .where(
                  (order) =>
                      order.customerName
                              ?.toLowerCase()
                              .contains(
                                widget.searchController.text
                                    .toLowerCase(),
                              ) ==
                          true ||
                      order.staffName
                              ?.toLowerCase()
                              .contains(
                                widget.searchController.text
                                    .toLowerCase(),
                              ) ==
                          true ||
                      order.barcode?.contains(
                            widget.searchController.text,
                          ) ==
                          true,
                )
                .toList()
            : returnOrdersProvider(
              context: context,
            ).returnOrdersByDayOrWeekAll().toList();
    double totalRevenue() {
      return orders
          .map((rec) => (rec.total ?? 0))
          .toList()
          .fold(0, (first, second) => first + second);
    }

    return GestureDetector(
      onTap:
          () =>
              FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: appBar(
          context: context,
          title: 'Search For An Order',
        ),
        body: Builder(
          builder: (context) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
              ),
              child: Column(
                children: [
                  Material(
                    color: Colors.white,
                    child: Column(
                      children: [
                        Row(
                          spacing: 10,
                          children: [
                            ValueSummaryTabSmall(
                              color: Colors.amber,
                              isMoney: true,
                              title: 'Unpaid Balance',
                              value: totalRevenue(),
                            ),
                            ValueSummaryTabSmall(
                              value:
                                  orders.length.toDouble(),
                              title: 'Order Number',
                              color: Colors.green,
                              isMoney: false,
                            ),
                          ],
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(
                                vertical: 10.0,
                              ),
                          child: SizedBox(
                            width: double.infinity,
                            height: 35,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(
                                    right: 10.0,
                                  ),
                              child: TextFieldBarcode(
                                searchController:
                                    widget.searchController,
                                onChanged: (value) {
                                  setState(() {});
                                },
                                onPressedScan: () {
                                  ItemsAuthAction().useOfBArcodeAction(
                                    context: context,
                                    action: () async {
                                      String? result =
                                          await scanCode(
                                            context,
                                            'Scan Failed',
                                          );
                                      setState(() {
                                        if (result !=
                                            null) {
                                          widget
                                              .searchController
                                              .text = result;
                                        } else {
                                          return;
                                        }
                                      });
                                      if (!context
                                          .mounted) {
                                        return;
                                      }
                                      setState(() {});
                                    },
                                  );
                                },
                                clearTextField: () {
                                  setState(() {});
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 5),
                  Expanded(
                    child: Builder(
                      builder: (context) {
                        if (orders.isEmpty) {
                          return EmptyWidgetDisplayOnly(
                            title: 'Empty List',
                            subText:
                                'You don\'t have any Sales under this category',
                            icon: Icons.clear,
                            theme: theme,
                            height: 35,
                            altAction: () {
                              getMainOrders();
                            },
                            altActionText: 'Refresh List',
                          );
                        } else {
                          return RefreshIndicator(
                            onRefresh: getMainOrders,
                            backgroundColor: Colors.white,
                            color:
                                theme
                                    .lightModeColor
                                    .prColor300,
                            displacement: 10,
                            child: ListView.builder(
                              itemCount: orders.length,
                              itemBuilder: (
                                context,
                                index,
                              ) {
                                var order = orders[index];
                                return MainOrderTile(
                                  action: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return ReceiptPage(
                                            response:
                                                CheckoutResponse(
                                                  order:
                                                      order,
                                                ),
                                            isMain: false,
                                          );
                                        },
                                      ),
                                    ).then((_) {
                                      // orderFuture =
                                      //     getMainOrders();
                                    });
                                  },
                                  key: ValueKey(order.uuid),
                                  order: order,
                                );
                              },
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class ValueSummaryTabSmall extends StatelessWidget {
  final double value;
  final String title;
  final Color color;
  final bool isMoney;

  const ValueSummaryTabSmall({
    super.key,
    required this.value,
    required this.title,
    required this.color,
    required this.isMoney,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: Colors.grey.shade300),
          color: Colors.grey.shade200,
        ),
        child: Row(
          spacing: 10,
          children: [
            Container(
              height: 10,
              width: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
              ),
            ),
            Column(
              spacing: 0,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                  title,
                ),
                Row(
                  children: [
                    Visibility(
                      visible: false,
                      child: Text(
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                        "N",
                      ),
                    ),
                    SizedBox(width: 2),
                    Text(
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Colors.grey.shade700,
                      ),
                      isMoney
                          ? formatMoneyMid(
                            amount: value,
                            context: context,
                          )
                          : formatLargeNumberDoubleWidgetDecimal(
                            value,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
