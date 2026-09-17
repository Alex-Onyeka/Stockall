import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_orders/order_items.dart';
import 'package:stockall/classes/temp_orders/orders.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/constants/calculations.dart';
import 'package:stockall/main.dart';
import 'package:stockall/providers/theme_provider.dart';

class OrderItemDeliveryTile extends StatelessWidget {
  const OrderItemDeliveryTile({
    super.key,
    required this.theme,
    required this.item,
    required this.order,
    required this.priceController,
    required this.quantityController,
  });

  final ThemeProvider theme;
  final OrderItems item;
  final Orders order;
  final TextEditingController priceController;
  final TextEditingController quantityController;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 3),
      color: Colors.grey.shade100,
      padding: EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 20,
      ),
      child: Row(
        spacing: 5,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 5,
            children: [
              Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                spacing: 5,
                children: [
                  Text(
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b2.fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                    item.productName,
                  ),
                ],
              ),
              Row(
                spacing: 10,
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b4.fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                    '${formatLargeNumberDouble(item.quantity)} ${returnOrdersActionProvider().itemUnit(orderItem: item)}',
                  ),
                  Text(
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b3.fontSize,
                      color: Colors.grey,
                    ),
                    '|',
                  ),
                  Text(
                    style: TextStyle(
                      fontSize:
                          theme.mobileTexts.b4.fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                    formatMoneyBig(
                      amount: item.getTotalRevenue(),
                      context: context,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            spacing: 5,
            children: [
              // Material(
              //   color: Colors.transparent,
              //   child: InkWell(
              //     mouseCursor: SystemMouseCursors.click,
              //     onTap: () {
              //       selectOrderItemsBottomSheet(
              //         priceController: priceController,
              //         quantityController:
              //             quantityController,
              //         context: context,
              //         orderItem: item,
              //         order: order,
              //       );
              //     },
              //     borderRadius: BorderRadius.circular(20),
              //     child: Padding(
              //       padding: const EdgeInsets.all(8.0),
              //       child: Icon(
              //         size: 20,
              //         color: Colors.grey.shade700,
              //         Icons.mode_edit_outlined,
              //       ),
              //     ),
              //   ),
              // ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  mouseCursor: SystemMouseCursors.click,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (confirmContext) {
                        return ConfirmationAlert(
                          theme: theme,
                          message:
                              'You are about to remove this item from order list. Are you sure you want to proceed?',
                          title: 'Remove From List',
                          action: () {
                            returnOrdersActionProvider()
                                .removeItemFromList(
                                  item: item,
                                );
                            Navigator.of(context).pop();
                          },
                        );
                      },
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(size: 20, Icons.clear),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
