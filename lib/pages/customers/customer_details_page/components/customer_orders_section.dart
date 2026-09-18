import 'package:flutter/material.dart';
import 'package:stockall/classes/checkout_response.dart';
import 'package:stockall/classes/temp_customers/temp_customers_class.dart';
import 'package:stockall/classes/temp_orders/orders.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/orders/order_list/order_list_page.dart';
import 'package:stockall/pages/sales/make_sales/receipt_page/receipt_page.dart';
import 'package:stockall/providers/theme_provider.dart';

class CustomerOrdersSection extends StatelessWidget {
  final TempCustomersClass customer;
  const CustomerOrdersSection({
    super.key,
    required this.customer,
  });

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    List<Orders> orders =
        customer.getOrders().length > 5
            ? customer.getOrders().sublist(0, 4)
            : customer.getOrders();

    return Container(
      margin: EdgeInsets.only(top: 10),
      padding: EdgeInsets.symmetric(
        vertical: 25,
        horizontal: 10,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(26, 0, 0, 0),
            blurRadius: 10,
          ),
        ],
        color: Colors.white,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Row(
                spacing: 5,
                children: [
                  Container(
                    padding: EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade100,
                    ),
                    child: Icon(
                      size: 16,
                      Icons.receipt_outlined,
                    ),
                  ),
                  Text(
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b4.fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                    'All Orders'.toUpperCase(),
                  ),
                ],
              ),
              Material(
                type: MaterialType.transparency,
                child: InkWell(
                  mouseCursor: SystemMouseCursors.click,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return OrderListPage(
                            customerUuid: customer.uuid,
                          );
                        },
                      ),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsetsGeometry.symmetric(
                      vertical: 8,
                      horizontal: 10,
                    ),
                    child: Row(
                      spacing: 5,
                      children: [
                        Text(
                          style: TextStyle(
                            fontSize:
                                theme
                                    .mobileTexts
                                    .b4
                                    .fontSize,
                          ),
                          'View All',
                        ),
                        Icon(
                          size: 14,
                          Icons.arrow_forward_ios_rounded,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Divider(color: Colors.grey.shade300, height: 25),
          Builder(
            builder: (context) {
              if (orders.isEmpty) {
                return Center(
                  child: EmptyWidgetDisplayOnly(
                    title: 'Empty List',
                    subText: 'No dOrders Found for Today',
                    theme: theme,
                    height: 15,
                    icon: Icons.clear,
                  ),
                );
              } else {
                return Column(
                  spacing: 5,
                  children:
                      orders
                          .map(
                            (item) => CustomerdOrdersList(
                              order: item,
                              theme: theme,
                            ),
                          )
                          .toList(),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class CustomerdOrdersList extends StatelessWidget {
  final Orders order;
  const CustomerdOrdersList({
    super.key,
    required this.theme,
    required this.order,
  });

  final ThemeProvider theme;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        mouseCursor: SystemMouseCursors.click,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) {
                return ReceiptPage(
                  isMain: false,
                  response: CheckoutResponse(order: order),
                );
              },
            ),
          );
        },
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 5,
          ),
          decoration: BoxDecoration(),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              Row(
                spacing: 8,
                children: [
                  Container(
                    padding: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade400,
                    ),
                  ),
                  Text(
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b4.fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                    formatMoneyBig(
                      amount:
                          order.getTotalMainRevenueOrder(),
                      context: context,
                    ),
                  ),
                  OrdersPaymentStatusWidget(order: order),
                ],
              ),
              Row(
                spacing: 5,
                children: [
                  Text(
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b4.fontSize,
                      fontWeight: FontWeight.normal,
                    ),
                    "${formatDateTime(order.createdAt)} - ${formatTime(order.createdAt)}",
                  ),
                  Icon(
                    size: 12,
                    Icons.arrow_forward_ios_rounded,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OrdersPaymentStatusWidget extends StatefulWidget {
  final Orders order;
  const OrdersPaymentStatusWidget({
    super.key,
    required this.order,
  });

  @override
  State<OrdersPaymentStatusWidget> createState() =>
      _OrdersPaymentStatusWidgetState();
}

class _OrdersPaymentStatusWidgetState
    extends State<OrdersPaymentStatusWidget> {
  Color mainColor() {
    return widget.order.getOrderStatus() == 1
        ? Colors.amber
        : widget.order.getOrderStatus() == 2
        ? Colors.green
        : Colors.red;
  }

  String mainText() {
    return widget.order.getOrderStatus() == 1
        ? 'Partial'
        : widget.order.getOrderStatus() == 2
        ? 'Paid'
        : 'Unpaid';
  }

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 2,
        horizontal: 4,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: mainColor()),
      ),
      child: Text(
        style: TextStyle(
          color: mainColor(),
          fontSize: theme.mobileTexts.b5.fontSize,
        ),
        mainText(),
      ),
    );
  }
}
