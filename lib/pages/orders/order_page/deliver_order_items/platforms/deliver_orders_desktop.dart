import 'package:flutter/material.dart';
import 'package:stockall/classes/temp_orders/orders.dart';
import 'package:stockall/components/alert_dialogues/confirmation_alert.dart';
import 'package:stockall/components/alert_dialogues/info_alert.dart';
import 'package:stockall/components/buttons/main_button_p.dart';
import 'package:stockall/components/major/desktop_center_container.dart';
import 'package:stockall/components/major/empty_widget_display_only.dart';
import 'package:stockall/main.dart';
import 'package:stockall/pages/orders/order_page/components/select_order_items_bottom_sheet.dart';
import 'package:stockall/pages/orders/order_page/deliver_order_items/platforms/components/order_comment_widget.dart';
import 'package:stockall/pages/orders/order_page/deliver_order_items/platforms/components/order_item_delivery_tile.dart';
import 'package:stockall/pages/orders/order_page/deliver_order_items/platforms/components/total_row_orders_delivery.dart';

class DeliverOrdersDesktop extends StatefulWidget {
  final Orders order;
  final TextEditingController searchController;
  final TextEditingController priceController;
  final TextEditingController quantityController;
  final TextEditingController bankController;
  final TextEditingController cashController;

  const DeliverOrdersDesktop({
    super.key,
    required this.order,
    required this.searchController,
    required this.priceController,
    required this.quantityController,
    required this.bankController,
    required this.cashController,
  });

  @override
  State<DeliverOrdersDesktop> createState() =>
      _DeliverOrdersDesktopState();
}

class _DeliverOrdersDesktopState
    extends State<DeliverOrdersDesktop> {
  bool isLoading = false;
  bool showSuccess = false;

  @override
  Widget build(BuildContext context) {
    var theme = returnTheme(context);
    return Scaffold(
      body: Stack(
        children: [
          DesktopCenterContainer(
            width: 650,
            mainWidget: Scaffold(
              appBar: AppBar(
                scrolledUnderElevation: 0,
                centerTitle: true,
                title: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.h4.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                      'Order Delivery',
                    ),
                    SizedBox(height: 5),
                    Text(
                      style: TextStyle(
                        fontSize:
                            theme.mobileTexts.b2.fontSize,
                      ),
                      'Select Items To be Delivered',
                    ),
                  ],
                ),
                actions: [
                  InkWell(
                    mouseCursor: SystemMouseCursors.click,
                    onTap: () {
                      selectItemsForOrderDeliveryBottomSheet(
                        priceController:
                            widget.priceController,
                        quantityController:
                            widget.quantityController,
                        context: context,
                        action: () {
                          setState(() {});
                        },
                        searchController:
                            widget.searchController,
                        order: widget.order,
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        8,
                        8,
                        12,
                        8,
                      ),
                      child: Row(
                        spacing: 5,
                        children: [
                          Text(
                            style: TextStyle(
                              fontSize:
                                  theme
                                      .mobileTexts
                                      .b3
                                      .fontSize,
                            ),
                            'Add Item',
                          ),
                          Icon(size: 16, Icons.add),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              body: Stack(
                children: [
                  Column(
                    children: [
                      Expanded(
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(
                                horizontal: 10.0,
                              ),
                          child: SingleChildScrollView(
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(
                                    top: 10.0,
                                  ),
                              child: Builder(
                                builder: (context) {
                                  if (returnOrdersActionProvider(
                                        context: context,
                                      )
                                      .orderListItems
                                      .isEmpty) {
                                    return Padding(
                                      padding:
                                          const EdgeInsets.only(
                                            top: 100.0,
                                          ),
                                      child: Center(
                                        child: EmptyWidgetDisplayOnly(
                                          title:
                                              'No Items Selected',
                                          subText:
                                              'Click on "Add Items" to Start Selecing Items For Delivery',
                                          theme: theme,
                                          height: 25,
                                          icon: Icons.clear,
                                          altAction: () {
                                            selectItemsForOrderDeliveryBottomSheet(
                                              priceController:
                                                  widget
                                                      .priceController,
                                              quantityController:
                                                  widget
                                                      .quantityController,
                                              context:
                                                  context,
                                              action: () {
                                                setState(
                                                  () {},
                                                );
                                              },
                                              searchController:
                                                  widget
                                                      .searchController,
                                              order:
                                                  widget
                                                      .order,
                                            );
                                          },
                                          altActionText:
                                              'Add Item',
                                          altIcon:
                                              Icons.add,
                                        ),
                                      ),
                                    );
                                  } else {
                                    return Column(
                                      children:
                                          returnOrdersActionProvider(
                                                context:
                                                    context,
                                              )
                                              .orderItemReversed()
                                              .map(
                                                (
                                                  item,
                                                ) => OrderItemDeliveryTile(
                                                  theme:
                                                      theme,
                                                  item:
                                                      item,
                                                  order:
                                                      widget
                                                          .order,
                                                  priceController:
                                                      widget
                                                          .priceController,
                                                  quantityController:
                                                      widget
                                                          .quantityController,
                                                ),
                                              )
                                              .toList(),
                                    );
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            bottom: 10.0,
                            top: 10,
                            left: 20,
                            right: 20,
                          ),
                          child: Column(
                            children: [
                              OrderCommentWidget(
                                order: widget.order,
                                bankController:
                                    widget.bankController,
                                cashController:
                                    widget.cashController,
                              ),
                              TotalRowOrdersDelivery(
                                priceController:
                                    widget.priceController,
                              ),
                              MainButtonP(
                                themeProvider: theme,
                                action: () {
                                  checkFields(
                                    bankController:
                                        widget
                                            .bankController,
                                    cashController:
                                        widget
                                            .cashController,
                                    context: context,
                                    order: widget.order,
                                    toggleLoading: () {
                                      setState(() {
                                        isLoading = true;
                                      });
                                    },
                                  );
                                },
                                text: 'Create Delivery',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Visibility(
            visible: isLoading,
            child: returnCompProvider(
              context,
              listen: false,
            ).showLoader(message: 'Creating Delivery'),
          ),
          Visibility(
            visible: showSuccess,
            child: returnCompProvider(
              context,
              listen: false,
            ).showSuccess('Delivery Created Successfully'),
          ),
        ],
      ),
    );
  }
}

void checkFields({
  required BuildContext context,
  required TextEditingController cashController,
  required TextEditingController bankController,
  required Orders order,
  required Function() toggleLoading,
}) async {
  if (returnOrdersActionProvider().orderListItems.isEmpty) {
    showDialog(
      context: context,
      builder: (context) {
        var theme = returnTheme(context);
        return InfoAlert(
          theme: theme,
          message:
              'No Item has been added to the List. Please add items to the list before proceeding',
          title: 'Empty List',
        );
      },
    );
  } else if (returnOrdersActionProvider().paymentOption ==
          3 &&
      !returnOrdersActionProvider().isBalanceSufficient(
        order.customerId ?? '',
      )) {
    showDialog(
      context: context,
      builder: (context) {
        var theme = returnTheme(context);
        return InfoAlert(
          theme: theme,
          message:
              'Customer Balance is Insufficient. Please Top Up Customer Account, or select Another Payment Method To Proceed.',
          title: 'Customer Balance Insufficient',
        );
      },
    );
  } else if (returnOrdersActionProvider().paymentOption ==
          2 &&
      (returnOrdersActionProvider().totalOrdersAmount() !=
          ((double.tryParse(
                    cashController.text.replaceAll(',', ''),
                  ) ??
                  0) +
              (double.tryParse(
                    bankController.text.replaceAll(',', ''),
                  ) ??
                  0)))) {
    showDialog(
      context: context,
      builder: (context) {
        var theme = returnTheme(context);
        return InfoAlert(
          theme: theme,
          message:
              'The Two Values Entered into the Split Payment Text Fields Does Not Sum Up to be Equal to The Total Amount of the Delivery. Please Update Values, or select Another Payment Method To Proceed.',
          title: 'Split Payment Sum Not Set',
        );
      },
    );
  } else {
    showDialog(
      context: context,
      builder: (confirmDialog) {
        return ConfirmationAlert(
          theme: returnTheme(context, listen: false),
          message:
              'You are about to record a order Delivery and update the items, are you sure you want to proceed?',
          title: 'Proceed With Action',
          action: () async {
            Navigator.of(confirmDialog).pop();
            toggleLoading();
            int index =
                returnOrdersActionProvider().paymentOption;
            double totalAmount =
                returnOrdersActionProvider()
                    .totalOrdersAmount();
            double bankAmount() {
              if (index == 1) {
                return totalAmount;
              } else if (index == 2) {
                return (double.tryParse(
                      bankController.text.replaceAll(
                        ',',
                        '',
                      ),
                    ) ??
                    0);
              } else {
                return 0;
              }
            }

            double cashAmount() {
              if (index == 0) {
                return totalAmount;
              } else if (index == 2) {
                return (double.tryParse(
                      cashController.text.replaceAll(
                        ',',
                        '',
                      ),
                    ) ??
                    0);
              } else {
                return 0;
              }
            }

            double customerAmount() {
              if (index == 3) {
                return totalAmount;
              } else {
                return 0;
              }
            }

            await returnOrdersProvider()
                .makeOrderItemDelivery(
                  bankAmount: bankAmount(),
                  cashAmount: cashAmount(),
                  customerAmount: customerAmount(),
                  order: order,
                  context: context,
                );
            cashController.clear();
            bankController.clear();
          },
        );
      },
    );
  }
}
